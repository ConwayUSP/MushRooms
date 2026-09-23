----------------------------------------
-- Importações de Módulos
----------------------------------------
require("modules.engine.assetmanager")
require("modules.utils.types")

----------------------------------------
-- Variáveis
----------------------------------------

local AUDIO_LOOP_TABLE = {
	[MUSIC_MENU] = true,
	[MUSIC_LAYER1] = true,
	[MUSIC_LAYER2] = true,
	[MUSIC_LAYER3] = true,
	[AUDIO_MOVEMENT] = true,
	[AUDIO_GET_HIT] = false,
}

-- volume específico de cada tipo de áudio (de 0 a 1).
-- se o áudio não estiver na tabela, o padrão é 1
local AUDIO_VOLUME_TABLE = {
	[MUSIC_MENU] = 0.75,
	[MUSIC_LAYER1] = 0.25,
}

-- variância no pitch/velocidade de cada áudio (de 0 a 1).
-- se o áudio não estiver na tabela, o padrão é 0
local AUDIO_PITCH_VARIANCE_TABLE = {
	[AUDIO_MOVEMENT] = 0.08,
	[AUDIO_GET_HIT] = 0.15,
}

-- limite máximo de vezes que o mesmo tipo de áudio pode tocar simultaneamente (evita estouro de volume)
local MAX_CONCURRENT_SOUNDS = 3

----------------------------------------
-- Gerenciador de Áudios
----------------------------------------

---@class AudioManager
---@field audios table<string, table>
---@field musicPlaying string
---@field owner Entity?
---@field play fun(type: string)
---@field stop fun(type: string)
---@field changeMusic fun(type: string)
---@field update fun(dt: number)

AudioManager = {}
AudioManager.__index = AudioManager
AudioManager.type = AUDIO_MANAGER

function AudioManager.init()
	if not globalAudioManager then
		local am = setmetatable({}, AudioManager)
		am.activeAudios = {} -- lista de estruturas com informações sobre os áudios ativos
		am.typeCounts = {} -- contador para o limite de áudios simultâneos
		am.musicPlaying = nil

		am.masterVolume = 1.0 -- volume geral (multiplica todos os volumes)
		am.sfxVolume = 1.0 -- volume de áudios normais (wav)
		am.musicVolume = 1.0 -- volume de músicas (ogg)

		am.musicFades = {} -- mapa de fade-in-out para áudio adaptativo
		am.targetMusic = nil
		am.fadeRate = 0

		-- configuração de atenuação do áudio espacial (ajuste conforme o tamanho das suas salas)
		love.audio.setDistanceModel("inverseclamped")
		love.audio.setPosition(0, 0, 0)

		return am
	end
end

function AudioManager:update(dt)
	-- atualizando a tabela de fades entre músicas
	if self.targetMusic and self.fadeRate > 0 then
		for audioType, currentMult in pairs(self.musicFades) do
			if audioType == self.targetMusic then
				self.musicFades[audioType] = math.min(1.0, currentMult + (self.fadeRate * dt))
			else
				self.musicFades[audioType] = math.max(0.0, currentMult - (self.fadeRate * dt))
			end
		end
	end

	for i = #self.activeAudios, 1, -1 do
		local audio = self.activeAudios[i]
		local source = audio.source

		if source:isPlaying() then
			-- atualiza posição do áudio em relação ao jogador mais próximo
			if audio.owner and audio.owner.pos then
				local closestPlayer = nil
				local minDistance = math.huge

				for _, p in pairs(players) do
					-- só calcula se o player estiver vivo (evita focar áudio em um defunto)
					if p.state ~= DYING then
						local d = dist(audio.owner.pos, p.pos)
						if d < minDistance then
							minDistance = d
							closestPlayer = p
						end
					end
				end

				if closestPlayer then
					local relX = audio.owner.pos.x - closestPlayer.pos.x
					local relY = audio.owner.pos.y - closestPlayer.pos.y
					source:setPosition(relX, relY, 0)
				else
					-- fallback caso todos estejam mortos
					source:setPosition(0, 0, 0)
				end
			end

			-- verificando se o áudio loopou para randomizar o pitch
			if audio.hasVariance and source:isLooping() then
				local currentPos = source:tell()
				if currentPos < audio.lastPos then
					local variance = AUDIO_PITCH_VARIANCE_TABLE[audio.type]
					local newPitch = 1.0 + (math.random() * 2 - 1) * variance
					source:setPitch(newPitch)
				end
				audio.lastPos = currentPos
			end

			-- atualizando o volume de acordo com o fade
			if audio.isMusic then
				local fadeMult = self.musicFades[audio.type] or 1.0
				-- parando a música se o fade-out zerou
				if fadeMult <= 0 and audio.type ~= self.targetMusic then
					source:stop()
				else
					local baseVol = AUDIO_VOLUME_TABLE[audio.type] or 1.0
					source:setVolume(baseVol * self.musicVolume * self.masterVolume * fadeMult)
				end
			end
		else
			-- limpeza
			self.typeCounts[audio.type] = self.typeCounts[audio.type] - 1
			if audio.isMusic then
				self.musicFades[audio.type] = nil
			end
			table.remove(self.activeAudios, i)
		end
	end
