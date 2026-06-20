----------------------------------------
-- Classe Mortal
----------------------------------------

---@class Mortal
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
Mortal = {}
Mortal.__index = Mortal

function Mortal.init(entity, hp)
  local self = setmetatable({}, Mortal)
  self.entity = entity

  entity.maxHp = hp
  entity.hp = hp

  entity.defaultInvulnerableTime = 1.0 -- tempo padrão de invulnerabilidade após levar dano
  entity.invulnerableTimer = 0 -- timer de invulnerabilidade após levar dano

  entity.blinkTimer = 0 -- timer para piscar o sprite do player quando invulnerável
  entity.burningTicks = 0 -- número de ticks restantes para o efeito de queimadura
  entity.burningDamage = 1 -- dano causado por cada tick de queimadura
  entity.burningTimer = Timer.new(1.5, true, function() 
    entity:takeDamage(entity.burningDamage)
    if entity.burningTicks > 0 then
      entity.burningTicks = entity.burningTicks - 1
      entity.burningTimer:start()
    else
      entity.burningTimer:stop()
    end
  end)
  entity.healingTimer = Timer.new(math.huge, true) -- timer para cura ao longo do tempo
  entity.fearTimer = Timer.new(math.huge, true) -- timer para efeito de medo

  return self
end

function Mortal:update(dt)
  local entity = self.entity

	if entity.state == DYING then
		return
	end

	self:updateInvulnerability(dt)
	entity.burningTimer:update(dt)
	entity.healingTimer:update(dt)
	entity.fearTimer:update(dt)
end

function Mortal:updateInvulnerability(dt)
  local entity = self.entity
	if entity.invulnerableTimer > 0 then
		entity.invulnerableTimer = entity.invulnerableTimer - dt
	end
end

function Mortal:setInvulnerable(duration)
  local entity = self.entity
	entity.defaultInvulnerableTime = duration or entity.defaultInvulnerableTime
	entity.invulnerableTimer = entity.defaultInvulnerableTime
end


---@param damage number
-- função para aplicar dano à entidade, levando em conta invulnerabilidade e estado de morte
function Mortal:takeDamage(damage)
  local entity = self.entity
	if entity.state == DYING or entity.invulnerableTimer > 0 then
		return false
	end

	self:setInvulnerable()
	entity.hp = math.max(entity.hp - damage, 0)

	if entity.hp <= 0 then
		self:die()
	end
	return true
end

function Mortal:burn(ticks, dmg)
	local entity = self.entity

	entity.burningTicks = ticks - 1
	entity.burningDamage = dmg
	entity.burningTimer:start()
end

function Mortal:heal(amount)
	local entity = self.entity

	entity.hp = math.min(entity.hp + amount, entity.maxHp)
end

function Mortal:applyFear(attacker, duration)
  print("Tomou sustinho!")
	self.entity.fearTimer:start()
end

-- inicia o processo de morte do inimigo
function Mortal:die()
  local entity = self.entity

	---@diagnostic disable
	if entity.state == DYING then
		return
	end

	entity.state = DYING
	entity.deathTimer = 0
	stopMovement(entity)

	collisionManager:unregister(entity)
	local atks = (entity.atk and entity.atk[entity.selectedAtk].events) or (entity.weapon and entity.weapon.atk.events)
	for _, atk in pairs(atks) do
		collisionManager:unregister(atk)
		atk:destroy()
	end

	if entity.weapon then
		entity:unequipWeapon()
	end
	---@diagnostic enable
end

function Mortal:getQuadInfo()
  local entity = self.entity

	---@diagnostic disable
	local animation = entity.animations[entity.state]
	local quad = animation.frames[animation.currFrame]
	local qx, qy, qw, qh = quad:getViewport()
	local imgW, imgH = entity.spriteSheets[entity.state]:getDimensions()
	local u_min = qx / imgW
	local v_min = qy / imgH
	local u_width = qw / imgW
	local v_height = qh / imgH

	return u_min, v_min, u_width, v_height
	---@diagnostic enable
end

function Mortal:drawShaders()
  local entity = self.entity

  ---@diagnostic disable
	if entity.state ~= DYING then
		if entity.invulnerableTimer > 0 then
			love.graphics.setShader(whiteShader)
			whiteShader:send("fillColor", { 1, 1, 1, 1.0 })
		elseif entity.healingTimer:isActive() then
			local u_min, v_min, u_width, v_height = self:getQuadInfo()
			love.graphics.setShader(particleShader)
			particleShader:send("time", entity.healingTimer.time)
			particleShader:send("quad_info", { u_min, v_min, u_width, v_height })
			particleShader:send("heal_color", { 0.2, 0.8, 0.35 })
		elseif entity.invisible then
			love.graphics.setShader(invisibilityShader)
			-- seria legal ter um jeito mais ergonômico de fazer isso:
			if entity.artifacts and entity.artifacts[1] and entity.artifacts[1].name == INVISIBILITY_RING.name then
				invisibilityShader:send("timer", entity.artifacts[1].customData.timer.time)
			elseif entity.artifacts and entity.artifacts[2] and entity.artifacts[2].name == INVISIBILITY_RING.name then
				invisibilityShader:send("timer", entity.artifacts[2].customData.timer.time)
			end
		elseif entity.burningTimer:isActive() then
			local u_min, v_min, u_width, v_height = self:getQuadInfo()
			love.graphics.setShader(particleShader)
			particleShader:send("time", entity.burningTimer.time)
			particleShader:send("quad_info", { u_min, v_min, u_width, v_height })
			particleShader:send("heal_color", { 0.9, 0.25, 0.2 })
		end
	else
		deadBodyShader:send("death_timer", entity.deathTimer)
		love.graphics.setShader(deadBodyShader)
	end
  ---@diagnostic enable
end