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
-- fumaça curta usada quando um pilar de tesouro desaparece.
function newTreasureDisappearParticles()
	local particleImg = assetManager:getImage(pngPathFormat({ "assets", "sprites", "circle" }))
	local ps = love.graphics.newParticleSystem(particleImg, 250)

	ps:setColors(
		0.55078125,
		0.48573231697083,
		0.45396423339844,
		1,
		0.38671875,
		0.35933876037598,
		0.34291076660156,
		0.41666665673256,
		0.51953125,
		0.40632772445679,
		0.39776611328125,
		0.026515152305365
	)
	ps:setDirection(-1.5707963705063)
	ps:setEmissionArea("ellipse", 2.0412668228149, 2.0412668228149, 0, false)
	ps:setEmissionRate(246.255451202393)
	ps:setEmitterLifetime(0.07274858951569)
	ps:setInsertMode("top")
	ps:setLinearAcceleration(0, 0, 0, 0)
	ps:setLinearDamping(0, 0)
	ps:setOffset(50, 50)
	ps:setParticleLifetime(0.84735202789307, 1.6003778457642)
	ps:setRadialAcceleration(0, 0)
	ps:setRelativeRotation(false)
	ps:setRotation(0, 0)
	ps:setSizes(0.08, 0.20, 0.04)
	ps:setSizeVariation(0.1)
	ps:setSpeed(105.062152862549, 207.71934509277)
	ps:setSpin(0, 0)
	ps:setSpinVariation(0)
	ps:setSpread(0.6917268037796)
	ps:setTangentialAcceleration(0, 0)
	ps:stop()

	return ps
end

---@return ParticleSystem
-- variante independente da poeira de caminhada para o movimento das pedras do puzzle
function newPuzzleStoneMovingParticles()
	local particleImg = assetManager:getImage(pngPathFormat({ "assets", "sprites", "circle" }))
	local particles = love.graphics.newParticleSystem(particleImg, 250)
	particles:setPosition(0, 0)
	particles:setParticleLifetime(0.3, 0.6)
	particles:setEmissionRate(6)
	particles:setSizes(0.05, 0.15)
	particles:setSizeVariation(0.1)
	particles:setSpin(math.pi)
	particles:setSpinVariation(0.5)
	particles:setColors(1.0, 1.0, 1.0, 0.5, 0.8, 0.8, 0.8, 0.0)
	particles:setLinearAcceleration(0, -100)
	particles:setSpread(math.pi / 4)
	particles:setDirection(-math.pi / 2)
	particles:setEmissionArea("normal", 10, 2)
	particles:setSpeed(70)
	particles:stop()
	return particles
end

---@return ParticleSystem
function newBreakingParticles()
	local particleImg = assetManager:getImage("assets/sprites/circle.png")
	local ps = love.graphics.newParticleSystem(particleImg, 12)

	ps:setColors(
		1,
		1,
		1,
		0,
		1,
		1,
		1,
		1,
		1,
		0.92716944217682,
		0.64393937587738,
		0.93181818723679,
		1,
		0.92716944217682,
		0.64393937587738,
		0.81818181276321,
		1,
		0.92716944217682,
		0.64393937587738,
		0.70075756311417
	)
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
	local particleImg = assetManager:getImage("assets/sprites/circle.png")
	local ps = love.graphics.newParticleSystem(particleImg, 36)

	ps:setColors(
		0.26953125,
		0.21162414550781,
		0.10107421875,
		0,
		0.3515625,
		0.30886563658714,
		0.142822265625,
		1,
		0.3359375,
		0.29648035764694,
		0.14303588867188,
		0.93181818723679,
		1,
		0.88813918828964,
		0.453125,
		0.81818181276321,
		1,
		0.92716944217682,
		0.64393937587738,
		0.70075756311417
	)
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
	local particleImg = assetManager:getImage("assets/sprites/circle.png")
	local ps = love.graphics.newParticleSystem(particleImg, 33)

	ps:setColors(
		0.59765625,
		0.94342041015625,
		1,
		0,
		0.6015625,
		0.97198486328125,
		1,
		1,
		0.81640625,
		0.96987915039063,
		1,
		0.93181818723679,
		0.64393937587738,
		0.94158381223679,
		1,
		0.81818181276321,
		0.64393937587738,
		0.908203125,
		1,
		0.70075756311417
	)
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
	ps:setTangentialAcceleration(2205.6977539063, 2846.716796875)
	ps:stop()

	return ps
