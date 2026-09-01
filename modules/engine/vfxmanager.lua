----------------------------------------
-- Importações de Módulos
----------------------------------------
require("modules.constructors.particles")
require("modules.utils.types")
require("modules.utils.vec")
require("modules.utils.utils")

----------------------------------------
-- Configurações
----------------------------------------

----------------------------------------------------------------------
--- Todas as configurações de partículas do jogo
--- devem ser definidas aqui. Cada tipo de partícula deve 
--- ter uma função que retorna um sistema de partículas configurado.
----------------------------------------------------------------------

local PARTICLES_SETTINGS = {
  [PARTICLE_DEFENSE] = {
    constructor = function(color1, color2)
      return newDefenseParticles(color1, color2)
    end
  },

  [PARTICLE_WALKING] = {
    constructor = function()
      return newWalkingParticles()
    end
  },

  [PARTICLE_BREAKING] = {
    constructor = function()
      return newBreakingParticles()
    end,
    blendMode = "add"
  },

  [PARTICLE_SEED] = {
    constructor = function()
      return newSeedParticles()
    end,
    blendMode = "add"
  },

  [PARTICLE_KATANA] = {
    constructor = function()
      return newKatanaParticles()
    end,
    blendMode = "add"
  },
}

local VFX_ANIMATIONS_TABLE = {
  [PARTICLE_EXPLOSION] = newAnimSetting(10, { width = 32, height = 32 }, 0.01, false, 0, 0, vec(0, 0), nil),
}

----------------------------------------
-- Gerenciador de VFX
----------------------------------------

--- @class VFXManager
--- @field particlesSettings table<string, ParticleSystem>
--- @field particlesInst table<Entity, table<string, ParticleSystem>>
--- @field animVFX table<string, table>
--- @field animInstances table<number, table>

VFXManager = {}
VFXManager.__index = VFXManager
VFXManager.type = VFX_MANAGER

function VFXManager.new()
  local vfx = setmetatable({}, VFXManager)

  vfx.particlesSettings = {}
  vfx.particlesInst = {}
  vfx.animVFX = {}
  vfx.animInstances = {}

  vfx.particlesSettings = PARTICLES_SETTINGS

  for type, setting in pairs(VFX_ANIMATIONS_TABLE) do
    local path = pngPathFormat({ "assets", "animations", "vfxs", type })

    vfx.animVFX[type] = {
      spriteSheet = assetManager:getImage(path),
      setting = setting,
      path = path,
    }
  end

  return vfx
end

----------------------------------------
-- Partículas
----------------------------------------

--- @param particleType string
--- @param entity Entity
--- @param offset Vec?
--- @param follow boolean?
--- @param ... any
-- toca uma partícula para uma entidade. Se a partícula já estiver sendo tocada, ela não será reiniciada.
function VFXManager:playParticle(particleType, entity, offset, follow, ...)
  local setting = self.particlesSettings[particleType]

  if not setting then
    return
  end

  self.particlesInst[entity] = self.particlesInst[entity] or {}

  local instance = self.particlesInst[entity][particleType]

  if instance then
    if instance.particle:isStopped() then
      instance.particle:start()
    end

    return instance.particle
  end

  local particle = setting.constructor(...)

  instance = {
    particle = particle,
    entity = entity,
    offset = offset or vec(0, 0),
    follow = follow or false,
    started = false,
    blendMode = setting.blendMode or "alpha",
  }

  self.particlesInst[entity][particleType] = instance

  local x, y = entity.pos.x + instance.offset.x, entity.pos.y + instance.offset.y
  particle:setPosition(x, y)
  particle:start()

  return particle
end

--- @param particleType string
--- @param entity Entity
-- para de tocar uma partícula para uma entidade.
function VFXManager:stopParticle(particleType, entity)
  local entityParticles = self.particlesInst[entity]

  if not entityParticles then
    return
  end

  local instance = entityParticles[particleType]

  if not instance then
    return
  end

  instance.particle:stop()
end

--- @param particleType string
--- @param entity Entity
--- @param direction number
-- define a direção de uma partícula para uma entidade.
function VFXManager:setParticleDirection(particleType, entity, direction)
  local entityParticles = self.particlesInst[entity]

  if not entityParticles then
    return
  end

  local instance = entityParticles[particleType]

  if not instance then
    return
  end

  instance.particle:setDirection(direction)
end

--- @param dt number
-- atualiza todas as partículas e animações. Se uma partícula ou animação terminar (não há mais partículas ou animação isFinished), ela será removida da lista de instâncias.
function VFXManager:update(dt)
  for entity, particles in pairs(self.particlesInst) do
    for particleType, instance in pairs(particles) do
      local particle = instance.particle

      particle:update(dt)

      if instance.follow then
        local x, y = entity.pos.x + instance.offset.x, entity.pos.y + instance.offset.y
        particle:setPosition(x, y)
      end

      local count = particle:getCount()

      if count > 0 then
        instance.started = true
      elseif instance.started then
        particles[particleType] = nil
      end
    end

    if next(particles) == nil then
      self.particlesInst[entity] = nil
    end
  end

  for id, instance in pairs(self.animInstances) do
    instance.animation:update(dt)

    if instance.animation.isFinished then
      self.animInstances[id] = nil
    end
  end
end

----------------------------------------
-- Desenho de Partículas
----------------------------------------

--- @param particleInstance table
--- @param camera Camera
-- desenha uma instância de partícula na tela, considerando a posição da câmera.
function VFXManager:drawParticleInstance(particleInstance, camera)
  local particleOffX = -camera.cx + camera.viewport.width / 2
	local particleOffY = -camera.cy + camera.viewport.height / 2

  local blendMode = particleInstance.blendMode
  local particle = particleInstance.particle

  love.graphics.setBlendMode(blendMode)
  love.graphics.draw(particle, particleOffX, particleOffY)
  love.graphics.setBlendMode("alpha")
end

----------------------------------------
-- Animações
----------------------------------------

--- @param animType string
--- @param pos Vec
function VFXManager:playAnimation(animType, pos)
  local anim = self.animVFX[animType]

  if not anim then
    return
  end

  local instance = {
    animation = newAnimation(anim.path, anim.setting),
    pos = pos,
    spriteSheet = anim.spriteSheet,
  }

  table.insert(self.animInstances, instance)
end

--- @param instance table
--- @param camera Camera
function VFXManager:drawAnimation(instance, camera)
  local viewX, viewY = camera:viewPos(instance.pos)
  local animation = instance.animation

  love.graphics.draw(instance.spriteSheet, animation.frames[animation.currFrame], viewX, viewY, 0, 3, 3, animation.frameDim.width / 2, animation.frameDim.height / 2)
end