----------------------------------------
-- Importações de Módulos
----------------------------------------
require("modules.utils.types")
require("modules.utils.utils")
require("modules.utils.vec")

----------------------------------------
-- Funções auxiliares para colisão
----------------------------------------

--- tipos de hitbox
DEFAULT = "default"
SOLID = "solid"
TRIGGER = "trigger"

---@class Hitboxes
---@field solids Hitbox[]
---@field default Hitbox[]
---@field triggers Hitbox[]

---@class Hitbox
---@field shape Shape
---@field offset Vec

---@alias CircleHitbox {offset: Vec, shape: Circle}
---@alias RectHitbox {offset: Vec, shape: Rectangle}
---@alias LineHitbox {offset: Vec, shape: Line}

---@param shape Shape
---@param posOffset? Vec
---@return Hitbox
-- cria uma `Hitbox`, estrutura com forma e posição
function hitbox(shape, posOffset)
	return {
		shape = shape,
		offset = posOffset or vec(0, 0),
	}
end

---@param default Hitbox[]
---@param solids? Hitbox[]
---@param triggers? Hitbox[]
---@return Hitboxes
-- cria uma estrutura `Hitboxes` para agrupar hitboxes por tipo
function hitboxes(default, solids, triggers)
	return {
		default = default or {},
		solids = solids or {},
		triggers = triggers or {},
	}
end

---@param hbs Hitboxes
-- retorna uma cópia da tabela de hitboxes `hbs`
function copyHitboxes(hbs)
	local newHbs = {
		default = {},
		solids = {},
		triggers = {},
	}

	for _, hb in ipairs(hbs.default) do
		table.insert(newHbs.default, copyHitbox(hb))
	end
	for _, hb in ipairs(hbs.solids) do
		table.insert(newHbs.solids, copyHitbox(hb))
	end
	for _, hb in ipairs(hbs.triggers) do
		table.insert(newHbs.triggers, copyHitbox(hb))
	end

	return newHbs
end

---@param hb Hitbox
---@param offset? Vec
---@return Hitbox
-- retorna uma cópia de `hb` podendo ou não distinguir sua posição
-- da hitbox original com o uso do parâmetro `offset`
function copyHitbox(hb, offset)
	local shape = copyShape(hb.shape)
	return {
		shape = shape,
		offset = offset or vec(hb.offset.x, hb.offset.y),
	}
end

---@param shape Shape | Circle | Rectangle | Line
---@return Shape
-- retorna uma cópia do formato passado como argumento
function copyShape(shape)
	if shape.shape == CIRCLE then
		return Circle.new(shape.radius)
	elseif shape.shape == RECTANGLE then
		return Rectangle.new(shape.width, shape.height)
	else
		return Line.new(shape.angle, shape.length)
	end
end

---@param hitbox Hitbox
---@param entityPos Vec
---@return Hitbox
-- constrói uma hitbox no "mundo" a partir de uma hitbox local `hitbox`
function buildWorldHitbox(hitbox, entityPos)
	return {
		shape = hitbox.shape,
		offset = addVec(entityPos, hitbox.offset),
	}
end

function entityKey(entity)
	if entity.type ~= ATTACK_EVENT then
		return entity.type
	else
		return entity.ally and PLAYER_ATTACK or ENEMY_ATTACK
	end
end

----------------------------------------
-- Funções auxiliares para colisão
----------------------------------------

---@param hb1 Hitbox
---@param hb2 Hitbox
---@return boolean
-- recebe duas hitboxes, retorna true se elas se tocam
function checkHitboxCollision(hb1, hb2)
	if hb1.shape.shape == CIRCLE then
		if hb2.shape.shape == CIRCLE then
			return checkCircleCircleCollision(hb1, hb2)
		elseif hb2.shape.shape == RECTANGLE then
			return checkCircleRectCollision(hb1, hb2)
		elseif hb2.shape.shape == LINE then
			return checkCircleLineCollision(hb1, hb2)
		end
	elseif hb1.shape.shape == RECTANGLE then
		if hb2.shape.shape == CIRCLE then
			return checkCircleRectCollision(hb2, hb1)
		elseif hb2.shape.shape == RECTANGLE then
			return checkRectRectCollision(hb1, hb2)
		elseif hb2.shape.shape == LINE then
			return checkRectLineCollision(hb1, hb2)
		end
	elseif hb1.shape.shape == LINE then
		if hb2.shape.shape == CIRCLE then
			return checkCircleLineCollision(hb2, hb1)
		elseif hb2.shape.shape == RECTANGLE then
			return checkRectLineCollision(hb2, hb1)
		elseif hb2.shape.shape == LINE then
			return checkLineLineCollision(hb1, hb2)
		end
	end

	return false
