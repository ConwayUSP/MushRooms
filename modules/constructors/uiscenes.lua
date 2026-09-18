----------------------------------------
-- Importações de Módulos
----------------------------------------
require("modules.UI.uiscene")
require("modules.UI.elements.button")
require("modules.UI.elements.image")
require("modules.UI.elements.lifebar")
require("modules.UI.elements.map")
require("modules.UI.elements.text")
require("modules.UI.elements.textbox")
require("modules.constructors.uielements")

----------------------------------------
-- Cenas Globais
----------------------------------------

function initMenuScene()
	local menuScene = UIScene.new(UI_MENU_SCENE)
	-- ELEMENTOS
	local menuBg = UIImageElem.new("menu bg", vec(640, 360), size(1280, 720))
	local startBtn = UIButtonElem.new("menu play btn", vec(300, 400), size(120, 120), nil, function()
		startGame()
	end)
	local settingsBtn = UIButtonElem.new("menu opt btn", vec(640, 400), size(120, 120), nil, function()
		globalUIManager:activateScene(UI_SETTINGS_SCENE)
	end)
	local quitBtn = UIButtonElem.new("menu quit btn", vec(980, 400), size(120, 120), nil, function()
		quitGame()
	end)
	local seedTextbox =
		UITextBox.new("menu seed textbox", vec(640, 600), size(320, 72), nil, Color.new(1, 1, 1, 1), 10, setWorldSeed)

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
	local boxAnimSettings = {}
	boxAnimSettings[IDLE] = newAnimSetting(1, size(80, 16), 1000000, true, 1)
	boxAnimSettings[SELECTED] = newAnimSetting(1, size(80, 16), 1000000, true, 1)
	seedTextbox:addAnimations(boxAnimSettings)

	-- SETUP DA CENA
	menuScene:addElement(menuBg, BG_LAYER_1, vec(1, 1))
	menuScene:addElement(startBtn, ELEM_LAYER_1, vec(1, 1))
	menuScene:addElement(settingsBtn, ELEM_LAYER_1, vec(2, 1))
	menuScene:addElement(quitBtn, ELEM_LAYER_1, vec(3, 1))
	menuScene:addElement(seedTextbox, ELEM_LAYER_1, vec(2, 2))

	return menuScene
end

function initSettingsScene()
	local settingsScene = UIScene.new(UI_SETTINGS_SCENE)
	-- ELEMENTOS
	local settingsBg = UIImageElem.new("settings bg", vec(640, 360), size(1280, 720))
	local controlsBtn = UIButtonElem.new("settings controls btn", vec(656, 260), size(832, 96), nil, function()
		print("MUDAR CONTROLES")
	end)
	local displayBtn = UIButtonElem.new("settings display btn", vec(656, 380), size(832, 96), nil, function()
		print("OPÇÕES DE GRÁFICOS")
	end)
	local creditsBtn = UIButtonElem.new("settings credits btn", vec(656, 500), size(832, 96), nil, function()
		print("CRÉDITOS")
	end)
	local returnBtn = UIButtonElem.new("go back btn", vec(640, 590), size(96, 72), nil, function()
		globalUIManager:deactivateScene(UI_SETTINGS_SCENE)
	end)

	-- ANIMAÇÕES
	local btnAnimSettings = {}
	btnAnimSettings[IDLE] = newAnimSetting(5, size(208, 24), 0.04, true, 5)
	btnAnimSettings[SELECTED] = newAnimSetting(5, size(208, 24), 0.04, true, 5)
	controlsBtn:addAnimations(btnAnimSettings)
	displayBtn:addAnimations(btnAnimSettings)
	creditsBtn:addAnimations(btnAnimSettings)
	local bgAnimSettings = {}
	bgAnimSettings[IDLE] = newAnimSetting(13, size(320, 180), 0.08, true, 1)
	settingsBg:addAnimations(bgAnimSettings)
	local returnAnimSettings = {}
	returnAnimSettings[IDLE] = newAnimSetting(1, size(24, 18), 1000, true, 1)
	returnAnimSettings[SELECTED] = newAnimSetting(2, size(24, 18), 0.8, true, 1)
	returnBtn:addAnimations(returnAnimSettings)

	-- SETUP DA CENA
	settingsScene:addElement(settingsBg, BG_LAYER_1, vec(1, 1))
	settingsScene:addElement(controlsBtn, ELEM_LAYER_1, vec(1, 1))
	settingsScene:addElement(displayBtn, ELEM_LAYER_1, vec(1, 2))
	settingsScene:addElement(creditsBtn, ELEM_LAYER_1, vec(1, 3))
	settingsScene:addElement(returnBtn, ELEM_LAYER_1, vec(1, 4))

	return settingsScene
