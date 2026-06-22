----------------------------------------
-- Importações de Módulos
----------------------------------------
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
TC_ALL = bit.bor(TC_ON_INIT, TC_EVERY_FRAME, TC_ON_KILL, TC_ON_COLLISION)

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

---@param subtype any
---@param changeTrigger any
---@param pos any
---@param weight any
---@param duration any
---@return table
-- cria um Target cuja função é ser parte da direção da mira ou do movimento de alguma entidade
function Target.new(subtype, changeTrigger, pos, weight, duration)
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
---@field targets table<Target, fun(tm: TargetManager, target: Target)>
---@field TCTimer Timer

TargetManager = {}
TargetManager.__index = TargetManager
TargetManager.type = TARGET_MANAGER

---@return TargetManager
-- Cria um TargetManager que controla toda a lógica de seleção e resolução de alvos
-- para inimigos, armas, ou qualquer entidade que "mire" em algo
function TargetManager.new(entity)
    local manager = setmetatable({}, TargetManager)
    manager.entity = entity
    manager.targets = {}

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
        -- caso excepcional: chamamos a estratégia fora do applyStrats pois o timer exige
        if target.timer.goingOff then
            strat(self, target)
        end
    end
    self:applyStrats(TC_EVERY_FRAME)
end

---@param trigger TargetChangeTrigger
-- aplica todas as mudanças de target cujas ativações estejam contidas no bitmask `trigger`
function TargetManager:applyStrats(trigger)
    for target, strat in pairs(self.targets) do
        if bit.band(target.changeTrigger, trigger) > 0 then
            strat(self, target)
        end
    end
end

-- limpa todos os targets deste manager;
-- cuidado! uma entidade sem alvos pode ficar perdidinha
function TargetManager:clearTargets()
    self.targets = {}
end

---@return Vec, boolean
-- faz a média dos targets ponderada por seus pesos;
-- retorna um vetor com a posição do target final (assumindo um target resultante de atração)
-- e um booleano indicando sucesso
function TargetManager:collapseTargets()
    local resultingTarget = vec(0, 0)
    local totalWeight = 0
    for t, _ in pairs(self.targets) do
        totalWeight = totalWeight + t.weight
        -- invertendo o sinal de targets que queremos evitar
        local w = t.subtype == TG_SEEK and t.weight or -t.weight
        resultingTarget = sumVec(resultingTarget, scaleVec(t.pos, w))
    end
    if totalWeight == 0 then
        return resultingTarget, false
    else
        resultingTarget = scaleVec(resultingTarget, 1 / totalWeight)
        return resultingTarget, true
    end
end
