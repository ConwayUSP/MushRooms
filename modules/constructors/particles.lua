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


---@return ParticleSystem
function newBreakingParticles()
	-- Remember to define the blend mode for this particle in PARTICLES_SETTINGS.
	-- Blend mode: "add"
	local particleImg1 = assetManager:getImage("assets/sprites/circle.png")
	local ps = love.graphics.newParticleSystem(particleImg1, 12)

	ps:setColors(1, 1, 1, 0, 1, 1, 1, 1, 1, 0.92716944217682, 0.64393937587738, 0.93181818723679, 1, 0.92716944217682, 0.64393937587738, 0.81818181276321, 1, 0.92716944217682, 0.64393937587738, 0.70075756311417)
	ps:setDirection(0)
	ps:setEmissionArea("borderellipse", 6.5320539474487, 6.5320539474487, 0, true)
	ps:setEmissionRate(149.26387023926)
	ps:setEmitterLifetime(0.07192774116993)
	ps:setInsertMode("top")
	ps:setLinearAcceleration(0, 1728.9719238281, 0, 1728.9719238281)
	ps:setLinearDamping(2.6003096103668, 4.091215133667)
	ps:setOffset(50, 50)
	ps:setParticleLifetime(0.16063083708286, 0.31359833478928)
	ps:setRadialAcceleration(0, 0)
	ps:setRelativeRotation(false)
	ps:setRotation(0, 0)
	ps:setSizes(0.04, 0)
	ps:setSizeVariation(0)
	ps:setSpeed(250.17938232422, 652.8349609375)
	ps:setSpin(0, 0)
	ps:setSpinVariation(0)
	ps:setSpread(0)
	ps:setTangentialAcceleration(0, 0)
	ps:stop()

	return ps
end

---@return ParticleSystem
function newSeedParticles()
	-- Remember to define the blend mode for this particle in PARTICLES_SETTINGS.
	-- Blend mode: "add"
	local particleImg1 = assetManager:getImage("assets/sprites/circle.png")
	local ps = love.graphics.newParticleSystem(particleImg1, 36)

	ps:setColors(0.26953125, 0.21162414550781, 0.10107421875, 0, 0.3515625, 0.30886563658714, 0.142822265625, 1, 0.3359375, 0.29648035764694, 0.14303588867188, 0.93181818723679, 1, 0.88813918828964, 0.453125, 0.81818181276321, 1, 0.92716944217682, 0.64393937587738, 0.70075756311417)
	ps:setDirection(0)
	ps:setEmissionArea("borderellipse", 6.5320539474487, 6.5320539474487, 0, true)
	ps:setEmissionRate(120)
	ps:setEmitterLifetime(0.07192774116993)
	ps:setInsertMode("top")
	ps:setLinearAcceleration(0, 500.2092590332, 0, 520.62384033203)
	ps:setLinearDamping(5.5612688064575, 6.3807458877563)
	ps:setOffset(50, 50)
	ps:setParticleLifetime(0.16063083708286, 0.75396627187729)
	ps:setRadialAcceleration(0, 0)
	ps:setRelativeRotation(false)
	ps:setRotation(0, 0)
	ps:setSizes(0.038547907024622, 0)
	ps:setSizeVariation(0)
	ps:setSpeed(250.17938232422, 333.07907104492)
	ps:setSpin(0, 0)
	ps:setSpinVariation(0)
	ps:setSpread(0)
	ps:setTangentialAcceleration(0, 0)
	ps:stop()

	return ps
end

---@return ParticleSystem
function newKatanaParticles()
	-- Remember to define the blend mode for this particle in PARTICLES_SETTINGS.
	-- Blend mode: "add"
	local particleImg1 = assetManager:getImage("assets/sprites/circle.png")
	local ps = love.graphics.newParticleSystem(particleImg1, 33)

	ps:setColors(0.59765625, 0.94342041015625, 1, 0, 0.6015625, 0.97198486328125, 1, 1, 0.81640625, 0.96987915039063, 1, 0.93181818723679, 0.64393937587738, 0.94158381223679, 1, 0.81818181276321, 0.64393937587738, 0.908203125, 1, 0.70075756311417)
	ps:setDirection(0)
	ps:setEmissionArea("borderellipse", 50.286659240723, 50.286659240723, 0, true)
	ps:setEmissionRate(424.49346923828)
	ps:setEmitterLifetime(0.07192774116993)
	ps:setInsertMode("top")
	ps:setLinearAcceleration(0, -18.424196243286, 0, 8.6251773834229)
	ps:setLinearDamping(4.0161485671997, 4.5562109947205)
	ps:setOffset(50, 50)
	ps:setParticleLifetime(0.17245730757713, 0.2662082016468)
	ps:setRadialAcceleration(-5541.4467773438, -6637.3037109375)
	ps:setRelativeRotation(false)
	ps:setRotation(0, 0)
	ps:setSizes(0.018888473510742, 0.038547907024622, 0)
	ps:setSizeVariation(0)
	ps:setSpeed(862.86358642578, 1033.9801025391)
	ps:setSpin(0, 0)
	ps:setSpinVariation(0)
	ps:setSpread(0)
	ps:setTangentialAcceleration(-2846.716796875, -2205.6977539063)
	ps:stop()

	return ps
end
