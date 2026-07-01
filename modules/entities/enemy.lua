----------------------------------------
-- Importações de Módulos
----------------------------------------
require("modules.systems.collision")
require("modules.systems.targeting")
require("modules.entities.mortal")
require("modules.utils.states")
require("modules.utils.types")
require("modules.systems.shaders")
require("table")

----------------------------------------
-- Classe Enemy
----------------------------------------

---@class Enemy : Mortal
---@field hp number
---@field maxHp number
---@field move function
---@field state string
---@field room Room
---@field spriteSheets table<string, table>
---@field animations table<string, Animation>
---@field moveTargeting TargetManager
---@field atkTargeting TargetManager
---@field scale number
---@field atk Attack[]
---@field atkFrame number[]
---@field selectedAtk number
---@field isAttacking boolean
---@field hasTriggeredAttackThisAnim boolean
---@field addAnimations function
---@field setProjectileAtk function
---@field isReallyDead boolean
---@field leavesBody boolean
---@field isBoss boolean
---@field attackMoveFunc? MovementFunc
---@field movementsBuilder? table<string, fun(): MovementFunc>

Enemy = setmetatable({}, { __index = Mortal })
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
---@param movementsBuilder? table<string, fun(): MovementFunc>
---@return Enemy
-- cria uma instância de `Enemy`
function Enemy.new(name, hp, spawnPos, physics, move, attacks, hitboxes, room, atkFrames, movementsBuilder)
	---@type Enemy
	local enemy = setmetatable({}, Enemy) ---@diagnostic disable-line
	enemy:init(name, spawnPos, hitboxes, room, physics, hp)

	-- atributos que variam
	enemy.move = move                           -- função de movimento do inimigo
	enemy.atk = attacks                         -- objetos Attack associados ao inimigo (caso possua)
	enemy.atkFrame = atkFrames                  -- frames para
	enemy.room = room                           -- a sala onde o inimigo está
	-- atributos fixos na instanciação
	enemy.selectedAtk = 1                       -- o primeiro ataque começa selecionado, os posteriores são aleatórios
	enemy.state = IDLE                          -- define o estado atual do inimigo, estreitamente relacionado às animações
	enemy.spriteSheets = {}                     -- no tipo imagem do love
	enemy.animations = {}                       -- as chaves são estados e os valores são Animações
	enemy.moveTargeting = TargetManager.new(enemy) -- um gerenciador de alvo do inimigo
	enemy.atkTargeting = TargetManager.new(enemy) -- um gerenciador de alvo do inimigo
	enemy.isAttacking = false                   -- indica se o inimigo está atualmente atacando
	enemy.hasTriggeredAttackThisAnim = false    -- garante que cada animação de ataque dispare apenas uma vez
	enemy.defaultInvulnerableTime = 0.2         -- tempo padrão de invulnerabilidade após levar dano
	enemy.hasShadow = true                      -- indica se a entidade tem sombra (pode ser usada para efeitos visuais)
	enemy.shadowWidth = 25
	enemy.isReallyDead = false                  -- indica se o inimigo já passou da animação de morte e pode ser considerado morto para efeitos de lógica de jogo
	enemy.leavesBody = true                     -- indica se o inimigo deixa um corpo após morrer (pode ser usado para efeitos visuais ou mecânicas de jogo)
	enemy.movementsBuilder = movementsBuilder or {} -- tabela de construtores de funções de movimento específicas para cada ataque, indexada pelo nome do ataque
	enemy.scale = 3	-- escala padrão do inimigo
	enemy.isBoss = false -- indica se o inimigo é um chefe
	enemy.attackMoveFunc = nil -- função de movimento específica para o ataque atual, se houver

	enemy.moveTargeting:applyStrats(TC_ON_INIT)
	enemy.atkTargeting:applyStrats(TC_ON_INIT)

	table.insert(room.enemies, enemy)
	return enemy
end

