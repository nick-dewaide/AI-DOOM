function Level(name, width, height)
    local self = {
        name = name,
        width = width,
        height = height,
        sectors = {},
        linedefs = {},
        interactables = {}
    }

    function self:addSector(sector)
        table.insert(self.sectors, sector)
    end

    function self:addLinedef(linedef)
        table.insert(self.linedefs, linedef)
    end

    function self:addInteractable(interactable)
        table.insert(self.interactables, interactable)
    end

    function self:getSectors()
        return self.sectors
    end

    function self:getLinedefs()
        return self.linedefs
    end

    function self:getInteractables()
        return self.interactables
    end

    return self
end

return Level