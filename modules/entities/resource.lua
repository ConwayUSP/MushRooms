----------------------------------------
-- Classe Resource
----------------------------------------

---@class Resource
---@field name string
---@field subtype Type
---@field description string
---@field image table

Resource = {}
Resource.__index = Resource
Resource.type = RESOURCE

---@param resType Type
---@param name string
---@param description string
-- cria uma nova instância de Resource
function Resource.new(resType, name, description)
	---@type Resource
	local resource = setmetatable({}, Resource) ---@diagnostic disable-line

	resource.subtype = resType -- se o recurso é MATERIAL ou INGREDIENT
	resource.name = name -- nome do recurso
	resource.description = description -- descrição do recurso
	resource.image = love.graphics.newImage(pngPathFormat({ "assets", "sprites", "resources", name })) -- sprite do recurso
	resource.image:setFilter("nearest", "nearest")

	return resource
end
