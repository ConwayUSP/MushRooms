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
CREDITS_CTX = "Credits Context"
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
	resetSpeedrunTimer()
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
	-- players[1]:collectWeapon(newKatana())
	-- players[1]:collectWeapon(newBoomerangue())
	-- players[1]:equipWeapon(SKULL_SHOOTER.name)
	-- players[1]:collectWeapon(newSlingShot())
	-- players[1]:collectWeapon(newSkullShooter())
	-- players[1]:collectWeapon(newBlackholer())
	-- players[1]:collectWeapon(newFlowergun())
	-- players[1]:collectArtifact(newInvisibilityRing():setOwner(players[1]))
	-- players[1]:collectArtifact(newRainbowDash():setOwner(players[1]))
	-- players[1]:equipArtifact(RAINBOW_DASH.name)
	-- players[1].blessingManager:equip(newFireBlessing())
	----------------------------------------------------------
	gameCtx = GAMEPLAY_CTX
	globalUIManager:deactivateAllScenes()
	globalAudioManager:changeMusic(MUSIC_STD, MUSIC_FADE_DURATION)
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

---@param room Room?
---@return string
-- devolve a música de gameplay que a sala atual deveria estar tocando
function musicForRoom(room)
	if not room then
		return MUSIC_STD
	end

	if room.roomType == BATTLE_ROOM or room.roomType == BOSS_ROOM then
		if room:isInCombat() then
			return MUSIC_BATTLE
		end
	elseif room.roomType == PUZZLE_ROOM then
		if room:isPuzzlePending() then
			return MUSIC_PUZZLE
		end
	end

	return MUSIC_STD
end

--- sincroniza a música de gameplay com a sala do primeiro player.
-- o crossfade é gradual e não reinicia a faixa se ela já é o alvo
function updateGameplayMusic()
	if gameCtx ~= GAMEPLAY_CTX then
		return
	end

	local player = players[1]
	if not player or not player.room then
		return
	end

	globalAudioManager:changeMusic(musicForRoom(player.room), MUSIC_FADE_DURATION)
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
	resetRoomGenerator(1)
	-- reseta VFX (partículas presas a entidades mortas)
	globalVFXManager.particlesInst = {}
	globalVFXManager.animInstances = {}
	-- para loops de som presos a entidades que serão descartadas
	globalAudioManager:stopLoopingSounds()
end

---@param action string
-- inicia uma transição de tela e agenda `action` para o ponto médio (a tela
-- está totalmente coberta). se já há uma transição, o pedido é ignorado
local function requestWorldAction(action)
	if not globalScreenTransition or globalScreenTransition:isActive() then
		return
	end

	globalScreenTransition:start({
		onMidpoint = function()
			pendingWorldAction = action
		end,
	})
end

--- inicia o jogo a partir do menu, com transição de tela
function startFromMenu()
	requestWorldAction("start")
end

--- agenda a troca para o menu no meio da transição de tela
function returnToMenu()
	requestWorldAction("menu")
end

--- agenda o restart do mundo com a mesma seed no meio da transição de tela
function retryGame()
	requestWorldAction("retry")
end

--- agenda a ida aos créditos no meio da transição de tela.
function finishToCredits()
	requestWorldAction("credits")
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
		globalAudioManager:changeMusic(MUSIC_MENU, MUSIC_FADE_DURATION)
	elseif action == "retry" then
		cleanupWorld()
		startGame()
	elseif action == "start" then
		startGame()
	elseif action == "credits" then
		cleanupWorld()
		gameCtx = CREDITS_CTX
		globalUIManager:deactivateAllScenes()
		if speedrunMode then
			globalUIManager:activateScene(UI_SPEEDRUN_TIME_SCENE)
		else
			globalUIManager:activateScene(UI_CREDITS_SCENE)
		end
		globalAudioManager:changeMusic(MUSIC_MENU, MUSIC_FADE_DURATION)
	end
end
