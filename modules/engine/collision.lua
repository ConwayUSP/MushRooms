----------------------------------------
-- Importações de Módulos
----------------------------------------
require("modules.utils.types")
require("modules.utils.utils")
require("modules.utils.vec")

----------------------------------------
-- Funções auxiliares para colisão
----------------------------------------

--- tipos de hitbox
DEFAULT = "default"
SOLID = "solid"
TRIGGER = "trigger"

---@class Hitboxes
---@field solids Hitbox[]
---@field default Hitbox[]
---@field triggers Hitbox[]

---@class Hitbox
---@field shape Shape
---@field offset Vec

---@alias CircleHitbox {offset: Vec, shape: Circle}
---@alias RectHitbox {offset: Vec, shape: Rectangle}
---@alias LineHitbox {offset: Vec, shape: Line}

---@param shape Shape
---@param posOffset? Vec
---@return Hitbox
-- cria uma `Hitbox`, estrutura com forma e posição
function hitbox(shape, posOffset)
	return {
		shape = shape,
		offset = posOffset or vec(0, 0),
	}
end

---@param default Hitbox[]
---@param solids? Hitbox[]
---@param triggers? Hitbox[]
---@return Hitboxes
-- cria uma estrutura `Hitboxes` para agrupar hitboxes por tipo
function hitboxes(default, solids, triggers)
	return {
		default = default or {},
		solids = solids or {},
		triggers = triggers or {},
	}
end

---@param hbs Hitboxes
-- retorna uma cópia da tabela de hitboxes `hbs`
function copyHitboxes(hbs)
	local newHbs = {
		default = {},
		solids = {},
		triggers = {},
	}

	for _, hb in ipairs(hbs.default) do
		table.insert(newHbs.default, copyHitbox(hb))
	end
	for _, hb in ipairs(hbs.solids) do
		table.insert(newHbs.solids, copyHitbox(hb))
	end
	for _, hb in ipairs(hbs.triggers) do
		table.insert(newHbs.triggers, copyHitbox(hb))
	end

	return newHbs
end

---@param hb Hitbox
---@param offset? Vec
---@return Hitbox
-- retorna uma cópia de `hb` podendo ou não distinguir sua posição
-- da hitbox original com o uso do parâmetro `offset`
function copyHitbox(hb, offset)
	local shape = copyShape(hb.shape)
	return {
		shape = shape,
		offset = offset or vec(hb.offset.x, hb.offset.y),
	}
end

---@param shape Shape | Circle | Rectangle | Line
---@return Shape
-- retorna uma cópia do formato passado como argumento
function copyShape(shape)
	if shape.shape == CIRCLE then
		return Circle.new(shape.radius)
	elseif shape.shape == RECTANGLE then
		return Rectangle.new(shape.width, shape.height)
	else
		return Line.new(shape.angle, shape.length)
	end
end

---@param hitbox Hitbox
---@param entityPos Vec
---@return Hitbox
-- constrói uma hitbox no "mundo" a partir de uma hitbox local `hitbox`
function buildWorldHitbox(hitbox, entityPos)
	return {
		shape = hitbox.shape,
		offset = addVec(entityPos, hitbox.offset),
	}
end

function entityKey(entity)
	if entity.type ~= ATTACK_EVENT then
		return entity.type
	else
		return entity.ally and PLAYER_ATTACK or ENEMY_ATTACK
	end
end

----------------------------------------
-- Funções auxiliares para colisão
----------------------------------------

---@param hb1 Hitbox
---@param hb2 Hitbox
---@return boolean
-- recebe duas hitboxes, retorna true se elas se tocam
function checkHitboxCollision(hb1, hb2)
	if hb1.shape.shape == CIRCLE then
		if hb2.shape.shape == CIRCLE then
			return checkCircleCircleCollision(hb1, hb2)
		elseif hb2.shape.shape == RECTANGLE then
			return checkCircleRectCollision(hb1, hb2)
		elseif hb2.shape.shape == LINE then
			return checkCircleLineCollision(hb1, hb2)
		end
	elseif hb1.shape.shape == RECTANGLE then
		if hb2.shape.shape == CIRCLE then
			return checkCircleRectCollision(hb2, hb1)
		elseif hb2.shape.shape == RECTANGLE then
			return checkRectRectCollision(hb1, hb2)
		elseif hb2.shape.shape == LINE then
			return checkRectLineCollision(hb1, hb2)
		end
	elseif hb1.shape.shape == LINE then
		if hb2.shape.shape == CIRCLE then
			return checkCircleLineCollision(hb2, hb1)
		elseif hb2.shape.shape == RECTANGLE then
			return checkRectLineCollision(hb2, hb1)
		elseif hb2.shape.shape == LINE then
			return checkLineLineCollision(hb1, hb2)
		end
	end

	return false
