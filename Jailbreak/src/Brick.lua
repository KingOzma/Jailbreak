Brick = Class{}

boardColors = {
-- Blue
    [1] = {
        ['r'] = 99/255,
        ['g'] = 155/255,
        ['b'] = 255/255
    },
-- Green
    [2] = {
        ['r'] = 106/255,
        ['g'] = 190/255,
        ['b'] = 47/255
    },
-- Red
    [3] = {
        ['r'] = 217/255,
        ['g'] = 87/255,
        ['b'] = 99/255
    },
-- Purple
    [4] = {
        ['r'] = 215/255,
        ['g'] = 123/255,
        ['b'] = 186/255
    },
-- Gold
    [5] = {
        ['r'] = 251/255,
        ['g'] = 242/255,
        ['b'] = 54/255
    }
}

function Brick:init(x, y)
-- Used for coloring and score calculation
    self.order = 0
    self.color = 1
    
    self.x = x
    self.y = y
    self.width = 32
    self.height = 16
    
-- Used to determine whether this brick should be rendered
    self.inPlay = true

-- Particle system belonging to the brick, emitted on hit
    self.psystem = love.graphics.newParticleSystem(gTextures['particle'], 64)

-- Various behavior-determining functions for the particle system
-- https://love2d.org/wiki/ParticleSystem

-- Lasts between 0.5-1 seconds seconds
    self.psystem:setParticleLifetime(0.5, 1)

-- Give it an acceleration of anywhere between X1,Y1 and X2,Y2 (0, 0) and (80, 80) here
-- Gives generally downward 
    self.psystem:setLinearAcceleration(-15, 0, 15, 80)

-- Spread of particles; normal looks more natural than uniform.
    self.psystem:setEmissionArea('normal', 10, 10)
end

-- Triggers a hit on the brick, taking it out of play if at 0 health or changing its color otherwise.
function Brick:hit()
    self.psystem:setColors(
        boardColors[self.color].r,
        boardColors[self.color].g,
        boardColors[self.color].b,
        55 * (self.order + 1),
        boardColors[self.color].r,
        boardColors[self.color].g,
        boardColors[self.color].b,
        0
    )
    self.psystem:emit(64)

-- Sound on hit
    gSounds['brick-hit-2']:stop()
    gSounds['brick-hit-2']:play()

    if self.order > 0 then
        if self.color == 1 then
            self.order = self.order - 1
            self.color = 5
        else
            self.color = self.color - 1
        end
    else
-- In the first order and the base color, remove brick from play
        if self.color == 1 then
            self.inPlay = false
        else
            self.color = self.color - 1
        end
    end

-- Play a second layer sound if the brick is destroyed
    if not self.inPlay then
        gSounds['brick-hit-1']:stop()
        gSounds['brick-hit-1']:play()
    end
end

function Brick:update(dt)
    self.psystem:update(dt)
end

function Brick:render()
    if self.inPlay then
        love.graphics.draw(gTextures['main'], 
-- Multiply color by 4 (-1) to get our color offset, then add order to that
-- to draw the correct order and color brick onto the screen
            gFrames['bricks'][1 + ((self.color - 1) * 4) + self.order],
            self.x, self.y)
    end
end

function Brick:renderParticles()
    love.graphics.draw(self.psystem, self.x + 16, self.y + 8)
end
