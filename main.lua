local set = require 'set'

local Card = require 'card'

local MARGIN = 64
local PADDING = 16
local GRID_WIDTH = 5

function love.load()
    love.graphics.setBackgroundColor(1, 1, 1)
    timer = 0
    text = ""
    cards = {}
    for i = 1, 15 do
        table.insert(cards, Card.random())
    end
    selected_cards = {}
end

function love.update(dt)
    timer = timer + dt
end

local function is_selected(card)
    for i, c in pairs(selected_cards) do
        if c == card then 
            return i
        end
    end
    return nil
end

local function toggle_card(card)
    local index = is_selected(card)
    if index then
        table.remove(selected_cards, index)
    else
        table.insert(selected_cards, card)
    end
    if #selected_cards == 3 then
        if set.is_set(selected_cards) then
            text = "SET!"
        else
            text = "..."
        end
    else
        text = ""
    end
end

function love.mousepressed(mx, my, button)
    if button == 1 then
        local screen_width = love.graphics.getWidth()
        local screen_height = love.graphics.getHeight()
        local board_width = GRID_WIDTH * (Card.width + PADDING) + PADDING
        local board_height = (#cards / GRID_WIDTH) * (Card.height + PADDING) + PADDING + MARGIN
        if screen_width < board_width or screen_height < board_height then
            local wx = mx * board_width / screen_width - PADDING
            local wy = my * board_height / screen_height - PADDING - MARGIN
            local i = math.ceil(wx / (Card.width + PADDING))
            local j = math.floor(wy / (Card.height + PADDING))
            local n = i + (j * GRID_WIDTH)
            toggle_card(cards[n])
        else

        end
    end
    if button == 2 then
        selected_cards = {}
    end
end

function love.draw()
    local screen_width = love.graphics.getWidth()
    local screen_height = love.graphics.getHeight()
    local board_width = GRID_WIDTH * (Card.width + PADDING) + PADDING
    local board_height = (#cards / GRID_WIDTH) * (Card.height + PADDING) + PADDING + MARGIN
    love.graphics.push()
    if screen_width < board_width or screen_height < board_height then
        love.graphics.translate(PADDING, PADDING + MARGIN)
        love.graphics.scale(screen_width / board_width, screen_height / board_height)
    else
        local cx = (screen_width - board_width) / 2
        local cy = (screen_height - board_height) / 2
        love.graphics.translate(cx, cy + MARGIN)
    end
    for n, card in ipairs(cards) do
        local selected = is_selected(card)
        local i = (n-1) % GRID_WIDTH
        local j = math.floor((n-1) / GRID_WIDTH)
        local x = i * (Card.width + PADDING)
        local y = j * (Card.height + PADDING)
        if selected then
            love.graphics.setColor(0, 0, 0)
            love.graphics.rectangle("fill", x - 4, y - 4, Card.width + 8, Card.height + 8, 6, 6)
            love.graphics.setColor(1, 1, 1)
            love.graphics.rectangle("fill", x, y, Card.width, Card.height, 6, 6)
        end
        card:draw(x, y)
    end
    love.graphics.pop()
    love.graphics.setColor(0, 0, 0)
    -- TODO: Print time as minutes and seconds
    local clock = ("%02.2f"):format(timer)
    love.graphics.printf(clock, 0, 0, screen_width, "center")
    love.graphics.printf(text, 0, 16, screen_width, "center")
end
