----------------------------------------------------------------------------
-- Esse arquivo serve de template para usar de export
-- no software HotParticles. Ele gera um construtor
-- pronto para apenas ser colocado em modules\constructors\particles.lua
----------------------------------------------------------------------------

-- Define images. Some may be shared between multiple particle systems.
local imageIdentBySystem = {}
local imageIdentByTexturePath = {}
local imageIdentByTexturePreset = {}
local imageN = 0

for _, ps in ipairs(exported.particleSystems) do
	local imageIdentByKey = ps.texturePath ~= "" and imageIdentByTexturePath or imageIdentByTexturePreset
	local key = ps.texturePath ~= "" and ps.texturePath or ps.texturePreset
	local imageIdent = imageIdentByKey[key]

	if not imageIdent then
		imageN = imageN + 1
		imageIdent = "particleImg" .. imageN
		imageIdentByKey[key] = imageIdent

		if ps.texturePath == "" then
			Text"local " Text(imageIdent) Text" = ? -- Preset: " Text(ps.texturePreset) Text"\n"
		else
			Text"local " Text(imageIdent) Text" = assetManager:getImage(\"assets/sprites/" Lua(ps.texturePath) Text"\")\n"
		end

		if exported.pixelateTextures then
			Text(imageIdent) Text":setFilter(\"nearest\", \"nearest\")\n"
		else
			Text(imageIdent) Text":setFilter(\"linear\", \"linear\")\n"
		end
	end

	imageIdentBySystem[ps] = imageIdent
end

-- Define particle constructors.
for _, ps in ipairs(exported.particleSystems) do
	Text"\n"
	Text"---@return ParticleSystem\n"
	Text"function new" Text(ps.title ~= "" and ps.title or "Particle") Text"Particles()\n"
	Text"\t-- Blend mode: " 			  LuaCsv(ps.blendMode) 				Text"\n"
	Text"\tlocal ps = love.graphics.newParticleSystem(" Text(imageIdentBySystem[ps]) Text", " Lua(ps.bufferSize) Text")\n\n"

	Text"\tps:setColors("                 LuaCsv(ps.colors)                 Text")\n"
	Text"\tps:setDirection("              LuaCsv(ps.direction)              Text")\n"
	Text"\tps:setEmissionArea("           LuaCsv(ps.emissionArea)           Text")\n"
	Text"\tps:setEmissionRate("           LuaCsv(ps.emissionRate)           Text")\n"
	Text"\tps:setEmitterLifetime("        LuaCsv(ps.emitterLifetime)        Text")\n"
	Text"\tps:setInsertMode("             LuaCsv(ps.insertMode)             Text")\n"
	Text"\tps:setLinearAcceleration("     LuaCsv(ps.linearAcceleration)     Text")\n"
	Text"\tps:setLinearDamping("          LuaCsv(ps.linearDamping)          Text")\n"	
	Text"\tps:setOffset("                 LuaCsv(ps.textureOffset)          Text")\n"	
	Text"\tps:setParticleLifetime("       LuaCsv(ps.particleLifetime)       Text")\n"	
	Text"\tps:setRadialAcceleration("     LuaCsv(ps.radialAcceleration)     Text")\n"	
	Text"\tps:setRelativeRotation("       LuaCsv(ps.relativeRotation)       Text")\n"	
	Text"\tps:setRotation("               LuaCsv(ps.rotation)               Text")\n"	
	Text"\tps:setSizes("                  LuaCsv(ps.sizes)                  Text")\n"	
	Text"\tps:setSizeVariation("          LuaCsv(ps.sizeVariation)          Text")\n"	
	Text"\tps:setSpeed("                  LuaCsv(ps.speed)                  Text")\n"	
	Text"\tps:setSpin("                   LuaCsv(ps.spin)                   Text")\n"	
	Text"\tps:setSpinVariation("          LuaCsv(ps.spinVariation)          Text")\n"	
	Text"\tps:setSpread("                 LuaCsv(ps.spread)                 Text")\n"	
	Text"\tps:setTangentialAcceleration(" LuaCsv(ps.tangentialAcceleration) Text")\n"
	
	if ps.quads[1] then
		Text"\tps:setQuads("
		for i, quad in ipairs(ps.quads) do
			if i > 1 then Text", " end
			Text"love.graphics.newQuad(" LuaCsv(quad) Text")"
		end
		Text")\n"
	end

	Text"\tps:stop()\n"
	Text"\n"
	Text"\treturn ps\n"
	Text"end\n"
end