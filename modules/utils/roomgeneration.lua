local RoomGeneration = {}

---@class DecorationExclusionArea
---@field min Vec
---@field max Vec

---@param size Vec dimensões do grid em tiles
---@param margin number
---@return DecorationExclusionArea
-- cria uma área protegida ao redor do grid do puzzle
function RoomGeneration.puzzleGridExclusionArea(size, margin)
	local halfWidth = size.x * PuzzleGridManager.TILE_SIZE / 2 + margin
	local halfHeight = size.y * PuzzleGridManager.TILE_SIZE / 2 + margin

	return {
		min = vec(-halfWidth, -halfHeight),
		max = vec(halfWidth, halfHeight),
	}
end

---@param pos Vec
---@param excludedAreas? DecorationExclusionArea[]
---@return boolean
-- verifica se um ponto está dentro de alguma área protegida
local function isPositionExcluded(pos, excludedAreas)
	for _, area in ipairs(excludedAreas or {}) do
		if pos.x >= area.min.x and pos.x <= area.max.x and pos.y >= area.min.y and pos.y <= area.max.y then
			return true
		end
	end

	return false
end

---@class DecorationBounds
---@field min Vec
---@field max Vec

---@class DecorationOccupancy
---@field ground DecorationBounds[] musgos, negativos e rachaduras
---@field prop DecorationBounds[] entulhos e esqueletos
---@field structure DecorationBounds[] pilares, tochas e outras estruturas

---@return DecorationOccupancy
-- cria o registro temporário das áreas ocupadas por cada camada
local function newDecorationOccupancy()
	return {
		ground = {},
		prop = {},
		structure = {},
	}
end

---@param pos Vec
---@param dimensions Size dimensões já considerando a escala do sprite
---@param margin? number
---@return DecorationBounds
-- calcula os limites visuais de uma decoração a partir do seu centro
local function centeredDecorationBounds(pos, dimensions, margin)
	margin = margin or 0
	local halfWidth = dimensions.width / 2 + margin
	local halfHeight = dimensions.height / 2 + margin

	return {
		min = vec(pos.x - halfWidth, pos.y - halfHeight),
		max = vec(pos.x + halfWidth, pos.y + halfHeight),
	}
end

---@param first DecorationBounds
---@param second DecorationBounds
---@return boolean
-- verifica se duas áreas visuais se cruzam
local function decorationBoundsOverlap(first, second)
	return first.min.x < second.max.x
		and first.max.x > second.min.x
		and first.min.y < second.max.y
		and first.max.y > second.min.y
end

---@param bounds DecorationBounds
---@param excludedAreas? DecorationExclusionArea[]
---@return boolean
-- verifica se uma decoração invade alguma área protegida
local function isDecorationAreaExcluded(bounds, excludedAreas)
	for _, area in ipairs(excludedAreas or {}) do
		if decorationBoundsOverlap(bounds, area) then
			return true
		end
	end

	return false
end

---@param occupancy DecorationOccupancy
---@param bounds DecorationBounds
---@param layer "ground"|"prop"|"structure"
---@return boolean
-- verifica se a camada permite ocupar a área desejada
local function canOccupyDecorationArea(occupancy, bounds, layer)
	for _, occupiedBounds in ipairs(occupancy.structure) do
		if decorationBoundsOverlap(bounds, occupiedBounds) then
			return false
		end
	end

	if layer == "structure" then
		for _, occupiedBounds in ipairs(occupancy.ground) do
			if decorationBoundsOverlap(bounds, occupiedBounds) then
				return false
			end
		end

		for _, occupiedBounds in ipairs(occupancy.prop) do
			if decorationBoundsOverlap(bounds, occupiedBounds) then
				return false
			end
		end
	else
		for _, occupiedBounds in ipairs(occupancy[layer]) do
			if decorationBoundsOverlap(bounds, occupiedBounds) then
				return false
			end
		end
	end

	return true
end

---@param occupancy DecorationOccupancy
---@param bounds DecorationBounds
---@param layer "ground"|"prop"|"structure"
-- registra uma área como ocupada pela camada informada
local function occupyDecorationArea(occupancy, bounds, layer)
	table.insert(occupancy[layer], bounds)
end

