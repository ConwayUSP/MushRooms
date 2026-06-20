----------------------------------------
-- Importações de Módulos
----------------------------------------
require("modules.systems.collision")
require("modules.entities.entity")
require("modules.utils.states")
require("modules.utils.types")
require("modules.systems.shaders")
require("table")

----------------------------------------
-- Classe Enemy
----------------------------------------

---@class Enemy : Entity
---@field hp number
---@field maxHp number
---@field move function
---@field state string
---@field spriteSheets table<string, table>
---@field animations table<string, Animation>
---@field target any
---@field atk Attack[]
---@field atkFrame number[]
---@field selectedAtk number
---@field isAttacking boolean
---@field hasTriggeredAttackThisAnim boolean
---@field attackJustStarted boolean
---@field addAnimations function
---@field setProjectileAtk function
---@field isReallyDead boolean
---@field leavesBody boolean
---@field movements? table<string, MovementFunc>

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
---@param atkFrames number[]
---@param movements? table<string, MovementFunc>
---@return Enemy
-- cria uma instância de `Enemy`
function Enemy.new(name, hp, spawnPos, physics, move, attacks, hitboxes, room, atkFrames, movements)
	---@type Enemy
	local enemy = setmetatable({}, Enemy) ---@diagnostic disable-line
	enemy:init(name, spawnPos, hitboxes, room, physics)
	enemy:becomeMortal(hp)

	-- atributos que variam
	enemy.move = move                     -- função de movimento do inimigo
	enemy.atk = attacks                   -- objetos Attack associados ao inimigo (caso possua)
	enemy.atkFrame = atkFrames            -- frames para
	-- atributos fixos na instanciação
	enemy.selectedAtk = 1                 -- o primeiro ataque começa selecionado, os posteriores são aleatórios
	enemy.state = IDLE                    -- define o estado atual do inimigo, estreitamente relacionado às animações
	enemy.spriteSheets = {}               -- no tipo imagem do love
	enemy.animations = {}                 -- as chaves são estados e os valores são Animações
	enemy.target = nil                    -- alvo atual do inimigo
	enemy.isAttacking = false             -- indica se o inimigo está atualmente atacando
	enemy.hasTriggeredAttackThisAnim = false -- garante que cada animação de ataque dispare apenas uma vez
	enemy.attackJustStarted = false       -- indica se um novo ataque acabou de começar
	enemy.defaultInvulnerableTime = 0.2   -- tempo padrão de invulnerabilidade após levar dano
	enemy.hasShadow = true                -- indica se a entidade tem sombra (pode ser usada para efeitos visuais)
	enemy.shadowWidth = 25
	enemy.isReallyDead = false -- indica se o inimigo já passou da animação de morte e pode ser considerado morto para efeitos de lógica de jogo
	enemy.leavesBody = true -- indica se o inimigo deixa um corpo após morrer (pode ser usado para efeitos visuais ou mecânicas de jogo)
	enemy.movements = movements or {} -- tabela de funções de movimento específicas para cada ataque, indexada pelo nome do ataque

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
	self.animations[DYING].onFinish = function()
		self.isReallyDead = true

		if not self.leavesBody then
			table.remove(self.room.enemies, tableIndexOf(self.room.enemies, self))
		end
	end
end

---@param anim Animation
-- inicializa a animação de ataque do inimigo, definindo seu callback `onFinish`
function Enemy:initAttackAnim(anim)
	anim.onFinish = function()
		self.isAttacking = false
		self.selectedAtk = math.random(#self.atk)
		self.hasTriggeredAttackThisAnim = false
		-- stopMovement(self)
	end
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

-- verifica se um estado é de ataque
function Enemy:isAttackState(state)
	return state == ATTACKING_UP or state == ATTACKING_DOWN or state == ATTACKING_LEFT or state == ATTACKING_RIGHT
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

-- inicia o processo de morte do inimigo
function Enemy:die()
	Entity.die(self)
end

function Enemy:updateMotion(dt)
	if self.state ~= DYING then
		if self.isAttacking then
			local movementFunc = self.movements[self.atk[self.selectedAtk].name]
			if movementFunc then
				movementFunc(self, dt)
			end
		else
			self.move(self, dt)
		end
	else
		self.deathTimer = self.deathTimer + dt
	end
end

function Enemy:updateAttackState(dt)
	self.atk[self.selectedAtk]:updateTimer(dt)
	for _, atk in pairs(self.atk) do
		atk:update(dt)
	end

	Entity.update(self, dt)
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
end

function Enemy:attack()
	-- as condições para tentar um ataque não são cumpridas
	if not self.target or not self.target.pos or not self.atk[self.selectedAtk] then
		return
	end
	if self.atk[self.selectedAtk].canAttack and not self.isAttacking then
		self.isAttacking = true
		self.attackTimer = 0
		self.hasTriggeredAttackThisAnim = false
		self.attackJustStarted = true
	end
end


---@param dt number
-- atualiza os estados do inimigo e seus ataques, além de movê-lo
function Enemy:update(dt)
	self:defineTarget()
	self:updateMotion(dt)
	self:updateAttackState(dt)
	applyPhysics(self, dt)
end

function Enemy:updateAttack()
	if self.isAttacking then
		local anim = self.animations[self.state]

		if anim.currFrame >= self.atkFrame[self.selectedAtk] and not self.hasTriggeredAttackThisAnim then
			local dir = math.atan2(self.target.pos.y - self.pos.y, self.target.pos.x - self.pos.x)
			self.atk[self.selectedAtk]:attack(self, self.pos, dir)
			self.hasTriggeredAttackThisAnim = true
		end
	end
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
	self.mortal:drawShaders()

	local viewPos = camera:viewPos(self.pos)
	local animation = self.animations[self.state]
	local quad = animation.frames[animation.currFrame]
	local p = (self.invulnerableTimer > 0 and self.state ~= DYING)
		and (self.defaultInvulnerableTime - self.invulnerableTimer) / self.defaultInvulnerableTime
		or 0
	local defaultScale = 3
	local scaleX = defaultScale - 0.6 * math.sin(2 * math.pi * p)
	local scaleY = defaultScale + 0.6 * math.sin(2 * math.pi * p)
	local offset = {
		x = animation.frameDim.width / 2,
		y = (animation.frameDim.height * scaleY - (animation.frameDim.height / 2) * defaultScale) / scaleY,
	}
	love.graphics.draw(self.spriteSheets[self.state], quad, viewPos.x, viewPos.y, 0, scaleX, scaleY, offset.x, offset.y)

	love.graphics.setShader()
	love.graphics.setColor(1, 1, 1, 1)
end
