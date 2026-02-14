-- spriteexport.lua
-- Utility for baking Love2D drawing commands into a PNG file.
--
-- Usage:
--   local SpriteExport = require("src/rendering/spriteexport")
--
--   SpriteExport.exportSprite(
--       function()
--           -- any love.graphics calls here
--           love.graphics.setColor(1, 0, 0)
--           love.graphics.rectangle("fill", 4, 4, 8, 8)
--       end,
--       16, 16,            -- canvas size in pixels
--       "my_sprite.png"    -- output path (relative to the save directory)
--   )
--
-- The file is written to Love2D's save directory (love.filesystem.getSaveDirectory()).
-- On Windows this is typically %APPDATA%\LOVE\<game-name>\.
-- Pass an absolute path (starting with "/") to write elsewhere if needed.

local SpriteExport = {}

--- Render `drawFn` into a `width × height` canvas and save the result as a PNG.
--
-- @param drawFn   function  Love2D drawing commands to execute (no arguments).
-- @param width    number    Canvas width in pixels.
-- @param height   number    Canvas height in pixels.
-- @param filename string    Output filename, e.g. "gremlin.png".
-- @return string  The filename that was written.
function SpriteExport.exportSprite(drawFn, width, height, filename)
    assert(type(drawFn)   == "function", "exportSprite: drawFn must be a function")
    assert(type(width)    == "number",   "exportSprite: width must be a number")
    assert(type(height)   == "number",   "exportSprite: height must be a number")
    assert(type(filename) == "string",   "exportSprite: filename must be a string")

    -- Create an off-screen canvas.
    local canvas = love.graphics.newCanvas(width, height)

    -- Save current render state we're about to clobber.
    local prevCanvas = love.graphics.getCanvas()
    local pr, pg, pb, pa = love.graphics.getColor()

    -- Redirect drawing to the canvas and clear it to fully transparent.
    love.graphics.setCanvas(canvas)
    love.graphics.clear(0, 0, 0, 0)

    -- Let the caller draw whatever they like.
    drawFn()

    -- Restore previous render state.
    love.graphics.setCanvas(prevCanvas)
    love.graphics.setColor(pr, pg, pb, pa)

    -- Grab pixel data and encode as PNG.
    local imageData = canvas:newImageData()
    imageData:encode("png", filename)

    -- Release resources.
    imageData:release()
    canvas:release()

    return filename
end

return SpriteExport
