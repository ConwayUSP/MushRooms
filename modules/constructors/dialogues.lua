----------------------------------------
-- Importações de Módulos
----------------------------------------
require("modules.conditions")
require("modules.systems.dialogue")

----------------------------------------
-- Funções auxiliares
----------------------------------------

function parseDialogueBlocks(path)
  assert(love.filesystem.getInfo(path), "Diálogo inexistente ou caminho incorreto: " .. path)

  local blocks = {}
  local current = {}

  for line in love.filesystem.lines(path) do
    -- linha vazia = próximo bloco
    if line == "" then
      if #current > 0 then
        table.insert(blocks, current)
        current = {}
      end
    else
      table.insert(current, line)
    end
  end

  -- último bloco
  if #current > 0 then
    table.insert(blocks, current)
    current = {}
  end

  return blocks
end

function newSequence(text, condition)
  return {
    text = text,
    idx = -1,
    triggered = false,
    condition = condition or nil,
  }
end

function buildDialogueData(blocks)
  local data = {
    intro = nil,
    loop = nil,
    event = {},
  }

  if blocks[1] then
    data.intro = newSequence(blocks[1])
  end

  if blocks[2] then
    data.loop = newSequence(blocks[2])
  end

  for i = 3, #blocks do
    local block = blocks[i]
    local key = block[1]

    local condition = getCondition(key)
    local text = { unpack(blocks[i], 2) }

    table.insert(data.event, newSequence(text, condition))
  end

  return data
end

----------------------------------------
-- Construtores
----------------------------------------

---@return Dialogue
-- cria um diálogo de teste com algumas falas simples
function globDialogue()
  local blocks = parseDialogueBlocks("assets/dialogues/glob.txt")
  local data = buildDialogueData(blocks)

  return Dialogue.new({
    intro = data.intro,
    loop = data.loop,
    event = data.event,
  })
end
