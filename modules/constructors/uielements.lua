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
		local textX = viewX - self.quantityBounds.width / 2
		local textY = viewY + self.quantityBounds.height / 2 - mushFont:getHeight() - padding
		local textWidth = self.quantityBounds.width - padding * 2
		local previousFont = love.graphics.getFont()
		local r, g, b, a = love.graphics.getColor()

		love.graphics.setFont(mushFont)
		love.graphics.setColor(0, 0, 0, 0.85)
		love.graphics.printf(quantity, textX + 2, textY + 2, textWidth, "right") -- texto sombreado
		love.graphics.setColor(1, 1, 1, 1)
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
		self.ctx.player:startBuildingMode(CONSTRUCTORS[PRODUCT][recipe.output.name]())
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

	return itemEl
end

function newCraftingItemPreviewElement(itemName, coords, elSize, path, spriteDim)
	local itemEl = setmetatable({}, UIElement)
	itemEl:init("item preview image", UI_IMAGE_ELEM, coords, elSize, nil)
	local settings = newAnimSetting(1, size(spriteDim, spriteDim), 1, true)
	addAnimation(itemEl, path, IDLE, settings)

	return itemEl
end
