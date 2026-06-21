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
---@param trajectoryFuncBuilder? function
---@return Attack
-- um tiro de pedrinha
function newPebbleShotAttack(ally, dur, cooldown, speed, trajectoryFuncBuilder)
	local hb = hitbox(Circle.new(15))
	local hbs = hitboxes({ hb })
	local settings = newAtkSetting({
		subtype = RANGED_ATTACK,
		ally = ally,
		dmg = 15,
		dur = dur,
		hb = hbs,
		cooldown = cooldown,
		initialSpeed = speed,
		accFactor = -speed / 2,
		restitution = 1,
		friction = 0,
		bounces = 3,
		pierces = 2,
		-- tick = 0.5
	})

	local animIntact = newAnimSetting(5, { width = 16, height = 16 }, 0.1, true, 1)
	local animBreaking = newAnimSetting(5, { width = 16, height = 16 }, 0.05, false, 1)
	local updateFunc = AttackEvent.baseUpdate
	local rotationFunc = function (e)
		return math.atan2(e.vel.y, e.vel.x)
	end
	local onHitFunc = function(e, t)
		print("Pebble Shot acertou um alvo")
	end

	local attack = Attack.new(PEBBLE_SHOT.name, settings, updateFunc, onHitFunc, nil, trajectoryFuncBuilder, rotationFunc)
	attack:addAnimations(animIntact, animBreaking)
	attack.hasShadow = true
	attack.shadowWidth = 10

	return attack
end

---@param ally boolean
---@param cooldown function
---@param speed number
---@param trajectoryFuncBuilder? function
---@return Attack
-- um tiro nuclear
function newNuclearShotAttack(ally, duration, cooldown, speed, trajectoryFuncBuilder)
	local hb = hitbox(Circle.new(25))
	local hbs = hitboxes({ hb })
	local settings = newAtkSetting({
		subtype = RANGED_ATTACK,
		ally = ally,
		dmg = 30,
		dur = duration,
		hb = hbs,
		cooldown = cooldown,
		initialMass = 1,
		initialSpeed = speed,
		friction = 0,
		accFactor = -speed / 2,
		restitution = 1,
		bounces = 2,
		pierces = 1
	})
	local animIntact = newAnimSetting(3, { width = 32, height = 32 }, 0.1, true, 1)
	local animBreaking = newAnimSetting(5, { width = 32, height = 32 }, 0.05, false, 1)
	local updateFunc = AttackEvent.baseUpdate
	local rotationFunc = function (e)
		return -math.rad(90) + math.atan2(e.vel.y, e.vel.x)
	end
	local onHitFunc = function(e, t)
		print("Nuclear Shot acertou um alvo")
	end

	local attack = Attack.new(NUCLEAR_SHOT.name, settings, updateFunc, onHitFunc, nil, trajectoryFuncBuilder, rotationFunc)
	attack:addAnimations(animIntact, animBreaking)
	attack.hasShadow = true
	attack.shadowWidth = 10

	return attack
end

---@param ally boolean
---@param speed number
---@param timing number
---@param force number
---@return Attack
-- um tiro nuclear
function newBoomerangueAttack(ally, speed, timing, force)
	local cooldown = constCooldown(0.4)
	local trajectoryFuncBuilder = function() return boomerangMovement(speed * 1.6, timing, force) end
	local hb = hitbox(Circle.new(25))
	local hbs = hitboxes({ hb })
	local settings = newAtkSetting({
		subtype = RANGED_ATTACK,
		ally = ally,
		dmg = 12,
		dur = math.huge,
		hb = hbs,
		cooldown = cooldown,
		initialMass = 1,
		initialSpeed = speed,
		friction = 0,
		accFactor = 0,
		restitution = 1,
		bounces = math.huge,
		pierces = math.huge,
		tick = 0.2
	})
	local anim = newAnimSetting(12, { width = 32, height = 32 }, 0.1, true, 1)
	local updateFunc = AttackEvent.baseUpdate
	local rotationFunc = function (e)
		return e.age * 12
	end
	local onHitFunc = function(e, t)
		print(BOOMERANGUE_SHOT.name .. " acertou um alvo")
	end
	local onShotFunc = function (e)
		e.weapon.visible = false
	end

	local attack = Attack.new(BOOMERANGUE_SHOT.name, settings, updateFunc, onHitFunc, onShotFunc, trajectoryFuncBuilder, rotationFunc)
	attack:addAnimations(anim)
	attack.hasShadow = true
	attack.shadowWidth = 10

	return attack
end

function newSkullAttack(ally, dur, cooldown, speed, trajectoryFuncBuilder)
	local hb = hitbox(Circle.new(10))
	local hbs = hitboxes({ hb })
	local settings = newAtkSetting({
		subtype = RANGED_ATTACK,
		ally = ally,
		dmg = 5,
		dur = dur,
		hb = hbs,
		cooldown = cooldown,
		initialSpeed = speed,
		restitution = 0,
		friction = 0,
		bounces = 0,
		pierces = 1,
		-- tick = 0.5
	})

	local animIntact = newAnimSetting(1, { width = 32, height = 32 }, 0.1, true, 1)
	local animBreaking = newAnimSetting(1, { width = 32, height = 32 }, 0.05, false, 1)
	local updateFunc = AttackEvent.baseUpdate
	local rotationFunc = function (e)
		local angle = math.atan2(e.vel.y, e.vel.x)
		local flip = flipSecondAndThirdQuadrants(angle)
		return flip
	end
	local onHitFunc = function(e, t)
		print(SKULL_SHOT.name .. " acertou um alvo")
	end

	local attack = Attack.new(SKULL_SHOT.name, settings, updateFunc, onHitFunc, nil, trajectoryFuncBuilder, rotationFunc)
	attack:addAnimations(animIntact, animBreaking)
	attack.hasShadow = true
	attack.shadowWidth = 10

	return attack
