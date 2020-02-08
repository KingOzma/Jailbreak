StartState = Class{__includes = BaseState}

-- Whether we're featuring "Start" or "High Scores"
local featured = 1

function StartState:enter(params)
    self.highScores = params.highScores
end

function StartState:update(dt)
-- Toggle featured option if you press an arrow key up or down
    if love.keyboard.wasPressed('up') or love.keyboard.wasPressed('down') then
        featured = featured == 1 and 2 or 1
        gSounds['racquet-hit']:play()
    end

-- Confirm whichever option you have selected to change screens
    if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
        gSounds['confirm']:play()

        if featured == 1 then
            gStateMachine:change('racquet-select', {
                highScores = self.highScores
            })
        else
            gStateMachine:change('high-scores', {
                highScores = self.highScores
            })
        end
    end

-- No longer have this globally, so include here
    if love.keyboard.wasPressed('escape') then
        love.event.quit()
    end
end

function StartState:render()
-- Title
    love.graphics.setFont(gFonts['big'])
    love.graphics.printf("JAILBREAK", 0, SUPER_HEIGHT / 3,
        SUPER_WIDTH, 'center')
    
-- Instructions
    love.graphics.setFont(gFonts['medium'])

-- If featuring 1, render that option blue
    if featured == 1 then
        love.graphics.setColor(59/255, 255/255, 45/255, 255/255)
    end
    love.graphics.printf("START", 0, SUPER_HEIGHT / 2 + 70,
        SUPER_WIDTH, 'center')

-- Reset the color
    love.graphics.setColor(255/255, 255/255, 255/255, 255/255)

-- Render option 2 blue if featuring that one
    if featured == 2 then
        love.graphics.setColor(59/255, 255/255, 45/255, 255/255)
    end
    love.graphics.printf("HIGH SCORES", 0, SUPER_HEIGHT / 2 + 90,
        SUPER_WIDTH, 'center')

-- Reset the color
    love.graphics.setColor(255/255, 255/255, 255/255, 255/255)
end