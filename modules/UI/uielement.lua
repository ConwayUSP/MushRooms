----------------------------------------
-- Classe UIScene
----------------------------------------

---@class UIElement
---@field name string
---@field subtype Type
---@field pos Vec
---@field size Size
---@field hb Hitboxes
---@field state string
---@field selected boolean
---@field spriteSheets table
---@field animations table

UIElement = {}
UIElement.__index = UIElement
UIElement.type = UI_ELEMENT

---@param name string
---@param elementType Type
---@param pos Vec
---@param size Size
---@param hitboxes? Hitboxes
-- inicializa um elemento de UI com estado `IDLE` e selected = `false`
function UIElement:init(name, elementType, pos, size, hitboxes)
	self.name = name
	self.subtype = elementType
	self.pos = pos
	self.size = size
	self.hb = hitboxes
	self.state = IDLE
	self.selected = false
	self.spriteSheets = {}
	self.animations = {}
	return self
end

---@param animSettings table<string, AnimSettings>
-- adiciona animações ao elemento de UI
function UIElement:addAnimations(animSettings)
	for state, settings in pairs(animSettings) do
		local path = pngPathFormat({ "assets", "animations", "UI", self.name, state })
		addAnimation(self, path, state, settings)
	end
end

---@param dt number
-- atualiza a animação do elemento de UI
function UIElement:update(dt)
	if not self.animations[self.state] then
		return
	end

	self.animations[self.state]:update(dt)
end

-- marca o elemento de UI como `selected` e seu estado como `SELECTED`
function UIElement:select()
	self.selected = true
	self.state = SELECTED
end

-- marca o elemento de UI como não selecionado e seu estado como `IDLE`
function UIElement:deselect()
	self.selected = false
	if self.animations[self.state] then
		self.animations[self.state]:reset()
	end
	self.state = IDLE
end

---@param camera Camera
-- renderiza o elemento de UI
function UIElement:draw(camera)
	local viewX = self.pos.x
	local viewY = self.pos.y
	if camera then
		viewX, viewY = camera:viewPos(self.pos)
	end
	local anim = self.animations[self.state]
	if not anim then
		return
	end
	local scale = self.size.width / anim.frameDim.width
	local offsetX = anim.frameDim.width / 2
	local offsetY = anim.frameDim.height / 2

	love.graphics.draw(
		self.spriteSheets[self.state],
		anim.frames[anim.currFrame],
		viewX,
		viewY,
		0,
		scale,
		scale,
		offsetX,
		offsetY
	)
end