end

---@return ParticleSystem
function newBlackHoleParticles()
	local particleImg = assetManager:getImage("assets/sprites/square.png")
	local ps = love.graphics.newParticleSystem(particleImg, 48)

	ps:setColors(
		0.99691772460938,
		1,
		0.60546875,
		1,
		1,
		0.2734375,
		0.2734375,
		1,
		0.4609375,
		0.099029541015625,
		0.33653163909912,
		1
	)
	ps:setDirection(-1.5707963705063)
	ps:setEmissionArea("borderellipse", 32, 32, 0, true)
	ps:setEmissionRate(18)
	ps:setEmitterLifetime(-1)
	ps:setInsertMode("top")
	ps:setLinearAcceleration(0, 8, 0, 8)
	ps:setLinearDamping(0.2, 0.2)
	ps:setOffset(50, 50)
	ps:setParticleLifetime(1.8, 2.2)
	ps:setRadialAcceleration(-350, -450)
	ps:setRelativeRotation(false)
	ps:setRotation(0, 0)
	ps:setSizes(0.01, 0.015, 0)
	ps:setSizeVariation(0.25)
	ps:setSpeed(155, 225)
	ps:setSpin(0, 0)
	ps:setSpinVariation(0)
	ps:setSpread(6.2831854820251)
	-- ps:setTangentialAcceleration(60, 120)

	ps:stop()

	return ps
end

---@return ParticleSystem
function newFlowerShotParticles()
	local particleImg = assetManager:getImage("assets/sprites/circle.png")
	local ps = love.graphics.newParticleSystem(particleImg, 20)

	ps:setColors(0.734375, 0, 1, 0.65390625, 1, 0.13671875, 0.7032470703125, 0.0)
	ps:setDirection(-1.5707963705063)
	ps:setEmissionArea("none", 0, 0, 0, false)
	ps:setEmissionRate(0)
	ps:setEmitterLifetime(0.01)
	ps:setInsertMode("top")
	ps:setLinearAcceleration(-3.95, -3.95)
	ps:setLinearDamping(4.4, 4.4)
	ps:setOffset(50, 50)
	ps:setParticleLifetime(0.6, 4.3)
	ps:setRadialAcceleration(0, 0)
	ps:setRelativeRotation(false)
	ps:setRotation(0, 0)
	ps:setSizes(0.03, 0.005)
	ps:setSizeVariation(0.08)
	ps:setSpeed(65, 596)
	ps:setSpin(0, 0)
	ps:setSpinVariation(0)
	ps:setSpread(0.8771174430847)
	ps:setTangentialAcceleration(0, 0)
	ps:stop()

	return ps
end

---@return ParticleSystem
function newMoaisBossStartingParticles()
	local particleImg = assetManager:getImage("assets/sprites/circle.png")
	local ps = love.graphics.newParticleSystem(particleImg, 282)

	ps:setColors(
		0.55078125,
		0.48573231697083,
		0.65396423339844,
		1,
		0.38671875,
		0.35933876037598,
		0.44291076660156,
		0.41666665673256,
		0.51953125,
		0.40632772445679,
		0.59776611328125,
		0.026515152305365
	)
	ps:setDirection(-1.5707963705063)
	ps:setEmissionArea("uniform", 145.474609375, 1.9432859420776, 0, false)
	ps:setEmissionRate(180)
	ps:setEmitterLifetime(3.8)
	ps:setInsertMode("top")
	ps:setLinearAcceleration(0, 0, 0, 0)
	ps:setLinearDamping(0, 0)
	ps:setOffset(50, 50)
	ps:setParticleLifetime(0.83239555358887, 1.6638013124466)
	ps:setRadialAcceleration(0, 0)
	ps:setRelativeRotation(false)
	ps:setRotation(0, 0)
	ps:setSizes(0.06494667291641, 0.22221557617188, 0.035508986115456)
	ps:setSizeVariation(0.10223641991615)
	ps:setSpeed(105.16536712646, 208.12532043457)
	ps:setSpin(0, 0)
	ps:setSpinVariation(0)
	ps:setSpread(3.1415927410126)
	ps:setTangentialAcceleration(0, 0)
	ps:stop()

	return ps
