----------------------------------------
-- Importações de Módulos
----------------------------------------
require("table")

----------------------------------------
-- Classe Animation
----------------------------------------

---@class AnimationFrameCallback
---@field callback fun(animation: Animation)
---@field remainingCalls? integer

---@class Animation
---@field frames table[]
---@field frameDur number
---@field looping boolean
---@field loopFrame number
---@field frameDim Size
---@field currFrame number
---@field timer number
---@field isFinished boolean
---@field onFinish? function
---@field frameCallbacks table<number, AnimationFrameCallback>
---@field update function
---@field offset Vec

Animation = {}
Animation.__index = Animation

---@param frames table[]
---@param frameDur number
---@param looping boolean
---@param loopFrame number
---@param frameDim Size
---@param offset Vec?
---@param onFinish function?
---@return Animation
-- cria uma animação com as configurações passadas como argumento
function Animation.new(frames, frameDur, looping, loopFrame, frameDim, offset, onFinish)
	local animation = setmetatable({}, Animation)

	-- atributos que variam
	animation.frames = frames    -- número de frames na animação
	animation.frameDur = frameDur -- duração de cada frame em segundos
	animation.looping = looping  -- se a animação é ciclica ou não
	animation.loopFrame = loopFrame -- a partir de qual frame a animação é ciclica
	animation.frameDim = frameDim -- dimensões de cada frame
	animation.isFinished = false -- se a animação terminou ou não
	animation.onFinish = onFinish -- callback chamado quando a animação não-loop termina
	animation.frameCallbacks = {} -- callbacks chamados ao entrar em frames específicos
	-- atributos fixos na instanciação
	animation.currFrame = 1      -- frame atual
	animation.timer = 0          -- tempo decorrido desde a última mudança de frame

	local center = vec(frameDim.width / 2, frameDim.height / 2)
	animation.offset = offset and addVec(offset, center) or center -- offset do centro do sprite

	return animation
end

---@param frame integer
---@param callback fun(animation: Animation)
---@param callLimit? integer quantidade máxima de execuções; sem valor, executa sempre
-- registra uma ação para quando a animação entrar no frame informado
function Animation:onFrame(frame, callback, callLimit)
	if callLimit and callLimit <= 0 then
		self:offFrame(frame)
		return
	end

	self.frameCallbacks[frame] = {
		callback = callback,
		remainingCalls = callLimit,
	}
end

---@param frame integer
-- remove a ação associada ao frame informado
function Animation:offFrame(frame)
	self.frameCallbacks[frame] = nil
end

-- executa uma única vez o callback associado à entrada no frame atual
function Animation:triggerOnFrame()
	local frame = self.currFrame
	local registration = self.frameCallbacks[frame]
	if not registration then
		return
	end

	registration.callback(self)

	-- preserva alterações feitas pelo próprio callback durante sua execução
	if self.frameCallbacks[frame] ~= registration or not registration.remainingCalls then
		return
	end

	registration.remainingCalls = registration.remainingCalls - 1
	if registration.remainingCalls <= 0 then
		self.frameCallbacks[frame] = nil
	end
end

---@param dt number
-- atualiza o timer, o frame atual, e chama o callback `onFinish`
-- se for a hora
function Animation:update(dt)
	self.timer = self.timer + dt

	-- laço while + subtração (em vez de zerar o timer) garante que a duração
	-- real de cada frame seja a mesma em qualquer taxa de quadros: o excesso
	-- do timer é repassado ao próximo frame e vários frames podem avançar
	-- num único update caso o dt seja maior que frameDur. A tolerância de
	-- 1e-9 absorve o erro de ponto flutuante da soma dos dts (ex.: 60 chamadas
	-- de 1/60 não somam exatamente frameDur, deixando a animação "presa"
	-- um frame além do fim em algumas taxas de quadros)
	while self.frameDur > 0 and self.timer >= self.frameDur - 1e-9 do
		self.timer = self.timer - self.frameDur
		self.currFrame = self.currFrame + 1

		-- atingiu o fim da animação
		if self.currFrame > #self.frames then
			if self.looping then
				-- volta pro primeiro frame de loop se a animação for ciclica
				self.currFrame = self.loopFrame
				self:triggerOnFrame()
			else
				-- trava no último frame e chama callback se existir
				self.currFrame = #self.frames
				if not self.isFinished and self.onFinish then
					self.onFinish(self)
				end
				self.isFinished = true
				break
			end
		else
			self:triggerOnFrame()
		end
	end
end

-- volta a animação ao primeiro frame e a torna executável novamente
function Animation:reset()
	self.currFrame = 1
	self.timer = 0
	self.isFinished = false
end

----------------------------------------
-- Funções Globais
----------------------------------------

---@param path string
---@param settings AnimSettings
---@return Animation
-- cria uma animação com o spritesheet na localização indicada
-- por `path` e as configurações dadas por `settings`
function newAnimation(path, settings)
	local sheetImg = assetManager:getImage(path)
	local frames = {}
	local sWidth = sheetImg:getWidth()
	local sHeight = sheetImg:getHeight()
	local gap = settings.gap ~= nil and settings.gap or 4
	local qWidth = settings.quadSize.width
	local qHeight = settings.quadSize.height
	local i = 0

	for y = 0, sHeight - qHeight, qHeight + gap do
		for x = 0, sWidth - qWidth, qWidth + gap do
			i = i + 1
			if i > settings.numFrames then
				goto createanimation
			end

			table.insert(frames, love.graphics.newQuad(x, y, qWidth, qHeight, sWidth, sHeight))
		end
	end

	::createanimation::
	return Animation.new(
		frames,
		settings.frameDur,
		settings.looping,
		settings.loopFrame,
		settings.quadSize,
		settings.offset
	)
end

---@class AnimSettings
---@field numFrames number
---@field quadSize Size
---@field frameDur number
---@field looping boolean
---@field loopFrame number
---@field gap number
---@field offset Vec

---@param numFrames number
---@param quadSize Size
---@param frameDur number
---@param looping boolean
---@param loopFrame number?
---@param gap number?
---@param offset Vec?
---@param onFinish function?
---@return AnimSettings
-- cria uma cofiguração de animação, usada para criar novas animações
function newAnimSetting(numFrames, quadSize, frameDur, looping, loopFrame, gap, offset, onFinish)
	return {
		numFrames = numFrames,
		quadSize = quadSize,
		frameDur = frameDur,
		looping = looping,
		loopFrame = loopFrame or 1,
		gap = gap or 4,
		offset = offset or vec(0, 0),
		onFinish or nil,
	}
end

---@param entity any
---@param path any
---@param action any
---@param settings any
-- atrela uma animação com configuração `setting` à ação
-- `action` da entidade `entity`. `path` é o caminho para
-- o sprite sheet da animação
function addAnimation(entity, path, action, settings)
	local animation = newAnimation(path, settings)
	entity.animations = entity.animations or {}
	entity.spriteSheets = entity.spriteSheets or {}
	entity.animations[action] = animation
	entity.spriteSheets[action] = assetManager:getImage(path)
end

function addAnimations(entity, pathStart, settings)
	for state, s in pairs(settings) do
		local path = pngPathFormat({ pathStart, state })
		addAnimation(entity, path, state, s)
	end
end

return Animation
