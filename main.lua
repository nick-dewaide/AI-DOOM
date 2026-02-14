-- Import all necessary modules
local GameState = require("src/engine/gamestate")
local Player = require("src/player/player")
local Camera = require("src/engine/camera")
local MapLoader = require("src/map/maploader")
local Renderer = require("src/rendering/raycaster")
local Weapon = require("src/weapons/weapon")
local Enemy = require("src/entities/enemies/enemy")
local Item = require("src/entities/items/item")
local Pickup = require("src/entities/items/pickup")
local Door = require("src/interaction/door")
local Switch = require("src/interaction/switch")
local LevelManager = require("src/progression/levelmanager")

-- Global variables
local gameState
local player
local camera
local renderer
local levelManager
local currentMap
local enemies = {}
local items = {}
local doors = {}
local switches = {}
local playerWeapons = {}
local currentWeapon = 1
local mouseSensitivity = 0.003 -- Adjust this value as needed

-- Gun visual state
local muzzleFlashTimer    = 0
local MUZZLE_FLASH_DUR    = 0.08  -- seconds the flash is visible


function love.load()
    -- Initialize game engine
    love.window.setTitle("Doom Clone")
    love.window.setMode(800, 600)

    love.mouse.setRelativeMode(true) -- Captures mouse and hides cursor
    -- Initialize game state
    gameState = GameState:new()
    gameState:changeState("menu")
    
    -- Initialize level manager
    levelManager = LevelManager:new()
    
    -- Load the first level
    currentMap = require("src/map/maps/level1")
    if not currentMap or not currentMap.tiles or not currentMap.spawnPoints then
        print("ERROR: Map failed to load properly!")
        love.event.quit()
        return
    end
    
    -- Initialize player
    player = Player:new(nil, currentMap.spawnPoints[1].x, currentMap.spawnPoints[1].y)
    player.angle = 0  -- Make sure angle is initialized
    player.moveForward = false
    player.moveBackward = false
    player.moveLeft = false
    player.moveRight = false
    player.isShooting = false
    
    -- Initialize camera
    camera = Camera:new(player.position.x, player.position.y, player.angle)
    
    -- Initialize renderer
    renderer = Renderer:new(currentMap)
    
    -- Create weapons
    table.insert(playerWeapons, Weapon("Pistol", 10, 10, 30))
    table.insert(playerWeapons, Weapon("Shotgun", 25, 5, 15))
    
    -- Create enemies from map data
    for _, enemyData in ipairs(currentMap.enemies or {}) do
        local enemy = Enemy:new(enemyData.x, enemyData.y, enemyData.health, enemyData.damage)
        table.insert(enemies, enemy)
    end
    
    -- Create items and pickups from map data
    for _, itemData in ipairs(currentMap.items or {}) do
        if itemData.type == "health" then
            local healthPickup = Pickup:new(itemData.x, itemData.y, "health")
            table.insert(items, healthPickup)
        elseif itemData.type == "ammo" then
            local ammoPickup = Pickup:new(itemData.x, itemData.y, "ammo")
            table.insert(items, ammoPickup)
        end
    end
    
    -- Create doors from map data
    for _, doorData in ipairs(currentMap.doors or {}) do
        local door = Door:new(doorData.x, doorData.y, 1, 1)
        door.isOpen = doorData.isOpen
        door.isLocked = doorData.isLocked or false
        table.insert(doors, door)
    end
    
    -- Create switches from map data
    for _, switchData in ipairs(currentMap.switches or {}) do
        local switch = Switch:new(switchData.x, switchData.y)
        switch.activated = switchData.isActive
        
        -- Link switches to doors if specified
        if switchData.doorIndex then
            switch:link(doors[switchData.doorIndex])
        end
        
        table.insert(switches, switch)
    end
    
    -- Load controls
    local controls = require("src/player/controls")
    controls.setPlayer(player)
    controls.setGameState(gameState)
    controls.setWeapons(playerWeapons, {value = currentWeapon})  -- Pass by reference
    
    function love.keypressed(key)
        controls.keypressed(key)
    end
    
    function love.keyreleased(key)
        controls.keyreleased(key)
    end
    
    function love.mousemoved(x, y, dx, dy)
        controls.mousemoved(x, y, dx, dy)
    end
end