end

---@param a Hitbox[]
---@param ownerA Entity
---@param b Hitbox[]
---@param ownerB Entity
-- checa colisão entre as hitboxes `a` e `b`, pertencentes aos donos `ownerA` e `ownerB`
function checkColision(a, ownerA, b, ownerB)
	if #a == 0 or #b == 0 then
		return false
	end

	for _, hbA in ipairs(a) do
		local worldHbA = buildWorldHitbox(hbA, ownerA.pos)

		for _, hbB in ipairs(b) do
			local worldHbB = buildWorldHitbox(hbB, ownerB.pos)

			if checkHitboxCollision(worldHbA, worldHbB) then
				return true
			end
		end
	end

	return false
end

---@param point Vec
---@param line {offset: Vec, shape: Line} Hitbox em formato de linha
---@return boolean
-- verifica se a linha `line` contém o ponto `point`
function pointOnLine(point, line)
	local d1 = dist(point, line.offset)
	local d2 = dist(point, polarToVec(line.shape.angle, line.shape.length) + line.offset)
	local leniency = 0.01
	if d1 + d2 < line.shape.length + leniency and d1 + d2 > line.shape.length - leniency then
		return true
	end
	return false
end

---@param point Vec
---@param rect RectHitbox
---@return boolean
-- verifica se o ponto `point` está dentro do retângulo `rect`
function pointOnRect(point, rect)
	if
		point.x >= rect.offset.x
		and point.x <= rect.offset.x + rect.shape.width
		and point.y >= rect.offset.y
		and point.y <= rect.offset.y + rect.shape.height
	then
		return true
	end

	return false
end

---@param circle1 CircleHitbox
---@param circle2 CircleHitbox
---@return boolean
-- checa se dois círculos estão colidindo
function checkCircleCircleCollision(circle1, circle2)
	return dist(circle1.offset, circle2.offset) <= circle1.shape.radius + circle2.shape.radius
end

---@param circle CircleHitbox
---@param rect RectHitbox
---@return boolean
-- checa se um círculo e um retângulo estão colidindo
function checkCircleRectCollision(circle, rect)
	local dist = vec(math.abs(circle.offset.x - rect.offset.x), math.abs(circle.offset.y - rect.offset.y))
	if dist.x > (rect.shape.halfW + circle.shape.radius) or dist.y > (rect.shape.halfH + circle.shape.radius) then
		return false
	end
	if dist.x <= rect.shape.halfW or dist.y <= rect.shape.halfH then
		return true
	end
	local cornerDist = (dist.x - rect.shape.halfW) ^ 2 + (dist.y - rect.shape.halfH) ^ 2
	return cornerDist <= circle.shape.radius ^ 2
end

---@param circle CircleHitbox
---@param line LineHitbox
---@return boolean
-- checa se um círculo e uma linha estão colidindo
function checkCircleLineCollision(circle, line)
	local p1 = line.offset
	local p2 = addVec(p1, polarToVec(line.shape.angle, line.shape.length))
	if dist(p1, circle.offset) < circle.shape.radius or dist(p2, circle.offset) < circle.shape.radius then
		return true
	end
	local dot = dotProd(subVec(circle.offset, p1), subVec(p2, p1))
	local closestX = p1.x + (dot * (p2.x - p1.x))
	local closestY = p1.y + (dot * (p2.y - p1.y))
	if not pointOnLine(vec(closestX, closestY), line) then
		return false
	end
	local distX = closestX - circle.offset.x
	local distY = closestY - circle.offset.y
	local dist = distX ^ 2 + distY ^ 2
	if dist <= circle.shape.radius ^ 2 then
		return true
	end
	return false
end

---@param rect1 RectHitbox
---@param rect2 RectHitbox
---@return boolean
-- checa se dois retângulos estão colidindo
function checkRectRectCollision(rect1, rect2)
	if
		rect1.offset.x + rect1.shape.width >= rect2.offset.x
		and rect1.offset.x <= rect2.offset.x + rect2.shape.width
		and rect1.offset.y + rect1.shape.height >= rect2.offset.y
		and rect1.offset.y <= rect2.offset.y + rect2.shape.height
	then
		return true
	end
	return false
