----------------------------------------
-- Classe Puzzle
----------------------------------------

---@class Puzzle
---@field room Room sala que contém o puzzle

Puzzle = {}
Puzzle.__index = Puzzle

---@param room Room
---@return Puzzle
-- cria a base compartilhada pelos puzzles de uma sala
function Puzzle.new(room)
	local puzzle = setmetatable({}, Puzzle)
	puzzle.room = room

	return puzzle
end

---@param dt number
-- atualiza o estado específico do puzzle
function Puzzle:update(dt) end

---@param camera Camera
-- desenha o fundo próprio do puzzle
function Puzzle:drawBackground(camera) end

---@param player Player
-- reage à entrada de um player na sala
function Puzzle:onPlayerEnter(player) end

---@param player Player
-- reage à saída de um player da sala
function Puzzle:onPlayerExit(player) end
