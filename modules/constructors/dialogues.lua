----------------------------------------
-- Importações de Módulos
----------------------------------------
require("modules.conditions")
require("modules.systems.dialogue")

----------------------------------------
-- Construtores
----------------------------------------

---@return Dialogue
-- cria um diálogo de teste com falas simples
function tenkarDialogue()
  local blocks = parseDialogueBlocks("assets/dialogues/tenkar.txt")
  local data = buildDialogueData(blocks)

  return Dialogue.new({
    intro = data.intro,
    loop = data.loop,
    event = data.event,
  })
end

---@return Dialogue
-- cria um diálogo de teste com falas simples
function shoumShoumDialogue()
  local blocks = parseDialogueBlocks("assets/dialogues/shoum_shoum.txt")
  local data = buildDialogueData(blocks)

  return Dialogue.new({
    intro = data.intro,
    loop = data.loop,
    event = data.event,
  })
end
