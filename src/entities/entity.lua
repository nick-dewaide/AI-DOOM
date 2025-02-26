local Entity = {}
function Entity:new(o, x, y)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    self.x = x or 0
    self.y = y or 0
    self.width = 32
    self.height = 32
    self.health = 100
    return o
end

function Entity:update(dt)
    -- Update entity logic here
end

function Entity:draw()
    -- Draw entity here
end

function Entity:takeDamage(amount)
    self.health = self.health - amount
    if self.health <= 0 then
        self:destroy()
    end
end

function Entity:destroy()
    -- Handle entity destruction
end

return Entity