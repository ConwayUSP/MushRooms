----------------------------------------------
--- Ancient Moai
----------------------------------------------

-- fases da máquina de estado do Ancient Moai
local MOAI_IDLE = "moai idle"
local MOAI_RUSH = "moai rush"
local MOAI_BRAKE = "moai brake"
local MOAI_COLLISION = "moai collision"
local MOAI_SLAM = "moai slam"
local MOAI_TORNADO = "moai tornado"

-- estado de animação da batida na parede (sheets collision_<dir>)
local COLLISION = "collision"

-- índice de cada ataque na lista `atk` do inimigo
local RUSH_ATK = 1
local SLAM_ATK = 2
local TORNADO_ATK = 3

-- constantes de comportamento
local IDLE_DURATION = 0.5        -- espera antes de escolher um ataque
local RETRY_DELAY = 0.4          -- espera quando nenhum ataque está pronto
local STOP_MARGIN = 200          -- margem de segurança entre o ponto de parada e a parede
local RUSH_OVERSHOOT_MIN = 200   -- quantos px no mínimo o boss vai mirar além do player no rush
local RUSH_OVERSHOOT_MAX = 400   -- quantos px no máximo o boss vai mirar além do player no rush
local WALL_CRASH_DMG = 30        -- dano ao bater na parede durante o embalo
local WALL_STUN_DURATION = 1.8   -- espera prolongada após bater na parede
local MIN_RUSH_DIST = 300        -- distância mínima de espaço livre para o embalo
local MAX_CLEARANCE = 1800       -- alcance máximo da checagem de espaço livre (cobre a largura da sala)
local RUSH_ACCEL = 3500          -- aceleração do embalo (vel. terminal ≈ 800 px/s)
local BRAKE_FACTOR = 1.0         -- intensidade do freio (≤1 para nunca inverter a velocidade)
local BRAKE_STOP_SPEED = 25      -- velocidade abaixo da qual o freio encerra o embalo
local SLAM_IMPACT_FRAME = 8      -- frame da animação de slam em que o impacto acontece
local SLAM_FRAME_DUR = 0.06      -- duração de cada frame do slam (18 frames ≈ 1.08s)
local SLAM_BURST = 750           -- mudança de velocidade do impulso no impacto (≈50px de arrasto)
local TORNADO_DUR = 3.0          -- duração da animação de tornado
local TORNADO_EMIT_DELAY = 1.0   -- espera antes do primeiro tiro do tornado
local EMIT_RATE_START = 12       -- tiros/s no início da emissão
local EMIT_RATE_END = 24         -- tiros/s no fim da emissão
local SPIRAL_STEP = math.rad(22) -- incremento angular entre tiros do tornado
local SHAKE_SLAM_I = 30          -- intensidade do tremor da câmera no slam
local SHAKE_SLAM_DUR = 0.4       -- duração do tremor da câmera no slam
local SHAKE_WALL_I = 23          -- intensidade do tremor da câmera na batida na parede
local SHAKE_WALL_DUR = 0.7       -- duração do tremor da câmera na batida na parede

-- pesos de escolha dos ataques (proporção entre si)
local RUSH_WEIGHT = 15
local TORNADO_WEIGHT = 3
local SLAM_WEIGHT = 2

local CENTERED_OFFSET = vec(0, -35)
local NEUTRAL_OFFSET = vec(0, 0)

---@param enemy Enemy
---@param state State
---@return string
-- caminho da spritesheet de um estado do Moai Anciente
local function moaiSheetPath(enemy, state)
	return pngPathFormat({ "assets", "animations", "enemies", enemy.name, state })
end

---@param dir State
---@return State
-- estado de embalo em uma direção (que é a forma como o boss "anda")
local function rushState(dir)
	return WALKING_STATE[dir]
end

---@param dir State
---@return State
-- estado de batida na parede em uma direção
local function collisionState(dir)
	return COLLISION .. " " .. dir
end

---@param dir State
---@return State
-- estado de head slam em uma direção
local function slamState(dir)
	return ATTACKING .. " Head Slam " .. dir
end

-- estado de tornado shots
local TORNADO_STATE = ATTACKING .. " Tornado Shots"

---@param enemy Enemy
---@return State
-- direção cardinal mais próxima do alvo de movimento do inimigo
local function cardinalDirToTarget(enemy)
	if not enemy.moveTargeting.validTarget then
		return enemy.facing
	end
	local toTarget = subVec(enemy.moveTargeting.targetPos, enemy.pos)
	if math.abs(toTarget.y) >= math.abs(toTarget.x) then
		return toTarget.y < 0 and UP or DOWN
	else
		return toTarget.x < 0 and LEFT or RIGHT
	end
