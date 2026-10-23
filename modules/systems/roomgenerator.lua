----------------------------------------
-- Room Generator
----------------------------------------

---@class RoomPoolEntry
---@field constructor fun(rng: RNG): Blueprint
---@field roomType RoomType
---@field weight number

---@class RoomWeightConfig
---@field weight number
---@field distribution "equal" | table<fun(rng: RNG): Blueprint, number>

---@class RoomRule
---@field count number
---@field maxCount number
---@field condition? fun(pos: Vec, floor: number): boolean
---@field position? Vec

---@type RoomPoolEntry[]
local ROOM_POOL = {}

---@type number?
local currentFloor = nil

local ROOM_POSITION_RADIUS = 5
local ROOM_POSITION_ATTEMPTS = 50

---@type RoomType[]
local SPECIAL_ROOM_TYPE_ORDER = {
	NPC_ROOM,
	PUZZLE_ROOM,
	BOSS_ROOM,
}

---@type table<RoomType, (fun(rng: RNG): Blueprint)[]>
BLUEPRINTS = {
	[BATTLE_ROOM] = {
		new3SpotsBattleRoom,
		new4SpotsBattleRoom,
		new5SpotsBattleRoom,
		new3SpiderDucksBattleRoom,
		new4SpiderDucksBattleRoom,
		new5SpiderDucksBattleRoom,
		new3NuclearCatsBattleRoom,
		new4NuclearCatsBattleRoom,
		new5NuclearCatsBattleRoom,
		new3RollingStonesBattleRoom,
		new4RollingStonesBattleRoom,
		new5RollingStonesBattleRoom,
		new3DemonBallsBattleRoom,
		new4DemonBallsBattleRoom,
		new5DemonBallsBattleRoom,
	},
	[RESOURCE_ROOM] = {
		new2SpotsResourceRoom,
		new3SpotsResourceRoom,
		new4SpotsResourceRoom,
		new2BonesSpotsResourceRoom,
		new3BonesSpotsResourceRoom,
		new4BonesSpotsResourceRoom,
		new2RocksSpotsResourceRoom,
		new3RocksSpotsResourceRoom,
		new4RocksSpotsResourceRoom,
		new2CoalSpotsResourceRoom,
		new3CoalSpotsResourceRoom,
		new4CoalSpotsResourceRoom,
	},
	[NPC_ROOM] = {
		newTenkarRoom,
		newShoumShoumRoom,
		newBiguiriRoom,
	},
	[PUZZLE_ROOM] = {
		newSmallPuzzleRoomDash,
		newSmallPuzzleRoomRing
	},
	[TREASURE_ROOM] = {
		newTreasureRoom1,
	},
	[BOSS_ROOM] = {
		newAncientMoaiBossRoom,
	},
}

---@type table<RoomType, RoomWeightConfig>
ROOM_WEIGHTS = {
	[BATTLE_ROOM] = {
		weight = 67,
		distribution = "equal",
	},
	[RESOURCE_ROOM] = {
		weight = 12,
		distribution = "equal",
	},
	-- esse é um exemplo de um caso onde uma sala dentre as demais é mais "rara"
	-- o sistema atual permite configurar sub-pesos dentro de um tipo de sala
	-- [NPC_ROOM] = {
	-- 	weight = 8,
	-- 	distribution = {
	-- 		[newTenkarRoom] = 1,
	-- 		[newShoumShoumRoom] = 1,
	-- 		[newBiguiriRoom] = 0.05,
	-- 	},
	-- },
	[TREASURE_ROOM] = {
		weight = 3,
		distribution = "equal",
	}
}

---@type table<fun(rng: RNG): Blueprint, RoomRule>
ROOM_RULES = {
	[newTenkarRoom] = {
		count = 0,
		maxCount = 1,
	},
	[newShoumShoumRoom] = {
		count = 0,
		maxCount = 1,
	},
	[newBiguiriRoom] = {
		count = 0,
		maxCount = 1,
		condition = function(pos)
			-- TODO: ser mais criativo e colocar alguma condição extra aqui
			return math.abs(pos.x) + math.abs(pos.y) >= ROOM_POSITION_RADIUS
		end,
	},
	[newSmallPuzzleRoomDash] = {
		count = 0,
		maxCount = 1,
	},
	[newSmallPuzzleRoomRing] = {
		count = 0,
		maxCount = 1,
	},	
	[newAncientMoaiBossRoom] = {
		count = 0,
		maxCount = 1,
		condition = function(pos)
			return math.abs(pos.x) + math.abs(pos.y) >= ROOM_POSITION_RADIUS
		end,
	},
}

---@return nil
-- monta a pool mantendo o peso de cada categoria
local function buildRoomPool()
	ROOM_POOL = {}

	for roomType, constructors in pairs(BLUEPRINTS) do
		local config = ROOM_WEIGHTS[roomType]

		if config and #constructors > 0 then
			local totalWeight = 0
			local weights = {}

			if config.distribution == "equal" then
				for _, constructor in ipairs(constructors) do
					weights[constructor] = 1
          totalWeight = totalWeight + 1
				end
			else
        local dist = config.distribution
        ---@cast dist table<fun(rng: RNG): Blueprint, number>
				weights = dist

        for _, constructor in pairs(constructors) do
          totalWeight = totalWeight + (weights[constructor] or 0)
        end
			end

      if totalWeight > 0 then
        for _, constructor in ipairs(constructors) do
          local relativeWeight = weights[constructor] or 0
          local weight = config.weight * relativeWeight / totalWeight
  
          if weight > 0 and not ROOM_RULES[constructor] then
            ROOM_POOL[#ROOM_POOL + 1] = {
              constructor = constructor,
              roomType = roomType,
              weight = weight,
            }
          end
        end
      end

		end
	end
