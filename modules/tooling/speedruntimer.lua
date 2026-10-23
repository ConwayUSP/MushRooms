----------------------------------------
-- Cronômetro do modo speedrun
----------------------------------------

-- liga/desliga pelo switch do menu principal (valor da sessão atual)
speedrunMode = false
-- segundos acumulados da run atual (só conta tempo de gameplay,
-- pausa e transições congelam o mundo e não somam)
speedrunTime = 0

-- zera o cronômetro para uma nova run (start/retry)
function resetSpeedrunTimer()
	speedrunTime = 0
end

---@param t number
---@return string
-- formata o tempo como M:SS.mmm
function formatSpeedrunTime(t)
	local minutes = math.floor(t / 60)
	local seconds = math.floor(t % 60)
	local millis = math.floor((t % 1) * 1000)
	return string.format("%d:%02d.%03d", minutes, seconds, millis)
end

-- desenha o cronômetro no canto superior esquerdo da janela
function drawSpeedrunTimer()
	local text = formatSpeedrunTime(speedrunTime)
	love.graphics.setFont(mushFont)
	love.graphics.setColor(0.02, 0.1, 0.12, 0.6)
	local textW = mushFont:getWidth(text) * 2
	love.graphics.rectangle("fill", 20, 15, textW + 16, 44, 6, 6)
	love.graphics.setColor(0.45, 0.75, 0.75, 1)
	love.graphics.print(text, 28, 21, 0, 2, 2)
	love.graphics.setColor(1, 1, 1, 1)
end
