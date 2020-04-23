local set = require 'set'

local Card = require 'card'

local MARGIN = 128
local PADDING = 16
local GRID_WIDTH = 4

local function draw_card()
    local i = math.ceil(math.random() * #deck)
    local card = deck[i]
    table.remove(deck, i)
    return card
end

local function is_selected(card)
    for i, c in pairs(selected_cards) do
        if c == card then 
            return i
        end
    end
    return nil
end

local function card_index(card)
    for i, c in pairs(board) do
        if c == card then 
            return i
        end
    end
    return nil
end

local function refresh()
    available_sets = {}
    for i = 1, #board do
        for j = 1, #board do
            for k = 1, #board do
                if i < j and j < k then
                    if set.is_set({board[i], board[j], board[k]}) then
                        table.insert(available_sets, {i, j, k})
                    end
                end
            end
        end
    end
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
            table.insert(found_sets, {
                time = timer,
                set = selected_cards,
            })
            for _, card in ipairs(selected_cards) do
                local i = card_index(card)
                local replacement = draw_card()
                board[i] = replacement
            end
            refresh()
        end
        selected_cards = {}
    end
end

function love.load()
    love.graphics.setBackgroundColor(1, 1, 1)
    timer = 0
    deck = set.new_deck()
    board = {}
    selected_cards = {}
    found_sets = {}
    available_sets = 0
    for _ = 1, 12 do
        table.insert(board, draw_card())
    end
    refresh()
end

function love.update(dt)
    timer = timer + dt
end

function love.mousepressed(mx, my, button)
    if button == 1 then
        local screen_width = love.graphics.getWidth()
        local screen_height = love.graphics.getHeight()
        local board_width = GRID_WIDTH * (Card.width + PADDING) + PADDING
        local board_height = (#board / GRID_WIDTH) * (Card.height + PADDING) + PADDING + MARGIN
        if screen_width < board_width or screen_height < board_height then
            local wx = mx * board_width / screen_width - PADDING
            local wy = my * board_height / screen_height - PADDING - MARGIN
            local i = math.ceil(wx / (Card.width + PADDING))
            local j = math.floor(wy / (Card.height + PADDING))
            local n = i + (j * GRID_WIDTH)
            toggle_card(board[n])
        else
            local cx = (screen_width - board_width) / 2
            local cy = (screen_height - board_height) / 2
            local i = math.ceil((mx - cx) / (Card.width + PADDING))
            local j = math.floor((my - cy) / (Card.height + PADDING))
            local n = i + (j * GRID_WIDTH)
            toggle_card(board[n])
        end
    end
    if button == 2 then
        selected_cards = {}
    end
end

function love.keypressed(key)
    if key == "r" and love.keyboard.isDown("lctrl", "rctrl") then   
        love.load()
    end
    if key == "h" then 
        show_hint = not show_hint
    end
    if key == "s" then 
        show_solutions = not show_solutions
    end
end

function love.draw()
    local screen_width = love.graphics.getWidth()
    local screen_height = love.graphics.getHeight()
    local board_width = GRID_WIDTH * (Card.width + PADDING) + PADDING
    local board_height = (#board / GRID_WIDTH) * (Card.height + PADDING) + PADDING + MARGIN
    love.graphics.push()
    if screen_width < board_width or screen_height < board_height then
        love.graphics.translate(PADDING, PADDING + MARGIN / 2)
        love.graphics.scale(screen_width / board_width, screen_height / board_height)
    else
        local cx = (screen_width - board_width) / 2
        local cy = (screen_height - board_height) / 2
        love.graphics.translate(cx, cy + MARGIN / 2)
    end
    for n, card in ipairs(board) do
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
    love.graphics.printf(tostring(#found_sets) .. " sets found.", 0, 16, screen_width, "center")
    if show_hint then
        love.graphics.printf(tostring(#available_sets) .. " sets to be found.", 0, 32, screen_width, "center")
    end
    if show_solutions then
        for j, solution in pairs(available_sets) do
            local a, b, c = unpack(solution)
            love.graphics.printf(a .. ", " .. b .. ", " .. c, 0, (j-1) * 16, screen_width, "left")
        end
    end
end
