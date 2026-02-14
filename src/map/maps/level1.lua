function level1()
    return {
        width = 64,
        height = 64,
        tiles = {
            {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},  -- y=1  top border
            {1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},  -- y=2  top corridor
            {1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 1},  -- y=3  inner wall (x=3..11 solid)
            {1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 1, 1, 1},  -- y=4  inner room (x=4..10) + right col
            {1, 0, 1, 0, 1, 1, 1, 1, 1, 0, 1, 0, 0, 0, 0, 1},  -- y=5  inner inner room (x=5..9)
            {1, 0, 0, 0, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 1},  -- y=6  lower area
            {1, 0, 0, 0, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 1},  -- y=7  lower area (continued)
            {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},  -- y=8  bottom border
        },
        spawnPoints = {
            -- Center of the first open tile; away from all wall corners
            {x = 2.5, y = 2.5},
        },
        enemies = {
            -- All positions verified open (ENEMY_RADIUS=0.3 bounding-box safe):
            -- top corridor (y=2, all x=2..15 open)
            {x = 6.5,  y = 2.5, health = 100, damage = 10, type = "basic"},    -- close patrol
            {x = 10.5, y = 2.5, health = 100, damage = 10, type = "basic"},    -- mid-corridor
            {x = 14.5, y = 2.5, health = 150, damage = 15, type = "advanced"}, -- far-end boss
            -- lower area accessible via left corridor (x=2, y=2..7)
            {x = 2.5,  y = 6.5, health = 100, damage = 10, type = "basic"},    -- flanker
            -- right-side corridor (x=12, y=3..5 all open)
            {x = 12.5, y = 5.5, health = 75,  damage = 5,  type = "weak"},     -- right patrol
        },
        items = {
            {type = "health", x = 7.5, y = 2.5},   -- top corridor
            {type = "ammo",   x = 3.5, y = 2.5},   -- near player start
            {type = "health", x = 13.5, y = 2.5},  -- far corridor pickup
            {type = "ammo",   x = 10.5, y = 6.5},  -- lower-right area
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
