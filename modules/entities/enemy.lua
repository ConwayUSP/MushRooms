----------------------------------------
-- Importações de Módulos
----------------------------------------
require("modules.engine.collision")
require("modules.entities.entity")
require("modules.utils.states")
require("modules.utils.types")
require("table")

----------------------------------------
-- Classe Enemy
----------------------------------------

---@class Enemy : Entity
---@field hp number
---@field move function
---@field state string
---@field spriteSheets table<string, table>
---@field animations table<string, Animation>
---@field target any
---@field atk Attack[]
---@field selectedAtk number
---@field isAttacking boolean
---@field hasTriggeredAttackThisAnim boolean
---@field attackJustStarted boolean
---@field attackFrame number
---@field addAnimations function
---@field setProjectileAtk function

Enemy = setmetatable({}, { __index = Entity })
Enemy.__index = Enemy
Enemy.type = ENEMY

---@param name string
---@param hp number
---@param spawnPos Vec
---@param physics PhysicsSettings
---@param move function
---@param attacks Attack[]
---@param hitboxes Hitboxes
---@param room Room
---@param attackFrame number
---@return Enemy
-- cria uma instância de `Enemy`
function Enemy.new(name, hp, spawnPos, physics, move, attacks, hitboxes, room, attackFrame)
	---@type Enemy
	local enemy = setmetatable({}, Enemy) ---@diagnostic disable-line
	enemy:init(name, spawnPos, hitboxes, room, physics)

	-- atributos que variam
	enemy.hp = hp -- pontos de vida do inimigo
	enemy.move = move -- função de movimento do inimigo
	enemy.atk = attacks -- objetos Attack associados ao inimigo (caso possua)
	enemy.attackFrame = attackFrame -- frame de ataque do inimigo
	-- atributos fixos na instanciação
	enemy.selectedAtk = 1 -- o primeiro ataque começa selecionado, os posteriores são aleatórios
	enemy.state = IDLE -- define o estado atual do inimigo, estreitamente relacionado às animações
	enemy.spriteSheets = {} -- no tipo imagem do love
	enemy.animations = {} -- as chaves são estados e os valores são Animações
	enemy.target = nil -- alvo atual do inimigo
	enemy.isAttacking = false -- indica se o inimigo está atualmente atacando
	enemy.hasTriggeredAttackThisAnim = false -- garante que cada animação de ataque dispare apenas uma vez
	enemy.attackJustStarted = false -- indica se um novo ataque acabou de começar

	table.insert(room.enemies, enemy)
	return enemy
end

