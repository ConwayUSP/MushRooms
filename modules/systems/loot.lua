----------------------------------------
-- Classe Loot
----------------------------------------

---@class Loot
---@field len number
---@field insert function

Loot = {}
Loot.__index = Loot
Loot.type = LOOT

---@param object? any
---@param chance? number
---@param amountRange? range
---@param autoPick? boolean
---@return Loot
-- cria um `Loot` a partir de um objeto, uma faixa de quantidade (`amountRange`),
-- uma `chance` e se o objeto é coletado automaticamente com proximidade (`autoPick`)
function Loot.new(object, chance, amountRange, autoPick)
	local loot = setmetatable({}, Loot)
	loot.len = 0
	loot:insert(object, chance, amountRange, autoPick)
	return loot
end

---@param object? any
---@param chance? number
---@param amountRange? range
---@param autoPick? boolean
---@return Loot?
-- insere um objeto com suas configurações de spawn: `chance`, `amountRange` e `autoPick`
function Loot:insert(object, chance, amountRange, autoPick)
	if not object then
		return
	end
	self.len = self.len + 1
	self[self.len] = {}
	self[self.len].object = object
	self[self.len].chance = chance
	self[self.len].amountRange = amountRange
	self[self.len].autoPick = autoPick
	return self
end

----------------------------------------
-- Tabela de loots do jogo
----------------------------------------

---@type table<string, Loot>
-- tabela que associa o nome de objetos que contém loot com o `Loot` que eles contém
LOOT_TABLE = {
	barrel = Loot.new(COIN, 0.5, range(1, 4), true),
	jar = Loot.new(COIN, 0.5, range(1, 4), true),
}
