require("modules.entities.resource")

---@return Resource
-- cria um recurso do tipo Madeira
function newWood()
	local description = "A piece of wood, useful for crafting."
	local wood = Resource.new(MATERIAL, WOOD.name, description)

	return wood
end

---@return Resource
-- cria um recurso do tipo Pedra
function newStone()
	local description = "A sturdy stone, can be used for building."
	local stone = Resource.new(MATERIAL, STONE.name, description)

	return stone
end

---@return Resource
-- cria um recurso do tipo Osso
function newBone()
	local description = "A bone from a creature, might have some value."
	local bone = Resource.new(MATERIAL, BONE.name, description)

	return bone
end

---@return Resource
-- cria um recurso do tipo Pena
function newFeather()
	local description = "A light feather, could be used for crafting arrows."
	local feather = Resource.new(MATERIAL, FEATHER.name, description)

	return feather
end

---@return Resource
-- cria um recurso do tipo Ferro
function newIron()
	local description = "A chunk of iron ore, essential for forging weapons."
	local iron = Resource.new(MATERIAL, IRON.name, description)

	return iron
end

---@return Resource
-- cria um recurso do tipo Ouro
function newGold()
	local description = "A precious piece of gold, valuable for trading."
	local gold = Resource.new(MATERIAL, GOLD.name, description)

	return gold
end

---@return Resource
-- cria um recurso do tipo Pão
function newBread()
	local description = "A loaf of bread, restores a small amount of health."
	local bread = Resource.new(MATERIAL, BREAD.name, description)

	return bread
end