end

---@return ParticleSystem
-- explosão de brasas usada quando a Bolota Demoníaca morre
function newDemonDieParticles()
	local particleImg = assetManager:getImage("assets/sprites/circle.png")
	local ps = love.graphics.newParticleSystem(particleImg, 90)

	ps:setColors(
		1,
		0.95,
		0.6,
		1, -- amarelo quente
		1,
		0.55,
		0.3,
		1, -- laranja
		0.75,
		0.15,
		0.15,
		0.9, -- vermelho
		0.2,
		0.05,
		0.05,
		0 -- fumaça escura
	)
	ps:setDirection(0)
	ps:setEmissionArea("borderellipse", 8, 8, 0, true)
	ps:setEmissionRate(0)
	ps:setEmitterLifetime(-1)
	ps:setInsertMode("top")
	ps:setLinearAcceleration(0, 120, 0, 260) -- puxa pra baixo
	ps:setLinearDamping(1.5, 2.5)
	ps:setParticleLifetime(0.35, 0.7)
	ps:setSizes(0.16, 0.08, 0.02)
	ps:setSizeVariation(0.4)
	ps:setSpeed(180, 420)
	ps:setSpread(4.2831854820251)
	ps:setSpin(math.pi, math.pi * 2)
	ps:setSpinVariation(0.5)
	ps:stop()

	return ps
end

---@return ParticleSystem
-- rastro de brasas deixado pela Bolota Demoníaca enquanto pula
function newDemonTrailParticles()
	local particleImg = assetManager:getImage("assets/sprites/circle.png")
	local ps = love.graphics.newParticleSystem(particleImg, 64)

	ps:setColors(1, 0.75, 0.35, 0.9, 1, 0.3, 0.15, 0.6, 0.4, 0.05, 0.05, 0)
	ps:setDirection(0)
	ps:setEmissionArea("normal", 6, 6, 0, false)
	ps:setEmissionRate(20)
	ps:setEmitterLifetime(-1)
	ps:setLinearAcceleration(0, -60, 0, -20) -- as brasas sobem
	ps:setParticleLifetime(0.25, 0.5)
	ps:setSizes(0.06, 0.03)
	ps:setSizeVariation(0.3)
	ps:setSpeed(10, 45)
	ps:setSpread(1.2)
	ps:stop()

	return ps
end

---@return ParticleSystem
-- penas caindo ao redor do Pato Aranha durante o ataque voador
function newFeatherParticles()
	local particleImg = assetManager:getImage("assets/sprites/feather.png")
	local ps = love.graphics.newParticleSystem(particleImg, 120)

	ps:setColors(1, 1, 0.35, 0.7, 1, 0.85, 0.3, 0.6, 1, 0.7, 0.5, 0.2)
	ps:setDirection(-1.5707963705063) -- para baixo
	ps:setEmissionArea("borderellipse", 60, 45, 0, false)
	ps:setInsertMode("top")
	ps:setEmissionRate(12)
	ps:setEmitterLifetime(3) -- limitado de propósito: não vaza se o ataque for interrompido
	ps:setLinearAcceleration(0, 85, 0, 140)
	ps:setLinearDamping(1.2, 2)
	ps:setParticleLifetime(0.9, 1.6)
	ps:setSizes(0.13, 0.08, 0.03)
	ps:setSizeVariation(0.35)
	ps:setSpeed(100, 130)
	ps:setSpread(6)
	ps:setSpin(-3, -1, 0, -1, -3)
	ps:setSpinVariation(2)
	ps:stop()

	return ps
end

