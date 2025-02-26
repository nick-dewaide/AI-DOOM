local Item = {}
function Item:new(o, name, description, value)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    self.name = name or "Unnamed Item"
    self.description = description or "No description available."
    self.value = value or 0
    return o
end

function Item:use()
    -- Logic for using the item
end

function Item:getInfo()
    return string.format("Item: %s\nDescription: %s\nValue: %d", self.name, self.description, self.value)
end

return Item