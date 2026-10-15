----------------------------------------
-- Importações de Módulos
----------------------------------------
require("modules.utils.types")

----------------------------------------
-- Classe Color
----------------------------------------

---@class Color
---@field r number
---@field g number
---@field b number
---@field a number
Color = {}
Color.__index = Color
Color.type = COLOR

---@param r number
---@param g number
---@param b number
---@param a number
---@return Color
-- cria uma instância de `Color`
function Color.new(r, g, b, a)
	local c = setmetatable({}, Color)
	c.r = clamp(r, 0, 1)
	c.g = clamp(g, 0, 1)
	c.b = clamp(b, 0, 1)
	c.a = clamp(a, 0, 1)
	return c
end

----------------------------------------
-- Construtores
----------------------------------------

---@param r number
---@param g number
---@param b number
---@param a number
---@return Color
-- cria uma cor RGBA com componentes entre 0 e 1
function rgba(r, g, b, a)
	return Color.new(r, g, b, a)
end

---@param r number
---@param g number
---@param b number
---@param a number
---@return Color
-- cria uma cor RGBA a partir de argumentos no formato 8-bits [0-255]
function rgba8(r, g, b, a)
	return Color.new(r / 255, g / 255, b / 255, a / 255)
end

----------------------------------------
-- Paletas de cores dos players
----------------------------------------

---@return Color[]
-- retorna a paleta de cores do player 1
function getP1ColorPalette()
	local palette = {}
	table.insert(palette, rgba(1.0, 0.11, 0.2, 1.0))
	table.insert(palette, rgba(1.0, 0.88, 0.44, 1.0))
	table.insert(palette, rgba(0.08, 0.75, 0.39, 1.0))
	return palette
end

---@return Color[]
-- retorna a paleta de cores do player 2
function getP2ColorPalette()
	local palette = {}
	table.insert(palette, rgba(0.2, 0.52, 0.89, 1.0))
	table.insert(palette, rgba(0.59, 0.16, 0.94, 1.0))
	table.insert(palette, rgba(0.43, 0.96, 0.83, 1.0))
	return palette
end

---@return Color[]
-- retorna a paleta de cores do player 3
function getP3ColorPalette()
	local palette = {}
	table.insert(palette, rgba(0.79, 0.06, 0.17, 1.0))
	table.insert(palette, rgba(0.94, 0.45, 0.19, 1.0))
	table.insert(palette, rgba(0.92, 0.85, 0.28, 1.0))
	return palette
end

---@return Color[]
-- retorna a paleta de cores do player 4
function getP4ColorPalette()
	local palette = {}
	table.insert(palette, rgba(0.92, 0.16, 0.54, 1.0))
	table.insert(palette, rgba(0.2, 0.41, 0.91, 1.0))
	table.insert(palette, rgba(0.56, 0.15, 0.88, 1.0))
	return palette
end

-------------------------------------------
-- Cores de brilho para objetos do cenário
-------------------------------------------

COLOR_RED_GLOW = { 0.9, 0.2, 0.4, 0.66 }
COLOR_WEAK_RED_GLOW = {0.9, 0.2, 0.4, 0.33}