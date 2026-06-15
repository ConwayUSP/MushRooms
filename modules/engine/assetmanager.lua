----------------------------------------
-- Classe AssetManager
----------------------------------------

---@class AssetManager
---@field getImage function
AssetManager = {}
AssetManager.__index = AssetManager

function AssetManager.init()
	if not assetManager then
		local am = setmetatable({}, AssetManager)
		am.imageCache = {}
		-- !TODO: cache de áudio e fontes?
		return am
	end
end

function AssetManager:getImage(path)
	-- para nós só carregarmos as imagens do disco "uma vez"
	if not self.imageCache[path] then
		local img = love.graphics.newImage(path)
		img:setFilter("nearest", "nearest")
		self.imageCache[path] = img
	end

	return self.imageCache[path]
end

-- vai ser útil para liberar memória quando tivermos mais camadas,
-- já que a maioria dos sprites serão usados em uma camada só
function AssetManager.clearCache()
	self.imageCache = {}
end
