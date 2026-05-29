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
	local physics = physicsSettings(math.huge, 0, 0, nil, nil, nil, 0)
	local chest = Product.new(BUILDING, CHEST.name, CHEST.description, hb, physics)

	local animSettings = {}
	animSettings[IDLE] = newAnimSetting(1, size(128, 128), 1, true, 1)
	animSettings[ACTIVE] = newAnimSetting(1, size(128, 128), 1, true, 1)
	local pathStart = dirPathFormat({ "assets", "animations", "products", BUILDING, CHEST.name })
	addAnimations(chest, pathStart, animSettings)
	chest.shadowWidth = 35

	return chest
end

function newFirecamp()
	local hb = hitboxes({ hitbox(Circle.new(30)) }, { hitbox(Circle.new(30)) }, { hitbox(Circle.new(120)) })
	local physics = physicsSettings(math.huge, 0, 0, nil, nil, nil, 0)
	local onInteract = function() end
	local onEnter = function(firecamp, player)
		player.inFirecamp = true
		print("Player entered firecamp")
	end
	local onExit = function(firecamp, player)
		player.inFirecamp = false
		print("Player exited firecamp")
	end
	local firecamp = Product.new(BUILDING, FIRECAMP.name, FIRECAMP.description, hb, physics, onInteract, nil, onEnter, onExit)

	local animSettings = {}
	animSettings[IDLE] = newAnimSetting(2, size(128, 128), 0.2, true, 1)
	animSettings[ACTIVE] = newAnimSetting(2, size(128, 128), 0.2, true, 1)
	local pathStart = dirPathFormat({ "assets", "animations", "products", BUILDING, FIRECAMP.name })
	addAnimations(firecamp, pathStart, animSettings)
	firecamp.shadowWidth = 35
	return firecamp
end