end

---@param pos Vec
---@return boolean
local function isInsideRoomPositionRadius(pos)
	return math.abs(pos.x) + math.abs(pos.y) <= ROOM_POSITION_RADIUS
end

---@param a Vec
---@param b Vec
---@return boolean
local function isSamePosition(a, b)
	return a.x == b.x and a.y == b.y
end

---@param pos Vec
---@param roomType RoomType
---@param assigned { position: Vec, roomType: RoomType }[]
---@return boolean
local function isValidSpecialRoomPosition(pos, roomType, assigned)
	if not isInsideRoomPositionRadius(pos) then
		return false
	end

	if isSamePosition(pos, { x = 0, y = 0 }) then
		return false
	end

	for _, room in ipairs(assigned) do
		if isSamePosition(pos, room.position) then
			return false
		end

		-- impede salas adjacentes do mesmo tipo de ficarem juntas
		if room.roomType == roomType
			and math.abs(pos.x - room.position.x) <= 1
			and math.abs(pos.y - room.position.y) <= 1 then
			return false
		end
	end

	return true
end

---@param rule RoomRule
---@param roomType RoomType
---@param rng RNG
---@param assigned { position: Vec, roomType: RoomType }[]
---@return nil
-- reserva uma posição para uma sala especial
local function assignSpecialRoomPosition(rule, roomType, rng, assigned)
	rule.position = nil

	local function isValid(pos)
		return isInsideRoomPositionRadius(pos)
			and isValidSpecialRoomPosition(pos, roomType, assigned)
			and (not rule.condition or rule.condition(pos, currentFloor or 1))
	end

	for _ = 1, ROOM_POSITION_ATTEMPTS do
		-- usa distância de taxista
		local x = rng:random(-ROOM_POSITION_RADIUS, ROOM_POSITION_RADIUS)
		local maxY = ROOM_POSITION_RADIUS - math.abs(x)
		local y = rng:random(-maxY, maxY)
		local pos = vec(x, y)

		if isValid(pos) then
			rule.position = pos
			assigned[#assigned + 1] = { position = pos, roomType = roomType }
			rule.count = rule.count + 1

			print(roomType, pos.x, pos.y)

			return
		end
	end
end

---@param floor? number
---@return nil
-- reinicia as contagens e sorteia posições para as salas especiais
function resetRoomGenerator(floor)
	currentFloor = floor or 1

	for _, rule in pairs(ROOM_RULES) do
		rule.count = 0
		rule.position = nil
	end

	-- usa seed GLOBAL não alterar a sequência aleatória das salas
	local positionRng = love.math.newRandomGenerator(worldSeed)

	-- lista de salas já definidas
	local assigned = {
		{ position = { x = 0, y = 0 }, roomType = INITIAL_ROOM },
	}

	for _, roomType in ipairs(SPECIAL_ROOM_TYPE_ORDER) do
		for _, constructor in ipairs(BLUEPRINTS[roomType] or {}) do
			---@type RoomRule
			local rule = ROOM_RULES[constructor]

			while rule.count < rule.maxCount do
				assignSpecialRoomPosition(rule, roomType, positionRng, assigned)
			end
		end
	end

	buildRoomPool()
end

---@param constructor fun(rng: RNG): Blueprint
---@return nil
-- registra a escolha e atualiza as regras
local function registerRoomChoice(constructor)
  ---@type RoomRule
	local rule = ROOM_RULES[constructor]

	if rule then
		rule.count = rule.count + 1
	end
end

---@param candidate RoomPoolEntry
---@param roomType RoomType?
---@param pos Vec
---@param floor number
---@return boolean
local function matchesCandidate(candidate, roomType, pos, floor)
	---@type RoomRule?
	local rule = ROOM_RULES[candidate.constructor]

	local matchesType = roomType == nil
		or candidate.roomType == roomType

	local matchesCondition = not rule
		or (rule.position ~= nil and isSamePosition(rule.position, pos))

	return matchesType and matchesCondition
end

---@param pos Vec
---@return (fun(rng: RNG): Blueprint|nil), RoomRule|nil, RoomType|nil
-- retorna o construtor e a regra de uma sala já reservada
local function findReservedRoom(pos)
	for constructor, rule in pairs(ROOM_RULES) do
		if rule.position and isSamePosition(rule.position, pos) then
			return constructor, rule
		end
	end

	return nil
end

---@param roomType RoomType?
---@param rng RNG
---@param pos Vec
---@return Blueprint
-- escolhe uma blueprint respeitando os pesos e as regras
function randRoomBlueprint(roomType, rng, pos)
	if not currentFloor then
		resetRoomGenerator(1)
	end

	if roomType == INITIAL_ROOM then
		return newInitialRoom1(rng)
	end

	-- se é uma sala especial, já foi reservada previamente
	local reservedConstructor, reservedRule = findReservedRoom(pos)
	if reservedConstructor and reservedRule then
		registerRoomChoice(reservedConstructor)

		return reservedConstructor(rng)
	end

  local totalWeight = 0
  ---@cast currentFloor number

  for _, candidate in ipairs(ROOM_POOL) do
		if matchesCandidate(candidate, roomType, pos, currentFloor) then
			totalWeight = totalWeight + candidate.weight
		end
	end

  local target = rng:random() * totalWeight
	local accumulatedWeight = 0

  for i, candidate in ipairs(ROOM_POOL) do
		if matchesCandidate(candidate, roomType, pos, currentFloor) then
			accumulatedWeight = accumulatedWeight + candidate.weight

			if target < accumulatedWeight then
				local constructor = candidate.constructor

				return constructor(rng)
			end
		end
	end
end