Orb = Class{}

function Orb:init(surface)
-- Simple positional and dimensional variables
    self.width = 8
    self.height = 8

-- These variables are for keeping track of velocity on both the 
-- X and Y axis, since the orb can move in two dimensions
    self.dy = 0
    self.dx = 0

-- The color of our orb.
    self.surface = surface
end

function Orb:collides(target)
-- Checks to see if the left edge of either is farther to the right than the right edge of the other.
    if self.x > target.x + target.width or target.x > self.x + self.width then
        return false
    end

-- Checks to see if the bottom edge of either is higher than the top edge of the other
    if self.y > target.y + target.height or target.y > self.y + self.height then
        return false
    end 

-- If the above aren't true, they're overlapping
    return true
end

-- Places the orb in the middle of the screen, with no movement.
function Orb:reset()
    self.x = SUPER_WIDTH / 2 - 2
    self.y = SUPER_HEIGHT / 2 - 2
    self.dx = 0
    self.dy = 0
end

function Orb:update(dt)
    self.x = self.x + self.dx * dt
    self.y = self.y + self.dy * dt

-- Allow orb to bounce off walls
    if self.x <= 0 then
        self.x = 0
        self.dx = -self.dx
        gSounds['wall-hit']:play()
    end

    if self.x >= SUPER_WIDTH - 8 then
        self.x = SUPER_WIDTH - 8
        self.dx = -self.dx
        gSounds['wall-hit']:play()
    end

    if self.y <= 0 then
        self.y = 0
        self.dy = -self.dy
        gSounds['wall-hit']:play()
    end
end

function Orb:render()
-- gTexture is the global texture for all blocks
-- gBallFrames is a table of quads mapping to each individual orb surface in the texture
    love.graphics.draw(gTextures['main'], gFrames['orbs'][self.surface],
        self.x, self.y)
end
