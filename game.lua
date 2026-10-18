----------------------------------------
-- Importações de módulos
----------------------------------------
require("modules.systems.collision")
require("modules.systems.links")
require("modules.entities.player")
require("modules.entities.room")
require("modules.utils.seeds")

----------------------------------------
-- Enums
----------------------------------------
--- contexto atual do jogo
MENU_CTX = "Menu Context"
GAMEPLAY_CTX = "In-game Context"
QUITTING_CTX = "Quitting Context"

respawnRoom = vec(0, 0)
respawnPos = vec(0, 0)

DEFAULT_WORLD_SEED = "MU5HR00M5"
worldSeedText = ""
worldSeed = 0

----------------------------------------
-- Funções globais
----------------------------------------

function startGame()
	if worldSeed == 0 then
		setWorldSeed(DEFAULT_WORLD_SEED)
	end
	collisionManager = CollisionManager.init()
	createInitialRooms()
	respawnPos = vec(rooms[0][0].pos.x, rooms[0][0].pos.y)
	newPlayer()
	for _, joystick in pairs(love.joystick.getJoysticks()) do
		if joystick:isGamepad() then
			newPlayer(joystick)
		end
	end
	-- debug -------------------------------------------------
	players[1]:collectWeapon(newSlingShot())
	players[1]:collectWeapon(newKatana())
	players[1]:collectWeapon(newBoomerangue())
	players[1]:collectWeapon(newSkullShooter())
	players[1]:collectWeapon(newBlackholer())
	players[1]:collectWeapon(newFlowergun())
	players[1]:equipWeapon(SKULL_SHOOTER.name)
	players[1]:collectArtifact(newInvisibilityRing():setOwner(players[1]))
	players[1]:collectArtifact(newRainbowDash():setOwner(players[1]))
	players[1]:equipArtifact(RAINBOW_DASH.name)
	players[1].blessingManager:equip(newFireBlessing())
	----------------------------------------------------------
	gameCtx = GAMEPLAY_CTX
	globalUIManager:deactivateAllScenes()
	globalAudioManager:changeMusic(MUSIC_LAYER1, 0.8)
end

function quitGame()
	gameCtx = QUITTING_CTX
	love.event.quit()
end

--- retorna se o mundo está pausado (algum player com a cena de pausa aberta)
function isWorldPaused()
	for _, p in pairs(players) do
		if p.uiManager and p.uiManager:isSceneActive(UI_PAUSE_SCENE) then
			return true
		end
	end
	return false
end

-- ação de mundo adiada para o fim do frame (evita mutar `players` durante iteração)
local pendingWorldAction = nil

--- limpa todo o estado do mundo atual (salas, players, câmeras, colisões)
local function cleanupWorld()
	-- desregistra players do mouse manager e limpa a lista
	for i = #players, 1, -1 do
		mouseManager:unregister(players[i])
		table.remove(players, i)
	end
	-- reseta estruturas de mundo
	rooms = BiList.new()
	activeRooms = Set.new()
	doors = BiList.new()
	walls = BiList.new()
	cameras = {}
	-- reseta VFX (partículas presas a entidades mortas)
	globalVFXManager.particlesInst = {}
	globalVFXManager.animInstances = {}
end

--- agenda a troca para o menu no fim do frame atual
function returnToMenu()
	pendingWorldAction = "menu"
end

--- agenda o restart do mundo com a mesma seed no fim do frame atual
function retryGame()
	pendingWorldAction = "retry"
end

--- processa a ação de mundo adiada, se houver (chamar após os updates de player)
function processPendingWorldAction()
	if not pendingWorldAction then
		return
	end
	local action = pendingWorldAction
	pendingWorldAction = nil
	if action == "menu" then
		cleanupWorld()
		gameCtx = MENU_CTX
		globalUIManager:deactivateAllScenes()
		globalUIManager:activateScene(UI_MENU_SCENE)
		globalAudioManager:changeMusic(MUSIC_MENU, 0.8)
	elseif action == "retry" then
		cleanupWorld()
		startGame()
	end
end
