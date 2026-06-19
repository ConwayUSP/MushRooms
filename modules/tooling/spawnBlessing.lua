----------------------------------------
-- Importações de Módulos
----------------------------------------
require("modules.utils.entities")
require("modules.utils.utils")

----------------------------------------
-- Funções de debug
----------------------------------------

function _spawnBlessingCondition()
	return love.keyboard.isDown("b")
end

function _spawnBlessingDebugHandler(numberKey)
	local spawn = false
	local constructors = {}

	if not tonumber(numberKey) then 
		return false 
	end

	for _, constructor in pairs(CONSTRUCTORS[BLESSING]) do
		table.insert(constructors, constructor)
	end

	local blessing = constructors[tonumber(numberKey)]
	if blessing then
		_spawnDropAtPlayer(blessing(), true)
		spawn = true
	end

	return spawn
end

function _spawnDropAtPlayer(drop, autoPick)
	spawnDrop(drop, players[1].pos, players[1].room, autoPick, getAnchor(players[1], FLOOR), vec(0, -500))
end
