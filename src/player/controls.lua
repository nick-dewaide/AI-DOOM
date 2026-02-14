local player  -- Will be assigned in setPlayer function
local gameState -- Will be assigned in setGameState function
local playerWeaponsRef -- Will be assigned in setWeapons function
local currentWeaponRef -- Will be assigned in setWeapons function

local controls = {}

function controls.setPlayer(playerRef)
    player = playerRef
end

function controls.setGameState(gameStateRef)
    gameState = gameStateRef
end

function controls.setWeapons(weapons, currentWeapon)
    playerWeaponsRef = weapons
    currentWeaponRef = currentWeapon
end

function controls.keypressed(key)
    if key == "escape" then
        if gameState.currentState == "playing" then
            gameState:changeState("paused")
        elseif gameState.currentState == "paused" then
            gameState:changeState("playing")
        elseif gameState.currentState == "menu" then
            love.event.quit()
        end
    elseif key == "return" or key == "kpenter" then 
        -- Check for both Enter keys
        if gameState.currentState == "menu" then
            gameState:changeState("playing")
        end
    elseif key == "1" or key == "2" then
        -- Switch weapons
        local weaponIndex = tonumber(key)
        if playerWeaponsRef[weaponIndex] then
            currentWeaponRef.value = weaponIndex
        end
    end
    
    if not player then return end
    
    if key == "w" then
        player.moveForward = true
    elseif key == "s" then
        player.moveBackward = true
    elseif key == "a" then
        player.moveLeft = true
    elseif key == "d" then
        player.moveRight = true
    elseif key == "space" then
        player.isShooting = true
    elseif key == "r" then
        local weapon = playerWeaponsRef[currentWeaponRef.value]
        if weapon then weapon:startReload() end
    end
end

function controls.keyreleased(key)
    if not player then return end
    
    if key == "w" then
        player.moveForward = false
    elseif key == "s" then
        player.moveBackward = false
    elseif key == "a" then
        player.moveLeft = false
    elseif key == "d" then
        player.moveRight = false
    elseif key == "space" then
        player.isShooting = false
    end
end

function controls.mousemoved(x, y, dx, dy)
    if not player then return end
    
    player.angle = player.angle + dx * 0.003  -- Use a sensitivity value
    player.angle = player.angle % (2 * math.pi)  -- Keep angle in 0-2π range
end

return controls