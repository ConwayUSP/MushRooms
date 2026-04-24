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

---@param resources table<Resource, number>
---@return boolean
-- Confere se a lista `resources` possui o que é necessário
-- para craftar esta receita
function Recipe:canCraftWith(resources)
	-- !TODO: implementar essa bagaça
	return true
end
