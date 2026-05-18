----------------------------------------
-- Importações de Módulos
----------------------------------------
require("modules.entities.interactive")

function newTurtle(spawnPos, room)
	local physics = physicsSettings(2, 800, 0.6, nil, nil, nil, 0.5)
	local defaulthb = { hitbox(Circle.new(20)) }
	local solidhb = { hitbox(Circle.new(20)) }
	local triggerhb = { hitbox(Circle.new(100)) }
	local hbs = hitboxes(defaulthb, solidhb, triggerhb)
	-- ao interagir com a tartaruga, você chuta ela para longe
	local onInteract = function(turtle, player)
		local forceDir = normalize(subVec(turtle.pos, player.pos))
		local forceVec = scaleVec(forceDir, 60000)
		applyForce(turtle, forceVec)
		turtle.state = MOVING
	end
	local update = function(turtle, dt)
		applyPhysics(turtle, dt)
		if lenVec(turtle.vel) < 20 then
			turtle.vel = vec(0, 0)
		end
		if nullVec(turtle.vel) then
			turtle.state = IDLE
		end
	end
	local turtle = Interactive.new("turtle", spawnPos, hbs, room, physics, onInteract, update)
	local animSettings = {}
	animSettings[IDLE] = newAnimSetting(2, { width = 32, height = 32 }, 0.2, true, 1)
	animSettings[MOVING] = newAnimSetting(8, { width = 32, height = 32 }, 0.08, true, 1)
	turtle:addAnimations(animSettings)
end

---------- DOORS ----------
local onInteractDoor = function(door, player)
	if door.state == OPEN then
		door.state = CLOSING
		door.closingTimer = 0.05 * 17 -- sincroniza com a animação
		door.animations[OPENING]:reset()
	elseif door.state == CLOSED then
		door.state = OPENING
		door.openingTimer = 0.05 * 19 -- mesma coisa
		door.animations[CLOSING]:reset()
	end
end

local updateDoor = function(door, dt)
	if door.state == OPENING then
		local oldTimer = door.openingTimer
		door.openingTimer = door.openingTimer - dt
		if oldTimer > 0.6 and door.openingTimer < 0.6 then
			collisionManager:unregister(door)
			door.hb.solids = {}
		end
		if door.openingTimer < 0 then
			door.state = OPEN
		end
	elseif door.state == CLOSING then
		local oldTimer = door.closingTimer
		door.closingTimer = door.closingTimer - dt
		if oldTimer > 0.3 and door.closingTimer < 0.3 then
			-- o hitbox depende da direção da porta
			if door.name == DOOR_UP.name or door.name == DOOR_DOWN.name then
				door.hb.solids = { hitbox(Rectangle.new(140, 80)) }
			else
				door.hb.solids = { hitbox(Rectangle.new(60, 200), vec(0, 100)) }
			end
			collisionManager:register(door)
		end
		if door.closingTimer < 0 then
			door.state = CLOSED
		end
	end
end

function newDoor(spawnPos, room, doorType)
	local physics = physicsSettings(math.huge, 0, 0, nil, nil, nil, 0.0)
	local hbs = hitboxes({}, {}, {})
	local door = Interactive.new(doorType.name, spawnPos, hbs, room, physics, onInteractDoor, updateDoor)

	door.state = OPEN
	door.openingTimer = 0 ---@diagnostic disable-line
	door.closingTimer = 0 ---@diagnostic disable-line

	local animSettings = {}

	if doorType == DOOR_UP or doorType == DOOR_DOWN then
		animSettings[OPEN] = newAnimSetting(1, { width = 64, height = 64 }, 1000, true, 1)
		animSettings[CLOSED] = newAnimSetting(1, { width = 64, height = 64 }, 1000, true, 1)
		animSettings[OPENING] = newAnimSetting(19, { width = 64, height = 64 }, 0.03, false, 1)
		animSettings[CLOSING] = newAnimSetting(17, { width = 64, height = 64 }, 0.03, false, 1)
	else
		animSettings[OPEN] = newAnimSetting(1, { width = 32, height = 64 }, 1000, true, 1)
		animSettings[CLOSED] = newAnimSetting(1, { width = 32, height = 64 }, 1000, true, 1)
		animSettings[OPENING] = newAnimSetting(1, { width = 32, height = 64 }, 1000, true, 1)
		animSettings[CLOSING] = newAnimSetting(1, { width = 32, height = 64 }, 1000, true, 1)
	end

	door:addAnimations(animSettings)
end
