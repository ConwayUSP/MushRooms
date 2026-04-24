----------------------------------------
-- Importações de Módulos
----------------------------------------
require("modules.constructors.resources")
require("modules.utils.utils")

----------------------------------------
-- Funções de debug
----------------------------------------

function _spawnDropCondition()
	return love.keyboard.isDown("q")
end

function _spawnDropDebugHandler(numberKey)
	local spawn = false

	if numberKey == "1" then
		_spawnDropAtPlayer(newKatana(), false)
		spawn = true
	elseif numberKey == "2" then
		_spawnDropAtPlayer(newSlingShot(), false)
		spawn = true
	elseif numberKey == "3" then
		_spawnDropAtPlayer(COIN, true)
		spawn = true
	elseif numberKey == "4" then
		_spawnDropAtPlayer(newWood(), true)
		spawn = true
	elseif numberKey == "5" then
		_spawnDropAtPlayer(newStone(), true)
		spawn = true
	elseif numberKey == "6" then
		_spawnDropAtPlayer(newBone(), true)
		spawn = true
	elseif numberKey == "7" then
		_spawnDropAtPlayer(newFeather(), true)
		spawn = true
	elseif numberKey == "8" then
		_spawnDropAtPlayer(newIron(), true)
		spawn = true
	elseif numberKey == "9" then
		_spawnDropAtPlayer(newGold(), true)
		spawn = true
	elseif numberKey == "0" then
		_spawnDropAtPlayer(newBread(), true)
		spawn = true
	end

	return spawn
end

function _spawnDropAtPlayer(drop, autoPick)
	spawnDrop(drop, players[1].pos, players[1].room, autoPick, getAnchor(players[1], FLOOR), vec(0, -500))
end
