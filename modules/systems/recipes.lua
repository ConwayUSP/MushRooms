---@class Recipe
---@field inputs Resource[]
---@field output Resource
---@field stationType string

Recipe = {}
Recipe.__index = Recipe
Recipe.type = RECIPE

function Recipe.new(inputs, output, stationType)
  local recipe = setmetatable({}, Recipe)
  recipe.inputs = inputs
  recipe.output = output
  recipe.stationType = stationType
  
  return recipe
end