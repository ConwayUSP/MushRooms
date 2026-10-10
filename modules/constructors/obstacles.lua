----------------------------------------
-- Importações de Módulos
----------------------------------------
require("modules.entities.obstacle")

---@param rng? RNG
---@param ... number
---@return number
-- usa o gerador da sala quando disponível e mantém compatibilidade com outros spawns
local function randomFrom(rng, ...)
	if rng then
		return rng:random(...)
	end
	return math.random(...)
end

function newWallUp(spawnPos, room)
	local solidHb1 = hitbox(Rectangle.new(700, 160), vec(-420, 0))
	local solidHb2 = hitbox(Rectangle.new(700, 160), vec(420, 0))
	local hbs = hitboxes({}, { solidHb1, solidHb2 }, {})
	local obs = Obstacle.new(WALL_UP.name, hbs, spawnPos, room)
	obs:addAnimations(newAnimSetting(1, size(512, 76), 1000, true))

	return obs
end

function newWallDown(spawnPos, room)
	local solidHb1 = hitbox(Rectangle.new(700, 160), vec(-420, 0))
	local solidHb2 = hitbox(Rectangle.new(700, 160), vec(420, 0))
	local hbs = hitboxes({}, { solidHb1, solidHb2 }, {})
	local obs = Obstacle.new(WALL_DOWN.name, hbs, spawnPos, room)
	obs:addAnimations(newAnimSetting(1, size(512, 76), 1000, true))

	return obs
end

function newWallLeftBack(spawnPos, room)
	local solidHb = hitbox(Rectangle.new(100, 800), vec(0, -34))
	local hbs = hitboxes({}, { solidHb }, {})
	local obs = Obstacle.new(WALL_LEFT_BACK.name, hbs, spawnPos, room)
	obs:addAnimations(newAnimSetting(1, size(34, 340), 1000, true))

	return obs
end

function newWallLeftFront(spawnPos, room)
	local solidHb = hitbox(Rectangle.new(100, 800), vec(0, 210))
	local hbs = hitboxes({}, { solidHb }, {})
	local obs = Obstacle.new(WALL_LEFT_FRONT.name, hbs, spawnPos, room)
	obs:addAnimations(newAnimSetting(1, size(34, 340), 1000, true))

	return obs
end

function newWallRightBack(spawnPos, room)
	local solidHb = hitbox(Rectangle.new(100, 800), vec(0, -34))
	local hbs = hitboxes({}, { solidHb }, {})
	local obs = Obstacle.new(WALL_RIGHT_BACK.name, hbs, spawnPos, room)
	obs:addAnimations(newAnimSetting(1, size(34, 340), 1000, true))

	return obs
end

function newWallRightFront(spawnPos, room)
	local solidHb = hitbox(Rectangle.new(100, 800), vec(0, 210))
	local hbs = hitboxes({}, { solidHb }, {})
	local obs = Obstacle.new(WALL_RIGHT_FRONT.name, hbs, spawnPos, room)
	obs:addAnimations(newAnimSetting(1, size(34, 340), 1000, true))

	return obs
end

function newPillar(spawnPos, room, rng)
	local triggerHb = hitbox(Rectangle.new(300, 360), vec(-90, -40))
	local hbs = hitboxes({}, {}, { triggerHb })
	local randPillar = tostring(randomFrom(rng, 4))
	local obs = Obstacle.new(PILLAR.name .. randPillar, hbs, spawnPos, room, false, false, rng)
	obs:addAnimations(newAnimSetting(1, size(95, 155), 1000, true))

	return obs
end

function newPillarBase(spawnPos, room, rng)
	local solidHb = hitbox(Rectangle.new(120, 70), vec(0, -10))
	local hbs = hitboxes({}, { solidHb }, {})
	local randPillar = tostring(randomFrom(rng, 4))
	local obs = Obstacle.new(PILLAR_BASE.name .. randPillar, hbs, spawnPos, room, true, false, rng)
	obs:addAnimations(newAnimSetting(1, size(46, 46), 1000, false))

	return obs
end

function newPillarProp(spawnPos, room, rng)
	local hbs = hitboxes({}, {}, {})
	local obs = Obstacle.new(PILLAR_PROP.name, hbs, spawnPos, room, false, false, rng)
	obs:addAnimations(newAnimSetting(1, size(57, 52), 1000, false))

	return obs
end

function newCandle(spawnPos, room, rng)
	local hbs = hitboxes({}, {}, {})
	local randCandle = tostring(randomFrom(rng, 3))
	local obs = Obstacle.new(CANDLE.name .. randCandle, hbs, spawnPos, room, true, false, rng)
	obs:addAnimations(newAnimSetting(2, size(27, 36), 0.35, true, 1))
	obs:makeGlow(600)

	return obs
end

