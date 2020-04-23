local set = {}

local DIMENSIONS = { "colour", "number", "shape", "fill"}

function set.is_set(cards)
    local n = #cards
    for _, dimension in pairs(DIMENSIONS) do
        local dimension_values = {}
        for _, card in pairs(cards) do
            local value = card[dimension]
            if dimension_values[value] then
                dimension_values[value] = dimension_values[value] + 1
            else
                dimension_values[value] = 1
            end
        end
        for value, count in pairs(dimension_values) do
            if count ~= 1 and count ~= n then 
                return false 
            end
        end
    end
    return true
end

return set