----------------------------------------
-- Importações de Módulos
----------------------------------------
require("modules.systems.movement")
require("modules.systems.attack")
require("modules.utils.types")

----------------------------------------
-- Construtores de Ataques
----------------------------------------
-- de forma semelhante ao que fizemos com o sistema de
-- movimentos, iremos utilizar o padrão de estratégia
-- para criar tipos de ataque reutilizáveis e ao mesmo
-- tempo altamente customizáveis, sendo que o trade-off
-- entre reutilizabilidade e customização pode ser
-- ajustado a gosto e com mínimos efeitos colaterais.
-- Cada construtor neste arquivo recebe como argumento
-- as "configurações" que devem ser customizáveis para
-- aquele tipo de ataque, o restante dos dados necessários
-- para a criação de um ataque serão fixos naquele
-- construtor, e portanto representam a "essência" daquele
-- tipo de ataque: a parte imutável

---@param ally boolean
---@param cooldown function
---@param speed number
---@param trajectoryFunc? MovementFunc
---@return Attack
-- um tiro de pedrinha
function newPebbleShotAttack(ally, duration, cooldown, speed, trajectoryFunc)
	local hb = hitbox(Circle.new(15))
	local hbs = hitboxes({ hb })
	local settings = newAtkSetting(RANGED_ATTACK, ally, 15, duration, hbs, cooldown, 1, speed, 0.1, -speed / 2, 4, 2, 1)
	local animIntact = newAnimSetting(5, { width = 16, height = 16 }, 0.1, true, 1)
	local animBreaking = newAnimSetting(5, { width = 16, height = 16 }, 0.05, false, 1)
	local updateFunc = AttackEvent.baseUpdate
	local onHitFunc = function(e, t)
		print("Pebble Shot acertou um alvo")
	end

	local attack = Attack.new("Pebble Shot", settings, updateFunc, onHitFunc, trajectoryFunc)
	attack:addAnimations(animIntact, animBreaking)
	attack.hasShadow = true
	attack.shadowWidth = 10

	return attack
end

---@param ally boolean
---@param cooldown function
---@param speed number
---@param trajectoryFunc? MovementFunc
---@return Attack
-- um tiro nuclear
function newNuclearShotAttack(ally, duration, cooldown, speed, trajectoryFunc)
	local hb = hitbox(Circle.new(25))
	local hbs = hitboxes({ hb })
	local settings = newAtkSetting(RANGED_ATTACK, ally, 30, duration, hbs, cooldown, 1, speed, 0.1, -speed / 2, 1, 2, 1)
	local animIntact = newAnimSetting(3, { width = 32, height = 32 }, 0.1, true, 1)
	local animBreaking = newAnimSetting(5, { width = 32, height = 32 }, 0.05, false, 1)
	local updateFunc = function(e, dt)
		AttackEvent.baseUpdate(e, dt)
		e.animDir = -math.rad(90)
	end
	local onHitFunc = function(e, t)
		print("Nuclear Shot acertou um alvo")
	end

	local attack = Attack.new("Nuclear Shot", settings, updateFunc, onHitFunc, trajectoryFunc)
	attack:addAnimations(animIntact, animBreaking)
	attack.hasShadow = true
	attack.shadowWidth = 10

	return attack
end

---@param ally boolean
---@param duration number
---@param cooldown function
---@return Attack
-- um ataque rotatório corpo-a-corpo (sem animação)
function newRotatoryAttack(ally, duration, cooldown)
	local hb = hitbox(Circle.new(40), vec(0, -20))
	local hbs = hitboxes({ hb })
	local settings = newAtkSetting(MELEE_ATTACK, ally, 20, duration, hbs, cooldown, 1, 0, 1, 0, 1, 2, 1)
	local updateFunc = function(e, dt)
		e:baseUpdate(dt)
		e.pos = e.attacker.pos
	end
	local onHitFunc = function(e, t)
		print("Rotatory Attack acertou um alvo")
	end

	local attack = Attack.new("Rotatory Attack", settings, updateFunc, onHitFunc)
	attack.hasShadow = false

	return attack
end


---@param min integer
---@param max integer
---@param ang? rad
---@return function
-- função que gera múltiplos `AttackEvents` em um padrão circular, com `min` e `max` controlando a quantidade de eventos gerados
function defaultCircularAttackFunc(min, max, ang)
	return function(atk, attacker, origin, direction)
		local atks = {}
		for i = min, max do
			local dirIncrement = ang and (ang/(max - min) * i) or math.rad(360/(max - min)) * i
			local newDirection = direction + dirIncrement

			local atkEvent = AttackEvent.new(atk, attacker, origin, newDirection)
			table.insert(atks, atkEvent)
		end

		return atks
	end
end

---@param ally boolean
---@param cooldown function
---@param speed number
---@param trajectoryFunc MovementFunc
---@return Attack
-- um tiro de pedrinha em círculo
function newPebbleCircularAttack(ally, duration, cooldown, speed, trajectoryFunc)
	local pebble = newPebbleShotAttack(ally, duration, cooldown, speed, trajectoryFunc)
	local attackFunc = defaultCircularAttackFunc(1, 8)
	pebble:addAttackFunc(attackFunc)

	return pebble
end

---@param ally boolean
---@param cooldown function
---@param speed number
---@param trajectoryFunc MovementFunc
---@return Attack
-- um tiro de pedrinha em cone
function newPebbleConeAttack(ally, duration, cooldown, speed, trajectoryFunc)
	local pebble = newPebbleShotAttack(ally, duration, cooldown, speed, trajectoryFunc)
	local attackFunc = defaultCircularAttackFunc(-1, 1, math.rad(30))
	pebble:addAttackFunc(attackFunc)

	return pebble
end

---@param ally boolean
---@param duration number
---@param cooldown function
---@param speed number
---@param trajectoryFunc MovementFunc
---@return Attack
-- tiro de pedrinha que alterna entre circular e cone
function newPebbleCircularConeAttack(ally, duration, cooldown, speed, trajectoryFunc)
	local pebble = newPebbleShotAttack(ally, duration, cooldown, speed, trajectoryFunc)
	local useCircular = true

	local attackFunc = function(atk, attacker, origin, direction)
		local nextAttackFunc
		if useCircular then
			nextAttackFunc = defaultCircularAttackFunc(1, 30)
		else
			nextAttackFunc = defaultCircularAttackFunc(-1, 1, math.rad(30))
		end

		useCircular = not useCircular
		return nextAttackFunc(atk, attacker, origin, direction)
	end

	pebble:addAttackFunc(attackFunc)

	return pebble
end
