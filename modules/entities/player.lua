----------------------------------------
-- Importações de Módulos
----------------------------------------
require("modules.constructors.craftings")
require("modules.engine.animation")
require("modules.engine.audiomanager")
require("modules.engine.screentransition")
require("modules.engine.vfxmanager")
require("modules.entities.mortal")
require("modules.entities.artifact")
require("modules.systems.blessing")
require("modules.systems.collision")
require("modules.systems.inventory")
require("modules.systems.inputbuffer")
require("modules.systems.control")
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
local MAX_HP = 100		-- limite de hp
local MAX_WEAPONS = 6 -- limite de armas exibidas na UI de equipamentos
local TIME_TO_SLEEP = 15 -- limite de tempo inativo até dormir
local MAX_DEFENSE_DUR = 2.5 -- limite de tempo que o player pode ficar defendendo sem parar
local DEFAULT_COOLDOWN_DUR = 2 -- limite de tempo que o player deve esperar antes de poder defender novamente

----------------------------------------
-- Classe Player
----------------------------------------

---@class Player : Mortal
---@field id number
---@field hp number
---@field maxHp number
---@field size number
---@field scale number
---@field controls Controls
---@field colors Color[]
---@field speed number
---@field movementVec Vec
---@field atkSpeed number
---@field state string
---@field spriteSheets table<string, table>
---@field animations table<string, Animation>
---@field weapons Weapon[]
---@field weapon Weapon
---@field artifacts Artifact[]
---@field artifact Artifact
---@field collectedItems table<Type, table<string, boolean>>
---@field invulnerableTimer number
---@field blinkTimer number
---@field addAnimations function
---@field inDialogue boolean
---@field inCutscene boolean
---@field interactiveObj? Entity
---@field activeInteraction? Interactive|Npc[]
---@field inventory Inventory
---@field candidateInteractives? Interactive|Npc[]
---@field uiManager table
---@field craftingManager CraftingManager
---@field blessingManager BlessingManager
---@field building any
---@field recipe any
---@field buildingModeTimer number
---@field startBuildingMode function
---@field age number
---@field defenseCooldownTimer Timer
---@field defenseDurationTimer Timer
---@field sleepTimer Timer
---@field specialMovement function
---@field sleep function

Player = setmetatable({}, { __index = Mortal })
Player.__index = Player
Player.type = PLAYER

---@param name string
---@param spawnPos Vec
---@param control table<string, string>
---@param colors Color[]
---@param room Room
---@return Player
-- cria uma instância de `Player` e o adiciona à lista global de `players`
function Player.new(name, spawnPos, control, colors, room)
	---@type Player
	local player = setmetatable({}, Player) ---@diagnostic disable-line

	player.scale = 3
	player.size = 20
	player:init(name, spawnPos, player:calcHitboxes(), room, physicsSettings(1, 9000, 12), MAX_HP)

	-- atributos que variam
	player.id = #players + 1 -- número do jogador
	player.controls = control -- o controle associado ao jogador, seja teclado ou gamepad
	player.colors = colors -- paleta de cores do jogador
	-- atributos fixos na instanciação
	player.movementVec = { x = 0, y = 0 } -- vetor de direção e magnitude do movimento do jogador
	player.state = IDLE -- define o estado atual do jogador, estreitamente relacionado às animações
	player.spriteSheets = {} -- no tipo imagem do love
	player.animations = {} -- as chaves são estados e os valores são Animações
	player.weapons = {} -- lista das armas que o jogador possui
	player.weapon = nil -- arma equipada
	player.artifacts = {} -- lista de artefatos (itens ativos) que o jogador possui
	player.artifact = nil -- artefato equipado
	player.collectedItems = {} -- itens distintos já recebidos, separados por tipo
	player.inDialogue = false -- se o player está em diálogo
	player.inCutscene = false -- se o player está em uma cutscene
	player.interactiveObj = nil -- objeto próximo ao player com o qual ele pode interagir (ex: NPC)
	player.activeInteraction = nil -- objeto com o qual o player está interagindo agora (pode ser nenhum)
	player.inventory = Inventory.new(player) -- inventário do jogador
	player.candidateInteractives = {} -- lista de objetos interativos próximos ao jogador
	player.craftingManager = newCraftingRaw(player) -- gerenciador de crafting do jogador
	player.uiManager = newPlayerUIManager(player) -- gerenciador da UI do jogador
	player.blessingManager = BlessingManager.new(player) -- gerenciador de bênçãos do jogador
	player.building = nil -- construção que o player está posicionando para construir
	player.recipe = nil -- construção que o player está posicionando para construir
	player.buildingModeTimer = 0
	-- dissolve da morte/respawn: cobre só a tela (canvas) deste player
	player.screenTransition = ScreenTransition.new()
	player.defaultInvulnerableTime = 0.25
	player.hasShadow = true -- indica se a entidade tem sombra (pode ser usada para efeitos visuais)
	player.shadowWidth = 25
	player.atkSpeed = 1 -- porcentagem de velocidade de ataque do jogador (1 = 100%)
	player.age = 0
	player.defenseCooldownTimer = Timer.new(DEFAULT_COOLDOWN_DUR)
	player.defenseDurationTimer = Timer.new(MAX_DEFENSE_DUR, true)
	player.sleepTimer = Timer.new(TIME_TO_SLEEP, true)
	player.specialMovement = nil

	collisionManager:register(player)
	return player
