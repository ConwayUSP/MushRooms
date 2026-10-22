----------------------------------------
-- Importações de Módulos
----------------------------------------

----------------------------------------
-- Variáveis
----------------------------------------

-- duração total (em segundos) da transição de tela padrão
local DEFAULT_TRANSITION_DURATION = 2.5

-- shader padrão de todas as transições (nil = dissolve de shaders/transition.glsl)
-- resolvido sob demanda porque os shaders carregam depois deste arquivo
local customDefaultShader = nil

---@return Shader?|false
local function defaultShaderFor()
	if customDefaultShader ~= nil then
		return customDefaultShader
	end
	return transitionShader
end

----------------------------------------
-- Transição de Tela
----------------------------------------

---@class ScreenTransition
---@field active boolean
---@field elapsed number
---@field duration number
---@field onMidpoint function?
---@field midpointDone boolean
---@field shader Shader?|false
---@field uniforms table<string, any>
-- transição de tela em duas fases: o shader cobre a tela (fase 0), a troca
-- de mundo acontece no ponto médio e o shader revela a nova cena (fase 1).
-- uniforms enviados ao shader: progress (0..1 do total), phase (0 cobrindo,
-- 1 revelando), phaseProgress (0..1 da fase atual), time (segundos) e
-- resolution (largura, altura da tela atual, janela ou canvas).
ScreenTransition = {}
ScreenTransition.__index = ScreenTransition

---@return ScreenTransition
-- cria uma instância de transição. cada tela pode ter a sua: a global
-- (`globalScreenTransition`) cobre a janela inteira, a do player cobre
-- só o canvas da câmera dele (morte/respawn)
function ScreenTransition.new()
	---@type ScreenTransition
	local st = setmetatable({}, ScreenTransition)
	st.active = false
	st.elapsed = 0
	st.duration = DEFAULT_TRANSITION_DURATION
	st.onMidpoint = nil
	st.midpointDone = true
	st.shader = defaultShaderFor()
	st.uniforms = {}
	return st
end

---@return ScreenTransition?
function ScreenTransition.init()
	if not globalScreenTransition then
		return ScreenTransition.new()
	end
end

---@return boolean
function ScreenTransition:isActive()
	return self.active == true
end

---@param opts? table
-- inicia uma transição. opts:
--   duration   número total de segundos (padrão 0.9)
--   onMidpoint função chamada quando a tela está totalmente coberta
--   shader     Shader customizado, `false` para trocar sem efeito visual
--   uniforms   tabela nome -> valor enviada ao shader a cada frame
---@return boolean se a transição começou (false se já havia uma em andamento)
function ScreenTransition:start(opts)
	if self.active then
		return false
	end
	opts = opts or {}

	self.active = true
	self.elapsed = 0
	self.duration = math.max(0.001, opts.duration or DEFAULT_TRANSITION_DURATION)
	self.onMidpoint = opts.onMidpoint
	self.midpointDone = false
	-- `shader = false` desliga o efeito visual só nesta transição
	if opts.shader ~= nil then
		self.shader = opts.shader
	else
		self.shader = defaultShaderFor()
	end
	self.uniforms = opts.uniforms or {}

	return true
end

---@param shader Shader?|false
-- define o shader padrão de todas as próximas transições (nil volta ao dissolve,
-- `false` desliga o efeito visual por padrão)
function ScreenTransition:setShader(shader)
	customDefaultShader = shader
	if not self.active then
		self.shader = defaultShaderFor()
	end
end

function ScreenTransition:update(dt)
	if not self.active then
		return
	end

	local half = self.duration / 2
	self.elapsed = self.elapsed + dt

	-- metade da tela coberta: hora de trocar de cena
	if not self.midpointDone and self.elapsed >= half then
		self.midpointDone = true
		local onMidpoint = self.onMidpoint
		self.onMidpoint = nil
		if onMidpoint then
			onMidpoint()
		end
	end

	-- o draw encerra a transição depois do último frame; esse é o fallback
	-- para quando não há renderização (ex.: testes sem love.draw)
	if self.elapsed >= self.duration + 0.25 then
		self:finish()
	end
end

-- encerra a transição e volta ao estado inicial
function ScreenTransition:finish()
	self.active = false
	self.elapsed = 0
	self.onMidpoint = nil
	self.midpointDone = true
	self.uniforms = {}
	self.shader = defaultShaderFor()
end

---@return number
function ScreenTransition:progress()
	if self.duration <= 0 then
		return 1
	end
	return math.min(1, self.elapsed / self.duration)
end

---@return number
-- avanço dentro da fase atual (0..1), onde a fase muda no ponto médio
function ScreenTransition:phaseProgress()
	local half = self.duration / 2
	if half <= 0 then
		return 1
	end
	local phaseElapsed = self.midpointDone and (self.elapsed - half) or self.elapsed
	return math.min(1, math.max(0, phaseElapsed / half))
end

---@return number
-- 0 enquanto cobre a cena antiga, 1 enquanto revela a nova
function ScreenTransition:phase()
	return self.midpointDone and 1 or 0
end

---@param shader Shader
---@param name string
---@param value number|table
function ScreenTransition:sendUniform(shader, name, value)
	if shader:hasUniform(name) then
		shader:send(name, value)
	end
end

-- desenha o overlay da transição por cima de tudo.
-- `width`/`height` são o tamanho do alvo de desenho (janela quando não
-- passados, ou o viewport do canvas de um player na transição de morte)
---@param width? number
---@param height? number
function ScreenTransition:draw(width, height)
	if not self.active then
		return
	end

	local shader = self.shader
	if not width or not height then
		width, height = love.graphics.getDimensions()
	end

	if shader then
		self:sendUniform(shader, "progress", self:progress())
		self:sendUniform(shader, "phase", self:phase() == 1 and 1.0 or 0.0)
		self:sendUniform(shader, "phaseProgress", self:phaseProgress())
		self:sendUniform(shader, "time", self.elapsed)
		self:sendUniform(shader, "resolution", { width, height })

		-- uniforms extras pedidos pelo shader customizado
		for name, value in pairs(self.uniforms) do
			self:sendUniform(shader, name, value)
		end

		local r, g, b, a = love.graphics.getColor()
		love.graphics.setShader(shader)
		love.graphics.setColor(1, 1, 1, 1)
		love.graphics.rectangle("fill", 0, 0, width, height)
		love.graphics.setShader()
		love.graphics.setColor(r, g, b, a)
	end

	-- só encerra depois de desenhar o último frame (progresso 1),
	-- senão o shader customizado pode piscar um frame sem efeito
	if self.elapsed >= self.duration then
		self:finish()
	end
end
