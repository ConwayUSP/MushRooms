-----------------------------
--- Classe LinkManager
------------------------------
---@class LinkManager
---@field links Link[]
---@field linksMap any
---@field addLink fun(self, entityA: Entity, entityB: Entity, maxDistance: number, duration: number): Link

LinkManager = {}
LinkManager.__index = LinkManager

function LinkManager.new()
  local self = setmetatable({}, LinkManager)
  self.links = {}
  self.linksMap = {}

  return self
end

function LinkManager:addLink(entityA, entityB, maxDistance, duration)
  self.linksMap[entityA] = self.linksMap[entityA] or {}
  self.linksMap[entityB] = self.linksMap[entityB] or {}

  local link = self.linksMap[entityA][entityB] or self.linksMap[entityB][entityA]

  if link then
    link.maxDistance = maxDistance
    link.timer:restart()
    return link
  end

  link = Link.new(entityA, entityB, maxDistance, duration)
  table.insert(self.links, link)

  self.linksMap[entityA][entityB] = link
  self.linksMap[entityB][entityA] = link

  return link
end

function LinkManager:update(dt)
  for i = #self.links, 1, -1 do
    local link = self.links[i]
    if not link.timer.active then
      local a = link.entityA
      local b = link.entityB
      self.linksMap[a][b] = nil
      self.linksMap[b][a] = nil

      table.remove(self.links, i)
    else
      link:update(dt)
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
---@field maxDistance number
---@field timer Timer

Link = {}
Link.__index = Link

function Link.new(entityA, entityB, maxDistance, duration)
  local self = setmetatable({}, Link)
  self.entityA = entityA
  self.entityB = entityB
  self.maxDistance = maxDistance
  self.timer = Timer.new(duration, true)
  self.timer:start()

  return self
end

function Link:update(dt)
  if not self.timer.active then
    return
  end

  if self.entityA.hp <= 0 or self.entityB.hp <= 0 then
    self.timer:stop()
    return
  end

  self.timer:update(dt)

  local dir = subVec(self.entityB.pos, self.entityA.pos)
  local d = lenVec(dir)
  local excess = d - self.maxDistance
  local k = 0.5
  applyForce(self.entityA, scaleVec(dir, excess * k))
  applyForce(self.entityB, scaleVec(dir, -excess * k))
end

function Link:draw(camera)
  local a = camera:viewPos(self.entityA.pos)
  local b = camera:viewPos(self.entityB.pos)

  love.graphics.push()
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.setLineWidth(4)
  love.graphics.line(a.x, a.y, b.x, b.y)
  love.graphics.pop()
end