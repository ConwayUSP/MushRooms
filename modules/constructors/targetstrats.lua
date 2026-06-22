function seekClosestPlayer(tm, target)
    local r = tm.entity.room
    target.weight = 0
    -- se não enxerga nenhum player, o target fica com peso 0 mesmo...
    if #r.players == 0 then
        return
    end
    local minDist = math.huge
    local closestPlayerPos = nil
    for _, p in pairs(r.players) do
        local d = dist(tm.entity.pos, p.pos)
        if d < minDist then
            minDist = d
            closestPlayerPos = p.pos
        end
    end
    if closestPlayerPos then
        target.pos = closestPlayerPos
        target.weight = 1
    end
end

function seekClosestEnemy(tm, target)
    local r = tm.entity.room
    target.weight = 0
    -- se não enxerga nenhum inimigo, o target fica com peso 0 mesmo...
    if #r.enemies == 0 then
        return
    end
    local minDist = math.huge
    local closestEnemyPos = nil
    for _, e in pairs(r.enemies) do
        local d = dist(tm.entity.pos, e.pos)
        if d < minDist then
            minDist = d
            closestEnemyPos = e.pos
        end
    end
    if closestEnemyPos then
        target.pos = closestEnemyPos
        target.weight = 1
    end
end

function seekAllPlayers(tm, target)
    local r = tm.entity.room
    target.weight = 0
    if #r.players == 0 then
        return
    end
    local posSum = vec(0, 0)
    for _, p in pairs(r.players) do
        posSum(p.pos)
    end
    target.pos = scaleVec(posSum, 1 / #r.players)
    target.weight = 1
end

function seekAllEnemies(tm, target)
    local r = tm.entity.room
    target.weight = 0
    if #r.enemies == 0 then
        return
    end
    local posSum = vec(0, 0)
    for _, e in pairs(r.enemies) do
        posSum(e.pos)
    end
    target.pos = scaleVec(posSum, 1 / #r.enemies)
    target.weight = 1
end

function avoidClosestPlayer(tm, target)
    -- voilá! grande sacada huahuha
    seekClosestPlayer(tm, target)
    target.subtype = TG_AVOID
end

function avoidAllPlayers(tm, target)
    seekAllPlayers(tm, target)
    target.subtype = TG_AVOID
end

function avoidAllPlayersStrong(tm, target)
    seekAllPlayers(tm, target)
    target.subtype = TG_AVOID
    -- aqui o peso é maior, pode ser usado no efeito de fobia
    if target.weight ~= 0 then
        target.weight = 10
    end
end
