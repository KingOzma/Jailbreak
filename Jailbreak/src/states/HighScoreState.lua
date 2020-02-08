HighScoreState = Class{__includes = BaseState}

function HighScoreState:enter(params)
    self.highScores = params.highScores
end

function HighScoreState:update(dt)
-- Return to the start screen if escape is hit.
    if love.keyboard.wasPressed('escape') then
        gSounds['wall-hit']:play()
        
        gStateMachine:change('start', {
            highScores = self.highScores
        })
    end
end

function HighScoreState:render()
    love.graphics.setFont(gFonts['big'])
    love.graphics.printf('High Scores', 0, 20, SUPER_WIDTH, 'center')

    love.graphics.setFont(gFonts['medium'])

-- Iterate over all high score indices in the high scores table.
    for k = 1, 10 do
        local name = self.highScores[k].name or '---'
        local score = self.highScores[k].score or '---'

-- Score number (1-10)
        love.graphics.printf(tostring(k) .. '.', SUPER_WIDTH / 4, 
            60 + k * 13, 50, 'left')

-- Score name
        love.graphics.printf(name, SUPER_WIDTH / 4 + 38, 
            60 + k * 13, 50, 'right')
        
-- Score itself
        love.graphics.printf(tostring(score), SUPER_WIDTH / 2,
            60 + k * 13, 100, 'right')
    end

    love.graphics.setFont(gFonts['little'])
    love.graphics.printf("Hit Escape to return to the main menu!",
        0, SUPER_HEIGHT - 18, SUPER_WIDTH, 'center')
end