function love.update(dt)
    if gameState.currentState == "playing" then
        -- Update player position based on input
        local dx, dy = 0, 0
        
        if player.moveForward then
            dx = math.cos(player.angle) * player.speed * dt
            dy = math.sin(player.angle) * player.speed * dt
        end
        
        if player.moveBackward then
            dx = -math.cos(player.angle) * player.speed * dt * 0.5
            dy = -math.sin(player.angle) * player.speed * dt * 0.5
        end
        
        if player.moveLeft then
            dx = math.cos(player.angle - math.pi/2) * player.speed * dt * 0.5
            dy = math.sin(player.angle - math.pi/2) * player.speed * dt * 0.5
        end
        
        if player.moveRight then
            dx = math.cos(player.angle + math.pi/2) * player.speed * dt * 0.5
            dy = math.sin(player.angle + math.pi/2) * player.speed * dt * 0.5
        end
        
        -- Apply movement if no collision
        local newX = player.position.x + dx
        local newY = player.position.y + dy
        
        -- Basic collision detection with walls
        if not isWall(currentMap, math.floor(newX), math.floor(newY)) then
            player.position.x = newX
            player.position.y = newY
            camera.x = player.position.x
            camera.y = player.position.y
        end

        -- Update camera position to match player
        camera.x = player.position.x
        camera.y = player.position.y
        camera.angle = player.angle
            
        -- Update weapon (reload timer, etc.)
        playerWeapons[currentWeapon]:update(dt)

        -- Tick muzzle flash
        if muzzleFlashTimer > 0 then
            muzzleFlashTimer = muzzleFlashTimer - dt
        end

        -- Handle shooting
        if player.isShooting then
            local weapon = playerWeapons[currentWeapon]
            if weapon:shoot() then
                muzzleFlashTimer = MUZZLE_FLASH_DUR

                -- Pistol hitscan: find the single closest enemy that is:
                --   1. within weapon range
                --   2. inside a narrow ±9° aim cone (not the broad 45° FOV)
                --   3. not blocked by a wall (line-of-sight check)
                local target     = nil
                local targetDist = math.huge

                for _, enemy in ipairs(enemies) do
                    if not enemy.isDying then
                        local edx  = enemy.x - player.position.x
                        local edy  = enemy.y - player.position.y
                        local dist = math.sqrt(edx * edx + edy * edy)

                        if dist <= weapon.range then
                            local eAngle = math.atan(edy, edx) % (2 * math.pi)
                            local pAngle = player.angle         % (2 * math.pi)
                            local diff   = math.abs(pAngle - eAngle)
                            diff = math.min(diff, 2 * math.pi - diff)

                            -- π/20 ≈ ±9°: tight enough that you have to actually
                            -- aim at an enemy, not just face their general direction
                            if diff <= math.pi / 20 then
                                if hasLineOfSight(currentMap,
                                        player.position.x, player.position.y,
                                        enemy.x, enemy.y) then
                                    if dist < targetDist then
                                        target     = enemy
                                        targetDist = dist
                                    end
                                end
                            end
                        end
                    end
                end

                if target then
                    target:takeDamage(weapon.damage)
                    target.hitFlash      = 0.15
                    target.hitFlashTotal = 0.15
                end

                player.isShooting = false
            end
        end

        -- Update enemies
        for i = #enemies, 1, -1 do
            local enemy = enemies[i]

            -- Tick hit flash
            if enemy.hitFlash and enemy.hitFlash > 0 then
                enemy.hitFlash = enemy.hitFlash - dt
            end

            if enemy.health <= 0 then
                -- Brief death flash before removal
                if not enemy.isDying then
                    enemy.isDying     = true
                    enemy.deathTimer  = 0.35
                end
                enemy.deathTimer = enemy.deathTimer - dt
                if enemy.deathTimer <= 0 then
                    table.remove(enemies, i)
                end
            else
                -- Basic AI: if player is close, move toward player
                local dx = player.position.x - enemy.x
                local dy = player.position.y - enemy.y
                local distance = math.sqrt(dx * dx + dy * dy)

                if distance < 10 then -- Detection range
                    enemy:moveTowards(player.position.x, player.position.y, dt, currentMap)
                    if distance < 1.5 then -- Attack range
                        enemy:attack(player)
                    end
                end
            end
        end
        
        -- Check for item pickups
        for i = #items, 1, -1 do
            local item = items[i]
            if not item.collected and 
               math.abs(player.position.x - item.x) < 0.5 and 
               math.abs(player.position.y - item.y) < 0.5 then
                
                item:collect()
                
                if item.type == "health" then
                    player:heal(25) -- Heal by 25 points
                elseif item.type == "ammo" then
                    playerWeapons[currentWeapon]:pickupAmmo(10) -- Add 10 rounds to reserve
                end
                
                table.remove(items, i)
            end
        end
        
        -- Check for interactions with switches
        for _, switch in ipairs(switches) do
            if not switch.activated and
               math.abs(player.position.x - switch.x) < 0.5 and
               math.abs(player.position.y - switch.y) < 0.5 then
                switch:activate()
            end
        end
        
        -- Update raycaster with new player position
        renderer:castRays(player)

        if renderer.prepareSprites then
            -- Process enemies for rendering
            renderer:prepareSprites(enemies, player)
        end
    elseif gameState.currentState == "menu" then
        -- Menu update logic
    elseif gameState.currentState == "paused" then
        -- Pause menu update logic
    end
    
    -- Update game state
    gameState:update(dt)
