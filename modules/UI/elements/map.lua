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
	map.targetFocus = vec(0, 0)

	map:addSprites()

	return map
end

function UIMapElem:addSprites()
	-- salva todos possíveis sprites de antemão
	self.sprites = {
		background = assetManager:getImage("assets/animations/ui/map_bg/idle.png"),
		current = assetManager:getImage("assets/animations/ui/map_room_slot/map_room_current.png"),
		unvisited = assetManager:getImage("assets/animations/ui/map_room_slot/map_room_unvisited.png"),
		visited = assetManager:getImage("assets/animations/ui/map_room_slot/map_room_visited.png"),
		Mush_icon = assetManager:getImage("assets/animations/ui/map_player_icons/map_mush_icon.png"),
		Musho_icon = assetManager:getImage("assets/animations/ui/map_player_icons/map_musho_icon.png"),
		Roomy_icon = assetManager:getImage("assets/animations/ui/map_player_icons/map_roomy_icon.png"),
		Shroom_icon = assetManager:getImage("assets/animations/ui/map_player_icons/map_shroom_icon.png"),
		Tenkar_icon = assetManager:getImage("assets/animations/ui/map_misc_icons/icon_tenkar.png"),
		boss_unvisited = assetManager:getImage("assets/animations/ui/map_misc_icons/icon_boss_unvisited.png"),
		boss_visited = assetManager:getImage("assets/animations/ui/map_misc_icons/icon_boss_visited.png"),
	}

	-- salva os tamanhos dos sprites para uso posterior
	self.spriteSizes = {}
	for name, sprite in pairs(self.sprites) do
		local width, height = sprite:getDimensions()
		self.spriteSizes[name] = { width = width, height = height }
	end
end

-- atualiza a posição do foco do mapa suavemente em direção ao alvo com lerp
function UIMapElem:update(dt)
	if math.abs(self.focus.x - self.targetFocus.x) > 0.00005 then
		self.focus.x = lerp(self.focus.x, self.targetFocus.x, 0.1)
	end
	if math.abs(self.focus.y - self.targetFocus.y) > 0.00005 then
		self.focus.y = lerp(self.focus.y, self.targetFocus.y, 0.1)
	end
end

-- atualiza a posição do foco do mapa para a sala especificada
function UIMapElem:setFocus(vec)
	self.targetFocus = vec
end

-- atualiza a posição do foco do mapa para a sala do jogador
function UIMapElem:updateMap(player)
	self.targetFocus = vec(player.room.arrPos.x, player.room.arrPos.y)
end

-- calcula o offset do slot do mapa relativo a posição da sala
function UIMapElem:calcOffsets(state, roomX, roomY)
	local p = 3
	local w = self.spriteSizes[state].width
	local h = self.spriteSizes[state].height

	local wSlot = self.spriteSizes["current"].width
	local hSlot = self.spriteSizes["current"].height

	local offsetX = w / 2 - (roomX - self.focus.x) * (wSlot + p)
	local offsetY = h / 2 - (roomY - self.focus.y) * (hSlot + p)

	return offsetX, offsetY
end

-- calcula o offset do ícone do jogador dentro do slot (relativo a posição do jogador na sala)
function UIMapElem:calcIconOffsets(offsetX, offsetY, room, player)
	local wSlot = self.spriteSizes["current"].width
	local hSlot = self.spriteSizes["current"].height

	local iconOffsetX = -(player.pos.x - room.pos.x) / room.stdDim.width * wSlot * 0.75 + offsetX
	local iconOffsetY = -(player.pos.y - room.pos.y) / room.stdDim.height * hSlot * 0.75 + offsetY

	return iconOffsetX, iconOffsetY
end

-- recorta a área de desenho do mapa para que não desenhe fora do fundo
function UIMapElem:setMapScissor()
	local padding = 20

	local bgSize = self.spriteSizes.background
	local width = bgSize.width * 3 - padding * 2
	local height = bgSize.height * 3 - padding * 2

	love.graphics.setScissor(self.pos.x - width / 2, self.pos.y - height / 2, width, height)
end

function UIMapElem:draw(camera)
	local firstX = self.targetFocus.x - 5
	local lastX  = self.targetFocus.x + 5

	local firstY = self.targetFocus.y - 3
	local lastY  = self.targetFocus.y + 3

	local viewX = self.pos.x
	local viewY = self.pos.y
	self:setMapScissor()

	for roomY = firstY, lastY do
    for roomX = firstX, lastX do
			local room = getRoomAt(vec(roomX, roomY))
			local roomStatus

			if room then
				if areVecsEqual(room.arrPos, self.targetFocus) then
					roomStatus = "current"
				elseif room.explored then
					roomStatus = "visited"
				else
					roomStatus = "unvisited"
				end

				local offsetX, offsetY = self:calcOffsets(roomStatus, roomX, roomY)

				-- SLOT
				love.graphics.draw(self.sprites[roomStatus], viewX, viewY, 0, 3, 3, offsetX, offsetY)

				-- MISC ICONS
				if room.roomType == BOSS_ROOM then
					local bossIcon = room.explored and "boss_visited" or "boss_unvisited"
					offsetX, offsetY = self:calcOffsets(bossIcon, roomX, roomY)
					love.graphics.draw(self.sprites[bossIcon], viewX, viewY, 0, 3, 3, offsetX, offsetY)

				elseif room.roomType == NPC_ROOM then
					for _, npc in ipairs(room.npcs) do
						if npc.name == "Tenkar" then
							offsetX, offsetY = self:calcOffsets("Tenkar_icon", roomX, roomY)
							love.graphics.draw(self.sprites["Tenkar_icon"], viewX, viewY, 0, 3, 3, offsetX, offsetY)
						end
					end

				end

				-- ICON PLAYER
				for _, player in room.playersInRoom:iter() do
					local spriteName = player.name.."_icon"
					offsetX, offsetY = self:calcOffsets(spriteName, roomX, roomY)
					offsetX, offsetY = self:calcIconOffsets(offsetX, offsetY, room, player)

					love.graphics.draw(self.sprites[spriteName], viewX, viewY, 0, 3, 3, offsetX, offsetY)
				end

			end
		end
	end

	love.graphics.setScissor()
end

return UIMapElem
