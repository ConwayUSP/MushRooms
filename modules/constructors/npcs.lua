----------------------------------------
-- Importações de Módulos
----------------------------------------
require("modules.constructors.dialogues")
require("modules.utils.types")
require("modules.entities.npc")

---@param spawnPos Vec
---@param room Room
---@return Npc
-- cria Tenkar, o curandeiro
function initTenkar(spawnPos, room)
	local hb = hitbox(Circle.new(20))
	local triggerHb = hitbox(Circle.new(130))
	local hbs = hitboxes({ hb }, {}, { triggerHb })
	description = newNpcDescription(
		TENKAR.name,
		"Curandeiro",
		"Uma criatura chifruda carregando um frasco. Ele parece cansado.",
		SEDENTARY
	)
	npc = Npc.new(description, spawnPos, hbs, room)
	local animSettings = {}
	animSettings[IDLE] = newAnimSetting(4, { width = 64, height = 50 }, 0.3, true)
	animSettings[SPEAKING] = newAnimSetting(7, { width = 50, height = 50 }, 0.3, true)
	npc:addAnimations(animSettings)
	npc.dialogue = tenkarDialogue()
	npc.shadowWidth = 55
	npc.shadowDist = 22
	return npc
end

---@param spawnPos Vec
---@param room Room
---@return Npc
-- cria Shoum Shoum, o mercador de artefatos
function initShoumShoum(spawnPos, room)
	local hb = hitbox(Circle.new(20))
	local triggerHb = hitbox(Circle.new(130))
	local hbs = hitboxes({ hb }, {}, { triggerHb })
	description = newNpcDescription(
		SHOUM_SHOUM.name,
		"Comerciante",
		"Um caracol alegre porém com uma ganância interminável.",
		SEDENTARY
	)
	npc = Npc.new(description, spawnPos, hbs, room)
	local animSettings = {}
	animSettings[IDLE] = newAnimSetting(2, { width = 50, height = 50 }, 0.5, true)
	animSettings[SPEAKING] = newAnimSetting(2, { width = 50, height = 50 }, 0.4, true)
	npc:addAnimations(animSettings)
	npc.dialogue = shoumShoumDialogue()
	npc.shadowWidth = 70
	return npc
end

---@param spawnPos Vec
---@param room Room
---@return Npc
-- cria Biguiri... o que ele está fazendo aqui?
function initBiguiri(spawnPos, room)
	local triggerHb = hitbox(Circle.new(250), vec(0, 100))
	local hbs = hitboxes({ }, {}, { triggerHb })
	description = newNpcDescription(BIGUIRI.name, "Easter Egg", "Um rapaz muito maneiro", SEDENTARY)
	npc = Npc.new(description, spawnPos, hbs, room)
	local animSettings = {}
	animSettings[IDLE] = newAnimSetting(16, { width = 120, height = 120 }, 0.4, true, 1, 4, vec(0, -12))
	animSettings[SPEAKING] = newAnimSetting(16, { width = 120, height = 120 }, 0.4, true, 1, 4, vec(0, -12))
	npc:addAnimations(animSettings)
	npc.dialogue = biguiriDialogue()
	npc.shadowWidth = 80
	npc.shadowDist = -40
	return npc
end