end

function newBlackholeAttack(ally, dur, cooldown, speed, trajectoryFuncBuilder)
	local hb = hitbox(Circle.new(50))
	local hbs = hitboxes({ hb })
	local settings = newAtkSetting({
		subtype = RANGED_ATTACK,
		ally = ally,
		dmg = 8,
		dur = dur,
		hb = hbs,
		cooldown = cooldown,
		initialSpeed = speed,
		initialMass = 0.1,
		restitution = 0,
		friction = 0.8,
		bounces = 0,
		pierces = math.huge,
		tick = 0.5
	})

	local animIntact = newAnimSetting(16, { width = 32, height = 32 }, 0.1, true, 1, 0)
	local animBreaking = newAnimSetting(16, { width = 32, height = 32 }, 0.1, false, 1, 0)
	local updateFunc = function (e, dt)
		e:baseUpdate(dt)
		local room = e.attacker.room
		for _, enemy in pairs(room.enemies) do
			-- valores puramente experimentais, ainda podem (e devem) ser ajustados :D
			local radius = 500
			local mass = 20000000

			local dir = subVec(e.pos, enemy.pos)
			local d = lenVec(dir)

			if d < radius and d > 30 then
				-- usamos uma "pseudomassa" pois, se a massa do buraco negro fosse muito grande, o inimigo seria arremessado muito longe
				-- assim, a massa real é pequena e aqui "simulamos" a real massa que queremos para o efeito
				local force = (enemy.mass * mass) / (d * d)
				local forceVec = scaleVec(normalize(dir), force)
				applyForce(enemy, forceVec)
			end
			
		end
	end
	local rotationFunc = function (e)
		return 0
	end
	local onHitFunc = function(e, t)
		print(BLACKHOLE_SHOT.name .. " acertou um alvo")
	end

	local attack = Attack.new(BLACKHOLE_SHOT.name, settings, updateFunc, onHitFunc, nil, trajectoryFuncBuilder, rotationFunc)
	attack:addAnimations(animIntact, animBreaking)
	attack.hasShadow = true
	attack.shadowWidth = 20

	return attack
end

function newSeedAttack(ally, dur, cooldown, speed, trajectoryFuncBuilder)
	local hb = hitbox(Circle.new(8))
	local hbs = hitboxes({ hb })
	local settings = newAtkSetting({
		subtype = RANGED_ATTACK,
		ally = ally,
		dmg = 2,
		dur = dur,
		hb = hbs,
		cooldown = cooldown,
		friction = 0,
		initialSpeed = speed,
		initialMass = 0.1,
		restitution = 0,
		bounces = 0,
		pierces = 1,
	})

	local animIntact = newAnimSetting(1, { width = 32, height = 32 }, 0.1, true, 1, 0)
	local animBreaking = newAnimSetting(1, { width = 32, height = 32 }, 0.1, false, 1, 0)
	local updateFunc = AttackEvent.baseUpdate
	local onHitFunc = function(e, t)
		print(SEED_SHOT.name .. " acertou um alvo")
	end

	local attack = Attack.new(SEED_SHOT.name, settings, updateFunc, onHitFunc, nil, trajectoryFuncBuilder, nil)
	attack:addAnimations(animIntact, animBreaking)
	attack.hasShadow = true
	attack.shadowWidth = 8

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
	local settings = newAtkSetting({
		subtype = MELEE_ATTACK,
		ally = ally,
		dmg = 20,
		dur = duration,
		hb = hbs,
		cooldown = cooldown,
		tick = 0.5
	})
	local updateFunc = function(e, dt)
		e:baseUpdate(dt)
		e.pos = e.attacker.pos
	end
	local onHitFunc = function(e, t)
		print("Rotatory Attack acertou um alvo")
	end

	local attack = Attack.new(ROTATORY.name, settings, updateFunc, onHitFunc, nil)
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
---@param trajectoryFuncBuilder? function
---@return Attack
-- um tiro de pedrinha em círculo
function newPebbleCircularAttack(ally, duration, cooldown, speed, trajectoryFuncBuilder)
	local pebble = newPebbleShotAttack(ally, duration, cooldown, speed, trajectoryFuncBuilder)
	local attackFunc = defaultCircularAttackFunc(1, 8)
	pebble:addAttackFunc(attackFunc)

	return pebble
end

---@param ally boolean
---@param cooldown function
---@param speed number
---@param trajectoryFuncBuilder? function
---@return Attack
-- um tiro de pedrinha em cone
function newPebbleConeAttack(ally, duration, cooldown, speed, trajectoryFuncBuilder)
	local pebble = newPebbleShotAttack(ally, duration, cooldown, speed, trajectoryFuncBuilder)
	local attackFunc = defaultCircularAttackFunc(-1, 1, math.rad(30))
	pebble:addAttackFunc(attackFunc)

	return pebble
end

---@param ally boolean
---@param duration number
---@param cooldown function
---@param speed number
---@param trajectoryFuncBuilder MovementFunc
---@return Attack
-- tiro de pedrinha que alterna entre circular e cone
function newPebbleCircularConeAttack(ally, duration, cooldown, speed, trajectoryFuncBuilder)
	local pebble = newPebbleShotAttack(ally, duration, cooldown, speed, trajectoryFuncBuilder)
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
