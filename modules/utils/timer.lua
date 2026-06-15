----------------------------------------
-- Importações de Módulos
----------------------------------------
require("modules.utils.types")

----------------------------------------
-- Classe Timer
----------------------------------------

---@class Timer
---@field time number tempo atual do timer
---@field increasing boolean se for true significa que cresce ou invés de decrescer, o padrão é `false`
---@field active boolean se inativo, o timer está congelado
---@field limit number limite do timer, o padrão é `0`
---@field goingOff boolean vira true no frame exato em que o timer chegar em seu limite, funciona como um sinal
---@field callback fun(...?: any)
---@field update fun(dt: number)
---@field start fun()

Timer = {}
Timer.__index = Timer

---@param duration number
---@param increasing? boolean
---@param callback? fun(...?: any)
---@return table
-- Cria um novo timer de `limite` segundos, com uma possível função de callback atrelada
function Timer.new(duration, increasing, callback)
    local t = setmetatable({}, Timer)
    t.increasing = increasing
    t.callback = callback
    if increasing then
        t.limit = duration
        t.time = 0
    else
        t.limit = 0
        t.time = duration
    end
    t.active = false
    t.goingOff = false
    return t
end

-- atualiza o tempo do timer e seus atributos, além de possivelmente chamar um callback
function Timer:update(dt)
    -- desligando o "alarme"
    if self.goindOff then
        self.goindOff = false
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

-- começa a contagem do timer desde o início
function Timer:start()
    self.active = true
    if self.increasing then
        self.time = 0
    else
        self.time = self.duration
    end
end
