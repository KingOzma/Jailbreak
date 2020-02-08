NONE = 1
SINGLE_PYRAMID = 2
MULTI_PYRAMID = 3

-- Per-row patterns
SOLID = 1           -- All colors the same in this row
ALTERNATE = 2       -- Alternate colors
SKIP = 3            -- Skip every other block
NONE = 4            -- No blocks this row

LevelMaker = Class{} 

-- Creates a table of Bricks to be returned to the main game, with different
-- possible ways of randomizing rows and columns of bricks. 
function LevelMaker.createMap(level)
    local bricks = {}

-- Randomly choose the number of rows
    local numRows = math.random(1, 5)

-- Randomly choose the number of columns
    local numCols = math.random(7, 13)
    numCols = numCols % 2 == 0 and (numCols + 1) or numCols

-- Highest possible spawned brick color in this level; ensure we don't go above 3
    local highestOrder = math.min(3, math.floor(level / 5))

-- Highest color of the highest order
    local highestColor = math.min(5, level % 5 + 3)

-- Lay out bricks such that they touch each other and fill the space
    for y = 1, numRows do
        
        local skipPattern = math.random(1, 2) == 1 and true or false

-- Whether to enable alternating colors for this row.
        local alternatePattern = math.random(1, 2) == 1 and true or false
        
-- Two colors to alternate between.
        local alternateColor1 = math.random(1, highestColor)
        local alternateColor2 = math.random(1, highestColor)
        local alternateOrder1 = math.random(0, highestOrder)
        local alternateOrder2 = math.random(0, highestOrder)
        
-- Used only to skip a block, for skip pattern.
        local skipBanner = math.random(2) == 1 and true or false

-- Used only to alternate a block, for alternate pattern.
        local alternateBanner= math.random(2) == 1 and true or false

-- Solid color if we're not alternating
        local solidColor = math.random(1, highestColor)
        local solidOrder = math.random(0, highestOrder)

        for x = 1, numCols do
-- If skipping is turned on and skipping iteration.
            if skipPattern and skipBanner then
-- Turn skipping off for the next iteration
                skipBanner = not skipBanner

-- Lua doesn't have a continue statement, so this is a workaround.
                goto continue
            else
-- flip the banner to true on an iteration we don't use it
                skipBanner = not skipBanner
            end

            b = Brick(
-- x-coordinate
                (x-1)                   -- Decrement x by 1 because tables are 1-indexed, coords are 0
                * 32                    -- Multiply by 32, the brick width
                + 8                     -- The screen should have 8 pixels of padding; can fit 13 cols + 16 pixels total
                + (13 - numCols) * 16,  -- Left-side padding for when there are fewer than 13 columns
                
                -- y-coordinate
                y * 16                  -- Just use y * 16, since we need top padding anyway
            ) 

-- If alternating, figure out which color/order you're on.
            if alternatePattern and alternateBanner then
                b.color = alternateColor1
                b.order = alternateOrder1
                alternateBanner = not alternateBanner
            else
                b.color = alternateColor2
                b.order = alternateOrder2
                alternateBanner = not alternateBanner
            end

-- If not alternating and made it here, use the solid color/order.
            if not alternatePattern then
                b.color = solidColor
                b.order = solidOrder
            end 

            table.insert(bricks, b)

            ::continue::
        end
    end 

-- If bricks didn't generate, try again.
    if #bricks == 0 then
        return self.createMap(level)
    else
        return bricks
    end
end