end

---@param a Hitbox[]
---@param ownerA Entity
---@param b Hitbox[]
---@param ownerB Entity
-- checa colisão entre as hitboxes `a` e `b`, pertencentes aos donos `ownerA` e `ownerB`
function checkColision(a, ownerA, b, ownerB)
	if #a == 0 or #b == 0 then
		return false
	end

	for _, hbA in ipairs(a) do
		local worldHbA = buildWorldHitbox(hbA, ownerA.pos)

		for _, hbB in ipairs(b) do
			local worldHbB = buildWorldHitbox(hbB, ownerB.pos)

			if checkHitboxCollision(worldHbA, worldHbB) then
				return true
			end
		end
	end

	return false
end

---@param point Vec
---@param line {offset: Vec, shape: Line} Hitbox em formato de linha
---@return boolean
-- verifica se a linha `line` contém o ponto `point`
function pointOnLine(point, line)
	local d1 = dist(point, line.offset)
	local d2 = dist(point, polarToVec(line.shape.angle, line.shape.length) + line.offset)
	local leniency = 0.01
	if d1 + d2 < line.shape.length + leniency and d1 + d2 > line.shape.length - leniency then
		return true
	end
	return false
end

---@param point Vec
---@param rect RectHitbox
---@return boolean
-- verifica se o ponto `point` está dentro do retângulo `rect`
function pointOnRect(point, rect)
	if
		point.x >= rect.offset.x
		and point.x <= rect.offset.x + rect.shape.width
		and point.y >= rect.offset.y
		and point.y <= rect.offset.y + rect.shape.height
	then
		return true
	end

	return false
end

---@param circle1 CircleHitbox
---@param circle2 CircleHitbox
---@return boolean
-- checa se dois círculos estão colidindo
function checkCircleCircleCollision(circle1, circle2)
	return dist(circle1.offset, circle2.offset) <= circle1.shape.radius + circle2.shape.radius
end

---@param circle CircleHitbox
---@param rect RectHitbox
---@return boolean
-- checa se um círculo e um retângulo estão colidindo
function checkCircleRectCollision(circle, rect)
	local dist = vec(math.abs(circle.offset.x - rect.offset.x), math.abs(circle.offset.y - rect.offset.y))
	if dist.x > (rect.shape.halfW + circle.shape.radius) or dist.y > (rect.shape.halfH + circle.shape.radius) then
		return false
	end
	if dist.x <= rect.shape.halfW or dist.y <= rect.shape.halfH then
		return true
	end
	local cornerDist = (dist.x - rect.shape.halfW) ^ 2 + (dist.y - rect.shape.halfH) ^ 2
	return cornerDist <= circle.shape.radius ^ 2
end

---@param circle CircleHitbox
---@param line LineHitbox
---@return boolean
-- checa se um círculo e uma linha estão colidindo
function checkCircleLineCollision(circle, line)
	local p1 = line.offset
	local p2 = addVec(p1, polarToVec(line.shape.angle, line.shape.length))
	if dist(p1, circle.offset) < circle.shape.radius or dist(p2, circle.offset) < circle.shape.radius then
		return true
	end
	local dot = dotProd(subVec(circle.offset, p1), subVec(p2, p1))
	local closestX = p1.x + (dot * (p2.x - p1.x))
	local closestY = p1.y + (dot * (p2.y - p1.y))
	if not pointOnLine(vec(closestX, closestY), line) then
		return false
	end
	local distX = closestX - circle.offset.x
	local distY = closestY - circle.offset.y
	local dist = distX ^ 2 + distY ^ 2
	if dist <= circle.shape.radius ^ 2 then
		return true
	end
	return false
end

---@param rect1 RectHitbox
---@param rect2 RectHitbox
---@return boolean
-- checa se dois retângulos estão colidindo
function checkRectRectCollision(rect1, rect2)
	if
		rect1.offset.x + rect1.shape.width >= rect2.offset.x
		and rect1.offset.x <= rect2.offset.x + rect2.shape.width
		and rect1.offset.y + rect1.shape.height >= rect2.offset.y
		and rect1.offset.y <= rect2.offset.y + rect2.shape.height
	then
		return true
	end
	return false
end

