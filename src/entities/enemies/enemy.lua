local Enemy = {}

-- Collision radius keeps enemies visually clear of wall faces.
-- Must match (or be smaller than) half the sprite billboard width at typical
-- viewing distance, so the sprite never overlaps a wall tile visually.
local ENEMY_RADIUS = 0.3

-- Returns true if the given point falls inside (or out of bounds of) a wall tile.
local function isWallCell(map, x, y)
    if x < 1 or y < 1 or x > map.width or y > map.height then
        return true
    end
    local gx = math.floor(x)
    local gy = math.floor(y)
    if gy <= #map.tiles and gx <= #map.tiles[1] then
        return map.tiles[gy][gx] == 1
    end
    return true
end

-- Check whether a circle of ENEMY_RADIUS centered at (x,y) overlaps any wall.
-- Tests all four corners of the bounding square so thin diagonal corridors are
-- handled correctly and enemies never visually clip into a wall face.
local function isWallAt(map, x, y)
    local r = ENEMY_RADIUS
    return isWallCell(map, x + r, y + r)
        or isWallCell(map, x + r, y - r)
        or isWallCell(map, x - r, y + r)
        or isWallCell(map, x - r, y - r)
end

function Enemy:new(x, y, health, damage)
    local obj = {
        x = x,
        y = y,
        health = health or 100,
        damage = damage or 10,
        state = "idle",
        speed = 0.5  -- Add a speed property with a lower value (was effectively 1.0)
    }
    setmetatable(obj, self)
    self.__index = self
    return obj
end

-- map is optional; when provided, enemies respect walls and slide along them
function Enemy:moveTowards(targetX, targetY, dt, map)
    local dx = targetX - self.x
    local dy = targetY - self.y
    local distance = math.sqrt(dx * dx + dy * dy)

    if distance > 0 then
        local moveX = (dx / distance) * self.speed * (dt or 1)
        local moveY = (dy / distance) * self.speed * (dt or 1)

        if map then
            local newX = self.x + moveX
            local newY = self.y + moveY

            -- Try full diagonal movement first
            if not isWallAt(map, newX, newY) then
                self.x = newX
                self.y = newY
            -- Wall sliding: try X axis only
            elseif not isWallAt(map, newX, self.y) then
                self.x = newX
            -- Wall sliding: try Y axis only
            elseif not isWallAt(map, self.x, newY) then
                self.y = newY
            -- Fully blocked; stay put
            end
        else
            self.x = self.x + moveX
            self.y = self.y + moveY
        end
    end
end

function Enemy:attack(target)
    if self.state == "chasing" and self:inAttackRange(target) then
        target:takeDamage(self.damage)
    end
end

function Enemy:inAttackRange(target)
    local distance = math.sqrt((self.x - target.x)^2 + (self.y - target.y)^2)
    return distance < 1.5 -- Example attack range
end

function Enemy:takeDamage(amount)
    self.health = self.health - amount
    if self.health <= 0 then
        self:die()
    end
end

function Enemy:die()
    -- Handle enemy death (e.g., remove from game, play death animation)
end

return Enemy