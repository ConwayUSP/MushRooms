----------------------------------------
-- Importações de Módulos
----------------------------------------
require("modules.systems.movement")

----------------------------------------
-- Funções de Movimento
----------------------------------------
-- cada uma das funções abaixo é uma closure que retorna uma
-- função com contexto isolado capaz de mover uma entidade de
-- acordo com sua estratégia própria. As funções de movimento
-- em si possuem todas o mesmo protótipo. Portanto, a closure
-- serve para encapsular o estado do qual aquela função de
-- movimento específica depende, e recebe como argumento as
-- "configurações" que podem variar para aquele tipo de
-- movimento. Ou seja, estamos criando uma implementação do
-- padrão estratégia baseada em closures

function straightMovement()
	return function(entity, dt)
		local desiredVel = polarToVec(entity.direction or 0, entity.speed)
		applySteering(entity, desiredVel, 20)
	end
end

---@param amplitude? integer
---@param frequency? integer
---@return MovementFunc
function zigZagMovement(amplitude, frequency)
	frequency = frequency or 1
	amplitude = amplitude or 50
	local time = 0

	return function(entity, dt)
		time = time + dt

		local forward = polarToVec(entity.direction or 0, entity.speed)
		local tangent = normalize(tangentVec(forward))
		local side = scaleVec(tangent, sign(math.cos(frequency * time)) * amplitude)
		local desiredVel = addVec(forward, side)

		applySteering(entity, desiredVel, 20)
	end
end

---@param amplitude? integer
---@param frequency? integer
---@return MovementFunc
function sineMovement(amplitude, frequency)
	frequency = frequency or 1
	amplitude = amplitude or 50
	local time = 0

	return function(entity, dt)
		time = time + dt

		local forward = polarToVec(entity.direction or 0, entity.speed)
		local tangent = normalize(tangentVec(forward))
		local side = scaleVec(tangent, math.sin(frequency * time) * amplitude)
		local desiredVel = addVec(forward, side)

		applySteering(entity, desiredVel, 20)
	end
end

---@param frequency? number
---@return MovementFunc
function stepMovement(frequency)
	frequency = frequency or 1
	local time = 0

	return function(entity, dt)
		time = time + dt

		local step = 1 - math.cos(2*math.pi*frequency*time)
		local desiredVel = polarToVec(entity.direction or 0, entity.speed * step)

		applySteering(entity, desiredVel, 20)
	end
end

---@param radius number
---@param angularSpeed number
---@param speed number
---@return MovementFunc
function orbitalMovement(radius, angularSpeed, speed)
	local angle = 0

	return function(entity, dt)
		angle = angle + angularSpeed * dt

		local forwardVel = polarToVec(entity.direction, speed or entity.speed)
		local orbitVel = polarToVec(angle + entity.direction - math.pi/2, angularSpeed * radius)
		local desiredVel = addVec(forwardVel, orbitVel)

		applySteering(entity, desiredVel, 20)
	end
end

function boomerangMovement(returnSpeed, timing)
	-- local isFirst = true
	timing = timing or 0.5

	return function(entity, dt)
		-- if isFirst then
		-- 	isFirst = false
		-- 	local forward = polarToVec(entity.direction, initSpeed)
		-- 	applySteering(entity, forward, 20)
		-- end

		if entity.age < timing then
			return
		end

		local dir = subVec(entity.attacker.pos, entity.pos)

		if lenVec(dir) < 50 then
			entity.atk.weapon.ammo = 1
			entity.atk.weapon.visible = true
			entity:destroy()
			return
		end

		local desiredVel = scaleVec(normalize(dir), returnSpeed)
		applySteering(entity, desiredVel, 1)
		
	end
end

---@param safeDistance number
---@param duration number
---@param baseCooldown number
---@param angleVar? rad
---@param easingFunc? easingFunc
---@return MovementFunc
function avoidTargetMovement(safeDistance, duration, baseCooldown, angleVar, easingFunc)
	duration = duration
	angleVar = angleVar or 0
	local cooldown = baseCooldown
	local timer = 0
	local escapeDir = nil

	return function(entity, dt)
		if cooldown > 0 then
			cooldown = cooldown - dt
			return
		end

		if not entity.target then
			return
		end

		-- se estiver perto e não estiver em fuga, começa a fuga
		if not escapeDir then
			local d = dist(entity.pos, entity.target.pos)
			if d < safeDistance then
				escapeDir = normalize(subVec(entity.pos, entity.target.pos))
				escapeDir = rotateVec(escapeDir, math.random(-angleVar, angleVar))
				timer = 0
			end
		end

		if escapeDir then
			timer = timer + dt
			local t = math.min(timer / duration, 1)
			local intensity = easingFunc(1 - t)
			-- força calculada para ser proporcional à velocidade da entidade
			local forceMag = entity.speed * entity.friction * entity.mass * 8 * intensity
			applyForce(entity, scaleVec(escapeDir, forceMag))

			if t >= 1 then
				escapeDir = nil
				cooldown = baseCooldown + math.random()
			end
		end
	end
end

---@param duration number
---@param baseCooldown number
---@param angleVariance? rad
---@param easingFunc easingFunc
---@return MovementFunc
function dashToTargetMovement(duration, baseCooldown, angleVariance, easingFunc)
	local angleVar = angleVariance or 0
	local timer = 0
	local cooldown = baseCooldown
	local dur = duration or 1.0
	local dashDir = nil

	return function(entity, dt)
		if cooldown > 0 then
			cooldown = cooldown - dt
			return
		end

		-- inicio do dash
		if not dashDir and entity.target then
			dashDir = normalize(subVec(entity.target.pos, entity.pos))
			dashDir = rotateVec(dashDir, math.random(-angleVar, angleVar))
			timer = 0
		end

		if dashDir then
			timer = timer + dt
			-- o easing controla o multiplicador da força
			local t = math.min(timer / dur, 1)
			local intensity = easingFunc(1 - t)
			local forceMag = entity.speed * entity.friction * entity.mass * 10 * intensity

			applyForce(entity, scaleVec(dashDir, forceMag))

			if t >= 1 then
				dashDir = nil
				cooldown = baseCooldown + math.random()
			end
		end
	end
end

function randomMovement(duration, baseCooldown, bonusSpeed, easingFunc)
	local changeInterval = 0.25
	local time = 0
	local cooldown = baseCooldown
	local randomAngle = math.random() * 2 * math.pi
	easingFunc = easingFunc or function(t)
		return t
	end

	return function(entity, dt)
		if cooldown > 0 then
			cooldown = cooldown - dt
			return
		end

		time = time + dt
		local t = math.min(time / duration, 1)
		local intensity = easingFunc(1 - t)

		if time >= changeInterval then
			time = time - changeInterval
			randomAngle = math.random() * 2 * math.pi
		end

		local desiredVel = polarToVec(randomAngle, entity.speed * bonusSpeed * intensity)
		applySteering(entity, desiredVel, 10)
	end
end