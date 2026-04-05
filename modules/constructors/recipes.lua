require("modules.systems.recipes")

function newFireCamp()
  local inputs = { WOOD, STONE }
  local output = FIRECAMP
  local stationType = "raw"
  
  return Recipe.new(inputs, output, stationType)
end

function newChest()
  local inputs = { WOOD, IRON }
  local output = CHEST
  local stationType = "buildings"

  return Recipe.new(inputs, output, stationType)
end

function newEngineeringTable()
  local inputs = { WOOD, IRON, STONE }
  local output = ENGINEERING_TABLE
  local stationType = "raw"

  return Recipe.new(inputs, output, stationType)
end

function newKitchenStation()
  local inputs = { WOOD, STONE, BREAD }
  local output = KITCHEN_STATION
  local stationType = "buildings"

  return Recipe.new(inputs, output, stationType)
end

function newFurnace()
  local inputs = { STONE, STONE, IRON }
  local output = FURNACE
  local stationType = "buildings"

  return Recipe.new(inputs, output, stationType)
end

function newDrill()
  local inputs = { STONE, IRON, GOLD }
  local output = DRILL
  local stationType = "buildings"

  return Recipe.new(inputs, output, stationType)
end

function newTrap()
  local inputs = { WOOD, BONE, FEATHER }
  local output = TRAP
  local stationType = "buildings"

  return Recipe.new(inputs, output, stationType)
end

function newLadder()
  local inputs = { WOOD, WOOD, STONE }
  local output = LADDER
  local stationType = "buildings"

  return Recipe.new(inputs, output, stationType)
end

function newBlesser()
  local inputs = { GOLD, BREAD, FEATHER }
  local output = BLESSER
  local stationType = "buildings"

  return Recipe.new(inputs, output, stationType)
end

function newForge()
  local inputs = { STONE, IRON, IRON }
  local output = FORGE
  local stationType = "buildings"

  return Recipe.new(inputs, output, stationType)
end