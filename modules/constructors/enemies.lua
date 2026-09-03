----------------------------------------
-- Importações de Módulos
----------------------------------------
require("modules.constructors.attacks")
require("modules.constructors.cooldowns")
require("modules.constructors.targetstrats")
require("modules.constructors.movements")
require("modules.utils.easing")

---@param spawnPos Vec
---@param room Room
---@return Enemy
-- cria um inimigo do tipo Gato Nuclear
function newNuclearCat(spawnPos, room)
	local movementFunc = avoidTargetMovement(450, 0.75, 1.25, math.rad(30), Easing.inOutQuad)
	local atksCooldown = randMultiCooldown({ 1.0, 2.0, 3.0 })
	local attack = newNuclearShotAttack(false, 5.0, atksCooldown, 400, function()
		return zigZagMovement(600, 10)
	end)
	local attackSlow = newNuclearShotAttack(false, 10.0, atksCooldown, 300, nil)
	local atks = { attack, attackSlow }
	local hb = hitbox(Rectangle.new(40, 70))
	local hbs = hitboxes({ hb })
	local physics = physicsSettings(1, 65, 4)
	local atkFrames = {
		[attack.name] = 22,
		[attackSlow.name] = 22,
	}
	local attackAnimSettings = {
		[attack.name] = newAnimSetting(28, { width = 32, height = 32 }, 0.1, false),
		[attackSlow.name] = newAnimSetting(28, { width = 32, height = 32 }, 0.1, false),
	}
	local enemy = Enemy.new(NUCLEAR_CAT.name, 30, spawnPos, physics, movementFunc, atks, hbs, room, atkFrames)
	local idleAnimSettings = newAnimSetting(15, { width = 32, height = 32 }, 0.15, true, 1)
	local walkingAnimSettings = newAnimSetting(4, { width = 32, height = 32 }, 0.15, true, 1)
	local dyingAnimSettings = newAnimSetting(33, { width = 32, height = 32 }, 0.1, false, 1)
	enemy:addAnimations(idleAnimSettings, walkingAnimSettings, dyingAnimSettings, attackAnimSettings)
	enemy.shadowWidth = 30
	enemy.moveTargeting:addTarget(Target.new(TG_SEEK, TC_EVERY_FRAME), seekClosestPlayer)
	enemy.atkTargeting:addTarget(Target.new(TG_SEEK, TC_EVERY_FRAME), seekClosestPlayer)
	return enemy
end

---@param spawnPos Vec
---@param room Room
---@return Enemy
-- cria um inimigo do tipo Pato Aranha
function newSpiderDuck(spawnPos, room)
	local movementFunc = dashToTargetMovement(1.2, 1.5, Easing.outQuad, math.rad(10))
	local atkCooldown = randCooldown(3.0, 4.0)
	local frameDur = 0.1
	local framesAtks = 12
	local atkDur = framesAtks * frameDur
	local framesStart = 5
	local startDur = framesStart * frameDur
	local attack = newRotatoryAttack(false, atkDur, atkCooldown)
	local movements = {
		[attack.name] = function()
			local moveBuilder = function()
				return spiralMovement(math.random(30, 50), math.random(15, 25))
			end
			return randomMovement(atkDur, startDur, moveBuilder)
		end,
	}
	local atkFrames = {
		[attack.name] = 4,
	}
	local attackAnimSettings = {
		[attack.name] = newAnimSetting(22, { width = 32, height = 50 }, frameDur, false, 1, 4, vec(0, -9)),
	}
	local atks = { attack }
	local hb = hitbox(Circle.new(25))
	local hbs = hitboxes({ hb })
	local physics = physicsSettings(0.8, 50, 5)
	local enemy =
		Enemy.new(SPIDER_DUCK.name, 20, spawnPos, physics, movementFunc, atks, hbs, room, atkFrames, movements)
	local idleAnimSettings = newAnimSetting(2, { width = 32, height = 32 }, 0.4, true, 1)
	local walkingAnimSettings = newAnimSetting(4, { width = 32, height = 32 }, 0.15, true, 1)
	local dyingAnimSettings = newAnimSetting(4, { width = 32, height = 32 }, 0.1, false)
	enemy:addAnimations(idleAnimSettings, walkingAnimSettings, dyingAnimSettings, attackAnimSettings)
	enemy.shadowWidth = 30
	enemy.moveTargeting:addTarget(Target.new(TG_SEEK, TC_EVERY_FRAME), seekClosestPlayer)
	enemy.atkTargeting:addTarget(Target.new(TG_SEEK, TC_EVERY_FRAME), seekClosestPlayer)
	return enemy
end

