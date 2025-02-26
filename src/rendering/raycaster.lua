local Raycaster = {}

function Raycaster:new(map)
    local obj = {
        map = map,
        fov = math.pi / 3,    -- Field of view (60 degrees)
        num_rays = 320,       -- Number of rays to cast (resolution)
        rays = {},
        wall_height = 500,    -- Base height of walls
        max_distance = 20,    -- Maximum render distance
        texture_width = 64,   -- Texture width for wall slices
        texture_height = 64   -- Texture height for wall slices
    }
    setmetatable(obj, self)
    self.__index = self
    return obj
end

function Raycaster:castRays(player)
    self.rays = {}  -- Clear previous rays
    
    local start_angle = player.angle - self.fov / 2
    
    for i = 0, self.num_rays - 1 do
        local ray_angle = start_angle + (i / self.num_rays) * self.fov
        local ray = self:castRay(player.position.x, player.position.y, ray_angle)
        table.insert(self.rays, ray)
    end
end

function Raycaster:castRay(x, y, angle)
    -- Initialize ray data
    local ray = {
        x = x,
        y = y,
        angle = angle,
        distance = 0,  -- This starts at 0
        hit_x = 0,
        hit_y = 0,
        hit_side = 0,
        texture_x = 0
    }
    
    -- Direction vector components
    local dir_x = math.cos(angle)
    local dir_y = math.sin(angle)
    
    -- Current map cell
    local map_x = math.floor(x)
    local map_y = math.floor(y)
    
    -- Length of ray from current position to next x or y-side
    local delta_dist_x = math.abs(1 / dir_x)
    local delta_dist_y = math.abs(1 / dir_y)
    
    -- Calculate step and initial side_dist
    local step_x, step_y
    local side_dist_x, side_dist_y
    
    if dir_x < 0 then
        step_x = -1
        side_dist_x = (x - map_x) * delta_dist_x
    else
        step_x = 1
        side_dist_x = (map_x + 1 - x) * delta_dist_x
    end
    
    if dir_y < 0 then
        step_y = -1
        side_dist_y = (y - map_y) * delta_dist_y
    else
        step_y = 1
        side_dist_y = (map_y + 1 - y) * delta_dist_y
    end
    
    -- Perform DDA (Digital Differential Analysis)
    local hit = false
    local side = 0   -- 0 for NS wall, 1 for EW wall
    
    -- THIS IS THE CRITICAL FIX - Need to properly increment ray.distance
    while not hit and ray.distance < self.max_distance do
        -- Jump to next map square in x or y direction
        if side_dist_x < side_dist_y then
            side_dist_x = side_dist_x + delta_dist_x
            map_x = map_x + step_x
            side = 0
            ray.distance = side_dist_x - delta_dist_x  -- Update distance
        else
            side_dist_y = side_dist_y + delta_dist_y
            map_y = map_y + step_y
            side = 1
            ray.distance = side_dist_y - delta_dist_y  -- Update distance
        end
        
        -- Check if we hit a wall
        if self.map.tiles[map_y] and self.map.tiles[map_y][map_x] == 1 then
            hit = true
        end
    end
    
    -- Calculate distance projected on camera direction
    if side == 0 then
        ray.distance = (map_x - x + (1 - step_x) / 2) / dir_x
    else
        ray.distance = (map_y - y + (1 - step_y) / 2) / dir_y
    end
    
    -- Store hit position
    ray.hit_x = x + dir_x * ray.distance
    ray.hit_y = y + dir_y * ray.distance
    ray.hit_side = side
    
    -- Calculate texture X coordinate
    if side == 0 then
        ray.texture_x = y + ray.distance * dir_y
    else
        ray.texture_x = x + ray.distance * dir_x
    end
    ray.texture_x = ray.texture_x % 1
    ray.texture_x = math.floor(ray.texture_x * self.texture_width)
    
    return ray
end

