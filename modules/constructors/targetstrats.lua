function seekClosestPlayer(tm, target)
    local r = tm.owner.room
    target.subtype = TG_SEEK
    target.weight = 0
    -- se não enxerga nenhum player, o target fica com peso 0 mesmo...
    if r.playersInRoom:size() == 0 then
        return
    end
    local minDist = math.huge
    local closestPlayerPos = nil
    -- buscando todos os players na sala por ID, pq eles ficam em um Set ToT
    for i = 0, 4 do
        local p = r.playersInRoom:has(i) and r.playersInRoom:get(i) or nil
        if p then
            local d = dist(tm.owner.pos, p.pos)
            if d < minDist then
                minDist = d
                closestPlayerPos = p.pos
            end
        end
    end
    if closestPlayerPos then
        target.pos = closestPlayerPos
        target.weight = 1
    end
end

function seekClosestEnemy(tm, target)
    local r = tm.owner.room
    target.subtype = TG_SEEK
    target.weight = 0
    -- se não enxerga nenhum inimigo, o target fica com peso 0 mesmo...
    if #r.enemies == 0 then
        return
    end
    local minDist = math.huge
    local closestEnemyPos = nil
    for _, e in pairs(r.enemies) do
        local d = dist(tm.owner.pos, e.pos)
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
    local r = tm.owner.room
    target.subtype = TG_SEEK
    target.weight = 0
    if r.playersInRoom:size() == 0 then
        return
    end
    local posSum = vec(0, 0)
    for i = 0, 4 do
        local p = r.playersInRoom:has(i) and r.playersInRoom:get(i) or nil
        if p then
            addVec(posSum, p.pos)
        end
    end
    target.pos = scaleVec(posSum, 1 / #r.players)
    target.weight = 1
end

function seekAllEnemies(tm, target)
    local r = tm.owner.room
    target.subtype = TG_SEEK
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

function seekRandomPoint(tm, target)
    local r = target.owner.room
    local minX, maxX = room.limit.p1.x, room.limit.p2.x
    local minY, maxY = room.limit.p1.y, room.limit.p2.y
    local x, y = math.random(minX, maxX), math.random(minY, maxY)
    target.subtype = TG_SEEK
    target.pos = vec(x, y)
    target.weight = 1
end
