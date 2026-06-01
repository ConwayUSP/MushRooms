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
-- **observação:** os valores aqui são referentes a posição relativa do 
-- ÚLTIMO pixel do sprite (que possui algum conteudo) em relação ao centro.
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
	door_up = floorAnchor(20),
	door_left = floorAnchor(10),
	door_right = floorAnchor(10),
	turtle = floorAnchor(10),

	-- Inimigos
	spider_duck = floorAnchor(14),
	nuclear_cat = floorAnchor(16),

	-- Jogadores
	mush = floorAnchor(14),
	musho = floorAnchor(14),
	roomy = floorAnchor(13),
	shroom = floorAnchor(13),

	-- NPCs
	glob = floorAnchor(16),

	-- Obstáculos
	pillar = floorAnchor(17),
	wall_up = floorAnchor(31.2), -- desempate com a porta
	wall_left_back = floorAnchor(130),
	wall_left_front = floorAnchor(200),
	wall_right_back = floorAnchor(130),
	wall_right_front = floorAnchor(200),

	-- Produtos
	chest = floorAnchor(10),
	firecamp = floorAnchor(10),

	-- Attacks
	nuclear_shot = floorAnchor(4),
	pebble_shot = floorAnchor(4),
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
	scale = scale or obj.scale or 3

	local key =  obj.object and obj.object.name or obj.name
	key = pathlizeName(string.lower(key))
	local anchor = ANCHORS[key] and ANCHORS[key][anchorType] or nil

	-- caso a string tenha um sufixo numérico
	if not anchor then
		local baseKey = string.gsub(key, "%d+$", "")
		if baseKey ~= key then
			anchor = ANCHORS[baseKey] and ANCHORS[baseKey][anchorType] or nil
		end
	end

	if anchor then
		return anchor * scale
	end

	-- fallback padrão
	return 15 * scale
end
