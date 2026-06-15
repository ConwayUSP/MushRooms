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

---@param period? number
---@param ampDeg? rad
---@return MovementFunc
function zigZagMovement(ampDeg, period)
	period = period or 1
	ampDeg = ampDeg or math.rad(45)
	local time = 0

	return function(entity, dt)
		time = time + dt
		local s = sign(math.fmod(time - period / 2, period) - period / 2)
		local targetAngle = (entity.direction or 0) + (ampDeg * s)
		local desiredVel = polarToVec(targetAngle, entity.speed)
		-- aplicando um steering pesado para forçar uma mudança abrupta de
		-- direção, quase que ignorando a inércia
		applySteering(entity, desiredVel, 20)
	end
end

---@param amplitude? integer
---@param frequency? integer
---@return MovementFunc
function sineMovement(amplitude, frequency)
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

---@param amplitude? integer
---@param frequency? integer
---@return MovementFunc
function sineMovement(amplitude, frequency)
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

function orbitalMovement(radius, angularSpeed, speed)
	local angle = 0

	return function(entity, dt)
		angle = angle + angularSpeed * dt

		local forwardVel = polarToVec(entity.direction, speed or entity.speed)
		local orbitVel = polarToVec(angle + math.pi/2, angularSpeed * radius)
		local desiredVel = addVec(forwardVel, orbitVel)

		applySteering(entity, desiredVel, 20)
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