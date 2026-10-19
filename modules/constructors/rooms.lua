----------------------------------------
-- Importações de Módulos
----------------------------------------

require("modules.constructors.puzzles.grid")
require("modules.utils.roomgeneration")

---@param rng RNG
---@return Blueprint
-- sala de puzzle pequena
function newPuzzleRoom1(rng)
	local bp = Blueprint.new(PUZZLE_ROOM, "Puzzle Room 4x4", rgba8(12, 253, 255, 255))
	local gridSize = vec(4, 4)
	local decorationMargin = 100
	local excludedAreas = { GridPuzzle.exclusionArea(gridSize, decorationMargin) }
	RoomGeneration.insertGeneralDecorations(bp, rng, excludedAreas)

	bp:addPuzzle(GridPuzzle.new, {
		size = gridSize,
		centerSize = vec(2, 2),
		pins = GridPuzzle.fullPerimeterPins(gridSize),
		stones = {
			{ id = "stone-up-left", cell = vec(1, 1), direction = vec(1, 1) },
			{ id = "stone-up-right", cell = vec(4, 1), direction = vec(-1, 1) },
			{ id = "stone-down-left", cell = vec(1, 4), direction = vec(1, -1) },
			{ id = "stone-down-right", cell = vec(4, 4), direction = vec(-1, -1) },
		},
	})

	return bp
end

---@param rng RNG
---@return Blueprint
-- sala de puzzle média
function newPuzzleRoom2(rng)
	local bp = Blueprint.new(PUZZLE_ROOM, "Puzzle Room 6x6", rgba8(12, 253, 255, 255))
	local gridSize = vec(6, 6)
	local decorationMargin = 100
	local excludedAreas = { GridPuzzle.exclusionArea(gridSize, decorationMargin) }
	RoomGeneration.insertGeneralDecorations(bp, rng, excludedAreas)

	bp:addPuzzle(GridPuzzle.new, {
		size = gridSize,
		centerSize = vec(2, 2),
		pins = GridPuzzle.fullPerimeterPins(gridSize),
		stones = {
			{ id = "stone-up-left", cell = vec(1, 2), direction = vec(1, 1) },
			{ id = "stone-up-right", cell = vec(6, 1), direction = vec(-1, 1) },
			{ id = "stone-down-left", cell = vec(2, 6), direction = vec(1, -1) },
			{ id = "stone-down-right", cell = vec(5, 5), direction = vec(-1, -1) },
		},
	})

	return bp
end

---@param rng RNG
---@return Blueprint
-- sala de puzzle GRANDE
function newPuzzleRoom3(rng)
	local bp = Blueprint.new(PUZZLE_ROOM, "Puzzle Room 8x8", rgba8(12, 253, 255, 255))
	local gridSize = vec(8, 8)
	local decorationMargin = 100
	local excludedAreas = { GridPuzzle.exclusionArea(gridSize, decorationMargin) }
	RoomGeneration.insertGeneralDecorations(bp, rng, excludedAreas)

	bp:addPuzzle(GridPuzzle.new, {
		size = gridSize,
		centerSize = vec(2, 2),
		pins = GridPuzzle.fullPerimeterPins(gridSize),
		stones = {
			{ id = "stone-up-left", cell = vec(2, 2), direction = vec(1, 1) },
			{ id = "stone-up-right", cell = vec(7, 3), direction = vec(-1, 1) },
			{ id = "stone-down-left", cell = vec(1, 7), direction = vec(1, -1) },
			{ id = "stone-down-right", cell = vec(8, 8), direction = vec(-1, -1) },
		},
	})

	return bp
end

---@return Blueprint
-- sala de NPC 1: contém barrís e jarros
function newNPCRoom1(rng)
	local bp = Blueprint.new(NPC_ROOM, "Test NPC Room", rgba8(120, 58, 242, 255))
	local sp1 = SpawnPoint.new(vec(250, 0))
	local tenkarData = SpawnData.new(TENKAR, 0.5)
	local shoumShoumData = SpawnData.new(SHOUM_SHOUM, 1.0)
	sp1:insert(tenkarData):insert(shoumShoumData)
	bp:insert(sp1)
	RoomGeneration.insertGeneralDecorations(bp, rng)
	return bp
end

---@return Blueprint
-- sala de NPC 1: contém o Biguiri
function newBiguiriRoom(rng)
	local bp = Blueprint.new(NPC_ROOM, "Test NPC Room", rgba8(120, 58, 242, 255))
	local sp1 = SpawnPoint.new(vec(0, 0))
	local biguiriData = SpawnData.new(BIGUIRI, 1.0)
	sp1:insert(biguiriData)
	bp:insert(sp1)
	RoomGeneration.insertGeneralDecorations(bp, rng)
	return bp
end

