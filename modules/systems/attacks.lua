----------------------------------------
-- Importações de Módulos
----------------------------------------
require("modules.utils.utils")

----------------------------------------
-- Classe AtkSetting e Construtor
----------------------------------------

---@class AtkSetting
---@field subtype string
---@field ally boolean
---@field dmg number
---@field dur number
---@field hb Hitboxes
---@field cooldown number
---@field initialMass number
---@field initialSpeed number
---@field friction number
---@field accFactor number
---@field bounces number
---@field pierces number

---@param subtype string
---@param ally boolean
---@param damage number
---@param duration number
---@param hitboxes Hitboxes
---@param mass? number
---@param speed? number
---@param friction? number
---@param acceleration? number
---@param bounces? number
---@param pierces? number
---@return AtkSetting
-- construtor complementar ao anterior, usado para ataques de projétil
function newAtkSetting(
	subtype,
	ally,
	damage,
	duration,
	hitboxes,
	cooldown,
	mass,
	speed,
	friction,
	acceleration,
	bounces,
	pierces
)
	return {
		subtype = subtype,
		ally = ally,
		dmg = damage,
		dur = duration,
		hb = hitboxes,
		cooldown = cooldown,
		initialMass = mass or 1,
		initialSpeed = speed or 0,
		friction = friction or 1,
		accFactor = acceleration or 0,
		bounces = bounces or 0,
		pierces = pierces or math.huge,
	}
end

----------------------------------------
-- Classe Attack
----------------------------------------

---@class Attack: AtkSetting
---@field name string
---@field timer number
---@field canAttack boolean
---@field animSettings table
---@field updateEvent function
---@field onHit function
---@field trajectoryFunc? MovementFunc
---@field events AtkEvent[]
Attack = {}
Attack.__index = Attack
Attack.type = ATTACK

---@param name string
---@param atkSettings AtkSetting
---@param animSettings AnimSettings
---@param updateFunc function
---@param onHit function
---@param trajectoryFunc? MovementFunc
---@return Attack
-- `Attacks` agem como emissores de `AttackEvents`;
-- eles armazenam as configurações, dados iniciais
-- de um ataque e informações de controle (como o cooldown)
function Attack.new(name, atkSettings, animSettings, updateFunc, onHit, trajectoryFunc)
	local attack = setmetatable({}, Attack)
	attack.name = name -- nome do tipo de ataque
	attack.subtype = atkSettings.subtype -- indica se o ataque é melee, ranged ou outro tipo
	attack.ally = atkSettings.ally -- true se for de um player e false se for de um inimigo
	attack.dmg = atkSettings.dmg -- dano base do ataque
	attack.dur = atkSettings.dur -- duração do evento de ataque associado
	attack.initialMass = atkSettings.initialMass
	attack.initialSpeed = atkSettings.initialSpeed -- fator inicial de velocidade do ataque/projétil
	attack.friction = atkSettings.friction
	attack.accFactor = atkSettings.accFactor -- fator inicial de aceleração do ataque/projétil
	attack.hb = atkSettings.hb -- hitboxes do ataque
	attack.bounces = atkSettings.bounces -- quantas vezes o ataque pode ricochetear (caso seja projétil)
	attack.pierces = atkSettings.pierces -- quantas vezes o ataque pode atravessar um alvo
	attack.cooldown = atkSettings.cooldown -- tempo que deve passar entre ataques
	attack.timer = 0 -- timer do cooldown, ao chegar em 0 permite gerar ataques
	attack.canAttack = true -- se pode gerar um AttackEvent ou não
	attack.animSettings = animSettings -- configurações da animação de cada evento
	attack.updateEvent = updateFunc -- função executada para cada AttackEvent, atualizando seu estado atual
	attack.onHit = onHit -- função executada toda vez que um ataque acertar um alvo
	attack.trajectoryFunc = trajectoryFunc -- função que define a trajetória do ataque/projétil
	-- Atributos fixos na instanciação
	attack.events = {}
	return attack
end

---@param attacker any
---@param origin Vec
---@param direction rad
-- inicia um evento de ataque no ponto `origin` com direção `direction`.
-- `attacker` é a entidade (player ou inimigo) iniciando o ataque
function Attack:attack(attacker, origin, direction)
	self.timer = self.cooldown
	self.canAttack = false

	local atkEvent = AttackEvent.new(self, attacker, origin, direction)
	atkEvent:addAnimation(self.animSettings)
	table.insert(self.events, atkEvent)
end

---@param dt number
-- atualiza os eventos de ataque e gerencia a lista `Attack.events`
function Attack:update(dt)
	-- atualiza os eventos ativos deste ataque
	for i = #self.events, 1, -1 do
		local e = self.events[i]
		self.updateEvent(e, dt)

		if e.timer <= 0 or e.piercesLeft <= 0 then
			e.active = false
			collisionManager:unregister(e)
			table.remove(self.events, i)
		else
			e.animation:update(dt)
			applyPhysics(e, dt)
		end
	end
end

