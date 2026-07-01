----------------------------------------
-- Importações de Módulos
----------------------------------------
require("modules.UI.uielement")


---------------------------------------
--- LifeBarBg
---------------------------------------

---@class LifeBarBg
---@field pos Vec
---@field size Size
---@field animations table<string, Animation>
---@field spriteSheets table<string, table>
local LifeBarBg = {}
LifeBarBg.__index = LifeBarBg

function LifeBarBg.new(pos, size, name)
	local bg = setmetatable({}, LifeBarBg)
	bg.pos = vec(pos.x, pos.y)
	bg.size = size

	local path = pngPathFormat({ "assets", "animations", "UI", name, "back" })
  addAnimation(bg, path, IDLE, newAnimSetting(1, size, 0.1, false))

	return bg
end

function LifeBarBg:update(dt)
  self.animations[IDLE]:update(dt)
end

function LifeBarBg:draw(camera)
	local viewPos = self.pos
	if camera then
		viewPos = camera:viewPos(self.pos)
	end
	local anim = self.animations[IDLE]
	local quad = anim.frames[anim.currFrame]
	local scale = self.size.width / anim.frameDim.width
	love.graphics.draw(self.spriteSheets[IDLE], quad, viewPos.x, viewPos.y, 0, scale, scale, anim.offset.x, anim.offset.y)
end

--------------------------------------
--- LifeBarFront
--------------------------------------

---@class LifeBarFront
---@field pos Vec
---@field size Size
---@field frontTarget number
---@field backTarget number
---@field percent number
---@field spriteSheets table<string, table>
---@field animations table<string, Animation>
local LifeBarFront = {}
LifeBarFront.__index = LifeBarFront

function LifeBarFront.new(pos, size, name)
	local front = setmetatable({}, LifeBarFront)
  front.pos = vec(pos.x, pos.y)
	front.size = size
  front.frontTarget = 1
  front.backTarget = 1
  front.percent = 1
	
  local path = pngPathFormat({ "assets", "animations", "UI", name, "front" })
  addAnimation(front, path, IDLE, newAnimSetting(1, size, 0.1, false))

  return front
end

function LifeBarFront:update(dt, lifeCalc)
  local oldPercent = self.percent
	local hp, maxHp = lifeCalc()
  self.percent = math.max(0, (hp / maxHp))

  if oldPercent ~= self.percent then
    if self.percent < oldPercent  then
      self.frontTarget = self.percent
    else
      self.backTarget = self.percent
    end
  end

  if math.abs(self.frontTarget - self.percent) > 0.00005 then
    self.frontTarget = lerp(self.frontTarget, self.percent, 4 * dt)
  end

  if math.abs(self.backTarget - self.percent) > 0.00005 then
    self.backTarget = lerp(self.backTarget, self.percent, 4 * dt)
  end

end

function LifeBarFront:draw(camera)
	local viewPos = self.pos
	if camera then
		viewPos = camera:viewPos(self.pos)
	end
  local anim = self.animations[IDLE]
	local quad = anim.frames[anim.currFrame]

  local drawFunc = function () 
    love.graphics.draw(self.spriteSheets[IDLE], quad, viewPos.x, viewPos.y, 0, 1, 1, anim.offset.x, anim.offset.y) 
  end

  local startX = viewPos.x - anim.offset.x
  local endX = startX + anim.frameDim.width
  local width = endX - startX
  
  love.graphics.setScissor(startX, 0, self.backTarget * width, window.height)
  drawWithColorShader(drawFunc)
  love.graphics.setScissor()

  love.graphics.setScissor(startX, 0, self.frontTarget * width, window.height)
  drawFunc()
  love.graphics.setScissor()
end

----------------------------------------
-- Classe UILifeBarElem
----------------------------------------

---@class UILifeBarElem : UIElement
---@field lifeCalc fun()
---@field front LifeBarFront
---@field back LifeBarBg
---@field canvasSize Size
UILifeBarElem = setmetatable({}, { __index = UIElement })
UILifeBarElem.__index = UILifeBarElem

function UILifeBarElem.new(name, pos, size, canvasSize, lifeCalc)
	local lifeBar = setmetatable({}, UILifeBarElem)
	---@diagnostic disable-next-line
	lifeBar:init(name, UI_BUTTON_ELEM, pos, size)
	lifeBar.lifeCalc = lifeCalc or function() end
	lifeBar.front = LifeBarFront.new(pos, size, name)
	lifeBar.back = LifeBarBg.new(pos, size, name)
	lifeBar.canvasSize = canvasSize

	return lifeBar
end

function UILifeBarElem:update(dt)
	self.front:update(dt, self.lifeCalc)
	self.back:update(dt)
end

function UILifeBarElem:draw(camera)
  if self.front.frontTarget <= 0 or self.front.backTarget <= 0 then
    return
  end

  love.graphics.setColor(1, 1, 1, 0.5)

  self.back:draw(camera)
  self.front:draw(camera)

  love.graphics.setColor(1, 1, 1, 1)
end