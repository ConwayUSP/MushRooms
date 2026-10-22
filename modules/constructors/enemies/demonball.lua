----------------------------------------------
--- Bolota Demoníaca
----------------------------------------------

local JUMP_FRAME_DUR = 0.065
local JUMP_START_FRAME = 5 -- frame que a bolota inicia o pulo
local JUMP_END_FRAME = 10  -- frame que a bolota termina o pulo

local ATTACK_FRAME_COUNT = 18
local ATTACK_JUMP_START_FRAME = 11 -- frame que a bolota inicia o pulo kamikaze
local ATTACK_JUMP_END_FRAME = 17   -- frame que a bolota termina o pulo kamikaze

local JUMP_ANGLE_VARIANCE = math.rad(20)
local MIN_JUMP_SPEED = 400
local MAX_JUMP_SPEED = 500
local MIN_ATK_SPEED = 500
local MAX_ATK_SPEED = 600
local LANDING_FRICTION = 1 -- fricição aplicada no pouso

-- função de targeting do ataque mira no player mas tem um raio de ação
local function seekPlayerInRange(tm, target)
	seekClosestPlayer(tm, target)
	local attackRange = tm.owner.attackRange or 200
	-- se achou um alvo, mas está mais longe que certa distância, remove o peso do alvo para não atacar ainda
	if target.weight > 0 and dist(tm.owner.pos, target.pos) > attackRange then
		target.weight = 0
	end
end

