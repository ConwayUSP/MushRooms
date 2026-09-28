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
