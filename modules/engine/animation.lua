----------------------------------------
-- Importações de Módulos
----------------------------------------
require("table")

----------------------------------------
-- Classe Animation
----------------------------------------

---@class Animation
---@field frames table[]
---@field frameDur number
---@field looping boolean
---@field loopFrame number
---@field frameDim Size
---@field currFrame number
---@field timer number
---@field onFinish? function
---@field update function

Animation = {}
Animation.__index = Animation

---@param frames table[]
---@param frameDur number
---@param looping boolean
---@param loopFrame number
---@param frameDim Size
---@return Animation
-- cria uma animação com as configurações passadas como argumento
function Animation.new(frames, frameDur, looping, loopFrame, frameDim)
	local animation = setmetatable({}, Animation)

	-- atributos que variam
	animation.frames = frames -- número de frames na animação
	animation.frameDur = frameDur -- duração de cada frame em segundos
	animation.looping = looping -- se a animação é ciclica ou não
	animation.loopFrame = loopFrame -- a partir de qual frame a animação é ciclica
	animation.frameDim = frameDim -- dimensões de cada frame
	-- atributos fixos na instanciação
	animation.currFrame = 1 -- frame atual
	animation.timer = 0 -- tempo decorrido desde a última mudança de frame
	animation.onFinish = nil -- callback chamado quando a animação não-loop termina

	return animation
end

---@param dt number
-- atualiza o timer, o frame atual, e chama o callback `onFinish`
-- se for a hora
function Animation:update(dt)
	self.timer = self.timer + dt
	if self.timer > self.frameDur then
		self.timer = 0
		self.currFrame = self.currFrame + 1

		-- atingiu o fim da animação
		if self.currFrame > #self.frames then
			if self.looping then
				-- volta pro primeiro frame de loop se a animação for ciclica
				self.currFrame = self.loopFrame
			else
				-- trava no último frame e chama callback se existir
				self.currFrame = #self.frames
				if self.onFinish then
					self.onFinish(self)
				end
			end
		end
	end
end

-- volta a animação ao primeiro frame
function Animation:reset()
	self.currFrame = 1
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
	local sheetImg = love.graphics.newImage(path)
	local frames = {}
	local gap = 4
	local sWidth = sheetImg:getWidth()
	local sHeight = sheetImg:getHeight()
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
	return Animation.new(frames, settings.frameDur, settings.looping, settings.loopFrame, settings.quadSize)
end

---@class AnimSettings
---@field numFrames number
---@field quadSize Size
---@field frameDur number
---@field looping boolean
---@field loopFrame number

---@param numFrames number
---@param quadSize Size
---@param frameDur number
---@param looping boolean
---@param loopFrame number?
---@return AnimSettings
-- cria uma cofiguração de animação, usada para criar novas animações
function newAnimSetting(numFrames, quadSize, frameDur, looping, loopFrame)
	return {
		numFrames = numFrames,
		quadSize = quadSize,
		frameDur = frameDur,
		looping = looping,
		loopFrame = loopFrame,
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
	entity.animations[action] = animation
	entity.spriteSheets[action] = love.graphics.newImage(path)
end

function addAnimations(entity, pathStart, settings)
	for state, s in pairs(settings) do
		local path = pngPathFormat({ pathStart, state })
		addAnimation(entity, path, state, s)
	end
end

return Animation