---@param spawnPos Vec
---@param room Room
---@return Enemy
-- cria um inimigo do tipo Bolota Demoníaca
function newDemonBall(spawnPos, room)
	local jumpDir = nil
	local isJumping = false
	local previousJumping = false
	local movementState = WALKING_DOWN
	local groundPause = 0 -- tempo que a bolota fica parada antes de continuar a se mover

	local function walkingStateFromDirection(dir)
		if math.abs(dir.y) > math.abs(dir.x) then
			return dir.y < 0 and WALKING_UP or WALKING_DOWN
		end

		return dir.x < 0 and WALKING_LEFT or WALKING_RIGHT
	end

	-- se movimenta somente enquanto a bolota está no ar
	local movementFunc = function(entity, dt)
		local animation = entity.animations[movementState]
		isJumping = animation.currFrame >= JUMP_START_FRAME and animation.currFrame <= JUMP_END_FRAME

		-- se acabou de iniciar o pulo, aplica impulso na direção do player
		if isJumping and not previousJumping and entity.moveTargeting.validTarget then
			jumpDir = normalize(subVec(entity.moveTargeting.targetPos, entity.pos))
			jumpDir = rotateVec(jumpDir, (math.random() * 2 - 1) * JUMP_ANGLE_VARIANCE)
			movementState = walkingStateFromDirection(jumpDir)
			entity.friction = 0

			local jumpSpeed = math.random(MIN_JUMP_SPEED, MAX_JUMP_SPEED)
			applyImpulse(entity, scaleVec(jumpDir, entity.mass * jumpSpeed))
		end

		-- se acabou de pousar do pulo, aplica fricção e reseta a direção do pulo
		if not isJumping and previousJumping then
			entity.friction = LANDING_FRICTION
			groundPause = 0.06 + math.random() * 0.10
			jumpDir = nil
		end

		previousJumping = isJumping
	end

	local jumpDur = ATTACK_FRAME_COUNT * JUMP_FRAME_DUR
	local atkDur = jumpDur / 2
	local jumpAtk = newDemonJumpAttack(atkDur)
	local emberAtk = newEmberMarkAttack(false)

	-- faz o pulo kamikaze somente se estiver no ar
	local movements = {
		[jumpAtk.name] = function()
			local attackJumpDir = nil
			local previousAttackJumping = false

			return function(entity, dt)
				if not entity:isAttackState() then
					previousAttackJumping = false
					return
				end

				local animation = entity.animations[entity.state]
				local isAttackJumping = animation.currFrame >= ATTACK_JUMP_START_FRAME
					and animation.currFrame <= ATTACK_JUMP_END_FRAME
				local isPreJumping = animation.currFrame < ATTACK_JUMP_START_FRAME
				local targetPos = entity.atkTargeting.validTarget and entity.atkTargeting.targetPos or nil

				-- se target se distanciou demais, cancela o ataque e volta a se movimentar
				if isPreJumping and not targetPos then
					jumpAtk.timer = 0
					jumpAtk.canAttack = true
					entity:interruptAttack()
					return
				end

				-- se acabou de iniciar o pulo kamikaze, aplica impulso na direção do player
				if isAttackJumping and not previousAttackJumping and targetPos then
					attackJumpDir = normalize(subVec(targetPos, entity.pos))
					attackJumpDir = rotateVec(attackJumpDir, (math.random() * 2 - 1) * JUMP_ANGLE_VARIANCE)
					entity.friction = 0

					-- TODO: talvez seja melhor trocar applyImpulse por outra função, para que o pulo kamikaze seja mais "assertivo"
					local jumpSpeed = math.random(MIN_ATK_SPEED, MAX_ATK_SPEED)
					applyImpulse(entity, scaleVec(attackJumpDir, entity.mass * jumpSpeed))
				end

				-- se acabou de pousar do pulo kamikaze, aplica fricção e reseta a direção do pulo
				if not isAttackJumping and previousAttackJumping then
					entity.friction = LANDING_FRICTION
					attackJumpDir = nil
				end

				previousAttackJumping = isAttackJumping
			end
		end,
	}

	-- configs do ataque kamikaze
	local atkFrames = {
		[jumpAtk.name] = ATTACK_JUMP_START_FRAME,
	}
	local attackAnimSettings = {
		[jumpAtk.name] = newAnimSetting(ATTACK_FRAME_COUNT, { width = 18, height = 36 }, JUMP_FRAME_DUR, false),
	}

	-- física e hitboxes
	local atks = { jumpAtk }
	local hb = hitbox(Circle.new(10), vec(0, 10))
	local hbs = hitboxes({ hb })
	local physics = physicsSettings(0.6, 50, LANDING_FRICTION)

	local enemy = Enemy.new(DEMON_BALL.name, 30, spawnPos, physics, movementFunc, atks, hbs, room, atkFrames, movements)
	enemy.attackRange = math.random(150, 200)
	enemy.hasShadow = true
	enemy.leavesBody = false

	-- animações
	local idleAnimSettings = newAnimSetting(2, { width = 18, height = 36 }, 0.45, true, 1)
	local walkingAnimSettings = newAnimSetting(14, { width = 18, height = 36 }, JUMP_FRAME_DUR, true, 1)
	local dyingAnimSettings = newAnimSetting(1, { width = 1, height = 1 }, 0.1, false)
	enemy:addAnimations(idleAnimSettings, walkingAnimSettings, dyingAnimSettings, attackAnimSettings)

	enemy.state = movementState
	local initialFrame = math.random(1, walkingAnimSettings.numFrames)
	local initialTimer = math.random() * JUMP_FRAME_DUR
	for _, state in ipairs({ WALKING_UP, WALKING_DOWN, WALKING_LEFT, WALKING_RIGHT }) do
		enemy.animations[state].currFrame = initialFrame
		enemy.animations[state].timer = initialTimer
	end

	-- só tenta atacar se não estiver pulando
	enemy.tryStartAttack = function(self)
		if isJumping then
			return
		end

		Enemy.tryStartAttack(self)
	end

	for _, direction in ipairs(DIRECTIONS) do
		local state = ATTACKING .. " " .. jumpAtk.name .. " " .. direction
		local animation = enemy.animations[state]
		local baseOnFinish = animation.onFinish

		-- cria a EMBER_MARK no final da animação de ataque
		animation.onFinish = function()
			baseOnFinish()
			AttackEvent.new(emberAtk, enemy, addVec(enemy.pos, vec(0, 30)), 0)
			table.insert(room.detachedAttacks, emberAtk)
			enemy.hp = 0
			enemy:die()
		end
	end

	-- mantém a animação de caminhada em execução durante os frames de chão.
	enemy.updateState = function(self, dt)
		if self.state == DYING or self.isAttacking then
			Enemy.updateState(self, dt)
			return
		end

		local previousState = self.state
		self.state = movementState

		if self.state ~= previousState then
			self.animations[self.state].currFrame = self.animations[previousState].currFrame
			self.animations[self.state].timer = self.animations[previousState].timer
			self.animations[previousState]:reset()
		end

		if groundPause > 0 then
			groundPause = groundPause - dt
		else
			self.animations[self.state]:update(dt)
		end
	end

	-- targeting
	enemy.atkTargeting:addTarget(Target.new(TG_SEEK, TC_EVERY_FRAME), seekPlayerInRange)
	enemy.moveTargeting:addTarget(Target.new(TG_SEEK, TC_EVERY_FRAME), seekClosestPlayer)
	enemy.moveTargeting:addTarget(Target.new(TG_SEEK, TC_EVERY_FRAME), avoidNearbyEnemies)

	return enemy
end
