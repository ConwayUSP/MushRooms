----------------------------------------
-- Importações de Módulos
----------------------------------------

require("modules.constructors.puzzles.grid")
require("modules.utils.roomgeneration")

---@param rng RNG
-- Tipos de sala x quantidade
-- - Sala de puzzle: 3
-- - Sala de NPC: 5
-- - Sala de recurso: 12
-- - Sala de combate: 15
-- - Sala de boss: 1
-- - Sala de evento: 1
-- - Sala de tesouro: 1

---@return Blueprint
-- sala de puzzle pequena 4x4
function newSmallPuzzleRoom(rng)
	local bp = Blueprint.new(PUZZLE_ROOM, "Puzzle Room 4x4", rgba8(12, 253, 255, 255))
	local gridSize = vec(4, 4)
	local decorationMargin = 100
	local excludedAreas = { GridPuzzle.exclusionArea(gridSize, decorationMargin) }
	RoomGeneration.insertGeneralDecorations(bp, rng, excludedAreas)

	local settings = {
		size = gridSize,
		centerSize = vec(2, 2),
		pins = GridPuzzle.fullPerimeterPins(gridSize),
		stones = {
			{ id = "stone-up-left", cell = vec(1, 1), direction = vec(1, 1) },
			{ id = "stone-up-right", cell = vec(4, 1), direction = vec(-1, 1) },
			{ id = "stone-down-left", cell = vec(1, 4), direction = vec(1, -1) },
			{ id = "stone-down-right", cell = vec(4, 4), direction = vec(-1, -1) },
		},
	}
	local rewards = { newRainbowDash }
	bp:addPuzzle(GridPuzzle.new, settings, rewards)

	return bp
end

---@param rng RNG
---@return Blueprint
-- sala de puzzle média 6x6
function newMediumPuzzleRoom(rng)
	local bp = Blueprint.new(PUZZLE_ROOM, "Puzzle Room 6x6", rgba8(12, 253, 255, 255))
	local gridSize = vec(6, 6)
	local decorationMargin = 100
	local excludedAreas = { GridPuzzle.exclusionArea(gridSize, decorationMargin) }
	RoomGeneration.insertGeneralDecorations(bp, rng, excludedAreas)

	local settings = {
		size = gridSize,
		centerSize = vec(2, 2),
		pins = GridPuzzle.fullPerimeterPins(gridSize),
		stones = {
			{ id = "stone-up-left", cell = vec(1, 2), direction = vec(1, 1) },
			{ id = "stone-up-right", cell = vec(6, 1), direction = vec(-1, 1) },
			{ id = "stone-down-left", cell = vec(2, 6), direction = vec(1, -1) },
			{ id = "stone-down-right", cell = vec(5, 5), direction = vec(-1, -1) },
		},
	}
	local rewards = { newRainbowDash }
	bp:addPuzzle(GridPuzzle.new, settings, rewards)

	return bp
end

---@param rng RNG
---@return Blueprint
-- sala de puzzle GRANDE 8x8
function newBigPuzzleRoom(rng)
	local bp = Blueprint.new(PUZZLE_ROOM, "Puzzle Room 8x8", rgba8(12, 253, 255, 255))
	local gridSize = vec(8, 8)
	local decorationMargin = 100
	local excludedAreas = { GridPuzzle.exclusionArea(gridSize, decorationMargin) }
	RoomGeneration.insertGeneralDecorations(bp, rng, excludedAreas)

	local settings = {
		size = gridSize,
		centerSize = vec(2, 2),
		pins = GridPuzzle.fullPerimeterPins(gridSize),
		stones = {
			{ id = "stone-up-left", cell = vec(2, 2), direction = vec(1, 1) },
			{ id = "stone-up-right", cell = vec(7, 3), direction = vec(-1, 1) },
			{ id = "stone-down-left", cell = vec(1, 7), direction = vec(1, -1) },
			{ id = "stone-down-right", cell = vec(8, 8), direction = vec(-1, -1) },
		},
	}
	local rewards = { newRainbowDash }
	bp:addPuzzle(GridPuzzle.new, settings, rewards)

	return bp
end