---@param dt number
-- atualiza o timer de cooldown
function Attack:updateTimer(dt)
	if not self.canAttack then
		self.timer = self.timer - dt
		if self.timer <= 0 then
			self.canAttack = true
		end
	end
end

----------------------------------------
-- Classe AttackEvent
----------------------------------------

---@class AtkEvent : Attack, Entity
---@field attacker any
---@field origin Vec
---@field direction rad
---@field pos Vec
---@field vel Vec
---@field acc Vec
---@field bouncesLeft number
---@field piercesLeft number
---@field target any
---@field ignoreSolids boolean
---@field subtype Type
---@field animDir rad
---@field age number
---@field active boolean
---@field targetsDamaged any[]
AttackEvent = setmetatable({}, { __index = Entity })
AttackEvent.__index = AttackEvent
AttackEvent.type = ATTACK_EVENT

---@param attackState Attack
---@param attacker any
---@param origin Vec
---@param direction rad
---@return AtkEvent
-- AttackEvents armazenam o comportamento de um ataque
-- são instanciados a cada ataque e destruídos ao fim do timer
function AttackEvent.new(attackState, attacker, origin, direction)
	---@type AtkEvent
	local atkEvent = setmetatable({}, AttackEvent) ---@diagnostic disable-line
	local dirVec = polarToVec(direction, 1)
	local hitboxes = copyHitboxes(attackState.hb)
	local initialVel = scaleVec(dirVec, attackState.initialSpeed)
	local initialAcc = scaleVec(dirVec, attackState.accFactor)
	local physics = physicsSettings(
		attackState.initialMass,
		attackState.initialSpeed,
		attackState.friction,
		nil,
		initialVel,
		initialAcc
	)
	atkEvent:init(attackState.name, origin, hitboxes, nil, physics)

	atkEvent.name = attackState.name -- para descobrirmos o caminho até os assets
	atkEvent.ally = attackState.ally -- para definir quem é afetado pelo ataque
	atkEvent.subtype = attackState.subtype -- subtipo do ataque, como melee, ranged, etc
	atkEvent.attacker = attacker -- jogador ou inimigo que desferiu o ataque
	atkEvent.pos = origin -- posição atual do ataque
	atkEvent.dmg = attackState.dmg -- dano atual do ataque (caso mude com o tempo)
	atkEvent.timer = attackState.dur -- tempo até o ataque terminar
	atkEvent.dur = attackState.dur -- duração total do ataque/projétil
	atkEvent.direction = direction -- ângulo do ataque em radianos
	atkEvent.bouncesLeft = attackState.bounces -- número de ricochetes restantes
	atkEvent.piercesLeft = attackState.pierces -- número de alvos atravessáveis restantes
	atkEvent.trajectoryFunc = attackState.trajectoryFunc -- função que define a trajetória do ataque/projétil
	atkEvent.onHit = attackState.onHit -- função executada ao acertar um alvo
	atkEvent.target = attacker.target -- alvo do ataque
	atkEvent.ignoreSolids = attackState.subtype == MELEE_ATTACK -- se o ataque colide com sólidos ou não

	-- atributos fixos na instanciação
	atkEvent.animDir = 0 -- direção visual do sprite, usada para corrigir a rotação do sprite caso necessário
	atkEvent.age = 0 -- tempo desde a criação do ataque
	atkEvent.active = true -- se o ataque atualmente pode dar dano
	atkEvent.targetsDamaged = {} -- lista de alvos feridos pelo ataque

	-- adicionando à respectiva lista de hitboxes
	collisionManager:register(atkEvent)

	return atkEvent
end

---@param dt number
-- atualiza o estado interno de um evento de ataque (`AttackEvent`)
function AttackEvent:baseUpdate(dt)
	self.age = self.age + dt

	-- aplica função de trajetória se existir
	if self.trajectoryFunc then
		self.trajectoryFunc(self, dt)
	end
	self.timer = self.timer - dt
end

----------------------------------------
-- Funções de Renderização
----------------------------------------

---@param settings AnimSettings
-- adiciona as animações à lista `AttackEvents.animations` de acordo
-- com as `settings` fornecidas como argumento
function AttackEvent:addAnimation(settings)
	local path = pngPathFormat({ "assets", "animations", "attacks", self.name, "sheet" })
	local animation = newAnimation(path, settings)
	self.animation = animation
	self.spriteSheet = love.graphics.newImage(path)
	self.spriteSheet:setFilter("nearest", "nearest")
end

---@param camera Camera
-- desenha o evento de ataque no canvas atual segundo a perpectiva da `camera`
function AttackEvent:draw(camera)
	local viewPos = camera:viewPos(self.pos)
	local animation = self.animation
	local quad = animation.frames[animation.currFrame]
	local flipY = (self.direction / math.pi < -0.5 and self.direction / math.pi >= -1.5 and not self.animDir) and -1
		or 1

	love.graphics.draw(
		self.spriteSheet,
		quad,
		viewPos.x,
		viewPos.y,
		self.direction + self.animDir, -- corrigindo a rotação para que o sprite olhe para a direção do ataque
		3,
		3 * flipY,
		animation.frameDim.width / 2,
		animation.frameDim.height / 2
	)
end
