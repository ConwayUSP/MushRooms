----------------------------------------
-- Tipo RecipeInput
----------------------------------------

---@alias CraftInput table<EntityReg, number>

---@param res EntityReg
---@param qty number
---@return CraftInput
-- cria um input de receita
function craftInput(res, qty)
	return { res, qty }
end

----------------------------------------
-- Classe Recipe
----------------------------------------

---@class Recipe
---@field inputs table<Resource, number>
---@field output any Armas, Construcoes, Comidas, etc.

Recipe = {}
Recipe.__index = Recipe
Recipe.type = RECIPE

function Recipe.new(inputs, output)
	local recipe = setmetatable({}, Recipe)
	recipe.inputs = inputs
	recipe.output = output

	return recipe
end

---@param inv Inventory
---@return boolean
-- Confere se o inventário do player em questão possui
-- o que é necessário para craftar esta receita
function Recipe:canCraftWith(inv)
	for _, inp in pairs(self.inputs) do
		if inv:countItem(inp[1]) < inp[2] then
			return false
		end
	end
	return true
end

---@param inv Inventory
---@return boolean
-- checa se consegue craftar e consome os itens se conseguir
function Recipe:consumeItems(inv)
	if not self:canCraftWith(inv) then
		return false
	end

	for _, inp in pairs(self.inputs) do
		inv:subtractItem(inp[1], inp[2])
	end
	return true
end