---@return Blueprint
-- sala de NPC 1: contém Tenkar, Shoum-Shoum e Biguiri perto da porta leste
function newNPCRoomEast(rng)
	local bp = Blueprint.new(NPC_ROOM, "NPC Room East Side", rgba8(120, 58, 242, 255))
	local sp1 = SpawnPoint.new(vec(250, 0))
	local tenkarData = SpawnData.new(TENKAR, 0.45)
	local shoumShoumData = SpawnData.new(SHOUM_SHOUM, 0.9)
	local biguiriData = SpawnData.new(BIGUIRI, 1.0)
	local barrelData = SpawnData.new(BARREL, 0.2)
	sp1:insert(tenkarData):insert(shoumShoumData):insert(biguiriData)
	bp:insert(sp1)
	RoomGeneration.insertGeneralDecorations(bp, rng)
	return bp
end

---@return Blueprint
-- sala de NPC 2: contém Tenkar, Shoum-Shoum e Biguiri perto da porta oeste
function newNPCRoomWest(rng)
	local bp = Blueprint.new(NPC_ROOM, "NPC Room West Side", rgba8(120, 58, 242, 255))
	local sp1 = SpawnPoint.new(vec(-250, 0))
	local tenkarData = SpawnData.new(TENKAR, 0.45)
	local shoumShoumData = SpawnData.new(SHOUM_SHOUM, 0.9)
	local biguiriData = SpawnData.new(BIGUIRI, 1.0)
	local barrelData = SpawnData.new(BARREL, 0.2)
	sp1:insert(tenkarData):insert(shoumShoumData):insert(biguiriData)
	bp:insert(sp1)
	RoomGeneration.insertGeneralDecorations(bp, rng)
	return bp
end

---@return Blueprint
-- sala de NPC 3: contém Tenkar, Shoum-Shoum e Biguiri perto da porta norte
function newNPCRoomNorth(rng)
	local bp = Blueprint.new(NPC_ROOM, "NPC Room North Side", rgba8(120, 58, 242, 255))
	local sp1 = SpawnPoint.new(vec(0, -250))
	local tenkarData = SpawnData.new(TENKAR, 0.45)
	local shoumShoumData = SpawnData.new(SHOUM_SHOUM, 0.9)
	local biguiriData = SpawnData.new(BIGUIRI, 1.0)
	local barrelData = SpawnData.new(BARREL, 0.2)
	sp1:insert(tenkarData):insert(shoumShoumData):insert(biguiriData)
	bp:insert(sp1)
	RoomGeneration.insertGeneralDecorations(bp, rng)
	return bp
end

---@return Blueprint
-- sala de NPC 4: contém Tenkar, Shoum-Shoum e Biguiri perto da porta sul
function newNPCRoomSouth(rng)
	local bp = Blueprint.new(NPC_ROOM, "NPC Room South Side", rgba8(120, 58, 242, 255))
	local sp1 = SpawnPoint.new(vec(0, 250))
	local tenkarData = SpawnData.new(TENKAR, 0.45)
	local shoumShoumData = SpawnData.new(SHOUM_SHOUM, 0.9)
	local biguiriData = SpawnData.new(BIGUIRI, 1.0)
	local barrelData = SpawnData.new(BARREL, 0.2)
	sp1:insert(tenkarData):insert(shoumShoumData):insert(biguiriData)
	bp:insert(sp1)
	RoomGeneration.insertGeneralDecorations(bp, rng)
	return bp
end

---@return Blueprint
-- sala de NPC 5: contém Tenkar, Shoum-Shoum e Biguiri perto do centro da sala
function newNPCRoomMiddle(rng)
	local bp = Blueprint.new(NPC_ROOM, "NPC Room Middle Side", rgba8(120, 58, 242, 255))
	local sp1 = SpawnPoint.new(vec(0, 0))
	local tenkarData = SpawnData.new(TENKAR, 0.45)
	local shoumShoumData = SpawnData.new(SHOUM_SHOUM, 0.9)
	local biguiriData = SpawnData.new(BIGUIRI, 1.0)
	local barrelData = SpawnData.new(BARREL, 0.2)
	sp1:insert(tenkarData):insert(shoumShoumData):insert(biguiriData)
	bp:insert(sp1)
	RoomGeneration.insertGeneralDecorations(bp, rng)
	return bp
end

