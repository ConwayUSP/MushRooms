----------------------------------------
-- Importações de Módulos
----------------------------------------
require("modules.UI.uiscene")
require("modules.UI.elements.button")
require("modules.UI.elements.image")
require("modules.constructors.uielements")

----------------------------------------
-- Cenas Globais
----------------------------------------

function initMenuScene()
	local menuScene = UIScene.new(UI_MENU_SCENE)
	-- ELEMENTOS
	local menuBg = UIImageElem.new("menu bg", vec(640, 360), size(1280, 720))
	local startBtn = UIButtonElem.new("menu play btn", vec(280, 400), size(120, 120), nil, function()
		print("Botão clicado -> Start")
		startGame()
	end)
	local settingsBtn = UIButtonElem.new("menu opt btn", vec(620, 400), size(120, 120), nil, function()
		print("Botão clicado -> Settings")
	end)
	local quitBtn = UIButtonElem.new("menu quit btn", vec(960, 400), size(120, 120), nil, function()
		print("Botão clicado -> Quit")
		quitGame()
	end)

	-- ANIMAÇÕES
	local animSettings = {}
	animSettings[IDLE] = newAnimSetting(1, size(32, 32), 1, true, 1)
	animSettings[SELECTED] = newAnimSetting(4, size(32, 32), 0.08, true, 4)
	startBtn:addAnimations(animSettings)
	settingsBtn:addAnimations(animSettings)
	quitBtn:addAnimations(animSettings)
	local bgAnimSettings = {}
	bgAnimSettings[IDLE] = newAnimSetting(1, size(320, 180), 1, true, 1)
	menuBg:addAnimations(bgAnimSettings)

	-- SETUP DA CENA
	menuScene:addElement(menuBg, BG_LAYER_1, vec(1, 1))
	menuScene:addElement(startBtn, ELEM_LAYER_1, vec(1, 1))
	menuScene:addElement(settingsBtn, ELEM_LAYER_1, vec(2, 1))
	menuScene:addElement(quitBtn, ELEM_LAYER_1, vec(3, 1))

	return menuScene
end

----------------------------------------
-- Cenas de Player
----------------------------------------

function newResourceInventoryScene(canvasSize)
	local invScene = UIScene.new(UI_INVENTORY_SCENE)
	local canvasCenter = vec(canvasSize.width / 2, canvasSize.height / 2)

	-- ANIMAÇÕES
	local animSettings = {}
	animSettings[IDLE] = newAnimSetting(1, size(32, 32), 1, true, 1)
	animSettings[SELECTED] = newAnimSetting(1, size(32, 32), 1, true, 1)

	local bgAnimSettings = {}
	bgAnimSettings[IDLE] = newAnimSetting(1, size(128, 128), 1, true, 1)

	-- BACKGROUND
	local pos = subVec(canvasCenter, vec(256, 256))
	local invBg = UIImageElem.new("resource inventory bg", canvasCenter, size(768, 768))
	invBg:addAnimations(bgAnimSettings)
	invScene:addElement(invBg, BG_LAYER_1, vec(1, 1))

	-- SLOTS
	local leftMargin = canvasCenter.x - 300
	local topMargin = canvasCenter.y
	for row = 0, 2 do
		for col = 0, 4 do
			local posX = leftMargin + col * 108
			local posY = topMargin + row * 108
			local slot = UIImageElem.new("resource slot", vec(posX, posY), size(96, 96))
			slot:addAnimations(animSettings)
			invScene:addElement(slot, ELEM_LAYER_1, vec(col + 1, row + 1))
		end
	end

	-- MÉTODOS AUXILIARES
	function invScene:addResourceEl(resource, inventory, canvasSize)
		local invLength = inventory:length(RESOURCE)
		local col = math.fmod(invLength - 1, 5)
		local row = math.floor((invLength - 1) / 5)
		local resourceEl = newResourceItemElement(resource.name, invLength, canvasSize)
		self:addElement(resourceEl, ELEM_LAYER_2, vec(col + 1, row + 1))
	end

	return invScene
end

