----------------------------------------
-- Classe Obstacle
----------------------------------------

---@class Obstacle : Entity
---@field animations table<string, Animation>
---@field spriteSheets table<string, table>
---@field arrPos Vec?
---@field scale number?
---@field transparent boolean

Obstacle = setmetatable({}, { __index = Entity })
Obstacle.__index = Obstacle
Obstacle.type = OBSTACLE

function Obstacle.new(name, hbs, spawnPos, room)
	---@type Obstacle
	local ob = setmetatable({}, Obstacle) ---@diagnostic disable-line
	local entityPhysics = physicsSettings(math.huge, 0, 1, nil, nil, nil, 0)
	ob:init(name, spawnPos, hbs, room, entityPhysics)
	ob.scale = 3
	ob.animations = {}
	ob.spriteSheets = {}
	ob.transparent = false

	if name:sub(1, 4) ~= "wall" then
		table.insert(room.obstacles, ob)
	else
		local idx = room:getWallIndex(name)
		if not walls[idx.y] then
			walls:insert(idx.y, BiList.new())
		end
		if not walls[idx.y][idx.x] then -- evitando overwrite
			walls[idx.y]:insert(idx.x, ob)
		end
		ob.arrPos = idx
	end

	return ob
end

---@param idleSettings AnimSettings
-- adiciona a animação do obstáculo (só possuem IDLE)
function Obstacle:addAnimations(idleSettings)
	----------------- IDLE -----------------
	local path = pngPathFormat({ "assets", "animations", "obstacles", self.name })
	addAnimation(self, path, IDLE, idleSettings)
end

---@param dt number
-- atualiza a animação do obstáculo, se houver
function Obstacle:update(dt)
	self.animations[IDLE]:update(dt)
end

---@param glowRadius number
-- faz o objeto emitir luz
function Obstacle:makeGlow(glowRadius)
	self.emitsLight = true
	self.glowRadius = 600
end

function Obstacle:updateTransparentShaderUniforms(shader)
	local anim = self.animations[IDLE]
	local spriteWidth = anim.frameDim.width * self.scale
	local spriteHeight = anim.frameDim.height * self.scale
	local obsLeft = self.pos.x - spriteWidth / 2
	local obsTop = self.pos.y - spriteHeight / 2

	shader:send("aspect_ratio", spriteWidth / spriteHeight)
	shader:send("radius", 0.25)
	shader:send("min_alpha", 0.35)

	for i = 1, 4 do
		local player = players[i]
		if player then
			-- posição relativa do player ao canto superior-esquerdo do obstáculo
			local relX = player.pos.x - obsLeft
			local relY = player.pos.y - obsTop
			-- precisa ser normalizada
			local uvX = relX / spriteWidth
			local uvY = relY / spriteHeight
			shader:send("p" .. i .. "_uv", { uvX, uvY })
		else
			shader:send("p" .. i .. "_uv", { -999.0, -999.0 })
		end
	end
end

function Obstacle:draw(camera)
	local viewPos = camera:viewPos(self.pos)
	local anim = self.animations[IDLE] -- obstáculos só possuem a animação IDLE
	local quad = anim.frames[anim.currFrame]
	local offset = {
		x = anim.frameDim.width / 2,
		y = anim.frameDim.height / 2,
	}

	if self.transparent then
		love.graphics.setShader(seeThroughShader)
		self:updateTransparentShaderUniforms(seeThroughShader)
	end

	love.graphics.draw(
		self.spriteSheets[IDLE],
		quad,
		viewPos.x,
		viewPos.y,
		0,
		self.scale,
		self.scale,
		offset.x,
		offset.y
	)

	if self.transparent or self.emitsLight then
		love.graphics.setShader()
	end
end
