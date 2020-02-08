GameOverState = Class{__includes = BaseState}

function GameOverState:enter(params)
    self.score = params.score
    self.highScores = params.highScores
end

function GameOverState:update(dt)
    if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
-- See if score is higher than any in the high scores table
        local highScore = false
        
-- Keep track of what high score overwrites, if any
        local scoreIndex = 11

        for k = 10, 1, -1 do
            local score = self.highScores[k].score or 0
            if self.score > score then
                highScoreIndex = k
                highScore = true
            end
        end

        if highScore then
            gSounds['high-score']:play()
            gStateMachine:change('enter-high-score', {
                highScores = self.highScores,
                score = self.score,
                scoreIndex = highScoreIndex
            }) 
        else 
            gStateMachine:change('start', {
                highScores = self.highScores
            }) 
        end
    end

    if love.keyboard.wasPressed('escape') then
        love.event.quit()
    end
end

function GameOverState:render()
    love.graphics.setFont(gFonts['big'])
    love.graphics.printf('GAME OVER', 0, SUPER_HEIGHT / 3, SUPER_WIDTH, 'center')
    love.graphics.setFont(gFonts['medium'])
    love.graphics.printf('Final Score: ' .. tostring(self.score), 0, SUPER_HEIGHT / 2,
        SUPER_WIDTH, 'center')
    love.graphics.printf('Hit Enter!', 0, SUPER_HEIGHT - SUPER_HEIGHT / 4,
        SUPER_WIDTH, 'center')
end
