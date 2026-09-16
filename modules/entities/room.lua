----------------------------------------
-- Importações de Módulos
----------------------------------------
require("modules.systems.blueprint")
require("modules.engine.spatialgrid")
require("modules.utils.constructors")
require("modules.utils.seeds")
require("modules.utils.types")
require("modules.utils.utils")
require("table")

----------------------------------------
-- Variáveis globais
----------------------------------------
rooms = BiList.new()
activeRooms = Set.new()
doors = BiList.new()
walls = BiList.new()

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
---@field doorsTimer Timer
---@field destructibles Destructible[]
---@field interactives Interactive[]
---@field drops Drop[]
---@field enemies Enemy[]
---@field npcs Npc[]
---@field obstacles Obstacle[]
---@field adjacentRooms Vec[]
---@field playersInRoom Set
---@field linkManager LinkManager
---@field collisionGrid SpatialGrid
---@field update fun(dt: number) : nil
---@field setExplored fun()
---@field createAdjacentRooms fun()
---@field getAdjacentPos fun() : Vec[]
---@field onPlayerEnter fun(Player)
---@field onPlayerExit fun(Player)
---@field openDoors function
---@field closeDoors function
---@field updateDoorsLogic fun(dt)
---@field populate function
---@field spawn function
---@field addWallsAndDoors fun()
---@field getDoorIndex fun(doorName: string) : Vec?
---@field getDoors fun() : Interactive[]
---@field getWallIndex fun(wallName: string) : Vec?
---@field getWalls fun() : Obstacle[]
---@field addBuilding fun(building: Product) : Interactive
---@field isInCombat fun() : boolean
---@field getRoomAt fun(pos: Vec) : Room | nil
---@field newRoom fun(pos: Vec, dimensions: Size, roomType?: RoomType)
---@field createInitialRooms function
---@field makeKey fun(x: number, y: number) : string

Room = {}
Room.__index = Room
Room.type = ROOM
Room.stdDim = { width = 1536, height = 1536 }
Room.spacingV = 96
Room.spacingH = 96
-- Tamanho-base das células para a broad phase de colisão. Será calibrado por profiling.
Room.collisionGridCellSize = 192

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
	room.roomType = blueprint.roomType               -- tipo da sala
	room.name = blueprint.roomName                   -- nome da sala
	room.sprites = sprites                           -- os sprites da sala em camadas
	room.collisionGrid = SpatialGrid.new(room.limits, Room.collisionGridCellSize)
	-- atributos fixos na instanciação
	room.adjacentRooms = {}                          -- salas adjacentes
	room.explored = false                            -- se algum jogador já entrou na sala ou não
	room.destructibles = {}                          -- lista de objetos destrutíveis da sala
	room.interactives = {}                           -- lista de objetos interativos na sala
	room.drops = {}                                  -- lista de itens dropados na sala
	room.enemies = {}                                -- lista de inimigos na sala
	room.npcs = {}                                   -- lista de NPCs na sala
	room.obstacles = {}                              -- lista de obstáculos na sala
	room.playersInRoom = Set.new()                   -- lista de jogadores na sala
	room.linkManager = LinkManager.new()             -- gerenciador de links da sala
	room.uiManager = newRoomUIManager(room)          -- gerenciador de UI da sala
	room.doorsTimer = Timer.new(3)                   -- timer para fechar a sala

	room:addWallsAndDoors()

	return room
end

---@param dt number
-- atualiza os destrutíveis, inimigos e drops da sala
function Room:update(dt)
	-- atualiza destrutíveis
	for _, d in pairs(self.destructibles) do
		d:update(dt)
	end
	-- atualiza objetos interativos
	for _, i in pairs(self.interactives) do
		i:update(dt)
	end
	-- atualiza obstáculos
	for _, o in pairs(self.obstacles) do
		o:update(dt)
	end
	-- atualiza drops
	for _, drop in pairs(self.drops) do
		drop:update(dt)
	end
	-- atualiza inimigos
	for _, e in pairs(self.enemies) do
		e:update(dt)
	end
	-- atualiza NPCs
	for _, npc in pairs(self.npcs) do
		npc:update(dt)
	end
	-- atualiza portas
	for _, door in pairs(self:getDoors()) do
		door:update(dt)
	end

	self.linkManager:update(dt)
	self.uiManager:update(dt)
	self:updateDoorsLogic(dt)
end

-- define a sala como estando explorada, gerando as 4 salas
-- vizinhas à ela
function Room:setExplored()
	if self.explored then
		return
	end
	self.explored = true
	collisionManager.roomsDirty = true
end

-- cria salas adjacentes se ainda não existirem
function Room:createAdjacentRooms()
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

