----------------------------------------
-- Importações de Módulos
----------------------------------------
require("modules.UI.uielement")

----------------------------------------
-- Classe UITextElem
----------------------------------------

UITextElem = setmetatable({}, { __index = UIElement })
UITextElem.__index = UITextElem

function UITextElem.new(name, pos, size, hitboxes, text)
	local txt = setmetatable({}, UITextElem)
	txt:init(name, UI_TEXT_ELEM, pos, size, hitboxes)
	txt.text = text
	return txt
end