end

----------------------------------------
-- Cenas de Player
----------------------------------------

function newResourceInventoryScene()
	local invScene = UIScene.new(UI_INVENTORY_SCENE)
	local canvasCenter = vec(640, 360)

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
		if row > 2 then
			return -- ultrapassou o limite do inventário
		end
		local topLeft = addVec(vec(640, 360), vec(-300, 0))
		local resourceEl = newResourceItemElement(resource.name, invLength, topLeft, 108, 5)
		self:addElement(resourceEl, ELEM_LAYER_2, vec(col + 1, row + 1))
	end

	return invScene
end

function newEquipmentScene(player)
	local equipScene = UIScene.new(UI_EQUIPMENT_SCENE, player)
	local canvasCenter = vec(640, 360)

	local bgAnimSettings = {}
	bgAnimSettings[IDLE] = newAnimSetting(1, size(256, 140), 1, true, 1)

	local signatureSettings = {}
	signatureSettings[IDLE] = newAnimSetting(1, size(56, 56), 1, true, 1)

	local slotSettings = {}
	slotSettings[IDLE] = newAnimSetting(1, size(32, 32), 1, true, 1)
	slotSettings[SELECTED] = newAnimSetting(1, size(32, 32), 1, true, 1)

	local decorationSettings = {}
	decorationSettings[IDLE] = newAnimSetting(1, size(15, 39), 1, true, 1)

	-- local ref = UIImageElem.new("equip ref", canvasCenter, size(768, 768))
	-- ref:addAnimations(bgAnimSettings)
	-- equipScene:addElement(ref, BG_LAYER_1, vec(1, 1))

	-- BACKGROUND
	local bg = UIImageElem.new("equip bg", canvasCenter, size(768, 768))
	bg:addAnimations(bgAnimSettings)
	equipScene:addElement(bg, BG_LAYER_1, vec(1, 2))

	-- ASSINATURA PLAYER
	local signature =
		UIImageElem.new("equip signature " .. player.name, vec(canvasCenter.x, canvasCenter.y + 90), size(168, 168))
	signature:addAnimations(signatureSettings)
	equipScene:addElement(signature, BG_LAYER_1, vec(1, 3))

	---------------
	-- ARMAS
	---------------

	-- SLOTS DE ARMAS
	local weaponCenter = vec(canvasCenter.x - 240, canvasCenter.y)
	local padding = 60
	local artifactCenter = vec(canvasCenter.x, canvasCenter.y - 65)
	local blessingCenter = vec(canvasCenter.x + 240, canvasCenter.y)

	-- retorna a posição visual e a posição nas camadas da UI de acordo com o tipo de equipamento
	function equipScene:getEquipmentSlotPosition(equipmentType, idx)
		if equipmentType == WEAPON then
			local col = (idx - 1) % 2
			local row = math.floor((idx - 1) / 2)

			return vec(weaponCenter.x + (-1 + col * 2) * padding, weaponCenter.y + (row - 1) * padding * 2),
				vec(col, row + 1)
		elseif equipmentType == ARTIFACT then
			local col = idx - 1

			return vec(artifactCenter.x + (-1 + col * 2) * 65, artifactCenter.y), vec(col + 2, 1)
		elseif equipmentType == BLESSING then
			local row = idx - 1
			local col = row % 2 == 0 and 1 or -1

			return vec(blessingCenter.x + col * 40, blessingCenter.y + (row - 2) * 60), vec((col + 1) / 2 + 4, idx)
		end
	end

	for idx = 1, 6 do
		local pos, layerPos = equipScene:getEquipmentSlotPosition(WEAPON, idx)
		local slot = UIImageElem.new("equip slot weapon", pos, size(96, 96))
		slot:addAnimations(slotSettings)
		equipScene:addElement(slot, ELEM_LAYER_1, layerPos)
	end

	---------------
	-- ARTEFATOS
	---------------

	-- DECORAÇÃO DE ARTEFATO
	local decorationArtifact =
		UIImageElem.new("equip decoration artifact", vec(canvasCenter.x, canvasCenter.y - 75), size(15 * 3, 39 * 3))
	decorationArtifact:addAnimations(decorationSettings)
	equipScene:addElement(decorationArtifact, BG_LAYER_1, vec(1, 4))

	-- SLOTS DE ARTEFATOS
	for idx = 1, 2 do
		local pos, layerPos = equipScene:getEquipmentSlotPosition(ARTIFACT, idx)
		local slot = UIImageElem.new("equip slot artifact", pos, size(96, 96))
		slot:addAnimations(slotSettings)
		equipScene:addElement(slot, ELEM_LAYER_1, layerPos)
	end

	---------------
	-- BENÇÃOS
	---------------

	-- SLOTS DE BENÇÃOS
	for idx = 1, 5 do
		local pos, layerPos = equipScene:getEquipmentSlotPosition(BLESSING, idx)
		local slot = UIImageElem.new("equip slot blessing", pos, size(96, 96))
		slot:addAnimations(slotSettings)
		equipScene:addElement(slot, ELEM_LAYER_1, layerPos)
	end

	---------------
	-- LIFE BAR
	---------------

	local calcFunc = function()
		return player.hp, player.maxHp
	end
	local offset = { l = 11, r = 3 }

	local lifebar = UILifeBarElem.new(
		"equip player lifebar",
		vec(canvasCenter.x, canvasCenter.y - 170),
		size(74, 14),
		calcFunc,
		offset,
		3
	)
	equipScene:addElement(lifebar, ELEM_LAYER_1, vec(1, 5))

	-- cria os UIElements de fato (armas e artefatos são interagíveis)
	function equipScene:newEquipmentElement(equipmentType, equipment, pos)
		local element
		if equipmentType == BLESSING then
			element = UIImageElem.new("equip " .. equipment.name, pos, size(96, 96))
		else
			element = UIButtonElem.new("equip " .. equipment.name, pos, size(96, 96), nil, function()
				if equipmentType == WEAPON then
					player:equipWeapon(equipment.name)
				elseif equipmentType == ARTIFACT then
					player:equipArtifact(equipment.name)
				end
				equipScene:setEquipmentInUse(equipmentType, equipment)
			end)
		end
		element.equipment = equipment

		local path = equipmentType == BLESSING and pngPathFormat({ "assets", "sprites", "blessings", equipment.name })
			or pngPathFormat({ "assets", "sprites", "icons", equipmentType .. "s", equipment.name })
		addAnimation(element, path, IDLE, slotSettings[IDLE])
		addAnimation(element, path, SELECTED, slotSettings[SELECTED])

		return element
	end

	-- coloca em uso o elemento equipado e retira todos os outros
	function equipScene:setEquipmentInUse(equipmentType, equippedEquipment)
		local equipmentList = equipmentType == WEAPON and player.weapons or player.artifacts

		for idx, equipment in ipairs(equipmentList) do
			local _, layerPos = self:getEquipmentSlotPosition(equipmentType, idx)
			local element = self.layers[ELEM_LAYER_2][layerPos.y] and self.layers[ELEM_LAYER_2][layerPos.y][layerPos.x]
			local slot = self.layers[ELEM_LAYER_1][layerPos.y] and self.layers[ELEM_LAYER_1][layerPos.y][layerPos.x]

			-- equipa o elemento em si
			if element then
				element:setInUse(equipment == equippedEquipment)
			end

			-- equipa o slot
			if slot then
				slot:setInUse(equipment == equippedEquipment)
			end
		end
	end

	-- sincroniza os equipamentos do player com o que é visto na UI
	function equipScene:syncEquipment(equipmentType, equipmentList)
		-- varre os equipamentos atuais e vê se já foram criados na UI
		for idx, equipment in ipairs(equipmentList) do
			local pos, layerPos = self:getEquipmentSlotPosition(equipmentType, idx)
			local current = self.layers[ELEM_LAYER_2][layerPos.y] and self.layers[ELEM_LAYER_2][layerPos.y][layerPos.x]

			if not current or current.equipment ~= equipment then
				if current then
					self:removeElement(ELEM_LAYER_2, layerPos)
				end
				self:addElement(self:newEquipmentElement(equipmentType, equipment, pos), ELEM_LAYER_2, layerPos)
			end
		end

		-- remove reminscências de equipamentos antigos
		local idx = #equipmentList + 1
		while true do
			local _, layerPos = self:getEquipmentSlotPosition(equipmentType, idx)
			local current = self.layers[ELEM_LAYER_2][layerPos.y] and self.layers[ELEM_LAYER_2][layerPos.y][layerPos.x]

			-- se não achou mais, removeu todos os antigos já
			if not current then
				break
			end

			self:removeElement(ELEM_LAYER_2, layerPos)
			idx = idx + 1
		end
	end

	equipScene.onActive = function(self)
		self:syncEquipment(WEAPON, self.player.weapons)
		self:syncEquipment(ARTIFACT, self.player.artifacts)
		self:syncEquipment(BLESSING, self.player.blessingManager.equipped)
		self:setEquipmentInUse(WEAPON, self.player.weapon)
		self:setEquipmentInUse(ARTIFACT, self.player.artifact)
	end

	return equipScene
