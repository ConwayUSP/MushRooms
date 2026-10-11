----------------------------------------
-- Classe UIWorldScene
----------------------------------------

---@class UIWorldScene
---@field subtype Type
---@field manager UIManager?
---@field active boolean
---@field visible boolean
---@field timer number
---@field duration number?
---@field isFinished boolean
---@field followEntity any?
---@field anchorOffset Vec
---@field pos Vec
---@field elements table[]
UIWorldScene = {}
UIWorldScene.__index = UIWorldScene
UIWorldScene.type = UI_WORLD_SCENE

---@param sceneType Type
---@param followEntity? any
---@param anchorOffset? Vec 
---@param duration? number
---@return UIWorldScene
-- cria uma cena de UI integrada ao mundo
function UIWorldScene.new(sceneType, followEntity, anchorOffset, duration)
	local scene = setmetatable({}, UIWorldScene)
	scene.subtype = sceneType
	scene.active = false
	scene.visible = true
	scene.timer = 0
	scene.duration = duration -- segundos até a cena expirar e ser removida, se for `nil` a cena é persistente
	scene.isFinished = false
	scene.followEntity = followEntity -- entidade a seguir, se for `nil` fica ancorada à câmera
	scene.anchorOffset = anchorOffset or vec(0, 0) -- deslocamento da âncora em relação à entidade/centro da câmera
	scene.pos = vec(scene.anchorOffset.x, scene.anchorOffset.y)
	scene.elements = {}
	return scene
end

---@param elem UIElement
---@param offset? Vec
-- adiciona um elemento à cena
function UIWorldScene:addElement(elem, offset)
	table.insert(self.elements, { elem = elem, offset = offset or vec(0, 0) })
	return self
end

-- torna a cena visível e reinicia o timer da cena
function UIWorldScene:show()
	self.visible = true
	self.timer = 0
end

-- esconde a cena sem removê-la do manager
function UIWorldScene:hide()
	self.visible = false
end

-- atualiza a posição da âncora da cena no mundo: segue a entidade
-- associada ou o centro da câmera
function UIWorldScene:updateAnchor()
	local ox = self.anchorOffset.x
	local oy = self.anchorOffset.y

	-- ancorada a uma entidade
	if self.followEntity and self.followEntity.pos then
		self.pos = vec(self.followEntity.pos.x + ox, self.followEntity.pos.y + oy)
		return
	end

	-- ancorada à câmera, acompanha o centro da visão
	local camera = self.manager and self.manager.camera
	if camera then
		self.pos = vec(camera.cx + ox, camera.cy + oy)
	end
end

---@param dt number
-- atualiza a âncora, os elementos e o tempo de vida da cena
function UIWorldScene:update(dt)
	if not self.active then
		return
	end

	-- hook opcional para a lógica específica da cena (roda antes dos elementos)
	if self.onUpdate then
		self:onUpdate(dt)
	end

	self:updateAnchor()

	-- elementos só atualizam quando a cena está visível
	if self.visible then
		for _, entry in ipairs(self.elements) do
			entry.elem:update(dt)
		end
	end

	-- expiração automática de pop-ups com duração
	if self.duration then
		self.timer = self.timer + dt
		if self.timer >= self.duration then
			self.timer = self.duration
			self.visible = false
			self.isFinished = true
			self.active = false
		end
	end
end

---@param camera Camera
-- renderiza os elementos da cena no espaço do mundo (com zoom da câmera)
function UIWorldScene:draw(camera)
	if not self.active or not self.visible then
		return
	end

	for _, entry in ipairs(self.elements) do
		local elem = entry.elem
		local pos = vec(self.pos.x + entry.offset.x, self.pos.y + entry.offset.y)
		elem.pos = pos

		-- elementos compostos (como a barra de vida) guardam cópias da
		-- posição nas suas partes internas
		if elem.front and elem.front.pos then
			elem.front.pos = vec(pos.x, pos.y)
		end
		if elem.back and elem.back.pos then
			elem.back.pos = vec(pos.x, pos.y)
		end

		elem:draw(camera)
	end
end