---@return Blueprint
-- sala de recurso 1: contém 2 fontes de recurso distintas
function new2SpotsResourceRoom(rng)
	local bp = Blueprint.new(RESOURCE_ROOM, "Resource Room 2 Random Resources", rgba8(255, 248, 122, 255))
	local sp1 = SpawnPoint.new(vec(100, 500))
	local sp2 = SpawnPoint.new(vec(200, 0))

	local bonesData = SpawnData.new(BONE_PILE, 0.333)
	local rocksData = SpawnData.new(DESTRUCTIBLE_ROCK, 0.666)
	local coalData = SpawnData.new(COAL_ALTAR, 1.0)
	sp1:insert(bonesData):insert(rocksData):insert(coalData)
	sp2:insert(bonesData):insert(rocksData):insert(coalData)
	
	bp:insert(sp1):insert(sp2)
	RoomGeneration.insertGeneralDecorations(bp, rng)
	return bp
end

---@return Blueprint
-- sala de recurso 2: contém 3 fontes de recurso distintas
function new3SpotsResourceRoom(rng)
	local bp = Blueprint.new(RESOURCE_ROOM, "Resource Room 3 Random Resources", rgba8(255, 248, 122, 255))
	local sp1 = SpawnPoint.new(vec(100, 500))
	local sp2 = SpawnPoint.new(vec(200, 0))
	local sp3 = SpawnPoint.new(vec(300, -200))

	local bonesData = SpawnData.new(BONE_PILE, 0.333)
	local rocksData = SpawnData.new(DESTRUCTIBLE_ROCK, 0.666)
	local coalData = SpawnData.new(COAL_ALTAR, 1.0)
	sp1:insert(bonesData):insert(rocksData):insert(coalData)
	sp2:insert(bonesData):insert(rocksData):insert(coalData)
	sp3:insert(bonesData):insert(rocksData):insert(coalData)

	bp:insert(sp1):insert(sp2):insert(sp3)
	RoomGeneration.insertGeneralDecorations(bp, rng)
	return bp
end

---@return Blueprint
-- sala de recurso 3: contém 4 fontes de recurso distintas
function new4SpotsResourceRoom(rng)
	local bp = Blueprint.new(RESOURCE_ROOM, "Resource Room 4 Random Resources", rgba8(255, 248, 122, 255))
	local sp1 = SpawnPoint.new(vec(100, 500))
	local sp2 = SpawnPoint.new(vec(200, 0))
	local sp3 = SpawnPoint.new(vec(300, -200))
	local sp4 = SpawnPoint.new(vec(500, -200))

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
-- sala de recurso 4: contém 2 fontes de recurso de osso
function new2BonesSpotsResourceRoom(rng)
	local bp = Blueprint.new(RESOURCE_ROOM, "Resource Room 2 Bones Piles", rgba8(255, 248, 122, 255))
	local sp1 = SpawnPoint.new(vec(100, 500))
	local sp2 = SpawnPoint.new(vec(200, 0))

	local bonesData = SpawnData.new(BONE_PILE, 1.0)
	sp1:insert(bonesData)
	sp2:insert(bonesData)
	
	bp:insert(sp1):insert(sp2)
	RoomGeneration.insertGeneralDecorations(bp, rng)
	return bp
end

---@return Blueprint
-- sala de recurso 5: contém 3 fontes de recurso de osso
function new3BonesSpotsResourceRoom(rng)
	local bp = Blueprint.new(RESOURCE_ROOM, "Resource Room 3 Bones Piles", rgba8(255, 248, 122, 255))
	local sp1 = SpawnPoint.new(vec(100, 500))
	local sp2 = SpawnPoint.new(vec(200, 0))
	local sp3 = SpawnPoint.new(vec(300, -200))

	local bonesData = SpawnData.new(BONE_PILE, 1.0)
	sp1:insert(bonesData)
	sp2:insert(bonesData)
	sp3:insert(bonesData)

	bp:insert(sp1):insert(sp2):insert(sp3)
	RoomGeneration.insertGeneralDecorations(bp, rng)
	return bp
end

---@return Blueprint
-- sala de recurso 6: contém 4 fontes de recurso de osso
function new4BonesSpotsResourceRoom(rng)
	local bp = Blueprint.new(RESOURCE_ROOM, "Resource Room 4 Bones Piles", rgba8(255, 248, 122, 255))
	local sp1 = SpawnPoint.new(vec(100, 500))
	local sp2 = SpawnPoint.new(vec(200, 0))
	local sp3 = SpawnPoint.new(vec(300, -200))
	local sp4 = SpawnPoint.new(vec(500, -200))

	local bonesData = SpawnData.new(BONE_PILE, 1.0)
	sp1:insert(bonesData)
	sp2:insert(bonesData)
	sp3:insert(bonesData)
	sp4:insert(bonesData)
	
	bp:insert(sp1):insert(sp2):insert(sp3):insert(sp4)
	RoomGeneration.insertGeneralDecorations(bp, rng)
	return bp
