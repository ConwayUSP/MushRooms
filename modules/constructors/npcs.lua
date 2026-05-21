----------------------------------------
-- Importações de Módulos
----------------------------------------
require("modules.constructors.dialogues")
require("modules.entities.npc")

---@param spawnPos Vec
---@param room Room
---@return Npc
--Cria Glob, a minhoca mágica
function initGlob(spawnPos, room)
	local hb = hitbox(Circle.new(20))
	local triggerHb = hitbox(Circle.new(130))
	local hbs = hitboxes({ hb }, {}, { triggerHb })
	description = newNpcDescription(GLOB.name, "Magician", "Misterious", SEDENTARY)
	npc = Npc.new(description, spawnPos, hbs, room)
	local idleAnimSettings = newAnimSetting(1, { width = 32, height = 32 }, 0.15, true, 1)
	npc:addAnimations(idleAnimSettings)
	npc.dialogue = globDialogue()
	npc.shadowWidth = 30
	return npc
end
