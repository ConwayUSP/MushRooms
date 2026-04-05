----------------------------------------
-- Importações de Módulos
----------------------------------------
require("modules.systems.blueprints")
require("modules.utils.constructors")
require("modules.utils.types")
require("modules.utils.utils")
require("table")

----------------------------------------
-- Variáveis e enums
----------------------------------------
rooms = BiList.new()
activeRooms = Set.new()

-- tipos de sala
PUZZLE_ROOM = "puzzle room"
NPC_ROOM = "npc room"
RESOURCE_ROOM = "resource room"
BATTLE_ROOM = "battle room"
BOSS_ROOM = "boss room"
EVENT_ROOM = "event room"

---@alias RoomType
---| `PUZZLE_ROOM`
---| `NPC_ROOM`
---| `RESOURCE_ROOM`
---| `BATTLE_ROOM`
---| `BOSS_ROOM`
---| `EVENT_ROOM`

---@class RoomLimits
---@field p1 Vec
---@field p2 Vec

----------------------------------------
-- Classe Room
----------------------------------------

---@class Room
---@field arrPos Vec
---@field pos Vec
---@field dimensions Size
---@field hb Hitboxes
---@field limits RoomLimits
---@field center Vec
---@field color Color
---@field sprites table
---@field explored boolean
---@field destructibles Destructible[]
---@field interactives Interactive[]
---@field items Item[]
---@field enemies Enemy[]
---@field npcs Npc[]
---@field obstacles Obstacle[]
---@field doors Interactive[]
---@field playersInRoom Set
---@field populate function
---@field visit function
---@field adjacentRooms Vec[]

Room = {}
Room.__index = Room
Room.type = ROOM
Room.stdDim = { width = 1536, height = 1536 }
Room.spacing = 64 * 6 -- tamanho do sprite de parede (pode mudar depois)

---@param pos Vec
---@param dimensions Size
---@param hitboxes Hitboxes
---@param limits RoomLimits
---@param blueprint Blueprint
---@param sprites table
---@return Room
-- cria uma instância de `Room`
function Room.new(pos, dimensions, hitboxes, limits, blueprint, sprites)
	local room = setmetatable({}, Room)

	-- atributos que variam
	room.arrPos = pos                                -- posição da sala na array de salas
	room.dimensions = dimensions                     -- largura e altura da sala
	room.hb = hitboxes                               -- hitbox da sala
	room.limits = limits                             -- limites da sala nas coordenadas de mundo
	room.pos = midpoint(room.limits.p1, room.limits.p2) -- centro da sala nas coordenadas de mundo
	room.color = blueprint.color                     -- cor da sala
	room.sprites = sprites                           -- os sprites da sala em camadas
	-- atributos fixos na instanciação
	room.adjacentRooms = {}                          -- salas adjacentes
	room.explored = false                            -- se algum jogador já entrou na sala ou não
	room.destructibles = {}                          -- lista de objetos destrutíveis da sala
	room.interactives = {}                           -- lista de objetos interativos na sala
	room.doors = {}                                  -- lista de portas da sala
	room.items = {}                                  -- lista de itens dropados na sala
	room.enemies = {}                                -- lista de inimigos na sala
	room.npcs = {}                                   -- lista de NPCs na sala
	room.obstacles = {}                              -- lista de obstáculos na sala
	room.playersInRoom = Set.new()                   -- lista de jogadores na sala

	room:addWallsAndDoors()

	return room
end

---@param dt number
-- atualiza os destrutíveis, inimigos e items da sala
function Room:update(dt)
	-- atualiza destrutíveis
	for _, d in pairs(self.destructibles) do
		d:update(dt)
	end
	-- atualiza objetos interativos
	for _, i in pairs(self.interactives) do
		i:update(dt)
	end
	-- atualiza portas
	for _, d in pairs(self.doors) do
		d:update(dt)
	end
	-- atualiza items
	for _, item in pairs(self.items) do
		item:update(dt)
	end
	-- atualiza inimigos
	for _, e in pairs(self.enemies) do
		e:update(dt)
	end
	-- atualiza NPCs
	for _, npc in pairs(self.npcs) do
		npc:update(dt)
	end
end

---@param player Player
-- adiciona `Room` à lista de salas ativas
function Room:visit(player)
	if self.playersInRoom:has(player.id) then
		return
	end

	self:setExplored()
	self.playersInRoom:add(player.id, player)
	activeRooms:add(makeKey(self.arrPos.x, self.arrPos.y), self)
	player.room = self

	collisionManager.roomsDirty = true
end

-- define a sala como estando explorada, gerando as 4 salas
-- vizinhas à ela
function Room:setExplored()
	if self.explored then
		return
	end

	self.explored = true

	-- criando salas adjacentes se eles ainda não existem
	local adjacentPos = self:getAdjacentPos()
	for _, pos in pairs(adjacentPos) do
		if not rooms[pos.y] then
			rooms:insert(pos.y, BiList.new())
		end
		if not rooms[pos.y][pos.x] then
			newRoom(pos, Room.stdDim)
		end

		table.insert(self.adjacentRooms, pos)
	end
end

