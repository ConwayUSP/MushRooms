----------------------------------------
-- Importações de Módulos
----------------------------------------
require("modules.utils.types")
require("modules.utils.utils")
require("modules.entities.product")

----------------------------------------
-- Construtores de Construções
----------------------------------------

function newChest()
	local hb = hitboxes({ hitbox(Circle.new(30)) }, { hitbox(Circle.new(30)) }, {})
	local chest = Product.new(BUILDING, CHEST.name, CHEST.description, hb)

	local animSettings = {}
	animSettings[IDLE] = newAnimSetting(1, size(128, 128), 1, true, 1)
	animSettings[ACTIVE] = newAnimSetting(1, size(128, 128), 1, true, 1)
	local pathStart = dirPathFormat({ "assets", "animations", "products", BUILDING, CHEST.name })
	addAnimations(chest, pathStart, animSettings)

	return chest
end

function newFirecamp()
	local hb = hitboxes({ hitbox(Circle.new(30)) }, { hitbox(Circle.new(30)) }, {})
	local firecamp = Product.new(BUILDING, FIRECAMP.name, FIRECAMP.description, hb)

	local animSettings = {}
	animSettings[IDLE] = newAnimSetting(2, size(128, 128), 0.2, true, 1)
	animSettings[ACTIVE] = newAnimSetting(2, size(128, 128), 0.2, true, 1)
	local pathStart = dirPathFormat({ "assets", "animations", "products", BUILDING, FIRECAMP.name })
	addAnimations(firecamp, pathStart, animSettings)

	return firecamp
end
