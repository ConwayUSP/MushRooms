----------------------------------------
-- Importações de Módulos
----------------------------------------
require("modules.utils.utils")

---@class Anchor
---@field floor? number

----------------------------------------
-- Funções locais
----------------------------------------

---@param y number
---@return Anchor
-- cria uma âncora que indica onde uma sprite toca o chão
local function floorAnchor(y)
	return { floor = y }
end

----------------------------------------
-- Variáveis e Enums
----------------------------------------

---@alias anchorType string
FLOOR = "floor"

---@type table<string, Anchor>
-- tabela de âncoras indexada pelo nome da entidade.
-- **observação:** os valores aqui são relativos ao centro do sprite.
-- no futuro, outros tipos de âncora podem ser adicionados (head, hand, etc)
ANCHORS = {
	-- Items
	katana = floorAnchor(11),
	sling_shot = floorAnchor(8),
	coin = floorAnchor(8),

	-- Destrutíveis
	barrel = floorAnchor(10),
	jar = floorAnchor(4),

	-- Interagiveis
	door = floorAnchor(20),

	-- Inimigos
	spider_duck = floorAnchor(14),
	nuclear_cat = floorAnchor(16),

	-- Jogadores
	mush = floorAnchor(10),
	musho = floorAnchor(10),
	roomy = floorAnchor(11),
	shroom = floorAnchor(13),

	-- NPCs
	glob = floorAnchor(16),

	-- Obstáculos
	pillar = floorAnchor(24),
	wall = floorAnchor(27.99), -- desempate com a porta
}

----------------------------------------
-- Funções Globais
----------------------------------------

---@param obj any
---@param anchorType anchorType
---@param scale number?
---@return number
-- retorna o valor da âncora do tipo `anchorType` associada ao objeto
-- `obj` em uma determinada escala
function getAnchor(obj, anchorType, scale)
	scale = scale or 3

	local key = obj.name or obj.object.name
	key = pathlizeName(string.lower(key))
	local anchor = ANCHORS[key] and ANCHORS[key][anchorType] or nil

	if anchor then
		return anchor * scale
	end

	-- fallback padrão
	return 0
end
