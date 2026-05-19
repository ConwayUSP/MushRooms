----------------------------------------
-- Importações de Módulos
----------------------------------------
require("modules.constructors.resources")
require("modules.constructors.weapons")
require("modules.utils.entities")
require("modules.utils.utils")

----------------------------------------
-- Funções de debug
----------------------------------------

function _spawnDropCondition()
	return love.keyboard.isDown("q")
end

function _spawnDropDebugHandler(numberKey)
	local spawn = false
	local constructors = {}

	for _, constructor in pairs(CONSTRUCTORS[RESOURCE]) do
		table.insert(constructors, constructor)
	end
	table.insert(constructors, newKatana)
	table.insert(constructors, newSlingShot)

	local idx = math.random(tableLen(constructors))
	local c = 0
	for _, constructor in pairs(constructors) do
		c = c + 1
		if c == idx then
			_spawnDropAtPlayer(constructor(), true)
			spawn = true
		end
	end

	return spawn
end

function _spawnDropAtPlayer(drop, autoPick)
	spawnDrop(drop, players[1].pos, players[1].room, autoPick, getAnchor(players[1], FLOOR), vec(0, -500))
end
