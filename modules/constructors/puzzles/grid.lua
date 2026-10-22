----------------------------------------
-- Importações de Módulos
----------------------------------------

require("modules.engine.animation")
require("modules.engine.tile")
require("modules.entities.interactive")
require("modules.systems.collision")
require("modules.systems.links")
require("modules.systems.puzzle")
require("modules.utils.easing")
require("modules.utils.shapes")
require("modules.utils.states")
require("modules.utils.timer")
require("modules.utils.utils")
require("modules.utils.vec")

----------------------------------------
-- Grid Puzzle
----------------------------------------

---@class GridPuzzle : Puzzle
---@field center Vec centro do puzzle em coordenadas de mundo
---@field size Vec número de tiles em cada eixo
---@field centerSize Vec número de tiles da área central
---@field background love.SpriteBatch fundo estático montado pelo tileset
---@field grid table<number, table<number, GridPuzzleStone | false>> stones por célula ocupada
---@field reservedCells table<number, table<number, GridPuzzleStone | false>> células de origem reservadas durante movimentos
---@field pieces table[] todas as peças interativas do puzzle
---@field pins GridPuzzlePin[] pinos disponíveis para seleção
---@field stones GridPuzzleStone[] stones móveis do puzzle
---@field pendingPinsByPlayer table<Player, table> pino selecionado e timer de cada player
---@field nextCompletionPin number próximo pino da animação de conclusão
---@field pinFinishTimer Timer controla o intervalo entre pinos finalizados
---@field completed boolean informa se o puzzle já foi concluído
---@field rewards table lista de recompensas a serem geradas ao concluir o puzzle

GridPuzzle = setmetatable({}, { __index = Puzzle })
GridPuzzle.__index = GridPuzzle

-- dimensões e tempos compartilhados pelo puzzle de grid
GridPuzzle.TILE_SIZE = 108
GridPuzzle.PENDING_SELECTION_DURATION = 5
GridPuzzle.LINK_DURATION = 5
GridPuzzle.STONE_MOVE_DURATION = 0.8
GridPuzzle.PIN_FINISH_DELAY = 0.1
GridPuzzle.PIN_INTERACTION_RADIUS = 100
GridPuzzle.STONE_INTERACTION_RADIUS = 108

local TILE_DIMENSIONS = { width = 36, height = 36 }
local TILE_SCALE = 3
local BACKGROUND_ATLAS_SIZE = 7

---@class GridPuzzleSettings
---@field center? Vec centro do grid em coordenadas de mundo; usa o centro da sala por padrão
---@field size Vec dimensões positivas e inteiras do grid em tiles
---@field centerSize Vec dimensões positivas e inteiras da área central
---@field pins? GridPuzzlePinSettings[] configurações dos pinos do perímetro
---@field stones? GridPuzzleStoneSettings[] configurações das stones iniciais

----------------------------------------
-- Pin
----------------------------------------

local PIN_FRAME_DURATION = 0.25
local PIN_FRAME_DIMENSIONS = { width = 36, height = 36 }
local PIN_HITBOX_RADIUS = 12
local ENVIRONMENT_PIN_PATH = dirPathFormat({ "assets", "sprites", "puzzle", "Pin", "Environment" })

---@class GridPuzzlePinSettings
---@field id string identificador único dentro do puzzle
---@field offset Vec posição do pino relativa ao centro do grid
---@field pullDirection Vec direção cardinal unitária para a qual o pino movimenta a stone

---@class GridPuzzlePin : Interactive
---@field puzzle GridPuzzle puzzle ao qual o pino pertence
---@field id string identificador único dentro do puzzle
---@field offset Vec posição relativa ao centro do grid
---@field pullDirection Vec direção em que o pino move a stone
---@field selectedBy table<any, boolean> fontes que mantêm o pino selecionado
---@field select fun(self: GridPuzzlePin, source: any) adiciona uma fonte de seleção
---@field deselect fun(self: GridPuzzlePin, source: any) remove uma fonte de seleção

----------------------------------------
-- Stone
----------------------------------------

local STONE_TILE_POSITIONS = {
	["-1,-1"] = vec(1, 1),
	["1,-1"] = vec(0, 1),
	["-1,1"] = vec(1, 0),
	["1,1"] = vec(0, 0),
}
local STONE_PATH = pngPathFormat({ "assets", "sprites", "puzzle", "Stone", "idle" })
local STONE_PIN_PATH = dirPathFormat({ "assets", "sprites", "puzzle", "Pin", "Stone" })

