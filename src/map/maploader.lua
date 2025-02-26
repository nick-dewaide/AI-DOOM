function loadMap(filename)
    local mapData = {}
    local file = love.filesystem.newFile(filename)

    if file:open("r") then
        for line in file:lines() do
            table.insert(mapData, line)
        end
        file:close()
    else
        error("Could not open map file: " .. filename)
    end

    return mapData
end

function initializeLevel(mapData)
    local level = {
        sectors = {},
        linedefs = {},
        objects = {}
    }

    -- Parse mapData to fill level structure
    for _, line in ipairs(mapData) do
        -- Example parsing logic (to be implemented)
        -- if line starts with "sector" then parse sector data
        -- if line starts with "linedef" then parse linedef data
        -- if line starts with "object" then parse object data
    end

    return level
end

function loadLevel(levelFile)
    local mapData = loadMap(levelFile)
    return initializeLevel(mapData)
end

return {
    loadMap = loadMap,
    initializeLevel = initializeLevel,
    loadLevel = loadLevel
}