---@param rect RectHitbox
---@param line LineHitbox
---@return boolean
-- checa se um retângulo e uma linha estão colidindo
function checkRectLineCollision(rect, line)
	local leftSide = hitbox(Line.new(math.pi * 3 / 2, rect.shape.height), rect.offset)
	local upSide = hitbox(Line.new(0, rect.shape.width), rect.offset)
	local rightSide =
		hitbox(Line.new(math.pi * 3 / 2, rect.shape.height), addVec(rect.offset, scaleVec(vec(1, 0), rect.shape.width)))
	local downSide = hitbox(Line.new(0, rect.shape.width), addVec(rect.offset, scaleVec(vec(0, 1), rect.shape.height)))
	local leftHit = checkLineLineCollision(line, leftSide)
	local upHit = checkLineLineCollision(line, upSide)
	local rightHit = checkLineLineCollision(line, rightSide)
	local downHit = checkLineLineCollision(line, downSide)
	if leftHit or upHit or rightHit or downHit then
		return true
	end
	return false
end

---@param line1 LineHitbox
---@param line2 LineHitbox
---@return boolean
-- checa se duas linhas estão colidindo
function checkLineLineCollision(line1, line2)
	local p1 = line1.offset
	local p2 = addVec(p1, polarToVec(line1.shape.angle, line1.shape.length))
	local p3 = line2.offset
	local p4 = addVec(p3, polarToVec(line2.shape.angle, line2.shape.length))

	local a = ((p4.x - p3.x) * (p1.y - p3.y) - (p4.y - p3.y) * (p1.x - p3.x))
		/ ((p4.y - p3.y) * (p2.x - p1.x) - (p4.x - p3.x) * (p2.y - p1.y))
	local b = ((p2.x - p1.x) * (p1.y - p3.y) - (p2.y - p1.y) * (p1.x - p3.x))
		/ ((p4.y - p3.y) * (p2.x - p1.x) - (p4.x - p3.x) * (p2.y - p1.y))
	if a >= 0 and a <= 1 and b >= 0 and b <= 1 then
		return true
	end
	return false
end

----------------------------------------
-- Funções de manifold para sólidos
----------------------------------------

---@param hb1 Hitbox
---@param hb2 Hitbox
---@return {normal: Vec, depth: number} | nil
-- retorna uma estrutura com a normal da colisão e o quão profundo
-- o objeto colisor entrou no objeto sólido
function getCollisionManifold(hb1, hb2)
	local shape1 = hb1.shape.shape
	local shape2 = hb2.shape.shape

	if shape1 == RECTANGLE and shape2 == RECTANGLE then
		return getRectRectManifold(hb1, hb2)
	elseif shape1 == CIRCLE and shape2 == RECTANGLE then
		return getCircleRectManifold(hb1, hb2)
	elseif shape1 == RECTANGLE and shape2 == CIRCLE then
		local m = getCircleRectManifold(hb2, hb1)
		if m then
			m.normal = scaleVec(m.normal, -1)
		end
		return m
	elseif shape1 == CIRCLE and shape2 == CIRCLE then
		return getCircleCircleManifold(hb1, hb2)
	end
	return nil
end

---@param r1 RectHitbox
---@param r2 RectHitbox
---@return {normal: Vec, depth: number} | nil
-- calcula o manifold (normal de colisão + profundidade) entre dois retângulos
function getRectRectManifold(r1, r2)
	-- distância entre os centros
	local dist = subVec(r1.offset, r2.offset)

	local rw1 = r1.shape.halfW
	local rh1 = r1.shape.halfH
	local rw2 = r2.shape.halfW
	local rh2 = r2.shape.halfH

	-- calcula a sobreposição nos eixos
	local xOverlap = (rw1 + rw2) - math.abs(dist.x)
	local yOverlap = (rh1 + rh2) - math.abs(dist.y)

	if xOverlap > 0 and yOverlap > 0 then
		-- empurra na direção da menor sobreposição
		if xOverlap < yOverlap then
			local sx = dist.x < 0 and -1 or 1
			return { normal = vec(sx, 0), depth = xOverlap }
		else
			local sy = dist.y < 0 and -1 or 1
			return { normal = vec(0, sy), depth = yOverlap }
		end
	end
	return nil
end

