----------------------------------------
-- Estrutura BiList
----------------------------------------
---@class BiList Uma lista que cresce para os dois lados (índices negativos ou positivos)
---@field minIndex number
---@field maxIndex number
---@field length number
BiList = {}
BiList.__index = BiList

---@return BiList
-- cria uma `BiList` vazia
function BiList.new()
	local biList = setmetatable({}, BiList)
	biList.minIndex = 0
	biList.maxIndex = -1
	biList.length = 0
	return biList
end

---@param el any
---@return nil
-- insere um valor `el` uma posição à frente de `maxIndex`
function BiList:insertRight(el)
	if el == nil then
		return
	end
	self.maxIndex = self.maxIndex + 1
	self[self.maxIndex] = el
	self.length = self.length + 1
end

---@param el any
---@return nil
-- insere um valor `el` uma posição atrás de `minIndex`
function BiList:insertLeft(el)
	if el == nil then
		return
	end
	self.minIndex = self.minIndex - 1
	self[self.minIndex] = el
	self.length = self.length + 1
end

---@param index number
---@param el any
---@return nil
-- insere um valor `el` na posição `index`
-- **cuidado:** esta função pode deixar buracos na lista
function BiList:insert(index, el)
	if el == nil then
		return
	end
	self[index] = el
	if index > self.maxIndex then
		self.maxIndex = index
	elseif index < self.minIndex then
		self.minIndex = index
	end
	self.length = self.length + 1
end

-------------------------------------------------
--- Estrutura Set
-------------------------------------------------
---@class Set Um conjunto de valores sem repetição
---@field __data table<any, any> Tabela de valores no Set
Set = {}
Set.__index = Set

---@return Set
-- cria um `Set` vazio
function Set.new()
	local set = setmetatable({ __data = {} }, Set)
	return set
end

---@param key any
---@param value any
---@return nil
-- adiciona um par chave-valor à um `Set`
function Set:add(key, value)
	self.__data[key] = value
end

---@param key any
---@return nil
-- remove uma entrada do `Set` por meio da chave (`key`)
function Set:remove(key)
	self.__data[key] = nil
end

---@param key any
---@return boolean
-- verifica se o `Set` contém um valor associado à uma chave `key`
function Set:has(key)
	return self.__data[key] ~= nil
end

---@param key any
---@return any
-- acessa um valor através de sua chave no `Set`
function Set:get(key)
	return self.__data[key]
end

---@return number
-- conta o número de elementos no `Set`
function Set:size()
	local count = 0
	for _, _ in pairs(self.__data) do
		count = count + 1
	end
	return count
end

---@return fun(): (any, any)
-- cria um iterador para os elementos do `Set`
function Set:iter()
	local k, v
	return function()
		k, v = next(self.__data, k)
		return k, v
	end
end

---@param src Set
---@return nil
-- modifica o `Set` para que fique com os mesmos elementos de `src`
function Set:copy(src)
	-- esvaziando a si mesmo primeiro
	for k, _ in self:iter() do
		self:remove(k)
	end

	for k, v in src:iter() do
		self:add(k, v)
	end
end

----------------------------------------
-- Funções para tabelas
----------------------------------------

---@param table table
---@param value any
---@return unknown
-- retorna a chave do valor `value` na tabela `table`
function tableFind(table, value)
	for k, v in pairs(table) do
		if v == value then
			return k
		end
	end
	return nil
end

---@param table table
---@param value any
---@return integer | nil
-- retorna o índice do valor `value` na tabela `table`
function tableIndexOf(table, value)
	for i, v in ipairs(table) do
		if v == value then
			return i
		end
	end
	return nil
end

---@param a table
---@param b table
-- retorna uma chave única para o par de tabelas `a` e `b`
function pairKey(a, b)
	return tostring(a) .. "|" .. tostring(b)
end

----------------------------------------
-- Funções matemáticas
----------------------------------------

---@param x number
---@param a number
---@param b number
---@return number
-- retorna `x` limitado ao intervalo `[a, b]`
function clamp(x, a, b)
	if x < a then
		return a
	end
	if x > b then
		return b
	end
	return x
end

---@param a number
---@param b number
---@param t number
---@return number
-- retorna a interpolação linear entre `a` e `b` no ponto `t`
function lerp(a, b, t)
	return a + (b - a) * t
end

---@alias range {min: number, max: number}

---@param min number
---@param max number
---@return range
-- cria uma faixa de valores com mínimo e máximo
function range(min, max)
	return { min = min, max = max }
end

---@param value number
---@param inMin number
---@param inMax number
---@param outMin number
---@param outMax number
---@return number
-- remapeia um valor em um intervalo [inMin, inMax] para [outMin, outMax]
function remap(value, inMin, inMax, outMin, outMax)
	return outMin + (value - inMin) * (outMax - outMin) / (inMax - inMin)
end

---@param x number
---@return -1 | 0 | 1
-- retorna o sinal de `x`
function sign(x)
	return (x > 0 and 1) or (x == 0 and 0) or -1
end

---@param width number
---@param height number
---@return Size
-- construtor do tipo Size
function size(width, height)
	return { width = width, height = height }
end

----------------------------------------
-- Funções de sistema de arquivos
----------------------------------------

---@param s string
---@return string
-- transforma uma string em um formato padronizado para caminhos,
-- substituindo espaços por `_` e  letras maiúsculas em minúsculas
function pathlizeName(s)
	return string.lower(string.gsub(s, " ", "_"))
end

---@param parts string[]
---@return string
-- transforma uma lista de nomes de pastas em um caminho para o diretório final
function dirPathFormat(parts)
	local path = pathlizeName(parts[1])
	for i = 2, #parts, 1 do
		path = path .. "/" .. pathlizeName(parts[i])
	end
	print(path)
	return path
end

---@param parts string[]
---@return string
-- transforma uma lista de pastas e um nome de arquivo em um caminho para o arquivo
function pngPathFormat(parts)
	local path = ""
	for i, v in ipairs(parts) do
		if i ~= #parts then
			path = path .. pathlizeName(v) .. "/"
		else
			path = path .. pathlizeName(v) .. ".png"
		end
	end
	return path
end

----------------------------------------
-- Funções de Debug
----------------------------------------

function debugTable(tableName, table)
	print("--- TABLE: " .. tableName .. " ---")
	for k, v in pairs(table) do
		print(tostring(k) .. " = " .. tostring(v))
	end
	print("----------------------------------")
end