---@return ParticleSystem
-- poeira arrancada pelo Rolling Stone durante o embalo
function newRushDustParticles()
	local particleImg = assetManager:getImage("assets/sprites/circle.png")
	local ps = love.graphics.newParticleSystem(particleImg, 160)

	ps:setColors(0.71, 0.67, 0.88, 0.7, 0.46, 0.42, 0.63, 0.4, 0.3, 0.28, 0.46, 0)
	ps:setDirection(0)
	ps:setEmissionArea("normal", 14, 10, 0, false)
	ps:setEmissionRate(60)
	ps:setEmitterLifetime(-1)
	ps:setLinearAcceleration(0, -30, 0, 30)
	ps:setLinearDamping(2, 4)
	ps:setParticleLifetime(0.2, 0.45)
	ps:setSizes(0.13, 0.06, 0.01)
	ps:setSizeVariation(0.4)
	ps:setSpeed(60, 160)
	ps:setSpread(0.9)
	ps:setSpin(math.pi, math.pi * 2)
	ps:setSpinVariation(0.5)
	ps:stop()

	return ps
end

---@return ParticleSystem
-- radiação verde que segue os projéteis do Gato Nuclear
function newRadiationParticles()
	local particleImg = assetManager:getImage("assets/sprites/circle.png")
	local ps = love.graphics.newParticleSystem(particleImg, 72)

	ps:setColors(0.5, 1, 0.3, 0.85, 0.25, 0.9, 0.2, 0.5, 0.1, 0.5, 0.1, 0)
	ps:setDirection(0)
	ps:setEmissionArea("borderellipse", 10, 10, 0, false)
	ps:setEmissionRate(24)
	ps:setEmitterLifetime(-1)
	ps:setLinearDamping(0.5, 1.5)
	ps:setParticleLifetime(0.35, 0.55)
	ps:setSizes(0.08, 0.04, 0)
	ps:setSizeVariation(0.5)
	ps:setSpeed(15, 70)
	ps:setSpread(6.2831854820251)
	ps:stop()

	return ps
end

---@return ParticleSystem
-- radiação que emana do próprio Gato Nuclear enquanto ele está vivo
function newRadiationGlowParticles()
	local particleImg = assetManager:getImage("assets/sprites/circle.png")
	local ps = love.graphics.newParticleSystem(particleImg, 110)

	ps:setColors(0.55, 1, 0.35, 0.7, 0.2, 0.85, 0.15, 0.35, 0.05, 0.4, 0.05, 0)
	ps:setDirection(-1.5707963705063) -- sobe
	ps:setEmissionArea("ellipse", 30, 45, 0, false)
	ps:setEmissionRate(6)
	ps:setEmitterLifetime(-1)
	ps:setLinearAcceleration(0, -40, 0, -70)
	ps:setParticleLifetime(1.0, 1.5)
	ps:setSizes(0.07, 0.03, 0)
	ps:setSizeVariation(0.1)
	ps:setSpeed(8, 55)
	ps:setSpread(0.8)
	ps:setSpin(-1, 1)
	ps:setSpinVariation(1)
	ps:stop()

	return ps
end

---@return ParticleSystem
-- cacos voando quando um seixo do Estilingue quebra
function newPebbleBreakParticles()
	local particleImg = assetManager:getImage("assets/sprites/square.png")
	local ps = love.graphics.newParticleSystem(particleImg, 18)

	ps:setColors(0.62, 0.58, 0.52, 1, 0.42, 0.39, 0.35, 1, 0.3, 0.28, 0.25, 0)
	ps:setDirection(0)
	ps:setEmissionArea("borderellipse", 6, 6, 0, false)
	ps:setEmissionRate(0)
	ps:setEmitterLifetime(-1)
	ps:setLinearAcceleration(0, 500, 0, 900) -- cai rápido
	ps:setLinearDamping(1.5, 2.5)
	ps:setParticleLifetime(0.3, 0.55)
	ps:setSizes(0.05, 0.03, 0)
	ps:setSizeVariation(0.5)
	ps:setSpeed(120, 300)
	ps:setSpread(6.2831854820251)
	ps:setSpin(-6, 6)
	ps:setSpinVariation(1)
	ps:stop()

	return ps
end

