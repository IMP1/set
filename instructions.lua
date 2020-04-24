local scene_manager = require 'scene_manager'

local instructions = {}
instructions.__index = instructions

function instructions.new()
    local self = {}
    setmetatable(self, instructions)

    return self
end

function instructions:draw()
end

return instructions