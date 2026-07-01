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

---@param amplitude? integer
---@param frequency? integer
---@return MovementFunc
-- um movimento em linha reta, mas com uma oscilação brusca para os lados, criando um efeito de "zig zag"
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
-- um movimento em linha reta, mas com uma oscilação suave para os lados, criando um "sine effect"
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

---@param frequency? integer
---@return MovementFunc
-- um movimento em linha reta, mas com uma oscilação quadratica, criando um efeito de "square wave"
function squaredMovement(frequency)
	local period = (1/frequency) or 0.1
	local time = 0

	return function(entity, dt)
		time = time + dt

		local forward = polarToVec(entity.direction or 0, entity.speed)
		local tangent = tangentVec(forward)

		local vy = math.cos( math.pi/2 * math.floor(time/period + 1/2) )
		local vx = (math.cos( math.pi * math.floor(time/period + 3/2) ) + 1) / 2
		local desiredVel = addVec(scaleVec(forward, vx), scaleVec(tangent, vy))

		applySteering(entity, desiredVel, 30)
	end
end

---@param frequency? number
---@return MovementFunc
-- um movimento de "passo": a velocidade da entidade oscila entre 0 e a velocidade máxima, criando um efeito de "parar e ir"
function stepMovement(frequency)
	frequency = frequency or 1
	local time = 0

	return function(entity, dt)
		time = time + dt

		local step = 1 - math.cos(2 * math.pi * frequency * time)
		local desiredVel = polarToVec(entity.direction or 0, entity.speed * step)

		applySteering(entity, desiredVel, 20)
	end
end

---@param radius number
---@param angularSpeed number
---@param speed number
---@return MovementFunc
-- um movimento orbital: a entidade orbita em torno de um ponto enquanto se move para frente
function orbitalMovement(radius, angularSpeed, speed)
	local angle = 0

	return function(entity, dt)
		angle = angle + angularSpeed * dt

		local forwardVel = polarToVec(entity.direction, speed or entity.speed)
		local orbitVel = polarToVec(angle + entity.direction - math.pi / 2, angularSpeed * radius)
		local desiredVel = addVec(forwardVel, orbitVel)

		applySteering(entity, desiredVel, 20)
	end
end

---@param radius number
---@param angularSpeed number
---@return MovementFunc
-- um movimento em espiral, onde a entidade orbita em torno de um ponto enquanto se afasta dele
function spiralMovement(radius, angularSpeed)
	local angle = 0
	local r = radius/4

	return function(entity, dt)
		angle = angle + angularSpeed * dt
		r = r + radius * 2 * dt

		local desiredVel = polarToVec(angle + (entity.direction or 0), angularSpeed * r)

		applySteering(entity, desiredVel, 20)
	end
end

---@param returnSpeed number
---@param timing number
---@param force? number
---@return MovementFunc
-- um movimento de boomerangue: a entidade se move na direção do ataque, e depois de um certo tempo retorna para o atacante
function boomerangMovement(returnSpeed, timing, force)
	timing = timing or 0.5

	return function(entity, dt)
		if entity.age < timing then
			return
		end

		local dir = subVec(entity.attacker.pos, entity.pos)

		if lenVec(dir) < 50 and entity.active then
			entity.atk.weapon.ammo = 1
			entity.atk.weapon.visible = true
			entity:destroy()
			return
		end

		local desiredVel = scaleVec(normalize(dir), returnSpeed)
		applySteering(entity, desiredVel, force or 1)
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

		if not entity.moveTargeting then
			return
		end

		-- se estiver perto e não estiver em fuga, começa a fuga
		if not escapeDir then
			local d = dist(entity.pos, entity.moveTargeting.targetPos)
			if d < safeDistance then
				escapeDir = normalize(subVec(entity.pos, entity.moveTargeting.targetPos))
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
		if not dashDir and entity.moveTargeting.validTarget then
			dashDir = normalize(subVec(entity.moveTargeting.targetPos, entity.pos))
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

---@param duration number
---@param baseCooldown number
---@param moveBuilder fun(): MovementFunc
---@return MovementFunc
function randomMovement(duration, baseCooldown, moveBuilder)
	local time = 0
	local age = 0
	local cooldown = baseCooldown
	local move = moveBuilder()

	return function(entity, dt)
		if cooldown > 0 then
			cooldown = cooldown - dt
			return
		end

		age = age + dt
		time = time + dt

		if age > duration then
			applySteering(entity, vec(0, 0), 10)
			return
		end

		move(entity, dt)
	end
end

---@param force? number
---@return MovementFunc
function followTargetMovement(force)
	force = force or 10
	return function(entity, dt)
		if not entity.moveTargeting or not entity.moveTargeting.validTarget then
			return
		end

		local dir = subVec(entity.moveTargeting.targetPos, entity.pos)
		local desiredVel = scaleVec(normalize(dir), entity.speed)

		applySteering(entity, desiredVel, force)
	end
end

function followTarget(entity, dt)
	if not entity.moveTargeting then
		return
	end

	local dir = subVec(entity.moveTargeting.targetPos, entity.pos)
	local desiredVel = scaleVec(normalize(dir), entity.speed * 2)

	applySteering(entity, desiredVel, 10)
end
