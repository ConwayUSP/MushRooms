---@alias ParticleSystem table sistemas de partícula são estruturas definidas pelo próprio Love2D

---@param c1 Color
---@param c2 Color
---@return ParticleSystem
-- cria um sistema de partículas que emite muitos círculos que sobem.
-- `c1` e `c2` são as cores do efeito
function newDefenseParticles(c1, c2)
	local particleImg = assetManager:getImage("assets/sprites/circle.png")
	local defParticles = love.graphics.newParticleSystem(particleImg, 250)
	defParticles:setPosition(0, 0)
	defParticles:setParticleLifetime(1, 2.25)
	defParticles:setEmissionRate(25)
	defParticles:setSizes(0.05, 0.2, 0.01)
	defParticles:setSizeVariation(0.3)
	defParticles:setSpin(math.pi)
	defParticles:setSpinVariation(0.5)
	defParticles:setColors(c1.r, c1.g, c1.b, 0.5, c2.r, c2.g, c2.b, 0.5)
	defParticles:setLinearAcceleration(0, -20, 0, -60)
	defParticles:setSpread(math.pi / 4)
	defParticles:setDirection(-math.pi / 2)
	defParticles:setEmissionArea("normal", 25, 20)
	defParticles:setSpeed(10, 50)
	defParticles:stop()
	return defParticles
end

---@return ParticleSystem
-- cria um sistema de partículas que emite circulos de poeira a uma curta distância
function newWalkingParticles()
	local particleImg = assetManager:getImage("assets/sprites/circle.png")
	local defParticles = love.graphics.newParticleSystem(particleImg, 250)
	defParticles:setPosition(0, 24)
	defParticles:setParticleLifetime(0.3, 0.6)
	defParticles:setEmissionRate(6)
	defParticles:setSizes(0.05, 0.15)
	defParticles:setSizeVariation(0.1)
	defParticles:setSpin(math.pi)
	defParticles:setSpinVariation(0.5)
	defParticles:setColors(1.0, 1.0, 1.0, 0.5, 0.8, 0.8, 0.8, 0.0)
	defParticles:setLinearAcceleration(0, -100)
	defParticles:setSpread(math.pi / 4)
	defParticles:setEmissionArea("normal", 10, 2)
	defParticles:setSpeed(70)
	defParticles:stop()
	return defParticles
end
