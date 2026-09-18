----------------------------------------
-- Importações de Módulos
----------------------------------------
require("modules.UI.uielement")
require("modules.utils.vec")

----------------------------------------
-- Classe UIMapElem
----------------------------------------

---@class UIMapElem : UIElement
---@field player Player
---@field focus Vec Coordenada da sala central na visualização do mapa

UIMapElem = setmetatable({}, { __index = UIElement })
UIMapElem.__index = UIMapElem

---@param name string
---@param pos Vec
---@param size Size
---@param player Player
---@return UIMapElem
-- cria o elemento base do mapa
function UIMapElem.new(name, pos, size, player)
	local map = setmetatable({}, UIMapElem)
	map:init(name, UI_ELEMENT, pos, size)

	map.player = player
	map.focus = vec(0, 0)
	-- TODO: adicionar vetor para armazenar offset da CÃMERA

	map:addSprites()

	return map
end

function UIMapElem:addSprites()
	-- salva todos possíveis sprites de antemão
	self.sprites = {
		current = assetManager:getImage("assets/animations/ui/map_room_current/idle.png"),
		unvisited = assetManager:getImage("assets/animations/ui/map_room_unvisited/idle.png"),
		visited = assetManager:getImage("assets/animations/ui/map_room_visited/idle.png"),
	}

	-- salva os tamanhos dos sprites para uso posterior
	self.spriteSizes = {}
	for name, sprite in pairs(self.sprites) do
		local width, height = sprite:getDimensions()
		self.spriteSizes[name] = { width = width, height = height }
	end
end

function UIMapElem:updateMap(player)
	self.focus = vec(player.room.arrPos.x, player.room.arrPos.y)
end

function UIMapElem:draw(camera)
	local firstX = math.floor(self.focus.x) - 3
	local lastX  = math.ceil(self.focus.x) + 3

	local firstY = math.floor(self.focus.y) - 2
	local lastY  = math.ceil(self.focus.y) + 2

	for roomY = firstY, lastY do
    for roomX = firstX, lastX do
        local room = getRoomAt(vec(roomX, roomY))
				local state

				if room then
					if room == self.player.room then
						state = "current"
					elseif room.explored then
						state = "visited"
					else
						state = "unvisited"
					end

					local viewX = self.pos.x
					local viewY = self.pos.y
	
					local w = self.spriteSizes[state].width
					local h = self.spriteSizes[state].height
					local p = 3
	
					local offsetX = w / 2 - (roomX - self.focus.x) * (w + p)
					local offsetY = h / 2 - (roomY - self.focus.y) * (h + p)
	
					love.graphics.draw(self.sprites[state], viewX, viewY, 0, 3, 3, offsetX, offsetY)
					love.graphics.setShader()
				end

    end
	end
end

return UIMapElem
