----------------------------------------
-- Importações de Módulos
----------------------------------------
require("modules.UI.uielement")
require("modules.UI.elements.button")
require("modules.UI.elements.image")

function newResourceItemElement(resName, invLength, canvasSize)
	local canvasCenter = vec(canvasSize.width / 2, canvasSize.height / 2)
	local leftMargin = canvasCenter.x - 300
	local topMargin = canvasCenter.y
	local col = math.fmod(invLength - 1, 5)
	local row = math.floor((invLength - 1) / 5)
	local posX = leftMargin + col * 108
	local posY = topMargin + row * 108
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
	local onClick = function(scene)
		scene.player:startBuildingMode(CONSTRUCTORS[PRODUCT][recipe.output.name]())
	end
	local itemEl = UIButtonElem.new(itemName, finalPos, size(96, 96), nil, onClick)
	local animSettings = {}
	animSettings[IDLE] = newAnimSetting(1, size(32, 32), 1, true, 1)
	animSettings[SELECTED] = newAnimSetting(1, size(32, 32), 1, true, 1)
	for state, settings in pairs(animSettings) do
		local path = pngPathFormat({ "assets", "sprites", "recipes", itemName })
		addAnimation(itemEl, path, state, settings)
	end

	-- propriedade extra para termos uma referência à receita
	itemEl.recipe = recipe

	return itemEl
end

function newCraftingItemPreviewElement(itemName, coords, elSize, path)
	local itemEl = setmetatable({}, UIElement)
	itemEl:init("item preview image", UI_IMAGE_ELEM, coords, elSize, nil)
	local settings = newAnimSetting(1, size(32, 32), 1, true, 1)
	addAnimation(itemEl, path, IDLE, settings)

	return itemEl
end
