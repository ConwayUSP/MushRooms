----------------------------------------
-- Importações de Módulos
----------------------------------------
require("modules.conditions")
require("modules.systems.dialogue")

----------------------------------------
-- Construtores
----------------------------------------

---@return Dialogue
-- cria o diálogo do Tenkar a partir do seu arquivo com tags
function tenkarDialogue()
	return Dialogue.new(parseDialogueFile("assets/dialogues/tenkar.txt"))
end

---@return Dialogue
-- cria o diálogo do Shoum Shoum a partir do seu arquivo com tags
function shoumShoumDialogue()
	return Dialogue.new(parseDialogueFile("assets/dialogues/shoum_shoum.txt"))
end

---@return Dialogue
-- cria o diálogo do Biguiri a partir do seu arquivo com tags
function biguiriDialogue()
	return Dialogue.new(parseDialogueFile("assets/dialogues/biguiri.txt"))
end
