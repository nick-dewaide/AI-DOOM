local LevelManager = {}
function LevelManager:new()
    local obj = {
        currentLevel = 1,
        levels = {},
        levelData = nil,
    }
    setmetatable(obj, self)
    self.__index = self
    return obj
end

function LevelManager:loadLevel(levelNumber)
    self.levelData = self.levels[levelNumber]
    if self.levelData then
        -- Initialize level entities, map, etc.
    else
        error("Level " .. levelNumber .. " does not exist.")
    end
end

function LevelManager:addLevel(level)
    table.insert(self.levels, level)
end

function LevelManager:nextLevel()
    if self.currentLevel < #self.levels then
        self.currentLevel = self.currentLevel + 1
        self:loadLevel(self.currentLevel)
    else
        -- Handle end of game or level progression
    end
end

function LevelManager:getCurrentLevel()
    return self.levelData
end

return LevelManager