---@return ParticleSystem
-- fragmentos de osso voando quando uma pilha de ossos é quebrada
function newBoneBreakParticles()
	local particleImg = assetManager:getImage("assets/sprites/square.png")
	local ps = love.graphics.newParticleSystem(particleImg, 24)

	ps:setColors(0.92, 0.89, 0.78, 1, 0.78, 0.74, 0.6, 1, 0.6, 0.56, 0.45, 0)
	ps:setDirection(0)
	ps:setEmissionArea("borderellipse", 24, 16, 0, false)
	ps:setEmissionRate(0)
	ps:setEmitterLifetime(-1)
	ps:setLinearAcceleration(0, 350, 0, 700)
	ps:setLinearDamping(1.5, 3)
	ps:setParticleLifetime(0.3, 0.6)
	ps:setSizes(0.04, 0.02, 0)
	ps:setSizeVariation(0.5)
	ps:setSpeed(80, 240)
	ps:setSpread(6.2831854820251)
	ps:setSpin(-5, 5)
	ps:setSpinVariation(1)
	ps:stop()

	return ps
end

---@return ParticleSystem
-- escombros voando quando uma rocha destrutível é quebrada
function newRockBreakParticles()
	local particleImg = assetManager:getImage("assets/sprites/square.png")
	local ps = love.graphics.newParticleSystem(particleImg, 32)

	ps:setColors(0.6, 0.58, 0.55, 1, 0.45, 0.43, 0.4, 1, 0.3, 0.29, 0.27, 0)
	ps:setDirection(0)
	ps:setEmissionArea("borderellipse", 26, 20, 0, false)
	ps:setEmissionRate(0)
	ps:setEmitterLifetime(-1)
	ps:setLinearAcceleration(0, 500, 0, 900)
	ps:setLinearDamping(1.5, 3)
	ps:setParticleLifetime(0.35, 0.7)
	ps:setSizes(0.06, 0.03, 0)
	ps:setSizeVariation(0.5)
	ps:setSpeed(110, 300)
	ps:setSpread(6.2831854820251)
	ps:setSpin(-6, 6)
	ps:setSpinVariation(1)
	ps:stop()

	return ps
end

---@return ParticleSystem
-- fatos de carvão e faíscas quando um altar de carvão é destruído
function newCoalBreakParticles()
	local particleImg = assetManager:getImage("assets/sprites/square.png")
	local ps = love.graphics.newParticleSystem(particleImg, 30)

	ps:setColors(
		0.2,
		0.18,
		0.17,
		1, -- carvão escuro
		0.35,
		0.3,
		0.28,
		1, -- pó
		1,
		0.6,
		0.2,
		0.9, -- brasa
		0.7,
		0.3,
		0.1,
		0 -- brasa apagando
	)
	ps:setDirection(0)
	ps:setEmissionArea("borderellipse", 22, 18, 0, false)
	ps:setEmissionRate(0)
	ps:setEmitterLifetime(-1)
	ps:setLinearAcceleration(0, 450, 0, 850)
	ps:setLinearDamping(1.5, 3)
	ps:setParticleLifetime(0.3, 0.65)
	ps:setSizes(0.05, 0.03, 0)
	ps:setSizeVariation(0.5)
	ps:setSpeed(100, 280)
	ps:setSpread(6.2831854820251)
	ps:setSpin(-6, 6)
	ps:setSpinVariation(1)
	ps:stop()

	return ps
end

---@return ParticleSystem
-- lascas de madeira voando quando uma caixa de madeira quebra
function newWoodBreakParticles()
	local particleImg = assetManager:getImage("assets/sprites/square.png")
	local ps = love.graphics.newParticleSystem(particleImg, 30)

	ps:setColors(
		0.55,
		0.36,
		0.32,
		1, -- madeira clara
		0.4,
		0.25,
		0.19,
		0.9, -- madeira escura
		0.72,
		0.5,
		0.4,
		0.8, -- lascas claras
		0.45,
		0.3,
		0.18,
		0 -- lascas sumindo
	)
	ps:setDirection(0)
	ps:setEmissionArea("borderellipse", 22, 18, 0, false)
	ps:setEmissionRate(0)
	ps:setEmitterLifetime(-1)
	ps:setLinearAcceleration(0, 450, 0, 850)
	ps:setLinearDamping(1.5, 3)
	ps:setParticleLifetime(0.3, 0.65)
	ps:setSizes(0.05, 0.03, 0)
	ps:setSizeVariation(0.5)
	ps:setSpeed(100, 280)
	ps:setSpread(6.2831854820251)
	ps:setSpin(-6, 6)
	ps:setSpinVariation(1)
	ps:stop()

	return ps
