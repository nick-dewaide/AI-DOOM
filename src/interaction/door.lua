local Door = {}
function Door:new(x, y, width, height)
    local obj = {
        x = x,
        y = y,
        width = width,
        height = height,
        isOpen = false,
        isLocked = false,
    }
    setmetatable(obj, self)
    self.__index = self
    return obj
end

function Door:open()
    if not self.isLocked then
        self.isOpen = true
    end
end

function Door:close()
    self.isOpen = false
end

function Door:toggle()
    if not self.isLocked then
        self.isOpen = not self.isOpen
    end
end

function Door:lock()
    self.isLocked = true
end

function Door:unlock()
    self.isLocked = false
end

function Door:draw()
    if self.isOpen then
        -- Draw the open door (could be a different sprite or color)
    else
        -- Draw the closed door
    end
end

return Door