---@class GridPuzzleStoneSettings
---@field id string identificador único dentro do puzzle
---@field cell Vec posição inicial no grid
---@field direction Vec direção da quina no sprite; cada eixo é -1 ou 1

---@class GridPuzzleStone : Interactive
---@field puzzle GridPuzzle puzzle ao qual a stone pertence
---@field id string identificador único dentro do puzzle
---@field cell Vec célula atualmente ocupada no grid
---@field direction Vec direção da quina desenhada no tile
---@field selectedBy table<any, boolean> fontes que mantêm a stone selecionada
---@field moving boolean informa se a stone está em deslocamento
---@field moveStart Vec? posição de mundo no início do movimento
---@field moveTarget Vec? posição de mundo no fim do movimento
---@field moveFromCell Vec? célula reservada durante o movimento
---@field targetCell Vec? célula que será ocupada ao terminar o movimento
---@field moveElapsed number tempo já decorrido do movimento
---@field moveDuration number duração total do movimento
---@field moveLink GridLink? link visual associado ao movimento
---@field pinVisualOffset number deslocamento vertical do pino visual
---@field tile Tile tile que representa a quina da stone
---@field select fun(self: GridPuzzleStone, source: any) adiciona uma fonte de seleção
---@field deselect fun(self: GridPuzzleStone, source: any) remove uma fonte de seleção

----------------------------------------
-- Background
----------------------------------------

local BACKGROUND_PATH = pngPathFormat({ "assets", "sprites", "puzzle", "background", "tileset b" })

---@param position number
---@param size number
---@param centerStart number
---@param centerEnd number
---@return number
-- escolhe a faixa do atlas correspondente à posição em um eixo
local function backgroundAtlasIndex(position, size, centerStart, centerEnd)
	if position == 0 then
		return 0
	elseif position < centerStart then
		return 1
	elseif centerStart == centerEnd then
		return 3
	elseif position == centerStart then
		return 2
	elseif position < centerEnd then
		return 3
	elseif position == centerEnd then
		return 4
	elseif position <= size then
		return 5
	end

	return 6
end

---@param puzzle GridPuzzle
---@return love.SpriteBatch
-- monta o fundo estático usando o atlas de tiles do puzzle
local function buildBackground(puzzle)
	local tiles = {}
	for y = 0, BACKGROUND_ATLAS_SIZE - 1 do
		tiles[y] = {}
		for x = 0, BACKGROUND_ATLAS_SIZE - 1 do
			tiles[y][x] = Tile.new(BACKGROUND_PATH, vec(x, y), TILE_DIMENSIONS)
		end
	end

	local width = puzzle.size.x + 2
	local height = puzzle.size.y + 2
	local centerStartX = (puzzle.size.x - puzzle.centerSize.x) / 2 + 1
	local centerStartY = (puzzle.size.y - puzzle.centerSize.y) / 2 + 1
	local centerEndX = centerStartX + puzzle.centerSize.x - 1
	local centerEndY = centerStartY + puzzle.centerSize.y - 1
	local centerColumn = (puzzle.size.x + 1) / 2
	local centerRow = (puzzle.size.y + 1) / 2
	local tileSize = TILE_DIMENSIONS.width * TILE_SCALE
	local spriteBatch = love.graphics.newSpriteBatch(tiles[0][0].image, width * height, "static")

	for y = 0, puzzle.size.y + 1 do
		local atlasY = backgroundAtlasIndex(y, puzzle.size.y, centerStartY, centerEndY)
		for x = 0, puzzle.size.x + 1 do
			local atlasX = backgroundAtlasIndex(x, puzzle.size.x, centerStartX, centerEndX)
			local tile = tiles[atlasY][atlasX]
			local drawX = (x - centerColumn) * tileSize
			local drawY = (y - centerRow) * tileSize
			spriteBatch:add(tile.quad, drawX, drawY, 0, TILE_SCALE, TILE_SCALE, tile.offset.x, tile.offset.y)
		end
	end

	return spriteBatch
end

----------------------------------------
-- Regras Grid Puzzle
----------------------------------------