end

---@param idleSettings AnimSettings
---@param defSettings AnimSettings
---@param walkSettings AnimSettings
---@param dyingSettings AnimSettings
---@param sleepSettings AnimSettings
-- adiciona animações à tabela do `Player`, associando-as aos seus estados respectivos
function Player:addAnimations(idleSettings, defSettings, walkSettings, dyingSettings, sleepSettings)
	-- !TODO: refatorar o addAnimations
	-- for state, settings in pairs(animSettings) do
	-- 	local path = pngPathFormat({ "assets", "animations", "players", self.name, state })
	-- 	addAnimation(self, path, state, settings)
	-- end
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
	addAnimation(self, path, WALKING_UP, walkSettings)
	------------- WALKING DOWN -------------
	path = pngPathFormat({ "assets", "animations", "players", self.name, WALKING_DOWN })
	addAnimation(self, path, WALKING_DOWN, walkSettings)
	------------- WALKING LEFT -------------
	path = pngPathFormat({ "assets", "animations", "players", self.name, WALKING_LEFT })
	addAnimation(self, path, WALKING_LEFT, walkSettings)
	------------- WALKING RIGHT ------------
	path = pngPathFormat({ "assets", "animations", "players", self.name, WALKING_RIGHT })
	addAnimation(self, path, WALKING_RIGHT, walkSettings)
	--------------- SLEEPING ---------------
	path = pngPathFormat({ "assets", "animations", "players", self.name, SLEEPING })
	addAnimation(self, path, SLEEPING, sleepSettings)
end

function Player:calcHitboxes()
	local hb = hitbox(Circle.new(self.size))
	local hbs = hitboxes({ hb })
	return hbs
end

---@param dt number
-- move o `Player`, atualiza seu estado e o de suas animações e efeitos de partícula
function Player:update(dt)
	self.controls:update(dt)
	-- dissolve da morte/respawn deste player: o mundo segue rodando, só a
	-- tela dele escurece e o respawn acontece no ponto médio (tela coberta)
	if self.screenTransition then
		self.screenTransition:update(dt)
	end
	if self.state == DYING then
		self.candidateInteractives = {}
		self.interactiveObj = nil
		self:tryRespawn()
	else
		self:move(dt)
		self:updateBuildingPos()
		self:updateBuildingMode(dt)
		self:updateState()
		self:resolveInteractive()
		self:updateSleep(dt)
		self.uiManager:update(dt)
	end

	if self.weapon then
		local aimDir = self.controls:getAimDir()
		if aimDir then
			self.weapon:updateOrientation(aimDir)
		end
	end

	self:processInput()
	self:checkEndDefense(dt)
	Mortal.update(self, dt)
	self.age = self.age + dt
	self.animations[self.state]:update(dt)

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
	if self.state == DYING or self.uiManager:hasActiveScene() then
		return
	end

	local movementDir = vec(0, 0)
	if self.state == DEFENDING or self.inDialogue or self.inCutscene then
		return
	end

	local walkForce = nil

	if self.specialMovement then
		local endSpecialMove = self:specialMovement(dt)
		if endSpecialMove then
			self.specialMovement = nil
			-- para o risco arco-íris quando o dash termina
			globalVFXManager:stopParticle(PARTICLE_RAINBOW_DASH, self)
		end
	--	goto applyphysics
	end

	if self.controls.gamepad then
		movementDir.x, movementDir.y = self.controls:getStickDir("left")
		movementDir.x = movementDir.x or 0
		movementDir.y = movementDir.y or 0
	else
		if self.controls:checkAction(ACT_MU) then
			movementDir.y = -1
		end
		if self.controls:checkAction(ACT_MD) then
			movementDir.y = 1
		end
		if self.controls:checkAction(ACT_ML) then
			movementDir.x = -1
		end
		if self.controls:checkAction(ACT_MR) then
			movementDir.x = 1
		end
	end

	if nullVec(movementDir) then
		applyPhysics(self, dt)
		return
	end

	-- a normalização impede o movimento de ser mais rápido na diagonal
	walkForce = scaleVec(normalize(movementDir), self.speed)

	------------ HACK PARA DEBUG ------------
	if love.keyboard.isDown("lctrl") then
		walkForce = scaleVec(walkForce, 5)
	end
	-----------------------------------------

	applyForce(self, walkForce)

	--::applyphysics::

	applyPhysics(self, dt)
