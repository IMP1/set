local card = {}
card.__index = card

card.colours = {
    red    = {1, 0, 0},
    green  = {0, 1, 0},
    purple = {0.6, 0, 1},
}

local PI = math.pi

card.shapes = {
    diamond  = {0, -1, 1, 0, 0, 1, -1, 0},
    oval     = {0, -1, 0.3, -0.9, 0.5, -0.75, 0.8, -0.4, 0.8, 0.4, 0.5, 0.75, 0.3, 0.9, 0, 1, -0.3, 0.9, -0.5, 0.75, -0.8, 0.4, -0.8, -0.4, -0.5, -0.75, -0.3, -0.9},
    squiggle = {0, -1, 1, 0, 0, 1, -1, 0},
    diamond  = function(fill)
        love.graphics.polygon(fill, 0, -card.shape_height, card.shape_width, 0, 0, card.shape_height, -card.shape_width, 0)
    end,
    oval = function(fill)
        local r = card.shape_width / 2
        love.graphics.arc(fill, "open", 0, r - card.shape_height, r * 2, -PI, 0)
        if fill == "line" then
            love.graphics.line(-card.shape_width, r - card.shape_height, -card.shape_width, card.shape_height - r)
            love.graphics.line(card.shape_width, r - card.shape_height, card.shape_width, card.shape_height - r)
        else
            love.graphics.rectangle("fill", -card.shape_width, r - card.shape_height, card.shape_width * 2, (card.shape_height - r) * 2)
        end
        love.graphics.arc(fill, "open", 0, card.shape_height - r, r * 2, 0, PI)
    end,
    squiggle = function(fill)
        -- local path = {}
        -- love.graphics.polygon(fill, path)
        love.graphics.arc(fill, "open", -card.shape_width, card.shape_width - card.shape_height, card.shape_width, -5 * PI / 8, PI / 8)
        love.graphics.arc(fill, "open", card.shape_width * PI / 5, -card.shape_width * PI / 8, card.shape_width, 5 * PI / 8, 10 * PI / 8)
    end
}

card.fills = {
    full    = 0,
    empty   = 1,
    striped = 2,
}

card.numbers = {
    [1] = {0},
    [2] = {-20, 20},
    [3] = {-30, 0, 30},
}

local STRIPE_COUNT = 10

card.width  = 96 -- pixels
card.height = 128 -- pixels

card.shape_width  = 12 -- pixels
card.shape_height = 32 -- pixels

function card.new(x, y, number, colour, shape, fill)
    local self = {}
    setmetatable(self, card)

    self.x = x
    self.y = y
    self.colour = colour
    self.number = number
    self.shape = shape
    self.fill = fill

    return self
end

function card:drawShape()
    -- local polygon = {}
    -- for i = 1, #self.shape, 2 do
        -- table.insert(polygon, self.shape[i] * card.shape_width)
        -- table.insert(polygon, self.shape[i + 1] * card.shape_height)
    -- end
    local fill = "line"
    if self.fill == card.fills.striped then
        love.graphics.stencil(function() 
            self.shape("fill")
            -- love.graphics.polygon("fill", polygon)
        end)
        love.graphics.setStencilTest("greater", 0)
        for i = 1, STRIPE_COUNT + 1 do
            local y = (i - STRIPE_COUNT / 2 - 1) * (self.shape_height * 2) / STRIPE_COUNT
            love.graphics.line(-card.shape_width, y, card.shape_width, y)
        end
        love.graphics.setStencilTest()
    end
    if self.fill == card.fills.full then
        fill = "fill"
    end
    self.shape(fill)
    -- love.graphics.polygon(fill, polygon)
end

function card:draw()
    love.graphics.push()
    love.graphics.translate(self.x, self.y)
    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle("line", 0, 0, card.width, card.height, 6, 6)
    love.graphics.setColor(self.colour)
    love.graphics.translate(card.width / 2, card.height / 2)
    for i = 1, self.number do
        -- TODO: do translating here
        love.graphics.push()
        love.graphics.translate(card.numbers[self.number][i], 0)
        self:drawShape()
        love.graphics.pop()
    end
    love.graphics.pop()
end

return card