function newCraftingScene(canvasSize, player)
	local invScene = UIScene.new(UI_CRAFTING_SCENE)
	local canvasCenter = vec(canvasSize.width / 2, canvasSize.height / 2)

	local COLS = 3
	local ROWS = 4

	local sizeSlot = size(96, 96)
	local slotOffset = vec(sizeSlot.width + 12, sizeSlot.height + 12)
	local marginOffset = vec(300, 100)
	local leftMargin = canvasCenter.x - marginOffset.x
	local topMargin = canvasCenter.y - marginOffset.y

	-- ANIMAÇÕES
	local animSettings = {}
	animSettings[IDLE] = newAnimSetting(1, size(32, 32), 1, true, 1)
	animSettings[SELECTED] = newAnimSetting(1, size(32, 32), 1, true, 1)

	local bgAnimSettings = {}
	bgAnimSettings[IDLE] = newAnimSetting(1, size(128, 128), 1, true, 1)

	-- BACKGROUND
	local pos = subVec(canvasCenter, vec(256, 256))
	local invBg = UIImageElem.new("crafting bg", canvasCenter, size(768, 768))
	invBg:addAnimations(bgAnimSettings)
	invScene:addElement(invBg, BG_LAYER_1, vec(1, 1))

	-- ARROWS
	local arrowSize = size(32, 32)
	local secondColX = leftMargin + slotOffset.x
	local arrowUpY = topMargin - (sizeSlot.height / 2) - (arrowSize.height / 2) - 8
	local lastRowY = topMargin + (ROWS - 1) * slotOffset.y + (sizeSlot.height / 2) + (arrowSize.height / 2) + 8

	local arrowUp = UIButtonElem.new("crafting arrow up", vec(secondColX, arrowUpY), arrowSize, nil, function()
		print("Botão clicado -> Arrow Up")
	end)
	local arrowDown = UIButtonElem.new("crafting arrow down", vec(secondColX, lastRowY), arrowSize, nil, function()
		print("Botão clicado -> Arrow Down")
	end)
	arrowUp:addAnimations(animSettings)
	arrowDown:addAnimations(animSettings)

	invScene:addElement(arrowUp, ELEM_LAYER_1, vec(2, 1))
	invScene:addElement(arrowDown, ELEM_LAYER_1, vec(2, ROWS + 2))

	-- SLOTS
	for row = 0, ROWS - 1 do
		for col = 0, COLS - 1 do
			local posX = leftMargin + col * slotOffset.x
			local posY = topMargin + row * slotOffset.y
			local slot = UIImageElem.new("resource slot", vec(posX, posY), sizeSlot)
			slot:addAnimations(animSettings)
			invScene:addElement(slot, ELEM_LAYER_1, vec(col + 1, row + 2))
		end
	end

	-- INITIAL RECIPES
	for i, recipe in ipairs(player.craftingManager.recipes) do
		local x = math.fmod(i - 1, COLS)
		local y = math.floor((i - 1) / COLS)
		local itemEl = newCraftingItemElement(recipe, vec(leftMargin, topMargin), slotOffset, x, y)
		invScene:addElement(itemEl, ELEM_LAYER_2, vec(x + 1, y + 2))
	end

	-- SELECTED ITEM SLOT
	local selectedSlotPos = vec(canvasCenter.x + marginOffset.x - slotOffset.x, canvasCenter.y - 100)
	function invScene:addSelectedItemPreviewSlot()
		local selectedSlotSize = size(128, 128)
		local selectedSlot = UIImageElem.new("resource slot", selectedSlotPos, selectedSlotSize)
		selectedSlot:addAnimations(animSettings)
		invScene:addElement(selectedSlot, VISUAL_LAYER_1, vec(4, 3))
	end

	-- -- SLOTS RESOURCES REQUIRED FOR CRAFTING
	local sizeMiniSlot = size(72, 72)
	local miniSlotOffset = sizeMiniSlot.width + 8
	function invScene:addRecipeIngredientSlot(col)
		local posX = selectedSlotPos.x - miniSlotOffset * 1.5 + col * miniSlotOffset
		local posY = canvasCenter.y + 200
		local slot = UIImageElem.new("resource slot", vec(posX, posY), sizeMiniSlot)
		slot:addAnimations(animSettings)
		invScene:addElement(slot, VISUAL_LAYER_1, vec(4 + col, 4))
	end

	-- ATUALIZAÇÃO AUTOMÁTICA DOS DETALHES AO MUDAR A SELEÇÃO
	local previewPos = vec(canvasCenter.x + 190, canvasCenter.y - 100)
	local ingredientsY = canvasCenter.y + 200
	function invScene:onSelectionChange()
		-- limpa a área de detalhes (Camadas Visuais onde colocaremos o preview)
		self.layers[VISUAL_LAYER_1] = {}
		self.layers[VISUAL_LAYER_2] = {}

		-- pega o elemento selecionado atualmente
		local sel = self.layers[ELEM_LAYER_2][self.selectionPos.y]
			and self.layers[ELEM_LAYER_2][self.selectionPos.y][self.selectionPos.x]

		-- se for um elemento de receita, desenha os detalhes
		if sel and sel.recipe then
			local recipe = sel.recipe

			-- adiciona o preview do item (grande)
			self:addSelectedItemPreviewSlot()
			local spritePath = pngPathFormat({ "assets", "sprites", "recipes", recipe.output.name })
			local previewImg = newCraftingItemPreviewElement(recipe.output.name, previewPos, size(128, 128), spritePath)
			self:addElement(previewImg, VISUAL_LAYER_2, vec(1, 1))

			-- adiciona os ingredientes abaixo
			for i, input in pairs(recipe.inputs) do
				self:addRecipeIngredientSlot(i)
				local resName = input[1].name
				local qty = input[2]

				local slotX = previewPos.x - 38 + (i - 1) * 80
				local spritePath = pngPathFormat({ "assets", "sprites", "resources", resName })
				local ingredientEl =
					newCraftingItemPreviewElement(resName, vec(slotX, ingredientsY), size(96, 96), spritePath)
				self:addElement(ingredientEl, VISUAL_LAYER_2, vec(i, 2))
			end
		end
	end

	invScene:onSelectionChange()

	return invScene
end
