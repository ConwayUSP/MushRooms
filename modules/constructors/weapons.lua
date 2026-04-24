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
	local atkSettings = newAtkSetting(MELEE_ATTACK, true, 15, 0.5, hbs, cooldown)
	local atkAnimSettings = newAnimSetting(12, { width = 64, height = 64 }, 0.03, false, 1)
	local attack = Attack.new("Katana Slice", atkSettings, atkAnimSettings, updateFunc, onHitFunc)

	-- Inicialicação da arma em si
	local katana = Weapon.new(KATANA.name, math.huge, attack)
	local idleAnimSettings = newAnimSetting(4, { width = 64, height = 64 }, 0.3, true, 1)
	local weaponAtkAnimSettings = newAnimSetting(12, { width = 64, height = 64 }, 0.03, false, 1)
	katana:addAnimations(idleAnimSettings, weaponAtkAnimSettings)
	return katana
end

---@return Weapon
-- cria uma arma do tipo Estilingue
function newSlingShot()
	local cooldown = constCooldown(0.4)
	local attack = newPebbleShotAttack(true, 1.5, cooldown, 2000)
	local slingshot = Weapon.new(SLING_SHOT.name, math.huge, attack)
	local idleAnimSettings = newAnimSetting(2, { width = 64, height = 64 }, 0.5, true, 1)
	local weaponAtkAnimSettings = newAnimSetting(10, { width = 64, height = 64 }, 0.05, false, 1)
	slingshot:addAnimations(idleAnimSettings, weaponAtkAnimSettings)
	return slingshot
end