end

function love.draw()
    if gameState.currentState == "playing" then
        renderer:render()
        if renderer.renderEntities then
            renderer:renderEntities(player)
        end

        -- Draw gun sprite at bottom-center with muzzle flash
        drawGunHUD(muzzleFlashTimer)

        -- Draw HUD text
        local weapon = playerWeapons[currentWeapon]
        love.graphics.setColor(1, 1, 1)
        love.graphics.print("Health: " .. player.health, 10, 10)
        love.graphics.print(
            "Ammo: " .. weapon.currentAmmo .. " / " .. weapon.reserveAmmo,
            10, 30)
        love.graphics.print("Weapon: " .. weapon.name, 10, 50)
        if weapon.isReloading then
            local pct   = 1 - (weapon.reloadTimer / weapon.reloadTime)
            local sw    = love.graphics.getWidth()
            local barW  = 160
            local barX  = (sw - barW) / 2
            love.graphics.setColor(0.2, 0.2, 0.2, 0.8)
            love.graphics.rectangle("fill", barX - 2, 78, barW + 4, 14)
            love.graphics.setColor(1, 0.55, 0)
            love.graphics.rectangle("fill", barX, 80, barW * pct, 10)
            love.graphics.setColor(1, 1, 1)
            love.graphics.print("RELOADING", barX + barW / 2 - 30, 79)
        end

        -- Draw minimap
        drawMinimap(currentMap, player, enemies, 4, 600, 400) -- scale and offset
    else
        gameState:draw()
    end
end

function drawMinimap(map, player, enemies, scale, offsetX, offsetY)
    love.graphics.setColor(0.2, 0.2, 0.2, 0.7)
    love.graphics.rectangle("fill", offsetX, offsetY, map.width * scale, map.height * scale)

    -- Draw walls
    for y = 1, map.height do
        if map.tiles[y] then
            for x = 1, map.width do
                if map.tiles[y][x] == 1 then
                    love.graphics.setColor(0.5, 0.5, 0.5)
                    love.graphics.rectangle("fill", offsetX + (x - 1) * scale, offsetY + (y - 1) * scale, scale, scale)
                end
            end
        end
    end

    -- Draw player
    love.graphics.setColor(0, 1, 0)
    love.graphics.circle("fill", 
        offsetX + (player.position.x - 0.5) * scale, 
        offsetY + (player.position.y - 0.5) * scale, 
        scale * 0.5)

    -- Draw enemies
    love.graphics.setColor(1, 0, 0)
    for _, enemy in ipairs(enemies) do
        love.graphics.circle("fill", 
            offsetX + (enemy.x - 0.5) * scale, 
            offsetY + (enemy.y - 0.5) * scale, 
            scale * 0.4)
    end
end


-- Helper functions

-- Check if a point is a wall in the map
function isWall(map, x, y)
    if x < 1 or y < 1 or x > map.width or y > map.height then
        return true -- Out of bounds is considered a wall
    end
    
    -- Convert x,y to grid coordinates
    local gridX = math.floor(x)
    local gridY = math.floor(y)
    
    -- Check if the tile at this position is a wall (value 1)
    if gridY <= #map.tiles and gridX <= #map.tiles[1] then
        return map.tiles[gridY][gridX] == 1
    end
    
    return true -- Default to wall if we can't determine
end

-- Check if an enemy is in front of the player and within range
function isEnemyInFront(player, enemy, range)
    local dx = enemy.x - player.position.x
    local dy = enemy.y - player.position.y
    local distance = math.sqrt(dx * dx + dy * dy)

    if distance > range then
        return false
    end

    local enemyAngle  = math.atan(dy, dx) % (2 * math.pi)
    local playerAngle = player.angle       % (2 * math.pi)
    local angleDiff   = math.abs(playerAngle - enemyAngle)
    angleDiff = math.min(angleDiff, 2 * math.pi - angleDiff)

    return angleDiff <= math.pi / 4