---@param piece table
---@param source any
-- marca uma peça como selecionada por uma fonte específica
local function selectPiece(piece, source)
	if piece.puzzle.completed then
		return
	end

	piece.selectedBy[source] = true
	piece.state = SELECTED
end

---@param piece table
---@param source any
-- remove a seleção de uma fonte específica
local function deselectPiece(piece, source)
	piece.selectedBy[source] = nil
	if not piece.puzzle.completed and not next(piece.selectedBy) then
		piece.state = IDLE
	end
end

---@param piece table
-- remove todas as seleções e restaura a peça ao estado inicial
local function clearPieceSelection(piece)
	piece.selectedBy = {}
	piece.state = IDLE
	piece.onInteract = nil
end

---@param piece table
-- inicia a animação definitiva de conclusão da peça
local function finishPiece(piece)
	piece.selectedBy = {}
	piece.animations[FINISHED]:reset()
	piece.state = FINISHED
	piece.onInteract = nil
end

---@param puzzle GridPuzzle
---@param cell Vec
---@return Vec
-- converte uma célula do grid em uma posição de mundo
local function cellToWorld(puzzle, cell)
	local centerColumn = (puzzle.size.x + 1) / 2
	local centerRow = (puzzle.size.y + 1) / 2

	return vec(
		puzzle.center.x + (cell.x - centerColumn) * GridPuzzle.TILE_SIZE,
		puzzle.center.y + (cell.y - centerRow) * GridPuzzle.TILE_SIZE
	)
end

---@param puzzle GridPuzzle
---@param cell Vec
---@return boolean
-- verifica se uma célula pertence ao grid
local function isCellInside(puzzle, cell)
	return cell.x % 1 == 0
		and cell.y % 1 == 0
		and cell.x >= 1
		and cell.x <= puzzle.size.x
		and cell.y >= 1
		and cell.y <= puzzle.size.y
end

---@param puzzle GridPuzzle
---@param cell Vec
---@return boolean
-- verifica se uma célula está livre para receber uma stone
local function isCellFree(puzzle, cell)
	return isCellInside(puzzle, cell)
		and puzzle.grid[cell.y][cell.x] == false
		and puzzle.reservedCells[cell.y][cell.x] == false
end

---@param puzzle GridPuzzle
---@param cell Vec
---@return GridPuzzleStone?
-- retorna a stone atual ou temporariamente reservada na célula
local function getStoneAt(puzzle, cell)
	if not isCellInside(puzzle, cell) then
		return nil
	end

	return puzzle.grid[cell.y][cell.x] or puzzle.reservedCells[cell.y][cell.x] or nil
end

---@param puzzle GridPuzzle
---@return table
-- calcula os limites da área central em coordenadas de célula
local function getCenterBounds(puzzle)
	local left = (puzzle.size.x - puzzle.centerSize.x) / 2 + 1
	local top = (puzzle.size.y - puzzle.centerSize.y) / 2 + 1

	return {
		left = left,
		right = left + puzzle.centerSize.x - 1,
		top = top,
		bottom = top + puzzle.centerSize.y - 1,
	}
end

---@param stone GridPuzzleStone
---@param centerBounds table
---@return boolean
-- verifica se uma stone de quina ocupa seu canto correto
local function isStoneCorrectlyPlaced(stone, centerBounds)
	local expectedX = stone.direction.x > 0 and centerBounds.left or centerBounds.right
	local expectedY = stone.direction.y > 0 and centerBounds.top or centerBounds.bottom

	return stone.cell.x == expectedX and stone.cell.y == expectedY
end

---@param puzzle GridPuzzle
---@return boolean
-- verifica se todas as stones necessárias ocupam a borda correta do centro
local function isComplete(puzzle)
	local bounds = getCenterBounds(puzzle)

	for y = bounds.top, bounds.bottom do
		for x = bounds.left, bounds.right do
			local isBorder = x == bounds.left or x == bounds.right or y == bounds.top or y == bounds.bottom
			if isBorder then
				local stone = getStoneAt(puzzle, vec(x, y))
				if not stone or stone.moving or not isStoneCorrectlyPlaced(stone, bounds) then
					return false
				end
			end
		end
	end

	return true
end