end

---@return Blueprint
-- sala de recurso 7: contém 2 fontes de recurso de pedra
function new2RocksSpotsResourceRoom(rng)
	local bp = Blueprint.new(RESOURCE_ROOM, "Resource Room 2 Rocks Piles", rgba8(255, 248, 122, 255))
	local sp1 = SpawnPoint.new(vec(100, 500))
	local sp2 = SpawnPoint.new(vec(200, 0))

	local rocksData = SpawnData.new(DESTRUCTIBLE_ROCK, 1.0)
	sp1:insert(rocksData)
	sp2:insert(rocksData)
	
	bp:insert(sp1):insert(sp2)
	RoomGeneration.insertGeneralDecorations(bp, rng)
	return bp
end

---@return Blueprint
-- sala de recurso 8: contém 3 fontes de recurso de pedra
function new3RocksSpotsResourceRoom(rng)
	local bp = Blueprint.new(RESOURCE_ROOM, "Resource Room 3 Rocks Piles", rgba8(255, 248, 122, 255))
	local sp1 = SpawnPoint.new(vec(100, 500))
	local sp2 = SpawnPoint.new(vec(200, 0))
	local sp3 = SpawnPoint.new(vec(300, -200))

	local rocksData = SpawnData.new(DESTRUCTIBLE_ROCK, 1.0)
	sp1:insert(rocksData)
	sp2:insert(rocksData)
	sp3:insert(rocksData)

	bp:insert(sp1):insert(sp2):insert(sp3)
	RoomGeneration.insertGeneralDecorations(bp, rng)
	return bp
end

---@return Blueprint
-- sala de recurso 9: contém 4 fontes de recurso de pedra
function new4RocksSpotsResourceRoom(rng)
	local bp = Blueprint.new(RESOURCE_ROOM, "Resource Room 4 Rocks Piles", rgba8(255, 248, 122, 255))
	local sp1 = SpawnPoint.new(vec(100, 500))
	local sp2 = SpawnPoint.new(vec(200, 0))
	local sp3 = SpawnPoint.new(vec(300, -200))
	local sp4 = SpawnPoint.new(vec(500, -200))

	local rocksData = SpawnData.new(DESTRUCTIBLE_ROCK, 1.0)
	sp1:insert(rocksData)
	sp2:insert(rocksData)
	sp3:insert(rocksData)
	sp4:insert(rocksData)
	
	bp:insert(sp1):insert(sp2):insert(sp3):insert(sp4)
	RoomGeneration.insertGeneralDecorations(bp, rng)
	return bp
end

---@return Blueprint
-- sala de recurso 10: contém 2 fontes de recurso de carvão
function new2CoalSpotsResourceRoom(rng)
	local bp = Blueprint.new(RESOURCE_ROOM, "Resource Room 2 Coal Piles", rgba8(255, 248, 122, 255))
	local sp1 = SpawnPoint.new(vec(100, 500))
	local sp2 = SpawnPoint.new(vec(200, 0))

	local coalData = SpawnData.new(COAL_ALTAR, 1.0)
	sp1:insert(coalData)
	sp2:insert(coalData)
	
	bp:insert(sp1):insert(sp2)
	RoomGeneration.insertGeneralDecorations(bp, rng)
	return bp
end

---@return Blueprint
-- sala de recurso 11: contém 3 fontes de recurso de carvão
function new3CoalSpotsResourceRoom(rng)
	local bp = Blueprint.new(RESOURCE_ROOM, "Resource Room 3 Coal Piles", rgba8(255, 248, 122, 255))
	local sp1 = SpawnPoint.new(vec(100, 500))
	local sp2 = SpawnPoint.new(vec(200, 0))
	local sp3 = SpawnPoint.new(vec(300, -200))

	local coalData = SpawnData.new(COAL_ALTAR, 1.0)
	sp1:insert(coalData)
	sp2:insert(coalData)
	sp3:insert(coalData)

	bp:insert(sp1):insert(sp2):insert(sp3)
	RoomGeneration.insertGeneralDecorations(bp, rng)
	return bp
end

