----------------------------------------
-- Importações de Módulos
----------------------------------------
require("modules.UI.uielement")

----------------------------------------
-- Classe UILinkElem
----------------------------------------

--- Elemento de UI clicável desenhado como texto (links externos).
--- Usa `UI_BUTTON_ELEM` como subtype para reaproveitar o clique/navegação existentes.
UILinkElem = setmetatable({}, { __index = UIElement })
UILinkElem.__index = UILinkElem

---@param name string
---@param pos Vec centro do link no espaço base (1280x720)
---@param size Size área de hit e largura máxima do texto
---@param onClick fun()
---@param color Color?
---@param text string
---@param scale number?
function UILinkElem.new(name, pos, size, onClick, color, text, scale)
	local link = setmetatable({}, UILinkElem)
	link:init(name, UI_BUTTON_ELEM, pos, size, nil)
	link.onClick = onClick
	link.color = color or rgba(0.75, 0.85, 1, 1)
	link.text = text
	link.scale = scale or 1
	return link
end

function UILinkElem:draw(camera)
	local viewX = self.pos.x
	local viewY = self.pos.y
	if camera then
		viewX, viewY = camera:viewPos(self.pos)
	end

	if self.selected then
		love.graphics.setColor(1, 1, 0.6, 1)
	else
		love.graphics.setColor(self.color.r, self.color.g, self.color.b, self.color.a)
	end

	love.graphics.printf(
		self.text,
		viewX - self.size.width / 2,
		viewY - 8 * self.scale,
		self.size.width,
		"left",
		0,
		self.scale,
		self.scale
	)
	love.graphics.setColor(1, 1, 1, 1)
end