---@param puzzle GridPuzzle
-- toca a animação do próximo pino e agenda o restante do stagger
local function finishNextPin(puzzle)
	local pin = puzzle.pins[puzzle.nextCompletionPin]
	if not pin then
		for _, reward in ipairs(puzzle.rewards) do
			local impulseVec = {x = math.random(-500,500), y = math.random(-1200, -1000)}
			spawnDrop(reward(), puzzle.center, puzzle.room, false, -200, impulseVec)
		end

		return
	end

	finishPiece(pin)
	puzzle.nextCompletionPin = puzzle.nextCompletionPin + 1
	puzzle.pinFinishTimer:restart()
end

---@param puzzle GridPuzzle
-- encerra as interações e inicia as animações de conclusão
local function completePuzzle(puzzle)
	puzzle.completed = true
	puzzle.pendingPinsByPlayer = {}

	for _, piece in ipairs(puzzle.pieces) do
		clearPieceSelection(piece)
	end

	for _, stone in ipairs(puzzle.stones) do
		finishPiece(stone)
	end

	puzzle.nextCompletionPin = 1
	puzzle.pinFinishTimer:restart()
end

---@param puzzle GridPuzzle
-- conclui o puzzle quando todas as stones chegam às posições corretas
local function checkCompletion(puzzle)
	if not puzzle.completed and isComplete(puzzle) then
		completePuzzle(puzzle)
	end
end

---@param puzzle GridPuzzle
---@param stone GridPuzzleStone
---@param previousCell Vec
-- libera a célula de origem e encerra os efeitos do movimento
local function onStoneMoveFinished(puzzle, stone, previousCell)
	if puzzle.reservedCells[previousCell.y][previousCell.x] == stone then
		puzzle.reservedCells[previousCell.y][previousCell.x] = false
	end

	if stone.moveLink then
		puzzle.room.linkManager:removeLink(stone.moveLink)
		stone.moveLink = nil
	end

	checkCompletion(puzzle)
end

---@param stone GridPuzzleStone
---@param camera Camera
-- desenha o tile da stone e o pino visual sobreposto
local function drawStone(stone, camera)
	local viewX, viewY = camera:viewPos(stone.pos)
	stone.tile:draw(viewX, viewY, stone.scale)

	local animation = stone.animations[stone.state]
	love.graphics.draw(stone.spriteSheets[stone.state], animation.frames[animation.currFrame], viewX, viewY + stone.pinVisualOffset, 0, stone.scale, stone.scale, animation.offset.x, animation.offset.y)
end

---@param stone GridPuzzleStone
---@param dt number
-- atualiza a interpolação determinística de uma stone em movimento
local function updateStone(stone, dt)
	if not stone.moving then
		return
	end

	stone.moveElapsed = math.min(stone.moveElapsed + dt, stone.moveDuration)
	local progress = stone.moveElapsed / stone.moveDuration
	local easedProgress = Easing.inOutQuad(progress)
	stone.pos.x = lerp(stone.moveStart.x, stone.moveTarget.x, easedProgress)
	stone.pos.y = lerp(stone.moveStart.y, stone.moveTarget.y, easedProgress)

	if progress >= 1 then
		local previousCell = stone.moveFromCell
		stone.pos = vec(stone.moveTarget.x, stone.moveTarget.y)
		stone.cell = vec(stone.targetCell.x, stone.targetCell.y)
		stone.moving = false

		globalVFXManager:stopParticle(PARTICLE_PUZZLE_STONE_MOVING, stone)
		onStoneMoveFinished(stone.puzzle, stone, previousCell)
		stone.moveStart = nil
		stone.moveTarget = nil
		stone.moveFromCell = nil
		stone.targetCell = nil
		stone.vel = vec(0, 0)
		stone.acc = vec(0, 0)
	end
end

---@param piece table
---@param idlePath string
---@param selectedPath string
---@param finishedPath string
-- adiciona os três estados visuais compartilhados pelas peças do grid
local function addPieceAnimations(piece, idlePath, selectedPath, finishedPath)
	addAnimation(piece, idlePath, IDLE, newAnimSetting(1, PIN_FRAME_DIMENSIONS, 1, true, 1, 0))
	addAnimation(piece, selectedPath, SELECTED, newAnimSetting(1, PIN_FRAME_DIMENSIONS, 1, true, 1, 0))
	addAnimation(piece, finishedPath, FINISHED, newAnimSetting(2, PIN_FRAME_DIMENSIONS, PIN_FRAME_DURATION, false, 1, 0))
end