end

function Player:checkEndDefense(dt)
	self.defenseCooldownTimer:update(dt)
	self.defenseDurationTimer:update(dt)
	if self.defenseCooldownTimer.completed and self.defenseDurationTimer.completed then
		self.defenseDurationTimer:stop()
	end
	if (self.defenseDurationTimer.active and not self.controls:isDown(ACT_DEF)) or self.state == DYING then
		self.defenseDurationTimer:stop()
	end
end

-- atualiza o estado do `Player`
function Player:updateState()
	local prevState = self.state
	local isMoving = not nullVec(self.vel)

	if self.defenseDurationTimer.active then
		self.state = DEFENDING
		self:wakeUp()
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
			if self.state ~= SLEEPING then
				self.state = IDLE
			end
		end
	end

	-- atualizando a situação do sistema de partículas de caminhada
	if isMoving then
		self:wakeUp()
		globalVFXManager:playParticle(PARTICLE_WALKING, self, vec(0, 24), true)
	else
		if self.sleepTimer.goingOff then
			self:sleep()
		end
		globalVFXManager:stopParticle(PARTICLE_WALKING, self)
	end

	-- situações que ocorrem em troca de estado
	if self.state ~= prevState then
		-- resetando a animação anterior
		self.animations[prevState]:reset()
		-- parando efeito de partículas
		if prevState == DEFENDING then
			-- a defesa não entra em cooldown se o jogador defendeu por muito pouco tempo
			-- basicamente: perdoa missclicks ou recompensa defesas muito precisas
			if self.defenseDurationTimer.time >= 0.3 then
				self.defenseCooldownTimer:start()
			end
			globalAudioManager:stop(AUDIO_DEFENSE, self)
			globalVFXManager:stopParticle(PARTICLE_DEFENSE, self)
		end
		-- iniciando ou parando áudio de movimento
		local wasMoving = isMovementState(prevState)
		if isMoving and not wasMoving then
			globalAudioManager:play(AUDIO_MOVEMENT, self)
		elseif not isMoving and wasMoving then
			globalAudioManager:stop(AUDIO_MOVEMENT, self)
		end
	end
end

-- faz com que a construção fique na direção aproximada em que o player está olhando (considera colisões)
function Player:updateBuildingPos()
	if self.building then
		local dir = normalize(self.controls:getAimDir() or player.vel)
		local pos = addVec(self.pos, scaleVec(dir, 110))
		pos.x = math.min(math.max(pos.x, self.room.limits.p1.x + 20), self.room.limits.p2.x - 20)
		pos.y = math.min(math.max(pos.y, self.room.limits.p1.y + 20), self.room.limits.p2.y - 20)
		setPos(self.building, pos)
	end
end

-- começa o modo de construção/posicionamento de algum objeto
function Player:startBuildingMode(building, recipe)
	self.building = building
	self.recipe = recipe
	setPos(self.building, addVec(self.pos, vec(100, 0)))
	self.buildingModeTimer = 0
	self.uiManager:deactivateAllScenes()
end

function Player:updateBuildingMode(dt)
	if self.building then
		self.building:update(dt)
		self.buildingModeTimer = self.buildingModeTimer + dt
	end
end

-- posiciona a construção e
function Player:build()
	-- timer necessário para não bugar e construir imediatamente ao comprar
	if self.building and self.buildingModeTimer > 0.3 then
		self.building.actualized = true
		self.room:addBuilding(self.building)
		if self.building.name == FIRECAMP.name then
			respawnRoom = self.room.arrPos
			respawnPos = self.building.pos
		end

		self.controls.blockAttackUntilRelease = true
		self.recipe:consumeItems(self.inventory)
		self.building = nil
		self.recipe = nil
	end
end

-- sai do modo construção
function Player:endBuildingMode()
	if self.state == DYING or self.buildingModeTimer > 0.5 then
		collisionManager:unregister(self.building)
		self.building = nil
		self.buildingModeTimer = 0
	end
end

