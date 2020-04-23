local set = {}

local Card = require 'card'

function set.is_set(cards)
    local n = #cards
    for dimension, _ in pairs(Card.DIMENSIONS) do
        local present_values = {}
        for _, card in pairs(cards) do
            local value = card[dimension]
            if present_values[value] then
                present_values[value] = present_values[value] + 1
            else
                present_values[value] = 1
            end
        end
        for value, count in pairs(present_values) do
            if count ~= 1 and count ~= n then 
                return false 
            end
        end
    end
    return true
end

function set.new_deck()
    local cards = {}
    for _, colour in pairs(Card.DIMENSIONS.colour) do
        for _, number in pairs(Card.DIMENSIONS.number) do
            for _, shape in pairs(Card.DIMENSIONS.shape) do
                for _, fill in pairs(Card.DIMENSIONS.fill) do
                    local card = Card.new(number, colour, shape, fill)
                    table.insert(cards, card)
                end
            end
        end
    end
    return cards
end

return set