end

-- Step along the straight line from (fromX,fromY) to (toX,toY) in 0.05-unit
-- increments and return false as soon as any map tile on the path is a wall.
-- Uses the existing isWall() helper so the logic stays consistent.
function hasLineOfSight(map, fromX, fromY, toX, toY)
    local dx   = toX - fromX
    local dy   = toY - fromY
    local dist = math.sqrt(dx * dx + dy * dy)
    if dist == 0 then return true end

    local steps = math.ceil(dist / 0.05)
    for i = 1, steps - 1 do
        local t = i / steps
        if isWall(map, fromX + dx * t, fromY + dy * t) then
            return false
        end
    end
    return true
end

-- Draw a pixel-art pistol at the bottom-centre of the screen.
-- flashTimer > 0  → show muzzle flash
-- weapon          → used for kick / reload state
function drawGunHUD(flashTimer)
    local sw = love.graphics.getWidth()
    local sh = love.graphics.getHeight()
    local s  = 4  -- one "pixel" in screen pixels

    -- Kick the gun up slightly when fired
    local kickY = (flashTimer > 0) and (-s) or 0

    -- Pivot point: bottom-centre, slightly right so the barrel is on-axis
    local gx = math.floor(sw / 2) - 10 * s
    local gy = sh - 12 * s

    -- ── barrel ──────────────────────────────────────────────
    love.graphics.setColor(0.28, 0.28, 0.32)
    love.graphics.rectangle("fill", gx + 6*s, gy - 3*s + kickY,  16*s, 2*s)

    -- barrel highlight
    love.graphics.setColor(0.50, 0.50, 0.55)
    love.graphics.rectangle("fill", gx + 6*s, gy - 3*s + kickY,  16*s, s)

    -- ── body ────────────────────────────────────────────────
    love.graphics.setColor(0.28, 0.28, 0.32)
    love.graphics.rectangle("fill", gx + 2*s, gy - s + kickY,    14*s, 4*s)

    -- body highlight
    love.graphics.setColor(0.50, 0.50, 0.55)
    love.graphics.rectangle("fill", gx + 2*s, gy - s + kickY,    14*s, s)

    -- slide detail
    love.graphics.setColor(0.18, 0.18, 0.20)
    love.graphics.rectangle("fill", gx + 12*s, gy - s + kickY,   2*s,  3*s)

    -- ── grip ────────────────────────────────────────────────
    love.graphics.setColor(0.22, 0.18, 0.14)   -- dark brownish grip
    love.graphics.rectangle("fill", gx + 4*s, gy + 3*s + kickY,  6*s,  7*s)

    -- grip highlight
    love.graphics.setColor(0.35, 0.28, 0.22)
    love.graphics.rectangle("fill", gx + 4*s, gy + 3*s + kickY,  6*s,  s)

    -- grip screws (detail pixels)
    love.graphics.setColor(0.45, 0.38, 0.30)
    love.graphics.rectangle("fill", gx + 5*s, gy + 5*s + kickY,  s,    s)
    love.graphics.rectangle("fill", gx + 8*s, gy + 7*s + kickY,  s,    s)

    -- ── muzzle flash ────────────────────────────────────────
    if flashTimer > 0 then
        local mx = gx + 22 * s
        local my = gy - 2 * s + kickY
        -- outer glow
        love.graphics.setColor(1, 0.6, 0, 0.55)
        love.graphics.circle("fill", mx, my, 5.5 * s)
        -- mid ring
        love.graphics.setColor(1, 0.85, 0.1, 0.80)
        love.graphics.circle("fill", mx, my, 3.5 * s)
        -- hot core
        love.graphics.setColor(1, 1, 0.8, 0.95)
        love.graphics.circle("fill", mx, my, 1.5 * s)
        -- starburst spikes
        love.graphics.setColor(1, 0.9, 0.3, 0.70)
        love.graphics.rectangle("fill", mx - 8*s, my - s*0.5, 16*s, s)
        love.graphics.rectangle("fill", mx - s*0.5, my - 6*s,  s,   12*s)
        -- subtle full-screen bloom
        love.graphics.setColor(1, 0.85, 0.4, 0.06)
        love.graphics.rectangle("fill", 0, 0, sw, sh)
    end
end