---@param player Player
-- lida com a entrada do player em salas, adicionando
-- e iniciando as especificidades da sala
function Room:onPlayerEnter(player)
	if self.playersInRoom:has(player.id) then
		return
	end

	self.playersInRoom:add(player.id, player)
	player.room = self
	activeRooms:add(makeKey(self.arrPos.x, self.arrPos.y), self)
	collisionManager.roomsDirty = true
	self:createAdjacentRooms()

	if self.roomType == BOSS_ROOM then
		self.uiManager:toggleScene(UI_BOSS_LIFE_BAR_SCENE)
	end

	if not self.explored then
		if not (self.roomType == BATTLE_ROOM or self.roomType == BOSS_ROOM) then
			self:setExplored()
		else
			self.doorsTimer:startOrContinue()
		end
	end
end

---@param player Player
-- lida com a saída do player de salas
function Room:onPlayerExit(player)
	self.playersInRoom:remove(player.id)

	if self.playersInRoom:size() == 0 then
		if self.roomType == BOSS_ROOM then
			self.uiManager:toggleScene(UI_BOSS_LIFE_BAR_SCENE)
		end
		if not self.explored and (self.roomType == BOSS_ROOM or self.roomType == BATTLE_ROOM) then
			self.doorsTimer:restart()
		end
		activeRooms:remove(makeKey(self.arrPos.x, self.arrPos.y))
		collisionManager.roomsDirty = true
	end
end

-- Lida com a abertura de portas
function Room:openDoors()
	for _, d in pairs(self:getDoors()) do
		d:onInteract()
	end
end

-- Lida com o fechamento de portas
function Room:closeDoors()
	for _, d in pairs(self:getDoors()) do
		d:customCloseInteract()
	end
end

---@param dt number
-- lida com o timer para abertura e fechamento de portas
-- e com a conclusão de combates em sala de combate
function Room:updateDoorsLogic(dt)
	self.doorsTimer:update(dt)
	if not self.explored and not self:isInCombat() then
		self:setExplored()
		self:openDoors()
		if self.doorsTimer.active then
			self.doorsTimer:stop()
			self.doorsTimer.goingOff = false
		end
	end
	if self.doorsTimer.goingOff then
		self:closeDoors()
	end
end

---@param spawnpoints SpawnPoint[]
---@param rng RNG
-- geração dos conteúdos de uma sala
function Room:populate(spawnpoints, rng)
	for _, sp in pairs(spawnpoints) do
		local n = rng:random()
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
	-- perdoe a quantidade de números mágicos nessa função T~T
	local doors = { DOOR_UP, DOOR_LEFT, DOOR_RIGHT, DOOR_DOWN }
	local doorsRelPos = {
		vec(0, -Room.stdDim.height / 2 - 120),
		vec(-Room.stdDim.width / 2 - 47, -120),
		vec(Room.stdDim.width / 2 + 47, -120),
		vec(0, Room.stdDim.height / 2 + 40),
	}
	local walls = { WALL_UP, WALL_DOWN, WALL_LEFT_BACK, WALL_LEFT_FRONT, WALL_RIGHT_BACK, WALL_RIGHT_FRONT }
	local wallsRelPos = {
		vec(0, -Room.stdDim.height / 2 - 114),
		vec(0, Room.stdDim.height / 2 + 114),
		vec(-Room.stdDim.width / 2 - 44, -Room.stdDim.height / 2 + 282),
		vec(-Room.stdDim.width / 2 - 44, 258),
		vec(Room.stdDim.width / 2 + 44, -Room.stdDim.height / 2 + 282),
		vec(Room.stdDim.width / 2 + 44, 258),
	}
	for i = 1, #doors do
		CONSTRUCTORS[doors[i].type][doors[i].name](addVec(self.pos, doorsRelPos[i]), self, doors[i])
	end
	for i = 1, #walls do
		CONSTRUCTORS[walls[i].type][walls[i].name](addVec(self.pos, wallsRelPos[i]), self)
	end
end

---@param doorName string
---@return Vec?
-- retorna o índice na array global de portas de uma porta com nome doorName (uma das 4 direções)
function Room:getDoorIndex(doorName)
	if doorName == DOOR_UP.name then
		return vec(self.arrPos.y * 3 - 1, self.arrPos.x)
	elseif doorName == DOOR_DOWN.name then
		return vec(self.arrPos.y * 3 + 1, self.arrPos.x)
	elseif doorName == DOOR_LEFT.name then
		return vec(self.arrPos.y * 3, self.arrPos.x)
	elseif doorName == DOOR_RIGHT.name then
		return vec(self.arrPos.y * 3, self.arrPos.x + 1)
	end
end

