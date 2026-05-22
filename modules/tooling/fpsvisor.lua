----------------------------------------
-- Contador de FPS com gráfico
----------------------------------------

local tickRate = 0.1
local fpsHistory = {}
local FPS_HIST_SIZE = 60
local fps = 0
local fpsTimer = 0

-- update no histórico de FPS
function updateFPSVisor(dt)
    fpsTimer = fpsTimer + dt
    if fpsTimer > tickRate then
        for i = math.min(FPS_HIST_SIZE, #fpsHistory + 1), 2, -1 do
            fpsHistory[i] = fpsHistory[i - 1]
        end
        fps = love.timer.getFPS()
        fpsHistory[1] = fps
        fpsTimer = 0
    end
end

-- renderizando o FPS e o gráfico
function drawFPSVisor()
    local windowW, windowH = love.window.getMode()
    -- contador de FPS
    love.graphics.setColor(0, 0, 0, 0.6)
    love.graphics.setFont(mushFont)
    local bgPos = { x = windowW - 140, y = 20 }
    love.graphics.rectangle("fill", bgPos.x, bgPos.y, 120, 50, 6, 6)
    if fps < 25 then
        love.graphics.setColor(1, 0.2, 0.3, 1.0)
    elseif fps < 50 then
        love.graphics.setColor(1, 1, 0.2)
    else
        love.graphics.setColor(0.1, 1, 0.3)
    end
    love.graphics.print(tostring(fps) .. " fps", bgPos.x + 10, bgPos.y + 10, 0, 2, 2)

    -- gráfico
    love.graphics.setLineWidth(3)
    love.graphics.setLineJoin("bevel")
    love.graphics.setLineStyle("smooth")
    local maxX = windowW - 20
    local maxY = 80
    local stepSizeX = 5
    love.graphics.setColor(0, 0, 0, 0.6)
    bgPos.x = maxX - FPS_HIST_SIZE * stepSizeX - 5
    bgPos.y = maxY - 5
    love.graphics.rectangle("fill", bgPos.x, bgPos.y, FPS_HIST_SIZE * stepSizeX + 5, 65, 6, 6)
    for i = 2, math.min(FPS_HIST_SIZE, #fpsHistory) do
        local x1 = maxX - i * stepSizeX
        local x2 = maxX - (i - 1) * stepSizeX
        local y1 = maxY + 60 - fpsHistory[i]
        local y2 = maxY + 60 - fpsHistory[i - 1]
        local fpsDiff = y1 - y2
        if fpsHistory[i - 1] < 25 then
            love.graphics.setColor(1, 0.2, 0.3, 1)
        elseif fpsHistory[i - 1] < 45 then
            love.graphics.setColor(1, 1, 0.2, 1)
        else
            love.graphics.setColor(0.1, 1, 0.3, 1)
        end
        love.graphics.line(x1, y1, x2, y2)
    end
    love.graphics.setColor(1, 1, 1, 1)
end
