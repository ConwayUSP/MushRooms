----------------------------------------
-- Classe AssetManager
----------------------------------------

---@class AssetManager
---@field getImage function
---@field getAudio function

AssetManager = {}
AssetManager.__index = AssetManager

function AssetManager.init()
	if not assetManager then
		local am = setmetatable({}, AssetManager)
		am.imageCache = {}
		am.audioCache = {}
		am.emptyTex = love.graphics.newImage(love.image.newImageData(1, 1))
		-- !TODO: cache de fontes?
		return am
	end
end

function AssetManager:getImage(path)
	-- para nós só carregarmos as imagens do disco "uma vez"
	if self.imageCache[path] == nil then
		local ok, img = pcall(love.graphics.newImage, path)

		if not ok then
			self.imageCache[path] = false
		else
			img:setFilter("nearest", "nearest")
			self.imageCache[path] = img
		end
	end

	if self.imageCache[path] == false then
		return nil
	end

	return self.imageCache[path]
end

function AssetManager:getAudio(path, isMusic)
	-- para nós carregarmos áudios e músicas
	if not self.audioCache[path] then
		local aud = love.audio.newSource(path, isMusic and "stream" or "static")
		self.audioCache[path] = aud
	end

	return self.audioCache[path]
end

-- vai ser útil para liberar memória quando tivermos mais camadas,
-- já que a maioria dos sprites serão usados em uma camada só
function AssetManager:clearCache()
	self.imageCache = {}
	self.audioCache = {}
end