end

---@return ParticleSystem
-- folhas soltando quando a grama alta é cortada
function newGrassBreakParticles()
	local particleImg = assetManager:getImage("assets/sprites/feather.png")
	local ps = love.graphics.newParticleSystem(particleImg, 20)

	ps:setColors(0.55, 0.8, 0.35, 0.95, 0.75, 0.85, 0.3, 0.7, 0.6, 0.5, 0.25, 0)
	ps:setDirection(0)
	ps:setEmissionArea("borderellipse", 20, 22, 0, false)
	ps:setEmissionRate(0)
	ps:setEmitterLifetime(-1)
	ps:setLinearAcceleration(0, 120, 0, 260) -- quase flutuam
	ps:setLinearDamping(1, 2)
	ps:setParticleLifetime(0.4, 0.8)
	ps:setSizes(0.05, 0.03, 0)
	ps:setSizeVariation(0.5)
	ps:setSpeed(40, 150)
	ps:setSpread(6.2831854820251)
	ps:setSpin(-5, 5)
	ps:setSpinVariation(1)
	ps:stop()

	return ps
end

---@return ParticleSystem
-- poeira e entulho levantados quando um inimigo bate na parede
function newWallHitParticles()
	local particleImg = assetManager:getImage("assets/sprites/square.png")
	local ps = love.graphics.newParticleSystem(particleImg, 60)

	ps:setColors(0.5, 0.48, 0.64, 0.85, 0.40, 0.40, 0.58, 0.5, 0.20, 0.18, 0.3, 0)
	ps:setDirection(0)
	ps:setEmissionArea("borderellipse", 14, 14, 0, true)
	ps:setEmissionRate(160)
	ps:setEmitterLifetime(0.1) -- burst curto e repetível
	ps:setLinearAcceleration(0, 350, 0, 700)
	ps:setLinearDamping(2, 3.5)
	ps:setParticleLifetime(0.4, 0.8)
	ps:setSizes(0.14, 0.07, 0.01)
	ps:setSizeVariation(0.45)
	ps:setSpeed(90, 260)
	ps:setSpread(6.2831854820251)
	ps:setSpin(math.pi, math.pi * 2)
	ps:setSpinVariation(1)
	ps:stop()

	return ps
end

---@return ParticleSystem
-- risco arco-íris deixado pelo dash do Rainbow Dash
function newRainbowDashParticles()
	local particleImg = assetManager:getImage("assets/sprites/feather.png")
	local ps = love.graphics.newParticleSystem(particleImg, 160)

	ps:setColors(
		1,
		0.2,
		0.2,
		1.0, -- vermelho
		1,
		0.6,
		0.15,
		0.9, -- laranja
		1,
		0.95,
		0.2,
		0.8, -- amarelo
		0.2,
		0.9,
		0.3,
		0.7, -- verde
		0.2,
		0.5,
		1,
		0.6, -- azul
		0.6,
		0.2,
		0.95,
		0.4                        -- roxo
	)
	ps:setDirection(-1.5707963705063) -- para baixo
	ps:setLinearAcceleration(0, 85, 0, 240)
	ps:setEmissionArea("normal", 10, 10, 0, false)
	ps:setEmissionRate(70)
	ps:setEmitterLifetime(-1)
	ps:setLinearDamping(4, 6)
	ps:setParticleLifetime(0.55, 1.05)
	ps:setSizes(0.16, 0.12, 0)
	ps:setSizeVariation(0.4)
	ps:setSpeed(0, 40)
	ps:setSpread(3.2831854820251)
	ps:setSpin(-3, -1, 0, -1, -3)
	ps:setSpinVariation(2)
	ps:stop()

	return ps
end
