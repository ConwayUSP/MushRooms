----------------------------------------
-- Importações de Módulos
----------------------------------------
require("modules.constructors.particles")
require("modules.utils.types")
require("modules.utils.vec")
require("modules.utils.utils")
require("modules.utils.vfxs")

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
      self:startParticle(instance, particleType, entity)
    end
    return instance.particle
  end

  local particle = setting.constructor(...)
  local offset = offset or self.particlesSettings[particleType].offset

  instance = {
    particle = particle,
    entity = entity,
    offset = offset or vec(0, 0),
    follow = follow or false,
    started = false,
    blendMode = setting.blendMode or "alpha",
  }

  self.particlesInst[entity][particleType] = instance
  self:startParticle(instance, particleType, entity, true)

  return particle
end

---@param instance ParticleSystem
---@param particleType string
---@param entity Entity
---@param newInstance? boolean
-- inicia a emissão de partículas e cuida da direção e velocidade iniciais da emissão
function VFXManager:startParticle(instance, particleType, entity, newInstance)
  instance.particle:start()
  local partDir = self:updateParticleDirection(instance, particleType, entity)

  if newInstance then
    -- a posição do sistema de partículas deve começar na entidade (com possível offset)
    local x, y = entity.pos.x + instance.offset.x, entity.pos.y + instance.offset.y
    instance.particle:setPosition(x, y)

    if self.particlesSettings[particleType].ownerInertia then
      -- usando a inércia da entidade para afetar a velocidade das partículas
      local speedMin, speedMax = instance.particle:getSpeed()
      local ownerDir = math.atan2(entity.attacker.vel.y, entity.attacker.vel.x)
      local f = 0.5 - math.atan2(math.sin(ownerDir - partDir), math.cos(ownerDir - partDir)) / (2 * math.pi) -- diferença normalizada entre as direções
      local speedChange = f * (math.abs(entity.attacker.vel.x) + math.abs(entity.attacker.vel.y))
      instance.particle:setSpeed(speedMin + speedChange, speedMax + speedChange)
    end

    -- burst de emissão inicial
    local emitAtStart = self.particlesSettings[particleType].emitAtStart
    if emitAtStart then
      instance.particle:emit(emitAtStart)
    end
  end
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

---@param instance ParticleSystem
---@param particleType string
---@param entity Entity | AtkEvent
-- define a direção de uma partícula para uma entidade.
function VFXManager:updateParticleDirection(instance, particleType, entity)
  if not self.particlesSettings[particleType].directed then
    return
  end

  local direction = entity.direction or math.atan2(entity.vel.y, entity.vel.x)
  if self.particlesSettings[particleType].invDirection then
    direction = direction + math.pi
  end

  instance.particle:setDirection(direction)
  return direction
end

--- @param dt number
-- atualiza todas as partículas e animações. Se uma partícula ou animação terminar (não há mais partículas ou animação isFinished), ela será removida da lista de instâncias.
function VFXManager:update(dt)
  for entity, particles in pairs(self.particlesInst) do
    for particleType, instance in pairs(particles) do
      local particle = instance.particle

      self:updateParticleDirection(instance, particleType, entity)
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
