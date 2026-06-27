----------------------------------------
-- Importações de Módulos
----------------------------------------
require("modules.engine.animation")
require("modules.entities.entity")
require("modules.systems.attack")
require("modules.utils.shapes")
require("modules.utils.types")

----------------------------------------
-- Classe Weapon
----------------------------------------

---@class Weapon: Entity
---@field ammo number
---@field atk Attack
---@field canShoot boolean
---@field visible boolean
---@field target any
---@field rotation rad
---@field gunOffset Vec
---@field shotOffset Vec
---@field rotateOffset Vec
---@field state string
---@field spriteSheets table<string, table>
---@field animations table<string, Animation>
---@field addAnimations fun(self: Weapon, idleSettings: AnimSettings, weaponAtkSettings?: AnimSettings): nil

Weapon = setmetatable({}, { __index = Entity })
Weapon.__index = Weapon
Weapon.type = WEAPON

---@param name string
---@param ammo number
---@param attack Attack
---@return Weapon
-- cria uma instância de `Weapon`
function Weapon.new(name, ammo, attack, gunOffset, shotOffset)
	---@type Weapon
	local weapon = setmetatable({}, Weapon) ---@diagnostic disable-line

	weapon:init(name)

	-- atributos que variam
	weapon.ammo = ammo -- número de munições
	weapon.atk = attack -- instância de Attack associada à arma
	weapon.gunOffset = gunOffset or vec(0, 0) -- deslocamento da arma em relação ao centro do jogador
	weapon.shotOffset = shotOffset or vec(0, 0) -- deslocamento do ponto de origem do ataque em relação ao centro da arma
	weapon.atk:setWeapon(weapon) -- associa a arma ao ataque
	-- atributos fixos na instanciação
	weapon.rotateOffset = vec(-10, 0)
	weapon.canShoot = false
	weapon.visible = true
	weapon.target = nil -- inimigo para o qual a arma está mirando
	weapon.rotation = 0 -- rotação da arma em radianos
	weapon.state = IDLE -- estado atual da arma
	weapon.spriteSheets = {} -- no tipo imagem do love
	weapon.animations = {} -- as chaves são estados e os valores são Animações
	return weapon
end

---@param dirVec Vec
-- atualiza a orientação (ângulo em radianos) de `Weapon`
function Weapon:updateOrientation(dirVec)
	if dirVec.x == 0 and dirVec.y == 0 then
		self.rotation = -math.pi * 0.5
	else
		self.rotation = math.atan2(dirVec.x, -dirVec.y) - math.pi * 0.5
	end
end

---@param dt number
-- atualiza o estado, o cooldown e o ataque da arma
function Weapon:update(dt)
	local speedBonus = self.owner and self.owner.atkSpeed or 1
	self.atk:updateTimer(dt*speedBonus)
	self.atk:update(dt)

	-- self.rotation = math.atan2(love.mouse.getX() - viewPos.x, -(love.mouse.getY() - viewPos.y)) - math.pi * 0.5

	if self.atk.canAttack then
		self.state = IDLE
	end
end

---@return boolean
-- tenta realizar um ataque, caso bem sucedido, atualiza o estado/animação da arma
function Weapon:attack()
	if self.ammo > 0 and self.atk.canAttack and self.visible then
		self.ammo = self.ammo - 1

		local origin = self:atkOriginPoint()
		self.atk:attack(self.owner, origin, self.rotation)

		if self.animations[ATTACKING] then
			self.state = ATTACKING
			self.animations[ATTACKING]:reset()
		end
		return true
	end
	return false
end

function Weapon:atkOriginPoint()
	local flip = invertSecondAndThirdQuadrants(self.rotation)
	local gunCenter = addVec(self.owner.pos, vec(self.gunOffset.x * flip, self.gunOffset.y))
	local rotateOffset = rotateVec(vec(-self.rotateOffset.x + self.shotOffset.x, -self.rotateOffset.y + self.shotOffset.y*flip), self.rotation)
	local origin = addVec(gunCenter, rotateOffset)

	return origin
end

---@param idleSettings AnimSettings
---@param weaponAtkSettings? AnimSettings
-- inicializa as animações de `Weapon` e as associa com seus respectivos estados
function Weapon:addAnimations(idleSettings, weaponAtkSettings)
	-- animação idle
	local path = pngPathFormat({ "assets", "animations", "weapons", self.name, IDLE })
	addAnimation(self, path, IDLE, idleSettings)
	
	if weaponAtkSettings then
			-- animação da arma ao atacar
		path = pngPathFormat({ "assets", "animations", "weapons", self.name, ATTACKING })
		addAnimation(self, path, ATTACKING, weaponAtkSettings)
	end
end

----------------------------------------
-- Funções de Renderização
----------------------------------------

---@param camera Camera
-- renderiza a arma na perspectiva da `camera`
function Weapon:draw(camera)
	-- Não renderiza armas de jogadores se defendendo
	if self.owner.state == DEFENDING or self.owner.building or not self.visible then
		return
	end

	love.graphics.setColor(1, 1, 1, 1)

	if self.owner.invulnerableTimer > 0 then
		love.graphics.setShader(whiteShader)
		whiteShader:send("fillColor", { 1, 1, 1, 1.0 })
	end

	local viewPos = camera:viewPos(self.owner.pos)
	local animation = self.animations[self.state]
	local quad = animation.frames[animation.currFrame]
	
	local p = self.owner.invulnerableTimer > 0
		and (self.owner.defaultInvulnerableTime - self.owner.invulnerableTimer) / self.owner.defaultInvulnerableTime
		or 0
	local defaultScale = 3
	local scaleX = defaultScale - 0.8 * math.sin(2 * math.pi * p)
	local scaleY = defaultScale + 0.8 * math.sin(2 * math.pi * p)
	local offset = {
		x = animation.frameDim.width / 2 + self.rotateOffset.x,
		y = (animation.frameDim.height * scaleY - (animation.frameDim.height / 2) * defaultScale) / scaleY,
	}
	local flip = invertSecondAndThirdQuadrants(self.rotation)
	
	love.graphics.draw(
		self.spriteSheets[self.state],
		quad,
		viewPos.x + self.gunOffset.x * flip,
		viewPos.y + self.gunOffset.y,
		self.rotation,
		scaleX,
		scaleY * flip,
		offset.x,
		offset.y
	)

	if self.owner.invulnerableTimer > 0 then
		love.graphics.setShader()
	end
end
