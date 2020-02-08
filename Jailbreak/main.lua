require 'src/Dependencies'

 --Used to set up game objects, variables, etc. and prepare the game world.

function love.load()
--Means there will be no filtering of pixels (blurriness)
    love.graphics.setDefaultFilter('nearest', 'nearest')

-- seed the RNG so that calls to random are always random
    math.randomseed(os.time())

-- set title bar
    love.window.setTitle('Jailbreak')

-- initialize nice-looking retro text fonts
    gFonts = {
        ['little'] = love.graphics.newFont('fonts/font.ttf', 8),
        ['medium'] = love.graphics.newFont('fonts/font.ttf', 16),
        ['big'] = love.graphics.newFont('fonts/font.ttf', 32)
    }
    love.graphics.setFont(gFonts['little'])

-- Load up the graphics throughout states
    gTextures = {
        ['background'] = love.graphics.newImage('graphics/background.png'),
        ['main'] = love.graphics.newImage('graphics/jailbreak.png'),
        ['arrows'] = love.graphics.newImage('graphics/arrows.png'),
        ['hearts'] = love.graphics.newImage('graphics/hearts.png'),
        ['particle'] = love.graphics.newImage('graphics/particle.png')
    }

-- Quads will generate for all of the textures
    gFrames = {
        ['arrows'] = GenerateQuads(gTextures['arrows'], 24, 24),
        ['racquets'] = GenerateQuadsRacquets(gTextures['main']),
        ['orbs'] = GenerateQuadsOrbs(gTextures['main']),
        ['bricks'] = GenerateQuadsBricks(gTextures['main']),
        ['hearts'] = GenerateQuads(gTextures['hearts'], 10, 9)
    }
    
-- Initialize virtual resolution, which will be rendered within the actual window no matter its dimensions
    push:setupScreen(SUPER_WIDTH, SUPER_HEIGHT, BOX_WIDTH, BOX_HEIGHT, {
        vsync = true,
        fullscreen = false,
        resizable = true
    })

-- Set up our sound effects
    gSounds = {
        ['racquet-hit'] = love.audio.newSource('sounds/racquet_hit.wav', 'static'),
        ['score'] = love.audio.newSource('sounds/score.wav', 'static'),
        ['wall-hit'] = love.audio.newSource('sounds/wall_hit.wav', 'static'),
        ['confirm'] = love.audio.newSource('sounds/confirm.wav', 'static'),
        ['select'] = love.audio.newSource('sounds/select.wav', 'static'),
        ['no-select'] = love.audio.newSource('sounds/no-select.wav', 'static'),
        ['brick-hit-1'] = love.audio.newSource('sounds/brick-hit-1.wav', 'static'),
        ['brick-hit-2'] = love.audio.newSource('sounds/brick-hit-2.wav', 'static'),
        ['hurt'] = love.audio.newSource('sounds/hurt.wav', 'static'),
        ['victory'] = love.audio.newSource('sounds/victory.wav', 'static'),
        ['recover'] = love.audio.newSource('sounds/recover.wav', 'static'),
        ['high-score'] = love.audio.newSource('sounds/high_score.wav', 'static'),
        ['pause'] = love.audio.newSource('sounds/pause.wav', 'static'),
    
        ['music'] = love.audio.newSource('sounds/401828__frankum__love-technohouse-peace.mp3', 'static')
    }

-- The state machine using to transition between various states
-- in our game instead of clumping them together in our update and draw
-- methods
    
-- our current game state can be any of the following:
-- 1. 'start' (Beginning of the game, hit Enter)
-- 2. 'racquet-select' (Where you get to choose the color of the racquet)
-- 3. 'serve' (Waiting on a key press to serve the orb)
-- 4. 'play' (The orb is in play, bouncing between racquets)
-- 5. 'victory' (When the current level is over with victory music)
-- 6. 'game-over' (When the player has lost, shows score, and allows restart)
    gStateMachine = StateMachine {
        ['start'] = function() return StartState() end,
        ['play'] = function() return PlayState() end,
        ['serve'] = function() return ServeState() end,
        ['game-over'] = function() return GameOverState() end,
        ['victory'] = function() return VictoryState() end,
        ['high-scores'] = function() return HighScoreState() end,
        ['enter-high-score'] = function() return EnterHighScoreState() end,
        ['racquet-select'] = function() return RacquetSelectState() end
    }
    gStateMachine:change('start', {
        highScores = loadHighScores()
    })

