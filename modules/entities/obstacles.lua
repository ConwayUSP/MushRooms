---@class Obstacle : Entity
---@field image table
---@field scale? number
---@field transparent boolean

Obstacle = setmetatable({}, { __index = Entity })
Obstacle.__index = Obstacle
Obstacle.type = OBSTACLE

function Obstacle.new(name, hbs, spawnPos, room, scale)
  ---@type Obstacle
  local ob = setmetatable({}, Obstacle) ---@diagnostic disable-line
  local entityPhysics = physicsSettings(math.huge, 0, 1, nil, nil, nil, 0)
  ob:init(name, spawnPos, hbs, room, entityPhysics)
  ob.scale = scale or 1

  local sprite_path = pngPathFormat({ "assets", "sprites", "obstacles", ob.name, IDLE })
  ob.image = love.graphics.newImage(sprite_path)
  ob.image:setFilter("nearest", "nearest")

  ob.transparent = false

  table.insert(room.obstacles, ob)
  return ob
end

function Obstacle:draw(camera)
  local viewPos = camera:viewPos(self.pos)
  local offset = {
    x = self.image:getWidth() / 2,
    y = self.image:getHeight() / 2,
  }

  love.graphics.setColor(1, 1, 1, self.transparent and 0.75 or 1)
  love.graphics.draw(self.image, viewPos.x, viewPos.y, 0, self.scale, self.scale, offset.x, offset.y)
  love.graphics.setColor(1, 1, 1, 1)
end
