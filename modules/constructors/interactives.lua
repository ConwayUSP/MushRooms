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

function newDoor(spawnPos, room)
	local physics = physicsSettings(math.huge, 0, 0, nil, nil, nil, 0.0)
	local solidhb = { hitbox(Rectangle.new(140, 80)) }
	local hbs = hitboxes({}, solidhb, {})
	-- ao interagir com a tartaruga, você chuta ela para longe
	local onInteract = function(door, player)
		if door.state == OPEN then
			door.state = CLOSING
			door.closingTimer = 0.03 * 19 -- sincroniza com a animação
			door.animations[OPENING]:reset()
		elseif door.state == CLOSED then
			door.state = OPENING
			door.openingTimer = 0.03 * 30 -- mesma coisa
			door.animations[CLOSING]:reset()
		end
	end
	local update = function(door, dt)
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
				door.hb.solids = { hitbox(Rectangle.new(140, 80)) }
				collisionManager:register(door)
			end
			if door.closingTimer < 0 then
				door.state = CLOSED
			end
		end
	end
	local door = Interactive.new("door", spawnPos, hbs, room, physics, onInteract, update)
	door.state = CLOSED
	door.openingTimer = 0 ---@diagnostic disable-line
	door.closingTimer = 0 ---@diagnostic disable-line
	local animSettings = {}
	animSettings[OPEN] = newAnimSetting(1, { width = 64, height = 64 }, 1000, true, 1)
	animSettings[CLOSED] = newAnimSetting(1, { width = 64, height = 64 }, 1000, true, 1)
	animSettings[OPENING] = newAnimSetting(30, { width = 64, height = 64 }, 0.03, false, 1)
	animSettings[CLOSING] = newAnimSetting(19, { width = 64, height = 64 }, 0.03, false, 1)
	door:addAnimations(animSettings)
end