end

---@param rect RectHitbox
---@param line LineHitbox
---@return boolean
-- checa se um retângulo e uma linha estão colidindo
function checkRectLineCollision(rect, line)
	local leftSide = hitbox(Line.new(math.pi * 3 / 2, rect.shape.height), rect.offset)
	local upSide = hitbox(Line.new(0, rect.shape.width), rect.offset)
	local rightSide =
		hitbox(Line.new(math.pi * 3 / 2, rect.shape.height), addVec(rect.offset, scaleVec(vec(1, 0), rect.shape.width)))
	local downSide = hitbox(Line.new(0, rect.shape.width), addVec(rect.offset, scaleVec(vec(0, 1), rect.shape.height)))
	local leftHit = checkLineLineCollision(line, leftSide)
	local upHit = checkLineLineCollision(line, upSide)
	local rightHit = checkLineLineCollision(line, rightSide)
	local downHit = checkLineLineCollision(line, downSide)
	if leftHit or upHit or rightHit or downHit then
		return true
	end
	return false
end

---@param line1 LineHitbox
---@param line2 LineHitbox
---@return boolean
-- checa se duas linhas estão colidindo
function checkLineLineCollision(line1, line2)
	local p1 = line1.offset
	local p2 = addVec(p1, polarToVec(line1.shape.angle, line1.shape.length))
	local p3 = line2.offset
	local p4 = addVec(p3, polarToVec(line2.shape.angle, line2.shape.length))

	local a = ((p4.x - p3.x) * (p1.y - p3.y) - (p4.y - p3.y) * (p1.x - p3.x))
		/ ((p4.y - p3.y) * (p2.x - p1.x) - (p4.x - p3.x) * (p2.y - p1.y))
	local b = ((p2.x - p1.x) * (p1.y - p3.y) - (p2.y - p1.y) * (p1.x - p3.x))
		/ ((p4.y - p3.y) * (p2.x - p1.x) - (p4.x - p3.x) * (p2.y - p1.y))
	if a >= 0 and a <= 1 and b >= 0 and b <= 1 then
		return true
	end
	return false
end

----------------------------------------
-- Funções de manifold para sólidos
----------------------------------------

---@param hb1 Hitbox
---@param hb2 Hitbox
---@return {normal: Vec, depth: number} | nil
-- retorna uma estrutura com a normal da colisão e o quão profundo
-- o objeto colisor entrou no objeto sólido
function getCollisionManifold(hb1, hb2)
	local shape1 = hb1.shape.shape
	local shape2 = hb2.shape.shape

	if shape1 == RECTANGLE and shape2 == RECTANGLE then
		return getRectRectManifold(hb1, hb2)
	elseif shape1 == CIRCLE and shape2 == RECTANGLE then
		return getCircleRectManifold(hb1, hb2)
	elseif shape1 == RECTANGLE and shape2 == CIRCLE then
		local m = getCircleRectManifold(hb2, hb1)
		if m then
			m.normal = scaleVec(m.normal, -1)
		end
		return m
	elseif shape1 == CIRCLE and shape2 == CIRCLE then
		return getCircleCircleManifold(hb1, hb2)
	end
	return nil
end

---@param r1 RectHitbox
---@param r2 RectHitbox
---@return {normal: Vec, depth: number} | nil
-- calcula o manifold (normal de colisão + profundidade) entre dois retângulos
function getRectRectManifold(r1, r2)
	-- distância entre os centros
	local dist = subVec(r1.offset, r2.offset)

	local rw1 = r1.shape.halfW
	local rh1 = r1.shape.halfH
	local rw2 = r2.shape.halfW
	local rh2 = r2.shape.halfH

	-- calcula a sobreposição nos eixos
	local xOverlap = (rw1 + rw2) - math.abs(dist.x)
	local yOverlap = (rh1 + rh2) - math.abs(dist.y)

	if xOverlap > 0 and yOverlap > 0 then
		-- empurra na direção da menor sobreposição
		if xOverlap < yOverlap then
			local sx = dist.x < 0 and -1 or 1
			return { normal = vec(sx, 0), depth = xOverlap }
		else
			local sy = dist.y < 0 and -1 or 1
			return { normal = vec(0, sy), depth = yOverlap }
		end
	end
	return nil