end

---@param enemy Enemy
-- carrega as animações do Ancient Moai (muitos mais estados que um inimigo
-- comum, então registramos manualmente em vez de usar Enemy:addAnimations)
local function addMoaiAnimations(enemy)
	----------------- ANDANDO / PARADO -----------------
	for _, dir in ipairs(DIRECTIONS) do
		local walkPath = moaiSheetPath(enemy, rushState(dir))
		addAnimation(
			enemy,
			walkPath,
			rushState(dir),
			newAnimSetting(9, { width = 200, height = 200 }, 0.12, true, 1, 4, CENTERED_OFFSET)
		)
		-- parado usa o primeiro frame da sheet de andar da mesma direção
		addAnimation(
			enemy,
			walkPath,
			IDLE .. " " .. dir,
			newAnimSetting(1, { width = 200, height = 200 }, 1000, true, 1, 4, CENTERED_OFFSET)
		)
	end

	----------------- BATIDA NA PAREDE -----------------
	for _, dir in ipairs(DIRECTIONS) do
		local state = collisionState(dir)
		local path = moaiSheetPath(enemy, state)
		addAnimation(
			enemy,
			path,
			state,
			newAnimSetting(10, { width = 200, height = 200 }, 0.08, false, 1, 4, CENTERED_OFFSET)
		)
		enemy.animations[state].onFinish = function()
			if enemy.phase == MOAI_COLLISION then
				enemy.facing = enemy.attackDir
				enemy.phase = MOAI_IDLE
				enemy.idleTimer = 0
			end
		end
	end

	----------------- HEAD SLAM -----------------
	for _, dir in ipairs(DIRECTIONS) do
		local state = slamState(dir)
		local path = moaiSheetPath(enemy, state)
		addAnimation(
			enemy,
			path,
			state,
			newAnimSetting(18, { width = 200, height = 200 }, SLAM_FRAME_DUR, false, 1, 0, NEUTRAL_OFFSET)
		)
	end

	----------------- TORNADO SHOTS -----------------
	addAnimation(
		enemy,
		moaiSheetPath(enemy, TORNADO_STATE),
		TORNADO_STATE,
		newAnimSetting(75, { width = 100, height = 150 }, TORNADO_DUR / 75, false, 1, 0, NEUTRAL_OFFSET)
	)

	----------------- MORRENDO -----------------
	addAnimation(
		enemy,
		moaiSheetPath(enemy, DYING),
		DYING,
		newAnimSetting(14, { width = 200, height = 200 }, 0.08, false, 1, 4, NEUTRAL_OFFSET)
	)
	enemy.animations[DYING].onFinish = function()
		enemy.isReallyDead = true
		if not enemy.leavesBody then
			table.remove(enemy.room.enemies, tableIndexOf(enemy.room.enemies, enemy))
		end
	end
end

---@param enemy Enemy
-- encerra imediatamente os eventos de ataque do embalo
local function stopRushAttack(enemy)
	local atk = enemy.atk[RUSH_ATK]
	if not atk then
		return
	end

	for i = #atk.events, 1, -1 do
		local e = atk.events[i]
		collisionManager:unregister(e)
		e:destroy()
	end
end

---@param enemy Enemy
-- volta para o estado ocioso e reinicia o timer de decisão
local function backToIdle(enemy)
	enemy.phase = MOAI_IDLE
	enemy.idleTimer = 0
	enemy.nextDecisionDelay = IDLE_DURATION
end

---@param enemy Enemy
---@param intensity number
---@param duration number
-- treme a câmera de todos os players presentes na sala do inimigo
local function shakeRoomCameras(enemy, intensity, duration)
	for _, player in enemy.room.playersInRoom:iter() do
		local cam = getCameraByPlayer(player)
		if cam then
			cam:shake(intensity, duration)
		end
	end
end

---@param enemy Enemy
---@return boolean
-- verifica se há espaço livre em alguma direção para o embalo
local function hasRushSpace(enemy)
	for _, dir in ipairs(DIRECTIONS) do
		if collisionManager:clearanceInDirection(enemy, DIR_VEC[dir], MAX_CLEARANCE) >= MIN_RUSH_DIST then
			return true
		end
	end
	return false
end

