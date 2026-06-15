----------------------------------------
-- Importações de Módulos
----------------------------------------
require("modules.entities.room")
require("modules.systems.blueprint")
require("modules.utils.utils")

----------------------------------------
-- Funções de debug
----------------------------------------

function _roomCondition()
	return love.keyboard.isDown("r")
end

function _roomDebugHandler(numberKey)
	local roomChange = false

	local debugRoomPos = { x = players[1].room.arrPos.x + 1, y = players[1].room.arrPos.y }
	if numberKey == "1" then
		_newRoomDebug(debugRoomPos, Room.stdDim, BATTLE_ROOM)
		roomChange = true
	elseif numberKey == "2" then
		_newRoomDebug(debugRoomPos, Room.stdDim, NPC_ROOM)
		roomChange = true
	elseif numberKey == "3" then
		_newRoomDebug(debugRoomPos, Room.stdDim, RESOURCE_ROOM)
		roomChange = true
	elseif numberKey == "4" then
		_newRoomDebug(debugRoomPos, Room.stdDim, PUZZLE_ROOM)
		roomChange = true
	elseif numberKey == "5" then
		_newRoomDebug(debugRoomPos, Room.stdDim, EVENT_ROOM)
		roomChange = true
	elseif numberKey == "6" then
		_newRoomDebug(debugRoomPos, Room.stdDim, BOSS_ROOM)
		roomChange = true
	end
	if roomChange then
		collisionManager.roomsDirty = true
	end
	return roomChange
end

function _newRoomDebug(pos, dimensions, type)
	newRoom(pos, dimensions, type)
end
