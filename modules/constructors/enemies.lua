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
		[attackSlow.name] = 22
	}
	local attackAnimSettings = {
		[attack.name] = newAnimSetting(28, { width = 32, height = 32 }, 0.1, false),
		[attackSlow.name] = newAnimSetting(28, { width = 32, height = 32 }, 0.1, false)
	}
	local enemy = Enemy.new(NUCLEAR_CAT.name, 30, spawnPos, physics, movementFunc, atks, hbs, room, atkFrames)
	local idleAnimSettings = newAnimSetting(15, { width = 32, height = 32 }, 0.15, true, 1)
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
-- cria um inimigo do tipo Pato Aranha
function newSpiderDuck(spawnPos, room)
	local movementFunc = dashToTargetMovement(1.2, 1.5, math.rad(10), Easing.outQuad)
	local atkCooldown = randCooldown(3.0, 4.0)
	local frameDur = 0.1
	local framesAtks = 12
	local atkDur = framesAtks * frameDur
	local framesStart = 5
	local startDur = framesStart * frameDur
	local attack = newRotatoryAttack(false, atkDur, atkCooldown)
	local movements = {
		[attack.name] = function()
			local moveBuilder = function() return spiralMovement(math.random(30, 50), math.random(15, 25)) end
			return randomMovement(atkDur, startDur, moveBuilder) 
		end
	}
	local atkFrames = { 
		[attack.name] = 4
	}
	local attackAnimSettings = {
		[attack.name] = newAnimSetting(22, { width = 32, height = 50 }, frameDur, false, 1, 4, vec(0, -9))
	}
	local atks = { attack }
	local hb = hitbox(Circle.new(25))
	local hbs = hitboxes({ hb })
	local physics = physicsSettings(0.8, 50, 5)
	local enemy = Enemy.new(SPIDER_DUCK.name, 20, spawnPos, physics, movementFunc, atks, hbs, room, atkFrames, movements)
	local idleAnimSettings = newAnimSetting(2, { width = 32, height = 32 }, 0.4, true, 1)
	local walkingAnimSettings = newAnimSetting(4, { width = 32, height = 32 }, 0.15, true, 1)
	local dyingAnimSettings = newAnimSetting(4, { width = 32, height = 32 }, 0.1, false)
	enemy:addAnimations(idleAnimSettings, walkingAnimSettings, dyingAnimSettings, attackAnimSettings)
	enemy.shadowWidth = 30
	enemy.moveTargeting:addTarget(Target.new(TG_SEEK, TC_EVERY_FRAME), seekClosestPlayer)
	enemy.atkTargeting:addTarget(Target.new(TG_SEEK, TC_EVERY_FRAME), seekClosestPlayer)
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
	local movementFunc = dashToTargetMovement(1.2, 1.5, math.rad(10), Easing.outQuad)
	local atkCooldown = randCooldown(3.0, 4.0)
	local frameDur = 0.1
	local framesAtks = 12
	local atkDur = framesAtks * frameDur
	local framesStart = 5
	local startDur = framesStart * frameDur
	local attackRotate = newRotatoryAttack(false, atkDur, atkCooldown, hitbox(Circle.new(100), vec(0, -60)))
	local attackSpawn = Attack.new(SPAWN_ATTACK, newAtkSetting({
		subtype = SPAWN_ATTACK,
		ally = false,
		cooldown = constCooldown(12)
	}))
	attackSpawn:addAttackFunc(spawnCircularEntities(1, 3, nil, SPIDER_DUCK, vec(0, 100)))
	local movements = {
		[attackRotate.name] = function()
			local moveBuilder = function() return spiralMovement(math.random(30, 50), math.random(15, 25)) end
			return randomMovement(atkDur, startDur, moveBuilder) 
		end,
	}
	local atkFrames = { 
		[attackRotate.name] = 4,
		[attackSpawn.name] = 2
	}
	local attackAnimSettings = {
		[attackRotate.name] = newAnimSetting(22, { width = 32, height = 50 }, frameDur, false, nil, nil, vec(0, -9)),
		[attackSpawn.name] = newAnimSetting(2, { width = 32, height = 32 }, 0.5, false)
	}
	local atks = { attackSpawn, attackRotate }
	local hb = hitbox(Circle.new(50))
	local hbs = hitboxes({ hb })
	local physics = physicsSettings(0.8, 50, 5)
	local enemy = Enemy.new(SPIDER_DUCK.name, 200, spawnPos, physics, movementFunc, atks, hbs, room, atkFrames, movements)
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