-- trata inputs de teclado. Se `key` não fizer parte dos controles do player, é ignorado
function Player:processInput()
	-- inputs que abrem UIs: abrir UI geral e abrir mapa
	-- importante: o mapa e a UI geral são excludentes, não podem ser abertos ao mesmo tempo
	if self.controls:checkAction(ACT_OUI) and not self.uiManager:isSceneActive(UI_MAP_SCENE) then
		self.uiManager:toggleScene(self.uiManager.lastPlayerScene)
		stopMovement(self)
	elseif self.controls:checkAction(ACT_MAP) and not self.uiManager:isSceneActive(self.uiManager.lastPlayerScene) then
		self.uiManager:toggleScene(UI_MAP_SCENE)
		stopMovement(self)
	end

	-- dropa o item selecionado na UI de equipamentos/inventário (ACT_DEF)
	if self.state ~= DYING and self.uiManager:hasActiveScene() and self.controls:justPressed(ACT_DEF) then
		self:dropSelectedUIItem()
		return
	end

	-- basicamente todo input é ignorado se o player está morto ou com uma UI aberta
	if self.state == DYING or self.uiManager:hasActiveScene() then
		return
	end

	-- inputs no modo de construção: confirmar construção ou cancelar
	if self.building then 
		if self.controls:checkAction(ACT_CON) then
			self:build()
		elseif self.controls:checkAction(ACT_EXT) then
			self:endBuildingMode()
		end
		return
	end

	-- avançando o diálogo ao clicar
	if self.inDialogue and self.controls:checkAction(ACT_CON) then
		DialogueManager:getDialogueByPlayer(self):advance()
		return
	end

	-- inputs de interação: interagir...
	if self.interactiveObj and self.controls:checkAction(ACT_INT) then
		if self.interactiveObj.type == NPC then
			DialogueManager:start(self.interactiveObj.dialogue, self.interactiveObj, self)
			stopMovement(self)
			return
		elseif self.interactiveObj.type == INTERACTIVE then
			-- define a interação ativa se for uma interação duradoura (como um baú, que se mantém aberto até ser fechado)
			self.activeInteraction = self.interactiveObj.onInteract and self.interactiveObj.onInteract(self.interactiveObj, self)
		end
		stopMovement(self)
	end

	-- input de uso de artefato
	if self.controls:checkAction(ACT_UA) and self.artifact then
		if not self.artifact:use() then
			self.uiManager:activateWorldScene(UI_ARTIFACT_COOLDOWN_BAR_SCENE)
		end
	end

	-- input de defesa
	if self.controls:checkAction(ACT_DEF) then
		-- tentou defender durante cooldown
		if self.defenseCooldownTimer.active then
			self.uiManager:activateWorldScene(UI_DEFENSE_COOLDOWN_BAR_SCENE)
		end

		-- se não está ativo, não completou e não está em cooldown, então ativa a defesa
		if not self.defenseDurationTimer.active and not self.defenseDurationTimer.completed and not self.defenseCooldownTimer.active then
			globalVFXManager:playParticle(PARTICLE_DEFENSE, self, vec(0, 0), true, self.colors[1], self.colors[3])
			globalAudioManager:play(AUDIO_DEFENSE, self, "defense")
			self.defenseDurationTimer:start()
			self.defenseCooldownTimer:stop()

		-- se a defesa terminou e o cooldown não terminou (e não está ativo), então inicia o cooldown
		elseif not self.defenseCooldownTimer.active and not self.defenseCooldownTimer.completed and self.defenseDurationTimer.completed then
			self.defenseCooldownTimer:start()
			self.defenseDurationTimer:stop()
		end
		return
	end

	-- input de ataque
	if self.controls:checkAction(ACT_ATK) and self.weapon and not self.inDialogue and not self.inCutscene then
		self.weapon:attack()
		self:wakeUp()
	end

	if self.state == SLEEPING then
		return
	end

	-- input de troca de arma
	if self.controls:checkAction(ACT_PW) then
		self:prevWeapon()
		self:wakeUp()
	elseif self.controls:checkAction(ACT_NW) then
		self:nextWeapon()
		self:wakeUp()
	end

	-- input de troca de artefato
	if self.controls:checkAction(ACT_CA) then
		self:changeArtifact()
	end
end

---@param dy number
function Player:wheelmoved(dy)
	if not self.weapon
		or self.state == DYING
		or self.uiManager:hasActiveScene()
		or self.inDialogue
		or self.inCutscene
		or self.state == SLEEPING
	then
		return
	end
	if dy > 0 then
		self:nextWeapon()
	else
		self:prevWeapon()
	end
	self:wakeUp()
end

