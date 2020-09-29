local scene_manager = require 'scene_manager'

local Game = require 'game'
-- TODO: Have a challenge mode where there are 6 sets and the cards aren't replaced.
local Challenge = require 'game'
local Instructions = require 'instructions'

local title = {}
title.__index = title

local PADDING = 64
local BUTTONS = {
    {
        text = "Play",
        action = function()
            scene_manager.pushScene(Game.new())
        end,
    },
    {
        text = "Challenge",
        action = function()
            scene_manager.pushScene(Challenge.new())
        end,
    },
    {
        text = "Learn",
        action = function()
            scene_manager.pushScene(Instructions.new())
        end,
    },
    {
        text = "Quit",
        action = function()
            love.event.quit()
        end,
    },
}

function title.new()
    local self = {}
    setmetatable(self, title)

    return self
end

function title:mousePressed(mx, my, button)
    if my >= love.graphics.getHeight() - 128 and my <= love.graphics.getHeight() - 64 then
        local n = 1
        -- TODO: Find correct button (and check if actually over it)
        BUTTONS[n].action()
    end
end

function title:draw()
    love.graphics.setColor(0, 0, 0)
    local y = love.graphics.getHeight() - 128
    local w = (love.graphics.getWidth() - PADDING * 2) / #BUTTONS
    for i, button in pairs(BUTTONS) do
        love.graphics.rectangle("line", PADDING + (i-1) * w + PADDING, y, w - (PADDING * 2), 64)
        love.graphics.printf(button.text, PADDING + (i-1) * w, y + 24, w, "center")
    end
end

return title