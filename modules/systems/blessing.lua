----------------------------------------
-- Classe BlessingManager
----------------------------------------

---@class BlessingManager

BlessingManager = {}
BlessingManager.__index = BlessingManager
BlessingManager.type = BLESSING_MANAGER

function BlessingManager.new()
	local manager = setmetatable({}, BlessingManager)
  manager.equipped = {}

	return manager
end

function BlessingManager:dispatch(event, ctx)
  for _, blessing in ipairs(self.equipped) do
    local fn = blessing[event]

    if fn then
      fn(blessing, ctx)
    end

  end

end

function BlessingManager:equip(blessing)
  table.insert(self.equipped, blessing)
  blessing.onEquip()

  return true
end

function BlessingManager:unequip(blessing)
  for i, b in ipairs(self.equipped) do
    if b == blessing then
      table.remove(self.equipped, i)
      blessing.onUnequip()

      return true
    end
  end

  return false
end

----------------------------------------
-- Classe Blessing
----------------------------------------

---@class Blessing
---@field name string
---@field description string
---@field tag string
---@field image any
---@field applyFuncs table<string, function>
Blessing = {}
Blessing.__index = Blessing
Blessing.type = BLESSING

function Blessing.new(name, description, tag, applyFuncs)
	local blessing = setmetatable({}, Blessing)
	blessing.name = name
	blessing.description = description
	blessing.tag = tag
	blessing:newApplyFuncs(applyFuncs)

  local sprite_path = pngPathFormat({ "assets", "sprites", "blessings", name })
  blessing.image = love.graphics.newImage(sprite_path)
  blessing.image:setFilter("nearest", "nearest")
	return blessing
end

function Blessing:newApplyFuncs(applyFuncs)
  self.onEquip = applyFuncs.onEquip or function() end
  self.onUnequip = applyFuncs.onUnequip or function() end
  self.onAttackHitEnemy = applyFuncs.onAttackHitEnemy or function() end
  self.onDamagedByEnemy = applyFuncs.onDamagedByEnemy or function() end
  self.onPlayerHeal = applyFuncs.onPlayerHeal or function() end
  self.onKillEnemy = applyFuncs.onKillEnemy or function() end
end

