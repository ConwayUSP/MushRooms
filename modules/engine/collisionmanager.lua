----------------------------------------
-- Importações de Módulos
----------------------------------------
require("modules.systems.collision")
require("modules.utils.types")
require("modules.utils.utils")
require("modules.utils.vec")

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
	cm.solids = {}                -- tabela que liga entidades com seus hitboxes sólidos
	cm.solidList = {}             -- lista com índices numéricos de hitboxes sólidas
	cm.solidIndices = {}          -- mapa de entidade para índice da lista `solids`

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
	reg[PRODUCT] = {}
	reg[DROP] = {}
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
		if enemy.state ~= DYING then
			for _, attack in pairs(enemy.atk) do
				for _, atkEvent in pairs(attack.events) do
					if atkEvent.active then
						self:register(atkEvent)
					end
				end
			end
			self:register(enemy)
		end
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

	-- pegando hitboxes de portas
	for _, door in pairs(room:getDoors()) do
		self:register(door)
	end

	-- pegando hitboxes de itens
	for _, drop in pairs(room.drops) do
		self:register(drop)
	end

	-- pegando hitboxes de npcs
	for _, npc in pairs(room.npcs) do
		self:register(npc)
	end

	-- pegando hitboxes de obstáculos
	for _, obs in pairs(room.obstacles) do
		self:register(obs)
	end

	-- pegando hitboxes de paredes
	for _, wall in pairs(room:getWalls()) do
		self:register(wall)
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
		for _, attack in pairs(enemy.atk) do
			for _, atkEvent in pairs(attack.events) do
				self:unregister(atkEvent)
			end
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

	-- removendo hitboxes de portas
	for _, door in pairs(room:getDoors()) do
		self:unregister(door)
	end

	-- removendo hitboxes de itens
	for _, drop in pairs(room.drops) do
		self:unregister(drop)
	end

	-- removendo hitboxes de npcs
	for _, npc in pairs(room.npcs) do
		self:unregister(npc)
	end

	-- removendo hitboxes de obstáculos
	for _, obs in pairs(room.obstacles) do
		self:unregister(obs)
	end

	-- removendo hitboxes de paredes
	for _, wall in pairs(room:getWalls()) do
		self:unregister(wall)
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
		-- só insere no array se ainda não existir
		if not self.solidIndices[entity] then
			table.insert(self.solidList, entity)
			self.solidIndices[entity] = #self.solidList
		end
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
		local idx = self.solidIndices[entity]
		if idx then
			-- pega o último elemento da lista
			local lastEntity = self.solidList[#self.solidList]

			-- o último elemento toma a posição do elemento que está sendo removido
			self.solidList[idx] = lastEntity
			self.solidIndices[lastEntity] = idx

			-- limpa a última posição (agora duplicada) e o índice da entidade apagada
			self.solidList[#self.solidList] = nil
			self.solidIndices[entity] = nil
		end
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

	----------- PLAYER / DROP -----------
	for drop, drophb in pairs(registry[DROP]) do
		if drop.collected then
			self:unregister(drop)
			goto nextdrop
		end

		local hitByAnyPlayer = false

		for player, playerhb in pairs(registry[PLAYER]) do
			local hit = checkColision(playerhb.default, player, drophb.triggers, drop)

			if hit then
				hitByAnyPlayer = true
				self:onPlayerDrop(player, drop)
			end
		end

		drop:setShine(hitByAnyPlayer)
		::nextdrop::
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

	------------- ATAQUE / INTERATIVO --------------
	for attack, attackhb in pairs(registry[PLAYER_ATTACK]) do
		for inter, interhb in pairs(registry[INTERACTIVE]) do
			local hit = checkColision(attackhb.default, attack, interhb.default, inter)

			if hit then
				self:onAttackObstacle(attack, inter)
			end
		end
	end

	------------- ATAQUE / INTERATIVO --------------
	for attack, attackhb in pairs(registry[ENEMY_ATTACK]) do
		for inter, interhb in pairs(registry[INTERACTIVE]) do
			local hit = checkColision(attackhb.default, attack, interhb.default, inter)

			if hit then
				self:onAttackObstacle(attack, inter)
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
				self:onAttackDestructible(attack, destr)
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

function CollisionManager:handleSolidCollisions(entityA, entityB)
	if entityA.type == ATTACK_EVENT and entityB.type == OBSTACLE then
		self:onAttackObstacle(entityA, entityB)
	elseif entityA.type == OBSTACLE and entityB.type == ATTACK_EVENT then
		self:onAttackObstacle(entityB, entityA)
	end
end

---@param entity Entity
---@param nextPos Vec
---@return Vec correctedPos
function CollisionManager:resolveSolidCollisions(entity, nextPos)
	local finalPos = vec(entity.pos.x, entity.pos.y)

	-- registro para garantir que callbacks (como onAttackObstacle) rodem apenas 1x por sólido
	local solidsHit = {}

	-- separamos o movimento em dois eixos para evitar o "Seam Catching"
	-- primeiro movemos apenas em X e resolvemos colisões
	-- depois movemos apenas em Y (com o X já corrigido) e resolvemos colisões
	local steps = {
		{ isX = true,  pos = vec(nextPos.x, entity.pos.y) },
		{ isX = false, pos = vec(0, nextPos.y) },
	}

	local pushOut = vec(0, 0) -- inicializando uma vez só aqui fora para reduzir alocações de vetores
	for _, step in ipairs(steps) do
		if not step.isX then
			-- no passo Y, herdamos o X seguro que calculamos no passo anterior
			step.pos.x = finalPos.x
		end

		finalPos = vec(step.pos.x, step.pos.y)

		for _ = 1, 5 do
			local collisionsDetected = 0

			for i = 1, #self.solidList do
				local solid = self.solidList[i]
				local solidhbs = self.solids[solid]

				if solid == entity then
					goto nextsolid
				end

				for _, entityhb in ipairs(entity.hb.default) do
					local desiredhb = buildWorldHitbox(entityhb, finalPos)

					for _, solidhb in ipairs(solidhbs) do
						local worldSolidhb = buildWorldHitbox(solidhb, solid.pos)
						local manifold = getCollisionManifold(desiredhb, worldSolidhb)

						if manifold then
							if collisionsDetected == 0 and not solidsHit[solid] then
								self:handleSolidCollisions(entity, solid)
								solidsHit[solid] = true
							end

							collisionsDetected = collisionsDetected + 1

							pushOut.x = manifold.normal.x * (manifold.depth + 0.01)
							pushOut.y = manifold.normal.y * (manifold.depth + 0.01)

							-- isso impede que uma parede lateral empurre o jogador para cima/baixo na quina
							if step.isX then
								pushOut.y = 0
							else
								pushOut.x = 0
							end

							finalPos.x = finalPos.x + pushOut.x
							finalPos.y = finalPos.y + pushOut.y
							desiredhb = buildWorldHitbox(entityhb, finalPos)

							local normalEntityToSolid = scaleVec(manifold.normal, -1)
							applyContactImpulse(entity, solid, normalEntityToSolid, 1)
						end
					end
				end
				::nextsolid::
			end

			if collisionsDetected == 0 then
				break
			end
		end
	end

	return finalPos
end

----------------------------------------
-- Regras de Colisão
----------------------------------------

function CollisionManager:onPlayerRoom(player, room)
	local prevRoom = player.room
	local changedRoom = prevRoom ~= room

	-- se mudou de sala, se retira dela e entra na próxima
	if prevRoom and changedRoom then
		prevRoom:onPlayerExit(player)
		room:onPlayerEnter(player)
	end

	if changedRoom then
		player:onRoomChanged()
	end
end

---@param player Player
---@param drop Drop
-- trata a colisão entre um `player` e um `drop`
function CollisionManager:onPlayerDrop(player, drop)
	player:tryCollectDrop(drop)
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

	attack.targetsDamaged[enemy] = { timer = attack.tick }
	attack.piercesLeft = attack.piercesLeft - 1

	if enemy.invulnerableTimer > 0 then
		return
	end

	applyImpulse(enemy, scaleVec(normalize(subVec(enemy.pos, attack.pos)), attack.mass * 1000))
	enemy:takeDamage(attack.dmg)
	attack.attacker.blessingManager:dispatch(TP_ON_ATTACK_ENEMY, { enemy = enemy, attack = attack })
	attack:onHit(enemy)
end

---@param enemy Enemy
---@param player Player
-- trata a colisão entre um `enemy` e um `player`
function CollisionManager:onEnemyPlayer(enemy, player)
	-- dano de contato
	if not player.invisible then
		player:takeDamage(10)
	end
end

---@param player Player
---@param attack AtkEvent
-- trata a colisão entre um `player` e um `attack` inimigo
function CollisionManager:onPlayerHitByEnemyAttack(player, attack)
	if not attack.active or player.invisible then
		return
	end
	local ctx = { attack = attack, player = player }
	player.blessingManager:dispatch(TP_ON_ATTACK_PLAYER, ctx)

	if ctx.result == BS_REFLECT then
		attack:reflect(player)
		return
	end

	if attack.targetsDamaged[player] then
		return
	end

	attack.targetsDamaged[player] = { timer = attack.tick }
	attack.piercesLeft = attack.piercesLeft - 1

	if not player:takeDamage(attack.dmg) then
		return
	end

	-- F = m.a, mas como nem todo ataque possui aceleração, vou usar a "velocidade" como base do impulso
	applyImpulse(player, scaleVec(attack.vel, attack.mass * 0.5))
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
	npc:onExit(player)
end

---@param destructible Destructible
-- trata a colisão entre um `player` ou um `attack` do player e um `destructible`
function CollisionManager:onPlayerDestructible(_, destructible)
	if destructible.fragility == FRAGILE then
		destructible:damage(math.huge)
	elseif destructible.fragility == UNSTABLE then
		destructible:destabilize()
	end
end

---@param destructible Destructible
-- trata a colisão entre um `player` ou um `attack` do player e um `destructible`
function CollisionManager:onAttackDestructible(_, destructible)
	destructible:damage(math.huge) -- !WARNING: mudar para ser o dano do ataque
end

---@param player Player
---@param inter Interactive
-- trata o início de colisão de um `player` com um objeto `interactive`
function CollisionManager:onPlayerInteractive(player, inter)
	player:considerInteractive(inter)
end

---@param attackA AtkEvent
---@param attackB AtkEvent
-- trata a colisão entre dois ataques
function CollisionManager:onAttackAttack(attackA, attackB)
	-- attackA:reducePierces()
	-- attackB:reducePierces()
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

---@param attack AtkEvent
---@param obstacle Obstacle
-- trata a colisão entre um ataque e um obstáculo
function CollisionManager:onAttackObstacle(attack, obstacle)
	attack:reduceBounces()
end