function Raycaster:render()
    local screen_width = love.graphics.getWidth()
    local screen_height = love.graphics.getHeight()
    
    -- Draw ceiling (sky)
    love.graphics.setColor(0.5, 0.7, 1.0)
    love.graphics.rectangle("fill", 0, 0, screen_width, screen_height / 2)
    
    -- Draw floor
    love.graphics.setColor(0.3, 0.3, 0.3)
    love.graphics.rectangle("fill", 0, screen_height / 2, screen_width, screen_height / 2)
    
    -- Store z-buffer for sprite rendering
    self.zBuffer = {}
    
    -- Draw walls
    for i, ray in ipairs(self.rays) do
        -- Apply fisheye correction
        local perpWallDist = ray.distance * math.cos(ray.angle - self.rays[math.floor(#self.rays / 2)].angle)
        
        -- Save distance to z-buffer for sprite rendering
        table.insert(self.zBuffer, perpWallDist)
        
        -- Calculate height of the wall slice to draw
        local line_height = self.wall_height / perpWallDist
        
        -- Calculate lowest and highest pixel to fill for the current stripe
        local draw_start = -line_height / 2 + screen_height / 2
        if draw_start < 0 then draw_start = 0 end
        
        local draw_end = line_height / 2 + screen_height / 2
        if draw_end >= screen_height then draw_end = screen_height - 1 end
        
        -- Choose wall color based on wall direction
        if ray.hit_side == 0 then
            love.graphics.setColor(0.8, 0.8, 0.8)  -- North-South walls
        else
            love.graphics.setColor(0.6, 0.6, 0.6)  -- East-West walls
        end
        
        -- Draw the vertical wall stripe
        local stripe_width = screen_width / self.num_rays
        love.graphics.rectangle("fill", (i-1) * stripe_width, draw_start, stripe_width, draw_end - draw_start)
    end
end

function Raycaster:prepareSprites(entities, player)
    self.sprites = {}
    
    -- Calculate sprite positions relative to player for all visible entities
    for _, entity in ipairs(entities) do
        -- Calculate sprite distance and angle from player
        local dx = entity.x - player.position.x
        local dy = entity.y - player.position.y
        local distance = math.sqrt(dx * dx + dy * dy)
        local angle = math.atan2(dy, dx)
        
        -- Only process sprites that are within reasonable distance
        if distance < 20 then
            -- Calculate sprite angle relative to player view
            local spriteAngle = angle - player.angle
            
            -- Normalize angle to -π to π range
            while spriteAngle > math.pi do spriteAngle = spriteAngle - 2 * math.pi end
            while spriteAngle < -math.pi do spriteAngle = spriteAngle + 2 * math.pi end
            
            -- Add to sprite list if potentially visible (within 180° field of view plus buffer)
            if math.abs(spriteAngle) < math.pi * 0.75 then
                table.insert(self.sprites, {
                    entity = entity,
                    distance = distance,
                    angle = spriteAngle,
                    screenX = 0 -- Will be calculated during render
                })
            end
        end
    end
    
    -- Sort sprites by distance (furthest first for proper drawing order)
    table.sort(self.sprites, function(a, b)
        return a.distance > b.distance
    end)
end

function Raycaster:renderEntities(player)
    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()
    
    for _, sprite in ipairs(self.sprites) do
        local entity = sprite.entity
        local distance = sprite.distance
        local angle = sprite.angle
        
        -- Calculate sprite position on screen
        local screenX = (math.tan(angle) / math.tan(math.pi/6)) * (screenWidth / 2) + (screenWidth / 2)
        
        -- Calculate sprite size based on distance
        local size = math.min(500, math.floor(800 / distance))
        
        -- Calculate sprite screen boundaries
        local drawStartX = math.floor(screenX - size / 2)
        local drawEndX = drawStartX + size
        local drawStartY = math.floor((screenHeight - size) / 2)
        local drawEndY = drawStartY + size
        
        -- Only render parts of sprite that are in front of walls
        for stripe = math.max(0, drawStartX), math.min(screenWidth, drawEndX) do
            -- Calculate column on screen
            local texX = math.floor((stripe - drawStartX) / size * 64)
            
            -- Check if sprite stripe is in front of wall using z-buffer
            local rayIndex = math.floor((stripe / screenWidth) * #self.zBuffer)
            if rayIndex > 0 and rayIndex <= #self.zBuffer and distance < self.zBuffer[rayIndex] then
                -- Draw sprite stripe
                if entity.health <= 0 then
                    -- Dead enemy (darker color)
                    love.graphics.setColor(0.5, 0, 0)
                else
                    -- Regular enemy
                    love.graphics.setColor(1, 0, 0)
                end
                
                love.graphics.rectangle("fill", stripe, drawStartY, 1, size)
            end
        end
    end
end

return Raycaster