---@param entity EntityReg
---@param pos Vec
---@return DecorationBounds?
---@return "ground"|"prop"|"structure"|nil
-- define a área visual e a camada usadas por cada decoração
local function decorationPlacement(entity, pos)
	local scale = 3
	local margin = 6

	if entity == MOSS_SMALL then
		return centeredDecorationBounds(pos, size(80 * scale, 46 * scale), margin), "ground"
	elseif entity == MOSS_BIG or entity == MOSS then
		return centeredDecorationBounds(pos, size(170 * scale, 112 * scale), margin), "ground"
	elseif entity == MOSS_LEFT then
		return {
			min = vec(pos.x - margin, pos.y - 170 * scale / 2 - margin),
			max = vec(pos.x + 190 * scale + margin, pos.y + 170 * scale / 2 + margin),
		}, "ground"
	elseif entity == MOSS_RIGHT then
		return {
			min = vec(pos.x - 88 * scale - margin, pos.y - 256 * scale / 2 - margin),
			max = vec(pos.x + margin, pos.y + 256 * scale / 2 + margin),
		}, "ground"
	elseif entity == MOSS_UP then
		return {
			min = vec(pos.x - 103 * scale / 2 - margin, pos.y - margin),
			max = vec(pos.x + 103 * scale / 2 + margin, pos.y + 22 * scale + margin),
		}, "ground"
	elseif entity == NEGATIVE then
		return centeredDecorationBounds(pos, size(41 * scale, 40 * scale), margin), "ground"
	elseif entity == CRACKS then
		return centeredDecorationBounds(pos, size(43 * scale, 15 * scale), margin), "ground"
	elseif entity == SKELETON then
		return centeredDecorationBounds(pos, size(28 * scale, 24 * scale), margin), "prop"
	elseif entity == RUBBLE_SMALL or entity == RUBBLE_BIG then
		return centeredDecorationBounds(pos, size(24 * scale, 36 * scale), margin), "prop"
	elseif entity == TORCH then
		return centeredDecorationBounds(pos, size(17 * scale, 37 * scale), margin), "structure"
	end

	return nil, nil
end

---@param occupancy DecorationOccupancy
---@param entity EntityReg
---@param pos Vec
---@param excludedAreas? DecorationExclusionArea[]
---@return boolean
-- valida uma posição e a reserva quando ela estiver disponível
local function tryOccupyDecorationArea(occupancy, entity, pos, excludedAreas)
	local bounds, layer = decorationPlacement(entity, pos)
	if not bounds or not layer then
		return not isPositionExcluded(pos, excludedAreas)
	end

	if isDecorationAreaExcluded(bounds, excludedAreas) then
		return false
	end

	if not canOccupyDecorationArea(occupancy, bounds, layer) then
		return false
	end

	occupyDecorationArea(occupancy, bounds, layer)
	return true
end

---@param size Vec dimensões do grid em tiles
---@return PuzzlePinSettings[]
-- cria um pino alinhado a cada tile dos quatro lados do grid
function RoomGeneration.fullPerimeterWithPins(size)
	local gridMargin = 50
	local directionNames = {
		["0;-1"] = "up",
		["1;0"] = "right",
		["0;1"] = "down",
		["-1;0"] = "left",
	}
	local pins = {}
	local pinHalfExtent = PuzzlePin.FRAME_DIM.width / 2

	for i = 0, 3 do
		local x = math.floor(math.sin(math.pi / 2 * i) + 0.5)
		local y = math.floor(-math.cos(math.pi / 2 * i) + 0.5)

		local direction = vec(x, y)
		local directionName = directionNames[x .. ";" .. y]
		
		local isHorizontalSide = x == 0
		local pinCount = isHorizontalSide and size.x or size.y
		local gridHalfExtent = (isHorizontalSide and size.y or size.x) * PuzzleGridManager.TILE_SIZE / 2
		local distanceFromCenter = gridHalfExtent + gridMargin + pinHalfExtent
		local sideCenter = scaleVec(direction, distanceFromCenter)
		local tangent = vec(-y, x)

		for k = 1, pinCount do
			local distanceAlongSide = (k - (pinCount + 1) / 2) * PuzzleGridManager.TILE_SIZE
			table.insert(pins, {
				id = "pin-" .. directionName .. "-" .. k,
				offset = addVec(sideCenter, scaleVec(tangent, distanceAlongSide)),
				pullDirection = vec(x, y),
			})
		end
	end

	return pins
end

----------------------------------------
-- Facilitadores
----------------------------------------

local insertPossiblePillars
local insertPossibleTorches
local insertPossibleWallMosses
local insertRandomly
local insertIntoGrid

