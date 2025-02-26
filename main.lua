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
            
        -- Handle shooting
        if player.isShooting then
            local weapon = playerWeapons[currentWeapon]
            if weapon:shoot() then
                -- Implement shooting logic
                -- Check for enemy hits
                for _, enemy in ipairs(enemies) do
                    if isEnemyInFront(player, enemy, weapon.range) then
                        enemy:takeDamage(weapon.damage)
                    end
                end
                player.isShooting = false -- Reset shooting flag after one shot
            end
        end
        
        -- Update enemies
        for i = #enemies, 1, -1 do
            local enemy = enemies[i]
            if enemy.health <= 0 then
                table.remove(enemies, i)
            else
                -- Basic AI: If player is close, move toward player
                local dx = player.position.x - enemy.x
                local dy = player.position.y - enemy.y
                local distance = math.sqrt(dx * dx + dy * dy)
                
                if distance < 10 then -- Detection range
                    enemy:moveTowards(player.position.x, player.position.y, dt)  -- Pass dt here
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
                    playerWeapons[currentWeapon]:reload() -- Reload current weapon
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
        -- Render the 3D view directly without camera transformations
        renderer:render()
        
        -- Render sprites (enemies, etc)
        if renderer.renderEntities then
            renderer:renderEntities(player)
        end
        
        -- Draw HUD
        love.graphics.setColor(1, 1, 1)
        love.graphics.print("Health: " .. player.health, 10, 10)
        love.graphics.print("Ammo: " .. playerWeapons[currentWeapon].currentAmmo, 10, 30)
        love.graphics.print("Weapon: " .. playerWeapons[currentWeapon].name, 10, 50)
    else
        -- Draw game state (menu, pause screen, etc)
        gameState:draw()
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
    
    -- Calculate angle to enemy
    local enemyAngle = math.atan2(dy, dx)
    
    -- Normalize player angle and enemy angle to 0-2π
    local playerAngle = player.angle % (2 * math.pi)
    enemyAngle = enemyAngle % (2 * math.pi)
    
    -- Check if enemy is within field of view (π/4 radians in each direction)
    local angleDiff = math.abs(playerAngle - enemyAngle)
    angleDiff = math.min(angleDiff, 2 * math.pi - angleDiff)
    
    return angleDiff <= math.pi / 4
end