---@return Blueprint
-- sala de recurso 12: contém 4 fontes de recurso de carvão
function new4CoalSpotsResourceRoom(rng)
	local bp = Blueprint.new(RESOURCE_ROOM, "Resource Room 4 Coal Piles", rgba8(255, 248, 122, 255))
	local sp1 = SpawnPoint.new(vec(100, 500))
	local sp2 = SpawnPoint.new(vec(200, 0))
	local sp3 = SpawnPoint.new(vec(300, -200))
	local sp4 = SpawnPoint.new(vec(500, -200))

	local coalData = SpawnData.new(COAL_ALTAR, 1.0)
	sp1:insert(coalData)
	sp2:insert(coalData)
	sp3:insert(coalData)
	sp4:insert(coalData)
	
	bp:insert(sp1):insert(sp2):insert(sp3):insert(sp4)
	RoomGeneration.insertGeneralDecorations(bp, rng)
	return bp
end

---@return Blueprint
-- sala de batalha 1: 3 inimigos aleatórios
function new3SpotsBattleRoom(rng)
	local bp = Blueprint.new(BATTLE_ROOM, "Battle Room 3 Random Enemies", rgba8(255, 255, 255, 255))
	local sp1 = SpawnPoint.new(vec(0, -250))
	local sp2 = SpawnPoint.new(vec(-200, 200))
	local sp3 = SpawnPoint.new(vec(200, 200))
	local enemyData1 = SpawnData.new(SPIDER_DUCK, 0.2)
	local enemyData2 = SpawnData.new(NUCLEAR_CAT, 0.4)
	local enemyData3 = SpawnData.new(ROLLING_STONE, 0.7)
	local enemyData4 = SpawnData.new(DEMON_BALL, 1.0)
	sp1:insert(enemyData1):insert(enemyData2):insert(enemyData3):insert(enemyData4)
	sp2:insert(enemyData1):insert(enemyData2):insert(enemyData3):insert(enemyData4)
	sp3:insert(enemyData1):insert(enemyData2):insert(enemyData3):insert(enemyData4)
	bp:insert(sp1):insert(sp2):insert(sp3)
	RoomGeneration.insertGeneralDecorations(bp, rng)
	return bp
end

---@return Blueprint
-- sala de batalha 2: 4 inimigos aleatórios
function new4SpotsBattleRoom(rng)
	local bp = Blueprint.new(BATTLE_ROOM, "Battle Room 4 Random Enemies", rgba8(255, 255, 255, 255))
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
-- sala de batalha 3: 5 inimigos aleatórios
function new5SpotsBattleRoom(rng)
	local bp = Blueprint.new(BATTLE_ROOM, "Battle Room 5 Random Enemies", rgba8(255, 255, 255, 255))
	local sp1 = SpawnPoint.new(vec(200, -200))
	local sp2 = SpawnPoint.new(vec(-200, 200))
	local sp3 = SpawnPoint.new(vec(200, 200))
	local sp4 = SpawnPoint.new(vec(-200, -200))
	local sp5 = SpawnPoint.new(vec(0, 0))
	local enemyData1 = SpawnData.new(SPIDER_DUCK, 0.2)
	local enemyData2 = SpawnData.new(NUCLEAR_CAT, 0.4)
	local enemyData3 = SpawnData.new(ROLLING_STONE, 0.7)
	local enemyData4 = SpawnData.new(DEMON_BALL, 1.0)
	sp1:insert(enemyData1):insert(enemyData2):insert(enemyData3):insert(enemyData4)
	sp2:insert(enemyData1):insert(enemyData2):insert(enemyData3):insert(enemyData4)
	sp3:insert(enemyData1):insert(enemyData2):insert(enemyData3):insert(enemyData4)
	sp4:insert(enemyData1):insert(enemyData2):insert(enemyData3):insert(enemyData4)
	sp5:insert(enemyData1):insert(enemyData2):insert(enemyData3):insert(enemyData4)
	bp:insert(sp1):insert(sp2):insert(sp3):insert(sp4):insert(sp5)
	RoomGeneration.insertGeneralDecorations(bp, rng)
	return bp
end

