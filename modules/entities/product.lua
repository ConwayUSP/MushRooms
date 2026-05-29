----------------------------------------
-- Importações de Módulos
----------------------------------------
require("modules.engine.animation")
require("modules.systems.shaders")

----------------------------------------
-- Classe Product
----------------------------------------

---@class Product : Entity
---@field name string
---@field subtype Type
---@field description string
---@field image table
---@field animations table
---@field spriteSheets table
---@field state string
---@field hasShadow boolean
---@field shadowWidth number
---@field physics PhysicsSettings
---@field onInteract function?
---@field customUpdate function?
---@field customEnter function?
---@field customExit function?

Product = setmetatable({}, { __index = Entity })
Product.__index = Product
Product.type = RESOURCE

---@param prodType Type
---@param name string
---@param description string
---@param hitboxes Hitboxes
---@param physics? PhysicsSettings
---@param onInteract? function
---@param customUpdate? function
---@param customEnter? function
---@param customExit? function
---@diagnostic disable: inject-field
-- cria uma nova instância de Product
function Product.new(prodType, name, description, hitboxes, physics, onInteract, customUpdate, customEnter, customExit)
	---@type Product
	local product
	product = setmetatable({}, Product) ---@diagnostic disable-line
	local productPhysics = physics or physicsSettings(math.huge)
	Entity.init(product, name, vec(0, 0), hitboxes, nil, productPhysics)

	product.subtype = prodType -- se o recurso é BUILDING ou FOOD
	product.actualized = prodType ~= BUILDING -- construções não começam reais (precisam ser posicionadas antes)
	product.description = description -- descrição do recurso
	product.state = IDLE
	product.animations = {}
	product.spriteSheets = {}
	product.hasShadow = true
	product.physics = productPhysics
	product.onInteract = onInteract or function() end
	product.customUpdate = customUpdate
	product.customEnter = customEnter
	product.customExit = customExit

	if prodType == BUILDING then
		product.update = Interactive.update
	end

	return product
end
---@diagnostic enable: inject-field

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
