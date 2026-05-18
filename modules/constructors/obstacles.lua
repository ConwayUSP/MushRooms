----------------------------------------
-- Importações de Módulos
----------------------------------------
require("modules.entities.obstacle")

function newPillar(spawnPos, room)
	local scale = 4
	local solidHb = hitbox(Circle.new(12 * scale), vec(0, 12 * scale))
	local triggerHb = hitbox(Rectangle.new(20 * scale, 40 * scale), vec(0, -8 * scale))
	local hbs = hitboxes({}, { solidHb }, { triggerHb })
	local randPillar = tostring(math.random(4))
	local obs = Obstacle.new(PILLAR.name .. randPillar, hbs, spawnPos, room, scale)

	return obs
end

function newWallUp(spawnPos, room)
	local scale = 3
	local solidHb1 = hitbox(Rectangle.new(700, 160), vec(-420, 0))
	local solidHb2 = hitbox(Rectangle.new(700, 160), vec(420, 0))
	local hbs = hitboxes({}, { solidHb1, solidHb2 }, {})
	local obs = Obstacle.new(WALL_UP.name, hbs, spawnPos, room, scale)

	return obs
end

function newWallDown(spawnPos, room)
	local scale = 3
	local solidHb1 = hitbox(Rectangle.new(700, 228), vec(-420, 0))
	local solidHb2 = hitbox(Rectangle.new(700, 228), vec(420, 0))
	local hbs = hitboxes({}, { solidHb1, solidHb2 }, {})
	local obs = Obstacle.new(WALL_DOWN.name, hbs, spawnPos, room, scale)

	return obs
end

function newWallLeftBack(spawnPos, room)
	local scale = 3
	local solidHb = hitbox(Rectangle.new(100, 700), vec(0, 16))
	local hbs = hitboxes({}, { solidHb }, {})
	local obs = Obstacle.new(WALL_LEFT_BACK.name, hbs, spawnPos, room, scale)

	return obs
end

function newWallLeftFront(spawnPos, room)
	local scale = 3
	local solidHb = hitbox(Rectangle.new(100, 700), vec(0, 160))
	local hbs = hitboxes({}, { solidHb }, {})
	local obs = Obstacle.new(WALL_LEFT_FRONT.name, hbs, spawnPos, room, scale)

	return obs
end

function newWallRightBack(spawnPos, room)
	local scale = 3
	local solidHb = hitbox(Rectangle.new(100, 700), vec(0, 16))
	local hbs = hitboxes({}, { solidHb }, {})
	local obs = Obstacle.new(WALL_RIGHT_BACK.name, hbs, spawnPos, room, scale)

	return obs
end

function newWallRightFront(spawnPos, room)
	local scale = 3
	local solidHb = hitbox(Rectangle.new(100, 700), vec(0, 160))
	local hbs = hitboxes({}, { solidHb }, {})
	local obs = Obstacle.new(WALL_RIGHT_FRONT.name, hbs, spawnPos, room, scale)

	return obs
end
