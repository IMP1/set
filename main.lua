local scene_manager = require 'scene_manager'
local Title = require 'title'

function love.load()
    love.graphics.setBackgroundColor(1, 1, 1)
    scene_manager.hook()
    scene_manager.setScene(Title.new())
end

function love.update(dt)
   scene_manager.update(dt)
end

function love.draw()
   scene_manager.draw()
end
