----------------------------------------
-- Importações de Módulos
----------------------------------------
require("modules.constructors.particles")
require("modules.constructors.craftings")
require("modules.engine.animation")
require("modules.entities.mortal")
require("modules.entities.artifact")
require("modules.systems.blessing")
require("modules.systems.collision")
require("modules.systems.inventory")
require("modules.systems.inputbuffer")
require("modules.utils.colors")
require("modules.utils.constructors")
require("modules.utils.shapes")
require("modules.utils.states")
require("modules.utils.timer")
require("modules.utils.types")
require("modules.utils.utils")
require("modules.utils.vec")
require("table")

----------------------------------------
-- Variáveis e Enums
----------------------------------------

players = {}
local MAX_HP = 100

----------------------------------------
-- Classe Player
----------------------------------------

---@class Player : Mortal
---@field id number
---@field hp number
---@field maxHp number
---@field size number
---@field scale number
---@field controls table<string, string>
---@field colors Color[]
---@field speed number
---@field movementVec Vec
---@field atkSpeed number
---@field state string
---@field spriteSheets table<string, table>
---@field animations table<string, Animation>
---@field particles table<string, ParticleSystem>
---@field weapons Weapon[]
---@field weapon Weapon
---@field artifacts Artifact[]
---@field artifact Artifact
---@field invulnerableTimer number
---@field blinkTimer number
---@field addAnimations function
---@field addParticles function
---@field inDialogue boolean
---@field interactiveObj? Entity
---@field inventory Inventory
---@field candidateInteractives Interactive|Npc[]
---@field uiManager table
---@field craftingManager CraftingManager
---@field blessingManager BlessingManager
---@field building any
---@field buildingModeTimer number
---@field startBuildingMode function
---@field inputBuffer InputBuffer
---@field age number
---@field defendingCooldownTimer Timer
---@field defendingDurationTimer Timer

Player = setmetatable({}, { __index = Mortal })
Player.__index = Player
Player.type = PLAYER

---@param name string
---@param spawnPos Vec
---@param controls table<string, string>
---@param colors Color[]
---@param room Room
---@return Player
-- cria uma instância de `Player` e o adiciona à lista global de `players`
function Player.new(name, spawnPos, controls, colors, room)
	---@type Player
	local player = setmetatable({}, Player) ---@diagnostic disable-line

	player.scale = 3
	player.size = 20
	player:init(name, spawnPos, player:calcHitboxes(), room, physicsSettings(1, 9000, 12), MAX_HP)

	-- atributos que variam
	player.id = #players + 1 -- número do jogador
	player.controls = controls -- os comandos para controlar o boneco, no formato {up = "", left = "", down = "", ...}
	player.colors = colors -- paleta de cores do jogador
	-- atributos fixos na instanciação
	player.movementVec = { x = 0, y = 0 } -- vetor de direção e magnitude do movimento do jogador
	player.state = IDLE -- define o estado atual do jogador, estreitamente relacionado às animações
	player.spriteSheets = {} -- no tipo imagem do love
	player.animations = {} -- as chaves são estados e os valores são Animações
	player.particles = {} -- efeitos de partícula emitidos pelo player
	player.weapons = {} -- lista das armas que o jogador possui
	player.weapon = nil -- arma equipada
	player.artifacts = {} -- lista de artefatos (itens ativos) que o jogador possui
	player.artifact = nil -- artefato equipado
	player.inDialogue = false -- se o player está em diálogo
	player.interactiveObj = nil -- objeto próximo ao player com o qual ele pode interagir (ex: NPC)
	player.inventory = Inventory.new(player) -- inventário do jogador
	player.candidateInteractives = {} -- lista de objetos interativos próximos ao jogador
	player.craftingManager = newCraftingRaw(player) -- gerenciador de crafting do jogador
	player.uiManager = newPlayerUIManager(player) -- gerenciador da UI do jogador
	player.blessingManager = BlessingManager.new(player) -- gerenciador de bênçãos do jogador
	player.building = nil -- construção que o player está posicionando para construir
	player.buildingModeTimer = 0
	player.defaultInvulnerableTime = 0.3
	player.hasShadow = true -- indica se a entidade tem sombra (pode ser usada para efeitos visuais)
	player.shadowWidth = 25
	player.inputBuffer = InputBuffer.new(player)
	player.atkSpeed = 1 -- porcentagem de velocidade de ataque do jogador (1 = 100%)
	player.age = 0
	player.defendingCooldownTimer = Timer.new(0.5)
	player.defendingDurationTimer = Timer.new(3.0, true)

	collisionManager:register(player)
	return player
