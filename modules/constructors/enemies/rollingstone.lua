----------------------------------------------
--- Rolling Stone
----------------------------------------------

-- código de direção usado nos nomes dos spritesheets (ex.: "rotating ur")
local DIR_CODE = { [UP] = "u", [DOWN] = "d", [LEFT] = "l", [RIGHT] = "r" }
-- vetor unitário de cada direção
local DIR_VEC = {
	[UP] = vec(0, -1),
	[DOWN] = vec(0, 1),
	[LEFT] = vec(-1, 0),
	[RIGHT] = vec(1, 0),
}
-- fases da máquina de estado do Rolling Stone
local RS_IDLE = "rs idle"
local RS_ROTATING = "rs rotating"
local RS_ROLLING = "rs rolling"
local RS_STOPING = "rs stoping"

local IDLE_DURATION = 1.5 -- tempo que o Rolling Stone fica parado antes de escolher uma direção de ataque
local ROLL_ACCEL = 3500 -- aceleração do embalo
local WALL_RESTITUTION = 0.8 -- força do knockback ao bater nas paredes
local MIN_CLEARANCE = 300 -- espaço mínimo que uma direção precisa ter para ser candidata ao ataque
local MAX_CLEARANCE = 600 -- distância máxima verificada na checagem de espaço livre

---@param fromDir State
---@param toDir State
---@return State
-- estado de rotação de uma direção inicial para uma direção final
local function rsRotatingState(fromDir, toDir)
	return ROTATING .. " " .. DIR_CODE[fromDir] .. DIR_CODE[toDir]
end

---@param dir State
---@return State
-- estado de embalo (rolagem) em uma direção
local function rsAttackState(dir)
	return ATTACKING .. " " .. dir
end

---@param dir State
---@return State
-- estado de batida na parede em uma direção
local function rsStopingState(dir)
	return STOPING .. " " .. dir
end

---@param enemy Enemy
---@param state State
---@return string
-- caminho da spritesheet de um estado do Rolling Stone
local function rsSheetPath(enemy, state)
	return pngPathFormat({ "assets", "animations", "enemies", enemy.name, state })
end

---@param path string
---@param quad number
---@return number
-- conta a quantidade de frames de uma spritesheet de linha única
local function rsFrameCount(path, quad)
	local gap = 4
	local img = assetManager:getImage(path)
	return math.floor((img:getWidth() + gap) / (quad + gap))
end

---@param enemy Enemy
-- carrega as animações do pedregulho (tem muito mais animação do que um inimigo comum)
local function addRollingStoneAnimations(enemy)
	----------------- IDLE -----------------
	-- fica parado no primeiro frame da sheet de ataque para cima
	for _, dir in ipairs(DIRECTIONS) do
		local state = IDLE .. " " .. dir
		local idlePath = pngPathFormat({ "assets", "animations", "enemies", enemy.name, state })
		addAnimation(enemy, idlePath, state, newAnimSetting(1, { width = 32, height = 32 }, 1000, true))
	end

	----------------- ROTACIONANDO -----------------
	for _, fromDir in ipairs(DIRECTIONS) do
		for _, toDir in ipairs(DIRECTIONS) do
			if fromDir ~= toDir then
				local state = rsRotatingState(fromDir, toDir)
				local path = rsSheetPath(enemy, state)
				local numFrames = rsFrameCount(path, 32)
				addAnimation(
					enemy,
					path,
					state,
					newAnimSetting(numFrames, { width = 32, height = 32 }, 0.5 / numFrames, false)
				)
				enemy.animations[state].onFinish = function()
					if enemy.phase == RS_ROTATING then
						stopMovement(enemy)
						enemy.phase = RS_ROLLING
					end
				end
			end
		end
	end

	----------------- ATACANDO -----------------
	for _, dir in ipairs(DIRECTIONS) do
		local state = rsAttackState(dir)
		local path = rsSheetPath(enemy, state)
		local numFrames = rsFrameCount(path, 36)
		addAnimation(enemy, path, state, newAnimSetting(numFrames, { width = 36, height = 36 }, 0.1, true))
	end

	----------------- PARANDO -----------------
	for _, dir in ipairs(DIRECTIONS) do
		local state = rsStopingState(dir)
		local path = rsSheetPath(enemy, state)
		local numFrames = rsFrameCount(path, 32)
		addAnimation(enemy, path, state, newAnimSetting(numFrames, { width = 32, height = 32 }, 0.08, false))
		enemy.animations[state].onFinish = function()
			if enemy.phase == RS_STOPING then
				enemy.facing = enemy.attackDir
				enemy.phase = RS_IDLE
				enemy.idleTimer = 0
			end
		end
	end

	----------------- MORRENDO -----------------
	-- !TODO: animação de morte da pedra rolante
	local dyingPath = rsSheetPath(enemy, rsStopingState(DOWN))
	local dyingFrames = rsFrameCount(dyingPath, 32)
	addAnimation(enemy, dyingPath, DYING, newAnimSetting(dyingFrames, { width = 32, height = 32 }, 0.08, false))
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
	local atk = enemy.atk[1]
	if not atk then
		return
	end

	for i = #atk.events, 1, -1 do
		local e = atk.events[i]
		collisionManager:unregister(e)
		e:destroy()
	end
end

