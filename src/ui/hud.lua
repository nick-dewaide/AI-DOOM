function love.load()
    -- Initialize HUD elements
    hud = {
        health = 100,
        ammo = 50,
        inventory = {},
        font = love.graphics.newFont("assets/fonts/default.ttf", 24)
    }
end

function love.update(dt)
    -- Update HUD elements if necessary
end

function love.draw()
    -- Draw health
    love.graphics.setFont(hud.font)
    love.graphics.print("Health: " .. hud.health, 10, 10)
    
    -- Draw ammo
    love.graphics.print("Ammo: " .. hud.ammo, 10, 40)
    
    -- Draw inventory items
    love.graphics.print("Inventory: " .. table.concat(hud.inventory, ", "), 10, 70)
end

function updateHealth(amount)
    hud.health = math.max(0, hud.health + amount)
end

function updateAmmo(amount)
    hud.ammo = math.max(0, hud.ammo + amount)
end

function addItemToInventory(item)
    table.insert(hud.inventory, item)
end