---@param idleSettings AnimSettings
---@param walkingSettings AnimSettings
---@param attackSettings AnimSettings
---@param dyingSettings AnimSettings
-- adiciona as animações dos estados dos inimigos à sua tabela de animações
function Enemy:addAnimations(idleSettings, walkingSettings, attackSettings, dyingSettings)
	----------------- IDLE -----------------
	local path = pngPathFormat({ "assets", "animations", "enemies", self.name, IDLE })
	addAnimation(self, path, IDLE, idleSettings)
	---------------- WALKING UP -----------------
	path = pngPathFormat({ "assets", "animations", "enemies", self.name, WALKING_UP })
	addAnimation(self, path, WALKING_UP, walkingSettings)
	---------------- WALKING DOWN -----------------
	path = pngPathFormat({ "assets", "animations", "enemies", self.name, WALKING_DOWN })
	addAnimation(self, path, WALKING_DOWN, walkingSettings)
	---------------- WALKING LEFT -----------------
	path = pngPathFormat({ "assets", "animations", "enemies", self.name, WALKING_LEFT })
	addAnimation(self, path, WALKING_LEFT, walkingSettings)
	---------------- WALKING RIGHT -----------------
	path = pngPathFormat({ "assets", "animations", "enemies", self.name, WALKING_RIGHT })
	addAnimation(self, path, WALKING_RIGHT, walkingSettings)
	---------------- ATTACKING UP -----------------
	path = pngPathFormat({ "assets", "animations", "enemies", self.name, ATTACKING_UP })
	addAnimation(self, path, ATTACKING_UP, attackSettings)
	self:initAttackAnim(self.animations[ATTACKING_UP])
	---------------- ATTACKING DOWN -----------------
	path = pngPathFormat({ "assets", "animations", "enemies", self.name, ATTACKING_DOWN })
	addAnimation(self, path, ATTACKING_DOWN, attackSettings)
	self:initAttackAnim(self.animations[ATTACKING_DOWN])
	---------------- ATTACKING LEFT -----------------
	path = pngPathFormat({ "assets", "animations", "enemies", self.name, ATTACKING_LEFT })
	addAnimation(self, path, ATTACKING_LEFT, attackSettings)
	self:initAttackAnim(self.animations[ATTACKING_LEFT])
	---------------- ATTACKING RIGHT -----------------
	path = pngPathFormat({ "assets", "animations", "enemies", self.name, ATTACKING_RIGHT })
	addAnimation(self, path, ATTACKING_RIGHT, attackSettings)
	self:initAttackAnim(self.animations[ATTACKING_RIGHT])
	---------------- DYING -----------------
	path = pngPathFormat({ "assets", "animations", "enemies", self.name, DYING })
	addAnimation(self, path, DYING, dyingSettings)
end

