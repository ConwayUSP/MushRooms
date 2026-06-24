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
	local atkFrames = { 22, 22 }
	local enemy = Enemy.new(NUCLEAR_CAT.name, 30, spawnPos, physics, movementFunc, atks, hbs, room, atkFrames)
	local idleAnimSettings = newAnimSetting(15, { width = 32, height = 32 }, 0.15, true, 1)
	local walkingAnimSettings = newAnimSetting(4, { width = 32, height = 32 }, 0.15, true, 1)
	local attackAnimSettings = newAnimSetting(28, { width = 32, height = 32 }, 0.1, false)
	local dyingAnimSettings = newAnimSetting(4, { width = 32, height = 32 }, 0.1, false)
	enemy:addAnimations(idleAnimSettings, walkingAnimSettings, attackAnimSettings, dyingAnimSettings)
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
		[attack.name] = randomMovement(atkDur, startDur)
	}
	local atks = { attack }
	local hb = hitbox(Circle.new(25))
	local hbs = hitboxes({ hb })
	local physics = physicsSettings(0.8, 50, 5)
	local atkFrames = { 4 }
	local enemy =
		Enemy.new(SPIDER_DUCK.name, 20, spawnPos, physics, movementFunc, atks, hbs, room, atkFrames, movements)
	local idleAnimSettings = newAnimSetting(2, { width = 32, height = 32 }, 0.4, true, 1)
	local walkingAnimSettings = newAnimSetting(4, { width = 32, height = 32 }, 0.15, true, 1)
	local attackAnimSettings = newAnimSetting(22, { width = 32, height = 50 }, frameDur, false, 1, 4, vec(0, -9))
	local dyingAnimSettings = newAnimSetting(4, { width = 32, height = 32 }, 0.1, false)
	enemy:addAnimations(idleAnimSettings, walkingAnimSettings, attackAnimSettings, dyingAnimSettings)
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
	local attack = newRotatoryAttack(false, atkDur, atkCooldown)
	local movements = {
		[attack.name] = randomMovement(atkDur, startDur)
	}
	local atks = { attack }
	local hb = hitbox(Circle.new(50))
	local hbs = hitboxes({ hb })
	local physics = physicsSettings(0.8, 50, 5)
	local atkFrames = { 4 }
	local enemy = Enemy.new(SPIDER_DUCK.name, 200, spawnPos, physics, movementFunc, atks, hbs, room, atkFrames, movements)
	local idleAnimSettings = newAnimSetting(2, { width = 32, height = 32 }, 0.4, true, 1)
	local walkingAnimSettings = newAnimSetting(4, { width = 32, height = 32 }, 0.15, true, 1)
	local attackAnimSettings = newAnimSetting(22, { width = 32, height = 50 }, frameDur, false, 1, 4, vec(0, -9))
	local dyingAnimSettings = newAnimSetting(4, { width = 32, height = 32 }, 0.1, false)
	enemy:addAnimations(idleAnimSettings, walkingAnimSettings, attackAnimSettings, dyingAnimSettings)
	enemy.scale = 5
	enemy.shadowWidth = 50
	enemy.isBoss = true
	enemy.moveTargeting:addTarget(Target.new(TG_SEEK, TC_EVERY_FRAME), seekClosestPlayer)
	enemy.atkTargeting:addTarget(Target.new(TG_SEEK, TC_EVERY_FRAME), seekClosestPlayer)
	return enemy
end