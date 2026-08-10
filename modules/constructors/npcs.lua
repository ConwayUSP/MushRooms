----------------------------------------
-- Importações de Módulos
----------------------------------------
require("modules.constructors.dialogues")
require("modules.entities.npc")

---@param spawnPos Vec
---@param room Room
---@return Npc
--Cria Tenkar, o curandeiro
function initTenkar(spawnPos, room)
	local hb = hitbox(Circle.new(20))
	local triggerHb = hitbox(Circle.new(130))
	local hbs = hitboxes({ hb }, {}, { triggerHb })
	description = newNpcDescription(
		TENKAR.name,
		"Curandeiro",
		"Uma criatura chifruda carregando um frasco. Ele parece cansado.",
		SEDENTARY)
	npc = Npc.new(description, spawnPos, hbs, room)
	local idleAnimSettings = newAnimSetting(4, { width = 64, height = 50 }, 0.3, true)
	local speakAnimSettings = newAnimSetting(7, { width = 50, height = 50 }, 0.3, true)
	npc:addAnimations(idleAnimSettings, speakAnimSettings)
	npc.dialogue = tenkarDialogue()
	npc.shadowWidth = 30
	return npc
end

---@param spawnPos Vec
---@param room Room
---@return Npc
--Cria Shoum Shoum, o mercador de artefatos
function initShoumShoum(spawnPos, room)
	local hb = hitbox(Circle.new(20))
	local triggerHb = hitbox(Circle.new(130))
	local hbs = hitboxes({ hb }, {}, { triggerHb })
	description = newNpcDescription(
		SHOUM_SHOUM.name,
		"Comerciante",
		"Um caracol alegre porém com uma ganância interminável.",
		SEDENTARY)
	npc = Npc.new(description, spawnPos, hbs, room)
	local idleAnimSettings = newAnimSetting(2, { width = 50, height = 50 }, 0.5, true)
	local speakAnimSettings = newAnimSetting(2, { width = 50, height = 50 }, 0.4, true)
	npc:addAnimations(idleAnimSettings, speakAnimSettings)
	npc.dialogue = shoumShoumDialogue()
	npc.shadowWidth = 30
	return npc
end