---@param anim Animation
-- inicializa a animação de ataque do inimigo, definindo seu callback `onFinish`
function Enemy:initAttackAnim(anim)
	anim.onFinish = function()
		self.isAttacking = false
		self.selectedAtk = math.random(#self.atk)
		self.hasTriggeredAttackThisAnim = false
	end
end

-- verifica se um estado é de ataque
function Enemy:isAttackState(state)
	return state == ATTACKING_UP or state == ATTACKING_DOWN or state == ATTACKING_LEFT or state == ATTACKING_RIGHT
end

-- reseta todas as animações de ataque para o primeiro frame
function Enemy:resetAttackAnimations()
	local attackStates = { ATTACKING_UP, ATTACKING_DOWN, ATTACKING_LEFT, ATTACKING_RIGHT }
	for _, state in ipairs(attackStates) do
		local anim = self.animations[state]
		if anim then
			anim:reset()
			anim.timer = 0
		end
	end
end

-- sincroniza o frame atual entre todas as animações de ataque
function Enemy:synchronizeAttackAnimations()
	if not self:isAttackState(self.state) then
		return
	end

	local sourceAnim = self.animations[self.state]
	if not sourceAnim then
		return
	end

	local attackStates = { ATTACKING_UP, ATTACKING_DOWN, ATTACKING_LEFT, ATTACKING_RIGHT }
	for _, state in ipairs(attackStates) do
		local anim = self.animations[state]
		if anim and anim ~= sourceAnim then
			anim.currFrame = sourceAnim.currFrame
			anim.timer = sourceAnim.timer
		end
	end
end

---@param damage number
-- reduz a vida do `Enemy` em `damage` pontos. Caso a vida
-- chegue abaixo de 0, mata o inimigo
function Enemy:takeDamage(damage)
	if self.state == DYING then
		return
	end

	self.hp = self.hp - damage
	if self.hp <= 0 then
		self:die()
	end
end

-- inicia o processo de morte do inimigo
function Enemy:die()
	self.state = DYING
	local anim = self.animations[DYING]
	anim.onFinish = function()
		collisionManager:unregister(self)
		for _, atk in pairs(self.atk[self.selectedAtk].events) do
			collisionManager:unregister(atk)
		end

		table.remove(self.room.enemies, tableIndexOf(self.room.enemies, self))
	end
end

function Enemy:attack()
	-- as condições para tentar um ataque não são cumpridas
	if not self.target or not self.target.pos or not self.atk[self.selectedAtk] then
		return
	end
	if self.atk[self.selectedAtk].canAttack and not self.isAttacking then
		self.isAttacking = true
		self.hasTriggeredAttackThisAnim = false
		self.attackJustStarted = true
	end
end

function Enemy:updateAttack()
	if self.isAttacking then
		local anim = self.animations[self.state]

		if anim.currFrame >= self.attackFrame and not self.hasTriggeredAttackThisAnim then
			local dir = math.atan2(self.target.pos.y - self.pos.y, self.target.pos.x - self.pos.x)
			self.atk[self.selectedAtk]:attack(self, self.pos, dir)
			self.hasTriggeredAttackThisAnim = true
		end
	end
end

---@param dt number
-- atualiza os estados do inimigo e seus ataques, além de movê-lo
function Enemy:update(dt)
	self:defineTarget()
	if self.move and self.state ~= DYING and not self.isAttacking then
		self:move(dt)
	end
	self.atk[self.selectedAtk]:updateTimer(dt)
	for _, atk in pairs(self.atk) do
		atk:update(dt)
	end

	self:updateInvulnerability(dt)
	self:attack()
	self:updateState()
	if self.isAttacking and self.attackJustStarted then
		self:resetAttackAnimations()
		self.attackJustStarted = false
	end
	self:updateAttack()
	self.animations[self.state]:update(dt)
	if self.isAttacking then
		self:synchronizeAttackAnimations()
	end
	applyPhysics(self, dt)
end

----------------------------------------
-- Funções de Estado
----------------------------------------

function Enemy:updateState()
	if self.state == DYING then
		return
	end

	if self.atk[self.selectedAtk] and self.isAttacking then
		local dirVec = subVec(self.target.pos, self.pos)

		local isVerticalAttack = math.abs(dirVec.y) > math.abs(dirVec.x)
		if isVerticalAttack and dirVec.y < 0 then
			self.state = ATTACKING_UP
		elseif isVerticalAttack and dirVec.y > 0 then
			self.state = ATTACKING_DOWN
		elseif not isVerticalAttack and dirVec.x > 0 then
			self.state = ATTACKING_RIGHT
		elseif not isVerticalAttack and dirVec.x < 0 then
			self.state = ATTACKING_LEFT
		end
	elseif self.move then
		local isVerticalMovement = math.abs(self.vel.y) > math.abs(self.vel.x)
		if self.vel.y < 0 and isVerticalMovement then
			self.state = WALKING_UP
		elseif self.vel.y > 0 and isVerticalMovement then
			self.state = WALKING_DOWN
		elseif self.vel.x > 0 then
			self.state = WALKING_RIGHT
		elseif self.vel.x < 0 then
			self.state = WALKING_LEFT
		else
			self.state = IDLE
		end
	end
end

-- define o alvo atual do `Enemy`
function Enemy:defineTarget()
	self.target = self:getClosestPlayer()
end

---@return any
-- encontra o jogador mais próximo ao `Enemy`
function Enemy:getClosestPlayer()
	local closestDist = math.huge
	local closestPlayer = nil

	for _, p in pairs(players) do
		if dist(self.pos, p.pos) < closestDist then
			closestDist = dist(self.pos, p.pos)
			closestPlayer = p
		end
	end

	return closestPlayer
end

----------------------------------------
-- Funções de Renderização
----------------------------------------

---@param camera Camera
-- função de renderização de `Enemy`
function Enemy:draw(camera)
	if self:isInvulnerable() then
		return
	end

	local viewPos = camera:viewPos(self.pos)
	local animation = self.animations[self.state]
	local quad = animation.frames[animation.currFrame]
	local offset = {
		x = animation.frameDim.width / 2,
		y = animation.frameDim.height / 2,
	}
	love.graphics.draw(self.spriteSheets[self.state], quad, viewPos.x, viewPos.y, 0, 3, 3, offset.x, offset.y)
end
