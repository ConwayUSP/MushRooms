----------------------------------------
-- Importações de Módulos
----------------------------------------
require("modules.UI.uielement")
require("modules.UI.elements.button")
require("modules.UI.elements.image")

---@param resource Resource
---@param pos Vec
---@param onClick? function
---@param quantityBounds? Size
---@return UIButtonElem
function newResourceItemElement(resource, pos, onClick, quantityBounds)
	local resourceEl = UIButtonElem.new(resource.name, pos, size(96, 96), nil, onClick or function()
		print("Recurso clicado: " .. resource.name)
	end)
	resourceEl.resource = resource
	resourceEl.quantityBounds = quantityBounds or resourceEl.size

	local animSettings = {}
	animSettings[IDLE] = newAnimSetting(1, size(32, 32), 1, true, 1)
	animSettings[SELECTED] = newAnimSetting(1, size(32, 32), 1, true, 1)
	for state, settings in pairs(animSettings) do
		local path = pngPathFormat({ "assets", "sprites", "resources", resource.name })
		addAnimation(resourceEl, path, state, settings)
	end

	-- desenha a quantidade no canto inferior direito do slot que contém o recurso
	resourceEl.draw = function(self, camera)
		UIElement.draw(self, camera)

		local viewX = self.pos.x
		local viewY = self.pos.y
		if camera then
			viewX, viewY = camera:viewPos(self.pos)
		end

		local quantity = tostring(self.resource.quantity or 1)
		local padding = 6
		local textX = viewX - self.quantityBounds.width / 2 + 12
		local textY = viewY + self.quantityBounds.height / 2 - mushFont:getHeight() - padding
		local textWidth = self.quantityBounds.width - padding * 2
		local previousFont = love.graphics.getFont()
		local r, g, b, a = love.graphics.getColor()

		love.graphics.setFont(mushMidFont)
		love.graphics.setColor(110 / 255, 175 / 255, 112 / 255, 1)
		love.graphics.printf(quantity, textX, textY, textWidth, "right") -- texto normal

		love.graphics.setFont(previousFont)
		love.graphics.setColor(r, g, b, a)
	end

	return resourceEl
end

function newCraftingItemElement(recipe, coordStart, vecOffset, x, y)
	local itemName = recipe.output.name
	local vec = vec(x * vecOffset.x, y * vecOffset.y)
	local finalPos = addVec(coordStart, vec)
	local onClick = function(self)
		local p = self.ctx.player
		if recipe:canCraftWith(p.inventory) then
			p:startBuildingMode(CONSTRUCTORS[PRODUCT][itemName](), recipe)
		end
	end
	local itemEl = UIButtonElem.new(itemName, finalPos, size(96, 96), nil, onClick)
	local animSettings = {}
	animSettings[IDLE] = newAnimSetting(1, size(45, 45), 1, true, 1)
	animSettings[SELECTED] = newAnimSetting(1, size(45, 45), 1, true, 1)
	for state, settings in pairs(animSettings) do
		local path = pngPathFormat({ "assets", "sprites", "recipes", itemName })
		addAnimation(itemEl, path, state, settings)
	end

	-- propriedade extra para termos uma referência à receita
	itemEl.recipe = recipe

	itemEl.draw = function(self, camera)
		if self.unavailable then
			love.graphics.setShader(cannotBuildShader)
		end
		UIElement.draw(self, camera)
	end

	return itemEl
end

function newCraftingItemPreviewElement(itemName, coords, elSize, path, spriteDim)
	local itemEl = setmetatable({}, UIElement)
	itemEl:init("item preview image", UI_IMAGE_ELEM, coords, elSize, nil)
	local settings = newAnimSetting(1, size(spriteDim, spriteDim), 1, true)
	addAnimation(itemEl, path, IDLE, settings)

	return itemEl
end

---@class UIItemCollectedElem : UIElement
---@field item any
---@field itemType Type
---@field title string
---@field description string
UIItemCollectedElem = setmetatable({}, { __index = UIElement })
UIItemCollectedElem.__index = UIItemCollectedElem

---@param item any
---@param margin? number
---@return UIItemCollectedElem
-- cartão escalável para comunicar que um equipamento foi adquirido
function UIItemCollectedElem.new(item, margin)
	local element = setmetatable({}, UIItemCollectedElem)
	element:init("item collected", UI_IMAGE_ELEM, vec(margin or 72, 0), size(320, 94), nil, "left")
	element.item = item
	element.itemType = item.type
	element.title = item.name
	element.description = item.description or "Descrição indisponível."
	element.iconSize = item.type == BLESSING and 50 or 72

	local iconPath
	local sizeAnim
	if item.type == BLESSING then
		iconPath = pngPathFormat({ "assets", "sprites", "blessings", item.name })
		sizeAnim = size(16, 16)
	else
		iconPath = pngPathFormat({ "assets", "sprites", "icons", item.type .. "s", item.name })
		sizeAnim = size(32, 32)
	end
	addAnimation(element, iconPath, IDLE, newAnimSetting(1, sizeAnim, 1, true, 1))

	return element
end

function UIItemCollectedElem:getColorByType()
	if self.itemType == ARTIFACT then
		return 153/255, 255/255, 230/255, 1
	end

	if self.itemType == BLESSING then
		return 237/255, 33/255, 88/255, 1
	end

	if self.itemType == WEAPON then
		return 253/255, 255/255, 153/255, 1
	end

	return 1, 1, 1, 1
end

function UIItemCollectedElem:draw()
	local left = self.pos.x - self.size.width / 2
	local top = self.pos.y - self.size.height / 2
	local previousFont = love.graphics.getFont()

	-- TODO: criar arte bonitinha para o background ao invés de retângulo simples
	love.graphics.setColor(0.06, 0.07, 0.1, 0.92)
	love.graphics.rectangle("fill", left, top, self.size.width, self.size.height)
	love.graphics.setColor(self:getColorByType())
	love.graphics.setLineWidth(3)
	love.graphics.rectangle("line", left + 1.5, top + 1.5, self.size.width - 3, self.size.height - 3)

	local anim = self.animations[IDLE]
	local iconX = left + 18
	local iconY = self.pos.y - self.iconSize / 2
	local iconScale = self.iconSize / anim.frameDim.width
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.draw(self.spriteSheets[IDLE], anim.frames[anim.currFrame], iconX, iconY, 0, iconScale, iconScale)

	local textX = iconX + self.iconSize + 18
	local textWidth = self.size.width - (textX - left) - 22
	love.graphics.setFont(mushFont)
	love.graphics.setColor(self:getColorByType())
	love.graphics.printf(self.title, textX, top + 15, textWidth / 1.15, "left", 0, 1.15, 1.15)
	love.graphics.setColor(0.92, 0.92, 0.96, 1)
	love.graphics.printf("New " .. self.itemType .. " collected", textX, top + 46, textWidth, "left")

	love.graphics.setLineWidth(1)
	love.graphics.setFont(previousFont)
	love.graphics.setColor(1, 1, 1, 1)
end
