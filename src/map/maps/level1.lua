function level1()
    return {
        width = 64,
        height = 64,
        tiles = {
            {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
            {1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},
            {1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 1},
            {1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 1, 1, 1},
            {1, 0, 1, 0, 1, 1, 1, 1, 1, 0, 1, 0, 0, 0, 0, 1},
            {1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1},
            {1, 0, 0, 0, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 1},
            {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
        },
        spawnPoints = {
            {x = 2, y = 2},
        },
        enemies = {
            {x = 5, y = 3, health = 100, damage = 10, type = "basic"},   -- Enemy in the corridor
            {x = 8, y = 3, health = 100, damage = 10, type = "basic"},   -- Enemy in an open room
            {x = 14, y = 2, health = 150, damage = 15, type = "advanced"}, -- Stronger enemy at the far end
            {x = 5, y = 6, health = 100, damage = 10, type = "basic"},   -- Enemy in the bottom area
            {x = 12, y = 5, health = 75, damage = 5, type = "weak"}     -- Weaker enemy near the exit
        },
        items = {
            {type = "health", x = 5, y = 5},
            {type = "ammo", x = 3, y = 3},
            {type = "health", x = 13, y = 2}, -- Added health pickup
            {type = "ammo", x = 10, y = 6}    -- Added ammo pickup
        },
        doors = {
            {x = 4, y = 1, isOpen = false},
        },
        switches = {
            {x = 6, y = 1, isActive = false},
        },
    }
end

return level1()