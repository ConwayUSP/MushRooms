----------------------------------------
-- Importações de Módulos
----------------------------------------
require("modules.entities.obstacle")

function newWallUp(spawnPos, room)
	local solidHb1 = hitbox(Rectangle.new(700, 160), vec(-420, 0))
	local solidHb2 = hitbox(Rectangle.new(700, 160), vec(420, 0))
	local hbs = hitboxes({}, { solidHb1, solidHb2 }, {})
	local obs = Obstacle.new(WALL_UP.name, hbs, spawnPos, room)
	obs:addAnimations(newAnimSetting(1, size(512, 76), 1000, true))

	return obs
end

function newWallDown(spawnPos, room)
	local solidHb1 = hitbox(Rectangle.new(700, 228), vec(-420, 0))
	local solidHb2 = hitbox(Rectangle.new(700, 228), vec(420, 0))
	local hbs = hitboxes({}, { solidHb1, solidHb2 }, {})
	local obs = Obstacle.new(WALL_DOWN.name, hbs, spawnPos, room)
	obs:addAnimations(newAnimSetting(1, size(512, 76), 1000, true))

	return obs
end

function newWallLeftBack(spawnPos, room)
	local solidHb = hitbox(Rectangle.new(100, 700), vec(0, 16))
	local hbs = hitboxes({}, { solidHb }, {})
	local obs = Obstacle.new(WALL_LEFT_BACK.name, hbs, spawnPos, room)
	obs:addAnimations(newAnimSetting(1, size(34, 340), 1000, true))

	return obs
end

function newWallLeftFront(spawnPos, room)
	local solidHb = hitbox(Rectangle.new(100, 700), vec(0, 160))
	local hbs = hitboxes({}, { solidHb }, {})
	local obs = Obstacle.new(WALL_LEFT_FRONT.name, hbs, spawnPos, room)
	obs:addAnimations(newAnimSetting(1, size(34, 340), 1000, true))

	return obs
end

function newWallRightBack(spawnPos, room)
	local solidHb = hitbox(Rectangle.new(100, 700), vec(0, 16))
	local hbs = hitboxes({}, { solidHb }, {})
	local obs = Obstacle.new(WALL_RIGHT_BACK.name, hbs, spawnPos, room)
	obs:addAnimations(newAnimSetting(1, size(34, 340), 1000, true))

	return obs
end

function newWallRightFront(spawnPos, room)
	local solidHb = hitbox(Rectangle.new(100, 700), vec(0, 160))
	local hbs = hitboxes({}, { solidHb }, {})
	local obs = Obstacle.new(WALL_RIGHT_FRONT.name, hbs, spawnPos, room)
	obs:addAnimations(newAnimSetting(1, size(34, 340), 1000, true))

	return obs
end

function newPillar(spawnPos, room)
	local triggerHb = hitbox(Rectangle.new(300, 360), vec(-90, -40))
	local hbs = hitboxes({}, {}, { triggerHb })
	local randPillar = tostring(math.random(4))
	local obs = Obstacle.new(PILLAR.name .. randPillar, hbs, spawnPos, room)
	obs:addAnimations(newAnimSetting(1, size(95, 155), 1000, true))

	return obs
end

function newPillarBase(spawnPos, room)
	local solidHb = hitbox(Rectangle.new(120, 70), vec(0, -10))
	local hbs = hitboxes({}, { solidHb }, {})
	local randPillar = tostring(math.random(4))
	local obs = Obstacle.new(PILLAR_BASE.name .. randPillar, hbs, spawnPos, room, true)
	obs:addAnimations(newAnimSetting(1, size(46, 46), 1000, false))

	return obs
end

function newCandle(spawnPos, room)
	local hbs = hitboxes({}, {}, {})
	local randCandle = tostring(math.random(1))
	local obs = Obstacle.new(CANDLE.name .. randCandle, hbs, spawnPos, room, true)
	obs:addAnimations(newAnimSetting(2, size(20, 28), 0.35, true, 1, 0))
	obs:makeGlow(600)

	return obs
end

function newMoss(spawnPos, room)
	local hbs = hitboxes({}, {}, {})
	local randMoss = tostring(math.random(12))
	local obs = Obstacle.new(MOSS.name .. randMoss, hbs, spawnPos, room, true, true)
	obs:addAnimations(newAnimSetting(1, size(172, 115), 1000, false))

	return obs
end

function newNegative(spawnPos, room)
	local hbs = hitboxes({}, {}, {})
	local randNegative = tostring(math.random(17))
	local obs = Obstacle.new(NEGATIVE.name .. randNegative, hbs, spawnPos, room, true)
	obs:addAnimations(newAnimSetting(1, size(41, 40), 1000, false))

	return obs
end

function newSkeleton(spawnPos, room)
	local hbs = hitboxes({}, {}, {})
	local randSkeleton = tostring(math.random(6))
	local obs = Obstacle.new(SKELETON.name .. randSkeleton, hbs, spawnPos, room, true)
	obs:addAnimations(newAnimSetting(1, size(28, 24), 1000, false))

	return obs
end

function newRubbleSmall(spawnPos, room)
	local hbs = hitboxes({}, {}, {})
	local randRubble = tostring(math.random(6))
	local obs = Obstacle.new(RUBBLE_SMALL.name .. randRubble, hbs, spawnPos, room, true)
	obs:addAnimations(newAnimSetting(1, size(24, 36), 1000, false))

	return obs
end

function newRubbleBig(spawnPos, room)
	local hbs = hitboxes({}, {}, {})
	local randRubble = tostring(math.random(10))
	local obs = Obstacle.new(RUBBLE_BIG.name .. randRubble, hbs, spawnPos, room, true)
	obs:addAnimations(newAnimSetting(1, size(24, 36), 1000, false))

	return obs
end

function newCracks(spawnPos, room)
	local hbs = hitboxes({}, {}, {})
	local randCrack = tostring(math.random(6))
	local obs = Obstacle.new(CRACKS.name .. randCrack, hbs, spawnPos, room, true, true)
	obs:addAnimations(newAnimSetting(1, size(43, 15), 1000, false))

	return obs
end
