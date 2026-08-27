----------------------------------------
-- Importações de Módulos
----------------------------------------
require("modules.utils.types")
require("modules.utils.vec")

----------------------------------------
-- Variáveis
----------------------------------------

local VFX_ANIMATIONS_TABLE = {
	[PARTICLE_EXPLOSION] = newAnimSetting(10, { width = 32, height = 32 }, 0.01, false, 0, 0, vec(0, 0), nil),
}

----------------------------------------
-- Gerenciador de Particulas
----------------------------------------

---@class VFXManager
---@field particles table<string, table>
---@field owner Entity?
---@field play fun(type: string)
---@field stop fun(type: string)
---@field update fun()

VFXManager = {}
VFXManager.__index = VFXManager
VFXManager.type = VFX_MANAGER

function VFXManager.new(animTypes, owner)
	local vfx = setmetatable({}, VFXManager)

	vfx.owner = owner
	vfx.particles = {}
	vfx.animVFX = {}
	vfx.animInstances = {}

	if animTypes then
		for _, type in pairs(animTypes) do
			local table = {}
			local path = pngPathFormat({ "assets", "animations", "vfxs", type })

			table.spriteSheet = assetManager:getImage(path)
			table.setting = VFX_ANIMATIONS_TABLE[type]
			table.path = path

			vfx.animVFX[type] = table
		end
	end

	return vfx
end

---@param particleType string
---@param particle table
---@param x? number
---@param y? number
-- adiciona uma particula ao gerenciador
function VFXManager:addParticle(particleType, particle, x, y)
	self.particles[particleType] = particle
	if x and y then
		self:setPos(particleType, x, y)
	end
end

---@param dt number
-- atualiza as partículas do gerenciador
function VFXManager:update(dt)
	for _, particle in pairs(self.particles) do
		particle:update(dt)
	end

	for id, instance in pairs(self.animInstances) do
		instance.animation:update(dt)

		if instance.animation.isFinished then
			self.animInstances[id] = nil
		end
	end
end

---@param particleType string
function VFXManager:playParticle(particleType)
	self.particles[particleType]:start()
end

---@param particleType string
function VFXManager:stopParticle(particleType)
	if self.particles[particleType] then
		self.particles[particleType]:stop()
	end
end

---@param animType string
---@param pos Vec
function VFXManager:playAnimation(animType, pos)
	local anim = self.animVFX[animType]
	local instance = {
		animation = newAnimation(anim.path, anim.setting),
		pos = pos,
		spriteSheet = anim.spriteSheet,
	}

	table.insert(self.animInstances, instance)
end

---@param particleType string
---@param direction number
function VFXManager:setDirection(particleType, direction)
	self.particles[particleType]:setDirection(direction)
end

---@param particleType string
---@param x number
---@param y number
function VFXManager:setPos(particleType, x, y)
	self.particles[particleType]:setPosition(x, y)
end

---@param vfxType string
---@param x number
---@param y number
function VFXManager:drawParticle(vfxType, x, y)
	love.graphics.draw(self.particles[vfxType], x, y)
end

---@param instance table
---@param camera Camera
function VFXManager:drawAnimation(instance, camera)
	local viewX, viewY = camera:viewPos(instance.pos)
	local animation = instance.animation
	love.graphics.draw(
		instance.spriteSheet,
		animation.frames[animation.currFrame],
		viewX,
		viewY,
		0,
		3,
		3,
		animation.frameDim.width / 2,
		animation.frameDim.height / 2
	)
end

---@param vfxType string
---@return number, number
function VFXManager:getPosition(vfxType)
	return self.particles[vfxType]:getPosition()
end
