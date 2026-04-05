----------------------------------------
-- Importações de Módulos
----------------------------------------

----------------------------------------
-- Classe Interactive
----------------------------------------

---@class Interactive : Entity
---@field onInteract function
---@field customUpdate function?
---@field customEnter function?
---@field customExit function?
---@field state State
---@field spriteSheets table<State, table>
---@field animations table<State, Animation>
---@field addAnimations function

Interactive = setmetatable({}, { __index = Entity })
Interactive.__index = Interactive
Interactive.type = INTERACTIVE

---@param name string
---@param pos Vec
---@param hitboxes Hitboxes
---@param room Room
---@param physics PhysicsSettings
---@param onInteract function
---@param update? function
---@param customEnter? function
---@param customExit? function
---@return Interactive
-- cria uma entidade interativa, podendo ter uma função de update customizada
function Interactive.new(name, pos, hitboxes, room, physics, onInteract, update, customEnter, customExit)
	---@type Interactive
	local interactive = setmetatable({}, Interactive) ---@diagnostic disable-line
	Entity.init(interactive, name, pos, hitboxes, room, physics)

	interactive.onInteract = onInteract
	interactive.customUpdate = update
	interactive.customEnter = customEnter
	interactive.customExit = customExit
	interactive.state = IDLE   -- define o estado atual do objeto, pode ser usado de formas criativas em interagiveis
	interactive.spriteSheets = {} -- no tipo imagem do love
	interactive.animations = {} -- as chaves são estados e os valores são Animações

	if name == "door" then
		table.insert(room.doors, interactive)
	else
		table.insert(room.interactives, interactive)
	end
	return interactive
end

---@param animSettings table<string, AnimSettings>
-- inicializa as animações do objeto, animSettings deve relacionar estados com `AnimSetting`
function Interactive:addAnimations(animSettings)
	for state, settings in pairs(animSettings) do
		local path = pngPathFormat({ "assets", "animations", "interactives", self.name, state })
		addAnimation(self, path, state, settings)
	end
end

---@param dt number
-- atualiza o objeto caso ele tenha uma função de update própria
function Interactive:update(dt)
	if self.customUpdate then
		self:customUpdate(dt)
	end
	self.animations[self.state]:update(dt)
end

---@param player Player
-- função chamada quando o `player` entra em alcance do objeto interativo
function Interactive:onEnter(player)
	if self.customEnter then
		self:customEnter(player)
	end
end

---@param player Player
-- função chamada quando o `player` sai do alcance do objeto interativo
function Interactive:onExit(player)
	if self.customExit then
		self:customExit(player)
	end
end

---@param camera Camera
-- função de renderização do `Destructible`
function Interactive:draw(camera)
	local viewPos = camera:viewPos(self.pos)
	local anim = self.animations[self.state]
	local quad = anim.frames[anim.currFrame]
	local offset = {
		x = anim.frameDim.width / 2,
		y = anim.frameDim.height / 2,
	}
	love.graphics.draw(self.spriteSheets[self.state], quad, viewPos.x, viewPos.y, 0, 3, 3, offset.x, offset.y)
end
