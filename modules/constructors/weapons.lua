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
		-- seguindo o jogador
		atkEvent.pos = atkEvent.attacker.pos
	end
	local onHitFunc = function(atkEvent, target)
		print("Katana acertou um " .. target.type .. " por " .. atkEvent.dmg .. " de dano!")
		target.hp = target.hp - atkEvent.dmg
	end
	local hb = hitbox(Circle.new(100))
	local hbs = hitboxes({ hb })
	local cooldown = multiCooldown({ 0.1, 0.1, 0.5 })
	local atkSettings = newAtkSetting({
		subtype = MELEE_ATTACK,
		ally = true,
		dmg = 15,
		dur = 0.5,
		hb = hbs,
		cooldown = cooldown
	})
	local atkAnimSettings = newAnimSetting(12, { width = 64, height = 64 }, 0.03, false, 1)
	local attack = Attack.new("Katana Slice", atkSettings, updateFunc, onHitFunc)
	attack:addAnimations(atkAnimSettings, atkAnimSettings)

	-- Inicialicação da arma em si
	local katana = Weapon.new(KATANA.name, math.huge, attack, vec(2, 30))
	local idleAnimSettings = newAnimSetting(4, { width = 64, height = 64 }, 0.3, true, 1)
	local weaponAtkAnimSettings = newAnimSetting(12, { width = 64, height = 64 }, 0.03, false, 1)
	katana:addAnimations(idleAnimSettings, weaponAtkAnimSettings)
	return katana
end

---@return Weapon
-- cria uma arma do tipo Estilingue
function newSlingShot()
	local cooldown = constCooldown(0.4)
	local attack = newPebbleShotAttack(true, 5, cooldown, 1200, nil)
	attack:setOnHit(onHitLinkTwoEnemies)
	local slingshot = Weapon.new(SLING_SHOT.name, math.huge, attack, vec(-2, 25), vec(40, -30))
	local idleAnimSettings = newAnimSetting(2, { width = 64, height = 64 }, 0.5, true, 1)
	local weaponAtkAnimSettings = newAnimSetting(10, { width = 64, height = 64 }, 0.05, false, 1)
	slingshot:addAnimations(idleAnimSettings, weaponAtkAnimSettings)
	return slingshot
end

---@return Weapon
-- cria uma arma do tipo Boomerangue
function newBoomerangue()
	local attack = newBoomerangueAttack(true, 1600)
	local boomerangue = Weapon.new(BOOMERANGUE.name, 1, attack, vec(20, 30))
	local idleAnimSettings = newAnimSetting(1, { width = 32, height = 32 }, 0.5, true, 1)
	boomerangue:addAnimations(idleAnimSettings)
	return boomerangue
end

---@return Weapon
-- cria uma arma do tipo Skull Shooter
function newSkullShooter()
	local cooldown = constCooldown(0.2)
	local trajectoryFuncBuilder = function() return followTargetMovement(5) end
	local attack = newSkullAttack(true, 10, cooldown, 400, trajectoryFuncBuilder)
	attack:setOnHit(onHitApplyFear)
	local skullshooter = Weapon.new(SKULL_SHOOTER.name, math.huge, attack, vec(25, 20),  vec(30, -5))
	local idleAnimSettings = newAnimSetting(1, { width = 32, height = 32 }, 0.5, true, 1)
	local weaponAtkAnimSettings = newAnimSetting(1, { width = 32, height = 32 }, 0.05, false, 1)
	skullshooter:addAnimations(idleAnimSettings, weaponAtkAnimSettings)
	return skullshooter
end

---@return Weapon
-- cria uma arma do tipo Blackhole
function newBlackholer()
	local cooldown = constCooldown(1)
	local attack = newBlackholeAttack(true, 10, cooldown, 1200, nil)
	local blackhole = Weapon.new(BLACKHOLER.name, math.huge, attack, vec(25, 20), vec(30, -5))
	local idleAnimSettings = newAnimSetting(1, { width = 32, height = 32 }, 0.5, true, 1)
	local weaponAtkAnimSettings = newAnimSetting(1, { width = 32, height = 32 }, 0.05, false, 1)
	blackhole:addAnimations(idleAnimSettings, weaponAtkAnimSettings)
	return blackhole
end

---@return Weapon
-- cria uma arma do tipo Flowergun
function newFlowergun()
	local cooldown = constCooldown(0.05)
	local attack = newSeedAttack(true, 0.3, cooldown, 1800, nil)
	attack:addAttackFunc(defaultCircularAttackFunc(-1, 1, math.rad(8)))
	local flowergun = Weapon.new(FLOWERGUN.name, math.huge, attack, vec(25, 20), vec(30, -5))
	local idleAnimSettings = newAnimSetting(1, { width = 32, height = 32 }, 0.5, true, 1)
	local weaponAtkAnimSettings = newAnimSetting(1, { width = 32, height = 32 }, 0.05, false, 1)
	flowergun:addAnimations(idleAnimSettings, weaponAtkAnimSettings)
	return flowergun
end

-----------------------------
--- onHitFunc
------------------------------

---@param atkEvent AtkEvent
---@param enemy Enemy
-- função de onHit para o ataque do estilingue, que cria um link entre o
function onHitLinkTwoEnemies(atkEvent, enemy)
	local target = enemy:nearestEnemy()
	local room = enemy.room

	if target and room then
		room.linkManager:addLink(enemy, target, 200, 5)
	end

end

function onHitApplyFear(atkEvent, enemy)
	enemy:applyFear(atkEvent.attacker, 3)
end