----------------------------------------
-- Importações de Módulos
----------------------------------------
require("modules.utils.utils")
require("modules.utils.vec")
require("modules.utils.states")
require("modules.utils.shapes")
require("modules.engine.animation")
require("modules.entities.entity")
require("modules.systems.collision")
require("modules.utils.types")

----------------------------------------
-- Classe PuzzlePiece
----------------------------------------

---@class PuzzlePiece : Entity
---@field id string
---@field kind string
---@field puzzleGridManager PuzzleGridManager
---@field solid boolean
---@field state string
---@field scale number
---@field animations table<string, Animation>
---@field spriteSheets table<string, table>
---@field selectedBy table<any, boolean>

PuzzlePiece = setmetatable({}, { __index = Entity })
PuzzlePiece.__index = PuzzlePiece
PuzzlePiece.type = PUZZLE_PIECE

---@param id string
---@param pos Vec
---@param puzzleGridManager PuzzleGridManager
---@param hbs Hitboxes
function PuzzlePiece:init(id, pos, puzzleGridManager, hbs)
	local physics = physicsSettings(math.huge, 0, 1, nil, nil, nil, 0)
	Entity.init(self, id, pos, hbs, puzzleGridManager.room, physics)

	self.id = id
	self.puzzleGridManager = puzzleGridManager
	self.solid = #hbs.solids > 0
	self.state = IDLE
	self.scale = 3
	self.animations = {}
	self.spriteSheets = {}
	self.selectedBy = {}
end

---@param source any fonte responsável por manter a peça selecionada
function PuzzlePiece:select(source)
	self.selectedBy[source] = true
	self.state = SELECTED
end

---@param source any fonte que deixou de selecionar a peça
function PuzzlePiece:deselect(source)
	self.selectedBy[source] = nil

	if not next(self.selectedBy) then
		self.state = IDLE
	end
end

---@return boolean
function PuzzlePiece:isSelected()
	return next(self.selectedBy) ~= nil
end

---@param attack AtkEvent
-- encaminha qualquer ataque recebido para o puzzle responsável pela peça
function PuzzlePiece:onAttackHit(attack)
	if self.puzzleGridManager then
		self.puzzleGridManager:onPieceHit(attack.attacker, self)
	end
end

---@param centerBounds PuzzleCenterBounds
---@return boolean
function PuzzlePiece:isCorrectlyPlaced(centerBounds)
	return false
end

---@param path string
---@param state State
---@param frameDim Size
function PuzzlePiece:addSingleFrameAnimation(path, state, frameDim)
	local settings = newAnimSetting(1, frameDim, 1, true, 1, 0)
	addAnimation(self, path, state, settings)
end

---@param path string
---@param frameDim Size
function PuzzlePiece:addIdleAnimation(path, frameDim)
	self:addSingleFrameAnimation(path, IDLE, frameDim)
end

---@param path string
---@param frameDim Size
function PuzzlePiece:addSelectedAnimation(path, frameDim)
	self:addSingleFrameAnimation(path, SELECTED, frameDim)
end

---@param dt number
function PuzzlePiece:update(dt)
	self.animations[self.state]:update(dt)
end

---@param camera Camera
function PuzzlePiece:draw(camera)
	local viewX, viewY = camera:viewPos(self.pos)
	local animation = self.animations[self.state]

	love.graphics.draw(
		self.spriteSheets[self.state],
		animation.frames[animation.currFrame],
		viewX,
		viewY,
		0,
		self.scale,
		self.scale,
		animation.offset.x,
		animation.offset.y
	)
end

return PuzzlePiece
