----------------------------------------
-- Classe PhysicsSettings
----------------------------------------

---@class PhysicsSettings
---@field mass number
---@field speed number
---@field friction number
---@field restitution number
---@field initialVel Vec
---@field initialAcc Vec
---@field speedRange range

---@param mass? number
---@param speed? number
---@param friction? number
---@param speedRange? range
---@param initialVel? Vec
---@param initialAcc? Vec
---@param restitution? number
---@return PhysicsSettings
-- cria uma configuração de propriedades físicas para o
-- movimento e interação dinâmica entre entidades
function physicsSettings(mass, speed, friction, speedRange, initialVel, initialAcc, restitution)
	return {
		mass = mass or 1,
		speed = speed or 0,
		friction = friction or 1,
		speedRange = speedRange or range(0, math.huge),
		initialVel = initialVel or vec(0, 0),
		initialAcc = initialAcc or vec(0, 0),
		restitution = restitution or 0,
	}
end

----------------------------------------
-- Classe Entity
----------------------------------------

---@class Entity
---@field name string
---@field pos? Vec
---@field hb? Hitboxes
---@field room? Room
---@field mass number
---@field speed number
---@field friction number
---@field vel Vec
---@field acc Vec
---@field state string
---@field speedRange range
---@field restitution number
---@field defaultInvulnerableTime number
---@field burningTimer Timer
---@field healingTimer Timer
---@field invulnerableTimer number	
---@field blinkTimer number
---@field hasShadow? boolean
---@field shadowWidth? number
Entity = {}
Entity.__index = Entity

---@param name string
---@param pos? Vec
---@param hitboxes? Hitboxes
---@param room? Room
---@param entityPhysics? PhysicsSettings
---@param hp? number
-- inicializa uma entidade com propriedades básicas.
function Entity:init(name, pos, hitboxes, room, entityPhysics, hp)
	self.name = name or ""
	self.pos = pos
	self.hb = hitboxes
	self.room = room
	self.hp = hp or 100
	self.maxHp = hp or 100

	local physics = entityPhysics and entityPhysics or physicsSettings()

	self.mass = physics.mass
	self.speed = physics.speed
	self.friction = physics.friction
	self.vel = physics.initialVel
	self.acc = physics.initialAcc
	self.speedRange = physics.speedRange
	self.restitution = physics.restitution or 0

	self.defaultInvulnerableTime = 1.0 -- tempo padrão de invulnerabilidade após levar dano
	self.invulnerableTimer = 0 -- timer de invulnerabilidade após levar dano
	self.blinkTimer = 0 -- timer para piscar o sprite do player quando invulnerável
	self.burningTicks = 0 -- número de ticks restantes para o efeito de queimadura
	self.burningDamage = 1 -- dano causado por cada tick de queimadura
	self.burningTimer = Timer.new(1.5, true, function() 
		self:takeDamage(self.burningDamage)
		if self.burningTicks > 0 then
			self.burningTicks = self.burningTicks - 1
			self.burningTimer:start()
		else
			self.burningTimer:stop()
		end
	end)
	self.healingTimer = Timer.new(math.huge, true)
end

function Entity:update(dt)
	if self.state == DYING then
		return
	end

	self:updateInvulnerability(dt)
	self.burningTimer:update(dt)
	self.healingTimer:update(dt)
end

function Entity:updateInvulnerability(dt)
	if self.invulnerableTimer > 0 then
		self.invulnerableTimer = self.invulnerableTimer - dt
		-- self.blinkTimer = (self.blinkTimer + dt * 10) % 1
	end
end

function Entity:isInvulnerable()
	return self.invulnerableTimer > 0
end

function Entity:setInvulnerable(duration)
	self.defaultInvulnerableTime = duration or self.defaultInvulnerableTime
	self.invulnerableTimer = self.defaultInvulnerableTime
end


---@param damage number
-- função para aplicar dano à entidade, levando em conta invulnerabilidade e estado de morte
function Entity:takeDamage(damage)
	if self.state == DYING or self:isInvulnerable() then
		return false
	end

	self:setInvulnerable()
	self.hp = math.max(self.hp - damage, 0)

	if self.hp <= 0 and self.die then
		self:die()
	end
	return true
