----------------------------------------
-- Importações de Módulos
----------------------------------------
require("modules.constructors.particles")
require("modules.engine.animation")
require("modules.engine.collision")
require("modules.entities.entity")
require("modules.systems.inventory")
require("modules.utils.colors")
require("modules.utils.constructors")
require("modules.utils.shapes")
require("modules.utils.states")
require("modules.utils.types")
require("modules.utils.utils")
require("modules.utils.vec")
require("table")

----------------------------------------
-- Variáveis e Enums
----------------------------------------

players = {}

----------------------------------------
-- Classe Player
----------------------------------------

---@class Player : Entity
---@field id number
---@field hp number
---@field controls table<string, string>
---@field colors Color[]
---@field speed number
---@field movementVec Vec
---@field state string
---@field spriteSheets table<string, table>
---@field animations table<string, Animation>
---@field particles table<string, ParticleSystem>
---@field weapons table[]
---@field weapon table
---@field invulnerableTimer number
---@field blinkTimer number
---@field addAnimations function
---@field addParticles function
---@field inDialogue boolean
---@field interactiveObj? Entity
---@field inventory Inventory
---@field candidateInteractives Interactive|Npc[]
---@field uiManager table

Player = setmetatable({}, { __index = Entity })
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

	local hb = hitbox(Circle.new(20))
	local hbs = hitboxes({ hb })
	player:init(name, spawnPos, hbs, room, physicsSettings(1, 9000, 12))

	-- atributos que variam
	player.id = #players + 1                   -- número do jogador
	player.hp = 100                            -- pontos de vida
	player.controls = controls                 -- os comandos para controlar o boneco, no formato {up = "", left = "", down = "", ...}
	player.colors = colors                     -- paleta de cores do jogador
	-- atributos fixos na instanciação
	player.movementVec = { x = 0, y = 0 }      -- vetor de direção e magnitude do movimento do jogador
	player.state = IDLE                        -- define o estado atual do jogador, estreitamente relacionado às animações
	player.spriteSheets = {}                   -- no tipo imagem do love
	player.animations = {}                     -- as chaves são estados e os valores são Animações
	player.particles = {}                      -- efeitos de partícula emitidos pelo player
	player.weapons = {}                        -- lista das armas que o jogador possui
	player.weapon = nil                        -- arma equipada
	player.inDialogue = false                  -- se o player está em diálogo
	player.interactiveObj = nil                -- objeto próximo ao player com o qual ele pode interagir (ex: NPC)
	player.inventory = Inventory.new(player)   -- inventário do jogador
	player.candidateInteractives = {}          -- lista de objetos interativos próximos ao jogador
	player.uiManager = newPlayerUIManager(player) -- gerenciador da UI do jogador

	collisionManager:register(player)
	return player
end

---@param idleSettings AnimSettings
---@param defSettings AnimSettings
---@param WalkSettings AnimSettings
-- adiciona animações à tabela do `Player`, associando-as aos seus estados respectivos
function Player:addAnimations(idleSettings, defSettings, WalkSettings)
	----------------- IDLE -----------------
	local path = pngPathFormat({ "assets", "animations", "players", self.name, IDLE })
	addAnimation(self, path, IDLE, idleSettings)
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

---@param dt number
-- move o `Player`, atualiza seu estado e o de suas animações e efeitos de partícula
function Player:update(dt)
	self:move(dt)
	self.animations[self.state]:update(dt)
	for _, w in pairs(self.weapons) do
		-- atualizando a animação da arma equipada
		if w == self.weapon then
			self.weapon.animations[self.weapon.state]:update(dt)
		end
		w:update(dt)
	end
	self:updateInvulnerability(dt)
	self:updateState()
	self:updateParticles(dt)
	self:resolveInteractive()
end

---@param dt number
-- movimenta o `Player` de acordo com o input do jogador
function Player:move(dt)
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

-- atualiza o estado do `Player`
function Player:updateState()
	local prevState = self.state
	local isMoving = not nullVec(self.vel)
	if love.keyboard.isDown(self.controls.act2) then
		-- só defende se está completamente parado; se não, muda de arma
		if not isMoving and not self.interactiveObj then
			if prevState ~= DEFENDING then
				self.particles[DEFENDING]:start()
			end
			self.state = DEFENDING
		end
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

---@param key string
-- verifica se o `Player` está pressionando a tecla de ação 1,
-- caso esteja em diálogo, avança o diálogo; caso contrário, chama a função de ataque dele
function Player:checkAction1(key)
	if key ~= self.controls.act1 then
		return
	end

	if self.inDialogue then
		DialogueManager:getDialogueByPlayer(self):advance()
		return
	end

	if self.weapon then
		self.weapon:attack()
	end
end

---@param key string
-- verifica se o `Player` está pressionando a tecla de ação 2
-- caso positivo, executa a ação correta dependendo do contexto
function Player:checkAction2(key)
	if key ~= self.controls.act2 then
		return
	end
	if self.interactiveObj then
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
	end
end

---@param key string
-- verifica se o `Player` está pressionando a combinação de teclas para abrir o inventário
function Player:checkSpecialActions(key)
	if key == "i" and love.keyboard.isDown(self.controls.act1) then
		self.uiManager:toggleScene(UI_INVENTORY_SCENE)
	end
	if key == "p" and love.keyboard.isDown(self.controls.act1) then
		self.room:toggleDoors()
	end
end

---@param weapon any
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

---@param item Item
-- coleta um item e o marca como coletado
function Player:collectItem(item)
	local result = false
	if item.object.type == WEAPON then
		result = self:collectWeapon(item.object)
		if result then
			self:equipWeapon(item.object.name)
		end
	elseif item.object.type == ITEM then
		result = self:collectCoin()
	elseif item.object.type == RESOURCE then
		result = self:collectResource(item.object)
	end
	if result then
		item:setCollected()
	end
end

---@param item Item
-- verifica se condições-chave para a coleta de um item
-- são verdadeiras, caso positivo, coleta o item
function Player:tryCollectItem(item)
	if not item.canPick then
		return
	end
	if item.autoPick then
		self:collectItem(item)
		return
	elseif love.keyboard.isDown(self.controls.act2) then
		self:collectItem(item)
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

---@param camera Camera
-- renderiza o `Player` na perspectiva da `camera`
function Player:draw(camera)
	-- desenhando o efeito de partículas de caminhada atrás do player
	local particles_offset = {
		x = -camera.cx + camera.viewport.width / 2,
		y = -camera.cy + camera.viewport.height / 2,
	}
	love.graphics.draw(self.particles[WALKING_UP], particles_offset.x, particles_offset.y)

	if self:isInvulnerable() then
		return
	end
	-- desenhando o player em si
	local viewPos = camera:viewPos(self.pos)
	local animation = self.animations[self.state]
	local quad = animation.frames[animation.currFrame]
	local offset = {
		x = animation.frameDim.width / 2,
		y = animation.frameDim.height / 2,
	}
	love.graphics.draw(self.spriteSheets[self.state], quad, viewPos.x, viewPos.y, 0, 3, 3, offset.x, offset.y)

	-- desenhando o efeito de partículas da defesa em cima do player
	love.graphics.draw(self.particles[DEFENDING], particles_offset.x, particles_offset.y)
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
	newCamera(players[#players])

	return true
end

return Player
