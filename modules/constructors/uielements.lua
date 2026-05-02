----------------------------------------
-- Importações de Módulos
----------------------------------------
require("modules.UI.uielement")
require("modules.UI.elements.button")
require("modules.UI.elements.image")

function newResourceItemElement(resName, invLength, canvasSize)
    local canvasCenter = vec(canvasSize.width / 2, canvasSize.height / 2)
    local leftMargin = canvasCenter.x - 300
    local topMargin = canvasCenter.y
    local col = math.fmod(invLength - 1, 5)
    local row = math.floor((invLength - 1) / 5)
    local posX = leftMargin + col * 108
    local posY = topMargin + row * 108
    local resourceEl = UIButtonElem.new(resName, vec(posX, posY), size(96, 96), nil, function()
        print("Recurso clicado: " .. resName)
    end)
    local animSettings = {}
    animSettings[IDLE] = newAnimSetting(1, size(32, 32), 1, true, 1)
    animSettings[SELECTED] = newAnimSetting(1, size(32, 32), 1, true, 1)
    for state, settings in pairs(animSettings) do
        local path = pngPathFormat({ "assets", "sprites", "resources", resName })
        addAnimation(resourceEl, path, state, settings)
    end

    return resourceEl
end

function newCraftingItemElement(resName, coordStart, vecOffset, x, y)
    local vec = vec(x * vecOffset.x, y * vecOffset.y)
    local finalPos = addVec(coordStart, vec)
    local itemEl = UIButtonElem.new(resName, finalPos, size(96, 96), nil, function()
        print("Receita clicada: " .. resName)
    end)
    local animSettings = {}
    animSettings[IDLE] = newAnimSetting(1, size(32, 32), 1, true, 1)
    animSettings[SELECTED] = newAnimSetting(1, size(32, 32), 1, true, 1)
    for state, settings in pairs(animSettings) do
        local path = pngPathFormat({ "assets", "sprites", "recipes", resName })
        addAnimation(itemEl, path, state, settings)
    end

    return itemEl
end
