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

	return attack
end

function newNuclearShotAttack(ally, duration, cooldown, speed, trajectoryFunc)
	local hb = hitbox(Circle.new(25))
	local hbs = hitboxes({ hb })
	local settings = newAtkSetting(RANGED_ATTACK, ally, 30, duration, hbs, cooldown, 1, speed, 0.1, -speed / 2, 1, 2)
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

	return attack
end