--Play music and have it loop
    gSounds['music']:play()
    gSounds['music']:setLooping(true)


-- A table used to keep track of which keys have been pressed.
    love.keyboard.keysPressed = {}
end

--Called whenever we change the dimensions of our window
function love.resize(w, h)
    push:resize(w, h)
end

--Called every frame, passing in `dt` since the last frame. `dt`
function love.update(dt)
-- Pass in dt to the state object currently being used
    gStateMachine:update(dt)

-- Reset keys pressed
    love.keyboard.keysPressed = {}
end

function love.keypressed(key)
-- Add to a table of keys pressed this frame
    love.keyboard.keysPressed[key] = true
end

-- Custom function that will allow test for individual keystrokes outside of the default `love.keypressed` callback
function love.keyboard.wasPressed(key)
    if love.keyboard.keysPressed[key] then
        return true
    else
        return false
    end
end

-- Responsible simply for drawing all of the game objects and more to the screen.
function love.draw()
-- Begin drawing with push, in the virtual resolution
    push:apply('start')

-- Background should be drawn regardless of state, scaled to fit.
    local backgroundWidth = gTextures['background']:getWidth()
    local backgroundHeight = gTextures['background']:getHeight()

    love.graphics.draw(gTextures['background'], 
-- Draw at coordinates 0, 0
        0, 0, 
-- No rotation
        0,
-- Scale factors on X and Y axis so it fills the screen.
        SUPER_WIDTH / (backgroundWidth - 1), SUPER_HEIGHT / (backgroundHeight - 1))
    
-- Use the state machine to defer rendering to the current state you're in.
    gStateMachine:render()
    
-- Display FPS for debugging.
    displayFPS()
    
    push:apply('end')
end

function loadHighScores()
    love.filesystem.setIdentity('Jailbreak')

-- If the file doesn't exist, initialize it with some default scores
    if not love.filesystem.getInfo('jailbreak.lst') then
        local scores = ''
        for k = 10, 1, -1 do
            scores = scores .. 'CTO\n'
            scores = scores .. tostring(k * 1000) .. '\n'
        end

        love.filesystem.write('jailbreak.lst', scores)
    end

-- Flag for whether reading a name or not
    local name = true
    local currentName = nil
    local counter = 1

-- Initialize scores table with at least 10 blank entries
    local scores = {}

    for k = 1, 10 do
-- Blank table; holds a name and a score
        scores[k] = {
            name = nil,
            score = nil
        }
    end

-- Iterate over each line in the file, filling in names and scores
    for line in love.filesystem.lines('jailbreak.lst') do
        if name then
            scores[counter].name = string.sub(line, 1, 3)
        else
            scores[counter].score = tonumber(line)
            counter = counter + 1
        end

-- Flip the name flag
        name = not name
    end

    return scores
end

-- Renders hearts based on how much HP the player has.
function renderHp(hp)
-- start of our HP rendering
    local hpX = SUPER_WIDTH - 100
    
-- render HP left
    for k = 1, hp do
        love.graphics.draw(gTextures['hearts'], gFrames['hearts'][1], hpX, 4)
        hpX = hpX + 11
    end

-- render missing HP
    for k = 1, 3 - hp do
        love.graphics.draw(gTextures['hearts'], gFrames['hearts'][2], hpX, 4)
        hpX = hpX + 11
    end
end 

-- Renders the current FPS.
function displayFPS()
-- Simple FPS display across all states
    love.graphics.setFont(gFonts['little'])
    love.graphics.setColor(0, 255, 0, 255)
    love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 5, 5)
end

function renderScore(score)
    love.graphics.setFont(gFonts['little'])
    love.graphics.print('Score:', SUPER_WIDTH - 60, 5)
    love.graphics.printf(tostring(score), SUPER_WIDTH - 50, 5, 40, 'right')
end

