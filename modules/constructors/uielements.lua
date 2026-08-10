----------------------------------------
-- Importações de Módulos
----------------------------------------
require("modules.UI.uielement")
require("modules.UI.elements.button")
require("modules.UI.elements.image")

function newResourceItemElement(resName, invLength, topLeft, spacing, numColumns)
	local col = math.fmod(invLength - 1, numColumns)
	local row = math.floor((invLength - 1) / numColumns)
	local posX = topLeft.x + col * spacing
	local posY = topLeft.y + row * spacing
	local resourceEl = UIButtonElem.new(resName, vec(posX, posY), size(96, 96), nil, function(scene)
		print("Recurso clicado: " .. resName)
	end)
	local animSettings = {}
	animSettings[IDLE] = newAnimSetting(1, size(32, 32), 1, true, 1)
	animSettings[SELECTED] = newAnimSetting(1, size(32, 32), 1, true, 1)
	for state, settings in pairs(animSettings) do
		local path = pngPathFormat({ "assets", "sprites", "resources", resName })
		addAnimation(resourceEl, path, state, settings)
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