---@return Interactive[]
-- retorna todas as portas que conectam esta sala com as adjacentes
function Room:getDoors()
	local doorTypes = { DOOR_UP, DOOR_DOWN, DOOR_LEFT, DOOR_RIGHT }
	local roomDoors = {}
	for _, dt in pairs(doorTypes) do
		local idx = self:getDoorIndex(dt.name)
		table.insert(roomDoors, doors[idx.y][idx.x])
	end
	return roomDoors
end

---@param wallName string
---@return Vec?
-- retorna o índice na array global de paredes de uma parede com nome wallName (uma das 6 possíveis)
function Room:getWallIndex(wallName)
	if wallName == WALL_UP.name then
		return vec(self.arrPos.y * 4 - 1, self.arrPos.x)
	elseif wallName == WALL_DOWN.name then
		return vec(self.arrPos.y * 4 + 2, self.arrPos.x)
	elseif wallName == WALL_LEFT_BACK.name then
		return vec(self.arrPos.y * 4, self.arrPos.x)
	elseif wallName == WALL_LEFT_FRONT.name then
		return vec(self.arrPos.y * 4 + 1, self.arrPos.x)
	elseif wallName == WALL_RIGHT_BACK.name then
		return vec(self.arrPos.y * 4, self.arrPos.x + 1)
	elseif wallName == WALL_RIGHT_FRONT.name then
		return vec(self.arrPos.y * 4 + 1, self.arrPos.x + 1)
	end
end

---@return Obstacle[]
-- retorna todas as paredes que separam esta sala das adjacentes
function Room:getWalls()
	local wallTypes = { WALL_UP, WALL_DOWN, WALL_LEFT_BACK, WALL_LEFT_FRONT, WALL_RIGHT_BACK, WALL_RIGHT_FRONT }
	local roomWalls = {}
	for _, wt in pairs(wallTypes) do
		local idx = self:getWallIndex(wt.name)
		table.insert(roomWalls, walls[idx.y][idx.x])
	end
	return roomWalls
end

---@param building Product
---@return Interactive
-- torna uma construção tangível e insere ela na sala, registrando sua hitbox
function Room:addBuilding(building)
	local interactive = building.makeInteractive(building.pos, self)
	table.insert(self.interactives, interactive)
	collisionManager:register(interactive)
	return interactive
end

---@return boolean
-- devolve se a sala está ou não em combate
function Room:isInCombat()
	if self.roomType ~= BATTLE_ROOM and self.roomType ~= BOSS_ROOM or self.playersInRoom:size() == 0 then
		return false
	end
	for _, e in pairs(self.enemies) do
		if not e.isReallyDead then
			return true
		end
	end
	return false
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

---@param pos Vec
---@param dimensions Size
---@param roomType? RoomType
-- cria uma nova sala no índice indicado por `pos` da
-- lista global de salas (`rooms`)
function newRoom(pos, dimensions, roomType)
	if not rooms[pos.y] then
		rooms:insert(pos.y, BiList.new())
	end

	local currRoom = rooms[pos.y][pos.x]
	if currRoom then
		-- TODO: remover entidades da sala antiga
		activeRooms:remove(makeKey(pos.x, pos.y))
		collisionManager:unregister(currRoom)
		for _, adjPos in pairs(currRoom.adjacentRooms) do
			local adjRoom = getRoomAt(adjPos)
			if adjRoom then
				collisionManager:unregister(adjRoom)
			end
		end
	end

	-- criando um gerador de números pseudo-aleatórios para a sala
	local roomRNG = love.math.newRandomGenerator(getRoomSeed(worldSeed, pos.x, pos.y))
	-- escolhendo uma blueprint para a sala
	roomType = roomType or randRoomType(roomRNG)
	local blueprint = randRoomBlueprint(roomType, roomRNG)

	-- posicionando a sala
	local leftLimit = pos.x * (dimensions.width + Room.spacingH) - Room.spacingH
	local topLimit = pos.y * (dimensions.height + Room.spacingV) - Room.spacingV
	local rightLimit = leftLimit + dimensions.width + Room.spacingH
	local bottomLimit = topLimit + dimensions.height + Room.spacingV
	local p1 = vec(leftLimit, topLimit)
	local p2 = vec(rightLimit, bottomLimit)
	local limits = { p1 = p1, p2 = p2 }
	local hb = hitbox(Rectangle.new(dimensions.width + Room.spacingH, dimensions.height + Room.spacingV), vec(0, -40))
	local hbs = hitboxes({}, {}, { hb })

	-- decorando a sala
	local sprites = {}
	--sprites.floor = love.graphics.newImage("assets/sprites/rooms/test_room.png")
	sprites.floor = assetManager:getImage("assets/sprites/rooms/test_room.png")

	-- instanciando e populando com entidades (inimigos, destrutíveis, etc)
	local room = Room.new(pos, dimensions, hbs, limits, blueprint, sprites)
	room:populate(blueprint.spawnpoints, roomRNG)
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
