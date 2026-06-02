----------------------------------------
-- Classe UIManager
----------------------------------------

---@class UIManager
---@field player Player
---@field canvas table
---@field canvasSize Size
---@field scenes table<string, UIScene>
---@field activeScene UIScene
---@field parentCanvas table
---@field parentCanvasPos Vec

UIManager = {}
UIManager.__index = UIManager
UIManager.type = UI_MANAGER

---@param player? Player
-- cria um novo gerenciador de UI vazio atrelado opcionalmente a um `player`
function UIManager.new(player)
	local uimanager = setmetatable({}, UIManager)
	uimanager.player = player
	uimanager.canvas = love.graphics.newCanvas(1280, 720)
	uimanager.canvasSize = size(1280, 720)
	uimanager.canvasPos = vec(0, 0)
	uimanager.scenes = {}
	uimanager.activeScene = nil
	return uimanager
end

function UIManager:scaleScenes(scaleX, scaleY)
	for _, scene in pairs(self.scenes) do
		for _, layer in pairs(scene.layers) do
			for _, row in pairs(layer) do
				for _, element in pairs(row) do
					element.pos.x = element.pos.x * scaleX
					element.pos.y = element.pos.y * scaleY
					element.size.width = element.size.width * scaleX
					element.size.height = element.size.height * scaleY
				end
			end
		end
	end
end

---@param canvas table
---@param canvasPos Vec
-- define em qual canvas este UI manager deveria renderizar sua UI
function UIManager:setParentCanvas(canvas, canvasPos)
	local previousSize = self.canvasSize
	self.parentCanvas = canvas
	self.parentCanvasPos = canvasPos
	local parentW = canvas:getWidth()
	local parentH = canvas:getHeight()
	self.canvas = love.graphics.newCanvas(parentW, parentH)
	if previousSize and previousSize.width and previousSize.height then
		local scaleX = parentW / previousSize.width
		local scaleY = parentH / previousSize.height
		if scaleX ~= 1 or scaleY ~= 1 then
			self:scaleScenes(scaleX, scaleY)
		end
	end
	self.canvasSize = size(parentW, parentH)
end

---@param scene UIScene
-- adiciona uma cena à lista de cenas deste manager
function UIManager:addScene(scene)
	self.scenes[scene.subtype] = scene
	return self
end

---@param sceneType Type
-- ativa uma cena de um determinado tipo
function UIManager:activateScene(sceneType)
	self.scenes[sceneType].active = true
	self.activeScene = sceneType
end

---@param sceneType Type
-- desativa uma cena de um determinado tipo
function UIManager:deactivateScene(sceneType)
	self.scenes[sceneType].active = false
	-- !TODO: implementar um stack de cenas ativas para UIs sobrepostas
	self.activeScene = nil
end

---@param sceneType string
---@return boolean
-- retorna um `boolean` dizendo se a cena de tipo `sceneType` está ativa
function UIManager:isSceneActive(sceneType)
	return self.scenes[sceneType].active
end

---@param sceneType Type
-- faz com que uma cena ativa se desative e uma cena desativa se ative
function UIManager:toggleScene(sceneType)
	local newState = not self.scenes[sceneType].active
	self.scenes[sceneType].active = newState

	if newState then
		self.activeScene = sceneType
	else
		if self.activeScene == sceneType then
			self.activeScene = nil
		end
	end
end

-- desativa todas as cenas deste UI manager
function UIManager:deactivateAllScenes()
	for _, scene in pairs(self.scenes) do
		scene.active = false
	end
	self.activeScene = nil
end

---@param dt number
-- atualiza o estado de todas as cenas deste manager
function UIManager:update(dt)
	for _, scene in pairs(self.scenes) do
		if scene.active then
			scene:update(dt)
		end
	end
end

---@param camera Camera
-- redefine o canvas ativo e os offsets necessários e então
-- renderiza todas as UIScenes deste manager
function UIManager:draw(camera)
	love.graphics.setCanvas(self.canvas)
	love.graphics.clear(0.0, 0.0, 0.0, 0.0)
	for _, scene in pairs(self.scenes) do
		if scene.active then
			scene:draw()
		end
	end
	if camera then
		love.graphics.setCanvas(camera.canvas)
		love.graphics.draw(self.canvas, self.canvasPos.x, self.canvasPos.y)
	else
		love.graphics.setCanvas()
		love.graphics.push()
		love.graphics.scale(window.scale)

		love.graphics.draw(self.canvas, self.canvasPos.x, self.canvasPos.y)

		love.graphics.pop()
	end
end

function UIManager:keypressed(key, isrepeat)
	if self.activeScene then
		self.scenes[self.activeScene]:keypressed(key, isrepeat)
	end
end
