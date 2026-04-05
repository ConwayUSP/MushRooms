----------------------------------------
-- Importações de Módulos
----------------------------------------
require("modules.constructors.recipes")

----------------------------------------
-- Classe Crafting
----------------------------------------
---@class Crafting
---@field possibleCraftings table<string, Recipe>

Crafting = {}
Crafting.__index = Crafting
Crafting.type = CRAFTING


-- Tabela de craftings, separada por tipo:
-- raw: craftings que podem ser feitos em qualquer lugar, sem necessidade de uma estação de crafting específica
-- buildings: craftings que só podem ser feitos em estações de crafting específicas
-- kitchen: craftings que só podem ser feitos em estações de cozinha
local craftingsTable = {
  raw = {
    firecamp = newFireCamp(),
    engineering_table = newEngineeringTable(),
  }, 
  buildings = {
    chest = newChest(),
    kitchen_station = newKitchenStation(),
    furnace = newFurnace(),
    drill = newDrill(),
    trap = newTrap(),
    ladder = newLadder(),
    blesser = newBlesser(),
    forge = newForge(),
  }, 
  kitchen = {

  }
}


---@param possibleCraftings? table<string, Recipe> | nil
---@param craftingType? string
-- cria uma nova instância de crafting
function Crafting.new(craftingType, possibleCraftings)
  local inv = setmetatable({}, Crafting)
  inv.possibleCraftings = possibleCraftings or craftingsTable[craftingType] or {}

  return inv
end

---@param resources Resource[]
---@return Resource | nil
-- retorna o item que pode ser craftado com os recursos fornecidos
function Crafting:canCraftWith(resources)
  
  for _, recipe in pairs(self.possibleCraftings) do
    local inputs = recipe.inputs

    if #resources ~= #inputs then
      goto next_recipe
    end

    local count = {}

    for _, res in pairs(inputs) do
      count[res] = (count[res] or 0) + 1
    end

    for _, res in pairs(resources) do
      if not count[res] or count[res] <= 0 then
        goto next_recipe
      end
      count[res] = count[res] - 1
    end

    do return recipe.output end

    ::next_recipe::
  end

  return nil
end

---@param inventory Inventory
---@param resouces Resource[]
---@return Resource | nil
-- tenta craftar um item com os recursos fornecidos; se for possível, adiciona o item ao inventário e remove os recursos usados
function Crafting:tryCraft(inventory, resouces)
  local item = self:canCraftWith(resouces)

  if item then
    inventory:addItem(item)
    for _, res in pairs(resouces) do
      inventory:subtractItem(res)
    end
  end

  return item
end
