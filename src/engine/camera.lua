local Camera = {}
function Camera:new(x, y, angle)
    local obj = {
        x = x or 0,
        y = y or 0,
        angle = angle or 0,
        scale = 1,
        width = love.graphics.getWidth(),
        height = love.graphics.getHeight()
    }
    setmetatable(obj, self)
    self.__index = self
    return obj
end

function Camera:move(dx, dy)
    self.x = self.x + dx
    self.y = self.y + dy
end

function Camera:rotate(dangle)
    self.angle = self.angle + dangle
end

function Camera:set()
    love.graphics.push()
    love.graphics.translate(self.width / 2, self.height / 2)
    love.graphics.rotate(-self.angle)
    love.graphics.translate(-self.x, -self.y)
end

function Camera:unset()
    love.graphics.pop()
end

return Camera