----------------------------------------
-- Regras Pin
----------------------------------------

---@param puzzle GridPuzzle
---@param pin GridPuzzlePin
---@param player Player
-- seleciona um pino e reinicia seu prazo de uso para o player
local function selectPin(puzzle, pin, player)
	if puzzle.completed then
		return
	end

	local current = puzzle.pendingPinsByPlayer[player]
	if current then
		if current.pin == pin then
			current.timer:restart()
			return
		end

		deselectPiece(current.pin, player)
	end

	local timer = Timer.new(GridPuzzle.PENDING_SELECTION_DURATION, true)
	timer:start()
	puzzle.pendingPinsByPlayer[player] = { pin = pin, timer = timer }
	selectPiece(pin, player)
	-- TODO: substituir pelo som definitivo de seleção do pino.
	globalAudioManager:play(AUDIO_SELECT, pin, "pop")
end

---@param puzzle GridPuzzle
---@param player Player
-- remove a seleção pendente do player
local function clearPendingPin(puzzle, player)
	local pending = puzzle.pendingPinsByPlayer[player]
	if not pending then
		return
	end

	deselectPiece(pending.pin, player)
	puzzle.pendingPinsByPlayer[player] = nil
end

----------------------------------------
-- Regras Pedra
----------------------------------------

---@param puzzle GridPuzzle
---@param stone GridPuzzleStone
---@param direction Vec
---@return boolean
-- move uma stone para a próxima célula livre na direção informada
local function moveStoneOneCell(puzzle, stone, direction)
	if puzzle.completed or stone.moving then
		return false
	end

	local targetCell = addVec(stone.cell, direction)
	if not isCellFree(puzzle, targetCell) then
		return false
	end

	local targetPos = cellToWorld(puzzle, targetCell)
	stone.moving = true
	stone.moveStart = vec(stone.pos.x, stone.pos.y)
	stone.moveTarget = vec(targetPos.x, targetPos.y)
	stone.moveFromCell = vec(stone.cell.x, stone.cell.y)
	stone.targetCell = vec(targetCell.x, targetCell.y)
	stone.moveElapsed = 0
	stone.moveDuration = GridPuzzle.STONE_MOVE_DURATION
	stone.vel = vec(0, 0)
	stone.acc = vec(0, 0)

	local moveDirection = normalize(subVec(targetPos, stone.pos))
	local particleOffset = scaleVec(moveDirection, -GridPuzzle.TILE_SIZE / 2)
	local particle = globalVFXManager:playParticle(PARTICLE_PUZZLE_STONE_MOVING, stone, particleOffset, true)
	if particle then
		particle:setDirection(math.atan2(-moveDirection.y, -moveDirection.x))
	end

	-- TODO: substituir pelo som definitivo de movimento da pedra.
	globalAudioManager:play(AUDIO_COLLIDE, stone, "wurr")

	puzzle.grid[stone.moveFromCell.y][stone.moveFromCell.x] = false
	puzzle.reservedCells[stone.moveFromCell.y][stone.moveFromCell.x] = stone
	puzzle.grid[targetCell.y][targetCell.x] = stone

	return true
end

---@param puzzle GridPuzzle
---@param stone GridPuzzleStone
---@param player Player
-- tenta mover uma stone usando o pino selecionado pelo player
local function interactWithStone(puzzle, stone, player)
	if puzzle.completed then
		return
	end

	local pending = puzzle.pendingPinsByPlayer[player]
	if not pending then
		return
	end

	if moveStoneOneCell(puzzle, stone, pending.pin.pullDirection) then
		local activeLink = puzzle.room.linkManager:addLink(GridLink.new(pending.pin, stone, GridPuzzle.LINK_DURATION))
		if activeLink then
			---@cast activeLink GridLink
			stone.moveLink = activeLink
			clearPendingPin(puzzle, player)
		end
	else
		-- TODO: tocar um sonzinho de "erro", pra indicar que deu ruim
		local pin = puzzle.pendingPinsByPlayer[player]
		globalAudioManager:play(AUDIO_PRESS, pin, "pfffft")
		
		clearPendingPin(puzzle, player)
	end
end

----------------------------------------
-- Criação Pin
----------------------------------------

