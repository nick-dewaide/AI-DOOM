local Enemy = {}

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

function Enemy:moveTowards(targetX, targetY, dt)  -- Add dt parameter
    local dx = targetX - self.x
    local dy = targetY - self.y
    local distance = math.sqrt(dx * dx + dy * dy)

    if distance > 0 then
        -- Use speed property and multiply by dt
        self.x = self.x + (dx / distance) * self.speed * (dt or 1)
        self.y = self.y + (dy / distance) * self.speed * (dt or 1)
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