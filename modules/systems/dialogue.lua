----------------------------------------
-- Importações de Módulos
----------------------------------------
require("modules.conditions")
require("modules.flags")
require("modules.utils.types")
require("table")

----------------------------------------
-- Variáveis
----------------------------------------

local DIALOGUE_ZOOM = 0.4

----------------------------------------
-- Classe Diálogo
----------------------------------------

---@class Dialogue
---@field intro table<string> sequência introdutória
---@field loops table<table<string>> opções de sequência em loop (sorteada a cada conversa)
---@field event table<table<string>> sequências de evento (condicionais)
---@field speaker Npc dono do diálogo
---@field listener Player jogador que está falando
---@field activeSequence table<string> sequência ativa atual
---@field active boolean se o diálogo está ativo
---@field start function começa o diálogo

Dialogue = {}
Dialogue.__index = Dialogue
Dialogue.type = DIALOGUE

---@returns Dialogue
-- cria uma nova instância de diálogo
function Dialogue.new(list)
	local dialogue = setmetatable({}, Dialogue)

	dialogue.intro = list.intro
	dialogue.loops = list.loops or {}
	dialogue.event = list.event or {}

	dialogue.speaker = nil
	dialogue.listener = nil

	dialogue.activeSequence = nil
	dialogue.active = false

	return dialogue
end

function Dialogue:start()
	-- escolhe a sequência que será exibida
	-- diálogo introdutório
	if self.intro and self.intro.triggered ~= true then
		self.activeSequence = self.intro
	else
		-- diálogos de evento (condicionais)
		for i = #self.event, 1, -1 do
			local entry = self.event[i]

			if
				entry.condition
				and entry.condition(self.listener, self.speaker, flagsTable)
				and entry.triggered ~= true
			then
				self.activeSequence = entry
			end
		end

		-- diálogo padrão (loop): sorteia uma das opções disponíveis
		if not self.activeSequence then
			self.activeSequence = self:pickLoop()
		end
	end

	-- diálogo vazio (arquivo sem falas): não ativa nada
	if not self.activeSequence then
		return
	end

	self.active = true
	self.listener.inDialogue = true
	self.speaker.inDialogue = true
	self.speaker.state = SPEAKING

	globalAudioManager:play(AUDIO_SPEAK, self.speaker, "amnuninamnuminuna")

	local playerCamera = getCameraByPlayer(self.listener)
	if playerCamera then
		playerCamera:changeTarget(self.speaker)
		playerCamera.targetZoom = playerCamera.startingZoom + DIALOGUE_ZOOM
	end

	self.activeSequence.idx = 1
end

