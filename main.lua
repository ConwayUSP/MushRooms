----------------------------------------
-- Importações de Módulos
----------------------------------------
require("modules.constructors.dialogues")
require("modules.constructors.uimanagers")
require("modules.engine.animation")
require("modules.engine.camera")
require("modules.engine.collisionmanager")
require("modules.engine.renderization")
require("modules.engine.assetmanager")
require("modules.entities.destructible")
require("modules.entities.enemy")
require("modules.entities.drop")
require("modules.entities.player")
require("modules.entities.room")
require("modules.entities.weapon")
require("modules.systems.dialogue")
require("modules.tooling.roomcontrol")
require("modules.tooling.spawnDrop")
require("modules.tooling.turtledebug")
require("modules.tooling.fpsvisor")
require("modules.systems.shaders")
require("game")
require("table")

local appleCake = require("libs.applecake")(true)
appleCake.setBuffer(true)
appleCake.beginSession()

----------------------------------------
-- Variáveis Globais
----------------------------------------

debugMode = false
inventoryOpen = false
window = { scale = 1, initialW = 1280, initialH = 720 }
gameCtx = MENU_CTX
local updateProfile
local drawProfile

----------------------------------------
-- Callbacks
----------------------------------------

function love.keypressed(key, scancode, isrepeat)
	-- esc fecha o jogo
	if key == "escape" then
		quitGame()
	end

	for _, p in pairs(players) do
		p.uiManager:keypressed(key, isrepeat)
	end

	-- repassa para os UI managers
	globalUIManager:keypressed(key, isrepeat)

	-- n adiciona um player ao jogo
	if key == "n" then
		newPlayer()
	end

	---------- DEBUG ----------

	-- q faz a câmera 1 tremer (teste)
	if key == "c" then
		cameras[1]:shake(20, 1)
	end
	-- z dá zoom na câmera 1 (teste)
	if key == "z" then
		cameras[1].targetZoom = 2
	end

	if _roomCondition() then
		_roomDebugHandler(key)
	elseif _spawnDropCondition() then
		_spawnDropDebugHandler(key)
	else
		_turtleDebugHandler(key)
		if key == "0" then
			debugMode = not debugMode
		end
	end

	-------- FIM DEBUG --------

	if not isrepeat then
		for _, p in pairs(players) do
			p:processKeyInput(key)
		end
	end
end

function love.keyreleased(key, scancode)
	if key == "z" then
		cameras[1].targetZoom = cameras[1].startingZoom
	end
end

function love.resize(w, h)
	local sx = w / window.initialW
	local sy = h / window.initialH
	window.scale = math.max(sx, sy)
	window.width = w / window.scale
	window.height = h / window.scale

	newCameras() -- o tamanho das câmeras precisa mudar
end

----------------------------------------
-- Inicialização
----------------------------------------

function love.load()
	-- muda o filtro padrão para eliminar o efeito de blur
	love.graphics.setDefaultFilter("nearest", "nearest")

	-- carregando o gerenciador de assets
	assetManager = AssetManager.init()

	-- carregando a biblioteca de UI
	globalUIManager = initGlobalUIManager()

	-- definindo a seed de aleatoriedade
	math.randomseed(os.time())

	-- definindo a fonte padrão do jogo
	mushFont = love.graphics.newFont("assets/fonts/Tiny5-Regular.ttf", 16)
	love.graphics.setFont(mushFont)

	-- definindo as dimensões iniciais do jogo
	window.width = 1280
	window.height = 720
	window.cx = window.width / 2 -- centro no eixo x
	window.cy = window.height / 2 -- centro no eixo y

	-- métodos de estado do love
	love.window.setMode(window.width, window.height, { resizable = true, vsync = true, msaa = 0 })
end

----------------------------------------
-- Atualização
----------------------------------------

function love.update(dt)
	-- iniciando o profiling da função de update
	updateProfile = appleCake.profileFunc(nil, updateProfile)

	-- pulando o update de gameplay enquanto está no menu
	if gameCtx == MENU_CTX then
		goto uiupdate
	end

	DialogueManager:update(dt)
	----------- Colisões ----------
	collisionManager:update(dt)
	---------- Jogadores ----------
	for _, p in pairs(players) do
		p:update(dt)
	end
	----------- Cameras -----------
	for _, c in pairs(cameras) do
		c:updatePosition(dt)
	end
	------------ Salas ------------
	for _, r in activeRooms:iter() do
		r:update(dt)
	end

	-------------- UI -------------
	::uiupdate::
	globalUIManager:update(dt)
	updateFPSVisor(dt)

	-- encerrando o profiling
	updateProfile:stop()
end

----------------------------------------
-- Renderização
----------------------------------------

function love.draw()
	-- iniciando o profiling da função de update
	drawProfile = appleCake.profileFunc(nil, drawProfile)

	for _, c in pairs(cameras) do
		c:draw()
	end

	globalUIManager:draw()

	if debugMode then
		drawFPSVisor()
	end

	-- encerrando o profiling
	drawProfile:stop()
	appleCake.flush()
end

----------------------------------------
-- Encerramento
----------------------------------------

function love.quit()
	appleCake.endSession()
end