end

function newCraftingScene(player)
	local invScene = UIScene.new(UI_CRAFTING_SCENE, player)
	local canvasCenter = vec(640, 360)

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

	local arrowUp = UIButtonElem.new("crafting arrow up", vec(secondColX, arrowUpY), arrowSize, nil, function() end)
	local arrowDown = UIButtonElem.new("crafting arrow down", vec(secondColX, lastRowY), arrowSize, nil, function() end)
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
		itemEl.ctx = { player = player }
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
			local previewImg =
				newCraftingItemPreviewElement(recipe.output.name, previewPos, size(128, 128), spritePath, 45)
			self:addElement(previewImg, VISUAL_LAYER_2, vec(1, 1))

			-- textos
			local namePos = vec(previewPos.x - 200, previewPos.y + 72)
			local nameText = UITextElem.new(
				"product name text",
				namePos,
				size(200, 400),
				2,
				nil,
				rgba(0, 0, 0, 255),
				recipe.output.name
			)
			self:addElement(nameText, VISUAL_LAYER_2, vec(1, 2))
			local descPos = vec(previewPos.x - 150, previewPos.y + 112)
			local descText = UITextElem.new(
				"product desc text",
				descPos,
				size(240, 400),
				1.26,
				nil,
				rgba(0, 0, 0, 255),
				recipe.output.description
			)
			self:addElement(descText, VISUAL_LAYER_2, vec(1, 3))

			-- adiciona os ingredientes abaixo
			for i, input in pairs(recipe.inputs) do
				self:addRecipeIngredientSlot(i)
				local resName = input[1].name
				local qty = input[2]

				local slotX = previewPos.x - 38 + (i - 1) * 80
				local spritePath = pngPathFormat({ "assets", "sprites", "resources", resName })
				local ingredientEl =
					newCraftingItemPreviewElement(resName, vec(slotX, ingredientsY), size(96, 96), spritePath, 32)
				self:addElement(ingredientEl, VISUAL_LAYER_2, vec(i, 4))
			end
		end
	end

	invScene:onSelectionChange()

	return invScene
