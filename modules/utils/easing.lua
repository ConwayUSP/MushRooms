----------------------------------------
-- Módulo de Easing
----------------------------------------

---@alias easingFunc fun(t: number): number

---@class Easing
Easing = {}

---@type easingFunc
-- função de suavização linear
function Easing.linear(t)
	return t
end

---@type easingFunc
-- função de suavização quadrática
function Easing.inQuad(t)
	return t * t
end

---@type easingFunc
-- função de suavização quadrática reversa
function Easing.outQuad(t)
	return t * (2 - t)
end

---@type easingFunc
-- função de suavização quadrática dupla
function Easing.inOutQuad(t)
	t = t * 2
	if t < 1 then
		return 0.5 * t * t
	end
	return -0.5 * ((t - 1) * (t - 3) - 1)
end

---@type easingFunc
-- função de suavização cúbica
function Easing.inCubic(t)
	return t * t * t
end

---@type easingFunc
-- função de suavização cúbica reversa
function Easing.outCubic(t)
	t = t - 1
	return t * t * t + 1
end

---@type easingFunc
-- função de suavização cúbica dupla
function Easing.inOutCubic(t)
	t = t * 2
	if t < 1 then
		return 0.5 * t * t * t
	end
	t = t - 2
	return 0.5 * (t * t * t + 2)
end

---@type easingFunc
-- função de suavização quártica
function Easing.inQuart(t)
	return t * t * t * t
end

---@type easingFunc
-- função de suavização quártica reversa
function Easing.outQuart(t)
	t = t - 1
	return -(t * t * t * t - 1)
end

---@type easingFunc
-- função de suavização quártica dupla
function Easing.inOutQuart(t)
	return t < 0.5 and 8 * t * t * t * t or 1 - ((-2 * t + 2) ^ 4) / 2
end

---@type easingFunc
-- função de suavização quíntica
function Easing.inQuint(t)
	return t * t * t * t * t
end

---@type easingFunc
-- função de suavização quíntica reversa
function Easing.outQuint(t)
	t = t - 1
	return (t * t * t * t * t + 1)
end

---@type easingFunc
-- função de suavização com inércia
function Easing.outBack(t)
	local c1 = 1.70158
	local c3 = c1 + 1

	return 1 + c3 * ((t - 1) ^ 3) + c1 * ((t - 1) ^ 2)
end

---@type easingFunc
-- função de suavização exponencial reversa
function Easing.outExpo(t)
	return t == 1 and 1 or 1 - 2^(-10 * t)
end

return Easing
