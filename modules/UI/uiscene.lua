----------------------------------------
-- Enums
----------------------------------------

BG_LAYER_1 = 1
BG_LAYER_2 = 2
VISUAL_LAYER_1 = 3
VISUAL_LAYER_2 = 4
ELEM_LAYER_1 = 5
ELEM_LAYER_2 = 6

----------------------------------------
-- Classe UIScene
----------------------------------------

---@class UIScene
---@field subtype Type
---@field controls table
---@field active boolean
---@field selectionPos Vec
---@field layers table<_, table<_, UIElement>>[]

UIScene = {}
UIScene.__index = UIScene
UIScene.type = UI_SCENE

---@param sceneType Type
---@param player any
---@return table
-- cria uma nova cena de UI com um subtipo e com os controles do `player`
function UIScene.new(sceneType, player)
	local uiscene = setmetatable({}, UIScene)
	uiscene.subtype = sceneType
	if player then
		uiscene.controls = player.controls
	else
		uiscene.controls = { up = "w", left = "a", down = "s", right = "d", act1 = "space", act2 = "lshift" }
	end
	uiscene.active = false
	uiscene.selectionPos = vec(math.huge, math.huge)
	uiscene.layers = { {}, {}, {}, {}, {}, {} }
	return uiscene
end

---@param element UIElement
---@param layer number
---@param pos Vec
---@return UIScene
-- coloca um elemento de UI na cena em uma determinada camada e posição da matriz
function UIScene:addElement(element, layer, pos)
	if not self.layers[layer][pos.y] then
		self.layers[layer][pos.y] = {}
	end
	self.layers[layer][pos.y][pos.x] = element
	-- o primeiro elemento começa selecionado
	if layer == ELEM_LAYER_1 or layer == ELEM_LAYER_2 then
		local newSelPos = vec(self.selectionPos.x, self.selectionPos.y)
		if pos.y < self.selectionPos.y or (pos.y == self.selectionPos.y and pos.x < self.selectionPos.x) then
			newSelPos = vec(pos.x, pos.y)
		end

		if newSelPos.x ~= self.selectionPos.x or newSelPos.y ~= self.selectionPos.y then
			local prevRow = self.layers[layer][self.selectionPos.y]
			if prevRow and prevRow[self.selectionPos.x] then
				prevRow[self.selectionPos.x]:deselect()
			end

			self.layers[layer][newSelPos.y][newSelPos.x]:select()
			self.selectionPos = newSelPos
			if self.onSelectionChange then
				self:onSelectionChange()
			end
		end
	end
	return self
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
	love.graphics.clear(0.0, 0.0, 0.0, 0.3)
	for i = 1, #self.layers do
		local layer = self.layers[i]
		for _, row in pairs(layer) do
			for _, el in pairs(row) do
				el:draw()
			end
		end
	end
end

function UIScene:keypressed(key, isrepeat)
	-- camadas que possuem interação (botões, itens, etc.)
	local interactionLayers = { ELEM_LAYER_1, ELEM_LAYER_2 }

	-- função auxiliar para verificar se existe algum elemento numa coordenada
	local function hasElementAt(x, y)
		for _, l in ipairs(interactionLayers) do
			if self.layers[l][y] and self.layers[l][y][x] then
				return true
			end
		end
		return false
	end

	-- lidando com movimentação pela UI
	local moveMap = {
		[self.controls.up] = vec(0, -1),
		[self.controls.down] = vec(0, 1),
		[self.controls.left] = vec(-1, 0),
		[self.controls.right] = vec(1, 0),
	}

	local dir = moveMap[key]
	if dir then
		local targetPos = addVec(self.selectionPos, dir)

		if hasElementAt(targetPos.x, targetPos.y) then
			-- deselecionando os elementos na posição antiga
			for _, l in ipairs(interactionLayers) do
				local el = self.layers[l][self.selectionPos.y]
					and self.layers[l][self.selectionPos.y][self.selectionPos.x]
				if el then
					el:deselect()
				end
			end

			self.selectionPos = targetPos

			-- selecionando os elementos na nova posição
			for _, l in ipairs(interactionLayers) do
				local el = self.layers[l][self.selectionPos.y]
					and self.layers[l][self.selectionPos.y][self.selectionPos.x]
				if el then
					el:select()
				end
			end

			-- atualiza a cena se necessário
			if self.onSelectionChange then
				self:onSelectionChange()
			end
		end
	end

	-- lidando com cliques
	if key == self.controls.act1 then
		for _, l in ipairs(interactionLayers) do
			local el = self.layers[l][self.selectionPos.y] and self.layers[l][self.selectionPos.y][self.selectionPos.x]
			if el and el.subtype == UI_BUTTON_ELEM then
				el.onClick()
			end
		end
	end
end
