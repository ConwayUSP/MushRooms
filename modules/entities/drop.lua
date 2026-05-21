----------------------------------------
-- Importações
----------------------------------------
require("modules.engine.collision")
require("modules.entities.entity")
require("modules.entities.player")
require("modules.systems.shaders")
require("modules.systems.movement")
require("modules.utils.types")
require("modules.utils.utils")
require("modules.utils.vec")
require("modules.systems.shaders")
require("table")

----------------------------------------
-- Classe Drop
----------------------------------------

---@class Drop: Entity
---@field object any
---@field collected boolean
---@field autoPick boolean
---@field gravity number
---@field floorY number
---@field idleTimer number
---@field shine boolean
---@field canPick boolean
---@field image table
---@field setCollected function
---@field state string
---@field visualOffset Vec

Drop = setmetatable({}, { __index = Entity })
Drop.__index = Drop
Drop.type = DROP

---@param object any
---@param pos Vec
---@param room Room
---@param autoPick boolean
---@param floorY number
---@return Drop
-- cria uma instância de `Drop`
function Drop.new(object, pos, room, autoPick, floorY)
	---@type Drop
	local drop = setmetatable({}, Drop) ---@diagnostic disable-line

	local hbRadius = autoPick and 30 or 60
	local hb = hitbox(Circle.new(hbRadius))
	local hbs = hitboxes({}, {}, { hb })
	local physics = physicsSettings(0.5, 0, 6)
	drop:init(object.name, pos, hbs, room, physics)

	drop.object = object -- objeto associado ao drop (arma, recurso, etc)
	drop.pos = pos -- posição do drop no mundo
	drop.autoPick = autoPick -- se o drop é coletado automaticamente ou manualmente
	drop.floorY = drop.pos.y + (floorY or 0) -- posição onde irá parar de cair

	drop.visualOffset = vec(0, 0) -- offset visual para renderização
	drop.gravity = 1500 -- força da gravidade
	drop.idleTimer = 0 -- timer para oscilar enquanto parado
	drop.collected = false -- flag de coleta
	drop.shine = false -- se está brilhando
	drop.canPick = false -- se o drop pode ser coletado (true após terminar de cair)
	drop.state = "falling" -- estado inicial do drop
	drop.hasShadow = true
	drop.shadowWidth = 15

	if object.image then
		drop.image = object.image
	else
		local sprite_path = pngPathFormat({ "assets", "sprites", "drops", object.name })
		drop.image = love.graphics.newImage(sprite_path)
		drop.image:setFilter("nearest", "nearest")
	end

	collisionManager:register(drop)
	table.insert(room.drops, drop)
	return drop
end

----------------------------------------
-- Atualização
----------------------------------------

---@param dt number
-- atualiza o estado do `Drop`
function Drop:update(dt)
	self:move(dt)
end

---@param dt number
-- movimenta o item, fazendo ele oscilar acima do chão ao colidir com ele
function Drop:move(dt)
	if not self.canPick then
		applyForce(self, vec(0, self.gravity * self.mass))
		applyPhysics(self, dt)

		-- checa se está apoiado em algo
		if self:isGrounded() then
			self.vel.y = 0
			self.acc.y = 0
			self.canPick = true
			self.state = "idle"
		end
		return
	end

	self:updateIdle(dt)
end

function Drop:updateIdle(dt)
	self.idleTimer = self.idleTimer + dt

	-- oscilação suave
	local amplitude = 5
	local speed = 5

	self.visualOffset.y = math.sin(self.idleTimer * speed) * amplitude
end

function Drop:isGrounded()
	return self.pos.y > self.floorY and self.vel.y > 0
end

---@param value boolean
-- define se o item está brilhando (bordas brancas) ou não
function Drop:setShine(value)
	self.shine = value
end

----------------------------------------
-- Renderização
----------------------------------------

---@param camera Camera
-- função de renderização do `Drop` - desenha ele na
-- perspectiva da `camera` passada como argumento
function Drop:draw(camera)
	local scale = 3
	if self.object.type == RESOURCE then
		love.graphics.setShader(rescaleShader)
		scale = 1.875 -- para manter a escala dos pixels com a textura 20x20
	end

	if self.collected then
		return
	end

	local visualPos = addVec(self.pos, self.visualOffset)
	local viewPos = camera:viewPos(visualPos)
	local offset = {
		x = self.image:getWidth() / 2,
		y = self.image:getHeight() / 2,
	}

	if self.shine and self.object.type ~= RESOURCE then
		drawSpriteWithOutline(self.image, viewPos.x, viewPos.y, scale, offset)
	else
		love.graphics.draw(self.image, viewPos.x, viewPos.y, 0, scale, scale, offset.x, offset.y)
	end
	love.graphics.setShader()
end

-- marca o `Drop` como tendo sido coletado
function Drop:setCollected()
	self.collected = true
	collisionManager:unregister(self)
	local index = tableIndexOf(self.room.drops, self)
	if index then
		table.remove(self.room.drops, index)
	end
end

----------------------------------------
-- Funções Globais
----------------------------------------

---@param object any
---@param pos Vec
---@param room any
---@param autoPick boolean
---@param floorY number
---@param impuselVec Vec
---@return Drop
function spawnDrop(object, pos, room, autoPick, floorY, impuselVec)
	local drop = newDrop(object, pos, room, autoPick, floorY)

	if nullVec(impuselVec) then
		drop.canPick = true
		return drop
	end

	applyImpulse(drop, impuselVec)
	return drop
end

---@param object any
---@param pos Vec
---@param room any
---@param autoPick boolean
---@param floorY number
---@return Drop
function newDrop(object, pos, room, autoPick, floorY)
	return Drop.new(object, pos, room, autoPick, floorY)
end

return Drop
