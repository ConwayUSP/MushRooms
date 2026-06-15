---@alias MovementFunc fun(entity: any, dt: number): nil

---@param entity any
---@param force Vec
-- aplica uma força: F = m * a
function applyForce(entity, force)
	local a = scaleVec(force, 1 / entity.mass)
	entity.acc = addVec(entity.acc, a)
end

---@param entity any
---@param dt number
-- aplica o movimento necessário na entidade, levando em conta o
-- atrito, a aceleração e a velocidade inicial
function applyPhysics(entity, dt)
	local friction = nullVec(entity.acc) and entity.friction * 5 or entity.friction
	local frictionMod = math.max(0, 1 - friction * dt)
	entity.vel = scaleVec(entity.vel, frictionMod)
	entity.vel = addVec(entity.vel, scaleVec(entity.acc, dt))
	local nextPos = addVec(entity.pos, scaleVec(entity.vel, dt))

	setPos(entity, nextPos)

	if math.abs(entity.vel.x) < 1 then
		entity.vel.x = 0
	end
	if math.abs(entity.vel.y) < 1 then
		entity.vel.y = 0
	end
	entity.acc = vec(0, 0)
end

---@param entity Entity
---@param pos Vec
-- atualiza a posição da entidade e resolve colisões sólidas
function setPos(entity, pos)
	local nextPos = vec(pos.x, pos.y)

	---@diagnostic disable-next-line
	if entity.hb and entity.hb.default and not entity.ignoreSolids then
		nextPos = collisionManager:resolveSolidCollisions(entity, nextPos)
	end

	entity.pos = nextPos
end

---@param entity any
---@param targetPos Vec
---@param dt number
-- se move na direção de um ponto específico.
-- `entity` precisa ter um atributo `entity.speed` indicando sua velocidade
function moveTowards(entity, targetPos, dt)
	local direction = normalize(subVec(targetPos, entity.pos))
	local movement = scaleVec(direction, entity.speed * dt)
	setPos(entity, addVec(entity.pos, movement))
end

---@param entity any
---@param targetVel Vec
---@param intensity? number
-- aplica uma força para aproximar a velocidade atual do objeto
-- à velocidade desejada (`targetVel`). `intensity` controla a
-- magnitude dessa força - o defaut é `100`
function applySteering(entity, targetVel, intensity)
	-- responsiveness: quão rápido ele tenta atingir a velocidade alvo (ex: 15 a 25)
	local steer = subVec(targetVel, entity.vel)
	local force = scaleVec(steer, (intensity or 100) * entity.mass)
	applyForce(entity, force)
end

---@param entity any
-- nulifica a velocidade e aceleração
function stopMovement(entity)
	entity.vel = vec(0, 0)
	entity.acc = vec(0, 0)
end

---@param entity any
---@param impulseVec Vec
-- aplica um impulso equivalente a força aplicada durante um segundo instantaneamente
-- F*Δt = m*Δv => Vf = Vi + F/m (quando Δt = 1s)
function applyImpulse(entity, impulseVec)
	entity.vel = addVec(entity.vel, scaleVec(impulseVec, 1 / entity.mass))
end
