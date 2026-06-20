-----------------------------------------
--- Importação de Módulos
--------------------------------------------

require("modules.entities.mortal")

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

---@class Entity : Mortal
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
---@field hasShadow? boolean
---@field shadowWidth? number
Entity = {}
Entity.__index = Entity

---@param name string
---@param pos? Vec
---@param hitboxes? Hitboxes
---@param room? Room
---@param entityPhysics? PhysicsSettings
-- inicializa uma entidade com propriedades básicas.
function Entity:init(name, pos, hitboxes, room, entityPhysics)
	self.name = name or ""
	self.pos = pos
	self.hb = hitboxes
	self.room = room

	local physics = entityPhysics and entityPhysics or physicsSettings()

	self.mass = physics.mass
	self.speed = physics.speed
	self.friction = physics.friction
	self.vel = physics.initialVel
	self.acc = physics.initialAcc
	self.speedRange = physics.speedRange
	self.restitution = physics.restitution or 0
end

function Entity:becomeMortal(hp)
	self.mortal = Mortal.init(self, hp)
end

function Entity:update(dt)
	if self.mortal then
		self.mortal:update(dt)
	end
end

function Entity:takeDamage(amount)
	if self.mortal then
		self.mortal:takeDamage(amount)
	end
end

function Entity:burn(ticks, dmg)
	if self.mortal then
		self.mortal:burn(ticks, dmg)
	end
end

function Entity:heal(amount)
	if self.mortal then
		self.mortal:heal(amount)
	end
end

function Entity:applyFear(attacker, duration)
	if self.mortal then
		self.mortal:applyFear(attacker, duration)
	end
end

-- inicia o processo de morte do inimigo
function Entity:die()
	if self.mortal then
		self.mortal:die()
	end
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
