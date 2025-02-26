local EnemyAI = {}

function EnemyAI:new()
    local obj = {
        state = "idle",
        position = {x = 0, y = 0},
        target = nil,
        detectionRange = 100,
        attackRange = 20,
        health = 100
    }
    setmetatable(obj, self)
    self.__index = self
    return obj
end

function EnemyAI:update(dt)
    if self.state == "idle" then
        self:searchForPlayer()
    elseif self.state == "chasing" then
        self:chasePlayer(dt)
    elseif self.state == "attacking" then
        self:attackPlayer()
    end
end

function EnemyAI:searchForPlayer()
    -- Logic to detect player within detection range
    if self:playerInRange() then
        self.state = "chasing"
    end
end

function EnemyAI:chasePlayer(dt)
    -- Logic to move towards the player
    if self:playerInAttackRange() then
        self.state = "attacking"
    end
end

function EnemyAI:attackPlayer()
    -- Logic to deal damage to the player
end

function EnemyAI:playerInRange()
    -- Check if the player is within detection range
    return false -- Placeholder
end

function EnemyAI:playerInAttackRange()
    -- Check if the player is within attack range
    return false -- Placeholder
end

return EnemyAI