---@param weapon Weapon
---@return boolean
-- adiciona uma arma ao arsenal do `Player`, mesmo que seja repetida.
-- se o arsenal estiver cheio, dropa a arma equipada para fazer espaço
function Player:collectWeapon(weapon)
	-- sem espaço: troca pela arma equipada
	if #self.weapons >= MAX_WEAPONS then
		local idx = self.weapon and tableIndexOf(self.weapons, self.weapon)
		if not idx or not self:dropWeaponAtIndex(idx) then
			return false
		end
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

-- equipa a próxima arma na ordem do inventário
function Player:nextWeapon()
	if #self.weapons == 0 then
		return
	end
	local idx = tableIndexOf(self.weapons, self.weapon) or 1
	local newIdx = math.fmod(idx, #self.weapons) + 1
	self.weapon = self.weapons[newIdx]
end

-- equipa a arma anterior na ordem do inventário
function Player:prevWeapon()
	if #self.weapons == 0 then
		return
	end
	local idx = tableIndexOf(self.weapons, self.weapon) or 1
	local newIdx = math.fmod(idx + #self.weapons - 2, #self.weapons) + 1
	self.weapon = self.weapons[newIdx]
end

function Player:unequipWeapon()
	self.weapon = nil
end

---@param artifact Artifact
---@return boolean
-- tenta coletar um artefato, retorna um booleano indicando o sucesso.
-- se o inventário estiver cheio, dropa o artefato equipado para fazer
-- espaço e equipa o novo no lugar do dropado
function Player:collectArtifact(artifact)
	if #self.artifacts >= 2 then
		-- sem espaço: troca pelo artefato equipado
		local idx = self.artifact and tableIndexOf(self.artifacts, self.artifact)
		if not idx or not self:dropArtifactAtIndex(idx) then
			return false
		end
		self.artifacts[#self.artifacts + 1] = artifact
		-- o novo artefato substitui o dropado como equipado
		self:equipArtifact(artifact.name)
		return true
	end
	self.artifacts[#self.artifacts + 1] = artifact
	return true
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

function Player:unequipArtifact()
	self.artifact = nil
end

-- troca qual artefato está equipado (entre os 2 possíveis artefatos do player)
function Player:changeArtifact()
	if #self.artifacts < 2 then
		return
	end
	local idx = tableIndexOf(self.artifacts, self.artifact) or 1
	local newIdx = 3 - idx -- inversão de 2 por 1 e 1 por 2
	self.artifact = self.artifacts[newIdx]
end

---@param resource Resource
---@return boolean
function Player:collectResource(resource)
	return self.inventory:addItem(resource)
end

---@param item Weapon|Artifact|Blessing
---@return boolean
-- registra um item distinto e retorna se ele ainda não havia sido coletado
function Player:registerCollectedItem(item)
	local itemsOfType = self.collectedItems[item.type]
	if not itemsOfType then
		itemsOfType = {}
		self.collectedItems[item.type] = itemsOfType
	end

	if itemsOfType[item.name] then
		return false
	end

	itemsOfType[item.name] = true
	return true
end

---@param item Weapon|Artifact|Blessing
-- mostra uma notificação apenas no primeiro recebimento de cada item distinto
function Player:notifyItemCollected(item)
	if not self:registerCollectedItem(item) then
		return
	end
	self.uiManager:getOverlayScene(UI_ITEM_COLLECTED_SCENE):push(item)
end

---@param drop Drop
-- coleta um drop e o marca como coletado
function Player:collectDrop(drop)
	local result = false
	if drop.object.type == WEAPON then
		result = self:collectWeapon(drop.object)
		if result then
			-- equipa a instância coletada (nomes repetidos não podem ser
			-- desambiguados por equipWeapon)
			self.weapon = drop.object
		end
	elseif drop.object.type == ARTIFACT then
		drop.object:setOwner(self)
		result = self:collectArtifact(drop.object)
	elseif drop.object.type == RESOURCE then
		result = self:collectResource(drop.object)
	elseif drop.object.type == BLESSING then
		result = self.blessingManager:equip(drop.object)
	end
	if result then
		drop:setCollected()
		globalAudioManager:play(AUDIO_COLLECT, self, "pop")
		if drop.object.type == WEAPON or drop.object.type == ARTIFACT or drop.object.type == BLESSING then
			self:notifyItemCollected(drop.object)
		end
	end
end

---@param drop Drop
-- verifica se condições-chave para a coleta de um drop
-- são verdadeiras, caso positivo, coleta o drop
function Player:tryCollectDrop(drop)
	if not drop.canPick or not drop.collectable then
		return
	end
	if drop.autoPick then
		self:collectDrop(drop)
		return
	elseif self.controls:checkAction(ACT_INT) then
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

---@param damage number
-- diminui a vida do player e treme sua câmera um pouco
function Player:takeDamage(damage)
	if self.defenseDurationTimer.active then
		damage = 0
	end

	Mortal.takeDamage(self, damage)
	getCameraByPlayer(self):shake(damage / 5, 0.5)
	globalAudioManager:play(AUDIO_GET_HIT, self, "char_hit")
end

-- tenta reespawnar quando está morto: espera a animação de morte e então
-- dissolve só a tela deste player (o mundo segue rodando). o respawn
-- acontece no ponto médio, quando a tela está totalmente coberta
function Player:tryRespawn()
	if self.deathTimer < 2 then
		return
	end

	local transition = self.screenTransition
	if not transition then
		self:respawn()
		return
	end
	if transition:isActive() then
		-- já cobrindo; o respawn roda no ponto médio
		return
	end

	transition:start({
		onMidpoint = function()
			self:respawn()
		end,
	})
end

-- volta o player para o ponto de respawn com a vida cheia
function Player:respawn()
	-- movendo player de uma sala para a outra
	self.pos = respawnPos
	collisionManager:onPlayerRoom(self, rooms[respawnRoom.y][respawnRoom.x])
	-- resetando os estados e a vida
	collisionManager:register(self)
	if #self.weapons > 0 then
		self:equipWeapon(self.weapons[1].name)
	end
	self.state = IDLE
	self.hp = MAX_HP
	self.deathTimer = 0
end

-- atualiza o foco do mapa para a sala em que o player está
function Player:onRoomChanged()
	local mapScene = self.uiManager.scenes[UI_MAP_SCENE]

	mapScene:setFocus(self.room.arrPos)
end

---@param chest Interactive
-- define o baú ativo e abre sua UI; a própria cena sincroniza os inventários
function Player:openChest(chest)
	self.uiManager.scenes[UI_CHEST_SCENE]:setChest(chest)
	self.uiManager:activateScene(UI_CHEST_SCENE)
end

---@param camera Camera
-- renderiza o `Player` na perspectiva da `camera`
function Player:draw(camera)
	-- TODO: usar algum tipo de "vinheta" na tela para indicar que o player está com pouca vida (igual no Deadly Encounter)

	-- desenhando o player em si
	local viewX, viewY = camera:viewPos(self.pos)
	local animation = self.animations[self.state]
	local p = self.invulnerableTimer > 0
			and (self.defaultInvulnerableTime - self.invulnerableTimer) / self.defaultInvulnerableTime
		or 0
	local defaultScale = self.scale
	local scaleX = defaultScale - 0.8 * math.sin(2 * math.pi * p)
	local scaleY = defaultScale + 0.8 * math.sin(2 * math.pi * p)
	local offsetX = animation.frameDim.width / 2
	local offsetY = (animation.frameDim.height * scaleY - (animation.frameDim.height / 2) * defaultScale) / scaleY

	self:drawShaders()

	local rotateOffset, angle = self:defenseShake(vec(0, 6), scaleX, scaleY)

	-- rotaciona o player em torno de um ponto de rotação (offset) para dar o efeito de "tremor" ao defender
	love.graphics.push()
	love.graphics.translate(viewX + rotateOffset.x, viewY + rotateOffset.y)
	love.graphics.rotate(angle)
	love.graphics.translate(-viewX - rotateOffset.x, -viewY - rotateOffset.y)

	love.graphics.draw(
		self.spriteSheets[self.state],
		animation.frames[animation.currFrame],
		viewX,
		viewY,
		0,
		scaleX,
		scaleY,
		offsetX,
		offsetY
	)

	love.graphics.pop()

	love.graphics.setShader()
end

function Player:defenseShake(offset, scaleX, scaleY)
	if not self.defenseDurationTimer.active then
		return vec(0, 0), 0
	end

	local shakeFunc = function(t, a)
		if t < a or t > a + 1 then
			return 0
		end

		return Easing.inOutQuart(t - a)
	end

	local k = self.defenseDurationTimer.duration - 1
	local deg = math.rad(4)
	local shake = shakeFunc(self.defenseDurationTimer.time, k)
	local angle = shake * math.sin(40 * (self.age ^ 4)) * deg

	local rotateOffset = shake > 0 and offset or vec(0, 0)
	rotateOffset = vec(scaleX * rotateOffset.x, scaleY * rotateOffset.y)

	return rotateOffset, angle
end

function Player:dropAllResources()
	for _, r in pairs(self.inventory.items[RESOURCE]) do
		local mockR = {
			name = r.name,
			type = r.type,
			image = assetManager:getImage(pngPathFormat({ "assets", "sprites", "resources", r.name }))
		}
		for i=1, r.quantity do
			spawnDrop(mockR, self.pos, self.room, true, getAnchor(self, FLOOR), {x = math.random(-500,500), y = math.random(-500,500)})
		end
		self.inventory.items[RESOURCE] = {}
	end
end

function Player:dropAllWeapons()
	for _, w in pairs(self.weapons) do
		if w.atk and w.atk.events then
			for _, e in pairs(w.atk.events) do
				collisionManager:unregister(e)
				globalVFXManager:stopEntityParticles(e)
				if e.destroy then
					e:destroy()
				end
			end
			w.atk.events = {}
		end
		spawnDrop(w, self.pos, self.room, false, getAnchor(self, FLOOR), {x = math.random(-500,500), y = math.random(-500,500)})
	end
	self:unequipWeapon()
	self.weapons = {}
end

function Player:dropAllArtifacts()
	for _, a in pairs(self.artifacts) do
		spawnDrop(a, self.pos, self.room, false, getAnchor(self, FLOOR), {x = math.random(-500,500), y = math.random(-500,500)})
	end
	self:unequipArtifact()
	self.artifacts = {}
	-- sem anéis no inventário ninguém atualiza os timers: limpa a invisibilidade
	if self.invisible and not hasActiveInvisibility(self.artifacts) then
		self.invisible = false
	end
end

function Player:dropAllBlessings()
	for _, b in pairs(self.blessingManager.equipped) do
		spawnDrop(b, self.pos, self.room, false, getAnchor(self, FLOOR), {x = math.random(-500,500), y = math.random(-500,500)})
		if b[TP_ON_UNEQUIP] then
			b[TP_ON_UNEQUIP](b, self)
		end
	end
	self.blessingManager.equipped = {}
end

---@param idx number
---@return boolean
-- dropa a arma no índice `idx` do arsenal
function Player:dropWeaponAtIndex(idx)
	local weapon = self.weapons[idx]
	if not weapon then
		return false
	end
	-- desregistra os eventos de ataque da arma
	if weapon.atk and weapon.atk.events then
		for _, e in pairs(weapon.atk.events) do
			collisionManager:unregister(e)
			globalVFXManager:stopEntityParticles(e)
			if e.destroy then
				e:destroy()
			end
		end
		weapon.atk.events = {}
	end
	-- desequipa se for a arma equipada
	local wasEquipped = self.weapon == weapon
	if wasEquipped then
		self:unequipWeapon()
	end
	table.remove(self.weapons, idx)
	-- se a dropada era a equipada e ainda sobraram armas, equipa outra automaticamente
	if wasEquipped and #self.weapons > 0 then
		self.weapon = self.weapons[math.min(idx, #self.weapons)]
	end
	spawnDrop(weapon, self.pos, self.room, false, getAnchor(self, FLOOR), {x = math.random(-500,500), y = math.random(-500,500)})
	return true
end

---@param idx number
---@return boolean
-- dropa o artefato no índice `idx`
function Player:dropArtifactAtIndex(idx)
	local artifact = self.artifacts[idx]
	if not artifact then
		return false
	end
	local wasEquipped = self.artifact == artifact
	if wasEquipped then
		self:unequipArtifact()
	end
	table.remove(self.artifacts, idx)
	-- se o dropado era o equipado e ainda sobraram artefatos, equipa outro automaticamente
	if wasEquipped and #self.artifacts > 0 then
		self.artifact = self.artifacts[math.min(idx, #self.artifacts)]
	end
	-- se o anel ativo saiu do inventário, ninguém mais atualiza o timer: limpa a invisibilidade
	if self.invisible and not hasActiveInvisibility(self.artifacts) then
		self.invisible = false
	end
	spawnDrop(artifact, self.pos, self.room, false, getAnchor(self, FLOOR), {x = math.random(-500,500), y = math.random(-500,500)})
	return true
end

---@param idx number
---@return boolean
-- dropa a benção no índice `idx`
function Player:dropBlessingAtIndex(idx)
	local blessing = self.blessingManager.equipped[idx]
	if not blessing then
		return false
	end
	self.blessingManager:unequip(blessing)
	spawnDrop(blessing, self.pos, self.room, false, getAnchor(self, FLOOR), {x = math.random(-500,500), y = math.random(-500,500)})
	return true
end

---@param idx number
-- dropa 1 unidade do recurso no índice `idx` do inventário
function Player:dropResourceAtIndex(idx)
	local resource = self.inventory.items[RESOURCE][idx]
	if not resource then
		return
	end
	local mockR = {
		name = resource.name,
		type = resource.type,
		image = assetManager:getImage(pngPathFormat({ "assets", "sprites", "resources", resource.name }))
	}
	self.inventory:subtractItem(resource)
	spawnDrop(mockR, self.pos, self.room, true, 80, {x = math.random(-200,200), y = math.random(100, 300)})
end

-- dropa o item selecionado na UI de equipamentos ou inventário aberta (ACT_DEF)
function Player:dropSelectedUIItem()
	if not self.uiManager:hasActiveScene() then
		return
	end

	if self.uiManager:isSceneActive(UI_EQUIPMENT_SCENE) then
		self:dropSelectedEquipmentItem(self.uiManager.scenes[UI_EQUIPMENT_SCENE])
	elseif self.uiManager:isSceneActive(UI_INVENTORY_SCENE) then
		self:dropSelectedInventoryItem(self.uiManager.scenes[UI_INVENTORY_SCENE])
	end
end

---@param scene UIScene
-- dropa o equipamento correspondente à célula selecionada na UI de equipamentos
function Player:dropSelectedEquipmentItem(scene)
	local pos = scene.selectionPos
	local dropped = false

	-- arma: colunas 0-1, linhas 2-4
	if (pos.x == 0 or pos.x == 1) and pos.y >= 2 and pos.y <= 4 then
		local idx = (pos.y - 2) * 2 + pos.x + 1
		dropped = self:dropWeaponAtIndex(idx)
		if dropped then
			scene:syncEquipment(WEAPON, self.weapons)
			scene:setEquipmentInUse(WEAPON, self.weapon)
		end
	-- artefato: (2,2) e (3,2)
	elseif (pos.x == 2 or pos.x == 3) and pos.y == 2 then
		local idx = pos.x - 1
		dropped = self:dropArtifactAtIndex(idx)
		if dropped then
			scene:syncEquipment(ARTIFACT, self.artifacts)
			scene:setEquipmentInUse(ARTIFACT, self.artifact)
		end
	-- benção: coluna 4, linhas 2-6
	elseif pos.x == 4 and pos.y >= 2 and pos.y <= 6 then
		local idx = pos.y - 1
		dropped = self:dropBlessingAtIndex(idx)
		if dropped then
			scene:syncEquipment(BLESSING, self.blessingManager.equipped)
		end
	end

	-- se o slot selecionado ficou vazio depois do drop, tira a seleção dele
	if dropped then
		local el = scene.layers[ELEM_LAYER_2][pos.y] and scene.layers[ELEM_LAYER_2][pos.y][pos.x]
		if not el then
			local slot = scene.layers[ELEM_LAYER_1][pos.y] and scene.layers[ELEM_LAYER_1][pos.y][pos.x]
			if slot then
				slot:deselect()
			end
		end
	end
end

---@param scene UIScene
-- dropa 1 unidade do recurso no slot selecionado na UI de inventário
function Player:dropSelectedInventoryItem(scene)
	local pos = scene.selectionPos
	-- slots (posições infelizmente hard-coded)
	if pos.x >= 1 and pos.x <= 4 and pos.y >= 2 and pos.y <= 4 then
		local slotIdx = (pos.y - 2) * 4 + pos.x
		local resourceIdx = (scene.currentPage - 1) * 12 + slotIdx
		self:dropResourceAtIndex(resourceIdx)
		-- a UI de inventário se resincroniza sozinha via revision no update
	end
end

function Player:sleep()
	self.animations[SLEEPING]:reset()
	self.state = SLEEPING
end

function Player:wakeUp()
	self.sleepTimer:restart()
	if self.state == SLEEPING then
		self.state = IDLE
	end
end

---@param dt number
function Player:updateSleep(dt)
	if self.uiManager:hasActiveScene()
		or self.inDialogue
		or self.inCutscene
		or self.activeInteraction
		or self.building then
		self:wakeUp()
		return
	end
	self.sleepTimer:update(dt)
end

----------------------------------------
-- Funções Globais
----------------------------------------

---@param gamepad table?
---@return boolean
-- inicializa o próximo jogador, caso os 4 jogadores
-- já tenham sido inicializados, retorna `false`
function newPlayer(gamepad)
	-- limite de jogadores alcançado
	if #players >= 4 then
		return false
	end

	local minID = 1
	for _, p in pairs(players) do
		if p.id - minID > 0 then
			break
		end
		minID = p.id + 1
	end

	CONSTRUCTORS[PLAYER][minID](gamepad)
	table.sort(players, function (left, right)
	    return left.id < right.id
	end)
	newCameras() -- cria novas câmeras para cada player

	return true
end

return Player
