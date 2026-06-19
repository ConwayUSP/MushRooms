----------------------------------------
-- Importações de Módulos
----------------------------------------
require("modules.utils.types")

----------------------------------------
-- Classe Timer
----------------------------------------

---@class Timer
---@field time number
---@field increasing boolean
---@field active boolean
---@field limit number
---@field goingOff boolean
---@field callback fun(...?: any)
---@field update fun(self, dt: number)
---@field isActive fun(self): boolean
---@field start fun(self)
---@field stop fun(self)
---@field setLabel fun(self, label: string)

Timer = {}
Timer.__index = Timer

---@param duration number
---@param increasing? boolean
---@param callback? fun(...?: any)
---@return table
-- Cria um novo timer de `limite` segundos, com uma possível função de callback atrelada
function Timer.new(duration, increasing, callback)
	local t = setmetatable({}, Timer)
	t.increasing = increasing -- se for true significa que cresce ou invés de decrescer, o padrão é false
	t.duration = duration -- duração do timer
	t.limit = 0 -- limite do timer
	t.time = duration -- tempo atual do timer
	t.callback = callback -- função de callback, é chamada assim que o timer chegar ao fim
	-- se for crescente, sobrescreve o limite e o tempo
	if increasing then
		t.limit = duration
		t.time = 0
	end
	t.active = false -- se inativo, o timer está congelado
	t.goingOff = false -- vira true no frame exato em que o timer chegar em seu limite, funciona como um sinal
	return t
end

-- atualiza o tempo do timer e seus atributos, além de possivelmente chamar o callback
function Timer:update(dt)
	-- desligando o "alarme"
	if self.goingOff then
		self.goingOff = false
	end

	if not self.active then
		return
	end

	if self.increasing then
		self.time = self.time + dt
		if self.time < self.limit then
			return -- retorno precoce
		end
	else
		self.time = self.time - dt
		if self.time > self.limit then
			return -- retorno precoce
		end
	end

	-- fim dessa contagem
	self.active = false
	self.goingOff = true
	if self.callback then
		self.callback()
	end
end

-- começa a contagem do tempo desde o início, tornando o timer ativo
function Timer:start()
	self.active = true
	if self.increasing then
		self.time = 0
	else
		self.time = self.duration
	end
end

-- para de rodar o timer, mas não reseta o atributo time
function Timer:stop()
	self.active = false
end

---@param label any
-- define um textinho atrelado ao timer (como um nome), pode ser útil
-- para debugar um timer específico
function Timer:setLabel(label)
	self.label = label
end

function Timer:isActive()
    return self.active
end
