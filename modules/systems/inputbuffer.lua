----------------------------------------
-- Classe Input Buffer
----------------------------------------

---@class InputBuffer
---@field buff table<string, number>

local BUFFER_DUR = 0.2

InputBuffer = {}
InputBuffer.__index = InputBuffer

---@param player Player
---@return InputBuffer
-- cria um `InputBuffer` para um player específico
function InputBuffer.new(player)
	local ib = setmetatable({}, InputBuffer)
	ib.player = player
	ib.buff = {} -- relaciona um input com o timer de seu buffering
	return ib
end

---@param input string
-- coloca um input e seu timer no buffer
function InputBuffer:buffer(input)
	self.buff[input] = BUFFER_DUR
end

---@param dt number
-- atualiza o timer de todos os inputs no buffer
function InputBuffer:update(dt)
	for input, timer in pairs(self.buff) do
		if timer > 0 then
			self.buff[input] = timer - dt
			self.player:checkAction1(input, true)
		end
	end
end

---@param input string
---@return boolean
-- retorna `true` se o `input` estiver ativo no buffer
function InputBuffer:pop(input)
	if self.buff[input] and self.buff[input] > 0 then
		self.buff[input] = 0
		return true
	end
	return false
end
