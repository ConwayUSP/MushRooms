----------------------------------------
-- Importações de Módulos
----------------------------------------
require("modules.engine.camera")
require("modules.systems.dialogue")
require("modules.utils.anchors")

----------------------------------------
-- Variáveis
----------------------------------------

local drawList = {}
local drawListPool = {}
local shadows = {}
local shadowsPool = {}
local bgList = {}
local bgListPool = {}

----------------------------------------
-- Funções locais
----------------------------------------

---@param entity Entity
---@param yPos number
---@param isAnimVFX? boolean
---@param isParticleVFX? boolean
-- tira uma tabela do pool para colocar na lista de draw
-- se não tiver mais nenhuma tabela livre no pool, cria uma nova (caso em que aloca memória)
local function addEntityToDrawList(entity, yPos, isAnimVFX, isParticleVFX)
	local item = drawListPool[#drawListPool]
	if item then
		drawListPool[#drawListPool] = nil
	else
		item = {}
	end

	item.it = entity
	item.y = yPos
	item.isAnimVFX = isAnimVFX
	item.isParticleVFX = isParticleVFX
	drawList[#drawList + 1] = item
end

---@param sx number
---@param sy number
---@param rx number
---@param ry number
-- tira uma tabela de sombra do pool para colocar na lista de draw das sombras
local function addShadow(sx, sy, rx, ry)
	local s = shadowsPool[#shadowsPool]
	if s then
		shadowsPool[#shadowsPool] = nil
	else
		s = {}
	end
	s.sx, s.sy = sx, sy
	s.rx, s.ry = rx, ry
	shadows[#shadows + 1] = s
end

--- @param entity Entity
--- @param yPos number
-- tira uma tabela do pool para colocar na lista de draw do background
-- se não tiver mais nenhuma tabela livre no pool, cria uma nova (caso em que aloca memória)
local function addEntityToBgList(entity, yPos)
	local item = bgListPool[#bgListPool]
	if item then
		bgListPool[#bgListPool] = nil
	else
		item = {}
	end

	item.it = entity
	item.y = yPos

	bgList[#bgList + 1] = item
end

----------------------------------------
-- Funções Globais
----------------------------------------

---@param camera Camera
-- renderiza as salas na perspectiva da `camera`
function renderRooms(camera)
	for i = rooms.minIndex, rooms.maxIndex do
		for j = rooms[i].minIndex, rooms[i].maxIndex do
			local r = rooms[i][j]
			if not r then
				goto nextroom
			end
			local roomViewPos = addVec(vec(camera:viewPos(r.limits.p1)), vec(Room.spacingH / 2, Room.spacingV / 2))
			-- love.graphics.draw(r.sprites.floor, roomViewPos.x, roomViewPos.y, 0, 3, 3)
			love.graphics.setColor(25 / 255, 21 / 255, 83 / 255, 1)
			love.graphics.rectangle("fill", roomViewPos.x - 1000, roomViewPos.y - 1000, 2000, 2000)
			love.graphics.setColor(1, 1, 1, 1)

			::nextroom::
		end
	end
end

----------------------------------------
-- Funções de Renderização Global
----------------------------------------

---@param camera Camera
-- renderiza os links de todas as salas na perspectiva da `camera`
function renderLinks(camera)
	for _, r in activeRooms:iter() do
		r.linkManager:draw(camera)
	end
end

---@param camera Camera
-- renderiza as demais entidades (além das salas) na perspecitiva da `camera`
function renderEntities(camera)
	-- resetando o pool e as listas de draw
	for i = #drawList, 1, -1 do
		drawListPool[#drawListPool + 1] = drawList[i]
		drawList[i] = nil
	end
	for i = #bgList, 1, -1 do
		bgListPool[#bgListPool + 1] = bgList[i]
		bgList[i] = nil
	end
	for i = #shadows, 1, -1 do
		shadowsPool[#shadowsPool + 1] = shadows[i]
		shadows[i] = nil
	end

	for _, r in activeRooms:iter() do
		-- adiciona destrutíveis
		for _, d in pairs(r.destructibles) do
			addEntityToDrawList(d, d.pos.y + getAnchor(d, FLOOR))
		end
		-- adiciona objetos interativos
		for _, i in pairs(r.interactives) do
			addEntityToDrawList(i, i.pos.y + getAnchor(i, FLOOR))
		end
		-- adiciona portas
		for _, d in pairs(r:getDoors()) do
			addEntityToDrawList(d, d.pos.y + getAnchor(d, FLOOR))
		end
		-- adiciona paredes
		for _, w in pairs(r:getWalls()) do
			addEntityToDrawList(w, w.pos.y + getAnchor(w, FLOOR))
		end
		-- adiciona drops
		for _, i in pairs(r.drops) do
			-- esse terceiro argumento é dropScale
			addEntityToDrawList(
				i,
				i.pos.y + getAnchor(i, FLOOR, (i.object and i.object.type == RESOURCE) and 1.875 or 3)
			)
		end
		-- adiciona inimigos
		for _, e in pairs(r.enemies) do
			addEntityToDrawList(e, e.pos.y + getAnchor(e, FLOOR))
			-- adiciona ataques de inimigos
			for _, a in pairs(e.atk) do
				for _, ev in pairs(a.events) do
					addEntityToDrawList(ev, ev.pos.y + getAnchor(ev, FLOOR))
				end
			end
		end
		-- adiciona NPCs
		for _, npc in pairs(r.npcs) do
			addEntityToDrawList(npc, npc.pos.y + getAnchor(npc, FLOOR))
		end
		-- adiciona obstáculos
		for _, o in pairs(r.obstacles) do
			local y = o.pos.y + getAnchor(o, FLOOR)

			if o.isBg then
				addEntityToBgList(o, y)
			else
				addEntityToDrawList(o, y)
			end
		end
	end

	-- adiciona jogadores e suas possíveis armas e construções
	for _, p in pairs(players) do
		addEntityToDrawList(p, p.pos.y + getAnchor(p, FLOOR))

		if p.weapon then
			addEntityToDrawList(
				p.weapon,
				p.pos.y + getAnchor(p, FLOOR) + invertFirstAndSecondQuadrants(p.weapon.rotation) * 4
			)
		end

		for _, w in pairs(p.weapons) do
			for _, e in pairs(w.atk.events) do
				addEntityToDrawList(e, e.pos.y + getAnchor(p, FLOOR))
			end
		end

		if p.building then
			local b = p.building
			addEntityToDrawList(p.building, p.building.pos.y + getAnchor(p.building, FLOOR))
		end
	end

	-- construindo sombras separadamente para não mutar drawList durante iteração
	for _, obj in ipairs(drawList) do
		if obj.it and obj.it.hasShadow then
			local sx = (obj.it.pos and obj.it.pos.x) or 0
			local sy = obj.y - 1
			local frameWidth
			local scale = obj.it.scale or 3
			if obj.it.shadowWidth then
				frameWidth = obj.it.shadowWidth * scale
			else
				frameWidth = 16 * scale
			end

			-- largura da sombra proporcional à largura do sprite
			local rx = frameWidth / 2
			local ry = rx * 0.4

			addShadow(sx, sy, rx, ry)
		end
	end

	-- adicionando os VFX
	for _, particles in pairs(globalVFXManager.particlesInst) do
		for _, instance in pairs(particles) do
			local _, y = instance.particle:getPosition()
			addEntityToDrawList(instance, y, false, true)
		end
	end
	for _, anim in pairs(globalVFXManager.animInstances) do
		addEntityToDrawList(anim, anim.pos.y, true, false)
	end

	-- ordena os obstáculos de background por posição Y
	table.sort(bgList, function(a, b)
		return a.y < b.y
	end)

	-- ordena por posição Y
	table.sort(drawList, function(a, b)
		return a.y < b.y
	end)

	-- desenha os obstáculos de background
	for _, obj in ipairs(bgList) do
		obj.it:draw(camera)
	end

	-- renderiza links de todas as salas
	renderLinks(camera)

	-- desenha as sombras das entidades
	love.graphics.setColor(0, 0, 0.1, 1.0)
	love.graphics.setShader(ditherShadowShader)
	for _, s in ipairs(shadows) do
		local viewX, viewY = camera:viewPos(vec(s.sx, s.sy))
		ditherShadowShader:send("shadow_center", { viewX, viewY })
		ditherShadowShader:send("shadow_radii", { s.rx, s.ry })
		ditherShadowShader:send("time", love.timer.getTime())
		ditherShadowShader:send("zoom", camera.zoom)
		ditherShadowShader:send("viewport_size", { camera.viewport.width, camera.viewport.height })
		love.graphics.circle("fill", viewX, viewY, s.rx)
	end
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.setShader()

	love.graphics.setBlendMode("alpha")

	-- desenha as entidades e VFXs na ordem correta
	for _, obj in ipairs(drawList) do
		if obj.isAnimVFX then
			globalVFXManager:drawAnimation(obj.it, camera)
		elseif obj.isParticleVFX then
			globalVFXManager:drawParticleInstance(obj.it, camera)
		else
			obj.it:draw(camera)
		end
	end
end

---@param drawFunc function
---@param color table
---@param lightLevels number
---@param gridSize number
function renderWithLight(drawFunc, color, lightLevels, gridSize)
	love.graphics.setShader(glowShader)
	glowShader:send("glow_color", color)
	glowShader:send("steps", lightLevels)
	glowShader:send("grid_size", gridSize)
	glowShader:send("time", love.timer.getTime())
	drawFunc()
	love.graphics.setShader()
end

---@param camera Camera
-- renderiza iluminações, como as de tochas ou dos players
function renderLighting(camera)
	for _, r in activeRooms:iter() do
		-- Iluminações de obstáculos
		for _, obs in pairs(r.obstacles) do
			if obs.emitsLight then
				local viewX, viewY = camera:viewPos(obs.pos)
				local drawFunc = function()
					love.graphics.draw(
						assetManager.emptyTex,
						viewX - obs.glowRadius / 2,
						viewY - obs.glowRadius / 2,
						0,
						obs.glowRadius,
						obs.glowRadius
					)
				end
				renderWithLight(drawFunc, { 0.9, 0.2, 0.4, 0.66 }, lightLevels, obs.glowRadius / 5)
			end
		end
	end

	-- Player
	for _, p in pairs(players) do
		local viewX, viewY = camera:viewPos(p.pos)
		local glowRadius = p.glowRadius or 600
		local lightLevels = p.lightLevels or 20
		local drawFunc = function()
			love.graphics.draw(
				assetManager.emptyTex,
				viewX - glowRadius / 2,
				viewY - glowRadius / 2,
				0,
				glowRadius,
				glowRadius
			)
		end
		renderWithLight(drawFunc, { 0.7, 0.7, 0.9, 0.15 }, lightLevels, glowRadius / 5)
	end
end

function renderVignette(camera)
	-- renderizando a vinheta escura nas bordas da câmera
	love.graphics.setShader(darkVignetteShader)
	love.graphics.draw(assetManager.emptyTex, 0, 0, 0, camera.viewport.width, camera.viewport.height)
	love.graphics.setShader()
end

function renderPlayerUIs(camera)
	camera.playerAttached.uiManager:draw(camera)
	camera.playerAttached.room.uiManager:draw(camera)
end

---@param camera Camera
-- renderiza os diálogos ativos na perspectiva da `camera`
function renderDialogues(camera)
	for _, dialogue in pairs(DialogueManager.dialogues) do
		if dialogue.active then
			dialogue:draw(camera)
		end
	end
end

---@param camera Camera
-- renderiza as hitboxes de todas as entidades na perspectiva da `camera`
function renderHitboxes(camera)
	if not debugMode then
		return
	end

	---@type table<string, table<Entity, Hitboxes>>
	local registry = collisionManager.registry

	love.graphics.setLineWidth(3)
	for _, reg in pairs(registry) do
		for entity, hitboxes in pairs(reg) do
			renderSolids(camera, hitboxes.solids, entity)
			renderDefaults(camera, hitboxes.default, entity)
			renderTriggers(camera, hitboxes.triggers, entity)
		end
	end
	love.graphics.setLineWidth(1)
end

---@param camera Camera
---@param hitboxes Hitbox[]
---@param entity Entity
-- renderiza as hitboxes sólidas na perspectiva da `camera`
function renderSolids(camera, hitboxes, entity)
	if #hitboxes == 0 then
		return
	end

	love.graphics.setColor(1, 0.3, 0.3, 0.8)
	for _, hb in ipairs(hitboxes) do
		renderByShape(camera, hb, entity)
	end
	love.graphics.setColor(1, 1, 1, 1)
end

---@param camera Camera
---@param hitboxes Hitbox[]
---@param entity Entity
-- renderiza as hitboxes padrão na perspectiva da `camera`
function renderDefaults(camera, hitboxes, entity)
	if #hitboxes == 0 then
		return
	end

	love.graphics.setColor(0.3, 0.3, 1, 0.8)
	for _, hb in ipairs(hitboxes) do
		renderByShape(camera, hb, entity)
	end
	love.graphics.setColor(1, 1, 1, 1)
end

---@param camera Camera
---@param hitboxes Hitbox[]
---@param entity Entity
-- renderiza as hitboxes de gatilho na perspectiva da `camera`
function renderTriggers(camera, hitboxes, entity)
	if #hitboxes == 0 then
		return
	end

	love.graphics.setColor(0.3, 1, 0.3, 0.8)
	for _, hb in ipairs(hitboxes) do
		renderByShape(camera, hb, entity)
	end
	love.graphics.setColor(1, 1, 1, 1)
end

function renderByShape(camera, hitbox, entity)
	local worldHb = buildWorldHitbox(hitbox, entity.pos)

	if worldHb.shape.shape == CIRCLE then
		renderCircleHitbox(camera, worldHb)
	elseif worldHb.shape.shape == RECTANGLE then
		renderRectangleHitbox(camera, worldHb)
	elseif worldHb.shape.shape == LINE then
		renderLineHitbox(camera, worldHb)
	end
end

---@param camera Camera
---@param hitbox CircleHitbox
--- renderiza a hitbox circular na perspectiva da `camera`
function renderCircleHitbox(camera, hitbox)
	local viewX, viewY = camera:viewPos(hitbox.offset)
	love.graphics.circle("line", viewX, viewY, hitbox.shape.radius)
end

---@param camera Camera
---@param hitbox RectHitbox
--- renderiza a hitbox retangular na perspectiva da `camera`
function renderRectangleHitbox(camera, hitbox)
	local viewX, viewY = camera:viewPos(hitbox.offset)
	love.graphics.rectangle(
		"line",
		viewX - hitbox.shape.width / 2,
		viewY - hitbox.shape.height / 2,
		hitbox.shape.width,
		hitbox.shape.height
	)
end

---@param camera Camera
---@param hitbox LineHitbox
--- renderiza a hitbox em formato de linha na perspectiva da `camera` (precisa de revisão)
function renderLineHitbox(camera, hitbox)
	local viewX, viewY = camera:viewPos(hitbox.offset)
	local endPos = addVec(hitbox.offset, polarToVec(hitbox.shape.angle, hitbox.shape.length))
	local viewEndX, viewEndY = camera:viewPos(endPos)
	love.graphics.line(viewX, viewY, viewEndX, viewEndY)
end
