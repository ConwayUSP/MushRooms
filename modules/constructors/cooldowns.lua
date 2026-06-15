----------------------------------------
-- Construtores de Cooldowns
----------------------------------------

---@param dur number
---@return function
-- gera um cooldown constante
function constCooldown(dur)
	local cd = function()
		return dur
	end
	return cd
end

---@param durList number[]
---@return function
-- cooldown que percorre uma lista de durações
function multiCooldown(durList)
	local counter = -1
	local cd = function()
		counter = counter + 1
		return durList[math.fmod(counter, #durList) + 1]
	end
	return cd
end

---@param minDur number
---@param maxDur number
---@return function
-- retorna um cooldown que seleciona uma duração aleatória entre `minDur` e `maxDur`
function randCooldown(minDur, maxDur)
	local cd = function()
		-- multiplicando e dividindo para gerar cooldowns com casas decimais
		return math.random(minDur * 100, maxDur * 100) / 100
	end
	return cd
end

---@param durList number[]
---@return function
-- cooldown que seleciona elementos aleatórios da lista de durações
function randMultiCooldown(durList)
	local cd = function()
		return durList[math.random(#durList)]
	end
	return cd
end
