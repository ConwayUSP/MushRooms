----------------------------------------
-- Importações de Módulos
----------------------------------------
require("modules.utils.types")

----------------------------------------
-- Gerenciador de Particulas
----------------------------------------

---@class ParticleManager
---@field particles table<string, table>
---@field owner Entity?
---@field play fun(type: string)
---@field stop fun(type: string)
---@field update fun()

ParticleManager = {}
ParticleManager.__index = ParticleManager
ParticleManager.type = PARTICLE_MANAGER

function ParticleManager.new(owner)
	local pm = setmetatable({}, ParticleManager)

	pm.owner = owner
	pm.particles = {}

	return pm
end

---@param particleType string
---@param particle table
-- adiciona uma particula ao gerenciador
function ParticleManager:addParticle(particleType, particle)
	self.particles[particleType] = particle
end

---@param dt number
-- atualiza as partículas do gerenciador
function ParticleManager:update(dt)
	for _, particle in pairs(self.particles) do
		particle:update(dt)
	end
end

---@param particleType string
---@return nil
function ParticleManager:play(particleType)
	self.particles[particleType]:start()
end

---@param particleType string
---@return nil
function ParticleManager:stop(particleType)
	self.particles[particleType]:stop()
end

---@param particleType string
---@param direction number
function ParticleManager:setDirection(particleType, direction)
	self.particles[particleType]:setDirection(direction)
end

---@param particleType string
---@param x number
---@param y number
function ParticleManager:setPos(particleType, x, y)
	self.particles[particleType]:setPosition(x, y)
end

---@param particleType string
---@param x number
---@param y number
function ParticleManager:draw(particleType, x, y)
	love.graphics.draw(self.particles[particleType], x, y)
end