---@return Blueprint
-- Sala de Puzzle 1: contém nada de mais
function newPuzzleRoom1()
	local bp = Blueprint.new(PUZZLE_ROOM, "Test Puzzle Room", rgba8(12, 253, 255, 255))
	insertGeneralDecorations(bp)
	return bp
end

---@return Blueprint
-- Sala de Puzzle 2: contém uma vela (?)
function newPuzzleRoom2()
	local bp = Blueprint.new(PUZZLE_ROOM, "Test Puzzle Room 2", rgba8(12, 253, 255, 255))
	local spCenter = SpawnPoint.new(vec(0, 0))
	local candleData = SpawnData.new(CANDLE, 1.0)
	spCenter:insert(candleData)
	bp:insert(spCenter)
	insertGeneralDecorations(bp)
	return bp
end

---@return Blueprint
-- Sala de NPC 1: contém barrís e jarros
function newNPCRoom1()
	local bp = Blueprint.new(NPC_ROOM, "Test NPC Room", rgba8(120, 58, 242, 255))
	local sp1 = SpawnPoint.new(vec(250, 0))
	local tenkarData = SpawnData.new(TENKAR, 0.5)
	local shoumShoumData = SpawnData.new(SHOUM_SHOUM, 1.0)
	sp1:insert(tenkarData):insert(shoumShoumData)
	bp:insert(sp1)
	insertGeneralDecorations(bp)
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
	insertGeneralDecorations(bp)
	return bp
end

---@return Blueprint
-- Sala de Recurso 2: contém grama alta pra caralho
function newResourceRoom2()
	local bp = Blueprint.new(RESOURCE_ROOM, "Test Resource Room 2", rgba8(255, 248, 122, 255))
	local grassData = SpawnData.new(TALL_GRASS, 1.0)
	for i = 1, 4 do
		for j = 1, 4 do
			local sp = SpawnPoint.new(vec(i * 60 - 120 - j, j * 30 - 80 + i))
			sp:insert(grassData)
			bp:insert(sp)
		end
	end
	insertGeneralDecorations(bp)
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
	insertGeneralDecorations(bp)
	return bp
end

---@return Blueprint
-- Sala de Boss 1: contém 1 Gato Nuclear ou 1 Pato Aranha no centro
function newBossRoom1()
	local bp = Blueprint.new(BOSS_ROOM, "Test Boss Room", rgba8(255, 41, 41, 255))
	local sp1 = SpawnPoint.new(vec(0, 0))
	local enemyData1 = SpawnData.new(SPIDER_DUCK_BOSS, 1.0)
	sp1:insert(enemyData1)
	bp:insert(sp1)
	insertGeneralDecorations(bp)
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
	insertGeneralDecorations(bp)
	return bp
end

----------------------------------------
-- Facilitadores
----------------------------------------

---@param blueprint any
-- insere algumas decorações gerais para facilitar nossa vida
function insertGeneralDecorations(blueprint)
	-- !WARNING: essa função é uma generalização bem forte, é recomendado
	-- fazermos uma personalização mais fina das salas depois
	insertPossiblePillars(blueprint, 0.6)
	insertRandomly(blueprint, NEGATIVE, 20)
	insertRandomly(blueprint, MOSS, 18)
	insertRandomly(blueprint, CRACKS, 16)
	insertRandomly(blueprint, SKELETON, 4)
	insertIntoGrid(blueprint, RUBBLE, 0.4, 6, true)
end

---@param blueprint Blueprint
---@param type EntityReg
---@param amount number
---comment
function insertRandomly(blueprint, type, amount)
	for i = 1, amount do
		local x = math.random(-(Room.stdDim.width / 2) + 20, Room.stdDim.width - 20)
		local y = math.random(-(Room.stdDim.height / 2) + 20, Room.stdDim.height - 20)
		local pos = vec(x, y)
		local sp = SpawnPoint.new(pos)
		local sd = SpawnData.new(type, 1.0)
		sp:insert(sd)
		blueprint:insert(sp)
	end
end

---@param blueprint Blueprint
---@param type EntityReg
---@param density number
---@param gridDim number
---@param scapeGrid boolean
-- insere na blueprint aleatoriamente de acordo com uma grade de tamanho ajustável
function insertIntoGrid(blueprint, type, density, gridDim, scapeGrid)
	for i = 0, gridDim do
		for j = 0, gridDim do
			local ox, oy = 0, 0
			local scapeFactor = Room.stdDim.width / (gridDim * 3)
			if scapeGrid then
				ox = math.random(-scapeFactor, scapeFactor)
				oy = math.random(-scapeFactor, scapeFactor)
			end
			local stepSize = Room.stdDim.width / gridDim
			local pos = vec(i * stepSize + ox, j * stepSize + oy)
			local sp = SpawnPoint.new(pos)
			local sd = SpawnData.new(type, density)
			sp:insert(sd)
			blueprint:insert(sp)
		end
	end
end

---@param blueprint Blueprint
---@param prob number
-- insere 4 pontos com bases de pilares e talvez colunas de pilares.
-- `prob` indica a chance desses 4 pilares serem inseridos
function insertPossiblePillars(blueprint, prob)
	local r = math.random()
	if r < prob then
		local pillarPositions = {
			vec(-400, -700),
			vec(580, -700),
			vec(-400, 320),
			vec(580, 320),
		}
		for i = 1, 4 do
			local spPillar = SpawnPoint.new(pillarPositions[i])
			local spPillarBase = SpawnPoint.new(addVec(pillarPositions[i], vec(-91, 210)))
			local pillarData = SpawnData.new(PILLAR, 1.0)
			local pillarBaseData = SpawnData.new(PILLAR_BASE, 1.0)
			spPillar:insert(pillarData)
			spPillarBase:insert(pillarBaseData)
			blueprint:insert(spPillar):insert(spPillarBase)
		end
	end
end

---@param blueprint Blueprint
---@param density number
-- insere os relevos negativos no blueprint
function insertNegatives(blueprint, density)
	for i = 1, 10 do
		for j = 1, 10 do
			local r = math.random(-30, 30)
			local pos = vec(i * 160 - 800 + r, j * 160 - 800 + r)
			local sp = SpawnPoint.new(pos)
			local negativeData = SpawnData.new(NEGATIVE, density)
			sp:insert(negativeData)
			blueprint:insert(sp)
		end
	end
end

---@param blueprint Blueprint
---@param density number
-- insere os patches de musgo no blueprint
function insertMoss(blueprint, density)
	for i = 1, 10 do
		for j = 1, 10 do
			local r = math.random(-30, 30)
			local pos = vec(i * 160 - 800 + r, j * 160 - 800 + r)
			local sp = SpawnPoint.new(pos)
			local mossData = SpawnData.new(MOSS, density)
			sp:insert(mossData)
			blueprint:insert(sp)
		end
	end
end

function insertCracks(blueprint, density)
	for i = 1, 10 do
		for j = 1, 10 do
			local r = math.random(-30, 30)
			local pos = vec(i * 160 - 800 + r, j * 160 - 800 + r)
			local sp = SpawnPoint.new(pos)
			local crackData = SpawnData.new(CRACKS, density)
			sp:insert(crackData)
			blueprint:insert(sp)
		end
	end
end