---@param idleSettings AnimSettings
---@param walkingSettings AnimSettings
---@param dyingSettings AnimSettings
---@param attackSettings table<string, AnimSettings>
-- adiciona as animações dos estados dos inimigos à sua tabela de animações
function Enemy:addAnimations(idleSettings, walkingSettings, dyingSettings, attackSettings)
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

	for name, settings in pairs(attackSettings) do
		local prefix = ATTACKING .. " " .. name
		for _, dir in ipairs(DIRECTIONS) do
			local fullName = prefix .. " " .. dir

			path = pngPathFormat({ "assets", "animations", "enemies", self.name, fullName })
			local f = io.open(path, "r")

			if f then
				f:close()
				addAnimation(self, path, fullName, settings)
				self:initAttackAnim(self.animations[fullName])
			else
				path = pngPathFormat({ "assets", "animations", "enemies", self.name, prefix })
				addAnimation(self, path, fullName, settings)
				self:initAttackAnim(self.animations[fullName])
			end
		end
	end

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
		self.attackMoveFunc = nil
		self.isAttacking = false
		self.selectedAtk = math.random(#self.atk)
		self.hasTriggeredAttackThisAnim = false
	end
end

-- reseta todas as animações de ataque para o primeiro frame
function Enemy:resetAttackAnimations()
	for _, atk in ipairs(self.atk) do
		local prefix = ATTACKING .. " " .. atk.name .. " "
		for _, dir in ipairs(DIRECTIONS) do
			local fullState = prefix .. dir
			local anim = self.animations[fullState]
			if anim then
				anim:reset()
				anim.timer = 0
			end
		end
	end
end

-- verifica se um estado é de ataque
function Enemy:isAttackState()
	return self.state:startsWith(ATTACKING)
end

-- sincroniza o frame atual entre todas as animações de ataque
function Enemy:synchronizeAttackAnimations()
	if not self:isAttackState() then
		return
	end

	local sourceAnim = self.animations[self.state]
	if not sourceAnim then
		return
	end

	local activeAtk = self.atk[self.selectedAtk]
	local prefix = ATTACKING .. " " .. activeAtk.name .. " "
	for _, dir in ipairs(DIRECTIONS) do
		local fullState = prefix .. dir
		local anim = self.animations[fullState]
		if anim and anim ~= sourceAnim then
			anim.currFrame = sourceAnim.currFrame
			anim.timer = sourceAnim.timer
		end
	end
end

---@param dt number
-- atualiza os estados do inimigo e seus ataques, além de movê-lo
function Enemy:update(dt)
	Mortal.update(self, dt)

	self.moveTargeting:update(dt)
	self.atkTargeting:update(dt)
	self:updateAttack(dt)
	self:updateMotion(dt)
	self:updateState(dt)
	applyPhysics(self, dt)
end

function Enemy:updateMotion(dt)
	if self.state == DYING then
		return
	end

	if self.isAttacking then
		if not self.attackMoveFunc then
			local movementFuncBuilder = self.movementsBuilder[self.atk[self.selectedAtk].name]
			if movementFuncBuilder then
				self.attackMoveFunc = movementFuncBuilder()
			else
				self.attackMoveFunc = function(...)	end
			end
		end
		self:attackMoveFunc(dt)

	else
		self.move(self, dt)
	end

end

function Enemy:updateAttack(dt)
	self.atk[self.selectedAtk]:updateTimer(dt)
	for _, atk in pairs(self.atk) do
		atk:update(dt)
	end

	if self.state == DYING then
		return
	end

	self:tryStartAttack()
	self:tryTriggerAttack()
	self:synchronizeAttackAnimations()
end

function Enemy:tryStartAttack()
	-- as condições para tentar um ataque não são cumpridas
	if not self.atkTargeting.validTarget or not self.atk[self.selectedAtk] then
		return
	end

	if self.atk[self.selectedAtk].canAttack and not self.isAttacking then
		self.isAttacking = true
		self.attackTimer = 0
		self.hasTriggeredAttackThisAnim = false
		self:resetAttackAnimations()
		self.attackJustStarted = false
	end
end

function Enemy:tryTriggerAttack()
	local atkTargetPos = self.atkTargeting.targetPos
	if self.isAttacking and self:isAttackState() then
		local anim = self.animations[self.state]

		-- trigger do ataque baseado no frame da animação
		if anim.currFrame >= self.atkFrame[self.atk[self.selectedAtk].name] and not self.hasTriggeredAttackThisAnim then
			local dir = math.atan2(atkTargetPos.y - self.pos.y, atkTargetPos.x - self.pos.x)
			self.atk[self.selectedAtk]:attack(self, self.pos, dir)
			self.hasTriggeredAttackThisAnim = true
		end
	end
end

----------------------------------------
-- Funções de Estado
----------------------------------------

function Enemy:updateState(dt)
	if self.state == DYING then
		return
	end

	if self.atk[self.selectedAtk] and self.isAttacking then
		local dirVec = subVec(self.atkTargeting.targetPos, self.pos)

		local prefix = ATTACKING .. " " .. self.atk[self.selectedAtk].name .. " "
		local isVerticalAttack = math.abs(dirVec.y) > math.abs(dirVec.x)
		if isVerticalAttack and dirVec.y < 0 then
			self.state = prefix .. UP
		elseif isVerticalAttack and dirVec.y > 0 then
			self.state = prefix .. DOWN
		elseif not isVerticalAttack and dirVec.x > 0 then
			self.state = prefix .. RIGHT
		elseif not isVerticalAttack and dirVec.x < 0 then
			self.state = prefix .. LEFT
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

	self.animations[self.state]:update(dt)
end

----------------------------------------
-- Funções de Renderização
----------------------------------------

---@param camera Camera
-- função de renderização de `Enemy`
function Enemy:draw(camera)
	self:drawShaders()

	local viewPos = camera:viewPos(self.pos)
	local animation = self.animations[self.state]
	local quad = animation.frames[animation.currFrame]
	local p = (self.invulnerableTimer > 0 and self.state ~= DYING)
		and (self.defaultInvulnerableTime - self.invulnerableTimer) / self.defaultInvulnerableTime
		or 0
	local scaleX = self.scale - 0.6 * math.sin(2 * math.pi * p)
	local scaleY = self.scale + 0.6 * math.sin(2 * math.pi * p)
	local offset = {
		x = animation.offset.x,
		y = (animation.frameDim.height * scaleY - (animation.offset.y) * self.scale) / scaleY,
	}
	love.graphics.draw(self.spriteSheets[self.state], quad, viewPos.x, viewPos.y, 0, scaleX, scaleY, offset.x, offset.y)

	love.graphics.setShader()
	love.graphics.setColor(1, 1, 1, 1)
end
