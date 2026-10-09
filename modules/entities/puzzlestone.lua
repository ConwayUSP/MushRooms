----------------------------------------
-- Importações de Módulos
----------------------------------------
require("modules.entities.puzzlepiece")
require("modules.utils.vec")

----------------------------------------
-- Classe PuzzleStone
----------------------------------------

---@class PuzzleStone : PuzzlePiece
---@field cell Vec
---@field direction Vec direção da quina no sprite (x e y iguais a -1 ou 1)
---@field spritePath string
---@field moving boolean

PuzzleStone = setmetatable({}, { __index = PuzzlePiece })
PuzzleStone.__index = PuzzleStone
PuzzleStone.SPRITE_PATH_START = dirPathFormat({ "assets", "sprites", "puzzle", "Puzzle Corner" })
PuzzleStone.PIECE_NAMES = {
	["-1,-1"] = "Piece Up Left",
	["1,-1"] = "Piece Up Right",
	["-1,1"] = "Piece Down Left",
	["1,1"] = "Piece Down Right",
}
PuzzleStone.FRAME_DIM = { width = 149, height = 149 }

---@class PuzzleStoneSettings
---@field id string identificador único dentro do puzzle
---@field cell Vec posição inicial válida e desocupada no grid
---@field direction Vec direção da quina: cada eixo deve ser -1 ou 1

---@param direction Vec
---@param state? State
---@return string
function PuzzleStone.spritePathForDirection(direction, state)
	local spriteState = state or IDLE
	local pieceName = PuzzleStone.PIECE_NAMES[direction.x .. "," .. direction.y]
	return pngPathFormat({ PuzzleStone.SPRITE_PATH_START, pieceName, spriteState })
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
	stone.cell = cell
	stone.direction = vec(settings.direction.x, settings.direction.y)
	stone.spritePath = PuzzleStone.spritePathForDirection(stone.direction, IDLE)
	stone.moving = false
	stone:addIdleAnimation(stone.spritePath, PuzzleStone.FRAME_DIM)
	stone:addSelectedAnimation(PuzzleStone.spritePathForDirection(stone.direction, SELECTED), PuzzleStone.FRAME_DIM)

	return stone
end

return PuzzleStone
