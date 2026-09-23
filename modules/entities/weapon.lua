----------------------------------------
-- Importações de Módulos
----------------------------------------
require("modules.engine.animation")
require("modules.entities.entity")
require("modules.systems.attack")
require("modules.systems.targeting")
require("modules.utils.shapes")
require("modules.utils.types")

----------------------------------------
-- Classe Weapon
----------------------------------------

---@class Weapon: Entity
---@field atk Attack
---@field canShoot boolean
---@field visible boolean
---@field atkTargeting TargetManager
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
---@param attack Attack
---@param gunOffset? Vec
---@param shotOffset? Vec
---@param chargeTime? number
---@return Weapon
-- cria uma instância de `Weapon`
function Weapon.new(name, attack, gunOffset, shotOffset, chargeTime)
	---@type Weapon
	local weapon = setmetatable({}, Weapon) ---@diagnostic disable-line

	weapon:init(name)

	-- atributos que variam
	weapon.atk = attack -- instância de Attack associada à arma
	weapon.gunOffset = gunOffset or vec(0, 0) -- deslocamento da arma em relação ao centro do jogador
	weapon.shotOffset = shotOffset or vec(0, 0) -- deslocamento do ponto de origem do ataque em relação ao centro da arma
	weapon.chargeTime = chargeTime or 0 -- tempo que o jogador deve segurar a arma para atirar
	weapon.atk:setWeapon(weapon) -- associa a arma ao ataque
	-- atributos fixos na instanciação
	weapon.rotateOffset = vec(-10, 0)
	weapon.canShoot = false
	weapon.visible = true
	weapon.atkTargeting = TargetManager.new(weapon) -- gerenciador de alvo da arma
	weapon.rotation = 0 -- rotação da arma em radianos
	weapon.currentCharge = 0 -- tempo atual de carregamento da arma
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
	self.atk:updateTimer(dt * speedBonus)
	self.atk:update(dt)

	if self.state == CHARGING then
		-- cancela o carregamento se o jogador defender ou morrer
		if self.owner.state == DEFENDING or self.owner.state == DYING then
			self.state = IDLE
			self.currentCharge = 0
			if self.animations[IDLE] then
				self.animations[IDLE]:reset()
			end
			return
		end

		-- incrementa o tempo de charge
		self.currentCharge = self.currentCharge + dt

		-- verifica se o jogador soltou o botão nesta exata frame
		if self.owner.controls:justReleased(ACT_ATK) or not self.owner.controls:isDown(ACT_ATK) then
			if self.currentCharge >= self.chargeTime then
				self:fire()
			else
				self.state = IDLE
			end
			self.currentCharge = 0
		end
	end
end

---@return boolean
-- tenta realizar um ataque, caso bem sucedido, atualiza o estado/animação da arma
function Weapon:attack()
	if self.state == CHARGING then
		return true
	end

	if self.atk.canAttack and self.visible then
		if self.chargeTime and self.chargeTime > 0 then
			self.state = CHARGING
			self.currentCharge = 0
			if self.animations[CHARGING] then
				self.animations[CHARGING]:reset()
			end
		else
			-- armas com chargeTime = 0 atiram imediatamente
			self:fire()
		end
		return true
	end
	return false
end

-- executa o disparo, gerando os eventos de ataque
function Weapon:fire()
	local origin = self:atkOriginPoint()
	self.atk:attack(self.owner, origin, self.rotation)

	if self.animations[ATTACKING] then
		self.state = ATTACKING
		self.animations[ATTACKING]:reset()
	end
end

function Weapon:atkOriginPoint()
	local flip = invertSecondAndThirdQuadrants(self.rotation)
	local gunCenter = addVec(self.owner.pos, vec(self.gunOffset.x * flip, self.gunOffset.y))
	local rotateOffset = rotateVec(
		vec(-self.rotateOffset.x + self.shotOffset.x, -self.rotateOffset.y + self.shotOffset.y * flip),
		self.rotation
	)
	local origin = addVec(gunCenter, rotateOffset)

	return origin
end

---@param idleSettings AnimSettings
---@param weaponAtkSettings? AnimSettings
---@param chargingSettings? AnimSettings
-- inicializa as animações de `Weapon` e as associa com seus respectivos estados
function Weapon:addAnimations(idleSettings, weaponAtkSettings, chargingSettings)
	-- animação idle
	local path = pngPathFormat({ "assets", "animations", "weapons", self.name, IDLE })
	addAnimation(self, path, IDLE, idleSettings)

	if weaponAtkSettings then
		-- animação da arma ao atacar
		path = pngPathFormat({ "assets", "animations", "weapons", self.name, ATTACKING })
		addAnimation(self, path, ATTACKING, weaponAtkSettings)
		self.animations[ATTACKING].onFinish = function()
			self.state = IDLE
		end
	end

	if chargingSettings then
		-- animação da arma ao carregar
		path = pngPathFormat({ "assets", "animations", "weapons", self.name, CHARGING })
		addAnimation(self, path, CHARGING, chargingSettings)
	else
		self.animations[CHARGING] = self.animations[IDLE]
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

	local viewX, viewY = camera:viewPos(self.owner.pos)
	local animation = self.animations[self.state]

	local p = self.owner.invulnerableTimer > 0
			and (self.owner.defaultInvulnerableTime - self.owner.invulnerableTimer) / self.owner.defaultInvulnerableTime
		or 0
	local defaultScale = 3
	local scaleX = defaultScale - 0.8 * math.sin(2 * math.pi * p)
	local scaleY = defaultScale + 0.8 * math.sin(2 * math.pi * p)
	local offsetX = animation.frameDim.width / 2 + self.rotateOffset.x
	local offsetY = (animation.frameDim.height * scaleY - (animation.frameDim.height / 2) * defaultScale) / scaleY

	local flip = invertSecondAndThirdQuadrants(self.rotation)

	love.graphics.draw(
		self.spriteSheets[self.state],
		animation.frames[animation.currFrame],
		viewX + self.gunOffset.x * flip,
		viewY + self.gunOffset.y,
		self.rotation,
		scaleX,
		scaleY * flip,
		offsetX,
		offsetY
	)

	if self.owner.invulnerableTimer > 0 then
		love.graphics.setShader()
	end
end
