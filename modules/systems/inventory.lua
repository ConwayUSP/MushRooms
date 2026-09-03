---@class Inventory
---@field owner Entity
---@field items table

Inventory = {}
Inventory.__index = Inventory
Inventory.type = INVENTORY

---@param owner Entity
-- cria uma nova instância de inventário para o dono especificado
function Inventory.new(owner)
	local inv = setmetatable({}, Inventory)
	inv.owner = owner
	inv.items = inv:startItems()

	return inv
end

function Inventory:startItems()
	local items = {}
	items[RESOURCE] = {}
	items[INGREDIENT] = {}
	items[FOOD] = {}

	return items
end

---@param item Resource
---@return boolean
function Inventory:addItem(item)
	local index = self:hasItem(item)

	if not index then
		local newItem = {
			name = item.name,
			type = item.type,
			description = item.description,
			weight = item.weight,
			quantity = item.quantity or 1,
		}

		table.insert(self.items[item.type], newItem)
	else
		local invItem = self.items[item.type][index]

		if invItem.quantity >= 99 then
			return false
		end

		invItem.quantity = invItem.quantity + 1
	end

	return true
end

---@param item Resource
---@return boolean
function Inventory:subtractItem(item)
	local index = self:hasItem(item)
	if index ~= -1 then
		local invItem = self.items[item.type][index]

		if invItem.quantity > 1 then
			invItem.quantity = invItem.quantity - 1
		else
			table.remove(self.items[item.type], index)
		end

		return true
	end

	return false
end

---@param item Resource
---@return boolean
function Inventory:hasItem(item)
	for index, invItem in ipairs(self.items[item.type]) do
		if invItem.name == item.name then
			return index
		end
	end

	return false
end

---@param item Resource
---@param dest Inventory
-- transfere um item de um inventário para outro
function Inventory:transferItem(item, dest)
	local destIdx = dest:hasItem(item)
	local selfIdx = self:hasItem(item)
	if destIdx then
		dest.items[item.type][destIdx].quantity = dest.items[item.type][destIdx].quantity
			+ self.items[item.type][selfIdx].quantity
	else
		dest:addItem(self.items[item.type][selfIdx])
	end
	table.remove(self.items[item.type], selfIdx)
end

function Inventory:length(itemType)
	return #self.items[itemType]
end
