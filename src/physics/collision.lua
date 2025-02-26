function checkCollision(rect1, rect2)
    return rect1.x < rect2.x + rect2.width and
           rect1.x + rect1.width > rect2.x and
           rect1.y < rect2.y + rect2.height and
           rect1.y + rect1.height > rect2.y
end

function resolveCollision(rect1, rect2)
    local overlapX = 0
    local overlapY = 0

    if rect1.x < rect2.x then
        overlapX = (rect1.x + rect1.width) - rect2.x
    else
        overlapX = (rect2.x + rect2.width) - rect1.x
    end

    if rect1.y < rect2.y then
        overlapY = (rect1.y + rect1.height) - rect2.y
    else
        overlapY = (rect2.y + rect2.height) - rect1.y
    end

    if overlapX < overlapY then
        if rect1.x < rect2.x then
            rect1.x = rect1.x - overlapX
        else
            rect1.x = rect1.x + overlapX
        end
    else
        if rect1.y < rect2.y then
            rect1.y = rect1.y - overlapY
        else
            rect1.y = rect1.y + overlapY
        end
    end
end

function handleCollisions(entities)
    for i = 1, #entities do
        for j = i + 1, #entities do
            if checkCollision(entities[i], entities[j]) then
                resolveCollision(entities[i], entities[j])
            end
        end
    end
end