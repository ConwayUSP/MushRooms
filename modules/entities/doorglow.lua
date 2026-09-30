----------------------------------------
-- Importações de Módulos
----------------------------------------

----------------------------------------
-- Classe DoorGlow
----------------------------------------

local LIGHT_SIZE = { width = 72, height = 72 }

---@class DoorGlow
---@field pos Vec
---@field door Interactive
---@field artName string
---@field state State
---@field animations table<State, Animation>
---@field spriteSheets table<State, table>
---@field update fun(self: DoorGlow, dt: number) : nil
---@field draw fun(self: DoorGlow, camera: Camera) : nil

DoorGlow = {}
DoorGlow.__index = DoorGlow

---@param room Room
---@param door Interactive
---@return DoorGlow
-- cria a luz que escorre por baixo de uma porta aberta
function DoorGlow.new(room, door)
	---@type DoorGlow
	local glow = setmetatable({}, DoorGlow)
	glow.door = door
	glow.state = door.state

	local spriteName
	local offsetX, offsetY
	if door.name == DOOR_LEFT.name then
		spriteName = "door_glow_left"
		offsetX = 100
		offsetY = 120
	elseif door.name == DOOR_RIGHT.name then
		spriteName = "door_glow_right"
		offsetX = -100
		offsetY = 120
	else
		spriteName = "door_glow_down"
		offsetX = 0
		offsetY = -140
	end
	glow.pos = vec(door.pos.x + offsetX, door.pos.y + offsetY)

	local animSettings = {}
	animSettings[OPEN] = newAnimSetting(1, LIGHT_SIZE, 1000, true, 1)
	animSettings[CLOSED] = newAnimSetting(1, LIGHT_SIZE, 1000, true, 1)
	animSettings[OPENING] = newAnimSetting(11, LIGHT_SIZE, 0.05, false, 1)
	animSettings[CLOSING] = newAnimSetting(11, LIGHT_SIZE, 0.05, false, 1)

	glow.animations = {}
	glow.spriteSheets = {}
	for state, settings in pairs(animSettings) do
		local path = pngPathFormat({ "assets", "animations", "interactives", spriteName, state })
		glow.animations[state] = newAnimation(path, settings)
		glow.spriteSheets[state] = assetManager:getImage(path)
	end

	return glow
end

---@param dt number
-- mantém a luz em sincronia com a porta: quando a porta troca de estado, a
-- animação do estado de entrada é resetada para começar do zero
function DoorGlow:update(dt)
	if self.state ~= self.door.state then
		self.state = self.door.state
		self.animations[self.state]:reset()
	end
	self.animations[self.state]:update(dt)
end

---@param camera Camera
-- renderiza o brilho na perspectiva da `camera`
function DoorGlow:draw(camera)
	local viewX, viewY = camera:viewPos(self.pos)
	local anim = self.animations[self.state]

	love.graphics.setColor(1, 1, 1, 0.6)
	love.graphics.draw(
		self.spriteSheets[self.state],
		anim.frames[anim.currFrame],
		viewX,
		viewY,
		0,
		3,
		3,
		anim.frameDim.width / 2,
		anim.frameDim.height / 2
	)
	love.graphics.setColor(1, 1, 1, 1.0)
end

return DoorGlow