end

function newMapScene(player)
	local mapScene = UIScene.new(UI_MAP_SCENE, player)

	local canvasCenter = vec(640, 360)

	local bgAnimSettings = {}
	bgAnimSettings[IDLE] = newAnimSetting(1, size(256, 140), 1, true, 1)

	-- local ref = UIImageElem.new("map ref", canvasCenter, size(768, 768))
	-- ref:addAnimations(bgAnimSettings)
	-- mapScene:addElement(ref, BG_LAYER_1, vec(1, 1))

	-- BACKGROUND
	local bg = UIImageElem.new("map bg", canvasCenter, size(768, 768))
	bg:addAnimations(bgAnimSettings)
	mapScene:addElement(bg, BG_LAYER_1, vec(1, 2))

	-- MAP
	local map = UIMapElem.new("map", canvasCenter, size(768, 768), player)
	mapScene:addElement(map, ELEM_LAYER_1, vec(1, 1))

	mapScene.onActive = function(self)
		self.layers[ELEM_LAYER_1][1][1]:updateMap(player)
	end

	mapScene.handleInput = function(self, key)
		local dir = vec(0, 0)
		if self.controls:justPressed(ACT_MU) then
			dir.y = dir.y - 1
		elseif self.controls:justPressed(ACT_MD) then
			dir.y = dir.y + 1
		elseif self.controls:justPressed(ACT_ML) then
			dir.x = dir.x - 1
		elseif self.controls:justPressed(ACT_MR) then
			dir.x = dir.x + 1
		end

		if not nullVec(dir) then
			local finalPos = addVec(self.layers[ELEM_LAYER_1][1][1].targetFocus, dir)
			if getRoomAt(finalPos) == nil then
				return
			end
			
			self.layers[ELEM_LAYER_1][1][1]:setFocus(finalPos)
		end
	end

	mapScene.setFocus = function(self, arrPos)
		self.layers[ELEM_LAYER_1][1][1]:setFocus(arrPos)
	end

	return mapScene
end