---@param puzzle GridPuzzle
---@param settings GridPuzzlePinSettings
---@return GridPuzzlePin
-- cria um pino interativo conectado ao puzzle
local function createPin(puzzle, settings)
	local offset = vec(settings.offset.x, settings.offset.y)
	local pos = addVec(puzzle.center, offset)
	local hbs = hitboxes({ hitbox(Circle.new(PIN_HITBOX_RADIUS)) }, { hitbox(Circle.new(PIN_HITBOX_RADIUS)) }, { hitbox(Circle.new(GridPuzzle.PIN_INTERACTION_RADIUS)) })
	local onInteract = function(self, player)
		---@cast self GridPuzzlePin
		selectPin(puzzle, self, player)
	end

	local pin = Interactive.new("puzzle_pin", pos, hbs, puzzle.room, physicsSettings(math.huge, 0, 1, nil, nil, nil, 0), onInteract)
	---@cast pin GridPuzzlePin

	pin.puzzle = puzzle
	pin.id = settings.id
	pin.offset = offset
	pin.pullDirection = vec(settings.pullDirection.x, settings.pullDirection.y)
	pin.selectedBy = {}
	pin.scale = 3
	pin.select = selectPiece
	pin.deselect = deselectPiece
	addPieceAnimations(pin, pngPathFormat({ ENVIRONMENT_PIN_PATH, IDLE }), pngPathFormat({ ENVIRONMENT_PIN_PATH, SELECTED }), pngPathFormat({ ENVIRONMENT_PIN_PATH, IDLE }))
	pin.animations[FINISHED]:onFrame(2, function()
		-- TODO: substituir pelo som definitivo de descida do pino.
		globalAudioManager:play(AUDIO_PRESS, pin, "pfffft")
	end, 1)

	return pin
end

----------------------------------------
-- Criação Stone
----------------------------------------

---@param puzzle GridPuzzle
---@param settings GridPuzzleStoneSettings
---@return GridPuzzleStone
-- cria uma stone interativa conectada ao puzzle
local function createStone(puzzle, settings)
	local cell = vec(settings.cell.x, settings.cell.y)
	local hbs = hitboxes( { }, { hitbox(Rectangle.new(GridPuzzle.TILE_SIZE, GridPuzzle.TILE_SIZE)) }, { hitbox(Circle.new(GridPuzzle.STONE_INTERACTION_RADIUS)) })
	local onInteract = function(self, player)
		---@cast self GridPuzzleStone
		interactWithStone(puzzle, self, player)
	end

	local stone = Interactive.new("puzzle_stone", cellToWorld(puzzle, cell), hbs, puzzle.room, physicsSettings(math.huge, 0, 1, nil, nil, nil, 0), onInteract, nil, updateStone)
	---@cast stone GridPuzzleStone

	stone.puzzle = puzzle
	stone.id = settings.id
	stone.cell = cell
	stone.direction = vec(settings.direction.x, settings.direction.y)
	stone.selectedBy = {}
	stone.scale = 3
	stone.moving = false
	stone.moveElapsed = 0
	stone.moveDuration = 0
	stone.moveLink = nil
	stone.pinVisualOffset = -12
	stone.select = selectPiece
	stone.deselect = deselectPiece
	stone.tile = Tile.new(STONE_PATH, STONE_TILE_POSITIONS[stone.direction.x .. "," .. stone.direction.y], TILE_DIMENSIONS)
	stone.draw = drawStone
	addPieceAnimations(stone, pngPathFormat({ STONE_PIN_PATH, IDLE }), pngPathFormat({ STONE_PIN_PATH, SELECTED }), pngPathFormat({ STONE_PIN_PATH, IDLE }))

	return stone
end

----------------------------------------
-- Criação Grid Puzzle
----------------------------------------

