----------------------------------------
-- Importações de Módulos
----------------------------------------
require("modules.entities.obstacles")

function newPillar(spawnPos, room)
  local scale = 4
  local solidHb = hitbox(Circle.new(12 * scale), vec(0, 12 * scale))
  local triggerHb = hitbox(Rectangle.new(20 * scale, 40 * scale), vec(0, -8 * scale))
  local hbs = hitboxes({}, { solidHb }, { triggerHb })
  local randPillar = tostring(math.random(4))
  local obs = Obstacle.new(PILLAR.name .. randPillar, hbs, spawnPos, room, scale)

  return obs
end

function newWall(spawnPos, room)
  local scale = 3
  local solidHb1 = hitbox(Rectangle.new(700, 160), vec(-420, 0))
  local solidHb2 = hitbox(Rectangle.new(700, 160), vec(420, 0))
  local hbs = hitboxes({}, { solidHb1, solidHb2 }, {})
  local obs = Obstacle.new(WALL.name, hbs, spawnPos, room, scale)

  return obs
end