---@param enemy Enemy
---@return State
-- embalo prefere a direção do player quando há espaço livre.
-- caso contrário, sorteia entre as direções com espaço livre (com mais peso
-- para as direções mais livres)
local function pickRushDirection(enemy)
	local primary = cardinalDirToTarget(enemy)

	if collisionManager:clearanceInDirection(enemy, DIR_VEC[primary], MAX_CLEARANCE) >= MIN_RUSH_DIST then
		return primary
	end

	local weights = {}
	local total = 0

	for _, dir in ipairs(DIRECTIONS) do
		local clearance = collisionManager:clearanceInDirection(enemy, DIR_VEC[dir], MAX_CLEARANCE)
		if clearance >= MIN_RUSH_DIST then
			local w = clearance / MAX_CLEARANCE + 1
			weights[dir] = w
			total = total + w
		end
	end

	if total <= 0 then
		return primary
	end

	local roll = math.random() * total
	for _, dir in ipairs(DIRECTIONS) do
		local w = weights[dir]
		if w then
			roll = roll - w
			if roll < 0 then
				return dir
			end
		end
	end
	return primary
end

---@param enemy Enemy
---@return number?
-- decide a distância em que o embalo deve frear. Mira parar um pouco depois
-- do player no eixo do embalo. Retorna nil se o embalo deve ir
-- até a parede
local function pickRushStopDistance(enemy)
	local dir = DIR_VEC[enemy.attackDir]
	local clearance = collisionManager:clearanceInDirection(enemy, dir, MAX_CLEARANCE)
	if clearance < MIN_RUSH_DIST then
		return nil
	end

	if enemy.moveTargeting.validTarget then
		local toTarget = subVec(enemy.moveTargeting.targetPos, enemy.pos)
		local along = toTarget.x * dir.x + toTarget.y * dir.y
		-- player está à frente do embalo, para um pouco depois dele
		if along > 0 then
			local overshoot = RUSH_OVERSHOOT_MIN + math.random() * (RUSH_OVERSHOOT_MAX - RUSH_OVERSHOOT_MIN)
			local stopDist = along + overshoot
			-- se não cabe antes da parede, vai até a parede (colisão)
			if stopDist < clearance - STOP_MARGIN then
				return stopDist
			end
			return nil
		end
	end

	-- se não tem player sendo mirado, vai até a parede
	return nil
end

---@param enemy Enemy
-- inicia o ataque de embalo
local function startRush(enemy)
	enemy.attackDir = pickRushDirection(enemy)
	enemy.facing = enemy.attackDir
	stopMovement(enemy)
	enemy.rushTravel = 0
	enemy.rushStopDist = pickRushStopDistance(enemy)
	enemy.phase = MOAI_RUSH

	local dir = DIR_VEC[enemy.attackDir]
	enemy.atk[RUSH_ATK]:attack(enemy, vec(enemy.pos.x, enemy.pos.y), math.atan2(dir.y, dir.x))
end

---@param enemy Enemy
-- inicia o ataque de head slam, escolhendo quantas repetições serão feitas
local function startSlam(enemy)
	stopMovement(enemy)
	enemy.attackDir = cardinalDirToTarget(enemy)
	enemy.slamReps = math.random(2, 4)
	enemy.slamRep = 1
	enemy.slamImpactDone = false
	enemy.animations[slamState(enemy.attackDir)]:reset()
	enemy.phase = MOAI_SLAM
end

---@param enemy Enemy
-- inicia o ataque de tornado
local function startTornado(enemy)
	stopMovement(enemy)
	enemy.tornadoTimer = 0
	enemy.emitTimer = 0
	enemy.emitStarted = false
	enemy.spiralAngle = math.random() * 2 * math.pi
	enemy.animations[TORNADO_STATE]:reset()
	enemy.phase = MOAI_TORNADO
end

---@param enemy Enemy
---@param dt number
-- atualiza a emissão em espiral de tiros e o encerramento do tornado.
-- a emissão começa após `TORNADO_EMIT_DELAY` e a frequência sobe linearmente
-- de `EMIT_RATE_START` para `EMIT_RATE_END` tiros/s até o fim da animação
local function updateTornado(enemy, dt)
	enemy.tornadoTimer = enemy.tornadoTimer + dt

	if enemy.tornadoTimer >= TORNADO_EMIT_DELAY then
		local window = TORNADO_DUR - TORNADO_EMIT_DELAY
		local progress = math.min((enemy.tornadoTimer - TORNADO_EMIT_DELAY) / window, 1)
		local rate = EMIT_RATE_START + (EMIT_RATE_END - EMIT_RATE_START) * progress
		local interval = 1 / rate

		if not enemy.emitStarted then
			-- primeiro tiro exatamente no fim do delay
			enemy.emitStarted = true
			enemy.emitTimer = interval
		end

		enemy.emitTimer = enemy.emitTimer + dt
		while enemy.emitTimer >= interval do
			enemy.emitTimer = enemy.emitTimer - interval
			enemy.spiralAngle = enemy.spiralAngle + SPIRAL_STEP
			enemy.atk[TORNADO_ATK]:attack(enemy, vec(enemy.pos.x, enemy.pos.y), enemy.spiralAngle)
		end
	end

	if enemy.tornadoTimer >= TORNADO_DUR then
		backToIdle(enemy)
	end
