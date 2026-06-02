----------------------------------------
-- Importações de Módulos
----------------------------------------
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
---@field loop table<string> sequência padrão (loop)
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
	dialogue.loop = list.loop
	dialogue.event = list.event

	dialogue.speaker = nil
	dialogue.listener = nil

	dialogue.activeSequence = nil
	dialogue.active = false

	return dialogue
end

function Dialogue:start()
	self.active = true
	self.listener.inDialogue = true
	self.speaker.inDialogue = true

	local playerCamera = getCameraByPlayer(self.listener)
	if playerCamera then
		playerCamera:changeTarget(self.speaker)
		playerCamera.targetZoom = playerCamera.startingZoom + DIALOGUE_ZOOM
	end

	-- diálogo introdutório
	if self.intro.triggered ~= true then
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

		-- diálogo padrão (loop)
		if not self.activeSequence then
			self.activeSequence = self.loop
		end
	end

	self.activeSequence.idx = 1
	local text = self.activeSequence.text[self.activeSequence.idx]
end

function Dialogue:advance()
	if not self.active or not self.activeSequence then
		return
	end

	if self.activeSequence.idx < #self.activeSequence.text then
		self.activeSequence.idx = self.activeSequence.idx + 1
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
		local viewPos = camera:viewPos(vec(self.speaker.pos.x, self.speaker.pos.y - 120))
		local dialogueBoxImg = love.graphics.newImage("assets/sprites/UI/dialogue/dialogue_box.png")
		local width = dialogueBoxImg:getWidth()
		local padding = 20
		love.graphics.draw(dialogueBoxImg, viewPos.x, viewPos.y, 0, 3, 3, width / 2, 12)
		love.graphics.setFont(mushFont)
		local textX = viewPos.x + padding - width * 1.5
		local textWidth = width * 3 - 2 * padding
		love.graphics.printf(text, textX, viewPos.y, textWidth, "center")
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
