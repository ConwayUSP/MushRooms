----------------------------------------
-- Importações de Módulos
----------------------------------------
require("modules.constructors.rooms")
require("modules.utils.types")

----------------------------------------
-- Tabela de Salas
----------------------------------------

local BLUEPRINTS = {}

BLUEPRINTS[PUZZLE_ROOM] = { newPuzzleRoom1 }
BLUEPRINTS[RESOURCE_ROOM] = { newResourceRoom1, newResourceRoom2 }
BLUEPRINTS[NPC_ROOM] = { newNPCRoom1, newBiguiriRoom }
-- BLUEPRINTS[BATTLE_ROOM] = { newBattleRoom1 }
BLUEPRINTS[BATTLE_ROOM] = { newDemonBallTestRoom }
BLUEPRINTS[BOSS_ROOM] = { newBossRoom1, newBossRoom2 }
BLUEPRINTS[EVENT_ROOM] = { newEventRoom1 }
BLUEPRINTS[TREASURE_ROOM] = { newTreasureRoom1 }

----------------------------------------
-- Classe SpawnData
----------------------------------------

---@class SpawnData
---@field entity any
---@field chance number

SpawnData = {}
SpawnData.__index = SpawnData
SpawnData.type = SPAWN_DATA

---@param entity any
---@param chance number
---@return SpawnData
-- um dado de spawn nos dá uma forma de descobrir o que será
-- instanciado e com qual chance em cada spawnpoint
function SpawnData.new(entity, chance)
	local data = setmetatable({}, SpawnData)
	data.entity = entity
	data.chance = chance
	return data
end

----------------------------------------
-- Classe SpawnPoint
----------------------------------------

---@class SpawnPoint
---@field pos Vec
---@field spawns SpawnData[]
---@field insert fun(self: SpawnPoint, spawnData: SpawnData): SpawnPoint

SpawnPoint = {}
SpawnPoint.__index = SpawnPoint
SpawnPoint.type = SPAWNPOINT

---@param pos Vec
---@return SpawnPoint
-- um spawn point agrega uma lista de objetos que podem
-- spawnar naquela posição e com qual chance
function SpawnPoint.new(pos)
	local sp = setmetatable({}, SpawnPoint)
	sp.pos = pos -- posição do spawnpoint na sala
	sp.spawns = {} -- lista de SpawnDatas relacionados a este spawn point
	return sp
end

---@param spawnData SpawnData
---@return SpawnPoint?
-- adiciona um `SpawnData` à lista de `spawns` do `SpawnPoint`
function SpawnPoint:insert(spawnData)
	if not spawnData then
		return
	end
	table.insert(self.spawns, spawnData)
	return self
end

----------------------------------------
-- Classe Blueprint
----------------------------------------

---@class Blueprint
---@field roomType RoomType
---@field roomName string
---@field color Color
---@field spawnpoints SpawnPoint[]
---@field puzzles PuzzleBlueprintEntry[]
---@field insert fun(self: Blueprint, spawnpoint: SpawnPoint): Blueprint
---@field addPuzzle fun(self: Blueprint, constructor: fun(room: Room, settings: table): Puzzle, settings: table, rewards: table): Blueprint

---@class PuzzleBlueprintEntry
---@field constructor fun(room: Room, settings: table): Puzzle
---@field settings table
---@field rewards table

Blueprint = {}
Blueprint.__index = Blueprint
Blueprint.type = BLUEPRINT

---@param roomType RoomType
---@param roomName string
---@param color Color
---@return Blueprint
-- A blueprint armazena informações gerais sobre
-- uma sala e uma lista de spawn points
function Blueprint.new(roomType, roomName, color)
	local bp = setmetatable({}, Blueprint)
	bp.roomType = roomType
	bp.roomName = roomName
	bp.color = color
	bp.spawnpoints = {}
	bp.puzzles = {}
	return bp
end

---@param spawnpoint SpawnPoint
---@return Blueprint?
-- adiciona um `SpawnData` à lista de `spawns` do `SpawnPoint`
function Blueprint:insert(spawnpoint)
	if not spawnpoint then
		return
	end
	table.insert(self.spawnpoints, spawnpoint)
	return self
end

---@param constructor fun(room: Room, settings: table): Puzzle
---@param settings table
---@param rewards? table
---@return Blueprint
-- registra um puzzle a ser construído quando a sala for criada
function Blueprint:addPuzzle(constructor, settings, rewards)
	table.insert(self.puzzles, { constructor = constructor, settings = settings, rewards = rewards })
	return self
end

----------------------------------------
-- Funções globais
----------------------------------------

---@param rng RNG
---@return string
-- escolhe um tipo de sala aleatóriamente
-- - Sala de combate: `66%`
-- - Sala de recurso: `12%`
-- - Sala de evento: `8%`
-- - Sala de NPC: `8%`
-- - Sala de puzzle: `2%`
-- - Sala de tesouro: `2%`
-- - Sala de boss: `2%`
function randRoomType(rng)
	local r = rng:random()
	if r < 0.66 then
		return BATTLE_ROOM
	elseif r < 0.78 then
		return RESOURCE_ROOM
	elseif r < 0.86 then
		return EVENT_ROOM
	elseif r < 0.94 then
		return NPC_ROOM
	elseif r < 0.96 then
		return PUZZLE_ROOM
	elseif r < 0.98 then
		return TREASURE_ROOM
	else
		return BOSS_ROOM
	end
end

---@param roomType RoomType
---@param rng RNG
---@return Blueprint
-- retorna um `Blueprint` de uma sala aleatória do tipo `roomType`
function randRoomBlueprint(roomType, rng)
	local n = #BLUEPRINTS[roomType]
	return BLUEPRINTS[roomType][rng:random(n)](rng)
end