---@param spawnPos Vec
---@param room Room
---@return Enemy
-- cria um inimigo do tipo Bolota Demoníaca (essa bolota é uma gambiarra do caralho)
function newDemonBall(spawnPos, room)
	-- movimentação em "pulos"
	local movementFunc = jumpToTargetMovement(0.65, 0.65, 35, Easing.outCubic, 0.9)
	local jumpDur = 1.12
	local atkDur = jumpDur / 2
	local jumpAtk = newDemonJumpAttack(atkDur)
	local emberAtk = newEmberMarkAttack(false)

	-- o movimento de ataque kamikaze
	local movements = {
		[jumpAtk.name] = function()
			local dashMove = dashToTargetMovement(jumpDur - 0.4, 0, Easing.outCubic, 0, 1.5)
			local time = 0
			local hasStopped = false
			return function(entity, dt)
				time = time + dt
				if not hasStopped then
					entity.friction = 4
					hasStopped = true
				end
				if time >= 0.4 then
					dashMove(entity, dt)
				end

				-- se o dash terminou e a bolota ainda não morreu
				if time >= jumpDur and entity.state ~= DYING then
					-- spawna a marca de brasa no local atual
					AttackEvent.new(emberAtk, entity, addVec(entity.pos, vec(0, 30)), 0)
					-- mata a bolota
					entity.hp = 0
					entity:die()
				end
			end
		end,
	}

	-- configs do ataque kamikaze
	local atkFrames = {
		[jumpAtk.name] = 10,
	}
	local attackAnimSettings = {
		[jumpAtk.name] = newAnimSetting(18, { width = 18, height = 36 }, 0.056, false),
	}

	-- física e hitboxes
	local atks = { jumpAtk, emberAtk }
	local hb = hitbox(Circle.new(10), vec(0, 10))
	local hbs = hitboxes({ hb })
	local physics = physicsSettings(0.6, 60, 1)

	local enemy = Enemy.new(DEMON_BALL.name, 1, spawnPos, physics, movementFunc, atks, hbs, room, atkFrames, movements)

	-- a bolota demoníaca não tem sombra
	enemy.hasShadow = false

	-- animações
	local idleAnimSettings = newAnimSetting(2, { width = 18, height = 36 }, 0.45, true, 1)
	local walkingAnimSettings = newAnimSetting(14, { width = 18, height = 36 }, 0.08, true, 1)
	local dyingAnimSettings = newAnimSetting(1, { width = 1, height = 1 }, 0.1, false)
	enemy:addAnimations(idleAnimSettings, walkingAnimSettings, dyingAnimSettings, attackAnimSettings)

	-- o ataque mira no player mas tem um raio de ação
	local function seekPlayerInRange(tm, target)
		seekClosestPlayer(tm, target)
		-- se achou um alvo, mas está mais longe que certa distância, remove o peso do alvo para não atacar ainda
		if target.weight > 0 and dist(tm.owner.pos, target.pos) > 200 then
			target.weight = 0
		end
	end
	enemy.atkTargeting:addTarget(Target.new(TG_SEEK, TC_EVERY_FRAME), seekPlayerInRange)
	-- o movimento mira sempre no player
	enemy.moveTargeting:addTarget(Target.new(TG_SEEK, TC_EVERY_FRAME), seekClosestPlayer)

	return enemy
end

----------------------------------------------
--- Bosses
----------------------------------------------

---@param spawnPos Vec
---@param room Room
---@return Enemy
-- cria um inimigo do tipo Pato Aranha BOSS
function newSpiderDuckBoss(spawnPos, room)
	local movementFunc = dashToTargetMovement(1.2, 1.5, Easing.outQuad, math.rad(10))
	local atkCooldown = randCooldown(3.0, 4.0)
	local frameDur = 0.1
	local framesAtks = 12
	local atkDur = framesAtks * frameDur
	local framesStart = 5
	local startDur = framesStart * frameDur
	local attackRotate = newRotatoryAttack(false, atkDur, atkCooldown, hitbox(Circle.new(100), vec(0, -60)))
	local attackSpawn = Attack.new(
		SPAWN_ATTACK,
		newAtkSetting({
			subtype = SPAWN_ATTACK,
			ally = false,
			cooldown = constCooldown(12),
		})
	)
	attackSpawn:addAttackFunc(spawnCircularEntitiesAsAttack(1, 3, nil, SPIDER_DUCK, vec(0, 100)))
	local movements = {
		[attackRotate.name] = function()
			local moveBuilder = function()
				return spiralMovement(math.random(30, 50), math.random(15, 25))
			end
			return randomMovement(atkDur, startDur, moveBuilder)
		end,
	}
	local atkFrames = {
		[attackRotate.name] = 4,
		[attackSpawn.name] = 2,
	}
	local attackAnimSettings = {
		[attackRotate.name] = newAnimSetting(22, { width = 32, height = 50 }, frameDur, false, nil, nil, vec(0, -9)),
		[attackSpawn.name] = newAnimSetting(2, { width = 32, height = 32 }, 0.5, false),
	}
	local atks = { attackSpawn, attackRotate }
	local hb = hitbox(Circle.new(50))
	local hbs = hitboxes({ hb })
	local physics = physicsSettings(0.8, 50, 5)
	local enemy =
		Enemy.new(SPIDER_DUCK.name, 200, spawnPos, physics, movementFunc, atks, hbs, room, atkFrames, movements)
	local idleAnimSettings = newAnimSetting(2, { width = 32, height = 32 }, 0.4, true, 1)
	local walkingAnimSettings = newAnimSetting(4, { width = 32, height = 32 }, 0.15, true, 1)
	local dyingAnimSettings = newAnimSetting(4, { width = 32, height = 32 }, 0.1, false)
	enemy:addAnimations(idleAnimSettings, walkingAnimSettings, dyingAnimSettings, attackAnimSettings)
	enemy.scale = 5
	enemy.shadowWidth = 50
	enemy.isBoss = true
	enemy.moveTargeting:addTarget(Target.new(TG_SEEK, TC_EVERY_FRAME), seekClosestPlayer)
	enemy.atkTargeting:addTarget(Target.new(TG_SEEK, TC_EVERY_FRAME), seekClosestPlayer)
	return enemy
end
