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
---@field update fun()

AudioManager = {}
AudioManager.__index = AudioManager
AudioManager.type = AUDIO_MANAGER

function AudioManager.new(audioTypes, owner)
	local am = setmetatable({}, AudioManager)

	am.musicPlaying = nil
	am.owner = owner
	am.audios = {}
	for _, type in pairs(audioTypes) do
		local pathParts = {}
		local isMusic = type:sub(#type - 4, #type) == "music"
		if owner then
			pathParts = { "assets", "audios", owner.type, owner.name, type }
		else
			pathParts = { "assets", "audios", "global", type }
		end
		local path = isMusic and oggPathFormat(pathParts) or wavPathFormat(pathParts)
		am.audios[type] = assetManager:getAudio(path, isMusic):clone()
		am.audios[type]:setLooping(AUDIO_LOOP_TABLE[type])
	end

	return am
end

---@param audioType string
---@return nil
function AudioManager:play(audioType)
	self.audios[audioType]:play()
	self.musicPlaying = self.audios[audioType]:getType() == "stream" and audioType or self.musicPlaying
end

---@param audioType string
---@return nil
function AudioManager:stop(audioType)
	self.audios[audioType]:stop()
end

---@param audioType string
---@return nil
function AudioManager:changeMusic(audioType)
	self.audios[self.musicPlaying]:stop()
	self.audios[audioType]:play()
end

-- !TODO: Lembrar de criar uma ferramenta para destruir os áudios
-- clonados quando eles passarem a ser desnecessários