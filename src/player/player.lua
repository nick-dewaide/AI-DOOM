local Player = {}

function Player:new(o, x, y)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    self.position = {x = x or 0, y = y or 0}
    self.health = 100
    self.inventory = {}
    self.speed = 5
    return o
end

function Player:move(dx, dy)
    self.position.x = self.position.x + dx * self.speed * love.timer.getDeltaTime()
    self.position.y = self.position.y + dy * self.speed * love.timer.getDeltaTime()
end

function Player:takeDamage(amount)
    self.health = self.health - amount
    if self.health < 0 then
        self.health = 0
    end
end

function Player:heal(amount)
    self.health = self.health + amount
    if self.health > 100 then
        self.health = 100
    end
end

function Player:addToInventory(item)
    table.insert(self.inventory, item)
end

function Player:useItem(index)
    if self.inventory[index] then
        -- Logic to use the item
        table.remove(self.inventory, index)
    end
end

return Player