---@param room Room
---@param settings GridPuzzleSettings
---@return GridPuzzle
-- cria um puzzle de grid composto por pinos e stones interativos
function GridPuzzle.new(room, settings, rewards) ---@diagnostic disable-line
	---@type GridPuzzle
	local puzzle = Puzzle.new(room) ---@diagnostic disable-line
	setmetatable(puzzle, GridPuzzle)

	local center = settings.center or room.pos
	puzzle.center = vec(center.x, center.y)
	puzzle.size = vec(settings.size.x, settings.size.y)
	puzzle.centerSize = vec(settings.centerSize.x, settings.centerSize.y)
	puzzle.grid = {}
	puzzle.reservedCells = {}
	puzzle.pieces = {}
	puzzle.pins = {}
	puzzle.stones = {}
	puzzle.pendingPinsByPlayer = {}
	puzzle.nextCompletionPin = 1
	puzzle.completed = false
	puzzle.background = buildBackground(puzzle)
	puzzle.pinFinishTimer = Timer.new(GridPuzzle.PIN_FINISH_DELAY, false, function()
		finishNextPin(puzzle)
	end)
	puzzle.rewards = rewards or {}

	for y = 1, puzzle.size.y do
		puzzle.grid[y] = {}
		puzzle.reservedCells[y] = {}
		for x = 1, puzzle.size.x do
			puzzle.grid[y][x] = false
			puzzle.reservedCells[y][x] = false
		end
	end

	for _, pinSettings in ipairs(settings.pins or {}) do
		local pin = createPin(puzzle, pinSettings)
		table.insert(puzzle.pieces, pin)
		table.insert(puzzle.pins, pin)
	end

	for _, stoneSettings in ipairs(settings.stones or {}) do
		local stone = createStone(puzzle, stoneSettings)
		table.insert(puzzle.pieces, stone)
		table.insert(puzzle.stones, stone)
		puzzle.grid[stone.cell.y][stone.cell.x] = stone
	end

	return puzzle
end

---@param dt number
-- atualiza os timers de seleção e conclusão do puzzle
function GridPuzzle:update(dt) ---@diagnostic disable-line
	self.pinFinishTimer:update(dt)

	local expiredPlayers = {}
	for player, pending in pairs(self.pendingPinsByPlayer) do
		pending.timer:update(dt)
		if not pending.timer.active then
			table.insert(expiredPlayers, player)
		end
	end

	for _, player in ipairs(expiredPlayers) do
		clearPendingPin(self, player)
	end
end

---@param camera Camera
-- desenha o fundo estático do puzzle
function GridPuzzle:drawBackground(camera) ---@diagnostic disable-line
	local viewX, viewY = camera:viewPos(self.center)
	love.graphics.draw(self.background, viewX, viewY)
end

---@param player Player
-- remove a seleção pendente do player ao sair da sala
function GridPuzzle:onPlayerExit(player) ---@diagnostic disable-line
	clearPendingPin(self, player)
end

---@param size Vec dimensões do grid em tiles
---@return GridPuzzlePinSettings[]
-- cria pinos alinhados a todos os tiles do perímetro do grid
function GridPuzzle.fullPerimeterPins(size)
	local gridMargin = 36
	local directionNames = {
		["0;-1"] = "up",
		["1;0"] = "right",
		["0;1"] = "down",
		["-1;0"] = "left",
	}
	local pins = {}
	local pinHalfExtent = PIN_FRAME_DIMENSIONS.width / 2

	for i = 0, 3 do
		local x = math.floor(math.sin(math.pi / 2 * i) + 0.5)
		local y = math.floor(-math.cos(math.pi / 2 * i) + 0.5)
		local direction = vec(x, y)
		local directionName = directionNames[x .. ";" .. y]
		local isHorizontalSide = x == 0
		local pinCount = isHorizontalSide and size.x or size.y
		local gridHalfExtent = (isHorizontalSide and size.y or size.x) * GridPuzzle.TILE_SIZE / 2
		local distanceFromCenter = gridHalfExtent + gridMargin + pinHalfExtent
		local sideCenter = scaleVec(direction, distanceFromCenter)
		local tangent = vec(-y, x)

		for k = 1, pinCount do
			local distanceAlongSide = (k - (pinCount + 1) / 2) * GridPuzzle.TILE_SIZE
			table.insert(pins, {
				id = "pin-" .. directionName .. "-" .. k,
				offset = addVec(sideCenter, scaleVec(tangent, distanceAlongSide)),
				pullDirection = vec(x, y),
			})
		end
	end

	return pins
end

---@param size Vec dimensões do grid em tiles
---@param margin number
---@return table
-- cria uma área protegida ao redor do grid do puzzle
function GridPuzzle.exclusionArea(size, margin)
	local halfWidth = size.x * GridPuzzle.TILE_SIZE / 2 + margin
	local halfHeight = size.y * GridPuzzle.TILE_SIZE / 2 + margin

	return {
		min = vec(-halfWidth, -halfHeight),
		max = vec(halfWidth, halfHeight),
	}
end