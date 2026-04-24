----------------------------------------
-- Importações de Módulos
----------------------------------------
require("modules.constructors.recipes")

----------------------------------------
-- Classe Crafting Manager
----------------------------------------
---@class CraftingManager
---@field recipes Recipe[]
---@field uimanager UIManager

CraftingManager = {}
CraftingManager.__index = CraftingManager
CraftingManager.type = CRAFTING_MANAGER

---@param recipes Recipe[]
---@param uimanager UIManager
-- cria um novo `CraftingManager` para um determinado contexto de crafting
function CraftingManager.new(recipes, uimanager)
	local cm = setmetatable({}, CraftingManager)
	cm.recipes = recipes
	cm.uimanager = uimanager
end
