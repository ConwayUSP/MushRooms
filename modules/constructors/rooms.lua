---@return Blueprint
-- sala de puzzle 1: contém nada de mais
function newPuzzleRoom1(rng)
	local bp = Blueprint.new(PUZZLE_ROOM, "Test Puzzle Room", rgba8(12, 253, 255, 255))
	insertGeneralDecorations(bp, rng)
	return bp
end

---@return Blueprint
-- sala de puzzle 2: contém uma vela (?)
function newPuzzleRoom2(rng)
	local bp = Blueprint.new(PUZZLE_ROOM, "Test Puzzle Room 2", rgba8(12, 253, 255, 255))
	local spCenter = SpawnPoint.new(vec(0, 0))
	local candleData = SpawnData.new(CANDLE, 1.0)
	spCenter:insert(candleData)
	bp:insert(spCenter)
	insertGeneralDecorations(bp, rng)
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
	insertGeneralDecorations(bp, rng)
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
	insertGeneralDecorations(bp, rng)
	return bp
end

---@return Blueprint
-- sala de recurso 1: contém barrís e jarros
function newResourceRoom1(rng)
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
	insertGeneralDecorations(bp, rng)
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
	insertGeneralDecorations(bp, rng)
	return bp
end

---@return Blueprint
-- sala de batalha 1: contém Gatos Nucleares e Patos Aranhas
function newBattleRoom1(rng)
	local bp = Blueprint.new(BATTLE_ROOM, "Test Battle Room", rgba8(255, 255, 255, 255))
	local sp1 = SpawnPoint.new(vec(100, -100))
	local sp2 = SpawnPoint.new(vec(-100, 100))
	local sp3 = SpawnPoint.new(vec(100, 100))
	local sp4 = SpawnPoint.new(vec(-100, -100))
	local enemyData1 = SpawnData.new(SPIDER_DUCK, 0.2)
	local enemyData2 = SpawnData.new(NUCLEAR_CAT, 0.4)
	local enemyData3 = SpawnData.new(DEMON_BALL, 1.0)
	sp1:insert(enemyData1):insert(enemyData2):insert(enemyData3)
	sp2:insert(enemyData1):insert(enemyData2):insert(enemyData3)
	sp3:insert(enemyData1):insert(enemyData2):insert(enemyData3)
	sp4:insert(enemyData1):insert(enemyData2):insert(enemyData3)
	bp:insert(sp1):insert(sp2):insert(sp3):insert(sp4)
	insertGeneralDecorations(bp, rng)
	return bp
end

---@return Blueprint
-- sala de boss 1: contém 1 Gato Nuclear ou 1 Pato Aranha no centro
function newBossRoom1(rng)
	local bp = Blueprint.new(BOSS_ROOM, "Test Boss Room", rgba8(255, 41, 41, 255))
	local sp1 = SpawnPoint.new(vec(0, 0))
	local enemyData1 = SpawnData.new(SPIDER_DUCK_BOSS, 1.0)
	sp1:insert(enemyData1)
	bp:insert(sp1)
	insertGeneralDecorations(bp, rng)
	return bp
end

---@return Blueprint
-- sala de evento 1: contém barrís, jarros ou inimigos
function newEventRoom1(rng)
	local bp = Blueprint.new(EVENT_ROOM, "Test Event Room", rgba8(104, 237, 102, 255))
	local sp1 = SpawnPoint.new(vec(0, 0))
	local barrelData = SpawnData.new(BARREL, 0.25)
	local jarData = SpawnData.new(JAR, 0.5)
	local enemyData1 = SpawnData.new(SPIDER_DUCK, 0.75)
	local enemyData2 = SpawnData.new(NUCLEAR_CAT, 1.0)
	sp1:insert(barrelData):insert(jarData):insert(enemyData1):insert(enemyData2)
	bp:insert(sp1)
	insertGeneralDecorations(bp, rng)
	return bp
end

----------------------------------------
-- Facilitadores
----------------------------------------

---@param blueprint any
-- insere algumas decorações gerais para facilitar nossa vida
function insertGeneralDecorations(blueprint, rng)
	-- !WARNING: essa função é uma generalização bem forte, é recomendado
	-- fazermos uma personalização mais fina das salas depois
	insertPossiblePillars(blueprint, 0.6, rng)
	insertPossibleTorches(blueprint, 0.8, rng)
	insertRandomly(blueprint, NEGATIVE, 20, rng)
	insertRandomly(blueprint, MOSS, 18, rng)
	insertRandomly(blueprint, CRACKS, 16, rng)
	insertRandomly(blueprint, SKELETON, 4, rng)
	insertIntoGrid(blueprint, RUBBLE_BIG, 0.1, 6, true, rng)
	insertIntoGrid(blueprint, RUBBLE_SMALL, 0.3, 8, true, rng)
end

---@param blueprint Blueprint
---@param type EntityReg
---@param amount number
---comment
function insertRandomly(blueprint, type, amount, rng)
	for i = 1, amount do
		local x = rng:random(-(Room.stdDim.width / 2) + 20, Room.stdDim.width - 20)
		local y = rng:random(-(Room.stdDim.height / 2) + 20, Room.stdDim.height - 20)
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
function insertIntoGrid(blueprint, type, density, gridDim, scapeGrid, rng)
	for i = 0, gridDim do
		for j = 0, gridDim do
			local ox, oy = 0, 0
			local scapeFactor = Room.stdDim.width / (gridDim * 3)
			if scapeGrid then
				ox = rng:random(-scapeFactor, scapeFactor)
				oy = rng:random(-scapeFactor, scapeFactor)
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
function insertPossiblePillars(blueprint, prob, rng)
	local r = rng:random()
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
			local spPillarProp = SpawnPoint.new(addVec(pillarPositions[i], vec(-168, 268)))
			local spPillarDecoration = SpawnPoint.new(addVec(pillarPositions[i], vec(rng:random(-140, 10), 280)))
			local pillarData = SpawnData.new(PILLAR, 1.0)
			local pillarBaseData = SpawnData.new(PILLAR_BASE, 1.0)
			local pillarPropData = SpawnData.new(PILLAR_PROP, 1.0)
			local pillarDecData1 = SpawnData.new(CANDLE, 0.2)
			local pillarDecData2 = SpawnData.new(SKELETON, 0.3)
			spPillar:insert(pillarData)
			spPillarBase:insert(pillarBaseData)
			spPillarProp:insert(pillarPropData)
			spPillarDecoration:insert(pillarDecData1):insert(pillarDecData2)
			blueprint:insert(spPillar):insert(spPillarBase):insert(spPillarProp):insert(spPillarDecoration)
		end
	end
end

---@param blueprint Blueprint
---@param prob number
-- insere tochas na parede de cima da sala
function insertPossibleTorches(blueprint, prob, rng)
	local torchPositions = {
		vec(-600, -900),
		vec(-200, -900),
		vec(200, -900),
		vec(600, -900),
	}
	for i = 1, 4 do
		local r = rng:random()
		if r < prob then
			local spTorch = SpawnPoint.new(torchPositions[i])
			local torchData = SpawnData.new(TORCH, 1.0)
			spTorch:insert(torchData)
			blueprint:insert(spTorch)
		end
	end
end
