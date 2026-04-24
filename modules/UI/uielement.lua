----------------------------------------
-- Classe UIScene
----------------------------------------

---@class UIElement
---@field name string
---@field subtype Type
---@field pos Vec
---@field size Size
---@field hb Hitboxes
---@field state string
---@field selected boolean
---@field spriteSheets table
---@field animations table

UIElement = {}
UIElement.__index = UIElement
UIElement.type = UI_ELEMENT

---@param name string
---@param elementType Type
---@param pos Vec
---@param size Size
---@param hitboxes Hitboxes
-- inicializa um elemento de UI com estado `IDLE` e selected = `false`
function UIElement:init(name, elementType, pos, size, hitboxes)
    self.name = name
    self.subtype = elementType
    self.pos = pos
    self.size = size
    self.hb = hitboxes
    self.state = IDLE
    self.selected = false
    self.spriteSheets = {}
    self.animations = {}
end

---@param animSettings table<string, AnimSettings>
-- adiciona animações ao elemento de UI
function UIElement:addAnimations(animSettings)
    for state, settings in pairs(animSettings) do
        local path = pngPathFormat({ "assets", "animations", "UI", self.name, state })
        addAnimation(self, path, state, settings)
    end
end

---@param dt number
-- atualiza a animação do elemento de UI
function UIElement:update(dt)
    self.animations[self.state]:update(dt)
end

-- marca o elemento de UI como `selected` e seu estado como `SELECTED`
function UIElement:select()
    self.selected = true
    self.state = SELECTED
end

-- marca o elemento de UI como não selecionado e seu estado como `IDLE`
function UIElement:deselect()
    self.selected = false
    self.animations[self.state]:reset()
    self.state = IDLE
end

---@param camera Camera
-- renderiza o elemento de UI
function UIElement:draw(camera)
    local viewPos = self.pos
    if camera then
        viewPos = camera:viewPos(self.pos)
    end
    local anim = self.animations[self.state]
    local quad = anim.frames[anim.currFrame]
    if not quad then
        print(self.state)
        print(#anim.frames)
    end
    local scale = self.size.width / anim.frameDim.width
    local offset = {
        x = anim.frameDim.width / 2,
        y = anim.frameDim.height / 2,
    }
    love.graphics.draw(self.spriteSheets[self.state], quad, viewPos.x, viewPos.y, 0, scale, scale, offset.x, offset.y)
end
