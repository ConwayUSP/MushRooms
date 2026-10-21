----------------------------------------
-- Importações de Módulos
----------------------------------------
require("modules.UI.uielement")

----------------------------------------
-- Classe UISwitchElem
----------------------------------------

--- Elemento de UI que alterna entre dois estados (on/off).
--- Usa `UI_BUTTON_ELEM` como subtype para reaproveitar o clique/navegação existentes.
--- Os sprites combinam seleção e valor: idle_off, idle_on, selected_off, selected_on.
UISwitchElem = setmetatable({}, { __index = UIElement })
UISwitchElem.__index = UISwitchElem

local OFF_IDLE = IDLE .. "_off"
local ON_IDLE = IDLE .. "_on"
local OFF_SELECTED = SELECTED .. "_off"
local ON_SELECTED = SELECTED .. "_on"

---@param name string nome da pasta de sprites (ex.: "switch")
---@param pos Vec centro do switch no espaço base (1280x720)
---@param elSize Size área de hit e tamanho de desenho
---@param hitboxes Hitboxes?
---@param isOn? boolean estado inicial
---@param onToggle? fun(isOn: boolean) chamado após alternar o valor
function UISwitchElem.new(name, pos, elSize, hitboxes, isOn, onToggle)
	local sw = setmetatable({}, UISwitchElem)
	sw:init(name, UI_BUTTON_ELEM, pos, elSize, hitboxes)
	sw.on = not not isOn
	sw.onToggle = onToggle
	sw.state = sw:currentState()

	local animSettings = {}
	for _, state in ipairs({ OFF_IDLE, ON_IDLE, OFF_SELECTED, ON_SELECTED }) do
		animSettings[state] = newAnimSetting(1, size(24, 12), 1, true, 1)
	end
	sw:addAnimations(animSettings)

	return sw
end

---@return string estado de animação atual (combina seleção com o valor)
function UISwitchElem:currentState()
	if self.selected then
		return self.on and ON_SELECTED or OFF_SELECTED
	end
	return self.on and ON_IDLE or OFF_IDLE
end

---@param instant? boolean
function UISwitchElem:select(instant)
	self.selected = true
	self.state = self:currentState()
	local animation = self.animations[self.state]
	if animation then
		if instant then
			animation:finish()
		else
			animation:reset()
		end
	end
end

---@param instant? boolean
function UISwitchElem:deselect(instant)
	self.selected = false
	self.state = self:currentState()
	local animation = self.animations[self.state]
	if animation then
		if instant then
			animation:finish()
		else
			animation:reset()
		end
	end
end

---@param isOn boolean
function UISwitchElem:setOn(isOn)
	self.on = not not isOn
	self.state = self:currentState()
end

-- alterna o valor e aplica a mudança (chamada pela UI como um botão)
function UISwitchElem:onClick()
	self:setOn(not self.on)
	if self.onToggle then
		self.onToggle(self.on)
	end
end
