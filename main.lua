Card = require 'card'

function love.load()
    love.graphics.setBackgroundColor(1, 1, 1)
    timer = 0
    cards = {}
    table.insert(cards, Card.new(100, 100, 3, Card.colours.red, Card.shapes.diamond, Card.fills.striped))
    table.insert(cards, Card.new(300, 100, 2, Card.colours.green, Card.shapes.oval, Card.fills.full))
    table.insert(cards, Card.new(100, 300, 1, Card.colours.purple, Card.shapes.squiggle, Card.fills.empty))
end

function love.update(dt)
    timer = timer + dt
end

function love.mousepressed(x, y, button)
    print(x, y, button)
end

function love.draw()
    for _, card in pairs(cards) do
        card:draw()
    end
end