---@return Blueprint
-- sala de batalha 4: 3 patos-aranha
function new3SpiderDucksBattleRoom(rng)
	local bp = Blueprint.new(BATTLE_ROOM, "Battle Room 3 Spider Ducks", rgba8(255, 255, 255, 255))
	local sp1 = SpawnPoint.new(vec(0, -250))
	local sp2 = SpawnPoint.new(vec(-200, 200))
	local sp3 = SpawnPoint.new(vec(200, 200))
	local enemyData1 = SpawnData.new(SPIDER_DUCK, 1.0)
	-- local enemyData2 = SpawnData.new(NUCLEAR_CAT, 0.4)
	-- local enemyData3 = SpawnData.new(ROLLING_STONE, 0.7)
	-- local enemyData4 = SpawnData.new(DEMON_BALL, 1.0)
	sp1:insert(enemyData1)
	sp2:insert(enemyData1)
	sp3:insert(enemyData1)
	bp:insert(sp1):insert(sp2):insert(sp3)
	RoomGeneration.insertGeneralDecorations(bp, rng)
	return bp
end

---@return Blueprint
-- sala de batalha 5: 4 patos-aranha
function new4SpiderDucksBattleRoom(rng)
	local bp = Blueprint.new(BATTLE_ROOM, "Battle Room 4 Spider Ducks", rgba8(255, 255, 255, 255))
	local sp1 = SpawnPoint.new(vec(200, -200))
	local sp2 = SpawnPoint.new(vec(-200, 200))
	local sp3 = SpawnPoint.new(vec(200, 200))
	local sp4 = SpawnPoint.new(vec(-200, -200))
	local enemyData1 = SpawnData.new(SPIDER_DUCK, 1.0)
	sp1:insert(enemyData1)
	sp2:insert(enemyData1)
	sp3:insert(enemyData1)
	sp4:insert(enemyData1)
	bp:insert(sp1):insert(sp2):insert(sp3):insert(sp4)
	RoomGeneration.insertGeneralDecorations(bp, rng)
	return bp
end

---@return Blueprint
-- sala de batalha 6: 5 patos-aranha
function new5SpiderDucksBattleRoom(rng)
	local bp = Blueprint.new(BATTLE_ROOM, "Battle Room 5 Spider Ducks", rgba8(255, 255, 255, 255))
	local sp1 = SpawnPoint.new(vec(200, -200))
	local sp2 = SpawnPoint.new(vec(-200, 200))
	local sp3 = SpawnPoint.new(vec(200, 200))
	local sp4 = SpawnPoint.new(vec(-200, -200))
	local sp5 = SpawnPoint.new(vec(0, 0))
	local enemyData1 = SpawnData.new(SPIDER_DUCK, 1.0)
	sp1:insert(enemyData1)
	sp2:insert(enemyData1)
	sp3:insert(enemyData1)
	sp4:insert(enemyData1)
	sp5:insert(enemyData1)
	bp:insert(sp1):insert(sp2):insert(sp3):insert(sp4):insert(sp5)
	RoomGeneration.insertGeneralDecorations(bp, rng)
	return bp
end

---@return Blueprint
-- sala de batalha 7: 3 gatos nucleares
function new3NuclearCatsBattleRoom(rng)
	local bp = Blueprint.new(BATTLE_ROOM, "Battle Room 3 Nuclear Cats", rgba8(255, 255, 255, 255))
	local sp1 = SpawnPoint.new(vec(0, -250))
	local sp2 = SpawnPoint.new(vec(-200, 200))
	local sp3 = SpawnPoint.new(vec(200, 200))
	local enemyData1 = SpawnData.new(NUCLEAR_CAT, 1.0)
	-- local enemyData2 = SpawnData.new(NUCLEAR_CAT, 0.4)
	-- local enemyData3 = SpawnData.new(ROLLING_STONE, 0.7)
	-- local enemyData4 = SpawnData.new(DEMON_BALL, 1.0)
	sp1:insert(enemyData1)
	sp2:insert(enemyData1)
	sp3:insert(enemyData1)
	bp:insert(sp1):insert(sp2):insert(sp3)
	RoomGeneration.insertGeneralDecorations(bp, rng)
	return bp
end

---@return Blueprint
-- sala de batalha 8: 4 gatos nucleares
function new4NuclearCatsBattleRoom(rng)
	local bp = Blueprint.new(BATTLE_ROOM, "Battle Room 4 Nuclear Cats", rgba8(255, 255, 255, 255))
	local sp1 = SpawnPoint.new(vec(200, -200))
	local sp2 = SpawnPoint.new(vec(-200, 200))
	local sp3 = SpawnPoint.new(vec(200, 200))
	local sp4 = SpawnPoint.new(vec(-200, -200))
	local enemyData1 = SpawnData.new(NUCLEAR_CAT, 1.0)
	sp1:insert(enemyData1)
	sp2:insert(enemyData1)
	sp3:insert(enemyData1)
	sp4:insert(enemyData1)
	bp:insert(sp1):insert(sp2):insert(sp3):insert(sp4)
	RoomGeneration.insertGeneralDecorations(bp, rng)
	return bp
