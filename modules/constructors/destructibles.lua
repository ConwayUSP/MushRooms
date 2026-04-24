---@param pos Vec
---@param room Room
---@return Destructible
-- cria um destrutível do tipo Barril
function newBarrel(pos, room)
	local loot = Loot.new(newSlingShot(), 0.2, range(1, 1), false)
	loot:insert(newKatana(), 0.2, range(1, 1), false)
	loot:insert(COIN, 0.6, range(1, 5), true)
	local hb = hitbox(Rectangle.new(40, 60))
	local hbs = hitboxes({ hb })
	local barrel = Destructible.new(BARREL.name, pos, room, loot, hbs)
	local intactAnimSettings = newAnimSetting(1, { width = 64, height = 64 }, 1, true, 1)
	local breakingAnimSettings = newAnimSetting(7, { width = 64, height = 64 }, 0.05, false, 1)
	local brokenAnimSettings = newAnimSetting(1, { width = 64, height = 64 }, 1, true, 1)
	barrel:addAnimations(intactAnimSettings, breakingAnimSettings, brokenAnimSettings)
	return barrel
end

---@param pos Vec
---@param room Room
---@return Destructible
-- cria um destrutível do tipo Jarro
function newJar(pos, room)
	local loot = Loot.new(COIN, 0.8, range(1, 3), true)
	local hb = hitbox(Circle.new(10))
	local hitboxes = hitboxes({ hb })
	local jar = Destructible.new(JAR.name, pos, room, loot, hitboxes)
	local intactAnimSettings = newAnimSetting(1, { width = 64, height = 64 }, 1, true, 1)
	local breakingAnimSettings = newAnimSetting(7, { width = 64, height = 64 }, 0.05, false, 1)
	local brokenAnimSettings = newAnimSetting(1, { width = 64, height = 64 }, 1, true, 1)
	jar:addAnimations(intactAnimSettings, breakingAnimSettings, brokenAnimSettings)
	return jar
end