---@param blueprint Blueprint
---@param rng RNG
---@param excludedAreas? DecorationExclusionArea[]
-- insere algumas decorações gerais para facilitar nossa vida
function RoomGeneration.insertGeneralDecorations(blueprint, rng, excludedAreas)
	-- !WARNING: essa função é uma generalização bem forte, é recomendado
	-- fazermos uma personalização mais fina das salas depois
	local occupancy = newDecorationOccupancy()
	insertPossiblePillars(blueprint, 0.6, rng, excludedAreas, occupancy)
	insertPossibleTorches(blueprint, 0.8, rng, excludedAreas, occupancy)
	insertPossibleWallMosses(blueprint, rng, excludedAreas, occupancy)
	insertRandomly(blueprint, MOSS_BIG, 1, rng, excludedAreas, 0.45, occupancy)
	insertRandomly(blueprint, NEGATIVE, 14, rng, excludedAreas, nil, occupancy)
	insertRandomly(blueprint, MOSS_SMALL, 12, rng, excludedAreas, nil, occupancy)
	insertRandomly(blueprint, CRACKS, 14, rng, excludedAreas, nil, occupancy)
	insertRandomly(blueprint, SKELETON, 3, rng, excludedAreas, nil, occupancy)
	insertIntoGrid(blueprint, RUBBLE_BIG, 0.1, 4, true, rng, excludedAreas, occupancy)
	insertIntoGrid(blueprint, RUBBLE_SMALL, 0.3, 6, true, rng, excludedAreas, occupancy)
end

---@param blueprint Blueprint
---@param entity EntityReg
---@param pos Vec
---@param excludedAreas? DecorationExclusionArea[]
---@param occupancy DecorationOccupancy
-- insere um musgo de parede somente quando sua área estiver livre
local function insertPossibleWallMoss(blueprint, entity, pos, excludedAreas, occupancy)
	if not tryOccupyDecorationArea(occupancy, entity, pos, excludedAreas) then
		return
	end

	local chance = 0.4
	local sp = SpawnPoint.new(pos)
	sp:insert(SpawnData.new(entity, chance))
	blueprint:insert(sp)
end