end

function Entity:burn(ticks, dmg)
	self.burningTicks = ticks - 1
	self.burningDamage = dmg
	self.burningTimer:start()
end

function Entity:heal(amount)
	self.hp = math.min(self.hp + amount, self.maxHp)
end

-- inicia o processo de morte do inimigo
function Entity:die()
	---@diagnostic disable
	if self.state == DYING then
		return
	end

	self.state = DYING
	self.deathTimer = 0
	stopMovement(self)

	collisionManager:unregister(self)
	local atks = (self.atk and self.atk[self.selectedAtk].events) or (self.weapon and self.weapon.atk.events)
	for _, atk in pairs(atks) do
		collisionManager:unregister(atk)
		atk:destroy()
	end

	if self.weapon then
		self:unequipWeapon()
	end
	---@diagnostic enable
end

function Entity:nearestEnemy(maxDistance)
	maxDistance = maxDistance or math.huge
	local pos = self.pos
	local nearest = nil
	local minDist = math.huge
	local room = self.room

	if room and #room.enemies > 0 then
		for _, enemy in pairs(room.enemies) do
			if enemy ~= self and enemy.hp > 0 then
				---@diagnostic disable-next-line
				local dist = lenVec(subVec(pos, enemy.pos))
				if dist < minDist and dist <= maxDistance then
					minDist = dist
					nearest = enemy
				end
			end
		end
	end

	return nearest
end

function Entity:getQuadInfo()
	---@diagnostic disable
	local animation = self.animations[self.state]
	local quad = animation.frames[animation.currFrame]
	local qx, qy, qw, qh = quad:getViewport()
	local imgW, imgH = self.spriteSheets[self.state]:getDimensions()
	local u_min = qx / imgW
	local v_min = qy / imgH
	local u_width = qw / imgW
	local v_height = qh / imgH

	return u_min, v_min, u_width, v_height
	---@diagnostic enable
end

---@param camera Camera
-- função de renderização padrão das entidades
function Entity:draw(camera)
	---@diagnostic disable
	local viewPos = camera:viewPos(self.pos)
	local anim = self.animations[self.state]
	local quad = anim.frames[anim.currFrame]
	local offset = {
		x = anim.frameDim.width / 2,
		y = anim.frameDim.height / 2,
	}
	love.graphics.draw(self.spriteSheets[self.state], quad, viewPos.x, viewPos.y, 0, 3, 3, offset.x, offset.y)
	---@diagnostic enable
end

function Entity:drawShaders()
	if self.state ~= DYING then
		if self:isInvulnerable() then
			love.graphics.setShader(whiteShader)
			whiteShader:send("fillColor", { 1, 1, 1, 1.0 })
		elseif self.healingTimer:isActive() then
			local u_min, v_min, u_width, v_height = self:getQuadInfo()
			love.graphics.setShader(particleShader)
			particleShader:send("time", self.healingTimer.time)
			particleShader:send("quad_info", { u_min, v_min, u_width, v_height })
			particleShader:send("heal_color", { 0.2, 0.8, 0.35 })
			---@diagnostic disable
		elseif self.invisible then
			love.graphics.setShader(invisibilityShader)
			-- seria legal ter um jeito mais ergonômico de fazer isso:
			if self.artifacts and self.artifacts[1] and self.artifacts[1].name == INVISIBILITY_RING.name then
				invisibilityShader:send("timer", self.artifacts[1].customData.timer.time)
			elseif self.artifacts and self.artifacts[2] and self.artifacts[2].name == INVISIBILITY_RING.name then
				invisibilityShader:send("timer", self.artifacts[2].customData.timer.time)
			end
			---@diagnostic enable
		elseif self.burningTimer:isActive() then
			local u_min, v_min, u_width, v_height = self:getQuadInfo()
			love.graphics.setShader(particleShader)
			particleShader:send("time", self.burningTimer.time)
			particleShader:send("quad_info", { u_min, v_min, u_width, v_height })
			particleShader:send("heal_color", { 0.9, 0.25, 0.2 })
		end
	else
		deadBodyShader:send("death_timer", self.deathTimer)
		love.graphics.setShader(deadBodyShader)
	end
end