---@param c CircleHitbox
---@param r RectHitbox
---@return {normal: Vec, depth: number} | nil
-- calcula o manifold (normal de colisão + profundidade) entre um círculo e um retângulo
function getCircleRectManifold(c, r)
	local rw = r.shape.halfW
	local rh = r.shape.halfH

	-- encontra o ponto mais próximo no retângulo em relação ao centro do círculo
	local closestX = clamp(c.offset.x, r.offset.x - rw, r.offset.x + rw)
	local closestY = clamp(c.offset.y, r.offset.y - rh, r.offset.y + rh)
	local closest = vec(closestX, closestY)

	-- vetor do ponto mais próximo até o centro do círculo
	local dist = subVec(c.offset, closest)
	local distLen = lenVec(dist)

	-- Se a distância for menor que o raio, colidiu
	if distLen < c.shape.radius then
		local normal
		local depth

		-- caso especial: centro do círculo está dentro do retângulo
		if distLen == 0 then
			-- encontra a menor distância para sair
			local dx = c.offset.x - r.offset.x
			local dy = c.offset.y - r.offset.y
			local distToRight = rw - dx
			local distToLeft = rw + dx
			local distToTop = rh - dy
			local distToBottom = rh + dy
			local minDist = math.min(distToRight, distToLeft, distToTop, distToBottom)

			if minDist == distToRight then
				normal = vec(1, 0)
			elseif minDist == distToLeft then
				normal = vec(-1, 0)
			elseif minDist == distToTop then
				normal = vec(0, 1)
			else
				normal = vec(0, -1)
			end
			depth = c.shape.radius + minDist
		else
			normal = normalize(dist)
			depth = c.shape.radius - distLen
		end

		return { normal = normal, depth = depth }
	end
	return nil
end

---@param c1 CircleHitbox
---@param c2 CircleHitbox
---@return {normal: Vec, depth: number} | nil
-- calcula o manifold (normal de colisão + profundidade) entre dois círculos
function getCircleCircleManifold(c1, c2)
	local dist = subVec(c1.offset, c2.offset)
	local distLen = lenVec(dist)
	local radiusSum = c1.shape.radius + c2.shape.radius

	if distLen < radiusSum then
		local normal
		local depth = radiusSum - distLen
		if distLen == 0 then
			normal = vec(1, 0)
		else
			normal = normalize(dist)
		end
		return { normal = normal, depth = depth }
	end
	return nil
end

----------------------------------------
-- Resposta física de colisão (3ª lei)
----------------------------------------

---@param entityA Entity
---@param entityB Entity
---@param normal Vec # normal apontando de A para B
---@param restitution? number
-- aplica um impulso de contato entre duas entidades, obedecendo
-- conservação de quantidade de movimento e coeficiente de restituição
function applyContactImpulse(entityA, entityB, normal, restitution)
	entityA.vel = entityA.vel or vec(0, 0)
	entityB.vel = entityB.vel or vec(0, 0)

	entityA.mass = entityA.mass or math.huge
	entityB.mass = entityB.mass or math.huge

	local vA = entityA.vel
	local vB = entityB.vel

	local mA = entityA.mass
	local mB = entityB.mass

	-- coeficiente de restituição efetivo (0 = inelástico, 1 = elástico)
	local rest = restitution or 0
	if entityA.restitution or entityB.restitution then
		rest = math.max(entityA.restitution or 0, entityB.restitution or 0)
	end

	-- garante normal unitária, de A pra B
	local u_normal = normalize(normal)
	local u_tangent = tangentVec(u_normal)

	local vA_normal = dotProd(vA, u_normal)
	local vA_tangent = dotProd(vA, u_tangent)

	local vB_normal = dotProd(vB, u_normal)
	local vB_tangent = dotProd(vB, u_tangent)

	if mA == math.huge or mB == math.huge then
		if mA == math.huge and mB == math.huge then
			return
		elseif mA == math.huge then
			entityB.vel = addVec(scaleVec(u_tangent, vB_tangent), scaleVec(u_normal, -vB_normal * rest))
		else
			entityA.vel = addVec(scaleVec(u_tangent, vA_tangent), scaleVec(u_normal, -vA_normal * rest))
		end

		return
	end

	-- formulas usadas:
	-- rest*(Va - Vb) = V'b - V'a
	-- mA*Va + mB*Vb = mA*V'a + mB*V'b
	-- obs: Va ou Vb = velocidade ANTES / V'a ou V'b = velocidade DEPOIS da colisão
	local vA_normal_prime = (mA * vA_normal + mB * vB_normal - mB * rest * (vA_normal - vB_normal)) / (mA + mB)
	local vB_normal_prime = (mA * vA_normal + mB * vB_normal + mA * rest * (vA_normal - vB_normal)) / (mA + mB)

	local vA_normal_prime_vec = scaleVec(u_normal, vA_normal_prime)
	local vB_normal_prime_vec = scaleVec(u_normal, vB_normal_prime)
	local vA_tangent_prime_vec = scaleVec(u_tangent, vA_tangent)
	local vB_tangent_prime_vec = scaleVec(u_tangent, vB_tangent)

	entityA.vel = addVec(vA_normal_prime_vec, vA_tangent_prime_vec)
	entityB.vel = addVec(vB_normal_prime_vec, vB_tangent_prime_vec)
end
