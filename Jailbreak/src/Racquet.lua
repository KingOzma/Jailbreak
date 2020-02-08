Racquet = Class{}

-- The racquet will initalize at the same spot every time the game starts.
function Racquet:init(surface)

-- x is placed in the middle.
    self.x = SUPER_WIDTH / 2 -32

-- y is placed a little above the bottom edge of the screen.
    self.y = SUPER_HEIGHT - 32

-- Start off with no velocity.
    self.dx = 0

-- Starting dimensions.
    self.width = 64
    self.height = 16

--The surface effect changing racquet color.
    self.surface = 1

-- Racquet size
    self.size = 2
end

function Racquet:update(dt)
-- Keyboard input
    if love.keyboard.isDown('left') then
        self.dx = -RACQUET_SPEED
    elseif love.keyboard.isDown('right') then
        self.dx = RACQUET_SPEED
    else
        self.dx = 0
    end

    if self.dx < 0 then
        self.x = math.max(0, self.x + self.dx * dt)
    else
        self.x = math.min(SUPER_WIDTH - self.width, self.x + self.dx * dt)
    end
end

-- Render the racquet by drawing the main texture.
function Racquet:render()
    love.graphics.draw(gTextures['main'], gFrames['racquets'][self.size + 4 * (self.surface - 1)], self.x, self.y)
end