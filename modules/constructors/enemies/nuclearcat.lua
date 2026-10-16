----------------------------------------------
--- Gato Nuclear
----------------------------------------------

---@param spawnPos Vec
---@param room Room
---@return Enemy
-- cria um inimigo do tipo Gato Nuclear
function newNuclearCat(spawnPos, room)
	local movementFunc = avoidTargetMovement(450, 0.75, 1.25, math.rad(30), Easing.inOutQuad)
	local atksCooldown = randMultiCooldown({ 1.0, 2.0, 3.0 })
	local attack = newNuclearShotAttack(false, 3.0, atksCooldown, 800, nil)
	local atks = { attack }
	local hb = hitbox(Rectangle.new(40, 70))
	local hbs = hitboxes({ hb })
	local physics = physicsSettings(1, 65, 4)
	local atkFrames = {
		[attack.name] = 22,
	}
	local attackAnimSettings = {
		[attack.name] = newAnimSetting(28, { width = 32, height = 32 }, 0.1, false),
	}
	local enemy = Enemy.new(NUCLEAR_CAT.name, 60, spawnPos, physics, movementFunc, atks, hbs, room, atkFrames)
	local idleAnimSettings = newAnimSetting(15, { width = 32, height = 32 }, 0.15, true, 1)
	local walkingAnimSettings = newAnimSetting(4, { width = 32, height = 32 }, 0.15, true, 1)
	local dyingAnimSettings = newAnimSetting(33, { width = 32, height = 32 }, 0.1, false, 1)
	enemy:addAnimations(idleAnimSettings, walkingAnimSettings, dyingAnimSettings, attackAnimSettings)
	enemy.shadowWidth = 30
	enemy.moveTargeting:addTarget(Target.new(TG_SEEK, TC_EVERY_FRAME), seekClosestPlayer)
	enemy.atkTargeting:addTarget(Target.new(TG_SEEK, TC_EVERY_FRAME), seekClosestPlayer)
	return enemy
end