end

---@param c CircleHitbox
---@param r RectHitbox
---@return {normal: Vec, depth: number} | nil
-- calcula o manifold (normal de colisão + profundidade) entre um círculo e um retângulo
function getCircleRectManifold(c, r)
	local rw = r.shape.halfW
	local rh = r.shape.halfH

	-- encontra o ponto mais próximo no retângulo em relação ao centro do círculo
	local closestX = clamp(c.offset.x, r.offset.x - rw, r.offset.x + rw)
	local closestY = clamp(c.offset.y, r.offset.y - rh, r.offset.y + rh)
	local closest = vec(closestX, closestY)

	-- vetor do ponto mais próximo até o centro do círculo
	local dist = subVec(c.offset, closest)
	local distLen = lenVec(dist)

	-- Se a distância for menor que o raio, colidiu
	if distLen < c.shape.radius then
		local normal
		local depth

		-- caso especial: centro do círculo está dentro do retângulo
		if distLen == 0 then
			-- encontra a menor distância para sair
			local dx = c.offset.x - r.offset.x
			local dy = c.offset.y - r.offset.y
			local distToRight = rw - dx
			local distToLeft = rw + dx
			local distToTop = rh - dy
			local distToBottom = rh + dy
			local minDist = math.min(distToRight, distToLeft, distToTop, distToBottom)

			if minDist == distToRight then
				normal = vec(1, 0)
			elseif minDist == distToLeft then
				normal = vec(-1, 0)
			elseif minDist == distToTop then
				normal = vec(0, 1)
			else
				normal = vec(0, -1)
			end
			depth = c.shape.radius + minDist
		else
			normal = normalize(dist)
			depth = c.shape.radius - distLen
		end

		return { normal = normal, depth = depth }
	end
	return nil
end

---@param c1 CircleHitbox
---@param c2 CircleHitbox
---@return {normal: Vec, depth: number} | nil
-- calcula o manifold (normal de colisão + profundidade) entre dois círculos
function getCircleCircleManifold(c1, c2)
	local dist = subVec(c1.offset, c2.offset)
	local distLen = lenVec(dist)
	local radiusSum = c1.shape.radius + c2.shape.radius

	if distLen < radiusSum then
		local normal
		local depth = radiusSum - distLen
		if distLen == 0 then
			normal = vec(1, 0)
		else
			normal = normalize(dist)
		end
		return { normal = normal, depth = depth }
	end
	return nil
end

----------------------------------------
-- Resposta física de colisão (3ª lei)
----------------------------------------

---@param entityA Entity
---@param entityB Entity
---@param normal Vec # normal apontando de A para B
---@param restitution? number
-- aplica um impulso de contato entre duas entidades, obedecendo
-- conservação de quantidade de movimento e coeficiente de restituição
local function applyContactImpulse(entityA, entityB, normal, restitution)
	-- garante normal unitária
	local n = normalize(normal)

	-- garante vetores de velocidade válidos
	entityA.vel = entityA.vel or vec(0, 0)
	entityB.vel = entityB.vel or vec(0, 0)

	local velA = entityA.vel
	local velB = entityB.vel

	-- velocidade relativa ao longo da normal (de A para B)
	local relVel = subVec(velB, velA)
	local velAlongNormal = dotProd(relVel, n)

	-- se já estiverem se afastando, não aplica impulso
	if velAlongNormal > 0 then
		return
	end

	-- coeficiente de restituição efetivo (0 = inelástico, 1 = elástico)
	local e = restitution or 0
	if entityA.restitution then
		e = math.max(e, entityA.restitution)
	end
	if entityB.restitution then
		e = math.max(e, entityB.restitution)
	end

	-- massas inversas (massa infinita -> 0)
	local invMassA = 0
	if entityA.mass and entityA.mass ~= 0 and entityA.mass ~= math.huge then
		invMassA = 1 / entityA.mass
	end
	local invMassB = 0
	if entityB.mass and entityB.mass ~= 0 and entityB.mass ~= math.huge then
		invMassB = 1 / entityB.mass
	end

	local invMassSum = invMassA + invMassB
	if invMassSum == 0 then
		return
	end

	-- impulso escalar
	local j = -((1 + e) * velAlongNormal) / invMassSum
	local impulse = scaleVec(n, j)

	-- aplica impulsos iguais e opostos
	if invMassA > 0 then
		entityA.vel = subVec(entityA.vel, scaleVec(impulse, invMassA))
	end
	if invMassB > 0 then
		entityB.vel = addVec(entityB.vel, scaleVec(impulse, invMassB))
	end
