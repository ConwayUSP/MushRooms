---@return Blueprint
-- Sala de Puzzle 1: contém nada
function newPuzzleRoom1()
	return Blueprint.new(PUZZLE_ROOM, "Test Puzzle Room", rgba8(12, 253, 255, 255))
end

---@return Blueprint
-- Sala de Puzzle 2: contém pilares
function newPuzzleRoom2()
	local bp = Blueprint.new(PUZZLE_ROOM, "Test Puzzle Room 2", rgba8(12, 253, 255, 255))
	local sp1 = SpawnPoint.new(vec(-150, 0))
	local sp2 = SpawnPoint.new(vec(150, 0))
	local pillarData1 = SpawnData.new(PILLAR, 1.0)
	local pillarData2 = SpawnData.new(PILLAR, 1.0)
	sp1:insert(pillarData1)
	sp2:insert(pillarData2)
	bp:insert(sp1):insert(sp2)
	return bp
end

---@return Blueprint
-- Sala de NPC 1: contém barrís e jarros
function newNPCRoom1()
	local bp = Blueprint.new(NPC_ROOM, "Test NPC Room", rgba8(120, 58, 242, 255))
	local sp1 = SpawnPoint.new(vec(250, 0))
	local globData = SpawnData.new(GLOB, 1.0)
	sp1:insert(globData)
	bp:insert(sp1)
	return bp
end

---@return Blueprint
-- Sala de Recurso 1: contém barrís e jarros
function newResourceRoom1()
	local bp = Blueprint.new(RESOURCE_ROOM, "Test Resource Room", rgba8(255, 248, 122, 255))
	local sp1 = SpawnPoint.new(vec(100, 0))
	local sp2 = SpawnPoint.new(vec(200, 0))
	local sp3 = SpawnPoint.new(vec(300, 0))
	local sp4 = SpawnPoint.new(vec(400, 0))
	local barrelData = SpawnData.new(BARREL, 0.5)
	local jarData = SpawnData.new(JAR, 1.0)
	sp1:insert(barrelData):insert(jarData)
	sp2:insert(barrelData):insert(jarData)
	sp3:insert(barrelData):insert(jarData)
	sp4:insert(barrelData):insert(jarData)
	bp:insert(sp1):insert(sp2):insert(sp3):insert(sp4)
	return bp
end

---@return Blueprint
-- Sala de Batalha 1: contém Gatos Nucleares e Patos Aranhas
function newBattleRoom1()
	local bp = Blueprint.new(BATTLE_ROOM, "Test Battle Room", rgba8(255, 255, 255, 255))
	local sp1 = SpawnPoint.new(vec(100, -100))
	local sp2 = SpawnPoint.new(vec(-100, 100))
	local sp3 = SpawnPoint.new(vec(100, 100))
	local sp4 = SpawnPoint.new(vec(-100, -100))
	local enemyData1 = SpawnData.new(SPIDER_DUCK, 0.5)
	local enemyData2 = SpawnData.new(NUCLEAR_CAT, 1.0)
	sp1:insert(enemyData1):insert(enemyData2)
	sp2:insert(enemyData1):insert(enemyData2)
	sp3:insert(enemyData1):insert(enemyData2)
	sp4:insert(enemyData1):insert(enemyData2)
	bp:insert(sp1):insert(sp2):insert(sp3):insert(sp4)
	return bp
end

---@return Blueprint
-- Sala de Boss 1: contém 1 Gato Nuclear ou 1 Pato Aranha no centro
function newBossRoom1()
	local bp = Blueprint.new(BOSS_ROOM, "Test Boss Room", rgba8(255, 41, 41, 255))
	local sp1 = SpawnPoint.new(vec(0, 0))
	local enemyData1 = SpawnData.new(SPIDER_DUCK, 0.5)
	local enemyData2 = SpawnData.new(NUCLEAR_CAT, 1.0)
	sp1:insert(enemyData1):insert(enemyData2)
	bp:insert(sp1)
	return bp
end

---@return Blueprint
-- Sala de Evento 1: contém barrís, jarros ou inimigos
function newEventRoom1()
	local bp = Blueprint.new(EVENT_ROOM, "Test Event Room", rgba8(104, 237, 102, 255))
	local sp1 = SpawnPoint.new(vec(0, 0))
	local barrelData = SpawnData.new(BARREL, 0.25)
	local jarData = SpawnData.new(JAR, 0.5)
	local enemyData1 = SpawnData.new(SPIDER_DUCK, 0.75)
	local enemyData2 = SpawnData.new(NUCLEAR_CAT, 1.0)
	sp1:insert(barrelData):insert(jarData):insert(enemyData1):insert(enemyData2)
	bp:insert(sp1)
	return bp
end
