----------------------------------------
-- Importações de Módulos
----------------------------------------
require("modules.entities.puzzlepin")
require("modules.entities.puzzlestone")
require("modules.utils.vec")

----------------------------------------
-- Classe PuzzleGridManager
----------------------------------------

---@class PuzzleGridSettings
---@field center? Vec centro do grid em coordenadas de mundo; usa room.pos por padrão
---@field size Vec dimensões positivas e inteiras do grid em tiles
---@field centerSize Vec dimensões positivas e inteiras da área central, limitadas pelo tamanho do grid
---@field pins? PuzzlePinSettings[]
---@field stones? PuzzleStoneSettings[]

---@class PuzzleGridManager
---@field room Room
---@field center Vec
---@field size Vec
---@field centerSize Vec
---@field grid table<number, table<number, PuzzleStone | false>>
---@field pieces PuzzlePiece[]
---@field piecesById table<string, PuzzlePiece>
---@field pins PuzzlePin[]
---@field stones PuzzleStone[]

PuzzleGridManager = {}
PuzzleGridManager.__index = PuzzleGridManager
PuzzleGridManager.TILE_SIZE = 150
PuzzleGridManager.GRID_COLOR = { 19 / 255, 15 / 255, 63 / 255, 1 }
PuzzleGridManager.CENTER_COLOR = { 14 / 255, 11 / 255, 47 / 255, 1 }
PuzzleGridManager.BORDER_COLOR = { 67 / 255, 68 / 255, 155 / 255, 1 }

---@param room Room
---@param settings PuzzleGridSettings
---@return PuzzleGridManager
function PuzzleGridManager.new(room, settings)
	---@type PuzzleGridManager
	local manager = setmetatable({}, PuzzleGridManager)
	local center = settings.center or room.pos

	manager.room = room
	manager.center = vec(center.x, center.y)
	manager.size = vec(settings.size.x, settings.size.y)
	manager.centerSize = vec(settings.centerSize.x, settings.centerSize.y)
	manager.grid = {}
	manager.pieces = {}
	manager.piecesById = {}
	manager.pins = {}
	manager.stones = {}

	for y = 1, manager.size.y do
		manager.grid[y] = {}
		for x = 1, manager.size.x do
			manager.grid[y][x] = false
		end
	end

	for _, pinSettings in ipairs(settings.pins or {}) do
		manager:addPin(pinSettings)
	end

	for _, stoneSettings in ipairs(settings.stones or {}) do
		manager:addStone(stoneSettings)
	end

	-- Apenas salas que recebem um puzzle passam a ter esta referência.
	room.puzzleGridManager = manager

	return manager
end

---@param piece PuzzlePiece
function PuzzleGridManager:registerPiece(piece)
	table.insert(self.pieces, piece)
	self.piecesById[piece.id] = piece
end

---@param settings PuzzlePinSettings
---@return PuzzlePin
function PuzzleGridManager:addPin(settings)
	local pin = PuzzlePin.new(settings, self)
	self:registerPiece(pin)
	table.insert(self.pins, pin)

	return pin
end

---@param settings PuzzleStoneSettings
---@return PuzzleStone
function PuzzleGridManager:addStone(settings)
	local stone = PuzzleStone.new(settings, self)
	self:registerPiece(stone)
	table.insert(self.stones, stone)
	self.grid[stone.cell.y][stone.cell.x] = stone

	return stone
end

---@param cell Vec
---@return boolean
function PuzzleGridManager:isCellInside(cell)
	return cell.x % 1 == 0
		and cell.y % 1 == 0
		and cell.x >= 1
		and cell.x <= self.size.x
		and cell.y >= 1
		and cell.y <= self.size.y
end

---@param cell Vec
---@return PuzzleStone?
function PuzzleGridManager:getStoneAt(cell)
	if not self:isCellInside(cell) then
		return nil
	end

	return self.grid[cell.y][cell.x] or nil
end

---@param cell Vec
---@return boolean
function PuzzleGridManager:isCellFree(cell)
	return self:isCellInside(cell) and self.grid[cell.y][cell.x] == false
end

---@param cell Vec
---@return Vec
function PuzzleGridManager:cellToWorld(cell)
	local centerColumn = (self.size.x + 1) / 2
	local centerRow = (self.size.y + 1) / 2
	local x = self.center.x + (cell.x - centerColumn) * self.TILE_SIZE
	local y = self.center.y + (cell.y - centerRow) * self.TILE_SIZE

	return vec(x, y)
end

---@param pos Vec
---@return Vec?
function PuzzleGridManager:worldToCell(pos)
	local centerColumn = (self.size.x + 1) / 2
	local centerRow = (self.size.y + 1) / 2
	local x = math.floor((pos.x - self.center.x) / self.TILE_SIZE + centerColumn + 0.5)
	local y = math.floor((pos.y - self.center.y) / self.TILE_SIZE + centerRow + 0.5)
	local cell = vec(x, y)

	if not self:isCellInside(cell) then
		return nil
	end

	return cell
end

---@param dt number
function PuzzleGridManager:update(dt)
	for _, piece in ipairs(self.pieces) do
		piece:update(dt)
	end
end

---@param camera Camera
function PuzzleGridManager:drawBackground(camera)
	local viewX, viewY = camera:viewPos(self.center)
	local gridWidth = self.size.x * self.TILE_SIZE
	local gridHeight = self.size.y * self.TILE_SIZE
	local centerWidth = self.centerSize.x * self.TILE_SIZE
	local centerHeight = self.centerSize.y * self.TILE_SIZE
	local padding = 15

	love.graphics.setColor(self.BORDER_COLOR[1], self.BORDER_COLOR[2], self.BORDER_COLOR[3], self.BORDER_COLOR[4])
	love.graphics.rectangle("fill", viewX - gridWidth / 2 - padding, viewY - gridHeight / 2 - padding, gridWidth + 2*padding, gridHeight + 2*padding)
	love.graphics.setColor(self.GRID_COLOR[1], self.GRID_COLOR[2], self.GRID_COLOR[3], self.GRID_COLOR[4])
	love.graphics.rectangle("fill", viewX - gridWidth / 2, viewY - gridHeight / 2, gridWidth, gridHeight)
	love.graphics.setColor(self.CENTER_COLOR[1], self.CENTER_COLOR[2], self.CENTER_COLOR[3], self.CENTER_COLOR[4])
	love.graphics.rectangle("fill", viewX - centerWidth / 2, viewY - centerHeight / 2, centerWidth, centerHeight)
	love.graphics.setColor(1, 1, 1, 1)
end

return PuzzleGridManager
