local bit = require("bit")

---@alias RNG table

---@param str string
---@return number
-- transforma uma string com um número em base 36 (0-9A-Z) para um número em base 10
function base36to10(str)
	local str = str:upper()
	local sum = 0
	for i = #str, 1, -1 do
		local n = tonumber(str:sub(i, i))
		if not n then
			n = str:byte(i, i) - 55 -- em ASCII, A = 65, então vira 10
		end
		sum = sum + n * math.pow(36, #str - i)
	end
	return sum
end

---@param seed string
function setWorldSeed(seed)
	if not seed or #seed == 0 then
		setWorldSeed(DEFAULT_WORLD_SEED)
	else
		worldSeedText = seed
		worldSeed = base36to10(seed)
	end
end

---@param globalSeed number
---@param x number
---@param y number
---@return number
function getRoomSeed(globalSeed, x, y)
	local prime1 = 73856093
	local prime2 = 19349663
	local prime3 = 83492791

	local h1 = bit.bxor(globalSeed * prime1, x * prime2)
	return bit.bxor(h1, y * prime3)
end
