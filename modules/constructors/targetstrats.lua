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
	-- iterar o Set evita perder um jogador com ID fora de uma faixa fixa e invalidar o alvo.
	for _, p in r.playersInRoom:iter() do
		local d = dist(tm.owner.pos, p.pos)
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
		if e.state ~= DYING then
			local d = dist(tm.owner.pos, e.pos)
			if d < minDist then
				minDist = d
				closestEnemyPos = e.pos
			end
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
	for _, p in r.playersInRoom:iter() do
		posSum = addVec(posSum, p.pos)
	end
	target.pos = scaleVec(posSum, 1 / r.playersInRoom:size())
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
		if e.state ~= DYING then
			posSum(e.pos)
		end
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
	avoidAllPlayers(tm, target)
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

---@param tm TargetManager
---@param target Target
-- calcula um vetor de repulsão em relação a outros inimigos próximos para evitar aglomerações
function avoidNearbyEnemies(tm, target)
	local owner = tm.owner
	local room = owner.room
	target.subtype = TG_SEEK
	target.weight = 0

	if not room or not room.enemies or #room.enemies <= 1 then
		return
	end

	local radius = 45
	local repulse = vec(0, 0)
	local count = 0

	for _, other in pairs(room.enemies) do
		if other ~= owner and other.state ~= DYING then
			local d = dist(owner.pos, other.pos)
			if d < radius and d > 0.001 then
				local factor = (radius - d) / radius
				local away = scaleVec(normalize(subVec(owner.pos, other.pos)), factor)
				repulse = addVec(repulse, away)
				count = count + 1
			end
		end
	end

	if count > 0 then
		target.pos = addVec(owner.pos, scaleVec(repulse, radius / count))
		target.weight = 1
	end
end


