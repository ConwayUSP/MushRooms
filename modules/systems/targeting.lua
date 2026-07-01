----------------------------------------
-- Importações de Módulos
----------------------------------------
require("modules.utils.vec")
local bit = require("bit")

----------------------------------------
-- Enums e Tipos
----------------------------------------

-- um bitmask maroto
---@alias TargetChangeTrigger number
TC_EVERY_FRAME = 1
TC_ON_INIT = 2
TC_ON_KILL = 4
TC_ON_COLLISION = 8
TC_ON_TRIGGER_HITBOX = 16
TC_ALL = bit.bor(TC_ON_INIT, TC_EVERY_FRAME, TC_ON_KILL, TC_ON_COLLISION, TC_ON_TRIGGER_HITBOX)

---@alias TargetType string
TG_AVOID = "avoid"
TG_SEEK = "seek"

----------------------------------------
-- Classe Target
----------------------------------------

---@class Target
---@field subtype TargetType
---@field changeTrigger TargetChangeTrigger
---@field pos Vec
---@field weight number
---@field timer? Timer

Target = {}
Target.__index = Target
Target.type = TARGET

---@param subtype TargetType
---@param changeTrigger? TargetChangeTrigger
---@param duration? number
---@param pos? Vec
---@param weight? number
---@return table
-- cria um Target cuja função é ser parte da direção da mira ou do movimento de alguma entidade
function Target.new(subtype, changeTrigger, duration, pos, weight)
	local target = setmetatable({}, Target)
	target.subtype = subtype or TG_SEEK
	target.changeTrigger = changeTrigger or TC_ON_INIT
	target.pos = pos or vec(0, 0)
	target.weight = weight or 0
	target.timer = duration and Timer.new(duration) or Timer.new(math.huge)

	return target
end

----------------------------------------
-- Classe TargetManager
----------------------------------------

---@class TargetManager
---@field owner Entity
---@field targetPos Vec
---@field validTarget boolean
---@field targets table<Target, fun(tm: TargetManager, target: Target)>
---@field update fun(self: TargetManager, dt: number)
---@field addTarget fun(self: TargetManager, target: Target, strategy: fun(tm: TargetManager, target: Target))
---@field applyStrats fun(self: TargetManager, triggerMask: TargetChangeTrigger)

TargetManager = {}
TargetManager.__index = TargetManager
TargetManager.type = TARGET_MANAGER

---@return TargetManager
-- Cria um TargetManager que controla toda a lógica de seleção e resolução de alvos
-- para inimigos, armas, ou qualquer entidade que "mire" em algo
function TargetManager.new(entity)
	local manager = setmetatable({}, TargetManager)
	manager.owner = entity
	manager.targets = {}
	manager.targetPos = vec(0, 0)
	manager.validTarget = false

	return manager
end

---@param target Target
---@param strategy fun(tm: TargetManager, target: Target)
---@return TargetManager
-- adiciona um target e sua estratégia de seleção ao manager, pode ser encadeado (retorna self)
function TargetManager:addTarget(target, strategy)
	self.targets[target] = strategy
	return self
end

---@param dt number
-- atualiza o timer de todos os targets e chama as funções de estratégia necessárias
function TargetManager:update(dt)
	for target, strat in pairs(self.targets) do
		target.timer:update(dt)
		-- se o target tinha duração específica, remove ele ao fim da duração
		if target.timer.goingOff then
			self.targets[target] = nil
		end
	end
	self:applyStrats(TC_EVERY_FRAME)
end

---@param triggerMask TargetChangeTrigger
-- aplica todas as mudanças de target cujas ativações estejam contidas no bitmask `triggerMask`
function TargetManager:applyStrats(triggerMask)
	for target, strat in pairs(self.targets) do
		if bit.band(target.changeTrigger, triggerMask) > 0 then
			strat(self, target)
		end
	end
	self:collapseTargets()
end

-- limpa todos os targets deste manager;
-- cuidado! uma entidade sem alvos pode ficar perdidinha
function TargetManager:clearTargets()
	self.targets = {}
end

-- faz a média dos targets ponderada por seus pesos;
-- define a propriedade targetPos como sendo essa média, e a propriedade
-- validTarget como uma flag que diz se foi possível definir um targetPos
function TargetManager:collapseTargets()
	local resultingTarget = vec(0, 0)
	local totalWeight = 0
	for t, _ in pairs(self.targets) do
		totalWeight = totalWeight + t.weight
		-- invertendo o sinal de targets que queremos evitar
		local w = t.subtype == TG_SEEK and t.weight or -t.weight
		resultingTarget = addVec(resultingTarget, scaleVec(t.pos, w))
	end
	if totalWeight == 0 then
		-- se todos os targets estão com peso zerado, não temos muito para onde ir
		self.validTarget = false
	else
		self.targetPos = scaleVec(resultingTarget, 1 / totalWeight)
		self.validTarget = true
	end
end
