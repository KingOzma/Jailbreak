VictoryState = Class{__includes = BaseState}

function VictoryState:enter(params)
    self.level = params.level
    self.score = params.score
    self.highScores = params.highScores
    self.racquet = params.racquet
    self.hp = params.hp
    self.orb = params.orb
    self.recoverPoints = params.recoverPoints
end

function VictoryState:update(dt)
    self.racquet:update(dt)

-- Have the orb track the player
    self.orb.x = self.racquet.x + (self.racquet.width / 2) - 4
    self.orb.y = self.racquet.y - 8

-- Go to play screen if the player hits Enter
    if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
        gStateMachine:change('serve', {
            level = self.level + 1,
            bricks = LevelMaker.createMap(self.level + 1),
            racquet = self.racquet,
            hp = self.hp,
            score = self.score,
            highScores = self.highScores,
            recoverPoints = self.recoverPoints
        })
    end
end

function VictoryState:render()
    self.racquet:render()
    self.orb:render()

    renderHp(self.hp)
    renderScore(self.score)

    -- level complete text
    love.graphics.setFont(gFonts['big'])
    love.graphics.printf("Level " .. tostring(self.level) .. " complete!",
        0, SUPER_HEIGHT / 4, SUPER_WIDTH, 'center')

    -- instructions text
    love.graphics.setFont(gFonts['medium'])
    love.graphics.printf('Press Enter to serve!', 0, SUPER_HEIGHT / 2,
        SUPER_WIDTH, 'center')
end