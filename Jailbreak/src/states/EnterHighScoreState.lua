EnterHighScoreState = Class{__includes = BaseState}

-- Individual chars of our string
local chars = {
    [1] = 65,
    [2] = 65,
    [3] = 65
}

-- Char that are currently changing.
local featuredChar = 1

function EnterHighScoreState:enter(params)
    self.highScores = params.highScores
    self.score = params.score
    self.scoreIndex = params.scoreIndex
end

function EnterHighScoreState:update(dt)
    if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
-- Update scores table
        local name = string.char(chars[1]) .. string.char(chars[2]) .. string.char(chars[3])

-- Go backwards through high scores table till this score, shifting scores
        for k = 10, self.scoreIndex, -1 do
            self.highScores[k + 1] = {
                name = self.highScores[k].name,
                score = self.highScores[k].score
            }
        end

        self.highScores[self.scoreIndex].name = name
        self.highScores[self.scoreIndex].score = self.score

-- Write scores to file
        local scoresStr = ''

        for k = 1, 10 do
            scoresStr = scoresStr .. self.highScores[k].name .. '\n'
            scoresStr = scoresStr .. tostring(self.highScores[k].score) .. '\n'
        end

        love.filesystem.write('jailbreak.lst', scoresStr)

        gStateMachine:change('high-scores', {
            highScores = self.highScores
        })
    end

-- Scroll through character slots
    if love.keyboard.wasPressed('left') and featuredChar > 1 then
        featuredChar = featuredChar - 1
        gSounds['select']:play()
    elseif love.keyboard.wasPressed('right') and featuredChar < 3 then
        featuredChar = featuredChar + 1
        gSounds['select']:play()
    end

-- Scroll through characters
    if love.keyboard.wasPressed('up') then
        chars[featuredChar] = chars[featuredChar] + 1
        if chars[featuredChar] > 90 then
            chars[featuredChar] = 65
        end
    elseif love.keyboard.wasPressed('down') then
        chars[featuredChar] = chars[featuredChar] - 1
        if chars[featuredChar] < 65 then
            chars[featuredChar] = 90
        end
    end
end

function EnterHighScoreState:render()
    love.graphics.setFont(gFonts['medium'])
    love.graphics.printf('Your score: ' .. tostring(self.score), 0, 30,
        SUPER_WIDTH, 'center')

    love.graphics.setFont(gFonts['big'])
    
    --
    -- render all three characters of the name
    --
    if featuredChar == 1 then
        love.graphics.setColor(103/255, 255/255, 255/255, 255/255)
    end
    love.graphics.print(string.char(chars[1]), SUPER_WIDTH / 2 - 28, SUPER_HEIGHT / 2)
    love.graphics.setColor(255/255, 255/255, 255/255, 255/255)

    if featuredChar == 2 then
        love.graphics.setColor(103/255, 255/255, 255/255, 255/255)
    end
    love.graphics.print(string.char(chars[2]), SUPER_WIDTH / 2 - 6, SUPER_HEIGHT / 2)
    love.graphics.setColor(255/255, 255/255, 255/255, 255/255)

    if featuredChar == 3 then
        love.graphics.setColor(103/255, 255/255, 255/255, 255/255)
    end
    love.graphics.print(string.char(chars[3]), SUPER_WIDTH / 2 + 20, SUPER_HEIGHT / 2)
    love.graphics.setColor(255/255, 255/255, 255/255, 255/255)
    
    love.graphics.setFont(gFonts['little'])
    love.graphics.printf('PrHit Enter to confirm!', 0, SUPER_HEIGHT - 18,
        SUPER_WIDTH, 'center')
end