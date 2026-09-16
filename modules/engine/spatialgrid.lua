----------------------------------------
-- Grid Espacial por Sala
----------------------------------------

---@class SpatialGridCell
---@field x integer
---@field y integer
---@field key string
---@field entities table<Entity | Room, boolean>

---@class SpatialGrid
---@field bounds RoomLimits
---@field cellSize number
---@field columns integer
---@field rows integer
---@field cells table<string, SpatialGridCell>
SpatialGrid = {}
SpatialGrid.__index = SpatialGrid

---@param bounds RoomLimits
---@param cellSize number
---@return SpatialGrid
function SpatialGrid.new(bounds, cellSize)
	assert(cellSize > 0, "SpatialGrid cellSize precisa ser maior que zero")

	local grid = setmetatable({}, SpatialGrid)
	grid.bounds = bounds
	grid.cellSize = cellSize
	grid.columns = math.ceil((bounds.p2.x - bounds.p1.x) / cellSize)
	grid.rows = math.ceil((bounds.p2.y - bounds.p1.y) / cellSize)
	-- Estrutura esparsa: células só serão criadas quando uma entidade for indexada.
	grid.cells = {}

	return grid
end

---@param x integer
---@param y integer
---@return string
function SpatialGrid:makeKey(x, y)
	return tostring(x) .. "," .. tostring(y)
end

---@param x integer
---@param y integer
---@return boolean
function SpatialGrid:isInside(x, y)
	return x >= 0 and x < self.columns and y >= 0 and y < self.rows
end

---@param x number
---@param y number
---@return integer cellX
---@return integer cellY
function SpatialGrid:worldToCell(x, y)
	local cellX = math.floor((x - self.bounds.p1.x) / self.cellSize)
	local cellY = math.floor((y - self.bounds.p1.y) / self.cellSize)

	return cellX, cellY
end

---@param x integer
---@param y integer
---@return SpatialGridCell | nil
function SpatialGrid:getCell(x, y)
	if not self:isInside(x, y) then
		return nil
	end

	return self.cells[self:makeKey(x, y)]
end

---@param x integer
---@param y integer
---@return SpatialGridCell | nil
function SpatialGrid:getOrCreateCell(x, y)
	if not self:isInside(x, y) then
		return nil
	end

	local key = self:makeKey(x, y)
	local cell = self.cells[key]
	if not cell then
		cell = { x = x, y = y, key = key, entities = {} }
		self.cells[key] = cell
	end

	return cell
end

--- Retorna as células tocadas por um AABB. Objetos grandes poderão, portanto,
--- ser inseridos em mais de uma célula sem tratamento especial.
---@param minX number
---@param minY number
---@param maxX number
---@param maxY number
---@return SpatialGridCell[]
function SpatialGrid:getCellsForAABB(minX, minY, maxX, maxY)
	local minCellX, minCellY = self:worldToCell(minX, minY)
	local maxCellX, maxCellY = self:worldToCell(maxX, maxY)
	local cells = {}

	for y = minCellY, maxCellY do
		for x = minCellX, maxCellX do
			local cell = self:getOrCreateCell(x, y)
			if cell then
				table.insert(cells, cell)
			end
		end
	end

	return cells
end

return SpatialGrid
