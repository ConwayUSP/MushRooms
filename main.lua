----------------------------------------
-- Importações de Módulos
----------------------------------------
require("modules.constructors.dialogues")
require("modules.constructors.uimanagers")
require("modules.constructors.vfxs")
require("modules.engine.animation")
require("modules.engine.camera")
require("modules.engine.mouse")
require("modules.engine.collisionmanager")
require("modules.engine.renderization")
require("modules.engine.assetmanager")
require("modules.engine.audiomanager")
require("modules.entities.destructible")
require("modules.entities.enemy")
require("modules.entities.drop")
require("modules.entities.player")
require("modules.entities.room")
require("modules.entities.weapon")
require("modules.tooling.roomcontrol")
require("modules.tooling.spawnBlessing")
require("modules.tooling.spawnDrop")
require("modules.tooling.turtledebug")
require("modules.tooling.fpsvisor")
require("modules.systems.dialogue")
require("modules.systems.shaders")
require("game")
require("table")

-- local appleCake = require("libs.applecake")(false)
-- appleCake.setBuffer(false)
-- appleCake.beginSession()

-- local lurker = require("libs.lurker.lurker")

----------------------------------------
-- Variáveis Globais
----------------------------------------

debugMode = false
inventoryOpen = false
window = { scale = 1, initialW = 1280, initialH = 720 }
gameCtx = MENU_CTX
local updateProfile
local drawProfile

lightLevels = 7

----------------------------------------
-- Callbacks
----------------------------------------

function love.keypressed(key, scancode, isrepeat)
	globalUIManager:handleInput(key)
	for _, p in pairs(players) do
		p.uiManager:handleInput(key)
	end

	if gameCtx ~= GAMEPLAY_CTX then
		return
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
	-- x tira vida do player 1 (teste)
	if key == "x" then
		players[1]:takeDamage(10)
	end

	if _roomCondition() then
		_roomDebugHandler(key)
	elseif _spawnDropCondition() then
		_spawnDropDebugHandler(key)
	elseif _spawnBlessingCondition() then
		_spawnBlessingDebugHandler(key)
	else
		_turtleDebugHandler(key)
		if key == "0" then
			debugMode = not debugMode
		end
	end

	if key == "." then
		lightLevels = lightLevels + 1
	elseif key == "," then
		lightLevels = lightLevels - 1
	end

	-------- FIM DEBUG --------
end

function love.joystickadded(joystick)
	if gameCtx == GAMEPLAY_CTX and joystick:isGamepad() then
		newPlayer(joystick)
	end
end

function love.joystickremoved(joystick)
	for _, p in pairs(players) do
		if p.controls.gamepad == joystick then
			p:die()
			p:dropAllWeapons()
			p:dropAllArtifacts()
			p:dropAllBlessings()
			table.remove(players, tableIndexOf(players, p))
			newCameras()
		end
	end
end

function love.keyreleased(key, scancode)
	if key == "z" then
		cameras[1].targetZoom = cameras[1].startingZoom
	end
end

function love.textinput(t)
	globalUIManager:handleTextInput(t)
	for _, p in pairs(players) do
		p.uiManager:handleTextInput(t)
	end
end

---@return Player|nil
-- primeiro jogador de teclado/mouse (dono do mouse)
local function getKeyboardPlayer()
	for _, p in pairs(players) do
		if p.controls and not p.controls.gamepad then
			return p
		end
	end
	return nil
end

function love.mousepressed(x, y, button, istouch, presses)
	if button ~= 1 then
		return
	end

	-- fora da gameplay o clique vale para a UI global (menu, settings...)
	if gameCtx ~= GAMEPLAY_CTX then
		globalUIManager:handleMouseClick(x, y)
		return
	end

	-- durante a gameplay o mouse pertence ao jogador de teclado/mouse
	local player = getKeyboardPlayer()
	if not player or player.state == DYING then
		return
	end

	-- UI aberta: o clique ativa o elemento sob o cursor
	if player.uiManager:hasActiveScene() then
		player.uiManager:handleMouseClick(x, y)
		return
	end

	-- em diálogo: o clique avança a fala
	if player.inDialogue then
		local dialogue = DialogueManager:getDialogueByPlayer(player)
		if dialogue then
			dialogue:advance()
		end
	end
end

function love.wheelmoved(dx, dy)
	if gameCtx ~= GAMEPLAY_CTX or dy == 0 then
		return
	end

	-- troca de arma com a roda do mouse (só para jogadores de teclado/mouse)
	for _, p in pairs(players) do
		local c = p.controls
		if not c.gamepad then
			p:wheelmoved(dy)
		end
	end
end

function love.focus(f)
	if f then
		-- reaplica escondimento e confinamento do ponteiro
		mouseManager:onFocus()
	else
		-- solta a captura para não prender o ponteiro de outros aplicativos
		mouseManager:onBlur()
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

	-- carregando o gerenciador de áudios
	globalAudioManager = AudioManager.init()
	globalAudioManager:play(MUSIC_MENU)

	-- carregando a biblioteca de UI
	globalUIManager = initGlobalUIManager()

	-- carregando o gerenciador de partículas
	globalVFXManager = initGlobalVFXManager()

	-- carregando o gerenciador de mouse
	mouseManager = MouseManager.init()

	-- definindo a seed de aleatoriedade
	math.randomseed(os.time())

	-- definindo a fonte padrão do jogo
	mushFont = love.graphics.newFont("assets/fonts/Tiny5-Regular.ttf", 16)
	mushBigFont = love.graphics.newFont("assets/fonts/Tiny5-Regular.ttf", 32)
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
	-- lurker.update()
	-- iniciando o profiling da função de update
	-- updateProfile = appleCake.profileFunc(nil, updateProfile)

	dt = math.min(dt, 1/30)

	-- atualiza o modo do mouse (menu = livre, gameplay = confinado ao
	-- viewport) e a posição do cursor de cada jogador de teclado/mouse
	mouseManager:update(dt)

	-- pulando o update de gameplay enquanto está no menu
	if gameCtx == MENU_CTX then
		goto skipgameplay
	end

	DialogueManager:update(dt)
	------------ Salas ------------
	for _, r in activeRooms:iter() do
		r:update(dt)
	end
	----------- Colisões ----------
	collisionManager:update(dt)
	----------- Cameras -----------
	-- antes dos players para que a mira (que depende da transformação
	-- da câmera) seja calculada com o estado da câmera do frame atual
	for _, c in pairs(cameras) do
		c:updatePosition(dt)
	end
	---------- Jogadores ----------
	for _, p in pairs(players) do
		p:update(dt)
	end
	---------- Partículas ---------
	globalVFXManager:update(dt)

	::skipgameplay::
	-------------- UI -------------
	globalUIManager:update(dt)
	updateFPSVisor(dt)

	------------ Áudio ------------
	globalAudioManager:update(dt)

	collectgarbage("step", 20) -- tentativa de amenizar os lagspikes causados pelo GC
	--print(math.floor(collectgarbage("count")) .. " KB")

	-- encerrando o profiling
	-- updateProfile:stop()
end

----------------------------------------
-- Renderização
----------------------------------------

function love.draw()
	-- iniciando o profiling da função de update
	-- drawProfile = appleCake.profileFunc(nil, drawProfile)

	for _, c in pairs(cameras) do
		c:draw()
	end

	globalUIManager:draw()

	if debugMode then
		drawFPSVisor()
	end

	-- encerrando o profiling
	-- drawProfile:stop()
	-- appleCake.flush()
end

----------------------------------------
-- Encerramento
----------------------------------------

function love.quit()
	-- appleCake.endSession()
end
