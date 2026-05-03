----------------------------------------
-- Importações de Módulos
----------------------------------------
require("modules.UI.uielement")

----------------------------------------
-- Classe UITextElem
----------------------------------------

UITextElem = setmetatable({}, { __index = UIElement })
UITextElem.__index = UITextElem

function UITextElem.new(name, pos, size, scale, hitboxes, color, text)
	local txt = setmetatable({}, UITextElem)
	txt:init(name, UI_TEXT_ELEM, pos, size, hitboxes)
	txt.color = color
	txt.text = text
	txt.scale = scale
	return txt
end

function UITextElem:draw(camera)
	local viewPos = self.pos
	if camera then
		viewPos = camera:viewPos(self.pos)
	end
	love.graphics.setColor(self.color.r, self.color.g, self.color.b, self.color.a)
	love.graphics.printf(self.text, viewPos.x, viewPos.y, self.size.width, "center", 0, self.scale, self.scale)
	love.graphics.setColor(1, 1, 1, 1)
end