end

---@return Blueprint
-- sala de batalha 9: 5 gatos nucleares
function new5NuclearCatsBattleRoom(rng)
	local bp = Blueprint.new(BATTLE_ROOM, "Battle Room 5 Nuclear Cats", rgba8(255, 255, 255, 255))
	local sp1 = SpawnPoint.new(vec(200, -200))
	local sp2 = SpawnPoint.new(vec(-200, 200))
	local sp3 = SpawnPoint.new(vec(200, 200))
	local sp4 = SpawnPoint.new(vec(-200, -200))
	local sp5 = SpawnPoint.new(vec(0, 0))
	local enemyData1 = SpawnData.new(NUCLEAR_CAT, 1.0)
	sp1:insert(enemyData1)
	sp2:insert(enemyData1)
	sp3:insert(enemyData1)
	sp4:insert(enemyData1)
	sp5:insert(enemyData1)
	bp:insert(sp1):insert(sp2):insert(sp3):insert(sp4):insert(sp5)
	RoomGeneration.insertGeneralDecorations(bp, rng)
	return bp
end

---@return Blueprint
-- sala de batalha 10: 3 pedras rolantes
function new3RollingStonesBattleRoom(rng)
	local bp = Blueprint.new(BATTLE_ROOM, "Battle Room 3 Rolling Stones", rgba8(255, 255, 255, 255))
	local sp1 = SpawnPoint.new(vec(0, -250))
	local sp2 = SpawnPoint.new(vec(-200, 200))
	local sp3 = SpawnPoint.new(vec(200, 200))
	local enemyData1 = SpawnData.new(ROLLING_STONE, 1.0)
	-- local enemyData2 = SpawnData.new(NUCLEAR_CAT, 0.4)
	-- local enemyData3 = SpawnData.new(ROLLING_STONE, 0.7)
	-- local enemyData4 = SpawnData.new(DEMON_BALL, 1.0)
	sp1:insert(enemyData1)
	sp2:insert(enemyData1)
	sp3:insert(enemyData1)
	bp:insert(sp1):insert(sp2):insert(sp3)
	RoomGeneration.insertGeneralDecorations(bp, rng)
	return bp
end

---@return Blueprint
-- sala de batalha 11: 4 pedras rolantes
function new4RollingStonesBattleRoom(rng)
	local bp = Blueprint.new(BATTLE_ROOM, "Battle Room 4 Rolling Stones", rgba8(255, 255, 255, 255))
	local sp1 = SpawnPoint.new(vec(200, -200))
	local sp2 = SpawnPoint.new(vec(-200, 200))
	local sp3 = SpawnPoint.new(vec(200, 200))
	local sp4 = SpawnPoint.new(vec(-200, -200))
	local enemyData1 = SpawnData.new(ROLLING_STONE, 1.0)
	sp1:insert(enemyData1)
	sp2:insert(enemyData1)
	sp3:insert(enemyData1)
	sp4:insert(enemyData1)
	bp:insert(sp1):insert(sp2):insert(sp3):insert(sp4)
	RoomGeneration.insertGeneralDecorations(bp, rng)
	return bp
end

---@return Blueprint
-- sala de batalha 12: 5 pedras rolantes
function new5RollingStonesBattleRoom(rng)
	local bp = Blueprint.new(BATTLE_ROOM, "Battle Room 5 Rolling Stones", rgba8(255, 255, 255, 255))
	local sp1 = SpawnPoint.new(vec(200, -200))
	local sp2 = SpawnPoint.new(vec(-200, 200))
	local sp3 = SpawnPoint.new(vec(200, 200))
	local sp4 = SpawnPoint.new(vec(-200, -200))
	local sp5 = SpawnPoint.new(vec(0, 0))
	local enemyData1 = SpawnData.new(ROLLING_STONE, 1.0)
	sp1:insert(enemyData1)
	sp2:insert(enemyData1)
	sp3:insert(enemyData1)
	sp4:insert(enemyData1)
	sp5:insert(enemyData1)
	bp:insert(sp1):insert(sp2):insert(sp3):insert(sp4):insert(sp5)
	RoomGeneration.insertGeneralDecorations(bp, rng)
	return bp
