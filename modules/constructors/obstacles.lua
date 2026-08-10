----------------------------------------
-- Importações de Módulos
----------------------------------------
require("modules.entities.obstacle")

function newWallUp(spawnPos, room)
	local scale = 3
	local solidHb1 = hitbox(Rectangle.new(700, 160), vec(-420, 0))
	local solidHb2 = hitbox(Rectangle.new(700, 160), vec(420, 0))
	local hbs = hitboxes({}, { solidHb1, solidHb2 }, {})
	local obs = Obstacle.new(WALL_UP.name, hbs, spawnPos, room, scale)
	obs:addAnimations(newAnimSetting(1, size(512, 76), 1000, true))

	return obs
end

function newWallDown(spawnPos, room)
	local scale = 3
	local solidHb1 = hitbox(Rectangle.new(700, 228), vec(-420, 0))
	local solidHb2 = hitbox(Rectangle.new(700, 228), vec(420, 0))
	local hbs = hitboxes({}, { solidHb1, solidHb2 }, {})
	local obs = Obstacle.new(WALL_DOWN.name, hbs, spawnPos, room, scale)
	obs:addAnimations(newAnimSetting(1, size(512, 76), 1000, true))

	return obs
end

function newWallLeftBack(spawnPos, room)
	local scale = 3
	local solidHb = hitbox(Rectangle.new(100, 700), vec(0, 16))
	local hbs = hitboxes({}, { solidHb }, {})
	local obs = Obstacle.new(WALL_LEFT_BACK.name, hbs, spawnPos, room, scale)
	obs:addAnimations(newAnimSetting(1, size(34, 340), 1000, true))

	return obs
end

function newWallLeftFront(spawnPos, room)
	local scale = 3
	local solidHb = hitbox(Rectangle.new(100, 700), vec(0, 160))
	local hbs = hitboxes({}, { solidHb }, {})
	local obs = Obstacle.new(WALL_LEFT_FRONT.name, hbs, spawnPos, room, scale)
	obs:addAnimations(newAnimSetting(1, size(34, 340), 1000, true))

	return obs
end

function newWallRightBack(spawnPos, room)
	local scale = 3
	local solidHb = hitbox(Rectangle.new(100, 700), vec(0, 16))
	local hbs = hitboxes({}, { solidHb }, {})
	local obs = Obstacle.new(WALL_RIGHT_BACK.name, hbs, spawnPos, room, scale)
	obs:addAnimations(newAnimSetting(1, size(34, 340), 1000, true))

	return obs
end

function newWallRightFront(spawnPos, room)
	local scale = 3
	local solidHb = hitbox(Rectangle.new(100, 700), vec(0, 160))
	local hbs = hitboxes({}, { solidHb }, {})
	local obs = Obstacle.new(WALL_RIGHT_FRONT.name, hbs, spawnPos, room, scale)
	obs:addAnimations(newAnimSetting(1, size(34, 340), 1000, true))

	return obs
end

function newPillar(spawnPos, room)
	local scale = 4
	local solidHb = hitbox(Circle.new(12 * scale), vec(0, 12 * scale))
	local triggerHb = hitbox(Rectangle.new(60 * scale, 60 * scale), vec(0, -20 * scale))
	local hbs = hitboxes({}, { solidHb }, { triggerHb })
	local randPillar = tostring(math.random(4))
	local obs = Obstacle.new(PILLAR.name .. randPillar, hbs, spawnPos, room, scale)
	obs:addAnimations(newAnimSetting(1, size(32, 64), 1000, true))

	return obs
end

function newCandle(spawnPos, room)
	local scale = 3
	local hbs = hitboxes({}, {}, {})
	local randCandle = tostring(math.random(1))
	local obs = Obstacle.new(CANDLE.name .. randCandle, hbs, spawnPos, room, scale)
	obs:addAnimations(newAnimSetting(2, size(96, 96), 0.35, true))
	obs.emitsLight = true
	obs.glowRadius = 600

	return obs
end
