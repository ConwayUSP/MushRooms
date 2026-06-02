----------------------------------------
-- Importações de Módulos
----------------------------------------
require("modules.constructors.attacks")
require("modules.constructors.cooldowns")
require("modules.constructors.movements")
require("modules.utils.easing")

---@param spawnPos Vec
---@param room Room
---@return Enemy
-- cria um inimigo do tipo Gato Nuclear
function newNuclearCat(spawnPos, room)
	local movementFunc = avoidTargetMovement(350, 0.75, 1.25, math.rad(30), Easing.inOutQuad)
	-- local attack = newPebbleShotAttack(false, 2.5, 5.0, 500, sineMovement(math.rad(60)))
	local atksCooldown = randMultiCooldown({ 1.0, 2.0, 3.0 })
	local attack = newNuclearShotAttack(false, 5.0, atksCooldown, 400, zigZagMovement(math.rad(45), 0.5))
	local attackSlow = newNuclearShotAttack(false, 10.0, atksCooldown, 300, straightMovement())
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
	return enemy
end

---@param spawnPos Vec
---@param room Room
---@return Enemy
-- cria um inimigo do tipo Pato Aranha
function newSpiderDuck(spawnPos, room)
	local movementFunc = dashToTargetMovement(1.2, 1.5, math.rad(10), Easing.outQuad)
	local atkCooldown = randCooldown(3.0, 4.0)
	local dur = 0.8
	local attack = newRotatoryAttack(false, dur, atkCooldown)
	local movements = {
		[attack.name] = randomMovement(dur, 0.2, 15, Easing.outQuad)
	}
	local atks = { attack }
	local hb = hitbox(Circle.new(25))
	local hbs = hitboxes({ hb })
	local physics = physicsSettings(0.8, 50, 5)
	local atkFrames = { 4 }
	local enemy = Enemy.new(SPIDER_DUCK.name, 20, spawnPos, physics, movementFunc, atks, hbs, room, atkFrames, movements)
	local idleAnimSettings = newAnimSetting(2, { width = 32, height = 32 }, 0.4, true, 1)
	local walkingAnimSettings = newAnimSetting(4, { width = 32, height = 32 }, 0.15, true, 1)
	local attackAnimSettings = newAnimSetting(7, { width = 32, height = 32 }, 0.2, false)
	local dyingAnimSettings = newAnimSetting(4, { width = 32, height = 32 }, 0.1, false)
	enemy:addAnimations(idleAnimSettings, walkingAnimSettings, attackAnimSettings, dyingAnimSettings)
	enemy.shadowWidth = 30
	return enemy
end