---@param spawnPos Vec
---@param room Room
---@return Enemy
-- cria um inimigo do tipo Rolling Stone: ele fica parado, escolhe uma
-- direção, vira para ela e se embala em linha reta até bater na parede
function newRollingStone(spawnPos, room)
	local physics = physicsSettings(30, 0, 3, nil, nil, nil, WALL_RESTITUTION)
	local hbs = hitboxes({ hitbox(Circle.new(32)) }, { hitbox(Circle.new(30)) })
	local rollAtk = newRollingRushAttack(false, 4.0, 20, hitboxes({ hitbox(Circle.new(40)) }))

	local enemy = Enemy.new(ROLLING_STONE.name, 30, spawnPos, physics, function() end, { rollAtk }, hbs, room)
	enemy.state = "idle down"

	-- Máquina de estados do Rolling Stone
	enemy.phase = RS_IDLE
	enemy.lastPhase = RS_IDLE
	enemy.idleTimer = 0
	enemy.attackDir = nil
	enemy.facing = DIRECTIONS[math.random(#DIRECTIONS)]
	enemy.rollAccel = ROLL_ACCEL
	enemy.contactDamage = false

	addRollingStoneAnimations(enemy)

	enemy.shadowWidth = 32
	-- o targeting existe só para dar a direção com viés para o player
	enemy.moveTargeting:addTarget(Target.new(TG_SEEK, TC_EVERY_FRAME), seekClosestPlayer)

	---@return State
	-- sorteia a direção de ataque entre as direções com espaço livre (os lados
	-- opostos da sala), com mais peso na direção do player
	local function pickAttackDirection()
		local openDirs = {}
		local bestDirs = {}
		local bestClearance = -1

		-- descobre quais direções têm espaço para o embalo
		for _, dir in ipairs(DIRECTIONS) do
			local clearance = collisionManager:clearanceInDirection(enemy, DIR_VEC[dir], MAX_CLEARANCE)

			if clearance >= MIN_CLEARANCE then
				table.insert(openDirs, dir)
			end

			if clearance > bestClearance then
				bestClearance = clearance
				bestDirs = { dir }
			elseif clearance == bestClearance then
				table.insert(bestDirs, dir)
			end
		end

		-- se nenhuma direção tem espaço mínimo, usa as mais abertas
		if #openDirs == 0 then
			openDirs = bestDirs
		end

		-- direção cardinal mais próxima do player
		local primary
		if enemy.moveTargeting.validTarget then
			local toTarget = subVec(enemy.moveTargeting.targetPos, enemy.pos)
			if math.abs(toTarget.y) >= math.abs(toTarget.x) then
				primary = toTarget.y < 0 and UP or DOWN
			else
				primary = toTarget.x < 0 and LEFT or RIGHT
			end
		end

		local weights = {}
		local total = 0
		for _, dir in ipairs(openDirs) do
			weights[dir] = dir == primary and 4 or 1
			total = total + weights[dir]
		end

		local roll = math.random() * total
		for _, dir in ipairs(openDirs) do
			roll = roll - weights[dir]
			if roll < 0 then
				return dir
			end
		end
		return openDirs[#openDirs]
	end

	-- decide a direção de ataque e sai do IDLE
	local function chooseAttackDirection()
		enemy.attackDir = pickAttackDirection()
		stopMovement(enemy)
		enemy.phase = enemy.attackDir == enemy.facing and RS_ROLLING or RS_ROTATING
	end

	-------- sobrescritas da máquina de estado -----------

	enemy.updateState = function(self, dt)
		if self.state == DYING then
			self.animations[DYING]:update(dt)
			return
		end

		-- depois de ficar parado, escolhe a direção do ataque
		if self.phase == RS_IDLE and not self.fearTimer.active then
			self.idleTimer = self.idleTimer + dt
			if self.idleTimer >= IDLE_DURATION then
				chooseAttackDirection()
			end
		end

		local prevState = self.state
		if self.phase == RS_ROTATING then
			self.state = rsRotatingState(self.facing, self.attackDir)
		elseif self.phase == RS_ROLLING then
			self.state = rsAttackState(self.attackDir)
		elseif self.phase == RS_STOPING then
			self.state = rsStopingState(self.attackDir)
		else
			self.state = IDLE .. " " .. self.facing
		end

		if self.state ~= prevState then
			self.animations[prevState]:reset()
		end

		self.animations[self.state]:update(dt)

		-- cria/destrói o AttackEvent do embalo conforme a fase
		if self.phase ~= self.lastPhase then
			if self.phase == RS_ROLLING then
				local dir = DIR_VEC[self.attackDir]
				self.atk[1]:attack(self, vec(self.pos.x, self.pos.y), math.atan2(dir.y, dir.x))
			elseif self.lastPhase == RS_ROLLING then
				stopRushAttack(self)
			end
			self.lastPhase = self.phase
		end
	end

	enemy.updateMotion = function(self, dt)
		if self.state == DYING then
			return
		end

		if self.phase == RS_ROLLING then
			-- força constante durante todo o embalo
			applyForce(self, scaleVec(DIR_VEC[self.attackDir], self.rollAccel * self.mass))
		end
	end

	enemy.interruptAttack = function(self)
		Enemy.interruptAttack(self)

		if self.phase == RS_ROLLING or self.phase == RS_ROTATING then
			if self.phase == RS_ROLLING then
				self.facing = self.attackDir
			end
			stopMovement(self)
			self.phase = RS_IDLE
			self.idleTimer = 0
		end
	end

	-- chamado pelo CollisionManager quando ele bate numa parede
	enemy.onSolidHit = function(self)
		if self.state == DYING or self.phase ~= RS_ROLLING then
			return
		end
		stopRushAttack(self)
		self.phase = RS_STOPING
	end

	return enemy
end
