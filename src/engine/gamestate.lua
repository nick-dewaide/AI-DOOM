local GameState = {}

function GameState:new()
    local obj = {
        currentState = "menu",  -- Possible states: menu, playing, paused, gameover
        states = {
            menu = {},
            playing = {},
            paused = {},
            gameover = {}
        }
    }
    setmetatable(obj, self)
    self.__index = self
    return obj
end

function GameState:changeState(newState)
    if self.states[newState] then
        self.currentState = newState
        self:enterState(newState)
    else
        error("Invalid game state: " .. newState)
    end
end

function GameState:enterState(state)
    if state == "menu" then
        -- Initialize menu state
    elseif state == "playing" then
        -- Initialize playing state
    elseif state == "paused" then
        -- Initialize paused state
    elseif state == "gameover" then
        -- Initialize game over state
    end
end

function GameState:update(dt)
    if self.currentState == "playing" then
        -- Update game logic
    elseif self.currentState == "paused" then
        -- Update pause logic
    end
end

function GameState:draw()
    if self.currentState == "menu" then
        -- Simple menu rendering
        love.graphics.setColor(1, 1, 1)
        love.graphics.print("DOOM CLONE", 300, 200, 0, 2, 2)
        love.graphics.print("Press ENTER to start", 270, 300)
        love.graphics.print("Press ESC to quit", 280, 350)
    elseif self.currentState == "playing" then
        -- Game rendering is handled in main.lua
    elseif self.currentState == "paused" then
        love.graphics.setColor(0.5, 0.5, 0.5, 0.7)
        love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
        love.graphics.setColor(1, 1, 1)
        love.graphics.print("PAUSED", 350, 250, 0, 2, 2)
        love.graphics.print("Press ESC to resume", 300, 300)
    elseif self.currentState == "gameover" then
        love.graphics.setColor(0.8, 0, 0)
        love.graphics.print("GAME OVER", 300, 250, 0, 2, 2)
        love.graphics.setColor(1, 1, 1)
        love.graphics.print("Press ENTER to restart", 290, 300)
    end
end

return GameState