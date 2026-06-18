outlineShader = love.graphics.newShader("shaders/outline.glsl")
positioningShader = love.graphics.newShader("shaders/positioning.glsl")
rescaleShader = love.graphics.newShader("shaders/rescale.glsl")
whiteShader = love.graphics.newShader("shaders/white.glsl")
ditherShadowShader = love.graphics.newShader("shaders/dithershadow.glsl")
deadBodyShader = love.graphics.newShader("shaders/deadbody.glsl")
healingShader = love.graphics.newShader("shaders/healing.glsl")
invisibilityShader = love.graphics.newShader("shaders/invisibility.glsl")

rescaleShader:send("new_res", { 20, 20 })

---@param image table
---@param x number
---@param y number
---@param scale? number
---@param thickness? number
---@param outlineColor? table
-- desenha uma imagem com um shader de outline (borda)
function drawSpriteWithOutline(image, x, y, scale, offset, thickness, outlineColor)
	love.graphics.setShader(outlineShader)

	-- envia os parâmetros do shader
	outlineShader:send("thickness", thickness or 1)
	outlineShader:send("outlineColor", outlineColor or { 1, 1, 1, 1 })
	outlineShader:send("texSize", { image:getWidth(), image:getHeight() })

	love.graphics.draw(image, x, y, 0, scale, scale, offset.x, offset.y)
	love.graphics.setShader()
end

---@param spriteSheet table
---@param quad table
---@param x number
---@param y number
---@param scale? number
---@param thickness? number
---@param outlineColor? table
-- desenha uma imagem com um shader de outline (borda)
function drawFrameWithOutline(spriteSheet, quad, x, y, scale, offset, thickness, outlineColor)
	love.graphics.setShader(outlineShader)
	local width, height = quad:getTextureDimensions()

	-- envia os parâmetros do shader
	outlineShader:send("thickness", thickness or 1)
	outlineShader:send("outlineColor", outlineColor or { 1, 1, 1, 1 })
	outlineShader:send("texSize", { width, height })

	love.graphics.draw(spriteSheet, quad, x, y, 0, scale, scale, offset.x, offset.y)
	love.graphics.setShader()
end