---@return table<string>?
-- sorteia uma das opções de diálogo em loop; sem opções, repete o intro
function Dialogue:pickLoop()
	if #self.loops > 0 then
		return self.loops[math.random(#self.loops)]
	end

	return self.intro
end

function Dialogue:advance()
	if not self.active or not self.activeSequence then
		return
	end

	if self.activeSequence.idx < #self.activeSequence.text then
		self.activeSequence.idx = self.activeSequence.idx + 1
		globalAudioManager:play(AUDIO_SPEAK, self.speaker, "amnuninamnuminuna")
	else
		self:endDialogue()
	end
end

function Dialogue:endDialogue()
	if self.activeSequence.triggered ~= nil then
		self.activeSequence.triggered = true
	end

	local playerCamera = getCameraByPlayer(self.listener)
	if playerCamera then
		playerCamera:changeTarget(self.listener)
		playerCamera.targetZoom = playerCamera.startingZoom
	end

	self.listener.inDialogue = false
	self.speaker.inDialogue = false
	self.speaker.state = IDLE -- !warning: se tiver mais de dois estados no NPC, rever essa linha
	self.active = false
	self.activeSequence.idx = -1
	self.activeSequence = nil
end

function Dialogue:update(dt)
	-- reservado para efeitos (typewriter, delays, etc)
end

function Dialogue:draw(camera)
	if not self.active or not self.activeSequence then
		return
	end

	local text = self.activeSequence.text[self.activeSequence.idx]

	if self.speaker and self.speaker.pos then
		local viewX, viewY = camera:viewPos(vec(self.speaker.pos.x, self.speaker.pos.y - 120))
		local dialogueBoxImg = love.graphics.newImage("assets/sprites/UI/dialogue/dialogue_box.png")
		local width = dialogueBoxImg:getWidth()
		local padding = 20
		love.graphics.draw(dialogueBoxImg, viewX, viewY, 0, 3, 3, width / 2, 12)
		love.graphics.setFont(mushFont)
		local textX = viewX + padding - width * 1.5
		local textWidth = width * 3 - 2 * padding
		love.graphics.printf(text, textX, viewY, textWidth, "center")
	else
		love.graphics.print(text, 50, love.graphics.getHeight() - 120)
	end
end

----------------------------------------
-- Dialogue Manager
----------------------------------------

DialogueManager = {}
DialogueManager.dialogues = {}
DialogueManager.current = nil
DialogueManager.context = {}

---@param dialogue Dialogue
---@param speaker Npc
---@param listener Player
-- inicia um diálogo entre um NPC e um jogador
function DialogueManager:start(dialogue, speaker, listener)
	if self.dialogues[speaker] then
		return
	end

	self.dialogues[speaker] = dialogue

	dialogue.speaker = speaker
	dialogue.listener = listener

	dialogue:start()
end

---@param dialogue Dialogue
-- limpa um diálogo finalizado
function DialogueManager:cleanDialogue(dialogue)
	if self.dialogues[dialogue.speaker] then
		self.dialogues[dialogue.speaker] = nil
	end
end

---@param dt number
-- atualiza todos os diálogos ativos
function DialogueManager:update(dt)
	for _, dialogue in pairs(self.dialogues) do
		dialogue:update(dt)

		if not dialogue.active then
			self:cleanDialogue(dialogue)
		end
	end
end

function DialogueManager:getDialogueByPlayer(player)
	for _, dialogue in pairs(self.dialogues) do
		if dialogue.listener == player then
			return dialogue
		end
	end
	return nil
end

----------------------------------------
-- Funções auxiliares
----------------------------------------

function newSequence(text, condition)
	return {
		text = text,
		idx = -1,
		triggered = false,
		condition = condition or nil,
	}
end

-- formato de arquivo de diálogo:
--
--   [INTRO]
--   falas do diálogo de primeira conversa
--
--   [LOOP]
--   opção 1 da conversa em loop
--   (linha vazia separa as opções)
--
--   opção 2 da conversa em loop
--
--   [EVENT]
--   condicaoDaOpcaoDeEvento
--   falas do evento (linha vazia separa os eventos)
--
-- as falas de [EVENT] seguem a sintaxe antiga: a primeira linha do bloco é a
-- chave da condição em `conditionTable` e as demais são as falas exibidas
---@param path string
---@return { intro: table<string>?, loops: table<table<string>>, event: table<table<string>> }
-- lê um arquivo de diálogo com as tags [INTRO], [LOOP] e [EVENT]
function parseDialogueFile(path)
	assert(love.filesystem.getInfo(path), "Diálogo inexistente ou caminho incorreto: " .. path)

	local data = {
		intro = nil,
		loops = {},
		event = {},
	}

	-- sem nenhuma tag o arquivo é tratado como apenas intro (tolerância a
	-- arquivos no formato antigo)
	local section = "intro"
	local introLines = {}
	local currentBlock = {}

	local function closeBlock()
		if #currentBlock == 0 then
			return
		end

		if section == "loop" then
			table.insert(data.loops, newSequence(currentBlock))
		elseif section == "event" then
			local key = currentBlock[1]
			local text = { unpack(currentBlock, 2) }

			table.insert(data.event, newSequence(text, getCondition(key)))
		end

		currentBlock = {}
	end

	for line in love.filesystem.lines(path) do
		line = line:gsub("\r", "")

		if line == "[INTRO]" then
			closeBlock()
			section = "intro"
		elseif line == "[LOOP]" then
			closeBlock()
			section = "loop"
		elseif line == "[EVENT]" then
			closeBlock()
			section = "event"
		elseif line == "" then
			-- linha vazia = próximo bloco de loop/evento
			closeBlock()
		elseif section == "intro" then
			table.insert(introLines, line)
		else
			table.insert(currentBlock, line)
		end
	end
	closeBlock()

	if #introLines > 0 then
		data.intro = newSequence(introLines)
	end

	return data
end
