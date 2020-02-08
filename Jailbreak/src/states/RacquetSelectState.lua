RacquetSelectState = Class{__includes = BaseState}

function RacquetSelectState:enter(params)
    self.highScores = params.highScores
end

function RacquetSelectState:init()
-- The racquet we're featuring; will be passed to the ServeState when hitting Enter.
    self.currentRacquet = 1
end

function RacquetSelectState:update(dt)
    if love.keyboard.wasPressed('left') then
        if self.currentRacquet == 1 then
            gSounds['no-select']:play()
        else
            gSounds['select']:play()
            self.currentRacquet = self.currentRacquet - 1
        end
    elseif love.keyboard.wasPressed('right') then
        if self.currentRacquet == 4 then
            gSounds['no-select']:play()
        else
            gSounds['select']:play()
            self.currentRacquet = self.currentRacquet + 1
        end
    end

-- Select racquet and move on to the serve state, passing in the selection
    if love.keyboard.wasPressed('return') or love.keyboard.wasPressed('enter') then
        gSounds['confirm']:play()

        gStateMachine:change('serve', {
            racquet = Racquet(self.currentRacquet),
            bricks = LevelMaker.createMap(1),
            hp = 3,
            score = 0,
            highScores = self.highScores,
            level = 1,
            recoverPoints = 5000
        })
    end

    if love.keyboard.wasPressed('escape') then
        love.event.quit()
    end
end

function RacquetSelectState:render()
-- Instructions
    love.graphics.setFont(gFonts['medium'])
    love.graphics.printf("Select your racquet with left and right!", 0, SUPER_HEIGHT / 4,
        SUPER_WIDTH, 'center')
    love.graphics.setFont(gFonts['little'])
    love.graphics.printf("(Hit Enter to continue!)", 0, SUPER_HEIGHT / 3,
        SUPER_WIDTH, 'center')
        
-- Left arrow; should render normally if higher than 1, else
-- in a shadowy form to let us know as far left as we can go.
    if self.currentRacquet == 1 then

-- Tint; give it a dark gray with half opacity.
        love.graphics.setColor(40/255, 40/255, 40.255, 128/255)
    end
    
    love.graphics.draw(gTextures['arrows'], gFrames['arrows'][1], SUPER_WIDTH / 4 - 24,
        SUPER_HEIGHT - SUPER_HEIGHT / 3)
   
-- Reset drawing color to full white for proper rendering.
    love.graphics.setColor(255/255, 255/255, 255/255, 255/255)

-- Right arrow; should render normally if less than 4, else
-- in a shadowy form to let us know as far right as you can go.
    if self.currentRacquet == 4 then

-- Tint; give it a dark gray with half opacity.
        love.graphics.setColor(40/255, 40/255, 40/255, 128/255)
    end
    
    love.graphics.draw(gTextures['arrows'], gFrames['arrows'][2], SUPER_WIDTH - SUPER_WIDTH / 4,
        SUPER_HEIGHT - SUPER_HEIGHT / 3)
    
-- Reset drawing color to full white for proper rendering.
    love.graphics.setColor(255/255, 255/255, 255/255, 255/255)

-- Draw the racquet itself, based on which we have selected.
    love.graphics.draw(gTextures['main'], gFrames['racquets'][2 + 4 * (self.currentRacquet - 1)],
        SUPER_WIDTH / 2 - 32, SUPER_HEIGHT - SUPER_HEIGHT / 3)
end