end

---@param audioType string
---@param owner Entity?
---@param path string?
-- para compartilhar áudios, podemos passar um path relativo a `assets/audios/shared`
function AudioManager:play(audioType, owner, path)
	-- verifica limite de concorrência
	self.typeCounts[audioType] = self.typeCounts[audioType] or 0
	if self.typeCounts[audioType] >= MAX_CONCURRENT_SOUNDS then
		return
	end

	local pathParts = { "assets", "audios" }
	local isMusic = audioType:sub(#audioType - 4, #audioType) == "music"
	if path then
		table.insert(pathParts, "shared")
		table.insert(pathParts, path)
	else
		if owner then
			table.insert(pathParts, owner.type)
			table.insert(pathParts, owner.name)
			table.insert(pathParts, audioType)
		else
			table.insert(pathParts, "global")
			table.insert(pathParts, audioType)
		end
	end
	local finalPath = isMusic and oggPathFormat(pathParts) or wavPathFormat(pathParts)

	-- clonando do assetManager
	local baseSource = assetManager:getAudio(finalPath, isMusic)
	if not baseSource then
		return
	end

	local clone = baseSource:clone()
	clone:setLooping(AUDIO_LOOP_TABLE[audioType] or false)

	-- ajusta o volume específico do áudio e da categoria
	local baseVolume = AUDIO_VOLUME_TABLE[audioType] or 1.0
	local categoryVolume = isMusic and self.musicVolume or self.sfxVolume
	local fadeMultiplier = self.musicFades[audioType] or 1.0
	clone:setVolume(baseVolume * categoryVolume * self.masterVolume * fadeMultiplier)

	local variance = AUDIO_PITCH_VARIANCE_TABLE[audioType]
	if variance then
		local pitch = 1.0 + (math.random() * 2 - 1) * variance
		clone:setPitch(pitch)
	end

	-- áudio posicional
	if owner and not isMusic then
		clone:setAttenuationDistances(100, 1000)
	end

	-- toca e registra na pool
	clone:play()
	table.insert(self.activeAudios, {
		source = clone,
		type = audioType,
		owner = owner,
		lastPos = clone:tell(),
		hasVariance = variance ~= nil,
		isMusic = isMusic,
	})
	self.typeCounts[audioType] = self.typeCounts[audioType] + 1

	if isMusic then
		self.musicPlaying = audioType
	end
end

---@param audioType string
---@param owner Entity?
function AudioManager:stop(audioType, owner)
	for i = #self.activeAudios, 1, -1 do
		local audio = self.activeAudios[i]
		if audio.type == audioType and audio.owner == owner then
			audio.source:stop()
			self.typeCounts[audio.type] = self.typeCounts[audio.type] - 1
			table.remove(self.activeAudios, i)
		end
	end
end

---@param owner Entity
-- para os áudios de uma entidade que morreu/foi destruída
function AudioManager:stopAllFrom(owner)
	for i = #self.activeAudios, 1, -1 do
		local audio = self.activeAudios[i]
		if audio.owner == owner then
			audio.source:stop()
			self.typeCounts[audio.type] = self.typeCounts[audio.type] - 1
			table.remove(self.activeAudios, i)
		end
	end
end

---@param audioType string
---@param fadeDuration number
function AudioManager:changeMusic(audioType, fadeDuration)
	fadeDuration = fadeDuration or 2.0
	self.fadeRate = 1.0 / fadeDuration
	self.targetMusic = audioType

	local isPlaying = false

	for _, audio in ipairs(self.activeAudios) do
		if audio.isMusic then
			-- se não estava no mapa de fade (iniciou direto pelo play), assume 1.0
			self.musicFades[audio.type] = self.musicFades[audio.type] or 1.0
			if audio.type == audioType then
				isPlaying = true
			end
		end
	end

	-- se a nova música não estiver tocando, adiciona no mapa zerada (fade-in) e dá play
	if not isPlaying then
		self.musicFades[audioType] = 0.0
		self:play(audioType)
	end
end