---@param blueprint Blueprint
---@param rng RNG
---@param excludedAreas? DecorationExclusionArea[]
---@param occupancy? DecorationOccupancy
-- distribui musgos nos dois segmentos de parede separados pelas portas
insertPossibleWallMosses = function(blueprint, rng, excludedAreas, occupancy)
	occupancy = occupancy or newDecorationOccupancy()
	local cornerMargin = 180
	local doorMargin = 200
	local halfWidth = Room.stdDim.width / 2
	local halfHeight = Room.stdDim.height / 2
	local topVerticalRange = {
		min = -halfHeight + cornerMargin,
		max = -doorMargin,
	}
	local bottomVerticalRange = {
		min = doorMargin,
		max = halfHeight - cornerMargin,
	}
	local leftHorizontalRange = {
		min = -halfWidth + cornerMargin,
		max = -doorMargin,
	}
	local rightHorizontalRange = {
		min = doorMargin,
		max = halfWidth - cornerMargin,
	}

	local verticalRanges = { topVerticalRange, bottomVerticalRange }
	local leftRange = verticalRanges[rng:random(#verticalRanges)]
	local rightRange = verticalRanges[rng:random(#verticalRanges)]
	local leftY = rng:random(leftRange.min, leftRange.max)
	local rightY = rng:random(rightRange.min, rightRange.max)
	insertPossibleWallMoss(blueprint, MOSS_LEFT, vec(-halfWidth, leftY), excludedAreas, occupancy)
	insertPossibleWallMoss(blueprint, MOSS_RIGHT, vec(halfWidth, rightY), excludedAreas, occupancy)

	local horizontalRanges = { leftHorizontalRange, rightHorizontalRange }
	local upRange = horizontalRanges[rng:random(#horizontalRanges)]
	local upX = rng:random(upRange.min, upRange.max)
	insertPossibleWallMoss(blueprint, MOSS_UP, vec(upX, -halfHeight), excludedAreas, occupancy)
end

---@param blueprint Blueprint
---@param type EntityReg
---@param amount number
---@param rng RNG
---@param excludedAreas? DecorationExclusionArea[]
---@param chance? number
---@param occupancy? DecorationOccupancy
-- distribui uma quantidade de entidades em posições aleatórias válidas
insertRandomly = function(blueprint, type, amount, rng, excludedAreas, chance, occupancy)
	occupancy = occupancy or newDecorationOccupancy()
	local roomMargin = 20
	local attemptsPerItem = 20
	local placed = 0
	local attempts = 0
	local maxAttempts = amount * attemptsPerItem
	local minX = -Room.stdDim.width / 2 + roomMargin
	local maxX = Room.stdDim.width / 2 - roomMargin
	local minY = -Room.stdDim.height / 2 + roomMargin
	local maxY = Room.stdDim.height / 2 - roomMargin

	while placed < amount and attempts < maxAttempts do
		attempts = attempts + 1
		local x = rng:random(minX, maxX)
		local y = rng:random(minY, maxY)
		local pos = vec(x, y)

		if not tryOccupyDecorationArea(occupancy, type, pos, excludedAreas) then
			goto continue
		end

		local sp = SpawnPoint.new(pos)
		local sd = SpawnData.new(type, chance or 1.0)
		sp:insert(sd)
		blueprint:insert(sp)
		placed = placed + 1

		::continue::
	end
end

---@param blueprint Blueprint
---@param type EntityReg
---@param density number
---@param gridDim number
---@param scapeGrid boolean
---@param rng RNG
---@param excludedAreas? DecorationExclusionArea[]
---@param occupancy? DecorationOccupancy
-- insere na blueprint aleatoriamente de acordo com uma grade de tamanho ajustável
insertIntoGrid = function(blueprint, type, density, gridDim, scapeGrid, rng, excludedAreas, occupancy)
	occupancy = occupancy or newDecorationOccupancy()
	local roomMargin = 20
	local minX = -Room.stdDim.width / 2 + roomMargin
	local maxX = Room.stdDim.width / 2 - roomMargin
	local minY = -Room.stdDim.height / 2 + roomMargin
	local maxY = Room.stdDim.height / 2 - roomMargin
	local stepX = (maxX - minX) / gridDim
	local stepY = (maxY - minY) / gridDim
	local scapeFactorX = stepX / 3
	local scapeFactorY = stepY / 3

	for i = 0, gridDim do
		for j = 0, gridDim do
			local ox, oy = 0, 0
			if scapeGrid then
				ox = (rng:random() * 2 - 1) * scapeFactorX
				oy = (rng:random() * 2 - 1) * scapeFactorY
			end

			local x = clamp(minX + i * stepX + ox, minX, maxX)
			local y = clamp(minY + j * stepY + oy, minY, maxY)
			local pos = vec(x, y)
			if not tryOccupyDecorationArea(occupancy, type, pos, excludedAreas) then
				goto continue
			end

			local sp = SpawnPoint.new(pos)
			local sd = SpawnData.new(type, density)
			sp:insert(sd)
			blueprint:insert(sp)

			::continue::
		end
	end
end

---@param blueprint Blueprint
---@param prob number
---@param rng RNG
---@param excludedAreas? DecorationExclusionArea[]
---@param occupancy? DecorationOccupancy
-- insere 4 pontos com bases de pilares e talvez colunas de pilares.
-- `prob` indica a chance desses 4 pilares serem inseridos
insertPossiblePillars = function(blueprint, prob, rng, excludedAreas, occupancy)
	occupancy = occupancy or newDecorationOccupancy()
	local r = rng:random()
	if r < prob then
		local pillarPositions = {
			vec(-400, -700),
			vec(580, -700),
			vec(-400, 320),
			vec(580, 320),
		}
		for i = 1, 4 do
			local positions = {
				pillarPositions[i],
				addVec(pillarPositions[i], vec(-91, 210)),
				addVec(pillarPositions[i], vec(-168, 268)),
				addVec(pillarPositions[i], vec(rng:random(-140, 10), 280)),
			}
			local scale = 3
			local margin = 6
			local pillarBounds = {
				centeredDecorationBounds(positions[1], size(95 * scale, 155 * scale), margin),
				centeredDecorationBounds(positions[2], size(46 * scale, 46 * scale), margin),
				centeredDecorationBounds(positions[3], size(57 * scale, 52 * scale), margin),
				centeredDecorationBounds(positions[4], size(28 * scale, 36 * scale), margin),
			}
			for _, bounds in ipairs(pillarBounds) do
				if isDecorationAreaExcluded(bounds, excludedAreas)
					or not canOccupyDecorationArea(occupancy, bounds, "structure")
				then
					goto continue
				end
			end
			for _, bounds in ipairs(pillarBounds) do
				occupyDecorationArea(occupancy, bounds, "structure")
			end

			local spPillar = SpawnPoint.new(positions[1])
			local spPillarBase = SpawnPoint.new(positions[2])
			local spPillarProp = SpawnPoint.new(positions[3])
			local spPillarDecoration = SpawnPoint.new(positions[4])
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

			::continue::
		end
	end
end

---@param blueprint Blueprint
---@param prob number
---@param rng RNG
---@param excludedAreas? DecorationExclusionArea[]
---@param occupancy? DecorationOccupancy
-- insere tochas na parede de cima da sala
insertPossibleTorches = function(blueprint, prob, rng, excludedAreas, occupancy)
	occupancy = occupancy or newDecorationOccupancy()
	local torchPositions = {
		vec(-600, -900),
		vec(-200, -900),
		vec(200, -900),
		vec(600, -900),
	}
	for i = 1, 4 do
		local r = rng:random()
		if r < prob
			and tryOccupyDecorationArea(occupancy, TORCH, torchPositions[i], excludedAreas)
		then
			local spTorch = SpawnPoint.new(torchPositions[i])
			local torchData = SpawnData.new(TORCH, 1.0)
			spTorch:insert(torchData)
			blueprint:insert(spTorch)
		end
	end
end

return RoomGeneration
