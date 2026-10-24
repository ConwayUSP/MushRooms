----------------------------------------
-- Importações de Módulos
----------------------------------------
require("modules.constructors.cooldowns")

---@return Weapon
-- cria uma arma do tipo Katana
function newKatana()
	-- configurações do ataque
	local updateFunc = function(atkEvent, dt)
		atkEvent:baseUpdate(dt)
		local weapon = atkEvent.atk.weapon
		local origin = weapon:atkOriginPoint()

		atkEvent.pos = origin
	end
	local onHitFunc = function(e, target) end
	local rotationFunc = function(e)
		return e.direction
	end
	local hb = hitbox(Circle.new(100))
	local hbs = hitboxes({ hb })
	local cooldown = multiCooldown({ 0.25, 0.25, 0.75 })
	local atkSettings = newAtkSetting({
		subtype = MELEE_ATTACK,
		ally = true,
		dmg = 12,
		dur = 0.4,
		hb = hbs,
		cooldown = cooldown,
	})
	local atkAnimSettings = newAnimSetting(12, { width = 64, height = 64 }, 0.03, false, 1)
	local particles = atkParticles(PARTICLE_KATANA)
	local attack = Attack.new("Katana Slice", atkSettings, updateFunc, onHitFunc, nil, nil, rotationFunc, particles)
	attack:addAnimations(atkAnimSettings, atkAnimSettings)

	-- Inicialicação da arma em si
	local katana = Weapon.new(KATANA.name, attack, vec(2, 30), vec(34, -30))
	local idleAnimSettings = newAnimSetting(4, { width = 64, height = 64 }, 0.3, true, 1)
	local weaponAtkAnimSettings = newAnimSetting(12, { width = 64, height = 64 }, 0.03, false, 1)
	katana:addAnimations(idleAnimSettings, weaponAtkAnimSettings)
	return katana
end

---@return Weapon
-- cria uma arma do tipo Estilingue
function newSlingShot()
	local cooldown = constCooldown(0.55)
	local attack = newPebbleShotAttack(true, 4, cooldown, 1200, nil)
	attack:setOnHit(onHitLinkTwoEnemies)
	local slingshot = Weapon.new(SLING_SHOT.name, attack, vec(-10, 10), vec(40, -30))
	local idleAnimSettings = newAnimSetting(2, { width = 64, height = 64 }, 0.5, true, 1)
	local weaponAtkAnimSettings = newAnimSetting(10, { width = 64, height = 64 }, 0.05, false, 1)
	slingshot:addAnimations(idleAnimSettings, weaponAtkAnimSettings)
	return slingshot
end

---@return Weapon
-- cria uma arma do tipo Boomerangue
function newBoomerangue()
	local attack = newBoomerangueAttack(true, 1500, 0.35, 2)
	local boomerangue = Weapon.new(BOOMERANGUE.name, attack, vec(20, 30))
	local idleAnimSettings = newAnimSetting(1, { width = 32, height = 32 }, 0.5, true, 1)
	boomerangue:addAnimations(idleAnimSettings)
	return boomerangue
end

---@return Weapon
-- cria uma arma do tipo Skull Shooter
function newSkullShooter()
	local cooldown = constCooldown(0.8)
	local trajectoryFuncBuilder = function()
		return followTargetMovement(5)
	end
	local attack = newSkullAttack(true, 4, cooldown, 400, trajectoryFuncBuilder)
	attack:setOnHit(onHitApplyFear)
	local skullshooter = Weapon.new(SKULL_SHOOTER.name, attack, vec(25, 20), vec(60, -6))
	local idleAnimSettings = newAnimSetting(4, { width = 40, height = 40 }, 0.5, true, 1, 0)
	local weaponAtkAnimSettings = newAnimSetting(30, { width = 32, height = 32 }, 0.05, false, 1)
	skullshooter:addAnimations(idleAnimSettings, weaponAtkAnimSettings)
	return skullshooter
end

---@return Weapon
-- cria uma arma do tipo Blackhole
function newBlackholer()
	local cooldown = constCooldown(2)
	local attack = newBlackholeAttack(true, 5, cooldown, 1200, nil)
	local blackhole = Weapon.new(BLACKHOLER.name, attack, vec(25, 20), vec(30, -5), 1.08)
	local idleAnimSettings = newAnimSetting(4, { width = 40, height = 40 }, 0.5, true, 1, 0)
	local weaponAtkAnimSettings = newAnimSetting(4, { width = 32, height = 32 }, 0.1, false, 1)
	local weaponChargingAnimSettings = newAnimSetting(51, { width = 32, height = 32 }, 0.03, true, 36)
	blackhole:addAnimations(idleAnimSettings, weaponAtkAnimSettings, weaponChargingAnimSettings)
	return blackhole
end

---@return Weapon
-- cria uma arma do tipo Flowergun
function newFlowergun()
	local cooldown = constCooldown(0.25)
	local initialSpeedCooldown = randCooldown(1000, 1400)
	local trajectoryFuncBuilder = function()
		return deceleratingProjectileMovement(initialSpeedCooldown)
	end
	local attack = newSeedAttack(true, 0.55, cooldown, 3000, trajectoryFuncBuilder)
	attack:addAttackFunc(defaultCircularAttackFunc(-2, 2, math.rad(8)))
	local flowergun = Weapon.new(FLOWERGUN.name, attack, vec(25, 20), vec(30, 0))
	local idleAnimSettings = newAnimSetting(1, { width = 36, height = 36 }, 0.5, true, 1)
	local weaponAtkAnimSettings = newAnimSetting(12, { width = 36, height = 36 }, 0.05, false, 1)
	flowergun:addAnimations(idleAnimSettings, weaponAtkAnimSettings)
	return flowergun
end

-----------------------------
--- onHitFunc
------------------------------

---@param atkEvent AtkEvent
---@param hitEntity Entity
-- função de onHit para o ataque do estilingue, que conecta o inimigo atingido
-- ao inimigo mais próximo
function onHitLinkTwoEnemies(atkEvent, hitEntity)
	if hitEntity.type ~= ENEMY then
		return
	end

	local enemy = hitEntity
	local target = enemy:nearestEnemy()
	local room = enemy.room

	if target and room then
		room.linkManager:addLink(SpringLink.new(enemy, target, 200, 5))
	end
end

---@param atkEvent AtkEvent
---@param hitEntity Entity
function onHitApplyFear(atkEvent, hitEntity)
	local CHANCE = 0.5
	if hitEntity.type == ENEMY and math.random() <= CHANCE then
		hitEntity:applyFear(atkEvent.attacker, 1.5)
	end
end
