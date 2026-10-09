----------------------------------------
-- Importações de Módulos
----------------------------------------
require("modules.entities.puzzlepiece")
require("modules.utils.vec")

----------------------------------------
-- Classe PuzzlePin
----------------------------------------

---@class PuzzlePin : PuzzlePiece
---@field offset Vec
---@field pullDirection Vec

PuzzlePin = setmetatable({}, { __index = PuzzlePiece })
PuzzlePin.__index = PuzzlePin
PuzzlePin.KIND = "pin"
PuzzlePin.SPRITE_PATH_START = dirPathFormat({ "assets", "sprites", "puzzle", "Pin" })
PuzzlePin.FRAME_DIM = { width = 49, height = 49 }

---@param state State
---@return string
function PuzzlePin.spritePathForState(state)
	return pngPathFormat({ PuzzlePin.SPRITE_PATH_START, state })
end

---@class PuzzlePinSettings
---@field id string identificador único dentro do puzzle
---@field offset Vec posição do pino relativa ao centro do grid
---@field pullDirection Vec direção cardinal unitária para a qual o pino puxará a pedra

---@param settings PuzzlePinSettings
---@param puzzleGridManager PuzzleGridManager
---@return PuzzlePin
function PuzzlePin.new(settings, puzzleGridManager)
	---@type PuzzlePin
	local pin = setmetatable({}, PuzzlePin)
	local offset = vec(settings.offset.x, settings.offset.y)
	local pos = addVec(puzzleGridManager.center, offset)
	local defaultHb = hitbox(Circle.new(PuzzlePin.FRAME_DIM.width / 2))
	local solidHb = hitbox(Circle.new(PuzzlePin.FRAME_DIM.width / 2))
	local hbs = hitboxes({ defaultHb }, { solidHb }, {})

	PuzzlePiece.init(pin, settings.id, pos, puzzleGridManager, hbs)
	pin.kind = PuzzlePin.KIND
	pin.offset = offset
	pin.pullDirection = vec(settings.pullDirection.x, settings.pullDirection.y)
	pin:addIdleAnimation(PuzzlePin.spritePathForState(IDLE), PuzzlePin.FRAME_DIM)
	pin:addSelectedAnimation(PuzzlePin.spritePathForState(SELECTED), PuzzlePin.FRAME_DIM)

	return pin
end

return PuzzlePin
