function handleCombat(player, enemies)
    for _, enemy in ipairs(enemies) do
        if isEnemyInRange(player, enemy) then
            if player.isAttacking then
                dealDamage(player, enemy)
            end
        end
    end
end

function isEnemyInRange(player, enemy)
    local distance = math.sqrt((player.x - enemy.x)^2 + (player.y - enemy.y)^2)
    return distance < player.attackRange
end

function dealDamage(player, enemy)
    enemy.health = enemy.health - player.attackDamage
    if enemy.health <= 0 then
        enemy:destroy()
    end
end

function playerAttack(player)
    player.isAttacking = true
    -- Add attack animation or effects here
end

function resetAttack(player)
    player.isAttacking = false
end