----------------------------------------
-- Fontes de Recurso
----------------------------------------
---@param pos Vec
---@param room Room
---@return Destructible
-- cria uma pilha de ossos destrutível (drop de ossos)
function newBonePile(pos, room)
	local loot = Loot.new(newTuntun(), 1, range(1, 4), true)
	local dhb = hitbox(Circle.new(44), vec(3, -6)) -- hitbox default
	local shb = hitbox(Circle.new(22), vec(3, -6)) -- hitbox sólida
	local hitboxes = hitboxes({ dhb }, { shb })
	local bones = Destructible.new(BONE_PILE.name, pos, room, loot, hitboxes, STABLE)
	local animSettings = {}
	animSettings[INTACT] = newAnimSetting(1, { width = 48, height = 32 }, 1000, true, 1)
	animSettings[BREAKING] = newAnimSetting(11, { width = 48, height = 32 }, 0.05, false, 1)
	animSettings[BROKEN] = newAnimSetting(1, { width = 48, height = 32 }, 1000, true, 1)
	bones:addAnimations(animSettings)
	bones.hasShadow = false
	bones.breakParticle = PARTICLE_BREAK_BONE
	return bones
end

---@param pos Vec
---@param room Room
---@return Destructible
-- cria um amontoado de pedras destrutível (drop de pedras)
function newDestructibleRock(pos, room)
	local loot = Loot.new(newPedacito(), 1, range(1, 7), true)
	local dhb = hitbox(Circle.new(55), vec(-3, -6)) -- hitbox default
	local shb = hitbox(Circle.new(30), vec(-3, -6)) -- hitbox sólida
	local hitboxes = hitboxes({ dhb }, { shb })
	local rock = Destructible.new(DESTRUCTIBLE_ROCK.name, pos, room, loot, hitboxes, STABLE)
	local animSettings = {}
	animSettings[INTACT] = newAnimSetting(1, { width = 60, height = 40 }, 1000, true, 1)
	animSettings[BREAKING] = newAnimSetting(10, { width = 60, height = 60 }, 0.05, false, 1)
	animSettings[BROKEN] = newAnimSetting(1, { width = 60, height = 40 }, 1000, true, 1)
	rock:addAnimations(animSettings)
	rock.hasShadow = false
	rock.breakParticle = PARTICLE_BREAK_ROCK
	return rock
end

---@param pos Vec
---@param room Room
---@return Destructible
-- cria um altar de carvão destrutível (drop de carvão)
function newCoalAltar(pos, room)
	local loot = Loot.new(newFafogo(), 1, range(1, 4), true)
	local dhb = hitbox(Rectangle.new(120, 72), vec(0, -8)) -- hitbox default
	local shb = hitbox(Rectangle.new(100, 36), vec(0, -8)) -- hitbox sólida
	local hitboxes = hitboxes({ dhb }, { shb })
	local coal = Destructible.new(COAL_ALTAR.name, pos, room, loot, hitboxes, STABLE)
	local animSettings = {}
	animSettings[INTACT] = newAnimSetting(1, { width = 48, height = 29 }, 1000, true, 1)
	animSettings[BREAKING] = newAnimSetting(7, { width = 60, height = 60 }, 0.05, false, 1)
	animSettings[BROKEN] = newAnimSetting(1, { width = 48, height = 28 }, 1000, true, 1)
	coal:addAnimations(animSettings)
	coal.hasShadow = false
	coal.breakParticle = PARTICLE_BREAK_COAL
	return coal
end

---@param pos Vec
---@param room Room
---@return Destructible
-- cria uma caixa de madeira destrutível (drop de madeira)
function newWoodBox(pos, room)
	local loot = Loot.new(newCaskin(), 1, range(1, 3), true)
	local dhb = hitbox(Rectangle.new(86, 86)) -- hitbox default
	local shb = hitbox(Rectangle.new(56, 48)) -- hitbox sólida
	local hitboxes = hitboxes({ dhb }, { shb })
	local box = Destructible.new(WOOD_BOX.name, pos, room, loot, hitboxes, STABLE)
	local animSettings = {}
	animSettings[INTACT] = newAnimSetting(1, { width = 46, height = 46 }, 1000, true, 1)
	animSettings[BREAKING] = newAnimSetting(5, { width = 72, height = 50 }, 0.08, false, 1)
	animSettings[BROKEN] = newAnimSetting(1, { width = 72, height = 50 }, 1000, true, 1)
	box:addAnimations(animSettings)
	box.hasShadow = true
	box.shadowWidth = 38
	box.breakParticle = PARTICLE_BREAK_WOOD
	return box
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
	tallGrass.breakParticle = PARTICLE_BREAK_GRASS
	return tallGrass
end
