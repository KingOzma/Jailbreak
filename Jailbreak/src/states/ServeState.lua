ServeState = Class{__includes = BaseState}

function ServeState:enter(params)
-- Grab game state from params
    self.racquet = params.racquet
    self.bricks = params.bricks
    self.hp= params.hp
    self.score = params.score
    self.highScores = params.highScores
    self.level = params.level
    self.recoverPoints = params.recoverPoints

-- Init new orb
    self.orb = Orb()
    self.orb.surface = math.random(7)
end

function ServeState:update(dt)
-- have the orb track the player
    self.racquet:update(dt)
    self.orb.x = self.racquet.x + (self.racquet.width / 2) - 4
    self.orb.y = self.racquet.y - 8

    if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
-- Pass in all important state info to the PlayState
        gStateMachine:change('play', {
            racquet = self.racquet,
            bricks = self.bricks,
            hp = self.hp,
            score = self.score,
            highScores = self.highScores,
            orb = self.orb,
            level = self.level,
            recoverPoints = self.recoverPoints
        })
    end

    if love.keyboard.wasPressed('escape') then
        love.event.quit()
    end
end

function ServeState:render()
    self.racquet:render()
    self.orb:render()

    for a, brick in pairs(self.bricks) do
        brick:render()
    end

    renderScore(self.score)
    renderHp(self.hp)

    love.graphics.setFont(gFonts['big'])
    love.graphics.printf('Level ' .. tostring(self.level), 0, SUPER_HEIGHT / 3,
        SUPER_WIDTH, 'center')

    love.graphics.setFont(gFonts['medium'])
    love.graphics.printf('Hit Enter to serve!', 0, SUPER_HEIGHT / 2,
        SUPER_WIDTH, 'center')
end