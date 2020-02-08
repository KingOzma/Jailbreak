function GenerateQuads(atlas, blockwidth, blockheight)
    local layerWidth = atlas:getWidth() / blockwidth
    local layerHeight = atlas:getHeight() / blockheight

    local layerCounter = 1
    local spritelayer = {}

    for y = 0, layerHeight - 1 do
        for x = 0, layerWidth - 1 do
            spritelayer[layerCounter] = 
                love.graphics.newQuad(x * blockwidth, y * blockheight, blockwidth,
                blockheight, atlas:getDimensions())
            layerCounter = layerCounter + 1
        end
    end

    return spritelayer
end

function table.hack(tbl, first, last, step)
    local hacked = {}
  
    for k = first or 1, last or #tbl, step or 1 do
      hacked[#hacked+1] = tbl[k]
    end
  
    return hacked
end

-- Used to piece out bricks.
function GenerateQuadsBricks(atlas)
    return table.hack(GenerateQuads(atlas, 32, 16), 1, 21)
end

-- This function is specifically made to piece out the racquets from the
function GenerateQuadsRacquets(atlas)
    local x = 0
    local y = 64

    local counter = 1
    local quads = {}

    for k = 0, 3 do
-- Littlest 
        quads[counter] = love.graphics.newQuad(x, y, 32, 16,
            atlas:getDimensions())
        counter = counter + 1
-- Medium
        quads[counter] = love.graphics.newQuad(x + 32, y, 64, 16,
            atlas:getDimensions())
        counter = counter + 1
-- Big
        quads[counter] = love.graphics.newQuad(x + 96, y, 96, 16,
            atlas:getDimensions())
        counter = counter + 1
-- Huge
        quads[counter] = love.graphics.newQuad(x, y + 16, 128, 16,
            atlas:getDimensions())
        counter = counter + 1

-- Prepare X and Y for the next set of racquets
        x = 0
        y = y + 32
    end

    return quads
end

-- Used to piece out orbs.
function GenerateQuadsOrbs(atlas)
    local x = 96
    local y = 48

    local counter = 1
    local quads = {}

    for k = 0, 3 do
        quads[counter] = love.graphics.newQuad(x, y, 8, 8, atlas:getDimensions())
        x = x + 8
        counter = counter + 1
    end

    x = 96
    y = 56

    for k = 0, 2 do
        quads[counter] = love.graphics.newQuad(x, y, 8, 8, atlas:getDimensions())
        x = x + 8
        counter = counter + 1
    end

    return quads
end