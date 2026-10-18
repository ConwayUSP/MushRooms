----------------------------------------
-- Importações de Módulos
----------------------------------------
require("modules.engine.assetmanager")
require("modules.utils.vec")

----------------------------------------
-- Classe Tile
----------------------------------------

---@class Tile
---@field image love.Image
---@field quad love.Quad
---@field position Vec
---@field dimensions Size
---@field offset Vec
---@field draw function

Tile = {}
Tile.__index = Tile

---@param path string
---@param position Vec posição do tile no atlas, começando em zero
---@param dimensions Size
---@return Tile
-- recorta um tile de um atlas usando sua coluna e linha
function Tile.new(path, position, dimensions)
	local tile = setmetatable({}, Tile)
	local image = assetManager:getImage(path)
	local imageWidth, imageHeight = image:getDimensions()
	local x = position.x * dimensions.width
	local y = position.y * dimensions.height

	tile.image = image
	tile.position = vec(position.x, position.y)
	tile.dimensions = dimensions
	tile.offset = vec(dimensions.width / 2, dimensions.height / 2)
	tile.quad = love.graphics.newQuad(x, y, dimensions.width, dimensions.height, imageWidth, imageHeight)

	return tile
end

---@param x number
---@param y number
---@param scale? number
-- desenha o tile centralizado na posição informada
function Tile:draw(x, y, scale)
	love.graphics.draw(self.image, self.quad, x, y, 0, scale or 1, scale or 1, self.offset.x, self.offset.y)
end

return Tile
