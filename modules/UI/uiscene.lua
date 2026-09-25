----------------------------------------
-- Enums
----------------------------------------

BG_LAYER_1 = 1
BG_LAYER_2 = 2
VISUAL_LAYER_1 = 3
VISUAL_LAYER_2 = 4
ELEM_LAYER_1 = 5
ELEM_LAYER_2 = 6

local INTERACTION_LAYERS = { ELEM_LAYER_1, ELEM_LAYER_2 }

----------------------------------------
-- Classe UIScene
----------------------------------------

---@class UIScene
---@field subtype Type
---@field active boolean
---@field player Player?
---@field hasBg boolean
---@field selectionPos Vec
---@field layers table<_, table<_, UIElement>>[]

UIScene = {}
UIScene.__index = UIScene
UIScene.type = UI_SCENE

---@param sceneType Type
---@param player any
---@param hasBg? boolean
---@return table
-- cria uma nova cena de UI com um subtipo e com os controles do `player`
function UIScene.new(sceneType, player, hasBg)
	local uiscene = setmetatable({}, UIScene)
	uiscene.subtype = sceneType
	uiscene.player = player
	uiscene.hasBg = hasBg
	uiscene.active = false
	uiscene.selectionPos = vec(math.huge, math.huge)
	uiscene.layers = { {}, {}, {}, {}, {}, {} }
	return uiscene
end

---@param element UIElement
---@param layer number
---@param pos Vec
---@param preserveSelection? boolean
---@return UIScene
-- coloca um elemento de UI na cena em uma determinada camada e posição da matriz
function UIScene:addElement(element, layer, pos, preserveSelection)
	if not self.layers[layer][pos.y] then
		self.layers[layer][pos.y] = {}
	end
	self.layers[layer][pos.y][pos.x] = element

	-- o primeiro elemento começa selecionado
	if layer == ELEM_LAYER_1 or layer == ELEM_LAYER_2 then
		if not preserveSelection
			and (pos.y < self.selectionPos.y or (pos.y == self.selectionPos.y and pos.x < self.selectionPos.x))
		then
			self:setSelection(pos)
			if self.onSelectionChange then
				self:onSelectionChange()
			end
		elseif pos.x == self.selectionPos.x and pos.y == self.selectionPos.y then
			-- mantém elementos sobrepostos, como slot e item, sincronizados
			element:select()
		end
	end
	return self
end

---@param pos Vec
-- troca a seleção em todas as camadas interativas ao mesmo tempo
function UIScene:setSelection(pos)
	for _, layer in ipairs(INTERACTION_LAYERS) do
		local current = self.layers[layer][self.selectionPos.y]
			and self.layers[layer][self.selectionPos.y][self.selectionPos.x]
		if current then
			current:deselect()
		end
	end

	self.selectionPos = vec(pos.x, pos.y)

	for _, layer in ipairs(INTERACTION_LAYERS) do
		local selected = self.layers[layer][pos.y] and self.layers[layer][pos.y][pos.x]
		if selected then
			selected:select()
		end
	end
end

---@param layer number
---@param pos Vec
---@return UIScene
-- remove um elemento de UI de acordo com a camada e sua posição na matriz
function UIScene:removeElement(layer, pos)
	self.layers[layer][pos.y][pos.x] = nil
	return self
end

---@param dt number
-- atualiza cada um dos elementos de UI desta cena
function UIScene:update(dt)
	for i = 1, #self.layers do
		local layer = self.layers[i]
		for _, row in pairs(layer) do
			for _, el in pairs(row) do
				el:update(dt)
			end
		end
	end
end

-- desenha cada um dos elementos de UI desta cena
function UIScene:draw()
	if self.hasBg then
		love.graphics.clear(0.0, 0.0, 0.0, 0.3)
	end
	for i = 1, #self.layers do
		local layer = self.layers[i]
		for _, row in pairs(layer) do
			for _, el in pairs(row) do
				el:draw()
			end
		end
	end
end

---@param key string
---@param controls Controls
function UIScene:handleInput(key, controls)
	-- lidando com movimentação pela UI
	local dir = vec(0, 0)
	if controls:justPressed(ACT_MU) then
		dir.y = dir.y - 1
	elseif controls:justPressed(ACT_MD) then
		dir.y = dir.y + 1
	elseif controls:justPressed(ACT_ML) then
		dir.x = dir.x - 1
	elseif controls:justPressed(ACT_MR) then
		dir.x = dir.x + 1
	end

	if not nullVec(dir) then
		local targetPos = addVec(self.selectionPos, dir)
		local closestEl = nil
		if dir.y ~= 0 then
			closestEl, targetPos = self:closestElemInRow(targetPos.y, targetPos.x)
		elseif dir.x ~= 0 then
			closestEl, targetPos = self:closestElemInColumn(targetPos.x, targetPos.y)
		end

		if closestEl then
			self:setSelection(targetPos)
			globalAudioManager:play(AUDIO_SELECT, self, "pop")

			-- atualiza a cena se necessário
			if self.onSelectionChange then
				self:onSelectionChange()
			end
		end
	end

	-- lidando com cliques
	if controls:checkAction(ACT_CON) then
		for _, l in ipairs(INTERACTION_LAYERS) do
			local el = self.layers[l][self.selectionPos.y] and self.layers[l][self.selectionPos.y][self.selectionPos.x]
			if el and el.subtype == UI_BUTTON_ELEM and el.onClick then
				el:onClick()
				globalAudioManager:play(AUDIO_SELECT, self, "kabum")
				break
			end
		end
	end

	-- lidando com teclas especiais de textbox
	if key and (key == "backspace" or key == "insert") then
		for _, l in ipairs(INTERACTION_LAYERS) do
			local el = self.layers[l][self.selectionPos.y] and self.layers[l][self.selectionPos.y][self.selectionPos.x]
			if el and el.subtype == UI_TEXTBOX_ELEM then
				el:keyPressed(key)
			end
		end
	end
end

-- acha o elemento mais próximo da linha `row` na coluna `column`
function UIScene:closestElemInRow(row, col)
	local smallestDif = math.huge
	local closestEl = nil
	local closestElPos = nil
	for _, l in ipairs(INTERACTION_LAYERS) do
		if self.layers[l][row] then
			for i, el in pairs(self.layers[l][row]) do
				if math.abs(col - i) < smallestDif then
					smallestDif = math.abs(col - i)
					closestEl = el
					closestElPos = vec(i, row)
				end
			end
		end
	end
	return closestEl, closestElPos
end

-- acha o elemento mais próximo da linha `row` na coluna `column`
function UIScene:closestElemInColumn(col, row)
	local smallestDif = math.huge
	local closestEl = nil
	local closestElPos = nil
	for _, l in ipairs(INTERACTION_LAYERS) do
		for i, r in pairs(self.layers[l]) do
			if r[col] then
				if math.abs(row - i) < smallestDif then
					smallestDif = math.abs(row - i)
					closestEl = r[col]
					closestElPos = vec(col, i)
				end
			end
		end
	end
	return closestEl, closestElPos
end

function UIScene:handleTextInput(t)
	for _, l in ipairs(INTERACTION_LAYERS) do
		local el = self.layers[l][self.selectionPos.y] and self.layers[l][self.selectionPos.y][self.selectionPos.x]
		if el and el.subtype == UI_TEXTBOX_ELEM then
			el:handleTextInput(t)
			globalAudioManager:play(AUDIO_SELECT, self, "kabum")
		end
	end
end