end

---@return Blueprint
-- sala de batalha 13: 3 bolas demoniácas
function new3DemonBallsBattleRoom(rng)
	local bp = Blueprint.new(BATTLE_ROOM, "Battle Room 3 Demon Balls", rgba8(255, 255, 255, 255))
	local sp1 = SpawnPoint.new(vec(0, -250))
	local sp2 = SpawnPoint.new(vec(-200, 200))
	local sp3 = SpawnPoint.new(vec(200, 200))
	local enemyData1 = SpawnData.new(DEMON_BALL, 1.0)
	sp1:insert(enemyData1)
	sp2:insert(enemyData1)
	sp3:insert(enemyData1)
	bp:insert(sp1):insert(sp2):insert(sp3)
	RoomGeneration.insertGeneralDecorations(bp, rng)
	return bp
end

---@return Blueprint
-- sala de batalha 14: 4 bolas demoniácas
function new4DemonBallsBattleRoom(rng)
	local bp = Blueprint.new(BATTLE_ROOM, "Battle Room 4 Demon Balls", rgba8(255, 255, 255, 255))
	local sp1 = SpawnPoint.new(vec(200, -200))
	local sp2 = SpawnPoint.new(vec(-200, 200))
	local sp3 = SpawnPoint.new(vec(200, 200))
	local sp4 = SpawnPoint.new(vec(-200, -200))
	local enemyData1 = SpawnData.new(DEMON_BALL, 1.0)
	sp1:insert(enemyData1)
	sp2:insert(enemyData1)
	sp3:insert(enemyData1)
	sp4:insert(enemyData1)
	bp:insert(sp1):insert(sp2):insert(sp3):insert(sp4)
	RoomGeneration.insertGeneralDecorations(bp, rng)
	return bp
end

---@return Blueprint
-- sala de batalha 12: 5 bolas demoniácas
function new5DemonBallsBattleRoom(rng)
	local bp = Blueprint.new(BATTLE_ROOM, "Battle Room 5 Demon Balls", rgba8(255, 255, 255, 255))
	local sp1 = SpawnPoint.new(vec(200, -200))
	local sp2 = SpawnPoint.new(vec(-200, 200))
	local sp3 = SpawnPoint.new(vec(200, 200))
	local sp4 = SpawnPoint.new(vec(-200, -200))
	local sp5 = SpawnPoint.new(vec(0, -250))
	local sp6 = SpawnPoint.new(vec(0, 250))
	local demonData = SpawnData.new(DEMON_BALL, 1.0)
	sp1:insert(demonData)
	sp2:insert(demonData)
	sp3:insert(demonData)
	sp4:insert(demonData)
	sp5:insert(demonData)
	sp6:insert(demonData)
	bp:insert(sp1):insert(sp2):insert(sp3):insert(sp4):insert(sp5):insert(sp6)
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
function newAncientMoaiBossRoom(rng)
	local bp = Blueprint.new(BOSS_ROOM, "Ancient Moai Boss Room", rgba8(180, 120, 60, 255))
	local sp1 = SpawnPoint.new(vec(0, 0))
	local enemyData1 = SpawnData.new(ANCIENT_MOAI, 1.0, true)
	sp1:insert(enemyData1)
	bp:insert(sp1)
	local excludedArea = { { min = vec(-150, -150), max = vec(150, 150) } }
	RoomGeneration.insertGeneralDecorations(bp, rng, excludedArea)
	return bp
end

---@return Blueprint
-- sala de evento 1: contém símbolos dos setores de pedra
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
	local excludedAreas = { { min = vec(-200, -100), max = vec(-100, 100) }, { min = vec(100, -100), max = vec(200, 100) } }
	RoomGeneration.insertGeneralDecorations(bp, rng, excludedAreas)
	return bp
end

---@return Blueprint
-- sala inicial do primeiro andar
function newInitialRoom1(rng)
	local bp = Blueprint.new(INITIAL_ROOM, "Initial Room", rgba8(255, 255, 255, 255))
	RoomGeneration.insertGeneralDecorations(bp, rng)
	-- TODO: botar decoração bonitinha aqui

	return bp
end