---@return Vec[]
-- retorna as posições das 4 salas adjacentes em uma lista
-- essa função existe mais por praticidade
function Room:getAdjacentPos()
	local adjacentPos = {}
	table.insert(adjacentPos, { x = self.arrPos.x - 1, y = self.arrPos.y })
	table.insert(adjacentPos, { x = self.arrPos.x + 1, y = self.arrPos.y })
	table.insert(adjacentPos, { x = self.arrPos.x, y = self.arrPos.y - 1 })
	table.insert(adjacentPos, { x = self.arrPos.x, y = self.arrPos.y + 1 })
	return adjacentPos
end

-- se a sala está vazia (sem jogadores), remove ela da lista de salas ativas
function Room:verifyIsEmpty()
	if self.playersInRoom:size() == 0 then
		activeRooms:remove(makeKey(self.arrPos.x, self.arrPos.y))

		collisionManager.roomsDirty = true
	end
end

---@param spawnpoints SpawnPoint[]
-- geração dos conteúdos de uma sala
function Room:populate(spawnpoints)
	for _, sp in pairs(spawnpoints) do
		local n = math.random()
		for _, sd in ipairs(sp.spawns) do
			if n < sd.chance then
				self:spawn(sd.entity, sp.pos)
				goto nextspawnpoint
			end
		end
		::nextspawnpoint::
	end
end

---@param entity any
---@param pos Vec
-- instancia uma entidade e a insere na lista correspondente da sala
function Room:spawn(entity, pos)
	local constructor = CONSTRUCTORS[entity.type][entity.name]
	local real_pos = addVec(pos, self.pos)
	constructor(real_pos, self) -- instancia a entidade na sala
end

-- coloca paredes e portas ao redor da sala
function Room:addWallsAndDoors()
	-- !TODO: inserir 4 paredes e salas ao invés de uma só
	local relativePosDoor = vec(0, -Room.stdDim.height / 2 - 96)
	local relativePosWall = vec(0, -Room.stdDim.height / 2 - 120)
	CONSTRUCTORS[DOOR.type][DOOR.name](addVec(self.pos, relativePosDoor), self)
	CONSTRUCTORS[WALL.type][WALL.name](addVec(self.pos, relativePosWall), self)
end

-- abre as portas se estiverem fechadas e fecha elas se estiverem abertas
function Room:toggleDoors()
	for _, d in pairs(self.doors) do
		d:onInteract()
	end
end

----------------------------------------
-- Funções Globais
----------------------------------------

---@param pos Vec
---@return Room | nil
-- retorna a sala na posição `pos` da lista global de salas (`rooms`)
function getRoomAt(pos)
	if rooms[pos.y] then
		return rooms[pos.y][pos.x]
	end

	return nil
end

---@param pos any
---@param dimensions any
---@param roomType? RoomType
-- cria uma nova sala no índice indicado por `pos` da
-- lista global de salas (`rooms`)
function newRoom(pos, dimensions, roomType)
	if not rooms[pos.y] then
		rooms:insert(pos.y, BiList.new())
	end

	local actualRoom = rooms[pos.y][pos.x]
	if actualRoom then
		-- TODO: remover entidades da sala antiga
		activeRooms:remove(makeKey(pos.x, pos.y))
		collisionManager:unregister(actualRoom)
		for _, adjPos in pairs(actualRoom.adjacentRooms) do
			local adjRoom = getRoomAt(adjPos)
			if adjRoom then
				collisionManager:unregister(adjRoom)
			end
		end
	end

	-- escolhendo uma blueprint para a sala
	roomType = roomType or randRoomType()
	local blueprint = randRoomBlueprint(roomType)

	-- posicionando a sala
	local leftLimit = pos.x * (dimensions.width + Room.spacing) - Room.spacing
	local topLimit = pos.y * (dimensions.height + Room.spacing) - Room.spacing
	local rightLimit = leftLimit + dimensions.width + Room.spacing
	local bottomLimit = topLimit + dimensions.height + Room.spacing
	local p1 = vec(leftLimit, topLimit)
	local p2 = vec(rightLimit, bottomLimit)
	local limits = { p1 = p1, p2 = p2 }
	local hb = hitbox(Rectangle.new(dimensions.width + Room.spacing, dimensions.height + Room.spacing))
	local hbs = hitboxes({}, {}, { hb })

	-- decorando a sala
	local sprites = {}
	sprites.floor = love.graphics.newImage("assets/sprites/rooms/testRoom.png")
	sprites.floor:setFilter("nearest", "nearest")

	-- instanciando e populando com entidades (inimigos, destrutíveis, etc)
	local room = Room.new(pos, dimensions, hbs, limits, blueprint, sprites)
	room:populate(blueprint.spawnpoints)
	rooms[pos.y]:insert(pos.x, room)
end

-- cria a sala inicial do jogo e suas 4 vizinhas
function createInitialRooms()
	newRoom({ x = 0, y = 0 }, Room.stdDim)
	rooms[0][0]:setExplored()
end

---@param x number
---@param y number
---@return string
-- cria uma key única baseada nas coordenadas da sala
function makeKey(x, y)
	return tostring(x) .. "," .. tostring(y)
end

return Room