end

---@param enemy Enemy
-- aplica uma força de freio proporcional à velocidade atual, sem
-- inverter o sentido do movimento
local function applyBrake(enemy)
	local speed = lenVec(enemy.vel)
	if speed <= BRAKE_STOP_SPEED then
		stopMovement(enemy)
		backToIdle(enemy)
		return
	end
	applyForce(enemy, scaleVec(normalize(enemy.vel), -BRAKE_FACTOR * speed * enemy.friction * enemy.mass))
end

---@param enemy Enemy
---@return boolean
-- sorteia um ataque disponível entre os pesos configurados.
-- retorna `false` se nenhum ataque está disponível
local function chooseNextAttack(enemy)
	local candidates = {}
	local total = 0

	if enemy.atk[RUSH_ATK].canAttack and hasRushSpace(enemy) then
		table.insert(candidates, { start = startRush, w = RUSH_WEIGHT })
		total = total + RUSH_WEIGHT
	end

	if enemy.atk[TORNADO_ATK].canAttack then
		table.insert(candidates, { start = startTornado, w = TORNADO_WEIGHT })
		total = total + TORNADO_WEIGHT
	end

	if enemy.atk[SLAM_ATK].canAttack then
		table.insert(candidates, { start = startSlam, w = SLAM_WEIGHT })
		total = total + SLAM_WEIGHT
	end

	if #candidates == 0 then
		return false
	end

	local roll = math.random() * total
	for _, c in ipairs(candidates) do
		roll = roll - c.w
		if roll < 0 then
			c.start(enemy)
			return true
		end
	end
	candidates[#candidates].start(enemy)
	return true
end

---@param spawnPos Vec
---@param room Room
---@return Enemy
-- cria um inimigo do tipo Ancient Moai
function newAncientMoai(spawnPos, room)
	local physics = physicsSettings(40, 160, 3, nil, nil, nil, 0.5)
	local hbs = hitboxes({ hitbox(Rectangle.new(200, 260)) })
	local rushAtk = newRollingRushAttack(false, 4.0, 20, hitboxes({ hitbox(Rectangle.new(220, 280)) }), "Moai Rush")
	local slamAtk = newRotatoryAttack(false, 0.5, constCooldown(0), hitbox(Circle.new(250)), "Head Slam", 25)
	local tornadoAtk = newPebbleShotAttack(false, 2.5, randCooldown(4, 6), 520, nil, 25)

	local enemy = Enemy.new(
		ANCIENT_MOAI.name,
		500,
		spawnPos,
		physics,
		followTargetMovement(),
		{ rushAtk, slamAtk, tornadoAtk },
		hbs,
		room
	)
	enemy.facing = DIRECTIONS[math.random(#DIRECTIONS)]
	enemy.state = IDLE .. " " .. enemy.facing

	-- máquina de estados do Ancient Moai
	enemy.phase = MOAI_IDLE
	enemy.idleTimer = 0
	enemy.nextDecisionDelay = IDLE_DURATION
	enemy.attackDir = enemy.facing
	enemy.rushStopDist = nil
	enemy.rushTravel = 0
	enemy.slamReps = 0
	enemy.slamRep = 0
	enemy.slamImpactDone = false
	enemy.tornadoTimer = 0
	enemy.emitTimer = 0
	enemy.emitStarted = false
	enemy.spiralAngle = 0

	-- o construtor do embalo usa constCooldown(0); damos a ele um cooldown
	-- variável para não encadear embalos direto (slam/tornado já têm os seus)
	enemy.atk[RUSH_ATK].cooldown = randCooldown(1, 2)

	enemy.isBoss = true
	enemy.shadowWidth = 90

	addMoaiAnimations(enemy)

	-- o targeting existe para seguir o player e mirar os ataques
	enemy.moveTargeting:addTarget(Target.new(TG_SEEK, TC_EVERY_FRAME), seekClosestPlayer)
	enemy.atkTargeting:addTarget(Target.new(TG_SEEK, TC_EVERY_FRAME), seekClosestPlayer)

	-------- sobrescritas da máquina de estado -----------

	-- só atualiza cooldowns e eventos; o início/gatilho dos ataques é manual
	enemy.updateAttack = function(self, dt)
		for _, atk in pairs(self.atk) do
			atk:updateTimer(dt)
			atk:update(dt)
		end
	end

	enemy.updateMotion = function(self, dt)
		if self.state == DYING then
			return
		end

		if self.phase == MOAI_RUSH then
			-- força constante durante todo o embalo
			applyForce(self, scaleVec(DIR_VEC[self.attackDir], RUSH_ACCEL * self.mass))
			self.rushTravel = self.rushTravel + lenVec(self.vel) * dt
			if self.rushStopDist and self.rushTravel >= self.rushStopDist then
				stopRushAttack(self)
				self.phase = MOAI_BRAKE
			elseif not self.rushStopDist and self.rushTravel >= MAX_CLEARANCE then
				-- encerra o embalo sem colisão
				stopRushAttack(self)
				backToIdle(self)
			end
		elseif self.phase == MOAI_BRAKE then
			applyBrake(self)
		elseif self.phase == MOAI_TORNADO then
			updateTornado(self, dt)
		elseif self.phase == MOAI_COLLISION or self.phase == MOAI_SLAM then
			-- parado
		elseif self.fearTimer.active then
			followTarget(self, dt)
		end
		-- se está em MOAI_IDLE fica parado
	end

	enemy.updateState = function(self, dt)
		if self.state == DYING then
			self.animations[DYING]:update(dt)
			return
		end

		-- depois de ficar parado, escolhe o próximo ataque
		if self.phase == MOAI_IDLE and not self.fearTimer.active then
			self.idleTimer = self.idleTimer + dt
			if self.idleTimer >= self.nextDecisionDelay then
				if not chooseNextAttack(self) then
					self.nextDecisionDelay = RETRY_DELAY
				end
				self.idleTimer = 0
			end
		end

		local prevState = self.state

		-- mapeia a fase atual para o estado de animação
		if self.phase == MOAI_RUSH or self.phase == MOAI_BRAKE then
			self.state = rushState(self.attackDir)
		elseif self.phase == MOAI_COLLISION then
			self.state = collisionState(self.attackDir)
		elseif self.phase == MOAI_SLAM then
			self.state = slamState(self.attackDir)
		elseif self.phase == MOAI_TORNADO then
			self.state = TORNADO_STATE
		else
			self.state = IDLE .. " " .. self.facing
		end

		if self.state ~= prevState then
			self.animations[prevState]:reset()
		end

		self.animations[self.state]:update(dt)

		-- lógica do head slam
		if self.phase == MOAI_SLAM then
			local anim = self.animations[self.state]
			if not self.slamImpactDone and anim.currFrame >= SLAM_IMPACT_FRAME then
				self.slamImpactDone = true
				local dir = DIR_VEC[self.attackDir]
				self.atk[SLAM_ATK]:attack(self, vec(self.pos.x, self.pos.y), math.atan2(dir.y, dir.x))
				applyImpulse(self, scaleVec(dir, SLAM_BURST * self.mass))
				shakeRoomCameras(self, SHAKE_SLAM_I, SHAKE_SLAM_DUR)
			end

			if anim.isFinished then
				self.slamRep = self.slamRep + 1
				if self.slamRep > self.slamReps then
					backToIdle(self)
				else
					-- recalcula a direção em relação ao player para o próximo slam
					self.attackDir = cardinalDirToTarget(self)
					self.slamImpactDone = false
					self.animations[slamState(self.attackDir)]:reset()
				end
			end
		end
	end

	enemy.interruptAttack = function(self)
		Enemy.interruptAttack(self)

		if self.phase == MOAI_RUSH then
			stopRushAttack(self)
			self.facing = self.attackDir
		end
		if self.phase ~= MOAI_IDLE then
			stopMovement(self)
			backToIdle(self)
		end
	end

	-- chamado pelo CollisionManager quando ele bate numa parede
	enemy.onSolidHit = function(self)
		if self.state == DYING or self.phase ~= MOAI_RUSH then
			return
		end
		stopRushAttack(self)
		self.facing = self.attackDir
		self.animations[collisionState(self.attackDir)]:reset()
		self.phase = MOAI_COLLISION
		-- pancada na parede machuca e deixa o boss atordoado por mais tempo
		self.nextDecisionDelay = WALL_STUN_DURATION
		self:takeDamage(WALL_CRASH_DMG)
		shakeRoomCameras(self, SHAKE_WALL_I, SHAKE_WALL_DUR)
	end

	return enemy
end