function newChestScene()
	local chestScene = UIScene.new(UI_CHEST_SCENE)
	local canvasCenter = vec(640, 360)

	-- ANIMAÇÕES
	local slotAnimSettings = {}
	slotAnimSettings[IDLE] = newAnimSetting(1, size(32, 32), 1, true, 1)
	slotAnimSettings[SELECTED] = newAnimSetting(1, size(32, 32), 1, true, 1)

	local arrowAnimSettings = {}
	arrowAnimSettings[IDLE] = newAnimSetting(1, size(16, 16), 1, true, 1)
	arrowAnimSettings[SELECTED] = newAnimSetting(1, size(16, 16), 1, true, 1)

	local bgAnimSettings = {}
	bgAnimSettings[IDLE] = newAnimSetting(1, size(256, 128), 1, true, 1)

	-- BACKGROUND
	local pos = subVec(canvasCenter, vec(128, 128))
	local chestBg = UIImageElem.new("chest bg", canvasCenter, size(1024, 512))
	chestBg:addAnimations(bgAnimSettings)
	chestScene:addElement(chestBg, BG_LAYER_1, vec(1, 1))

	-- PLAYER ITEM SLOTS
	local leftMargin = canvasCenter.x - 382
	local topMargin = canvasCenter.y - 124
	for row = 0, 2 do
		for col = 0, 2 do
			local posX = leftMargin + col * 132
			local posY = topMargin + row * 132
			local slot = UIImageElem.new("chest player slot", vec(posX, posY), size(120, 120))
			slot:addAnimations(slotAnimSettings)
			chestScene:addElement(slot, ELEM_LAYER_1, vec(col + 1, row + 1))
		end
	end

	-- CHEST SLOTS
	leftMargin = canvasCenter.x + 108
	topMargin = canvasCenter.y - 124
	for row = 0, 2 do
		for col = 0, 2 do
			local posX = leftMargin + col * 132
			local posY = topMargin + row * 132
			local slot = UIImageElem.new("chest slot", vec(posX, posY), size(120, 120))
			slot:addAnimations(slotAnimSettings)
			chestScene:addElement(slot, ELEM_LAYER_1, vec(3 + col + 1, row + 1))
		end
	end

	-- MÉTODOS AUXILIARES
	function chestScene:addPlayerResourceEl(resource, inventory, idx, player, chest)
		local col = math.fmod(idx - 1, 3)
		local row = math.floor((idx - 1) / 3)
		if row > 2 then
			return -- ultrapassou o limite do inventário
		end
		local topLeft = addVec(vec(640, 360), vec(-382, -124))
		local resourceEl = newResourceItemElement(resource.name, idx, topLeft, 132, 3)
		resourceEl.ctx = { resource = resource, player = player, chest = chest }
		-- ao clicar, transfere o recurso do player ao baú e recarrega a UI (com openChest)
		resourceEl.onClick = function(self)
			self.ctx.player.inventory:transferItem(self.ctx.resource, self.ctx.chest.inventory)
			self.ctx.player:openChest(self.ctx.chest)
		end
		self:addElement(resourceEl, ELEM_LAYER_2, vec(col + 1, row + 1))
	end

	function chestScene:addChestResourceEl(resource, inventory, idx, player, chest)
		local col = 3 + math.fmod(idx - 1, 3)
		local row = math.floor((idx - 1) / 3)
		if row > 2 then
			return -- ultrapassou o limite do inventário
		end
		local topLeft = addVec(vec(640, 360), vec(108, -124))
		local resourceEl = newResourceItemElement(resource.name, idx, topLeft, 132, 3)
		resourceEl.ctx = { resource = resource, player = player, chest = chest }
		-- ao clicar, transfere o recurso do baú ao player e recarrega a UI (com openChest)
		resourceEl.onClick = function(self)
			self.ctx.chest.inventory:transferItem(self.ctx.resource, self.ctx.player.inventory)
			self.ctx.player:openChest(self.ctx.chest)
		end
		self:addElement(resourceEl, ELEM_LAYER_2, vec(col + 1, row + 1))
	end

	return chestScene
end

----------------------------------------
-- Cenas da Sala
----------------------------------------

function newBossLifeBarScene(room)
	local lifeBarScene = UIScene.new(UI_BOSS_LIFE_BAR_SCENE, nil, false)
	-- ELEMENTOS
	local lifeCalc = function()
		local enemies = room.enemies
		local hp, maxHp = 0, 0

		for _, enemy in pairs(enemies) do
			if enemy.isBoss then
				hp = hp + enemy.hp
				maxHp = maxHp + enemy.maxHp
			end
		end
		return hp, maxHp
	end

	local lifeBarEl = UILifeBarElem.new("boss lifebar", vec(640, 50), size(640, 64), lifeCalc)

	-- SETUP DA CENA
	lifeBarScene:addElement(lifeBarEl, ELEM_LAYER_1, vec(1, 1))

	return lifeBarScene
end
