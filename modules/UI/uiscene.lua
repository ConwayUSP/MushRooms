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
	if (layer == ELEM_LAYER_1 or layer == ELEM_LAYER_2) then
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

---@param key string
---@param isrepeat boolean
-- trata uma interação via teclado com a UI desta cena
function UIScene:keypressed(key, isrepeat)
	local prevSelPos = vec(self.selectionPos.x, self.selectionPos.y)
	local elemLayer1 = self.layers[ELEM_LAYER_1]
	local elemLayer2 = self.layers[ELEM_LAYER_2]

	-- helpers
	local function getMaxXInRow(layer, y)
		local max = 0
		local row = layer[y]
		if row then
			for x, _ in pairs(row) do
				if x > max then max = x end
			end
		end
		return max
	end

	local function getMaxY(layer)
		local max = 0
		for y, _ in pairs(layer) do
			if y > max then max = y end
		end
		return max
	end

	local function getElem(layer, x, y)
		if layer[y] then
			return layer[y][x]
		end
		return nil
	end

	if (not elemLayer1[self.selectionPos.y] or not elemLayer1[self.selectionPos.y][self.selectionPos.x]) and (not elemLayer2[self.selectionPos.y] or not elemLayer2[self.selectionPos.y][self.selectionPos.x]) then
		return
	end

	if key == self.controls.left then
		if self.selectionPos.x > 1 then
			if getElem(elemLayer1, self.selectionPos.x - 1, self.selectionPos.y) or getElem(elemLayer2, self.selectionPos.x - 1, self.selectionPos.y) then
				self.selectionPos.x = self.selectionPos.x - 1
			end
		end
	elseif key == self.controls.right then
		local maxX1 = getMaxXInRow(elemLayer1, self.selectionPos.y)
		local maxX2 = getMaxXInRow(elemLayer2, self.selectionPos.y)
		local maxX = math.max(maxX1, maxX2)

		if self.selectionPos.x < maxX then
			self.selectionPos.x = self.selectionPos.x + 1
		end
	elseif key == self.controls.up then
		if self.selectionPos.y > 1 then
			local newY = self.selectionPos.y - 1
			local newX = 1
			local upLayer = (elemLayer1[newY] and elemLayer1) or elemLayer2
			if getElem(upLayer, self.selectionPos.x, newY) then
				newX = self.selectionPos.x
			else
				newX = getMaxXInRow(upLayer, newY)
			end
			self.selectionPos = vec(newX, newY)
		end
	elseif key == self.controls.down then
		local maxY1 = getMaxY(elemLayer1)
		local maxY2 = getMaxY(elemLayer2)
		local maxY = math.max(maxY1, maxY2)

		if self.selectionPos.y < maxY then
			local newY = self.selectionPos.y + 1
			local newX = 1
			local downLayer = (elemLayer1[newY] and elemLayer1) or elemLayer2
			if getElem(downLayer, self.selectionPos.x, newY) then
				newX = self.selectionPos.x
			else
				newX = getMaxXInRow(downLayer, newY)
			end
			self.selectionPos = vec(newX, newY)
		end
	elseif key == self.controls.act1 then
		local selPos = self.selectionPos
		local el_1 = getElem(elemLayer1, selPos.x, selPos.y)
		local el_2 = getElem(elemLayer2, selPos.x, selPos.y)
		if el_1 and el_1.subtype == UI_BUTTON_ELEM then
			el_1.onClick()
		elseif el_2 and el_2.subtype == UI_BUTTON_ELEM then
			el_2.onClick()
		end
	end

	if prevSelPos.y ~= self.selectionPos.y or prevSelPos.x ~= self.selectionPos.x then
		local prevEl1 = getElem(elemLayer1, prevSelPos.x, prevSelPos.y)
		local prevEl2 = getElem(elemLayer2, prevSelPos.x, prevSelPos.y)
		if prevEl1 then prevEl1:deselect() end
		if prevEl2 then prevEl2:deselect() end
		local newEl1 = getElem(elemLayer1, self.selectionPos.x, self.selectionPos.y)
		local newEl2 = getElem(elemLayer2, self.selectionPos.x, self.selectionPos.y)
		if newEl1 then newEl1:select() end
		if newEl2 then newEl2:select() end
	end
end
