----------------------------------------
-- Classe UIManager
----------------------------------------

---@class UIManager
---@field player Player
---@field canvas table
---@field canvasSize Size
---@field scenes table<string, UIScene>
---@field activeScenes UIScene[]
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
	uimanager.baseWidth = 1280
	uimanager.baseHeight = 720
	uimanager.canvas = love.graphics.newCanvas(uimanager.baseWidth, uimanager.baseHeight)
	uimanager.canvasPos = vec(0, 0)
	uimanager.scenes = {}
	uimanager.activeScenes = {}
	return uimanager
end

---@param canvas table
-- define em qual canvas este UI manager deveria renderizar sua UI
function UIManager:setParentCanvas(canvas)
	self.parentCanvas = canvas
	local parentW = canvas:getWidth()
	local parentH = canvas:getHeight()

	-- diferença de proporção entre a resolução desejada e a resolução base da UI
	local scale = math.min(parentW / self.baseWidth, parentH / self.baseHeight)
	self.scaleX = scale
	self.scaleY = scale

	-- centralizando as UIs
	local renderedW = self.baseWidth * scale
	local renderedH = self.baseHeight * scale
	local offsetX = (parentW - renderedW) / 2
	local offsetY = (parentH - renderedH) / 2
	self.canvasPos.x = offsetX
	self.canvasPos.y = offsetY
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
	table.insert(self.activeScenes, sceneType)
	self:onSceneActivated(sceneType)
end

---@param sceneType Type
-- desativa uma cena de um determinado tipo e todas as cenas acima dela no stack (sub-cenas)
function UIManager:deactivateScene(sceneType)
	local type = nil
	repeat
		type = table.remove(self.activeScenes)
		self.scenes[type].active = false
	until type == sceneType
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
		self:activateScene(sceneType)
		self:onSceneActivated(sceneType)
	else
		self:deactivateScene(sceneType)
	end
end

function UIManager:onSceneActivated(sceneType)
	if self.scenes[sceneType].onActive then
		self.scenes[sceneType]:onActive()
	end
end

-- desativa todas as cenas deste UI manager
function UIManager:deactivateAllScenes()
	for _, scene in pairs(self.scenes) do
		scene.active = false
	end
	self.activeScenes = {}
end

---@param dt number
-- atualiza o estado de todas as cenas deste manager
function UIManager:update(dt)
	self:handleInput()
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
	for _, sceneType in ipairs(self.activeScenes) do
		self.scenes[sceneType]:draw()
	end

	-- projetamos o canvas interno para o destino, delegando a transformação para a GPU
	if camera then
		love.graphics.setCanvas(camera.canvas)
		love.graphics.draw(self.canvas, self.canvasPos.x, self.canvasPos.y, 0, self.scaleX, self.scaleY)
	else
		love.graphics.setCanvas()
		love.graphics.push()

		local screenW = love.graphics.getWidth()
		local screenH = love.graphics.getHeight()

		local scale = math.min(screenW / self.baseWidth, screenH / self.baseHeight)
		local offsetX = (screenW - (self.baseWidth * scale)) / 2
		local offsetY = (screenH - (self.baseHeight * scale)) / 2

		love.graphics.draw(self.canvas, offsetX, offsetY, 0, scale, scale)

		love.graphics.pop()
	end
end

---@param key? string
function UIManager:handleInput(key)
	local activeScene = self.activeScenes[#self.activeScenes]
	if activeScene then
		self.scenes[activeScene]:handleInput(key)
	end
end

function UIManager:handleTextInput(t)
	local activeScene = self.activeScenes[#self.activeScenes]
	if activeScene then
		self.scenes[activeScene]:handleTextInput(t)
	end
end
