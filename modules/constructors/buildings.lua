----------------------------------------
-- Importações de Módulos
----------------------------------------
require("modules.utils.types")
require("modules.utils.utils")
require("modules.entities.product")

----------------------------------------
-- Construtores de Construções
----------------------------------------

local physics = physicsSettings(math.huge, 0, 0, nil, nil, nil, 0)

function newChest()
	local hb = hitboxes({ hitbox(Circle.new(30)) }, { hitbox(Circle.new(30)) }, {})
	local onInteract = function(chest, player)
		print("Player interacted with chest")
	end
	
	local animSettings = {}
	animSettings[IDLE] = newAnimSetting(1, size(128, 128), 1, true, 1)
	animSettings[ACTIVE] = newAnimSetting(1, size(128, 128), 1, true, 1)
	local pathStart = dirPathFormat({ "assets", "animations", "products", BUILDING, CHEST.name })

	local makeInteractive = function(pos, room)
		local chestInteractive = Interactive.new(CHEST.name, pos, hb, room, physics, onInteract)
		addAnimations(chestInteractive, pathStart, animSettings)	
	
		return chestInteractive
	end
	
	local chest = Product.new(BUILDING, CHEST.name, CHEST.description, makeInteractive)

	addAnimations(chest, pathStart, animSettings)
	chest.shadowWidth = 35

	return chest
end

function newFirecamp()
	local hb = hitboxes({ hitbox(Circle.new(30)) }, { hitbox(Circle.new(30)) }, { hitbox(Circle.new(120)) })

	local onInteract = function() end
	local onEnter = function(firecamp, player)
		if not firecamp.playersHealing then
			firecamp.playersHealing = {player}
		else
			table.insert(firecamp.playersHealing, player)
		end

		print("Player entered firecamp")
		player.inFirecamp = true
	end
	local customUpdate = function(self, dt)
		if not self.playersHealing then
			return
		end

		for _, player in pairs(self.playersHealing) do
			local cap = 40
			if player.state ~= DYING and player.hp < cap then
				player:heal(4 * dt)
				if player.hp > cap then
					player.hp = cap
				end
				print("curando no fogo, hp atual: " .. math.floor(player.hp))
			end
		end
	end
	local onExit = function(firecamp, player)
		if firecamp.playersHealing then
			local i = tableIndexOf(firecamp.playersHealing, player)
			if i then
				table.remove(firecamp.playersHealing, i)
			end
		end

		print("Player exited firecamp")
		player.inFirecamp = false
	end
	
	local animSettings = {}
	animSettings[IDLE] = newAnimSetting(2, size(128, 128), 0.2, true, 1)
	animSettings[ACTIVE] = newAnimSetting(2, size(128, 128), 0.2, true, 1)
	local pathStart = dirPathFormat({ "assets", "animations", "products", BUILDING, FIRECAMP.name })
	
	local makeInteractive = function(pos, room)
		local firecampInteractive = Interactive.new(FIRECAMP.name, pos, hb, room, physics, onInteract, customUpdate, onEnter, onExit)
		addAnimations(firecampInteractive, pathStart, animSettings)

		return firecampInteractive
	end

	local firecamp = Product.new(BUILDING, FIRECAMP.name, FIRECAMP.description, makeInteractive)
	
	addAnimations(firecamp, pathStart, animSettings)
	firecamp.shadowWidth = 35
	return firecamp
end
