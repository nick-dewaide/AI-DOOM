local Pickup = {} 
function Pickup:new(x, y, type)
    local obj = {
        x = x,
        y = y,
        type = type,
        collected = false
    }
    setmetatable(obj, self)
    self.__index = self
    return obj
end

function Pickup:collect()
    self.collected = true
    -- Handle the effect of the pickup (e.g., increase health or ammo)
end

function Pickup:draw()
    if not self.collected then
        -- Draw the pickup item at its position
    end
end

function Pickup:update(dt)
    -- Update logic for the pickup if needed (e.g., animations)
end

return Pickup