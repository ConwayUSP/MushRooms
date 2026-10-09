-----------------------------
--- Classe LinkManager
------------------------------

---@class LinkManager
---@field links Link[]
---@field linksMap table<Entity, table<Entity, Link>>
---@field addLink fun(self, link: Link): Link?

LinkManager = {}
LinkManager.__index = LinkManager

function LinkManager.new()
	local self = setmetatable({}, LinkManager)
	self.links = {}
	self.linksMap = {}

	return self
end

---@param link Link
---@return Link?
function LinkManager:addLink(link)
	if not link or not link:isValid() then
		return nil
	end

	local entityA = link.entityA
	local entityB = link.entityB

	self.linksMap[entityA] = self.linksMap[entityA] or {}
	self.linksMap[entityB] = self.linksMap[entityB] or {}

	local currentLink = self.linksMap[entityA][entityB] or self.linksMap[entityB][entityA]

	if currentLink then
		currentLink:refresh(link)
		return currentLink
	end

	table.insert(self.links, link)

	self.linksMap[entityA][entityB] = link
	self.linksMap[entityB][entityA] = link
	link:onAdded()

	return link
end

---@param link Link
function LinkManager:removeLink(link)
	for i = #self.links, 1, -1 do
		if self.links[i] == link then
			local a = link.entityA
			local b = link.entityB
			link:stop()

			if self.linksMap[a] and self.linksMap[a][b] == link then
				self.linksMap[a][b] = nil
			end
			if self.linksMap[b] and self.linksMap[b][a] == link then
				self.linksMap[b][a] = nil
			end

			link:onRemoved()
			table.remove(self.links, i)
			return
		end
	end
end

function LinkManager:update(dt)
	for i = #self.links, 1, -1 do
		local link = self.links[i]
		link:update(dt)

		if not link:isActive() then
			self:removeLink(link)
		end
	end
end

function LinkManager:draw(camera)
	for _, link in pairs(self.links) do
		link:draw(camera)
	end
end

-----------------------------
--- Classe Link
------------------------------

---@class Link
---@field entityA Entity
---@field entityB Entity
---@field timer Timer?
---@field active boolean

Link = {}
Link.__index = Link

---@param entityA Entity
---@param entityB Entity
---@param duration? number
function Link:init(entityA, entityB, duration)
	self.entityA = entityA
	self.entityB = entityB
	self.active = true

	if duration then
		self.timer = Timer.new(duration, true)
		self.timer:start()
	end
end

---@param entityA Entity
---@param entityB Entity
---@param duration? number
---@return Link
function Link.new(entityA, entityB, duration)
	local self = setmetatable({}, Link)
	self:init(entityA, entityB, duration)
	return self
end

---@return boolean
function Link:isValid()
	return self.entityA ~= nil and self.entityB ~= nil
end

---@return boolean
function Link:isActive()
	return self.active and (not self.timer or self.timer.active)
end

function Link:stop()
	self.active = false
	if self.timer then
		self.timer:stop()
	end
end

-- Hooks de ciclo de vida chamados pelo LinkManager.
function Link:onAdded() end

function Link:onRemoved() end

---@param newLink Link
function Link:refresh(newLink)
	self.active = true
	if self.timer then
		self.timer:restart()
	end
end

function Link:update(dt)
	if self.timer then
		self.timer:update(dt)
	end
end

function Link:draw(camera)
	local aX, aY = camera:viewPos(self.entityA.pos)
	local bX, bY = camera:viewPos(self.entityB.pos)

	love.graphics.push()
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.setLineWidth(4)
	love.graphics.line(aX, aY, bX, bY)
	love.graphics.pop()
end

-----------------------------
--- Classe SpringLink
------------------------------

---@class SpringLink : Link
---@field maxDistance number

SpringLink = setmetatable({}, { __index = Link })
SpringLink.__index = SpringLink

---@param entityA Entity
---@param entityB Entity
---@param maxDistance number
---@param duration number
---@return SpringLink
function SpringLink.new(entityA, entityB, maxDistance, duration)
	---@type SpringLink
	local self = setmetatable({}, SpringLink)
	Link.init(self, entityA, entityB, duration)
	self.maxDistance = maxDistance
	return self
end

---@return boolean
function SpringLink:isValid()
	return Link.isValid(self) and self.entityA.hp > 0 and self.entityB.hp > 0
end

---@param newLink SpringLink
function SpringLink:refresh(newLink)
	self.maxDistance = newLink.maxDistance
	Link.refresh(self, newLink)
end

function SpringLink:update(dt)
	if not self:isActive() then
		return
	end

	if not self:isValid() then
		self:stop()
		return
	end

	Link.update(self, dt)
	if not self:isActive() then
		return
	end

	local dir = subVec(self.entityB.pos, self.entityA.pos)
	local d = lenVec(dir)
	local excess = d - self.maxDistance
	local k = 0.5
	applyForce(self.entityA, scaleVec(dir, excess * k))
	applyForce(self.entityB, scaleVec(dir, -excess * k))
end

-----------------------------
--- Classe GridLink
------------------------------

---@class GridLink : Link

GridLink = setmetatable({}, { __index = Link })
GridLink.__index = GridLink

---@param entityA PuzzlePin
---@param entityB PuzzleStone
---@param duration number
---@return GridLink
function GridLink.new(entityA, entityB, duration)
	---@type GridLink
	local self = setmetatable({}, GridLink)
	Link.init(self, entityA, entityB, duration)
	return self
end

function GridLink:onAdded()
	self.entityA:select(self)
	self.entityB:select(self)
end

function GridLink:onRemoved()
	self.entityA:deselect(self)
	self.entityB:deselect(self)
end

function GridLink:draw()
	-- Linhas desenhadas não ficaram com um resultado legal no final das contas
	-- Talvez adicionar umas partículas ao se mover fique interessante
end
