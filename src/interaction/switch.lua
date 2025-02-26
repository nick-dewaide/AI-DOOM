local Switch = {}
function Switch:new(x, y)
    local obj = {
        x = x,
        y = y,
        activated = false,
        linkedDoor = nil
    }
    setmetatable(obj, self)
    self.__index = self
    return obj
end

function Switch:activate()
    self.activated = true
    if self.linkedDoor then
        self.linkedDoor:toggle()
    end
end

function Switch:link(door)
    self.linkedDoor = door
end

function Switch:draw()
    if self.activated then
        -- Draw the activated switch (e.g., change color)
    else
        -- Draw the normal switch
    end
end

function Switch:update(dt)
    -- Update logic for the switch, if needed
end

return Switch