function newTorch(spawnPos, room, rng)
	local hbs = hitboxes({}, {}, {})
	local randTorch = tostring(randomFrom(rng, 1))
	local obs = Obstacle.new(TORCH.name .. randTorch, hbs, spawnPos, room, true, false, rng)
	obs:addAnimations(newAnimSetting(2, size(17, 37), 0.35, true, 1))
	obs:makeGlow(400)

	return obs
end

---@param spawnPos Vec
---@param room Room
---@param variant number
---@param rng? RNG
---@return Obstacle
local function newMossVariant(spawnPos, room, variant, rng)
	local hbs = hitboxes({}, {}, {})
	local obs = Obstacle.new(MOSS.name .. variant, hbs, spawnPos, room, true, true, rng)
	obs:addAnimations(newAnimSetting(1, size(172, 115), 1000, false))

	return obs
end

function newMoss(spawnPos, room, rng)
	return newMossVariant(spawnPos, room, randomFrom(rng, 12), rng)
end

function newSmallMoss(spawnPos, room, rng)
	local variants = { 1, 4, 5, 6, 7, 8, 9, 10, 11, 12 }
	local variant = variants[randomFrom(rng, #variants)]
	return newMossVariant(spawnPos, room, variant, rng)
end

function newBigMoss(spawnPos, room, rng)
	local variants = { 2, 3 }
	local variant = variants[randomFrom(rng, #variants)]
	return newMossVariant(spawnPos, room, variant, rng)
end

---@param spawnPos Vec ponto da parede ao qual o sprite ficará preso
---@param room Room
---@param mossType EntityReg
---@param frameDims Size[]
---@param side string
---@param rng? RNG
---@return Obstacle
local function newWallMoss(spawnPos, room, mossType, frameDims, side, rng)
	local variant = randomFrom(rng, #frameDims)
	local frameDim = frameDims[variant]
	local hbs = hitboxes({}, {}, {})
	local obs = Obstacle.new(mossType.name .. variant, hbs, vec(spawnPos.x, spawnPos.y), room, false, true, rng)

	if side == "left" then
		obs.pos.x = obs.pos.x + frameDim.width * obs.scale / 2
	elseif side == "right" then
		obs.pos.x = obs.pos.x - frameDim.width * obs.scale / 2
	else
		obs.pos.y = obs.pos.y + frameDim.height * obs.scale / 2
	end

	obs:addAnimations(newAnimSetting(1, frameDim, 1000, false))
	return obs
end

function newLeftMoss(spawnPos, room, rng)
	local frameDims = { size(190, 170), size(40, 136) }
	return newWallMoss(spawnPos, room, MOSS_LEFT, frameDims, "left", rng)
end

function newRightMoss(spawnPos, room, rng)
	local frameDims = { size(88, 256), size(30, 100) }
	return newWallMoss(spawnPos, room, MOSS_RIGHT, frameDims, "right", rng)
end

function newUpMoss(spawnPos, room, rng)
	local frameDims = { size(103, 22) }
	return newWallMoss(spawnPos, room, MOSS_UP, frameDims, "up", rng)
end

function newNegative(spawnPos, room, rng)
	local hbs = hitboxes({}, {}, {})
	local randNegative = tostring(randomFrom(rng, 17))
	local obs = Obstacle.new(NEGATIVE.name .. randNegative, hbs, spawnPos, room, true, true, rng)
	obs:addAnimations(newAnimSetting(1, size(41, 40), 1000, false))

	return obs
end

function newSkeleton(spawnPos, room, rng)
	local hbs = hitboxes({}, {}, {})
	local randSkeleton = tostring(randomFrom(rng, 6))
	local obs = Obstacle.new(SKELETON.name .. randSkeleton, hbs, spawnPos, room, true, false, rng)
	obs:addAnimations(newAnimSetting(1, size(28, 24), 1000, false))

	return obs
end

function newRubbleSmall(spawnPos, room, rng)
	local hbs = hitboxes({}, {}, {})
	local randRubble = tostring(randomFrom(rng, 6))
	local obs = Obstacle.new(RUBBLE_SMALL.name .. randRubble, hbs, spawnPos, room, true, false, rng)
	obs:addAnimations(newAnimSetting(1, size(24, 36), 1000, false))

	return obs
end

function newRubbleBig(spawnPos, room, rng)
	local hbs = hitboxes({}, {}, {})
	local randRubble = tostring(randomFrom(rng, 10))
	local obs = Obstacle.new(RUBBLE_BIG.name .. randRubble, hbs, spawnPos, room, true, false, rng)
	obs:addAnimations(newAnimSetting(1, size(24, 36), 1000, false))

	return obs
end

function newCracks(spawnPos, room, rng)
	local hbs = hitboxes({}, {}, {})
	local randCrack = tostring(randomFrom(rng, 6))
	local obs = Obstacle.new(CRACKS.name .. randCrack, hbs, spawnPos, room, true, true, rng)
	obs:addAnimations(newAnimSetting(1, size(43, 15), 1000, false))

	return obs
end
