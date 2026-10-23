----------------------------------------
-- Importações de Módulos
----------------------------------------
require("modules.UI.uimanager")
require("modules.UI.uiscene")
require("modules.UI.uiworldscene")
require("modules.UI.elements.button")
require("modules.UI.elements.image")
require("modules.constructors.uiscenes")

function initGlobalUIManager()
	local globalManager = UIManager.new()
	local menuScene = initMenuScene()
	local amanitaIntroScene = initAmanitaIntroScene()
	local conwayIntroScene = initConwayIntroScene()
	local creditsScene = initCreditsScene()
	local settingsScene = initSettingsScene()
	local controlsScene = initControlsScene()
	local graphicsScene = initGraphicsSettingsScene()
	globalManager:addScene(menuScene)
	globalManager:addScene(amanitaIntroScene)
	globalManager:addScene(conwayIntroScene)
	globalManager:addScene(creditsScene)
	globalManager:addScene(settingsScene)
	globalManager:addScene(controlsScene)
	globalManager:addScene(graphicsScene)
	globalManager:activateScene(UI_INTRO_AMANITA_SCENE)

	return globalManager
end

function newPlayerUIManager(player)
	local playerManager = UIManager.new(player)
	local inventoryScene = newResourceInventoryScene(player)
	local craftingScene = newCraftingScene(player)
	local openChestScene = newChestScene(player)
	local equipScene = newEquipmentScene(player)
	local mapScene = newMapScene(player)
	local pauseScene = newPauseScene(player)
	local pauseSettingsScene = newPauseSettingsScene(player)
	playerManager:addScene(inventoryScene)
	playerManager:addScene(craftingScene)
	playerManager:addScene(openChestScene)
	playerManager:addScene(equipScene)
	playerManager:addScene(mapScene)
	playerManager:addScene(pauseScene)
	playerManager:addScene(pauseSettingsScene)

	-- cenas de mundo
	local damageBarScene = newPlayerDamageBarScene(player)
	local artifactEquipScene = newPlayerArtifactEquipScene(player)
	local interactionPromptScene = newPlayerInteractionPromptScene(player)
	local artifactCdScene = newPlayerArtifactCooldownBarScene(player)
	local defenseCdScene = newPlayerDefenseCooldownBarScene(player)
	playerManager:addWorldScene(damageBarScene)
	playerManager:addWorldScene(artifactEquipScene)
	playerManager:addWorldScene(interactionPromptScene)
	playerManager:addWorldScene(artifactCdScene)
	playerManager:addWorldScene(defenseCdScene)

	return playerManager
end

function newRoomUIManager(room)
	local roomManager = UIManager.new()
	local lifeBar = newBossLifeBarScene(room)
	roomManager:addScene(lifeBar)

	return roomManager
end
