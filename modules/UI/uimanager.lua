----------------------------------------
-- Classe UIManager
----------------------------------------

---@class UIManager
---@field player Player
---@field controls Controls
---@field canvas table
---@field canvasSize Size
---@field scenes table<string, UIScene>
---@field activeScenes Type[]
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
	uimanager.controls = player and player.controls or _newDefaultControl()
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
	if self.scenes[sceneType].active then
		return
	end

	self.scenes[sceneType].active = true
	table.insert(self.activeScenes, sceneType)
	self:onSceneActivated(sceneType)
end

---@param sceneType Type
-- desativa uma cena de um determinado tipo e todas as cenas acima dela no stack (sub-cenas)
function UIManager:deactivateScene(sceneType)
	for idx = #self.activeScenes, 1, -1 do
		if self.activeScenes[idx] == sceneType then
			while #self.activeScenes >= idx do
				self:deactivateActiveScene(false)
			end
			return
		end
	end
end

---@param sceneType string
---@return boolean
-- retorna um `boolean` dizendo se a cena de tipo `sceneType` está ativa
function UIManager:isSceneActive(sceneType)
	return self.scenes[sceneType].active
end

---@return boolean
-- retorna se existe pelo menos uma cena na pilha
function UIManager:hasActiveScene()
	return #self.activeScenes > 0
end

---@param keepOneAlive bool
-- remove a cena ativa do topo da pilha, a não ser que `keepOneAlive` seja verdadeiro e a cena seja a última
function UIManager:deactivateActiveScene(keepOneAlive)
	if #self.activeScenes == 0 or (#self.activeScenes == 1 and keepOneAlive) then
		return
	end

	local activeScene = table.remove(self.activeScenes)
	local scene = self.scenes[activeScene]
	scene.active = false
	if scene.onInactive then
		scene:onInactive()
	end
end

---@param sceneType Type
-- faz com que uma cena ativa se desative e uma cena desativa se ative
function UIManager:toggleScene(sceneType)
	if not self.scenes[sceneType].active then
		self:activateScene(sceneType)
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
	while #self.activeScenes > 0 do
		self:deactivateActiveScene(false)
	end

	-- garante consistência mesmo para uma cena marcada como ativa fora da pilha
	for _, scene in pairs(self.scenes) do
		if scene.active then
			scene.active = false
			if scene.onInactive then
				scene:onInactive()
			end
		end
	end
end

---@param dt number
-- atualiza o estado de todas as cenas deste manager
function UIManager:update(dt)
	-- se tiver um player, podemos confiar que ele já deu o update
	if not self.player then
		self.controls:update(dt)
	end

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
	if self.controls:justPressed(ACT_EXT) then
		if self.player then
			self:deactivateActiveScene(false)
		else
			self:deactivateActiveScene(true)
		end
		return
	end
	local activeScene = self.activeScenes[#self.activeScenes]
	if activeScene then
		self.scenes[activeScene]:handleInput(key, self.controls)
	end
end

function UIManager:handleTextInput(t)
	local activeScene = self.activeScenes[#self.activeScenes]
	if activeScene then
		self.scenes[activeScene]:handleTextInput(t)
	end
end
