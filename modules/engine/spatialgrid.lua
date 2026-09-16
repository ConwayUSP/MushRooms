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
---@field memberships table<Entity | Room, SpatialGridMembership>
SpatialGrid = {}
SpatialGrid.__index = SpatialGrid

---@class SpatialGridMembership
---@field minX integer
---@field minY integer
---@field maxX integer
---@field maxY integer

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
	grid.memberships = {}

	return grid
end

---@param minX number
---@param minY number
---@param maxX number
---@param maxY number
---@return integer? minCellX
---@return integer? minCellY
---@return integer? maxCellX
---@return integer? maxCellY
function SpatialGrid:getCellRangeForAABB(minX, minY, maxX, maxY)
	local minCellX, minCellY = self:worldToCell(minX, minY)
	local maxCellX, maxCellY = self:worldToCell(maxX, maxY)

	minCellX = math.max(0, minCellX)
	minCellY = math.max(0, minCellY)
	maxCellX = math.min(self.columns - 1, maxCellX)
	maxCellY = math.min(self.rows - 1, maxCellY)

	if minCellX > maxCellX or minCellY > maxCellY then
		return nil, nil, nil, nil
	end

	return minCellX, minCellY, maxCellX, maxCellY
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
function SpatialGrid:getOrCreateCellsForAABB(minX, minY, maxX, maxY)
	local minCellX, minCellY, maxCellX, maxCellY = self:getCellRangeForAABB(minX, minY, maxX, maxY)
	local cells = {}
	if not minCellX then
		return cells
	end

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

---@param entity Entity | Room
---@param minX number
---@param minY number
---@param maxX number
---@param maxY number
---@return boolean changed
function SpatialGrid:updateEntity(entity, minX, minY, maxX, maxY)
	local minCellX, minCellY, maxCellX, maxCellY = self:getCellRangeForAABB(minX, minY, maxX, maxY)
	local old = self.memberships[entity]

	if
		old
		and old.minX == minCellX
		and old.minY == minCellY
		and old.maxX == maxCellX
		and old.maxY == maxCellY
	then
		return false
	end

	self:removeEntity(entity)
	if not minCellX then
		return old ~= nil
	end

	for y = minCellY, maxCellY do
		for x = minCellX, maxCellX do
			local cell = self:getOrCreateCell(x, y)
			cell.entities[entity] = true
		end
	end

	self.memberships[entity] = {
		minX = minCellX,
		minY = minCellY,
		maxX = maxCellX,
		maxY = maxCellY,
	}
	return true
end

---@param entity Entity | Room
---@return boolean removed
function SpatialGrid:removeEntity(entity)
	local membership = self.memberships[entity]
	if not membership then
		return false
	end

	for y = membership.minY, membership.maxY do
		for x = membership.minX, membership.maxX do
			local key = self:makeKey(x, y)
			local cell = self.cells[key]
			if cell then
				cell.entities[entity] = nil
				if next(cell.entities) == nil then
					self.cells[key] = nil
				end
			end
		end
	end

	self.memberships[entity] = nil
	return true
end

--- Reúne entidades das células existentes sem criar células vazias.
---@param minX number
---@param minY number
---@param maxX number
---@param maxY number
---@param allowed? table<Entity | Room, any>
---@param excluded? Entity | Room
---@return table<Entity | Room, boolean>
function SpatialGrid:queryAABB(minX, minY, maxX, maxY, allowed, excluded)
	local minCellX, minCellY, maxCellX, maxCellY = self:getCellRangeForAABB(minX, minY, maxX, maxY)
	local entities = {}
	if not minCellX then
		return entities
	end

	for y = minCellY, maxCellY do
		for x = minCellX, maxCellX do
			local cell = self:getCell(x, y)
			if cell then
				for entity in pairs(cell.entities) do
					if entity ~= excluded and (not allowed or allowed[entity]) then
						entities[entity] = true
					end
				end
			end
		end
	end

	return entities
end

return SpatialGrid
