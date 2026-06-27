----------------------------------------
--- Importações de Módulos
----------------------------------------

require("modules.entities.entity")

----------------------------------------
-- Classe Mortal
----------------------------------------

---@class Mortal : Entity
---@field entity Entity
---@field maxHp number
---@field hp number
---@field defaultInvulnerableTime number
---@field burningTimer Timer
---@field burningTicks number
---@field burningDamage number
---@field healingTimer Timer
---@field fearTimer Timer
---@field invulnerableTimer number	
---@field blinkTimer number
Mortal = setmetatable({}, { __index = Entity })
Mortal.__index = Mortal

---@param name string
---@param pos? Vec
---@param hitboxes? Hitboxes
---@param room? Room
---@param entityPhysics? PhysicsSettings
---@param hp number
function Mortal:init(name, pos, hitboxes, room, entityPhysics, hp)
	Entity.init(self, name, pos, hitboxes, room, entityPhysics)

  self.maxHp = hp
  self.hp = hp

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
  self.healingTimer = Timer.new(math.huge, true) -- timer para cura ao longo do tempo
  self.fearTimer = Timer.new(math.huge, true) -- timer para efeito de medo
	self.deathTimer = 0 -- timer para efeito de morte
end

function Mortal:update(dt)
	if self.state == DYING then
		self.deathTimer = self.deathTimer + dt
		return
	end

	self:updateInvulnerability(dt)
	self.burningTimer:update(dt)
	self.healingTimer:update(dt)
	self.fearTimer:update(dt)
end

function Mortal:updateInvulnerability(dt)
	if self.invulnerableTimer > 0 then
		self.invulnerableTimer = self.invulnerableTimer - dt
	end
end

function Mortal:setInvulnerable(duration)
	self.defaultInvulnerableTime = duration or self.defaultInvulnerableTime
	self.invulnerableTimer = self.defaultInvulnerableTime
end


---@param damage number
-- função para aplicar dano à entidade, levando em conta invulnerabilidade e estado de morte
function Mortal:takeDamage(damage)
	if self.state == DYING or self.invulnerableTimer > 0 then
		return false
	end

	self:setInvulnerable()
	self.hp = math.max(self.hp - damage, 0)

	if self.hp <= 0 then
		self:die()
	end
	return true
end

function Mortal:burn(ticks, dmg)
	self.burningTicks = ticks - 1
	self.burningDamage = dmg
	self.burningTimer:start()
end

function Mortal:heal(amount)
	self.hp = math.min(self.hp + amount, self.maxHp)
end

function Mortal:applyFear(attacker, duration)
  print("Tomou sustinho!")
	self.fearTimer:start()
end

-- inicia o processo de morte do inimigo
function Mortal:die()
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

function Mortal:getQuadInfo()
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

function Mortal:drawShaders()
  ---@diagnostic disable
	if self.state ~= DYING then
		if self.invulnerableTimer > 0 then
			love.graphics.setShader(whiteShader)
			whiteShader:send("fillColor", { 1, 1, 1, 1.0 })
		elseif self.healingTimer.active then
			local u_min, v_min, u_width, v_height = self:getQuadInfo()
			love.graphics.setShader(particleShader)
			particleShader:send("time", self.healingTimer.time)
			particleShader:send("quad_info", { u_min, v_min, u_width, v_height })
			particleShader:send("heal_color", { 0.2, 0.8, 0.35 })
		elseif self.invisible then
			love.graphics.setShader(invisibilityShader)
			-- seria legal ter um jeito mais ergonômico de fazer isso:
			if self.artifacts and self.artifacts[1] and self.artifacts[1].name == INVISIBILITY_RING.name then
				invisibilityShader:send("timer", self.artifacts[1].customData.timer.time)
			elseif self.artifacts and self.artifacts[2] and self.artifacts[2].name == INVISIBILITY_RING.name then
				invisibilityShader:send("timer", self.artifacts[2].customData.timer.time)
			end
		elseif self.burningTimer.active then
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
  ---@diagnostic enable
end