end

---@param idleSettings AnimSettings
---@param defSettings AnimSettings
---@param WalkSettings AnimSettings
---@param dyingSettings AnimSettings
-- adiciona animações à tabela do `Player`, associando-as aos seus estados respectivos
function Player:addAnimations(idleSettings, defSettings, WalkSettings, dyingSettings)
	----------------- IDLE -----------------
	local path = pngPathFormat({ "assets", "animations", "players", self.name, IDLE })
	addAnimation(self, path, IDLE, idleSettings)
	----------------- DYING -----------------
	path = pngPathFormat({ "assets", "animations", "players", self.name, DYING })
	addAnimation(self, path, DYING, dyingSettings)
	--------------- DEFENDING --------------
	path = pngPathFormat({ "assets", "animations", "players", self.name, DEFENDING })
	addAnimation(self, path, DEFENDING, defSettings)
	-------------- WALKING UP --------------
	path = pngPathFormat({ "assets", "animations", "players", self.name, WALKING_UP })
	addAnimation(self, path, WALKING_UP, WalkSettings)
	------------- WALKING DOWN -------------
	path = pngPathFormat({ "assets", "animations", "players", self.name, WALKING_DOWN })
	addAnimation(self, path, WALKING_DOWN, WalkSettings)
	------------- WALKING LEFT -------------
	path = pngPathFormat({ "assets", "animations", "players", self.name, WALKING_LEFT })
	addAnimation(self, path, WALKING_LEFT, WalkSettings)
	------------- WALKING RIGHT ------------
	path = pngPathFormat({ "assets", "animations", "players", self.name, WALKING_RIGHT })
	addAnimation(self, path, WALKING_RIGHT, WalkSettings)
end

-- adiciona os efeitos de partícula à tabela do `Player`,
-- associando-os aos seus estados respectivos
function Player:addParticles()
	-- Efeito de partícula do player se defendendo
	self.particles[DEFENDING] = newDefenseParticles(self.colors[1], self.colors[3])
	-- Efeito de partícula do player caminhando
	local walkingParticles = newWalkingParticles()
	self.particles[WALKING_DOWN] = walkingParticles
	self.particles[WALKING_UP] = walkingParticles
	self.particles[WALKING_LEFT] = walkingParticles
	self.particles[WALKING_RIGHT] = walkingParticles
end

function Player:calcHitboxes()
	local hb = hitbox(Circle.new(self.size))
	local hbs = hitboxes({ hb })
	return hbs
end

---@param dt number
-- move o `Player`, atualiza seu estado e o de suas animações e efeitos de partícula
function Player:update(dt)
	if self.state == DYING then
		self.candidateInteractives = {}
		self.interactiveObj = nil
	else
		self:move(dt)
		self.inputBuffer:update(dt)
		self:updateBuildingMode(dt)
		self:updateDefense(dt)
		self:updateState()
		self:resolveInteractive()
		self.uiManager:update(dt)
	end

	Mortal.update(self, dt)
	self.age = self.age + dt
	self.animations[self.state]:update(dt)
	self:updateParticles(dt)
	self.defendingCooldownTimer:update(dt)
	self.defendingDurationTimer:update(dt)

	for _, w in pairs(self.weapons) do
		-- atualizando a animação da arma equipada
		if w == self.weapon and self.weapon.animations[self.weapon.state] then
			self.weapon.animations[self.weapon.state]:update(dt)
		end
		w:update(dt)
	end

	for _, a in pairs(self.artifacts) do
		a:update(dt)
	end