end

----------------------------------------
-- Classe Collision Manager
----------------------------------------

---@class CollisionManager
---@field registry table<string, table<Entity, Hitboxes>>
---@field solids table<Entity, Hitbox[]>
---@field roomsDirty boolean
---@field activeRoomsCopy Set<Room>

CollisionManager = {}
CollisionManager.__index = CollisionManager
CollisionManager.type = COLLISION_MANAGER

function CollisionManager.init()
	local cm = setmetatable({}, CollisionManager)

	cm.registry = cm:startRegistry() -- tabela mestre de hitboxes registradas
	cm.roomsDirty = false         -- flag para indicar se as listas de hitboxes precisam ser atualizadas
	cm.solids = {}                -- hitboxes sólidas

	-- otimização: manter uma cópia das salas ativas
	-- para minimizar o número de colisões checadas
	cm.activeRoomsCopy = Set.new()
	cm.activeRoomsCopy:copy(activeRooms)

	return cm
end

function CollisionManager:startRegistry()
	local reg = {}

	reg[PLAYER] = {}
	reg[ENEMY] = {}
	reg[DESTRUCTIBLE] = {}
	reg[INTERACTIVE] = {}
	reg[ITEM] = {}
	reg[NPC] = {}
	reg[PLAYER_ATTACK] = {}
	reg[ENEMY_ATTACK] = {}
	reg[OBSTACLE] = {}
	reg[ROOM] = {}

	return reg
end

-- atualiza o gerenciador de colisões
function CollisionManager:update(dt)
	self:updateHitboxListsIfNeeded()
	self:handleCollisions()
end

---@param room Room
-- adiciona as hitboxes das entidades em `room` à respectiva
-- lista do `CollisionManager`
function CollisionManager:fetchHitboxesByRoom(room)
	-- pegando hitboxes da sala
	self:register(room)
	for _, adjRoom in pairs(room.adjacentRooms) do
		local room = getRoomAt(adjRoom)
		if room then
			self:register(room)
		end
	end

	-- pegando hitboxes de inimigos
	for _, enemy in pairs(room.enemies) do
		for _, attack in pairs(enemy.atk.events) do
			self:register(attack)
		end
		self:register(enemy)
	end

	-- pegando hitboxes de destrutiveis
	for _, destr in pairs(room.destructibles) do
		if destr.state == INTACT then
			self:register(destr)
		end
	end

	-- pegando hitboxes de interativos
	for _, inter in pairs(room.interactives) do
		self:register(inter)
	end

	-- pegando hitboxes de interativos
	for _, door in pairs(room.doors) do
		self:register(door)
	end

	-- pegando hitboxes de itens
	for _, item in pairs(room.items) do
		self:register(item)
	end

	-- pegando hitboxes de npcs
	for _, npc in pairs(room.npcs) do
		self:register(npc)
	end

	-- pegando hitboxes de obstáculos
	for _, obs in pairs(room.obstacles) do
		self:register(obs)
	end
end

---@param room Room
-- remove as hitboxes das entidades em `room` das suas
-- respectivas listas do `CollisionManager`
function CollisionManager:clearHitboxesByRoom(room)
	-- removendo hitbox da sala
	self:unregister(room)
	for _, adjRoom in pairs(room.adjacentRooms) do
		local room = getRoomAt(adjRoom)
		if room then
			self:unregister(room)
		end
	end

	-- removendo hitboxes de inimigos
	for _, enemy in pairs(room.enemies) do
		for _, attack in pairs(enemy.atk.events) do
			self:unregister(attack)
		end
		self:unregister(enemy)
	end

	-- removendo hitboxes de destrutiveis
	for _, destr in pairs(room.destructibles) do
		self:unregister(destr)
	end

	-- removendo hitboxes de interativos
	for _, inter in pairs(room.interactives) do
		self:unregister(inter)
	end

	-- removendo hitboxes de itens
	for _, item in pairs(room.items) do
		self:unregister(item)
	end

	-- removendo hitboxes de npcs
	for _, npc in pairs(room.npcs) do
		self:unregister(npc)
	end

	-- removendo hitboxes de obstáculos
	for _, obs in pairs(room.obstacles) do
		self:unregister(obs)
	end
