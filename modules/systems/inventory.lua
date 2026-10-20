---@class Inventory
---@field owner Entity
---@field items table
---@field revision number
---@field capacity number?

Inventory = {}
Inventory.__index = Inventory
Inventory.type = INVENTORY

---@param owner Entity
---@param capacity? number
-- cria uma nova instância de inventário para o dono especificado
function Inventory.new(owner, capacity)
	local inv = setmetatable({}, Inventory)
	inv.owner = owner
	inv.items = inv:startItems()
	inv.revision = 0
	inv.capacity = capacity

	return inv
end

---@return number
-- retorna quantos slots distintos estão ocupados no inventário
function Inventory:slotCount()
	local count = 0
	for _, itemList in pairs(self.items) do
		count = count + #itemList
	end
	return count
end

---@param item Resource
---@return boolean
-- verifica se o item pode entrar no inventário sem ultrapassar sua capacidade
function Inventory:hasSpaceFor(item)
	return self:hasItem(item) ~= false or not self.capacity or self:slotCount() < self.capacity
end

-- marca que o conteúdo do inventário foi alterado
function Inventory:touch()
	self.revision = self.revision + 1
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
		if not self:hasSpaceFor(item) then
			return false
		end

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

	self:touch()
	return true
end

---@param item Resource | EntityReg
---@param quantity? number
---@return boolean
-- subtrai de um item determinada quantidade
-- se a quantidade no inventário é menor, retorna falso e não subtrai
function Inventory:subtractItem(item, quantity)
	local qtd = quantity or 1
	local index = self:hasItem(item)
	if not index then
		return false
	end

	local invItem = self.items[item.type][index]

	if invItem.quantity > qtd then
		invItem.quantity = invItem.quantity - qtd
	elseif invItem.quantity == qtd then
		table.remove(self.items[item.type], index)
	else
		return false
	end

	self:touch()
	return true
end

---@param item Resource
---@return number | false
function Inventory:hasItem(item)
	for index, invItem in ipairs(self.items[item.type]) do
		if invItem.name == item.name then
			return index
		end
	end

	return false
end

---@param item EntityReg | Resource
---@return number
-- dado um item, devolve a quantidade deste contida no inventário
function Inventory:countItem(item)
	local idx = self:hasItem(item)
	if idx then
		return self.items[item.type][idx].quantity
	end
	return 0
end

---@param item Resource
---@param dest Inventory
---@return boolean
-- transfere um item de um inventário para outro
function Inventory:transferItem(item, dest)
	local selfIdx = self:hasItem(item)
	if not selfIdx or not dest:hasSpaceFor(item) then
		return false
	end

	local sourceItem = self.items[item.type][selfIdx]
	local destIdx = dest:hasItem(item)
	if destIdx then
		local destItem = dest.items[item.type][destIdx]
		if destItem.quantity + sourceItem.quantity > 99 then
			return false
		end
		destItem.quantity = destItem.quantity + sourceItem.quantity
		dest:touch()
	else
		if not dest:addItem(sourceItem) then
			return false
		end
	end
	table.remove(self.items[item.type], selfIdx)
	self:touch()
	return true
end

function Inventory:length(itemType)
	return #self.items[itemType]
end
