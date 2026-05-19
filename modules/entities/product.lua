----------------------------------------
-- Importações de Módulos
----------------------------------------
require("modules.engine.animation")
require("modules.systems.shaders")

----------------------------------------
-- Classe Product
----------------------------------------

---@class Product
---@field name string
---@field subtype Type
---@field description string
---@field image table
---@field animations table
---@field spriteSheets table

Product = setmetatable({}, { __index = Entity })
Product.__index = Product
Product.type = RESOURCE

---@param prodType Type
---@param name string
---@param description string
-- cria uma nova instância de Product
function Product.new(prodType, name, description, hitboxes)
	---@type Product
	local product = setmetatable({}, Product) ---@diagnostic disable-line
	Entity.init(product, name, vec(0, 0), hitboxes, nil, physicsSettings(math.huge))

	product.subtype = prodType -- se o recurso é BUILDING ou FOOD
	product.actualized = prodType ~= BUILDING -- construções não começam reais (precisam ser posicionadas antes)
	product.description = description -- descrição do recurso
	product.state = IDLE
	product.animations = {}
	product.spriteSheets = {}

	if prodType == BUILDING then
		product.update = Interactive.update
	end

	return product
end

function Product:draw(camera)
	if not self.actualized then
		love.graphics.setShader(positioningShader)
	end
	local viewPos = camera:viewPos(self.pos)
	local anim = self.animations[self.state]
	local quad = anim.frames[anim.currFrame]
	local offset = {
		x = anim.frameDim.width / 2,
		y = anim.frameDim.height / 2,
	}
	love.graphics.draw(self.spriteSheets[self.state], quad, viewPos.x, viewPos.y, 0, 3, 3, offset.x, offset.y)
	love.graphics.setShader()
end
