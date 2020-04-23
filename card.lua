local card = {}
card.__index = card

local SHAPE_IMAGE_MASK = love.graphics.newShader([[
    vec4 effect(vec4 colour, Image texture, vec2 texture_coords, vec2 screen_coords)
    {
        if (Texel(texture, texture_coords).a == 0)
        {
            discard;
        }
        return vec4(1.0);
    }
]])

local SHAPE_IMAGE = love.graphics.newImage("shapes.png")
local SHAPE_QUADS = {
    diamond = {
        empty = love.graphics.newQuad(0 * 64, 0, 64, 128, SHAPE_IMAGE:getWidth(), SHAPE_IMAGE:getHeight()),
        full = love.graphics.newQuad(0 * 64, 128, 64, 128, SHAPE_IMAGE:getWidth(), SHAPE_IMAGE:getHeight()),
    },
    oval = {
        empty = love.graphics.newQuad(1 * 64, 0, 64, 128, SHAPE_IMAGE:getWidth(), SHAPE_IMAGE:getHeight()),
        full = love.graphics.newQuad(1 * 64, 128, 64, 128, SHAPE_IMAGE:getWidth(), SHAPE_IMAGE:getHeight()),
    },
    squiggle = {
        empty = love.graphics.newQuad(2 * 64, 0, 64, 128, SHAPE_IMAGE:getWidth(), SHAPE_IMAGE:getHeight()),
        full = love.graphics.newQuad(2 * 64, 128, 64, 128, SHAPE_IMAGE:getWidth(), SHAPE_IMAGE:getHeight()),
    },
}

local NUMBER_OFFSETS = {
    [1] = {0},
    [2] = {-32, 32},
    [3] = {-64, 0, 64},
}

local COLOURS = {
    red    = {1, 0, 0},
    green  = {0, 1, 0},
    purple = {0.6, 0, 1},
}

local FILLS = {
    empty   = 0,
    striped = 1,
    full    = 2,
}

local STRIPE_COUNT = 10

card.shape_width = 64
card.shape_height = 128
card.width  = 192 -- pixels
card.height = 256 -- pixels

function card.random()
    local number = ({1, 2, 3})[math.ceil(math.random() * 3)]
    local colour = ({"red", "green", "purple"})[math.ceil(math.random() * 3)]
    local shape  = ({"diamond", "oval", "squiggle"})[math.ceil(math.random() * 3)]
    local fill   = ({"empty", "striped", "full"})[math.ceil(math.random() * 3)]
    return card.new(number, colour, shape, fill)
end

function card.new(number, colour, shape, fill)
    local self = {}
    setmetatable(self, card)

    assert(NUMBER_OFFSETS[number], "Invalid number (" .. number .. ")")
    assert(COLOURS[colour], "Invalid colour (" .. colour .. ")")
    assert(SHAPE_QUADS[shape], "Invalid shape (" .. shape .. ")")
    assert(FILLS[fill], "Invalid fill (" .. fill .. ")")
    self.colour = colour
    self.number = number
    self.shape = shape
    self.fill = fill
    self.canvas = love.graphics.newCanvas(card.width, card.height)

    love.graphics.push()
    love.graphics.setCanvas({self.canvas, stencil=true})
    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle("line", 0, 0, card.width, card.height, 6, 6)
    love.graphics.setColor(COLOURS[self.colour])
    love.graphics.translate(card.width / 2, card.height / 2)
    for i = 1, self.number do
        love.graphics.push()
        love.graphics.translate(NUMBER_OFFSETS[self.number][i], 0)
        self:drawShape()
        love.graphics.pop()
    end
    love.graphics.setCanvas()
    love.graphics.pop()

    return self
end

function card:drawShape()
    local fill = self.fill
    if fill == "striped" then
        love.graphics.stencil(function() 
            love.graphics.setShader(SHAPE_IMAGE_MASK)
            local quad = SHAPE_QUADS[self.shape]["full"]
            local _, _, w, h = quad:getViewport()
            love.graphics.draw(SHAPE_IMAGE, quad, 0, 0, 0, 1, 1, w / 2, h / 2)
            love.graphics.setShader()
        end, "replace", 1)
        love.graphics.setStencilTest("greater", 0)
        for i = 1, STRIPE_COUNT + 1 do
            local y = (i - STRIPE_COUNT / 2 - 1) * (self.shape_height) / STRIPE_COUNT
            -- TODO: Set line width to slightly higher, and edit the outline image to have a thicker line
            love.graphics.line(-card.shape_width, y, card.shape_width, y)
        end
        love.graphics.setStencilTest()
        fill = "empty"
    end
    local quad = SHAPE_QUADS[self.shape][fill]
    local _, _, w, h = quad:getViewport()
    love.graphics.draw(SHAPE_IMAGE, quad, 0, 0, 0, 1, 1, w / 2, h / 2)
end

function card:draw(x, y)
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(self.canvas, x, y)
end

return card