end

---@param dt number
-- movimenta o `Player` de acordo com o input do jogador
function Player:move(dt)
	if self.state == DYING or self.uiManager.activeScene then
		return
	end

	local movementDir = vec(0, 0)
	if self.state == DEFENDING or self.inDialogue then
		return
	end
	if love.keyboard.isDown(self.controls.up) then
		movementDir.y = -1
	end
	if love.keyboard.isDown(self.controls.down) then
		movementDir.y = 1
	end
	if love.keyboard.isDown(self.controls.left) then
		movementDir.x = -1
	end
	if love.keyboard.isDown(self.controls.right) then
		movementDir.x = 1
	end

	if nullVec(movementDir) then
		applyPhysics(self, dt)
		return
	end

	-- a normalização impede o movimento de ser mais rápido na diagonal
	local walkForce = scaleVec(normalize(movementDir), self.speed)

	------------ HACK PARA DEBUG ------------
	if love.keyboard.isDown("lctrl") then
		walkForce = scaleVec(walkForce, 5)
	end
	-----------------------------------------

	applyForce(self, walkForce)
	applyPhysics(self, dt)

	-- atualizando objetos cujo movimento depende do Player
	self:updateBuildingPos()
	self:updateParticlesPos()
	if self.weapon then
		-- separa a orientação da arma em dois casos para amenizar o bug ao colidir com paredes
		if not nullVec(self.vel) then
			self.weapon:updateOrientation({ x = self.vel.x, y = self.vel.y })
		else
			self.weapon:updateOrientation(movementDir)
		end
	end
end

function Player:updateDefense(dt)
	if love.keyboard.isDown(self.controls.act2) then
		self.keyPressing = self.controls.act2
		-- só defende se está completamente parado, não está interagindo e não está em cooldown
	else
		if self.keyPressing == self.controls.act2 and not self.defendingCooldownTimer.active and not self.defendingCooldownTimer.completed then
			self.keyPressing = nil
			self.defendingCooldownTimer:start()
			self.defendingDurationTimer:stop()
		end
	end
end

-- atualiza o estado do `Player`
function Player:updateState()
	local prevState = self.state
	local isMoving = not nullVec(self.vel)

	if self.defendingDurationTimer.active then
		self.state = DEFENDING
	else
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

	-- atualizando a situação do sistema de partículas de caminhada
	if isMoving then
		if self.particles[self.state] then
			self.particles[self.state]:setDirection(math.atan2(self.vel.y, self.vel.x) + math.pi)
			self.particles[self.state]:start()
		end
	else
		self.particles[WALKING_UP]:stop()
	end

	-- resetando a animação anterior, caso o estado tenha mudado
	if self.state ~= prevState then
		if prevState == DEFENDING then
			self.particles[DEFENDING]:stop()
		end
		self.animations[prevState]:reset()
	end
end

---@param dt number
-- atualiza os efeitos de partícula do `Player`
function Player:updateParticles(dt)
	self.particles[DEFENDING]:update(dt)
	-- atualiza as partículas de caminhada como um todo
	self.particles[WALKING_UP]:update(dt)
end

-- atualiza as posições dos efeitos de partícula do `Player`
function Player:updateParticlesPos()
	self.particles[DEFENDING]:setPosition(self.pos.x, self.pos.y)
	self.particles[WALKING_UP]:setPosition(self.pos.x, self.pos.y + 24)
end

-- faz com que a construção fique na direção aproximada em que o player está olhando (considera colisões)
function Player:updateBuildingPos()
	if self.building then
		setPos(self.building, addVec(self.pos, scaleVec(normalize(self.vel), 100)))
	end
end

-- começa o modo de construção/posicionamento de algum objeto
function Player:startBuildingMode(building)
	self.building = building
	setPos(self.building, addVec(self.pos, vec(100, 0)))
	self.buildingModeTimer = 0
	self.uiManager:deactivateAllScenes()
