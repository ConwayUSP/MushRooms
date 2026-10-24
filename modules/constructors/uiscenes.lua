----------------------------------------
-- Importações de Módulos
----------------------------------------
require("modules.UI.uiscene")
require("modules.UI.uiworldscene")
require("modules.UI.elements.button")
require("modules.UI.elements.image")
require("modules.UI.elements.lifebar")
require("modules.UI.elements.link")
require("modules.UI.elements.map")
require("modules.UI.elements.text")
require("modules.UI.elements.textbox")
require("modules.UI.elements.switch")
require("modules.constructors.uielements")

----------------------------------------
-- Cenas Globais
----------------------------------------

---@param sceneType Type
---@param logoPath string
---@param nextScene Type
---@return UIScene
local function newIntroScene(sceneType, logoPath, nextScene, introDur, fadeInDur, fadeOutDur)
	local scene = UIScene.new(sceneType)
	scene.logo = assetManager:getImage(logoPath)
	scene.elapsed = 0

	function scene:onActive()
		self.elapsed = 0
		self.manager.controls:consumeAnyInput()
	end

	function scene:advance()
		self.manager:deactivateScene(self.subtype)
		self.manager:activateScene(nextScene)
	end

	function scene:update(dt)
		self.elapsed = self.elapsed + dt
		if self.manager.controls:consumeAnyInput() or self.elapsed >= introDur then
			self:advance()
		end
	end

	function scene:draw()
		local alpha = 1
		if self.elapsed < fadeInDur then
			alpha = self.elapsed / fadeInDur
		elseif self.elapsed > introDur - fadeOutDur then
			alpha = (introDur - self.elapsed) / fadeOutDur
		end

		local maxSize = 512
		local scale = math.min(maxSize / self.logo:getWidth(), maxSize / self.logo:getHeight())
		love.graphics.clear(0, 0, 0, 1)
		love.graphics.setColor(1, 1, 1, math.max(0, alpha))
		love.graphics.draw(self.logo, 640, 360, 0, scale, scale, self.logo:getWidth() / 2, self.logo:getHeight() / 2)
		love.graphics.setColor(1, 1, 1, 1)
	end

	return scene
end

function initAmanitaIntroScene()
	return newIntroScene(
		UI_INTRO_AMANITA_SCENE,
		"assets/sprites/logos/logo_amanita.png",
		UI_INTRO_CONWAY_SCENE,
		4,
		1.5,
		0.5
	)
end

function initConwayIntroScene()
	return newIntroScene(UI_INTRO_CONWAY_SCENE, "assets/sprites/logos/logo_conway.png", UI_MENU_SCENE, 5, 0.5, 1.5)
end

-- TODO: adicionar cena de créditos
function initCreditsScene()
	return newIntroScene(UI_CREDITS_SCENE, "assets/sprites/logos/logo_conway.png", UI_MENU_SCENE, 5, 1.5, 1.5)
end

--- tela preta com o tempo final da run no modo speedrun.
--- confirma (ou qualquer input, como nas telas de intro) avança para os créditos
function initSpeedrunTimeScene()
	local scene = UIScene.new(UI_SPEEDRUN_TIME_SCENE)

	function scene:onActive()
		self.timeText = formatSpeedrunTime(speedrunTime)
		self.manager.controls:consumeAnyInput()
	end

	function scene:advance()
		self.manager:deactivateScene(UI_SPEEDRUN_TIME_SCENE)
		self.manager:activateScene(UI_CREDITS_SCENE, UI_SPEEDRUN_TIME_SCENE)
		globalAudioManager:play(AUDIO_SELECT, self, "pop")
	end

	function scene:update(dt)
		if self.manager.controls:checkAction(ACT_CON) or self.manager.controls:consumeAnyInput() then
			self:advance()
		end
	end

	function scene:draw()
		love.graphics.clear(0, 0, 0, 1)
		love.graphics.setColor(1, 1, 1, 1)
		love.graphics.setFont(mushBigFont)
		love.graphics.printf("Thanks for speedrunning our Demo", 0, 300, 1280, "center")
		love.graphics.setColor(0.55, 0.8, 0.8, 1)
		love.graphics.setFont(mushBigFont)
		love.graphics.printf("Your time: " .. (self.timeText or "0:00.000"), 0, 400, 1280, "center")
		love.graphics.setColor(1, 1, 1, 1)
	end

	return scene
end

