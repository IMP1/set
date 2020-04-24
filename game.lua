local scene_manager = require 'scene_manager'
local set = require 'set'

local Card = require 'card'

local MARGIN = 128
local PADDING = 16
local GRID_WIDTH = 4

local game = {}
game.__index = game

function game.new()
    local self = {}
    setmetatable(self, game)
    return self
end

function game:load()
    self.timer = 0
    self.deck = set.new_deck()
    self.board = {}
    self.selected_cards = {}
    self.found_sets = {}
    self.available_sets = 0
    for _ = 1, 12 do
        table.insert(self.board, self:draw_card())
    end
    self:refresh()
end


function game:draw_card()
    local i = math.ceil(math.random() * #self.deck)
    local card = self.deck[i]
    table.remove(self.deck, i)
    return card
end

function game:is_selected(card)
    for i, c in pairs(self.selected_cards) do
        if c == card then 
            return i
        end
    end
    return nil
end

function game:card_index(card)
    for i, c in pairs(self.board) do
        if c == card then 
            return i
        end
    end
    return nil
end

function game:refresh()
    self.available_sets = {}
    for i = 1, #self.board do
        for j = 1, #self.board do
            for k = 1, #self.board do
                if i < j and j < k then
                    if set.is_set({self.board[i], self.board[j], self.board[k]}) then
                        table.insert(self.available_sets, {i, j, k})
                    end
                end
            end
        end
    end
end

function game:toggle_card(card)
    local index = self:is_selected(card)
    if index then
        table.remove(self.selected_cards, index)
    else
        table.insert(self.selected_cards, card)
    end
    if #self.selected_cards == 3 then
        if set.is_set(self.selected_cards) then
            table.insert(self.found_sets, {
                time = self.timer,
                set = self.selected_cards,
            })
            for _, card in ipairs(self.selected_cards) do
                local i = self:card_index(card)
                local replacement = self:draw_card()
                self.board[i] = replacement
            end
            self:refresh()
        end
        self.selected_cards = {}
    end
end


function game:keyPressed(key)
    if key == "r" and love.keyboard.isDown("lctrl", "rctrl") then   
        self:load()
    end
    if key == "h" then 
        self.show_hint = not self.show_hint
    end
    if key == "s" then 
        self.show_solutions = not self.show_solutions
    end
    if key == "escape" then
        scene_manager.popScene()
    end
end

function game:mousePressed(mx, my, button)
    if button == 1 then
        local screen_width = love.graphics.getWidth()
        local screen_height = love.graphics.getHeight()
        local board_width = GRID_WIDTH * (Card.width + PADDING) + PADDING
        local board_height = (#self.board / GRID_WIDTH) * (Card.height + PADDING) + PADDING + MARGIN
        if screen_width < board_width or screen_height < board_height then
            local wx = mx * board_width / screen_width - PADDING
            local wy = my * board_height / screen_height - PADDING - MARGIN
            local i = math.ceil(wx / (Card.width + PADDING))
            local j = math.floor(wy / (Card.height + PADDING))
            local n = i + (j * GRID_WIDTH)
            self:toggle_card(self.board[n])
        else
            local cx = (screen_width - board_width) / 2
            local cy = (screen_height - board_height) / 2
            local i = math.ceil((mx - cx) / (Card.width + PADDING))
            local j = math.floor((my - cy) / (Card.height + PADDING))
            local n = i + (j * GRID_WIDTH)
            self:toggle_card(self.board[n])
        end
    end
    if button == 2 then
        self.selected_cards = {}
    end
end

function game:update(dt)
    self.timer = self.timer + dt
end

function game:draw()
    local screen_width = love.graphics.getWidth()
    local screen_height = love.graphics.getHeight()
    local board_width = GRID_WIDTH * (Card.width + PADDING) + PADDING
    local board_height = (#self.board / GRID_WIDTH) * (Card.height + PADDING) + PADDING + MARGIN
    love.graphics.push()
    if screen_width < board_width or screen_height < board_height then
        love.graphics.translate(PADDING, PADDING + MARGIN / 2)
        love.graphics.scale(screen_width / board_width, screen_height / board_height)
    else
        local cx = (screen_width - board_width) / 2
        local cy = (screen_height - board_height) / 2
        love.graphics.translate(cx, cy + MARGIN / 2)
    end
    for n, card in ipairs(self.board) do
        local selected = self:is_selected(card)
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
    local clock = string.format("%02d:%05.2f", math.floor(self.timer / 60), self.timer % 60)
    love.graphics.printf(clock, 0, 0, screen_width, "center")
    love.graphics.printf(tostring(#self.found_sets) .. " sets found.", 0, 16, screen_width, "center")
    if self.show_hint then
        love.graphics.printf(tostring(#self.available_sets) .. " sets to be found.", 0, 32, screen_width, "center")
    end
    if self.show_solutions then
        for j, solution in pairs(self.available_sets) do
            local a, b, c = unpack(solution)
            love.graphics.printf(a .. ", " .. b .. ", " .. c, 0, (j-1) * 16, screen_width, "left")
        end
    end
end

return game