end

function Player:updateBuildingMode(dt)
	if self.building then
		self.building:update(dt)
		self.buildingModeTimer = self.buildingModeTimer + dt
		-- self:unequipWeapon()
	end
end

-- posiciona a construção e
function Player:build()
	-- timer necessário para não bugar e construir imediatamente ao comprar
	if self.building and self.buildingModeTimer > 0.5 then
		-- !TODO: consumir recursos do player
		self.building.actualized = true
		self.room:addBuilding(self.building)
		self.building = nil
	end
end

-- sai do modo construção
function Player:endBuildingMode()
	if self.buildingModeTimer > 0.5 then
		self.building = nil
		self.buildingModeTimer = 0
	end
end

---@param key any
-- trata inputs de teclado. Se `key` não fizer parte dos controles do player, é ignorado
function Player:processKeyInput(key)
	-- DEBUG -------------
	if key == "i" and self.artifact then
		self.artifact:use()
	end
	----------------------
	self:checkSpecialActions(key)
	self:checkAction1(key, false)
	self:checkAction2(key)
end

---@param key string
---@param isBuffered boolean
-- verifica se o `Player` está pressionando a tecla de ação 1, e então
-- realiza a ação correta de acordo com o contexto
function Player:checkAction1(key, isBuffered)
	-- casos em que ignoramos o input
	if key ~= self.controls.act1 or self.uiManager.activeScene or self.state == DYING then
		return
	end

	if self.building then
		self:build()
		return
	end

	-- daqui pra frente APENAS ações que não podem ser feitas
	-- quando defendendo
	if self.state == DEFENDING then
		return
	end

	-- imagino que não queremos que o buffer afete o diálogo
	if self.inDialogue and not isBuffered then
		DialogueManager:getDialogueByPlayer(self):advance()
		return
	end

	-- controlará se iremos bufferizar o input atual ou não
	local shouldBuffer = false

	if self.weapon then
		if not isBuffered then
			shouldBuffer = not self.weapon:attack()
		else
			if self.weapon:attack() then
				self.inputBuffer:pop(self.controls.act1)
			end
		end
	end

	if shouldBuffer then
		self.inputBuffer:buffer(key)
	end
end

---@param key string
-- verifica se o `Player` está pressionando a tecla de ação 2
-- caso positivo, executa a ação correta dependendo do contexto
function Player:checkAction2(key)
	if key ~= self.controls.act2 or self.uiManager.activeScene or self.state == DYING then
		return
	end
	if self.building then
		self:endBuildingMode()
	elseif self.interactiveObj then
		if self.interactiveObj.type == NPC then
			DialogueManager:start(self.interactiveObj.dialogue, self.interactiveObj, self)
			stopMovement(self)
		elseif self.interactiveObj.type == INTERACTIVE then
			self.interactiveObj.onInteract(self.interactiveObj, self)
		end
	elseif self.vel.x ~= 0 then
		local len = #self.weapons
		if len <= 1 then
			return
		end
		local indexWeapon = tableIndexOf(self.weapons, self.weapon)
		local nextIndex = indexWeapon
		-- caminha ciclicamente entre as armas
		if self.vel.x > 0 then
			nextIndex = (indexWeapon % len) + 1
		else
			nextIndex = ((indexWeapon - 2 + len) % len) + 1
		end

		self:equipWeapon(self.weapons[nextIndex].name)
	else
		if not self.defendingDurationTimer.active and not self.defendingDurationTimer.completed and not self.defendingCooldownTimer.active then
			self.particles[DEFENDING]:start()
			self.defendingDurationTimer:start()
			self.defendingCooldownTimer.completed = false
		end
	end
end

---@param key string
-- verifica se o `Player` está pressionando a combinação de teclas para abrir o inventário
function Player:checkSpecialActions(key)
	if self.state == DYING then
		return
	end

	if key == "i" and love.keyboard.isDown(self.controls.act1) then
		self.uiManager:toggleScene(UI_INVENTORY_SCENE)
	end
	if key == "c" and love.keyboard.isDown(self.controls.act1) then
		self.uiManager:toggleScene(UI_CRAFTING_SCENE)
	end
	if key == "p" and love.keyboard.isDown(self.controls.act1) then
		self.room:toggleDoors()
	end
