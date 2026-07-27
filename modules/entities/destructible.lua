----------------------------------------
-- Importações de Módulos
----------------------------------------
require("modules.constructors.weapons")
require("modules.engine.animation")
require("modules.systems.collision")
require("modules.entities.entity")
require("modules.systems.loot")
require("modules.utils.states")
require("modules.utils.types")
require("modules.utils.utils")
require("table")

----------------------------------------
-- Enums
----------------------------------------
-- opções do que acontece se o player toca no destrutível
FRAGILE = "fragile" -- quebra quando player toca
UNSTABLE = "unstable" -- se move mas não quebra
STABLE = "stable" -- não se move e nem quebra

----------------------------------------
-- Classe Destructible
----------------------------------------

---@class Destructible : Entity
---@field state string
---@field health number
---@field spriteSheets table<string, table>
---@field animations table<string, Animation>
---@field loot Loot
---@field fragility string
---@field addAnimations fun(self: Destructible, animSettings: table<string, AnimSettings>)

Destructible = setmetatable({}, { __index = Entity })
Destructible.__index = Destructible
Destructible.type = DESTRUCTIBLE

---@param name string
---@param pos Vec
---@param room Room
---@param loot Loot
---@param hitboxes Hitboxes
---@param fragility string?
---@return Destructible
-- cria um objeto destrutível contendo um certo `loot`
function Destructible.new(name, pos, room, loot, hitboxes, fragility)
	---@type Destructible
	local obj = setmetatable({}, Destructible) ---@diagnostic disable-line
	obj:init(name, pos, hitboxes, room)
	obj.state = INTACT
	obj.health = 100 -- vida para ser destruído
	obj.spriteSheets = {}
	obj.animations = {}
	obj.loot = loot or LOOT_TABLE[name] or Loot.new() -- pode ser sobrescrito na criação
	obj.fragility = fragility or FRAGILE

	table.insert(room.destructibles, obj)
	return obj
end

----------------------------------------
-- Animações
----------------------------------------

---@param animSettings table<string, AnimSettings>
-- aplica as animações dos estados `INTACT`, `BREAKING` e `BROKEN` ao `Destructible`
function Destructible:addAnimations(animSettings)
	for state, settings in pairs(animSettings) do
		local path = pngPathFormat({ "assets", "animations", "destructibles", self.name, state })
		addAnimation(self, path, state, settings)
	end
end

----------------------------------------
-- Lógica de dano e destruição
----------------------------------------

---@param amount number
-- causa dano ao `Destructible`. Caso sua vida chegue a 0, ele quebra
function Destructible:damage(amount)
	if self.state ~= INTACT then
		return
	end

	self.health = self.health - amount
	if self.health <= 0 then
		self:breakApart()
	end
end

-- função chamada quando um player colide com um destrutível UNSTABLE
function Destructible:destabilize()
	self.state = MOVING
	local anim = self.animations[MOVING]
	anim.onFinish = function()
		self.state = INTACT
		anim:reset()
	end
end

-- quebra o `Destructible`
function Destructible:breakApart()
	self.state = BREAKING
	self:spawnLoot()
	collisionManager:unregister(self)
	local anim = self.animations[BREAKING]
	anim.onFinish = function()
		self.state = BROKEN
	end
end

----------------------------------------
-- Atualização
----------------------------------------

-- atualiza a animação do `Destructible`
function Destructible:update(dt)
	self.animations[self.state]:update(dt)
end

----------------------------------------
-- Desenho
----------------------------------------

---@param camera Camera
-- função de renderização do `Destructible`
function Destructible:draw(camera)
	local viewPos = camera:viewPos(self.pos)
	local anim = self.animations[self.state]
	local quad = anim.frames[anim.currFrame]
	local offset = {
		x = anim.frameDim.width / 2,
		y = anim.frameDim.height / 2,
	}
	love.graphics.draw(self.spriteSheets[self.state], quad, viewPos.x, viewPos.y, 0, 3, 3, offset.x, offset.y)
end

-- spawna todo o `loot` contido no `Destructible` de forma aleatória,
-- seguindo as chances definidas no próprio `loot`
function Destructible:spawnLoot()
	local loot = self.loot
	if not loot or loot.len == 0 then
		return
	end
	-- spawna aleatoriamente os drops possíveis na posição destrutível
	for i = 1, loot.len do
		local el = loot[i] -- elemento do loot
		if math.random() < el.chance then
			local amount = math.random(el.amountRange.min, el.amountRange.max)
			for _ = 1, amount do
				local dropPos = vec(self.pos.x, self.pos.y)
				local impulseVec = vec(math.random(-100, 100), -math.random(300, 400))
				spawnDrop(el.object, dropPos, self.room, el.autoPick, math.random(-10, 20), impulseVec)
			end
		end
	end
end

return Destructible