function initMenuScene()
	local menuScene = UIScene.new(UI_MENU_SCENE)
	-- ELEMENTOS
	local menuBg = UIImageElem.new("menu bg", vec(640, 360), size(1280, 720))
	local startBtn = UIButtonElem.new("menu play btn", vec(300, 400), size(120, 120), nil, function()
		startFromMenu()
	end)
	local settingsBtn = UIButtonElem.new("menu opt btn", vec(640, 400), size(120, 120), nil, function()
		globalUIManager:activateScene(UI_SETTINGS_SCENE)
	end)
	local quitBtn = UIButtonElem.new("menu quit btn", vec(980, 400), size(120, 120), nil, function()
		quitGame()
	end)
	local seedTextbox =
		UITextBox.new("menu seed textbox", vec(640, 600), size(320, 72), nil, Color.new(1, 1, 1, 1), 10, setWorldSeed)
	local speedrunLabel = UITextElem.new(
		"speedrun label",
		vec(524, 645),
		size(240, 48),
		2,
		nil,
		rgba8(255, 254, 179, 255),
		"speedrun",
		true
	)
	local speedrunSwitch = UISwitchElem.new("switch", vec(704, 664), size(64, 32), nil, speedrunMode, function(isOn)
		speedrunMode = isOn
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
	menuScene:addElement(speedrunLabel, BG_LAYER_2, vec(2, 3))
	menuScene:addElement(speedrunSwitch, ELEM_LAYER_1, vec(2, 3))

	return menuScene
end

function initSettingsScene()
	local settingsScene = UIScene.new(UI_SETTINGS_SCENE)
	-- ELEMENTOS
	local settingsBg = UIImageElem.new("settings bg", vec(640, 360), size(1280, 720))
	local controlsBtn = UIButtonElem.new("settings controls btn", vec(656, 260), size(832, 96), nil, function()
		globalUIManager:activateScene(UI_CONTROLS_SCENE)
	end)
	local displayBtn = UIButtonElem.new("settings display btn", vec(656, 380), size(832, 96), nil, function()
		globalUIManager:activateScene(UI_GRAPHICS_SCENE)
	end)
	local creditsBtn = UIButtonElem.new("settings credits btn", vec(656, 500), size(832, 96), nil, function()
		print("CRÉDITOS")
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

	-- SETUP DA CENA
	settingsScene:addElement(settingsBg, BG_LAYER_1, vec(1, 1))
	settingsScene:addElement(controlsBtn, ELEM_LAYER_1, vec(1, 1))
	settingsScene:addElement(displayBtn, ELEM_LAYER_1, vec(1, 2))
	settingsScene:addElement(creditsBtn, ELEM_LAYER_1, vec(1, 3))

	return settingsScene
end

function initControlsScene()
	local controlsScene = UIScene.new(UI_CONTROLS_SCENE)
	-- ELEMENTOS
	local controlsBg = UIImageElem.new("controls settings bg", vec(640, 360), size(1280, 720))
	local controlsLabels = UITextElem.new(
		"controls labels",
		vec(312, 106),
		size(140, 700),
		2.2,
		nil,
		rgba8(255, 254, 179, 255),
		"Walk\nAim\nAttack\nDefend\nUse Item\nChange Weapon\nChange Item\nOpen Inventory\nOpen Map\nInteract\nConfirm\nExit\nQuick Actions\nPause",
		true
	)
	local kbMouseBinds = UITextElem.new(
		"kb-mouse binds",
		vec(680, 106),
		size(120, 700),
		2.2,
		nil,
		rgba8(255, 254, 179, 255),
		"WASD\nmouse\nL-mouse\nR-mouse\nQ\nwheel\nR\nE\nTab\nspace\nspace\nesc\nshift\nesc"
	)
	local joystickBinds = UITextElem.new(
		"joystick binds",
		vec(860, 106),
		size(120, 700),
		2.2,
		nil,
		rgba8(255, 254, 179, 255),
		"L-stick\nR-stick\nR2\nL2\nR1\n\n\n\nL1\n\n\n\n\nopt"
	)

	-- ANIMAÇÕES
	local bgAnimSettings = {}
	bgAnimSettings[IDLE] = newAnimSetting(1, size(320, 180), 1000, true, 1)
	controlsBg:addAnimations(bgAnimSettings)

	-- SETUP DA CENA
	controlsScene:addElement(controlsBg, BG_LAYER_1, vec(1, 1))
	controlsScene:addElement(controlsLabels, BG_LAYER_2, vec(1, 1))
	controlsScene:addElement(kbMouseBinds, BG_LAYER_2, vec(2, 1))
	controlsScene:addElement(joystickBinds, BG_LAYER_2, vec(3, 1))

	return controlsScene
end

function initGraphicsSettingsScene()
	local graphicsScene = UIScene.new(UI_GRAPHICS_SCENE)
	-- ELEMENTOS
	local graphicsBg = UIImageElem.new("graphics settings bg", vec(640, 360), size(1280, 720))
	local fullscreenLabel = UITextElem.new(
		"fullscreen label",
		vec(430, 216),
		size(260, 48),
		3,
		nil,
		rgba8(255, 254, 179, 255),
		"Fullscreen",
		true
	)
	local fullscreenSwitch = UISwitchElem.new(
		"switch",
		vec(770, 240),
		size(96, 48),
		nil,
		love.window.getFullscreen(),
		function(isOn)
			love.window.setFullscreen(isOn)
		end
	)
	local vsyncLabel =
		UITextElem.new("vsync label", vec(430, 336), size(260, 48), 3, nil, rgba8(255, 254, 179, 255), "VSync", true)
	local vsyncSwitch = UISwitchElem.new(
		"switch",
		vec(770, 360),
		size(96, 48),
		nil,
		love.window.getVSync() ~= 0,
		function(isOn)
			love.window.setVSync(isOn and 1 or 0)
		end
	)
	local fpsLabel = UITextElem.new(
		"fps label",
		vec(430, 456),
		size(260, 48),
		3,
		nil,
		rgba8(255, 254, 179, 255),
		"FPS Counter",
		true
	)
	local fpsSwitch = UISwitchElem.new("switch", vec(770, 480), size(96, 48), nil, showFPSCounter, function(isOn)
		showFPSCounter = isOn
	end)

	-- ANIMAÇÕES
	local bgAnimSettings = {}
	bgAnimSettings[IDLE] = newAnimSetting(1, size(320, 180), 1000, true, 1)
	graphicsBg:addAnimations(bgAnimSettings)

	-- SETUP DA CENA
	graphicsScene:addElement(graphicsBg, BG_LAYER_1, vec(1, 1))
	graphicsScene:addElement(fullscreenLabel, BG_LAYER_2, vec(1, 1))
	graphicsScene:addElement(fullscreenSwitch, ELEM_LAYER_1, vec(1, 1))
	graphicsScene:addElement(vsyncLabel, BG_LAYER_2, vec(2, 1))
	graphicsScene:addElement(vsyncSwitch, ELEM_LAYER_1, vec(1, 2))
	graphicsScene:addElement(fpsLabel, BG_LAYER_2, vec(3, 1))
	graphicsScene:addElement(fpsSwitch, ELEM_LAYER_1, vec(1, 3))

	-- reflete os valores atuais toda vez que a cena é aberta
	graphicsScene.onActive = function()
		fullscreenSwitch:setOn(love.window.getFullscreen())
		vsyncSwitch:setOn(love.window.getVSync() ~= 0)
		fpsSwitch:setOn(showFPSCounter)
	end

	return graphicsScene
end

----------------------------------------
-- Cenas de Pausa (por player)
----------------------------------------

function newPauseScene(player)
	-- sem hasBg: o escurecimento da tela toda é feito por renderPauseDim na câmera
	local pauseScene = UIScene.new(UI_PAUSE_SCENE, player)
	local canvasCenter = vec(640, 360)

	-- TÍTULO
	local title = UITextElem.new(
		"pause title",
		vec(canvasCenter.x - 600, canvasCenter.y - 280),
		size(400, 48),
		3,
		nil,
		rgba8(255, 254, 179, 255),
		"PAUSED"
	)

	-- SEED
	local seed = UITextElem.new(
		"seed text",
		vec(20, 630),
		size(120, 48),
		2,
		nil,
		rgba8(205, 215, 255, 145),
		"Seed: " .. worldSeedText
	)

	-- BOTÕES
	local resumeBtn = UIButtonElem.new(
		"menu play btn",
		vec(canvasCenter.x, canvasCenter.y - 90),
		size(120, 120),
		nil,
		function()
			player.uiManager:deactivateScene(UI_PAUSE_SCENE)
		end
	)
	local retryBtn = UIButtonElem.new(
		"pause retry btn",
		vec(canvasCenter.x, canvasCenter.y + 30),
		size(120, 120),
		nil,
		function()
			retryGame()
		end
	)
	local homeBtn = UIButtonElem.new(
		"pause home btn",
		vec(canvasCenter.x, canvasCenter.y + 150),
		size(120, 120),
		nil,
		function()
			returnToMenu()
		end
	)
	-- local settingsBtn = UIButtonElem.new(
	-- 	"menu opt btn",
	-- 	vec(canvasCenter.x, canvasCenter.y + 220),
	-- 	size(120, 120),
	-- 	nil,
	-- 	function()
	-- 		player.uiManager:activateScene(UI_PAUSE_SETTINGS_SCENE, UI_PAUSE_SCENE)
	-- 	end
	-- )

	-- LINKS (canto inferior direito)
	local feedbackLink = UILinkElem.new("pause feedback link", vec(1100, 620), size(220, 48), function()
		love.system.openURL("https://tally.so/r/Dq2YEq")
	end, rgba8(215, 215, 245, 225), "give feedback", 2)
	local bugLink = UILinkElem.new("pause bug link", vec(1100, 680), size(220, 48), function()
		love.system.openURL("https://tally.so/r/rDypQM")
	end, rgba8(255, 220, 220, 225), "report bug", 2)

	-- ANIMAÇÕES
	local btnAnimSettings = {}
	btnAnimSettings[IDLE] = newAnimSetting(1, size(32, 32), 1, true, 1)
	btnAnimSettings[SELECTED] = newAnimSetting(4, size(32, 32), 0.08, true, 4)
	resumeBtn:addAnimations(btnAnimSettings)
	--settingsBtn:addAnimations(btnAnimSettings)
	retryBtn:addAnimations(btnAnimSettings)
	homeBtn:addAnimations(btnAnimSettings)

	-- SETUP DA CENA
	pauseScene:addElement(title, BG_LAYER_1, vec(1, 1))
	pauseScene:addElement(seed, VISUAL_LAYER_1, vec(1, 1))
	pauseScene:addElement(resumeBtn, ELEM_LAYER_1, vec(1, 1))
	pauseScene:addElement(retryBtn, ELEM_LAYER_1, vec(1, 2))
	pauseScene:addElement(homeBtn, ELEM_LAYER_1, vec(1, 3))
	--pauseScene:addElement(settingsBtn, ELEM_LAYER_1, vec(1, 4))
	pauseScene:addElement(feedbackLink, ELEM_LAYER_2, vec(1, 4))
	pauseScene:addElement(bugLink, ELEM_LAYER_2, vec(1, 5))

	return pauseScene
end

function newPauseSettingsScene(player)
	local settingsScene = UIScene.new(UI_PAUSE_SETTINGS_SCENE, player, true)

	-- ELEMENTOS (réplica das opções globais, como cena de player)
	local controlsBtn = UIButtonElem.new("settings controls btn", vec(656, 260), size(832, 96), nil, function()
		globalUIManager:activateScene(UI_CONTROLS_SCENE)
	end)
	local displayBtn = UIButtonElem.new("settings display btn", vec(656, 380), size(832, 96), nil, function()
		globalUIManager:activateScene(UI_GRAPHICS_SCENE)
	end)
	local creditsBtn = UIButtonElem.new("settings credits btn", vec(656, 500), size(832, 96), nil, function()
		print("CRÉDITOS")
	end)

	-- ANIMAÇÕES
	local btnAnimSettings = {}
	btnAnimSettings[IDLE] = newAnimSetting(5, size(208, 24), 0.04, true, 5)
	btnAnimSettings[SELECTED] = newAnimSetting(5, size(208, 24), 0.04, true, 5)
	controlsBtn:addAnimations(btnAnimSettings)
	displayBtn:addAnimations(btnAnimSettings)
	creditsBtn:addAnimations(btnAnimSettings)

	-- SETUP DA CENA
	settingsScene:addElement(controlsBtn, ELEM_LAYER_1, vec(1, 1))
	settingsScene:addElement(displayBtn, ELEM_LAYER_1, vec(1, 2))
	settingsScene:addElement(creditsBtn, ELEM_LAYER_1, vec(1, 3))

	return settingsScene
end

----------------------------------------
-- Cenas de Player
----------------------------------------

function newResourceInventoryScene(player)
	local invScene = UIScene.new(UI_INVENTORY_SCENE, player):addNavTabs()
	local canvasCenter = vec(640, 360)
	local slotsCenter = addVec(canvasCenter, vec(-200, 0))
	local infoCenterX = canvasCenter.x + 300

	local COLS = 4
	local ROWS = 3
	local ITEMS_PER_PAGE = COLS * ROWS
	local slotSize = size(114, 114)
	local slotSpacing = 132
	local firstSlotPos =
		vec(slotsCenter.x - ((COLS - 1) * slotSpacing) / 2, slotsCenter.y - ((ROWS - 1) * slotSpacing) / 2)

	invScene.currentPage = 1
	invScene.lastInventoryRevision = -1

	-- ANIMAÇÕES
	local slotAnimSettings = {}
	slotAnimSettings[IDLE] = newAnimSetting(1, size(38, 38), 1, true, 1)
	slotAnimSettings[SELECTED] = newAnimSetting(1, size(38, 38), 1, true, 1)

	local bgAnimSettings = {}
	bgAnimSettings[IDLE] = newAnimSetting(1, size(360, 200), 1, true, 1)

	local arrowAnimSettings = {}
	arrowAnimSettings[IDLE] = newAnimSetting(1, size(10, 8), 1, true, 1)
	arrowAnimSettings[SELECTED] = newAnimSetting(1, size(10, 8), 1, true, 1)

	local infoHeadAnimSettings = {}
	infoHeadAnimSettings[IDLE] = newAnimSetting(1, size(100, 16), 1, true, 1)

	local infoFootAnimSettings = {}
	infoFootAnimSettings[IDLE] = newAnimSetting(1, size(100, 5), 1, true, 1)

	-- BACKGROUND
	local invBg = UIImageElem.new("inventory bg", canvasCenter, size(1080, 600))
	invBg:addAnimations(bgAnimSettings)
	invScene:addElement(invBg, BG_LAYER_1, vec(1, 1))

	-- DECORAÇÕES DO PAINEL DE INFORMAÇÕES
	local infoHead = UIImageElem.new("inventory info head", vec(infoCenterX, canvasCenter.y - 222), size(300, 48))
	infoHead:addAnimations(infoHeadAnimSettings)
	invScene:addElement(infoHead, BG_LAYER_2, vec(1, 1))

	local infoFoot = UIImageElem.new("inventory info foot", vec(infoCenterX, canvasCenter.y + 222), size(300, 15))
	infoFoot:addAnimations(infoFootAnimSettings)
	invScene:addElement(infoFoot, BG_LAYER_2, vec(1, 2))

	-- retorna a posição visual e a posição nas camadas da UI de um slot
	function invScene:getInventorySlotPosition(idx)
		local col = (idx - 1) % COLS
		local row = math.floor((idx - 1) / COLS)

		return vec(firstSlotPos.x + col * slotSpacing, firstSlotPos.y + row * slotSpacing), vec(col + 1, row + 2)
	end

	-- SLOTS
	for idx = 1, ITEMS_PER_PAGE do
		local pos, layerPos = invScene:getInventorySlotPosition(idx)
		local slot = UIImageElem.new("inventory slot item", pos, slotSize)
		slot:addAnimations(slotAnimSettings)
		invScene:addElement(slot, ELEM_LAYER_1, layerPos)
	end

	-- troca a página e atualiza os itens visíveis
	function invScene:setInventoryPage(page)
		local resources = self.player.inventory.items[RESOURCE]
		local pageCount = math.max(1, math.ceil(#resources / ITEMS_PER_PAGE))
		local targetPage = ((page - 1) % pageCount) + 1

		if targetPage == self.currentPage then
			return
		end

		self.currentPage = targetPage
		self:syncInventory()
	end

	-- SETAS DE NAVEGAÇÃO
	local leftArrow = UIButtonElem.new(
		"inventory nav arrow left",
		vec(slotsCenter.x - 291, slotsCenter.y),
		size(30, 24),
		nil,
		function()
			print("left arrow pressed")
			invScene:setInventoryPage(invScene.currentPage - 1)
		end
	)
	leftArrow:addAnimations(arrowAnimSettings)
	invScene:addElement(leftArrow, ELEM_LAYER_1, vec(0, 3))

	local rightArrow = UIButtonElem.new(
		"inventory nav arrow right",
		vec(slotsCenter.x + 291, slotsCenter.y),
		size(30, 24),
		nil,
		function()
			print("right arrow pressed")
			invScene:setInventoryPage(invScene.currentPage + 1)
		end
	)
	rightArrow:addAnimations(arrowAnimSettings)
	invScene:addElement(rightArrow, ELEM_LAYER_1, vec(COLS + 1, 3))

	-- sincroniza o inventário do player com os itens exibidos na página atual
	function invScene:syncInventory()
		local inventory = self.player.inventory
		local resources = inventory.items[RESOURCE]
		local pageCount = math.max(1, math.ceil(#resources / ITEMS_PER_PAGE))
		self.currentPage = math.min(self.currentPage, pageCount)
		self.layers[ELEM_LAYER_2] = {}

		local firstResourceIdx = (self.currentPage - 1) * ITEMS_PER_PAGE + 1
		local lastResourceIdx = math.min(firstResourceIdx + ITEMS_PER_PAGE - 1, #resources)

		for resourceIdx = firstResourceIdx, lastResourceIdx do
			local slotIdx = resourceIdx - firstResourceIdx + 1
			local pos, layerPos = self:getInventorySlotPosition(slotIdx)
			local resource = resources[resourceIdx]
			local resourceEl = newResourceItemElement(resource, pos)
			self:addElement(resourceEl, ELEM_LAYER_2, layerPos, true)
		end

		self.lastInventoryRevision = inventory.revision
	end

	invScene.onActive = function(self)
		self:syncInventory()
	end

	invScene.update = function(self, dt)
		if self.lastInventoryRevision ~= self.player.inventory.revision then
			self:syncInventory()
		end
		UIScene.update(self, dt)
	end

	return invScene
end

function newEquipmentScene(player)
	local equipScene = UIScene.new(UI_EQUIPMENT_SCENE, player):addNavTabs()
	local canvasCenter = vec(640, 360)

	local bgAnimSettings = {}
	bgAnimSettings[IDLE] = newAnimSetting(1, size(360, 200), 1, true, 1)

	local signatureSettings = {}
	signatureSettings[IDLE] = newAnimSetting(1, size(56, 56), 1, true, 1)

	local slotSettings = {}
	slotSettings[IDLE] = newAnimSetting(1, size(32, 32), 1, true, 1)
	slotSettings[SELECTED] = newAnimSetting(1, size(32, 32), 1, true, 1)

	local blessingsSettings = {}
	blessingsSettings[IDLE] = newAnimSetting(1, size(16, 16), 1, true, 1)
	blessingsSettings[SELECTED] = newAnimSetting(1, size(16, 16), 1, true, 1)

	local decorationSettings = {}
	decorationSettings[IDLE] = newAnimSetting(1, size(15, 39), 1, true, 1)

	-- BACKGROUND
	local bg = UIImageElem.new("equip bg", canvasCenter, size(1080, 600))
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
	local weaponCenter = vec(canvasCenter.x - 320, canvasCenter.y)
	local padding = 60
	local artifactCenter = vec(canvasCenter.x, canvasCenter.y - 105)
	local blessingCenter = vec(canvasCenter.x + 320, canvasCenter.y)

	-- retorna a posição visual e a posição nas camadas da UI de acordo com o tipo de equipamento
	function equipScene:getEquipmentSlotPosition(equipmentType, idx)
		if equipmentType == WEAPON then
			local col = (idx - 1) % 2
			local row = math.floor((idx - 1) / 2)

			return vec(weaponCenter.x + (-1 + col * 2) * padding, weaponCenter.y + (row - 1) * padding * 2),
				vec(col, row + 2)
		elseif equipmentType == ARTIFACT then
			local col = idx - 1

			return vec(artifactCenter.x + (-1 + col * 2) * 65, artifactCenter.y), vec(col + 2, 2)
		elseif equipmentType == BLESSING then
			local row = idx - 1
			local col = row % 2 == 0 and 1 or -1

			return vec(blessingCenter.x + col * 40, blessingCenter.y + (row - 2) * 60), vec(4, idx + 1)
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
		vec(canvasCenter.x, canvasCenter.y - 220),
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
			element = UIImageElem.new("equip " .. equipment.name, pos, size(64, 64))
		else
			element = UIButtonElem.new("equip " .. equipment.name, pos, size(96, 96), nil, function()
				if equipmentType == WEAPON then
					-- equipa a instância clicada (com duplicatas o nome seria ambíguo)
					player.weapon = equipment
				elseif equipmentType == ARTIFACT then
					player.artifact = equipment
				end
				equipScene:setEquipmentInUse(equipmentType, equipment)
			end)
		end
		element.equipment = equipment

		local path

		if equipmentType == BLESSING then
			path = pngPathFormat({ "assets", "sprites", "blessings", equipment.name })
			addAnimation(element, path, IDLE, blessingsSettings[IDLE])
			addAnimation(element, path, SELECTED, blessingsSettings[SELECTED])
		else
			path = pngPathFormat({ "assets", "sprites", "icons", equipmentType .. "s", equipment.name })
			addAnimation(element, path, IDLE, slotSettings[IDLE])
			addAnimation(element, path, SELECTED, slotSettings[SELECTED])
		end

		return element
	end

	-- coloca em uso o elemento equipado e retira todos os outros
	function equipScene:setEquipmentInUse(equipmentType, equippedEquipment)
		-- varre todos os slots do tipo (e não só os ocupados) pra limpar o
		-- destaque de slots que ficaram vazios após um drop
		local maxIdx = equipmentType == WEAPON and 6 or 2

		for idx = 1, maxIdx do
			local _, layerPos = self:getEquipmentSlotPosition(equipmentType, idx)
			local element = self.layers[ELEM_LAYER_2][layerPos.y] and self.layers[ELEM_LAYER_2][layerPos.y][layerPos.x]
			local slot = self.layers[ELEM_LAYER_1][layerPos.y] and self.layers[ELEM_LAYER_1][layerPos.y][layerPos.x]
			local inUse = element ~= nil and element.equipment == equippedEquipment

			-- equipa o elemento em si
			if element then
				element:setInUse(inUse)
			end

			-- equipa o slot
			if slot then
				slot:setInUse(inUse)
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
	local invScene = UIScene.new(UI_CRAFTING_SCENE, player):addNavTabs()
	local canvasCenter = vec(640, 360)

	local COLS = 3
	local ROWS = 4

	local sizeSlot = size(106, 106)
	local slotOffset = vec(sizeSlot.width + 12, sizeSlot.height + 12)
	local marginOffset = vec(300, 100)
	local leftMargin = canvasCenter.x - marginOffset.x - 118
	local topMargin = canvasCenter.y - marginOffset.y - 72

	-- ANIMAÇÕES
	local animSettings = {}
	animSettings[IDLE] = newAnimSetting(1, size(35, 35), 1, true, 1)
	animSettings[SELECTED] = newAnimSetting(1, size(35, 35), 1, true, 1)

	local outputAnimSettings = {}
	outputAnimSettings[IDLE] = newAnimSetting(1, size(37, 37), 1, true, 1)

	local bgAnimSettings = {}
	bgAnimSettings[IDLE] = newAnimSetting(1, size(360, 200), 1, true, 1)

	-- BACKGROUND
	local invBg = UIImageElem.new("crafting bg", canvasCenter, size(1080, 600))
	invBg:addAnimations(bgAnimSettings)
	invScene:addElement(invBg, BG_LAYER_1, vec(1, 1))

	-- SLOTS
	for row = 0, ROWS - 1 do
		for col = 0, COLS - 1 do
			local posX = leftMargin + col * slotOffset.x
			local posY = topMargin + row * slotOffset.y
			local slot = UIImageElem.new("crafting slot", vec(posX, posY), sizeSlot)
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
	local selectedSlotPos = vec(canvasCenter.x + 312, canvasCenter.y - 213)
	function invScene:addSelectedItemPreviewSlot()
		local selectedSlotSize = size(112, 112)
		local selectedSlot = UIImageElem.new("crafting output slot", selectedSlotPos, selectedSlotSize)
		selectedSlot:addAnimations(outputAnimSettings)
		invScene:addElement(selectedSlot, VISUAL_LAYER_1, vec(4, 3))
	end

	-- SLOTS RESOURCES REQUIRED FOR CRAFTING
	local sizeMiniSlot = size(106, 106)
	local miniSlotOffset = sizeMiniSlot.width + 8
	function invScene:addRecipeIngredientSlot(col)
		local posX = selectedSlotPos.x - miniSlotOffset * 1.5 + col * miniSlotOffset
		local posY = canvasCenter.y + 200
		local slot = UIImageElem.new("crafting slot", vec(posX, posY), sizeMiniSlot)
		slot:addAnimations(animSettings)
		invScene:addElement(slot, VISUAL_LAYER_1, vec(4 + col, 4))
	end

	-- ATUALIZAÇÃO AUTOMÁTICA DOS DETALHES AO MUDAR A SELEÇÃO
	local previewPos = vec(canvasCenter.x + 312, canvasCenter.y - 213)
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
			local namePos = vec(previewPos.x - 160, previewPos.y + 92)
			local nameText = UITextElem.new(
				"product name text",
				namePos,
				size(160, 400),
				2,
				nil,
				rgba(255, 255, 255, 255),
				recipe.output.name
			)
			self:addElement(nameText, VISUAL_LAYER_2, vec(1, 2))
			local descPos = vec(previewPos.x - 210, previewPos.y + 132)
			local descText = UITextElem.new(
				"product desc text",
				descPos,
				size(266, 400),
				1.5,
				nil,
				rgba(255, 255, 255, 255),
				recipe.output.description
			)
			self:addElement(descText, VISUAL_LAYER_2, vec(1, 3))

			-- adiciona os ingredientes abaixo
			for i, input in pairs(recipe.inputs) do
				self:addRecipeIngredientSlot(i)
				local resName = input[1].name
				local qty = input[2]

				local slotX = previewPos.x - 55 + (i - 1) * 111
				local spritePath = pngPathFormat({ "assets", "sprites", "resources", resName })
				local ingredientEl =
					newCraftingItemPreviewElement(resName, vec(slotX, ingredientsY), size(96, 96), spritePath, 32)

				-- "tenho/preciso" no canto do slot, igual aos slots do inventário
				local owned = self.player.inventory:countItem(input[1])
				local sufficient = owned >= qty
				ingredientEl.count = owned .. "/" .. qty
				ingredientEl.draw = function(el, camera)
					UIElement.draw(el, camera)

					local viewX, viewY = el.pos.x, el.pos.y
					if camera then
						viewX, viewY = camera:viewPos(el.pos)
					end

					local padding = 10
					local textX = viewX - sizeMiniSlot.width / 2 + 6
					local textY = viewY + sizeMiniSlot.height / 2 - mushFont:getHeight() - padding
					local textWidth = sizeMiniSlot.width - padding * 2
					local previousFont = love.graphics.getFont()
					local r, g, b, a = love.graphics.getColor()

					love.graphics.setFont(mushMidFont)
					-- cor da letra de quantidades do recurso
					if sufficient then
						love.graphics.setColor(105 / 255, 163 / 255, 179 / 255, 1)
					else
						love.graphics.setColor(255 / 255, 163 / 255, 179 / 255, 1)
					end
					love.graphics.printf(el.count, textX, textY, textWidth, "right")

					love.graphics.setFont(previousFont)
					love.graphics.setColor(r, g, b, a)
				end

				self:addElement(ingredientEl, VISUAL_LAYER_2, vec(i, 4))
			end
		end

		-- confere se a construção está disponível
		local unavailiable
		for _, row in pairs(self.layers[ELEM_LAYER_2]) do
			for _, el in pairs(row) do
				if el.recipe then
					el.unavailable = not el.recipe:canCraftWith(self.player.inventory)
				end
			end
		end
	end

	-- refaz os detalhes ao abrir a cena: os recursos do jogador podem ter
	-- mudado desde a última vez que ela foi vista
	function invScene:onActive()
		self:onSelectionChange()
	end

	invScene:onSelectionChange()

	return invScene
end

function newMapScene(player)
	local mapScene = UIScene.new(UI_MAP_SCENE, player)

	local canvasCenter = vec(640, 360)

	local bgAnimSettings = {}
	bgAnimSettings[IDLE] = newAnimSetting(1, size(360, 200), 1, true, 1)

	-- BACKGROUND
	local bg = UIImageElem.new("map bg", canvasCenter, size(1080, 600))
	bg:addAnimations(bgAnimSettings)
	mapScene:addElement(bg, BG_LAYER_1, vec(1, 2))

	-- MAP
	local map = UIMapElem.new("map", canvasCenter, size(1080, 600), player)
	mapScene:addElement(map, ELEM_LAYER_1, vec(1, 1))

	mapScene.onActive = function(self)
		self.layers[ELEM_LAYER_1][1][1]:updateMap(player)
	end

	mapScene.handleInput = function(self, key, controls)
		local dir = vec(0, 0)
		if controls:justPressed(ACT_MU) then
			dir.y = dir.y - 1
		elseif controls:justPressed(ACT_MD) then
			dir.y = dir.y + 1
		elseif controls:justPressed(ACT_ML) then
			dir.x = dir.x - 1
		elseif controls:justPressed(ACT_MR) then
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

function newChestScene(player)
	local chestScene = UIScene.new(UI_CHEST_SCENE, player)
	local canvasCenter = vec(640, 360)
	local COLS = 3
	local ROWS = 3
	local ITEMS_PER_SIDE = COLS * ROWS
	local slotSpacing = 132
	local slotSize = size(114, 114)
	local playerSlotsStart = addVec(canvasCenter, vec(-382, -124))
	local chestSlotsStart = addVec(canvasCenter, vec(108, -124))

	chestScene.chest = nil
	chestScene.lastPlayerInventoryRevision = -1
	chestScene.lastChestInventoryRevision = -1

	-- ANIMAÇÕES
	local slotAnimSettings = {}
	slotAnimSettings[IDLE] = newAnimSetting(1, size(38, 38), 1, true, 1)
	slotAnimSettings[SELECTED] = newAnimSetting(1, size(38, 38), 1, true, 1)

	local bgAnimSettings = {}
	bgAnimSettings[IDLE] = newAnimSetting(1, size(360, 200), 1, true, 1)

	-- BACKGROUND
	local chestBg = UIImageElem.new("chest bg", canvasCenter, size(1080, 600))
	chestBg:addAnimations(bgAnimSettings)
	chestScene:addElement(chestBg, BG_LAYER_1, vec(1, 1))

	-- PLAYER ITEM SLOTS
	for row = 0, ROWS - 1 do
		for col = 0, COLS - 1 do
			local posX = playerSlotsStart.x + col * slotSpacing
			local posY = playerSlotsStart.y + row * slotSpacing
			local slot = UIImageElem.new("chest player slot", vec(posX, posY), slotSize)
			slot:addAnimations(slotAnimSettings)
			chestScene:addElement(slot, ELEM_LAYER_1, vec(col + 1, row + 1))
		end
	end

	-- CHEST SLOTS
	for row = 0, ROWS - 1 do
		for col = 0, COLS - 1 do
			local posX = chestSlotsStart.x + col * slotSpacing
			local posY = chestSlotsStart.y + row * slotSpacing
			local slot = UIImageElem.new("chest slot", vec(posX, posY), slotSize)
			slot:addAnimations(slotAnimSettings)
			chestScene:addElement(slot, ELEM_LAYER_1, vec(COLS + col + 1, row + 1))
		end
	end

	-- retorna a posição visual e a posição nas camadas de um dos lados do baú
	function chestScene:getChestSlotPosition(idx, isPlayerSide)
		local col = (idx - 1) % COLS
		local row = math.floor((idx - 1) / COLS)
		local startPos = isPlayerSide and playerSlotsStart or chestSlotsStart
		local layerCol = isPlayerSide and col + 1 or COLS + col + 1

		return vec(startPos.x + col * slotSpacing, startPos.y + row * slotSpacing), vec(layerCol, row + 1)
	end

	-- adiciona até nove recursos de um inventário em um dos lados da cena
	function chestScene:syncInventorySide(inventory, isPlayerSide)
		local resources = inventory.items[RESOURCE]
		for idx = 1, math.min(#resources, ITEMS_PER_SIDE) do
			local resource = resources[idx]
			local pos, layerPos = self:getChestSlotPosition(idx, isPlayerSide)
			local sourceInventory = inventory
			local destinationInventory = isPlayerSide and self.chest.inventory or self.player.inventory
			local resourceEl = newResourceItemElement(resource, pos, function()
				sourceInventory:transferItem(resource, destinationInventory)
			end, slotSize)
			self:addElement(resourceEl, ELEM_LAYER_2, layerPos, true)
		end
	end

	function chestScene:syncInventories()
		if not self.chest then
			return
		end

		self.layers[ELEM_LAYER_2] = {}
		self:syncInventorySide(self.player.inventory, true)
		self:syncInventorySide(self.chest.inventory, false)
		self.lastPlayerInventoryRevision = self.player.inventory.revision
		self.lastChestInventoryRevision = self.chest.inventory.revision
	end

	function chestScene:setChest(chest)
		self.chest = chest
	end

	chestScene.onActive = function(self)
		self:syncInventories()
	end

	chestScene.onInactive = function(self)
		if self.chest and self.player.activeInteraction == self.chest then
			self.chest:onCloseInteract(self.player)
			self.player.activeInteraction = nil
		end
	end

	-- se um dos dois inventários atualizaram, sincroniza a cena novamente
	chestScene.update = function(self, dt)
		if
			self.chest
			and (
				self.lastPlayerInventoryRevision ~= self.player.inventory.revision
				or self.lastChestInventoryRevision ~= self.chest.inventory.revision
			)
		then
			self:syncInventories()
		end
		UIScene.update(self, dt)
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
	-- TODO: acrescentar elemento com NOME do(s) boss(s) logo acima da LifeBar

	-- SETUP DA CENA
	lifeBarScene:addElement(lifeBarEl, ELEM_LAYER_1, vec(1, 1))

	return lifeBarScene
end

---@param player Player
---@return UIScene
-- cena de tela não interativa que organiza as notificações de equipamentos recebidos
function newItemCollectedScene(player)
	local scene = UIScene.new(UI_ITEM_COLLECTED_SCENE, player)
	local MAX_NOTIFICATIONS = 3
	local DISPLAY_DURATION = 3
	local BOTTOM_MARGIN = 36
	local STACK_SPACING = 108
	scene.notifications = {}

	---@param item Weapon|Artifact|Blessing
	function scene:push(item)
		local notification = UIItemCollectedElem.new(item, BOTTOM_MARGIN)
		table.insert(self.notifications, { element = notification, timer = DISPLAY_DURATION })
		if #self.notifications > MAX_NOTIFICATIONS then
			table.remove(self.notifications)
		end
		self:layoutNotifications()
	end

	function scene:layoutNotifications()
		for index, notification in ipairs(self.notifications) do
			notification.element.pos.y = 720
				- BOTTOM_MARGIN
				- notification.element.size.height / 2
				- (index - 1) * STACK_SPACING
		end
	end

	function scene:update(dt)
		for index = #self.notifications, 1, -1 do
			local notification = self.notifications[index]
			notification.timer = notification.timer - dt
			notification.element:update(dt)
			if notification.timer <= 0 then
				table.remove(self.notifications, index)
			end
		end
		self:layoutNotifications()
	end

	function scene:draw()
		for index = #self.notifications, 1, -1 do
			self.notifications[index].element:draw()
		end
	end

	return scene
end

----------------------------------------
-- Cenas de Mundo
----------------------------------------

---@param player Player
---@return UIWorldScene
-- cena de mundo que mostra a barra de vida do jogador acima da cabeça
function newPlayerDamageBarScene(player)
	local DAMAGE_BAR_DURATION = 2

	local scene = UIWorldScene.new(UI_PLAYER_HP_SCENE, player, vec(0, -90), nil)

	local lifeCalc = function()
		return player.hp, player.maxHp
	end

	local lifebar = UILifeBarElem.new("equip player lifebar", vec(0, 0), size(74, 14), lifeCalc, { l = 11, r = 3 }, 2)
	scene:addElement(lifebar, vec(0, 0))

	-- detecta dano ou cura comparando o hp atual com o do frame anterior
	local lastHp = player.hp
	local hideTimer = 0
	scene.onUpdate = function(self, dt)
		if player.hp ~= lastHp then
			self:show()
			hideTimer = DAMAGE_BAR_DURATION
		end
		lastHp = player.hp

		if hideTimer > 0 then
			hideTimer = hideTimer - dt
			if hideTimer <= 0 then
				self:hide()
			end
		end
	end

	scene:hide()
	return scene
end

-- rótulos legíveis para teclas comuns (o resto vira maiúsculo)
local KEYBIND_LABELS = {
	mouse1 = "LMB",
	mouse2 = "RMB",
	mouse3 = "MMB",
	mousewheel = "Wheel",
	lshift = "Shift",
	rshift = "Shift",
	lctrl = "Ctrl",
	rctrl = "Ctrl",
	escape = "Esc",
}

---@param key string?
---@return string
-- converte uma tecla bruta do LÖVE em um rótulo legível para exibir na UI
local function keybindLabel(key)
	if not key then
		return "?"
	end
	return KEYBIND_LABELS[key] or string.upper(key)
end

---@param player Player
---@return UIWorldScene
-- cena de mundo que mostra o ícone do artefato equipado acima da cabeça
-- por um instante sempre que o jogador troca de artefato equipado
function newPlayerArtifactEquipScene(player)
	local ICON_DURATION = 1.5

	local scene = UIWorldScene.new(UI_ARTIFACT_EQUIP_SCENE, player, vec(0, -80), nil)

	-- um ícone para o equipamento antigo e um para o novo
	local afterIcon = UIImageElem.new("artifact equip icon", vec(0, 0), size(92, 92))
	local beforeIcon = UIImageElem.new("artifact equip icon", vec(0, 0), size(92, 92))
	scene:addElement(afterIcon, vec(0, 0))
	scene:addElement(beforeIcon, vec(0, 0))

	-- detecta a troca de artefato comparando a referência com a do frame anterior
	local lastArtifact = player.artifact
	local hideTimer = 0

	scene.onUpdate = function(self, dt)
		if player.artifact ~= lastArtifact then
			local newArtifact = player.artifact
			if lastArtifact and newArtifact then
				local path = pngPathFormat({ "assets", "sprites", "icons", ARTIFACT .. "s", newArtifact.name })
				addAnimation(afterIcon, path, IDLE, newAnimSetting(1, size(32, 32), 1, true))
				path = pngPathFormat({ "assets", "sprites", "icons", ARTIFACT .. "s", lastArtifact.name })
				addAnimation(beforeIcon, path, IDLE, newAnimSetting(1, size(32, 32), 1, true))
				self:show()
				hideTimer = ICON_DURATION
			else
				self:hide()
			end
			lastArtifact = newArtifact
		end

		if hideTimer > 0 then
			-- trazendo o novo ícone para o centro e crescendo ele
			local timeFactor = Easing.inOutCubic(math.min((ICON_DURATION - hideTimer) / ICON_DURATION * 4, 1))
			scene.elements[1].offset.x = lerp(70, 0, timeFactor)
			local size = lerp(0, 92, timeFactor)
			scene.elements[1].elem.size.width = size
			scene.elements[1].elem.size.height = size

			-- tirando o ícone antigo do centro e diminuindo ele
			scene.elements[2].offset.x = lerp(0, -70, timeFactor)
			local size = lerp(92, 0, timeFactor)
			scene.elements[2].elem.size.width = size
			scene.elements[2].elem.size.height = size

			hideTimer = hideTimer - dt
			if hideTimer <= 0 then
				self:hide()
			end
		end
	end

	scene:hide()
	return scene
end

---@param player Player
---@return UIWorldScene
-- cena de mundo que mostra o texto da tecla de interação acima do objeto
-- interativo mais próximo quando o jogador está no alcance dele
function newPlayerInteractionPromptScene(player)
	local scene = UIWorldScene.new(UI_INTERACTION_PROMPT_SCENE, nil, vec(0, -110), nil)

	local prompt =
		UITextElem.new("interaction prompt", vec(0, 0), size(120, 20), 1.5, nil, rgba8(255, 255, 255, 255), "?")
	scene:addElement(prompt, vec(0, 0))

	scene.onUpdate = function(self, dt)
		local target = player.interactiveObj
		-- não exibe o prompt em objetos sem onInteract (como a fogueira)
		if target and target.type ~= NPC and not target.onInteract then
			self:hide()
			return
		end
		self.followEntity = target
		self.anchorOffset.y = -110 + math.sin(love.timer.getTime() * 2) * 4

		if target and not player.activeInteraction and not player.inDialogue and not player.inCutscene then
			local key = player.controls and player.controls.keybinds and player.controls.keybinds[ACT_INT] or nil
			prompt.text = keybindLabel(key)
			self.anchorOffset.x = - #prompt.text * 18
			self:show()
		else
			self:hide()
		end
	end

	scene:hide()
	return scene
end

---@param player Player
---@return UIWorldScene
-- cena de mundo que mostra uma barra de cooldown abaixo do jogador
-- enquanto o artefato equipado está em cooldown
function newPlayerArtifactCooldownBarScene(player)
	local scene = UIWorldScene.new(UI_ARTIFACT_COOLDOWN_BAR_SCENE, player, vec(0, 76), nil)

	local cooldownCalc = function()
		local cd = player.artifact and player.artifact.cooldown
		if cd and cd.active and cd.duration > 0 then
			return cd.time, cd.duration
		end
		return 0, 1
	end

	local customCalcBarColor = function(self)
		local revPercent = 1 - self.percent
		self.color[1] = 0.7 - revPercent * 0.2        -- R
		self.color[2] = 0.8 + revPercent * 0.2        -- G
		self.color[3] = 0.9 + revPercent * revPercent * 0.1 -- B
	end

	local cooldownBar = UILifeBarElem.new(
		"artifact cooldown bar",
		vec(0, 0),
		size(12, 12),
		cooldownCalc,
		{ l = 0, r = 0 },
		3,
		customCalcBarColor
	)
	scene:addElement(cooldownBar, vec(0, 0))

	local hideTimer = 0
	-- chamado pelo player quando o uso do artefato é bloqueado pelo cooldown
	function scene:activate()
		hideTimer = 1
		if self.visible then
			return
		end
		self:show()
		-- começa cheia (cooldown recém-iniciado), sem o atraso do lerp
		local cd = player.artifact and player.artifact.cooldown
		if cd and cd.duration > 0 then
			local frac = math.min(math.max(cd.time / cd.duration, 0), 1)
			cooldownBar.front.frontTarget = frac
			cooldownBar.front.backTarget = frac
			cooldownBar.front.percent = frac
		end
	end

	-- some com o tempo ou quando o cooldown do artefato termina
	scene.onUpdate = function(self, dt)
		if hideTimer > 0 then
			hideTimer = hideTimer - dt
			if hideTimer <= 0 then
				self:hide()
				return
			end
		end
		local cd = player.artifact and player.artifact.cooldown
		if self.visible and (not cd or not cd.active) then
			self:hide()
		end
	end

	scene:hide()
	return scene
end

---@param player Player
---@return UIWorldScene
-- cena de mundo que mostra uma barra de cooldown da defesa
function newPlayerDefenseCooldownBarScene(player)
	local scene = UIWorldScene.new(UI_DEFENSE_COOLDOWN_BAR_SCENE, player, vec(0, 76), nil)

	local cooldownCalc = function()
		return player.defenseCooldownTimer.time, player.defenseCooldownTimer.duration
	end

	local customCalcBarColor = function(self)
		local revPercent = 1 - self.percent
		self.color[1] = 0.9 + revPercent * revPercent * 0.1 -- R
		self.color[2] = 0.7 - revPercent * 0.2        -- G
		self.color[3] = 0.7 - revPercent * 0.3        -- B
	end

	local cooldownBar = UILifeBarElem.new(
		"defense cooldown bar",
		vec(0, 0),
		size(12, 12),
		cooldownCalc,
		{ l = 0, r = 0 },
		3,
		customCalcBarColor
	)
	scene:addElement(cooldownBar, vec(0, 0))

	local hideTimer = 0
	-- chamado pelo player quando tenta defender no cooldown
	function scene:activate()
		hideTimer = 0.5
		if self.visible then
			return
		end
		self:show()
		local cd = player.defenseCooldownTimer
		if cd and cd.duration > 0 then
			local frac = math.min(math.max(cd.time / cd.duration, 0), 1)
			cooldownBar.front.frontTarget = frac
			cooldownBar.front.backTarget = frac
			cooldownBar.front.percent = frac
		end
	end

	-- some com o tempo ou quando o cooldown da defesa termina
	scene.onUpdate = function(self, dt)
		if hideTimer > 0 then
			hideTimer = hideTimer - dt
			if hideTimer <= 0 then
				self:hide()
				return
			end
		end
		local cd = player.defenseCooldownTimer
		if self.visible and (not cd or not cd.active) then
			self:hide()
		end
	end

	scene:hide()
	return scene
end
