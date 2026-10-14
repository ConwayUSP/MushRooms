----------------------------------------
-- Importações de Módulos
----------------------------------------
require("modules.entities.puzzlepiece")
require("modules.engine.tile")
require("modules.utils.easing")
require("modules.utils.vec")

----------------------------------------
-- Classe PuzzleStone
----------------------------------------

---@class PuzzleStone : PuzzlePiece
---@field cell Vec
---@field direction Vec direção da quina no sprite (x e y iguais a -1 ou 1)
---@field spritePath string
---@field moving boolean
---@field moveStart Vec?
---@field moveTarget Vec?
---@field moveFromCell Vec?
---@field targetCell Vec?
---@field moveElapsed number
---@field moveDuration number
---@field moveLink GridLink?
---@field tile Tile
---@field pinVisualOffset Vec

PuzzleStone = setmetatable({}, { __index = PuzzlePiece })
PuzzleStone.__index = PuzzleStone
PuzzleStone.KIND = "stone"
PuzzleStone.SPRITE_PATH_START = dirPathFormat({ "assets", "sprites", "puzzle", "Stone" })
PuzzleStone.PIN_PATH_START = dirPathFormat({ "assets", "sprites", "puzzle", "Pin", "Stone" })
PuzzleStone.TILE_POSITIONS = {
	["-1,-1"] = vec(1, 1),
	["1,-1"] = vec(0, 1),
	["-1,1"] = vec(1, 0),
	["1,1"] = vec(0, 0),
}
PuzzleStone.FRAME_DIM = { width = 36, height = 36 }
PuzzleStone.PIN_FRAME_DIM = { width = 36, height = 36 }
PuzzleStone.PIN_FRAME_DURATION = 0.25
PuzzleStone.MOVE_EASING = Easing.inOutQuad

---@class PuzzleStoneSettings
---@field id string identificador único dentro do puzzle
---@field cell Vec posição inicial válida e desocupada no grid
---@field direction Vec direção da quina: cada eixo deve ser -1 ou 1

---@return string
function PuzzleStone.spritePath()
	return pngPathFormat({ PuzzleStone.SPRITE_PATH_START, IDLE })
end

---@param state? State
---@return string
function PuzzleStone.pinPathForState(state)
	return pngPathFormat({ PuzzleStone.PIN_PATH_START, state or IDLE })
end

---@param settings PuzzleStoneSettings
---@param puzzleGridManager PuzzleGridManager
---@return PuzzleStone
function PuzzleStone.new(settings, puzzleGridManager)
	---@type PuzzleStone
	local stone = setmetatable({}, PuzzleStone)
	local cell = vec(settings.cell.x, settings.cell.y)
	local pos = puzzleGridManager:cellToWorld(cell)
	local defaultHb = hitbox(Rectangle.new(PuzzleGridManager.TILE_SIZE, PuzzleGridManager.TILE_SIZE))
	local solidHb = hitbox(Rectangle.new(PuzzleGridManager.TILE_SIZE, PuzzleGridManager.TILE_SIZE))
	local hbs = hitboxes({ defaultHb }, { solidHb }, {})

	PuzzlePiece.init(stone, settings.id, pos, puzzleGridManager, hbs)
	stone.kind = PuzzleStone.KIND
	stone.cell = cell
	stone.direction = vec(settings.direction.x, settings.direction.y)
	stone.spritePath = PuzzleStone.spritePath()
	stone.moving = false
	stone.moveElapsed = 0
	stone.moveDuration = 0
	stone.moveLink = nil
	stone.pinVisualOffset = vec(0, -4)

	local tilePosition = PuzzleStone.TILE_POSITIONS[stone.direction.x .. "," .. stone.direction.y]
	stone.tile = Tile.new(PuzzleStone.spritePath(), tilePosition, PuzzleStone.FRAME_DIM)
	-- as animações representam somente o pino visual sobreposto à pedra
	stone:addIdleAnimation(PuzzleStone.pinPathForState(IDLE), PuzzleStone.PIN_FRAME_DIM)
	stone:addSelectedAnimation(PuzzleStone.pinPathForState(SELECTED), PuzzleStone.PIN_FRAME_DIM)
	stone:addFinishedAnimation(PuzzleStone.pinPathForState(IDLE), PuzzleStone.PIN_FRAME_DIM, PuzzleStone.PIN_FRAME_DURATION)

	return stone
end

---@param targetCell Vec
---@param targetPos Vec
---@param duration number
---@return boolean
function PuzzleStone:moveToCell(targetCell, targetPos, duration)
	if self.moving then
		return false
	end

	self.moving = true
	self.moveStart = vec(self.pos.x, self.pos.y)
	self.moveTarget = vec(targetPos.x, targetPos.y)
	self.moveFromCell = vec(self.cell.x, self.cell.y)
	self.targetCell = vec(targetCell.x, targetCell.y)
	self.moveElapsed = 0
	self.moveDuration = duration
	self.vel = vec(0, 0)
	self.acc = vec(0, 0)

	local moveDirection = normalize(subVec(targetPos, self.pos))
	local particleOffset = scaleVec(moveDirection, -PuzzleGridManager.TILE_SIZE / 2)
	local particle = globalVFXManager:playParticle(PARTICLE_PUZZLE_STONE_MOVING, self, particleOffset, true)
	if particle then
		particle:setDirection(math.atan2(-moveDirection.y, -moveDirection.x))
	end

	return true
end

---@param dt number
function PuzzleStone:update(dt)
	PuzzlePiece.update(self, dt)

	if not self.moving then
		return
	end

	self.moveElapsed = math.min(self.moveElapsed + dt, self.moveDuration)
	local progress = self.moveElapsed / self.moveDuration
	local easedProgress = self.MOVE_EASING(progress)
	self.pos.x = lerp(self.moveStart.x, self.moveTarget.x, easedProgress)
	self.pos.y = lerp(self.moveStart.y, self.moveTarget.y, easedProgress)

	if progress >= 1 then
		self.pos = vec(self.moveTarget.x, self.moveTarget.y)
		self.cell = vec(self.targetCell.x, self.targetCell.y)
		self.moving = false
		globalVFXManager:stopParticle(PARTICLE_PUZZLE_STONE_MOVING, self)
		self.puzzleGridManager:onStoneMoveFinished(self, self.moveFromCell)
		self.moveStart = nil
		self.moveTarget = nil
		self.moveFromCell = nil
		self.targetCell = nil
		self.vel = vec(0, 0)
		self.acc = vec(0, 0)
	end
end

---@param camera Camera
function PuzzleStone:draw(camera)
	local viewX, viewY = camera:viewPos(self.pos)

	self.tile:draw(viewX, viewY, self.scale)
	PuzzlePiece.draw(self, camera, self.pinVisualOffset)
end

---@param centerBounds PuzzleCenterBounds
---@return boolean
function PuzzleStone:isCorrectlyPlaced(centerBounds)
	local expectedX = self.direction.x > 0 and centerBounds.left or centerBounds.right
	local expectedY = self.direction.y > 0 and centerBounds.top or centerBounds.bottom

	return self.cell.x == expectedX and self.cell.y == expectedY
end

return PuzzleStone
