----------------------------------------
-- Importações de Módulos
----------------------------------------
require("modules.utils.utils")
require("modules.utils.vec")

----------------------------------------
-- Enums e Variáveis
----------------------------------------

-- modo em que o mouse se encontra
MM_FREE = "mouse free mode" -- cursor do SO livre (menus)
MM_CONFINED = "mouse confined mode" -- cursor preso ao viewport do player (gameplay)

-- margem (em unidades lógicas) entre o cursor e a borda do viewport
local CURSOR_MARGIN = 6

----------------------------------------
-- Classe MouseCursor
----------------------------------------

---@class MouseCursor
---@field owner Player
---@field pos Vec
---@field getViewportRect fun() : table|nil
---@field clampToViewport fun() : boolean
---@field getAimPoint fun(camera: Camera) : Vec|nil
-- um cursor de mouse, atrelado a um jogador de teclado/mouse
MouseCursor = {}
MouseCursor.__index = MouseCursor

---@param owner Player
---@return MouseCursor
function MouseCursor.new(owner)
	local cursor = setmetatable({}, MouseCursor)
	cursor.owner = owner
	cursor.pos = vec(love.mouse.getPosition())
	return cursor
end

---@return table|nil
-- retângulo do viewport do dono deste cursor, em pixels da janela.
-- é recalculado a cada chamada, então redimensionar a janela ou entrar
-- em tela cheia se corrige sozinho
function MouseCursor:getViewportRect()
	local camera = getCameraByPlayer(self.owner)
	if not camera then
		return nil
	end

	local scale = window.scale
	return {
		x = camera.canvasPos.x * scale,
		y = camera.canvasPos.y * scale,
		w = camera.viewport.width * scale,
		h = camera.viewport.height * scale,
	}
end

---@return boolean
-- mantém o cursor dentro do viewport do dono e retorna se ele precisou ser movido
function MouseCursor:clampToViewport()
	local rect = self:getViewportRect()
	if not rect then
		-- sem câmera associada o cursor ainda não pode sair da janela
		rect = { x = 0, y = 0, w = love.graphics.getWidth(), h = love.graphics.getHeight() }
	end

	local margin = CURSOR_MARGIN * window.scale
	local nx = clamp(self.pos.x, rect.x + margin, rect.x + rect.w - margin)
	local ny = clamp(self.pos.y, rect.y + margin, rect.y + rect.h - margin)
	if nx == self.pos.x and ny == self.pos.y then
		return false
	end

	self.pos.x = nx
	self.pos.y = ny
	return true
end

---@param camera Camera
---@return Vec|nil
-- posição do mundo sob este cursor segundo a `camera` dada.
-- retorna `nil` se o cursor está fora do viewport desta câmera
function MouseCursor:getAimPoint(camera)
	if not camera then
		return nil
	end

	-- pixels da janela -> unidades lógicas -> espaço de mundo
	return camera:screenToWorld(self.pos.x / window.scale, self.pos.y / window.scale)
end

----------------------------------------
-- Classe MouseManager
----------------------------------------

---@class MouseManager
---@field mode string
---@field cursors MouseCursor[]
---@field cursorsByOwner table<Player, MouseCursor>
---@field register fun(player: Player)
---@field unregister fun(player: Player)
---@field get fun(player: Player?) : MouseCursor|nil
---@field getPos fun(player: Player?) : number, number
---@field isActive fun() : boolean
MouseManager = {}
MouseManager.__index = MouseManager

---@return MouseManager
function MouseManager.init()
	local manager = setmetatable({}, MouseManager)
	manager.mode = MM_FREE
	manager.cursors = {}
	manager.cursorsByOwner = {}
	manager:applyPointerCapture()
	return manager
end

---@param player Player
-- dá um cursor para um jogador de teclado/mouse
function MouseManager:register(player)
	if not player or self.cursorsByOwner[player] then
		return
	end

	local cursor = MouseCursor.new(player)
	cursor.pos = vec(love.mouse.getPosition())
	cursor:clampToViewport()
	table.insert(self.cursors, cursor)
	self.cursorsByOwner[player] = cursor
end

---@param player Player
function MouseManager:unregister(player)
	local cursor = self.cursorsByOwner[player]
	if not cursor then
		return
	end

	self.cursorsByOwner[player] = nil
	table.remove(self.cursors, tableIndexOf(self.cursors, cursor))
end

---@param player Player?
---@return MouseCursor|nil
function MouseManager:get(player)
	return player and self.cursorsByOwner[player] or nil
end

---@param player Player?
---@return number, number
-- posição atual do mouse em pixels da janela (livre no menu,
-- confinada ao viewport durante a gameplay)
function MouseManager:getPos(player)
	if self.mode == MM_FREE then
		return love.mouse.getPosition()
	end

	local cursor = self:get(player) or self.cursors[1]
	if cursor then
		return cursor.pos.x, cursor.pos.y
	end

	return love.mouse.getPosition()
end

---@param mode string
-- alterna entre o modo livre (menu) e o confinado (gameplay)
function MouseManager:applyMode(mode)
	if self.mode == mode then
		return
	end
	self.mode = mode
	self:applyPointerCapture()
end

---@return boolean
-- retorna se o mouse está no modo de mira
function MouseManager:isActive()
	return self.mode == MM_CONFINED
end

-- esconde/confina o ponteiro do SO segundo o modo atual
function MouseManager:applyPointerCapture()
	local confined = self.mode == MM_CONFINED
	love.mouse.setVisible(not confined)
	love.mouse.setGrabbed(confined)
end

---@param dt number
-- atualiza o modo do mouse e a posição de todos os cursores
function MouseManager:update(dt)
	-- o modo é decidido pelo contexto do jogo
	self:applyMode(gameCtx == GAMEPLAY_CTX and MM_CONFINED or MM_FREE)

	if self.mode == MM_FREE then
		-- no menu o cursor é o do SO, sem confinamento
		local ax, ay = love.mouse.getPosition()
		for _, cursor in ipairs(self.cursors) do
			cursor.pos.x = ax
			cursor.pos.y = ay
		end
		return
	end

	local winW, winH = love.graphics.getWidth(), love.graphics.getHeight()
	for i, cursor in ipairs(self.cursors) do
		cursor.pos.x, cursor.pos.y = love.mouse.getPosition()
		if cursor:clampToViewport() and i == 1 then
			love.mouse.setPosition(
				clamp(cursor.pos.x, 0, math.max(winW - 1, 0)),
				clamp(cursor.pos.y, 0, math.max(winH - 1, 0))
			)
		end
	end
end

-- ao (re)ganhar foco o SO pode ter soltado a captura e reexibido o
-- ponteiro, então reaplicamos a captura do modo atual
function MouseManager:onFocus()
	self:applyPointerCapture()
end

-- enquanto o jogo não tem o foco nada deve prender o ponteiro do usuário
function MouseManager:onBlur()
	love.mouse.setGrabbed(false)
end