end

-- verifica se as listas de hitboxes precisam ser atualizadas
function CollisionManager:updateHitboxListsIfNeeded()
	if not self.roomsDirty then
		return
	end

	self:updateHitboxLists()
	self.roomsDirty = false
end

-- atualiza as listas de hitboxes para conter hitboxes apenas de salas ativas
function CollisionManager:updateHitboxLists()
	-- eliminando as hitboxes de uma sala recém desativada
	for k, room in self.activeRoomsCopy:iter() do
		local present = activeRooms:has(k)

		if not present then
			self:clearHitboxesByRoom(room)
		end
	end

	-- atualizando nossa cópia das salas ativas
	self.activeRoomsCopy:copy(activeRooms)
	-- pegando as hitboxes de todas as salas ativas
	for _, room in self.activeRoomsCopy:iter() do
		self:fetchHitboxesByRoom(room)
	end
end

---@param entity Entity | Room
-- registra a hitbox da entidade `entity` nas listas do `CollisionManager`
function CollisionManager:register(entity)
	if not entity.hb then
		return
	end

	if entity.hb.solids and #entity.hb.solids > 0 then
		self.solids[entity] = entity.hb.solids
	end

	self.registry[entityKey(entity)] = self.registry[entityKey(entity)] or {}
	self.registry[entityKey(entity)][entity] = entity.hb
end

---@param entity Entity | Room
-- remove a hitbox da entidade `entity` das listas do `CollisionManager`
function CollisionManager:unregister(entity)
	local data = self.registry[entityKey(entity)][entity]
	if not data then
		return
	end

	if data.solids and #data.solids > 0 then
		self.solids[entity] = nil
	end

	self.registry[entityKey(entity)][entity] = nil
end

function CollisionManager:handleCollisions()
	---@type table<string, table<any, Hitboxes>>
	local registry = self.registry

	--------- PLAYER / SALA -----------
	for player, _ in pairs(registry[PLAYER]) do
		for room, roomhb in pairs(registry[ROOM]) do
			local pPos = player.pos
			local rRect = buildWorldHitbox(roomhb.triggers[1], room.limits.p1)
			local hit = pointOnRect(pPos, rRect)

			if hit then
				self:onPlayerRoom(player, room)
			end
		end
	end

	--------- PLAYER / OBSTACLE ----------
	for obstacle, obstaclehb in pairs(registry[OBSTACLE]) do
		local hitByAnyPlayer = false
		for player, playerhb in pairs(registry[PLAYER]) do
			local hit = checkColision(playerhb.default, player, obstaclehb.triggers, obstacle)

			if hit then
				hitByAnyPlayer = true
				self:onPlayerObstacle(obstacle)
			end
		end

		if not hitByAnyPlayer then
			self:onPlayerObstacleExit(obstacle)
		end
	end

	----------- PLAYER / ITEM -----------
	for item, itemhb in pairs(registry[ITEM]) do
		if item.collected then
			self:unregister(item)
			goto nextitem
		end

		local hitByAnyPlayer = false

		for player, playerhb in pairs(registry[PLAYER]) do
			local hit = checkColision(playerhb.default, player, itemhb.triggers, item)

			if hit then
				hitByAnyPlayer = true
				self:onPlayerItem(player, item)
			end
		end

		item:setShine(hitByAnyPlayer)
		::nextitem::
	end

	------- PLAYER / NPC --------
	for player, playerhb in pairs(registry[PLAYER]) do
		local hitSomeNPC = false
		for npc, npchb in pairs(registry[NPC]) do
			local hit = checkColision(playerhb.default, player, npchb.triggers, npc)

			if hit then
				hitSomeNPC = true
				self:onPlayerNpc(player, npc)
			end
		end

		if not hitSomeNPC and player.interactiveObj and player.interactiveObj.type == NPC then
			self:onPlayerNpcExit(player, player.interactiveObj)
		end
	end

	--------- ATAQUE / PLAYER ----------
	for player, playerhb in pairs(registry[PLAYER]) do
		for attack, attackhb in pairs(registry[ENEMY_ATTACK]) do
			local hit = checkColision(playerhb.default, player, attackhb.default, attack)

			if hit then
				self:onPlayerHitByEnemyAttack(player, attack)
			end
		end
	end

	------- PLAYER / DESTRUTIVEL --------
	for destr, destrhb in pairs(registry[DESTRUCTIBLE]) do
		for player, playerhb in pairs(registry[PLAYER]) do
			local hit = checkColision(destrhb.default, destr, playerhb.default, player)

			if hit then
				self:onPlayerDestructible(player, destr)
			end
		end
	end

	-------- PLAYER / INTERATIVO --------
	for player, playerhb in pairs(registry[PLAYER]) do
		local hitSomeInteractive = false
		for inter, interhb in pairs(registry[INTERACTIVE]) do
			local hit = checkColision(interhb.triggers, inter, playerhb.default, player)

			if hit then
				self:onPlayerInteractive(player, inter)
				hitSomeInteractive = true
			end
		end

		if not hitSomeInteractive and player.interactiveObj and player.interactiveObj.type == INTERACTIVE then
			self:onPlayerInteractiveExit(player, player.interactiveObj)
		end
	end

	--------- PLAYER / INIMIGO ----------
	for player, playerhb in pairs(registry[PLAYER]) do
		for enemy, enemyhb in pairs(registry[ENEMY]) do
			local hit = checkColision(playerhb.default, player, enemyhb.default, enemy)

			if hit then
				self:onEnemyPlayer(enemy, player)
			end
		end
	end

	--------- INIMIGO / ATAQUE ----------
	for enemy, enemyhb in pairs(registry[ENEMY]) do
		for attack, attackhb in pairs(registry[PLAYER_ATTACK]) do
			local hit = checkColision(enemyhb.default, enemy, attackhb.default, attack)

			if hit then
				self:onEnemyHitByPlayerAttack(enemy, attack)
			end
		end
	end

	------- ATAQUE / DESTRUTIVEL --------
	for destr, destrhb in pairs(registry[DESTRUCTIBLE]) do
		for attack, attackhb in pairs(registry[PLAYER_ATTACK]) do
			local hit = checkColision(destrhb.default, destr, attackhb.default, attack)

			if hit then
				self:onPlayerDestructible(attack, destr)
			end
		end
	end

	---------- ATAQUE / ATAQUE ----------
	for attackA, attackAhb in pairs(registry[PLAYER_ATTACK]) do
		for attackB, attackBhb in pairs(registry[ENEMY_ATTACK]) do
			local hit = checkColision(attackAhb.default, attackA, attackBhb.default, attackB)

			if hit then
				self:onAttackAttack(attackA, attackB)
			end
		end
	end
