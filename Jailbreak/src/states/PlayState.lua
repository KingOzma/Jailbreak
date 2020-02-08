PlayState = Class{__includes = BaseState}

-- Initialize what's in the PlayState via a state table that pass between states as it goes from playing to serving.
function PlayState:enter(params)
    self.racquet = params.racquet
    self.bricks = params.bricks
    self.hp = params.hp
    self.score = params.score
    self.highScores = params.highScores
    self.orb = params.orb
    self.level = params.level

    self.recoverPoints = 5000

-- Give orb random starting velocity
    self.orb.dx = math.random(-200, 200)
    self.orb.dy = math.random(-50, -60)
end

function PlayState:update(dt)
    if self.paused then
        if love.keyboard.wasPressed('space') then
            self.paused = false
            gSounds['pause']:play()
        else
            return
        end
    elseif love.keyboard.wasPressed('space') then
        self.paused = true
        gSounds['pause']:play()
        return
    end

-- Update positions based on velocity
    self.racquet:update(dt)
    self.orb:update(dt)

    if self.orb:collides(self.racquet) then
-- Raise orb above racquet in case it goes below it, then reverse dy
        self.orb.y = self.racquet.y - 8
        self.orb.dy = -self.orb.dy

-- Tweak angle of bounce based on where it hits the racquet.
-- If it hits the racquet on its left side while moving left.
        if self.orb.x < self.racquet.x + (self.racquet.width / 2) and self.racquet.dx < 0 then
            self.orb.dx = -50 + -(8 * (self.racquet.x + self.racquet.width / 2 - self.orb.x))
        
-- Else if it hits the racquet on its right side while moving right.
        elseif self.orb.x > self.racquet.x + (self.racquet.width / 2) and self.racquet.dx > 0 then
            self.orb.dx = 50 + (8 * math.abs(self.racquet.x + self.racquet.width / 2 - self.orb.x))
        end

        gSounds['racquet-hit']:play()
    end

-- Detect collision across all bricks with the orb.
    for a, brick in pairs(self.bricks) do

-- Only check collision if we're in play
        if brick.inPlay and self.orb:collides(brick) then

-- Add to score
            self.score = self.score + (brick.order * 200 + brick.color * 25)

-- Trigger the brick's hit function, which removes it from play
            brick:hit()

-- If you have enough points, recover a point of hp
            if self.score > self.recoverPoints then

-- Can't go above 3 hp
                self.hp = math.min(3, self.hp + 1)

-- Multiply recover points by 2
                self.recoverPoints = math.min(100000, self.recoverPoints * 2)

-- Play recover sound effect
                gSounds['recover']:play()
            end

            if self:checkVictory() then
                gSounds['victory']:play()

                gStateMachine:change('victory', {
                    level = self.level,
                    racquet = self.racquet,
                    hp = self.hp,
                    score = self.score,
                    highScores = self.highScores,
                    orb = self.orb,
                    recoverPoints = self.recoverPoints
                })
            end
            
            if self.orb.x + 2 < brick.x and self.orb.dx > 0 then
                
-- Flip x velocity and reset position outside of brick
                self.orb.dx = -self.orb.dx
                self.orb.x = brick.x - 8
            
-- Right edge; only check if moving left
            elseif self.orb.x + 6 > brick.x + brick.width and self.orb.dx < 0 then
                
-- Flip x velocity and reset position outside of brick
                self.orb.dx = -self.orb.dx
                self.orb.x = brick.x + 32
            
-- Top edge if no X collisions, always check
            elseif self.orb.y < brick.y then
                
-- Flip y velocity and reset position outside of brick
                self.orb.dy = -self.orb.dy
                self.orb.y = brick.y - 8
            
-- Bottom edge if no X collisions or top collision, last possibility
            else
                
-- Flip y velocity and reset position outside of brick
                self.orb.dy = -self.orb.dy
                self.orb.y = brick.y + 16
            end

-- Slightly scale the y velocity to speed up the game
            if math.abs(self.orb.dy) < 150 then
                self.orb.dy = self.orb.dy * 1.02
            end

-- Only allow colliding with one brick, for corners
            break
        end
    end

-- If orb goes below bounds, revert to serve state and decrease health
    if self.orb.y >= SUPER_HEIGHT then
        self.hp = self.hp - 1
        gSounds['hurt']:play()

        if self.hp == 0 then
            gStateMachine:change('game-over', {
                score = self.score,
                highScores = self.highScores
            })
        else
            gStateMachine:change('serve', {
                racquet = self.racquet,
                bricks = self.bricks,
                hp = self.hp,
                score = self.score,
                highScores = self.highScores,
                level = self.level,
                recoverPoints = self.recoverPoints
            })
        end
    end

-- For rendering particle systems
    for a, brick in pairs(self.bricks) do
        brick:update(dt)
    end

    if love.keyboard.wasPressed('escape') then
        love.event.quit()
    end
end

function PlayState:render()
-- Render bricks
    for a, brick in pairs(self.bricks) do
        brick:render()
    end

-- Render all particle systems.
    for a, brick in pairs(self.bricks) do
        brick:renderParticles()
    end

    self.racquet:render()
    self.orb:render()

    renderScore(self.score)
    renderHp(self.hp)

-- Pause text, if paused
    if self.paused then
        love.graphics.setFont(gFonts['big'])
        love.graphics.printf("PAUSED", 0, SUPER_HEIGHT / 2 - 16, SUPER_WIDTH, 'center')
    end
end

function PlayState:checkVictory()
    for a, brick in pairs(self.bricks) do
        if brick.inPlay then
            return false
        end 
    end

    return true
end