end

---@param weapon Weapon
---@return boolean
-- adiciona uma arma ao arsenal do `Player` caso ele não a tenha
function Player:collectWeapon(weapon)
	-- previne de pegar a mesma arma novamente
	if self:hasWeapon(weapon.name) then
		return false
	end
	table.insert(self.weapons, weapon)
	weapon.owner = self
	return true
end

---@param weaponName string
-- equipa uma arma com nome `weaponName` caso o `Player` a tenha
function Player:equipWeapon(weaponName)
	for _, w in pairs(self.weapons) do
		if w.name == weaponName then
			self.weapon = w
		end
	end
end

---@param weaponName string
---@return boolean
-- verifica se o `Player` possui uma arma com nome `weaponName`
function Player:hasWeapon(weaponName)
	for _, w in pairs(self.weapons) do
		if w.name == weaponName then
			return true
		end
	end
	return false
end

function Player:unequipWeapon()
	self.weapon = nil
end

---@param artifact Artifact
---@return boolean
-- tenta coletar um artefato, retorna um booleano indicando o sucesso
function Player:collectArtifact(artifact)
	if #self.artifacts >= 2 then
		return false
	else
		self.artifacts[#self.artifacts + 1] = artifact
		return true
	end
end

---@param artifactName string
-- define um artefato de nome `artifactName` como sendo o equipado, se o jogador tiver um
function Player:equipArtifact(artifactName)
	for _, a in pairs(self.artifacts) do
		if a.name == artifactName then
			self.artifact = a
		end
	end
end

---@param artifactName string
---@return boolean
-- retorna true se o player tiver o artefato e false se ele não tiver
function Player:hasArtifact(artifactName)
	for _, a in pairs(self.artifacts) do
		if a.name == artifactName then
			return true
		end
	end
	return false
end

---@return boolean
-- coleta uma moeda; função não séria
function Player:collectCoin()
	print("moedinhaaa")
	return true
end

---@param resource Resource
---@return boolean
function Player:collectResource(resource)
	local firstResource = not self.inventory:hasItem(resource)
	local success = self.inventory:addItem(resource)
	if success and firstResource then
		self.uiManager.scenes[UI_INVENTORY_SCENE]:addResourceEl(resource, self.inventory, self.uiManager.canvasSize)
	end
	return success
end

---@param drop Drop
-- coleta um drop e o marca como coletado
function Player:collectDrop(drop)
	local result = false
	if drop.object.type == WEAPON then
		result = self:collectWeapon(drop.object)
		if result then
			self:equipWeapon(drop.object.name)
		end
	elseif drop.object.type == drop then
		result = self:collectCoin()
	elseif drop.object.type == RESOURCE then
		result = self:collectResource(drop.object)
	elseif drop.object.type == BLESSING then
		result = self.blessingManager:equip(drop.object)
	end
	if result then
		drop:setCollected()
	end
end

---@param drop Drop
-- verifica se condições-chave para a coleta de um drop
-- são verdadeiras, caso positivo, coleta o drop
function Player:tryCollectDrop(drop)
	if not drop.canPick then
		return
	end
	if drop.autoPick then
		self:collectDrop(drop)
		return
	elseif love.keyboard.isDown(self.controls.act2) then
		self:collectDrop(drop)
		return
	end
end

-- adiciona um objeto interativo candidato à lista do `Player`
function Player:considerInteractive(obj)
	table.insert(self.candidateInteractives, obj)
end

-- resolve qual objeto interativo o `Player` deve interagir
function Player:resolveInteractive()
	local old = self.interactiveObj
	local new = nil

	if #self.candidateInteractives > 0 then
		new = self:chooseBestInteractive(self.candidateInteractives)
	end

	if new ~= old then
		if old and old.onExit then
			old:onExit(self)
		end
		self.interactiveObj = new
		if new and new.onEnter then
			new:onEnter(self)
		end
	end

	self.candidateInteractives = {}
end

---@param list Interactive|Npc[]
-- escolhe o objeto interativo mais perto dentre uma lista de candidatos
function Player:chooseBestInteractive(list)
	local best = nil
	local nearest = math.huge

	for _, obj in ipairs(list) do
		local d = dist(self.pos, obj.pos)
		if d < nearest then
			nearest = d
			best = obj
		end
	end

	return best
end

function Player:takeDamage(damage)
	Mortal.takeDamage(self, damage)
	cameras[self.id]:shake(damage / 5, 0.5)
end

---@param camera Camera
-- renderiza o `Player` na perspectiva da `camera`
function Player:draw(camera)
	-- desenhando o efeito de partículas de caminhada atrás do player
	local particles_offset = {
		x = -camera.cx + camera.viewport.width / 2,
		y = -camera.cy + camera.viewport.height / 2,
	}
	love.graphics.draw(self.particles[WALKING_UP], particles_offset.x, particles_offset.y)

	-- TODO: usar algum tipo de "vinheta" na tela para indicar que o player está com pouca vida (igual no Deadly Encounter)

	-- desenhando o player em si
	local viewPos = camera:viewPos(self.pos)
	local animation = self.animations[self.state]
	local quad = animation.frames[animation.currFrame]
	local p = self.invulnerableTimer > 0
			and (self.defaultInvulnerableTime - self.invulnerableTimer) / self.defaultInvulnerableTime
		or 0
	local defaultScale = self.scale
	local scaleX = defaultScale - 0.8 * math.sin(2 * math.pi * p)
	local scaleY = defaultScale + 0.8 * math.sin(2 * math.pi * p)
	local offset = {
		x = animation.frameDim.width / 2,
		y = (animation.frameDim.height * scaleY - (animation.frameDim.height / 2) * defaultScale) / scaleY,
	}

	self:drawShaders()

	local rotateOffset, angle = self:defenseShake(vec(0, 6), scaleX, scaleY)

	-- rotaciona o player em torno de um ponto de rotação (offset) para dar o efeito de "tremor" ao defender
	love.graphics.push()
	love.graphics.translate(viewPos.x + rotateOffset.x, viewPos.y + rotateOffset.y)
	love.graphics.rotate(angle)
	love.graphics.translate(-viewPos.x - rotateOffset.x, -viewPos.y - rotateOffset.y)

	love.graphics.draw(self.spriteSheets[self.state], quad, viewPos.x, viewPos.y, 0, scaleX, scaleY, offset.x, offset.y)

	love.graphics.pop()

	-- desenhando o efeito de partículas da defesa em cima do player
	love.graphics.draw(self.particles[DEFENDING], particles_offset.x, particles_offset.y)
	love.graphics.setShader()
end

function Player:defenseShake(offset, scaleX, scaleY)
	local shakeFunc = function(t, a)
		if t < a or t > a + 1 then
			return 0
		end

		return Easing.inOutQuart(t - a)
	end

	local k = self.defendingDurationTimer.duration - 1
	local deg = math.rad(4)
	local shake = shakeFunc(self.defendingDurationTimer.time, k)
	local angle = shake * math.sin(40 * (self.age ^ 4)) * deg

	local rotateOffset = shake > 0 and offset or vec(0, 0)
	rotateOffset = vec(scaleX * rotateOffset.x, scaleY * rotateOffset.y)

	return rotateOffset, angle
end

----------------------------------------
-- Funções Globais
----------------------------------------

---@return boolean
-- inicializa o próximo jogador, caso os 4 jogadores
-- já tenham sido inicializados, retorna `false`
function newPlayer()
	-- limite de jogadores alcançado
	if #players >= 4 then
		return false
	end
	CONSTRUCTORS[PLAYER][#players + 1]()
	newCameras() -- cria novas câmeras para cada player

	return true
end

return Player