end

---@param entity Entity
---@param nextPos Vec
---@return Vec correctedPos
function CollisionManager:resolveSolidCollisions(entity, nextPos)
	local finalPos = vec(nextPos.x, nextPos.y)

	-- executa múltiplas passadas para resolver colisões em canto
	for _ = 1, 3 do
		local collisionDetected = false

		-- itera sobre todas as entidades sólidas registradas
		for solid, solidhbs in pairs(self.solids) do
			if solid == entity then
				goto nextsolid
			end
			-- para cada hitbox "default" da minha entidade
			for _, entityhb in ipairs(entity.hb.default) do
				local desiredhb = buildWorldHitbox(entityhb, finalPos)

				-- contra cada hitbox sólida do outro objeto
				for _, solidhb in ipairs(solidhbs) do
					local worldSolidhb = buildWorldHitbox(solidhb, solid.pos)
					local manifold = getCollisionManifold(desiredhb, worldSolidhb)

					if manifold then
						collisionDetected = true
						-- resolve a posição (Empurra para fora)
						local pushOut = scaleVec(manifold.normal, manifold.depth)
						finalPos = addVec(finalPos, pushOut)
						-- Atualiza a hitbox para a nova posição (para a próxima iteração do loop i)
						desiredhb = buildWorldHitbox(entityhb, finalPos)
						-- para sólidos estáticos, mantemos o comportamento antigo;
						-- para sólidos dinâmicos aplicamos impulso de contato obedecendo a 3ª lei.
						local isStaticSolid = solid.isStatic == true
						if isStaticSolid then
							-- projeta a velocidade na normal da colisão, deslizando a entidade
							local velDotNormal = dotProd(entity.vel, manifold.normal)
							-- se estiver se movendo contra a parede, remove essa componente
							if velDotNormal < 0 then
								local slideCancel = scaleVec(manifold.normal, velDotNormal)
								entity.vel = scaleVec(subVec(entity.vel, slideCancel), 0.75) -- x0.75 para perder um pouco mais de energia
							end
						else
							local normalEntityToSolid = scaleVec(manifold.normal, -1)
							applyContactImpulse(entity, solid, normalEntityToSolid, 0)
						end
					end
				end
			end
			::nextsolid::
		end

		if not collisionDetected then
			break
		end
	end

	return finalPos
