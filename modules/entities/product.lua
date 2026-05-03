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

Product = {}
Product.__index = Product
Product.type = RESOURCE

---@param prodType Type
---@param name string
---@param description string
-- cria uma nova instância de Product
function Product.new(prodType, name, description)
	---@type Product
	local product = setmetatable({}, Product) ---@diagnostic disable-line

	product.subtype = prodType -- se o recurso é BUILDING ou FOOD
	product.name = name -- nome do recurso
	product.description = description -- descrição do recurso
	product.image = love.graphics.newImage(pngPathFormat({ "assets", "sprites", "resources", name })) -- sprite do recurso
	product.image:setFilter("nearest", "nearest")

	--!TODO: add animations

	return product
end
