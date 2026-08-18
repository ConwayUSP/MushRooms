---@param pos Vec
---@param room Room
---@return Destructible
-- cria um destrutível do tipo Barril
function newBarrel(pos, room)
	local loot = Loot.new(newSlingShot(), 0.2, range(1, 1), false)
	loot:insert(newKatana(), 0.2, range(1, 1), false)
	loot:insert(newCaskin(), 0.5, range(1, 3), true)
	local hb = hitbox(Rectangle.new(40, 60))
	local hbs = hitboxes({ hb })
	local barrel = Destructible.new(BARREL.name, pos, room, loot, hbs)
	local animSettings = {}
	animSettings[INTACT] = newAnimSetting(1, { width = 64, height = 64 }, 1000, true, 1)
	animSettings[BREAKING] = newAnimSetting(7, { width = 64, height = 64 }, 0.05, false, 1)
	animSettings[BROKEN] = newAnimSetting(1, { width = 64, height = 64 }, 1000, true, 1)
	barrel:addAnimations(animSettings)
	barrel.hasShadow = true
	barrel.shadowWidth = 20
	return barrel
end

---@param pos Vec
---@param room Room
---@return Destructible
-- cria um destrutível do tipo Jarro
function newJar(pos, room)
	local loot = Loot.new(newArduro(), 0.5, range(1, 2), true)
	local hb = hitbox(Circle.new(10))
	local hitboxes = hitboxes({ hb })
	local jar = Destructible.new(JAR.name, pos, room, loot, hitboxes)
	local animSettings = {}
	animSettings[INTACT] = newAnimSetting(1, { width = 64, height = 64 }, 1000, true, 1)
	animSettings[BREAKING] = newAnimSetting(7, { width = 64, height = 64 }, 0.05, false, 1)
	animSettings[BROKEN] = newAnimSetting(1, { width = 64, height = 64 }, 1000, true, 1)
	jar:addAnimations(animSettings)
	jar.hasShadow = true
	jar.shadowWidth = 12
	return jar
end

---@param pos Vec
---@param room Room
---@return Destructible
-- cria um destrutível do tipo Grama Alta
function newTallGrass(pos, room)
	local loot = Loot.new(newCoseca(), 0.75, range(1, 2), true)
	local hb = hitbox(Rectangle.new(40, 25))
	local hitboxes = hitboxes({ hb })
	local tallGrass = Destructible.new(TALL_GRASS.name, pos, room, loot, hitboxes, UNSTABLE)
	local animSettings = {}
	animSettings[INTACT] = newAnimSetting(1, { width = 32, height = 32 }, 1000, true, 1)
	animSettings[BREAKING] = newAnimSetting(7, { width = 32, height = 32 }, 0.075, false, 1)
	animSettings[MOVING] = newAnimSetting(8, { width = 32, height = 32 }, 0.075, false, 1, 0)
	animSettings[BROKEN] = newAnimSetting(1, { width = 32, height = 32 }, 1000, true, 1)
	tallGrass:addAnimations(animSettings)
	tallGrass.hasShadow = true
	tallGrass.shadowWidth = 12
	return tallGrass
end
