----------------------------------------
-- Importações de Módulos
----------------------------------------
require("modules.engine.tile")
require("modules.utils.utils")
require("modules.utils.vec")

----------------------------------------
-- Classe PuzzleBackground
----------------------------------------

---@class PuzzleBackground
---@field center Vec
---@field gridSize Vec
---@field centerSize Vec
---@field tiles Tile[][]
---@field spriteBatch love.SpriteBatch

PuzzleBackground = {}
PuzzleBackground.__index = PuzzleBackground
PuzzleBackground.TILE_DIMENSIONS = { width = 36, height = 36 }
PuzzleBackground.TILE_SCALE = 3
PuzzleBackground.ATLAS_SIZE = 7
PuzzleBackground.SPRITE_PATH = pngPathFormat({ "assets", "sprites", "puzzle", "background", "tileset b" })

---@param position number
---@param size number
---@param centerStart number
---@param centerEnd number
---@return number
-- escolhe a faixa do atlas correspondente à posição em um eixo
local function atlasIndex(position, size, centerStart, centerEnd)
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

---@param center Vec
---@param gridSize Vec
---@param centerSize Vec
---@return PuzzleBackground
function PuzzleBackground.new(center, gridSize, centerSize)
	---@type PuzzleBackground
	local background = setmetatable({}, PuzzleBackground)
	background.center = vec(center.x, center.y)
	background.gridSize = vec(gridSize.x, gridSize.y)
	background.centerSize = vec(centerSize.x, centerSize.y)
	background.tiles = {}

	for y = 0, PuzzleBackground.ATLAS_SIZE - 1 do
		background.tiles[y] = {}
		for x = 0, PuzzleBackground.ATLAS_SIZE - 1 do
			background.tiles[y][x] = Tile.new(PuzzleBackground.SPRITE_PATH, vec(x, y), PuzzleBackground.TILE_DIMENSIONS)
		end
	end

	background:buildSpriteBatch()
	return background
end

-- monta o fundo estático usando uma única imagem e vários quads
function PuzzleBackground:buildSpriteBatch()
	local image = self.tiles[0][0].image
	local width = self.gridSize.x + 2
	local height = self.gridSize.y + 2
	local centerStartX = (self.gridSize.x - self.centerSize.x) / 2 + 1
	local centerStartY = (self.gridSize.y - self.centerSize.y) / 2 + 1
	local centerEndX = centerStartX + self.centerSize.x - 1
	local centerEndY = centerStartY + self.centerSize.y - 1
	local centerColumn = (self.gridSize.x + 1) / 2
	local centerRow = (self.gridSize.y + 1) / 2
	local tileSize = self.TILE_DIMENSIONS.width * self.TILE_SCALE

	self.spriteBatch = love.graphics.newSpriteBatch(image, width * height, "static")
	for y = 0, self.gridSize.y + 1 do
		local atlasY = atlasIndex(y, self.gridSize.y, centerStartY, centerEndY)
		for x = 0, self.gridSize.x + 1 do
			local atlasX = atlasIndex(x, self.gridSize.x, centerStartX, centerEndX)
			local tile = self.tiles[atlasY][atlasX]
			local drawX = (x - centerColumn) * tileSize
			local drawY = (y - centerRow) * tileSize
			self.spriteBatch:add(tile.quad, drawX, drawY, 0, self.TILE_SCALE, self.TILE_SCALE, tile.offset.x, tile.offset.y)
		end
	end
end

---@param camera Camera
function PuzzleBackground:draw(camera)
	local viewX, viewY = camera:viewPos(self.center)
	love.graphics.draw(self.spriteBatch, viewX, viewY)
end

return PuzzleBackground
