----------------------------------------
-- Importações de Módulos
----------------------------------------
require("modules.utils.types")

----------------------------------------
-- Classe Product
----------------------------------------

---@class Artifact
---@field name string
---@field description string
---@field owner Player
---@field cooldown Timer
---@field onUse fun(self: Artifact)
---@field customData table
---@field customUpdate fun(self: Artifact, dt: number)
---@field update fun(self: Artifact, dt: number)
---@field use fun(self: Artifact)
---@field setOwner fun(self: Artifact, owner: Player)

Artifact = {}
Artifact.__index = Artifact
Artifact.type = ARTIFACT

-- cria uma nova instância de Artifact
function Artifact.new(name, description, cooldown, onUse, customData, customUpdate)
	---@type Artifact
	local artifact = setmetatable({}, Artifact) ---@diagnostic disable-line

	artifact.name = name -- nome do artefato
	artifact.description = description -- descrição visível no inventário
	artifact.cooldown = Timer.new(cooldown) -- timer do cooldown, enquanto ativo o item não pode ser usado
	artifact.onUse = onUse -- efeito ao utilizar o artefato
	artifact.customData = customData -- possiveis dados adicionais, considerando a grande diferença entre artefatos
	artifact.customUpdate = customUpdate -- é útil para manipular a o customData a cada frame

	return artifact
end

---@param dt number
-- atualiza o artefato
function Artifact:update(dt)
	self.cooldown:update(dt)
end

-- ativa o efeito do artefato e inicia o cooldown
function Artifact:use()
	self.cooldown:start()
	self:onUse()
end

---@param owner Player
-- define o jogador que possui o artefato
function Artifact:setOwner(owner)
	self.owner = owner
end
