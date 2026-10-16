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
	local period = (1 / frequency) or 0.1
	local time = 0

	return function(entity, dt)
		time = time + dt

		local forward = polarToVec(entity.direction or 0, entity.speed)
		local tangent = tangentVec(forward)

		local vy = math.cos(math.pi / 2 * math.floor(time / period + 1 / 2))
		local vx = (math.cos(math.pi * math.floor(time / period + 3 / 2)) + 1) / 2
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
	local r = radius / 4

	return function(entity, dt)
		local k = 20 -- intensidade de steering (applySteering)
		local f = entity.friction
		local F = k + f
		local decayP = f > 0 and math.exp(-f * dt) or 1 -- decaimento só do atrito
		local decayF = math.exp(-F * dt) -- decaimento atrito + steering
		local gain = f > 0 and (1 - decayP) / f or dt

		local dir = entity.direction or 0
		local V0 = polarToVec(angle + dir, angularSpeed * r)
		local Vend = polarToVec(angle + angularSpeed * dt + dir, angularSpeed * (r + radius * 2 * dt))

		-- W = Vend - decayF * V0;  C = k / (F + j*w) * W  (w = angularSpeed)
		local wx = Vend.x - decayF * V0.x
		local wy = Vend.y - decayF * V0.y
		local cs = k / (F * F + angularSpeed * angularSpeed)
		local cx = cs * (F * wx + angularSpeed * wy)
		local cy = cs * (F * wy - angularSpeed * wx)

		local ax = (entity.vel.x * (decayF - decayP) + cx) / gain
		local ay = (entity.vel.y * (decayF - decayP) + cy) / gain
		applyForce(entity, vec(ax * entity.mass, ay * entity.mass))

		angle = angle + angularSpeed * dt
		r = r + radius * 2 * dt
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
			-- intensidade amostrada no centro do frame (erro O(dt²) em vez
			-- de O(dt)), para a fuga não depender do FPS
			local tMid = math.min((timer - dt / 2) / duration, 1)
			local intensity = easingFunc(1 - tMid)
			-- força calculada para ser proporcional à velocidade da entidade
			local forceMag = entity.speed * entity.friction * entity.mass * 8 * intensity
			applyForce(entity, scaleVec(escapeDir, forceMag))

			-- a fronteira de fase usa o tempo cheio
			if t >= 1 then
				escapeDir = nil
				cooldown = baseCooldown + math.random()
			end
		end
	end
end

---@param duration number
---@param baseCooldown number
---@param easingFunc easingFunc
---@param angleVariance? rad
---@param forceFactor? number
---@return MovementFunc
function dashToTargetMovement(duration, baseCooldown, easingFunc, angleVariance, cooldownVariance)
	local angleVar = angleVariance or 0
	local timer = 0
	local cooldown = baseCooldown
	local dur = duration or 1.0
	local dashDir = nil
	local cooldownVar = cooldownVariance or 0

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
			local tMid = math.min((timer - dt / 2) / dur, 1)
			local intensity = easingFunc(1 - tMid)
			local forceMag = entity.speed * entity.mass * 10 * intensity

			applyForce(entity, scaleVec(dashDir, forceMag))

			if t >= 1 then
				dashDir = nil
				cooldown = baseCooldown + math.random(-cooldownVar, cooldownVar)
			end
		end
	end
end

---@param jumpDuration number
---@param restDuration number
---@param jumpForce number
---@param easingFunc function
---@param sync number
---@return MovementFunc
function jumpToTargetMovement(jumpDuration, restDuration, jumpForce, easingFunc, sync)
	local timer = sync or 0.0
	local isJumping = false
	local jumpDir = nil

	return function(entity, dt)
		if not entity.moveTargeting or not entity.moveTargeting.validTarget then
			return
		end

		timer = timer + dt

		if isJumping then
			-- fase do pulo
			local t = math.min(timer / jumpDuration, 1)
			-- a intensidade é amostrada no CENTRO do frame (timer - dt/2):
			-- amostrar na ponta do frame tem erro O(dt) e faz a distância do
			-- pulo variar com a taxa de quadros; no centro o erro é O(dt²)
			local tMid = math.min((timer - dt / 2) / jumpDuration, 1)
			local intensity = easingFunc(1 - tMid)
			local forceMag = entity.speed * entity.friction * entity.mass * jumpForce * intensity

			if jumpDir then
				applyForce(entity, scaleVec(jumpDir, forceMag))
			end

			-- verifica se o pulo acabou (fronteira de fase usa o tempo cheio)
			if t >= 1 then
				isJumping = false
				timer = 0
				jumpDir = nil
			end
		else
			-- fase de preparo para o próximo pulo
			if timer >= restDuration then
				isJumping = true
				timer = 0
				-- trava a direção do pulo no exato momento em que ele sai do chão
				jumpDir = normalize(subVec(entity.moveTargeting.targetPos, entity.pos))
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
---@param targetSpeed? number
---@return MovementFunc
function followTargetMovement(force, targetSpeed)
	force = force or 10
	return function(entity, dt)
		if not entity.moveTargeting or not entity.moveTargeting.validTarget then
			return
		end

		local dir = subVec(entity.moveTargeting.targetPos, entity.pos)
		local desiredVel = scaleVec(normalize(dir), targetSpeed or entity.speed)

		applySteering(entity, desiredVel, force)
	end
end

---@param initialSpeedCooldown fun(): number
---@param finalSpeed? number
---@param force? number
---@return MovementFunc
-- mantém o projétil rápido no início e concentra a frenagem no fim da sua duração
function deceleratingProjectileMovement(initialSpeedCooldown, finalSpeed, force)
	local initialSpeed = initialSpeedCooldown()
	local initialized = false

	return function(entity, dt)
		local launchSpeed = initialSpeed + (entity.inheritedSpeed or 0)

		if not initialized then
			entity.vel = scaleVec(polarToVec(entity.direction, 1), launchSpeed)
			initialized = true
		end

		local progress = clamp(entity.age / entity.dur, 0, 1)
		local targetSpeed = lerp(launchSpeed, finalSpeed or 0, Easing.outQuad(progress))
		local desiredVel = scaleVec(polarToVec(entity.direction, 1), targetSpeed)

		applySteering(entity, desiredVel, force or 60)
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

---@param direction Vec
---@param duration number
---@param power number
---@return boolean
-- função de movimento em dash numa direção específica.
-- retorna `true` quando o dash terminar
function dashToDirection(direction, duration, power)
	local dir = normalize(direction)
	local dur = duration
	return function(entity, dt)
		if dur <= 0 then
			return true
		end
		-- o último frame do dash avança só o tempo restante, para que a
		-- distância total seja exatamente power * duration em qualquer FPS
		local moveDt = math.min(dt, dur)
		dur = dur - dt
		local step = scaleVec(dir, power * moveDt)
		setPos(entity, addVec(entity.pos, step))
		entity.vel = step
		return false
	end
end
