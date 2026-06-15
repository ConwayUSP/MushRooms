----------------------------------------
-- Importações de Módulos
----------------------------------------
require("modules.systems.crafting")

----------------------------------------
-- Construtores de Crafting
----------------------------------------

function newCraftingRaw(player)
  local recipes = {
    FIRECAMP_RECIPE,
    CHEST_RECIPE,
    -- ENGINEERING_TABLE_RECIPE,
  }

  local craftingManager = CraftingManager.new(recipes, player.uiManager)

  return craftingManager
end