---@return Blueprint
-- sala de recurso 1: contém fontes de recurso
function newResourceRoom1(rng)
	local bp = Blueprint.new(RESOURCE_ROOM, "Test Resource Room", rgba8(255, 248, 122, 255))
	local sp1 = SpawnPoint.new(vec(100, 500))
	local sp2 = SpawnPoint.new(vec(200, 0))
	local sp3 = SpawnPoint.new(vec(300, -200))
	local sp4 = SpawnPoint.new(vec(400, 800))

	local bonesData = SpawnData.new(BONE_PILE, 0.333)
	local rocksData = SpawnData.new(DESTRUCTIBLE_ROCK, 0.666)
	local coalData = SpawnData.new(COAL_ALTAR, 1.0)
	sp1:insert(bonesData):insert(rocksData):insert(coalData)
	sp2:insert(bonesData):insert(rocksData):insert(coalData)
	sp3:insert(bonesData):insert(rocksData):insert(coalData)
	sp4:insert(bonesData):insert(rocksData):insert(coalData)
	
	bp:insert(sp1):insert(sp2):insert(sp3):insert(sp4)
	RoomGeneration.insertGeneralDecorations(bp, rng)
	return bp
end

---@return Blueprint
-- sala de recurso 2: contém grama alta pra caralho
function newResourceRoom2(rng)
	local bp = Blueprint.new(RESOURCE_ROOM, "Test Resource Room 2", rgba8(255, 248, 122, 255))
	local grassData = SpawnData.new(TALL_GRASS, 1.0)
	for i = 1, 4 do
		for j = 1, 4 do
			local sp = SpawnPoint.new(vec(i * 60 - 120 - j, j * 30 - 80 + i))
			sp:insert(grassData)
			bp:insert(sp)
		end
	end
	RoomGeneration.insertGeneralDecorations(bp, rng)
	return bp
end

---@return Blueprint
-- sala de batalha 1: contém Gatos Nucleares e Patos Aranhas
function newBattleRoom1(rng)
	local bp = Blueprint.new(BATTLE_ROOM, "Test Battle Room", rgba8(255, 255, 255, 255))
	local sp1 = SpawnPoint.new(vec(200, -200))
	local sp2 = SpawnPoint.new(vec(-200, 200))
	local sp3 = SpawnPoint.new(vec(200, 200))
	local sp4 = SpawnPoint.new(vec(-200, -200))
	local enemyData1 = SpawnData.new(SPIDER_DUCK, 0.2)
	local enemyData2 = SpawnData.new(NUCLEAR_CAT, 0.4)
	local enemyData3 = SpawnData.new(ROLLING_STONE, 0.7)
	local enemyData4 = SpawnData.new(DEMON_BALL, 1.0)
	sp1:insert(enemyData1):insert(enemyData2):insert(enemyData3):insert(enemyData4)
	sp2:insert(enemyData1):insert(enemyData2):insert(enemyData3):insert(enemyData4)
	sp3:insert(enemyData1):insert(enemyData2):insert(enemyData3):insert(enemyData4)
	sp4:insert(enemyData1):insert(enemyData2):insert(enemyData3):insert(enemyData4)
	bp:insert(sp1):insert(sp2):insert(sp3):insert(sp4)
	RoomGeneration.insertGeneralDecorations(bp, rng)
	return bp
end

---@return Blueprint
function newBossRoom1(rng)
	local bp = Blueprint.new(BOSS_ROOM, "Test Boss Room", rgba8(255, 41, 41, 255))
	local sp1 = SpawnPoint.new(vec(0, 0))
	local enemyData1 = SpawnData.new(SPIDER_DUCK_BOSS, 1.0)
	sp1:insert(enemyData1)
	bp:insert(sp1)
	RoomGeneration.insertGeneralDecorations(bp, rng)
	return bp
end

---@return Blueprint
-- sala de boss 2: contém 1 Ancient Moai no centro
function newBossRoom2(rng)
	local bp = Blueprint.new(BOSS_ROOM, "Ancient Moai Boss Room", rgba8(180, 120, 60, 255))
	local sp1 = SpawnPoint.new(vec(0, 0))
	local enemyData1 = SpawnData.new(ANCIENT_MOAI, 1.0)
	sp1:insert(enemyData1)
	bp:insert(sp1)
	RoomGeneration.insertGeneralDecorations(bp, rng)
	return bp
end

---@return Blueprint
-- sala de evento 1: contém inimigos
function newEventRoom1(rng)
	local bp = Blueprint.new(EVENT_ROOM, "Test Event Room", rgba8(104, 237, 102, 255))
	local sp1 = SpawnPoint.new(vec(0, 0))
	local enemyData1 = SpawnData.new(SPIDER_DUCK, 0.75)
	local enemyData2 = SpawnData.new(NUCLEAR_CAT, 1.0)
	sp1:insert(enemyData1):insert(enemyData2)
	bp:insert(sp1)
	RoomGeneration.insertGeneralDecorations(bp, rng)
	return bp
end

---@return Blueprint
-- sala de tesouro: a dupla de recompensas é criada ao popular a sala
function newTreasureRoom1(rng)
	local bp = Blueprint.new(TREASURE_ROOM, "Treasure Room", rgba8(255, 210, 74, 255))
	return bp
end