end

----------------------------------------
-- Regras de Colisão
----------------------------------------

function CollisionManager:onPlayerRoom(player, room)
	local prevRoom = player.room

	-- se mudou de sala, se retira dela e entra na próxima
	if prevRoom and prevRoom ~= room then
		-- print("Player entered room: " .. vecToString(room.arrPos))

		prevRoom.playersInRoom:remove(player.id)
		prevRoom:verifyIsEmpty()

		room:visit(player)
	end
end

---@param player Player
---@param item Item
-- trata a colisão entre um `player` e um `item`
function CollisionManager:onPlayerItem(player, item)
	player:tryCollectItem(item)
end

---@param enemy Enemy
---@param attack AtkEvent
-- trata a colisão entre um `enemy` e um `player`
function CollisionManager:onEnemyHitByPlayerAttack(enemy, attack)
	if not attack.active then
		return
	end
	if attack.targetsDamaged[enemy] then
		return
	end

	attack.targetsDamaged[enemy] = true
	attack.piercesLeft = attack.piercesLeft - 1

	if enemy.invulnerableTimer > 0 then
		return
	end

	enemy.invulnerableTimer = 0.5
	enemy:takeDamage(attack.dmg)
end

---@param enemy Enemy
---@param player Player
-- trata a colisão entre um `enemy` e um `player`
function CollisionManager:onEnemyPlayer(enemy, player)
	if player.invulnerableTimer > 0 then
		return
	end

	print(player.name .. " hit by enemy " .. enemy.name)
	player.invulnerableTimer = 1.0
end

---@param player Player
---@param attack AtkEvent
-- trata a colisão entre um `player` e um `attack` inimigo
function CollisionManager:onPlayerHitByEnemyAttack(player, attack)
	if not attack.active then
		return
	end
	if attack.targetsDamaged[player] then
		return
	end

	attack.targetsDamaged[player] = true
	attack.piercesLeft = attack.piercesLeft - 1

	if player.invulnerableTimer > 0 then
		return
	end

	print(player.name .. " hit by enemy " .. attack.attacker.name)

	player.invulnerableTimer = 1.0
	attack:onHit(player)
end

---@param player Player
---@param npc Npc
-- trata a colisão entre um `player` e um `npc`
function CollisionManager:onPlayerNpc(player, npc)
	player:considerInteractive(npc)
end

---@param player Player
---@param npc Npc
-- trata o fim da colisão entre um `player` e um `npc`
function CollisionManager:onPlayerNpcExit(player, npc)
	print(npc.name .. " onExit by " .. player.name)
	npc:onExit(player)
end

---@param destructible Destructible
-- trata a colisão entre um `player` ou um `attack` do player e um `destructible`
function CollisionManager:onPlayerDestructible(_, destructible)
	destructible:damage(math.huge)
end

---@param player Player
---@param inter Interactive
-- trata o início de colisão de um `player` com um objeto `interactive`
function CollisionManager:onPlayerInteractive(player, inter)
	player:considerInteractive(inter)
end

---@param player Player
---@param inter Interactive
-- trata o fim de colisão entre um `player` e um objeto `interactive`
function CollisionManager:onPlayerInteractiveExit(player, inter)
	print(inter.name .. " onExit by " .. player.name)
	inter:onExit(player)
end

---@param attackA AtkEvent
---@param attackB AtkEvent
-- trata a colisão entre dois ataques
function CollisionManager:onAttackAttack(attackA, attackB)
	if not attackA.active or not attackB.active then
		return
	end

	attackA.piercesLeft = attackA.piercesLeft - 1
	attackB.piercesLeft = attackB.piercesLeft - 1
end

---@param obstacle Obstacle
-- trata a colisão entre o `player` e um `obstacle`
function CollisionManager:onPlayerObstacle(obstacle)
	obstacle.transparent = true
end

---@param obstacle Obstacle
-- trata o fim da colisão entre o `player` e um `obstacle`
function CollisionManager:onPlayerObstacleExit(obstacle)
	obstacle.transparent = false
end
