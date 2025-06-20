import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "../Support/animatedimage"

local graphics <const> = playdate.graphics
local sound <const> = playdate.sound

local min, max, abs, floor = math.min, math.max, math.abs, math.floor

-- Constants
local left, right = 1, 0 -- Facing Directions
local dt = 0.05
local GRAVITY_CONSTANT = 1200
local JUMP_VELOCITY = -300
local JUMP_DURATION = 0.1
local JUMP_CUT_SHORT_MULTIPLIER = 0.5

-- Player state
---@class playdate.graphics.sprite 
local player = nil
local playerVelocity = { x = 0, y = 0 }
local isJumping = false
local jumpStartTime = 0
local currentJumpVelocity = 0

-- Screen Dimensions
local playdateHeight = 240
local playdateWidth = 400

local function createPlayer()

    -- Creating Sprite
    player = graphics.sprite.new()
    player.direction = right
    player.onGround = true

    player.ratio = 32/96
    player.idle = AnimatedImage.new("Images/Duck/Gifs/idle", {delay = 200, loop = true, first = 1, last = 2})
    player.moving = AnimatedImage.new("Images/Duck/Gifs/Walking", {delay = 200, loop = true, first = 1, last = 2})
    player.crouch = graphics.image.new("Images/Duck/Sprites/Crouching/Crouching")
    player.jump = graphics.image.new("Images/Duck/Sprites/Jumping/Jumping")

    assert(player.idle, "Idle didn't load")
    assert(player.jump, "Jump Image didn't load")
    assert(player.crouch, "Crouch Image didn't load")
    
    player.currentAnimation = player.idle

    local width, height = player.currentAnimation:getImage():scaledImage(player.ratio, player.ratio):getSize()
    print("Player Dimensions Idle",width,height)

    player.velocity = { x = 0, y = 0 }

    -- Sound Effects
    player.jumpSound = sound.fileplayer.new("Sounds/SoundEffects/Jump")
    player.lazerSound = sound.fileplayer.new("Sounds/SoundEffects/Lazer")
    
    -- Verify we can get an image
    local initialImage = player.currentAnimation:getImage()
    
    player:setImage(initialImage)
    
    local floorLevel = playdateHeight - 32
    player:moveTo(200, floorLevel - 44)
    player:add()
end

local function setupAudio()
    -- Create a fileplayer for your soundtrack
    local soundtrack = sound.fileplayer.new("Sounds/SoundTracks/SoundTrack")  -- Assumes your file is in Sounds/soundtrack.wav
    if soundtrack then
        -- Set to loop when it reaches the end
        soundtrack:setLoopRange(0, soundtrack:getLength())
        soundtrack:play(0)  -- Play immediately from position 0
    else
        print("⚠️ Couldn't load soundtrack")
    end
end


local function createFloor()
    local tileImage = graphics.image.new("Images/stoneFloor") -- 1024x1024
    assert(tileImage, "⚠️ Couldn't load stoneFloor image")

    -- Scale down to 32x32
    local scaledTile = tileImage:scaledImage(32 / 1024, 32 / 1024)
    assert(scaledTile, "⚠️ Failed to scale floor image")

    local tileWidth, tileHeight = scaledTile:getSize()
    local floorY = playdateHeight - tileHeight

    for x = 0, playdateWidth, tileWidth do
        local tileSprite = graphics.sprite.new(scaledTile)
        tileSprite:moveTo(x + tileWidth / 2, floorY + tileHeight / 2)
        tileSprite:add()
    end

end

local function createBackground() 
    local backgroundImage = graphics.image.new("Images/mountain")
    assert(backgroundImage)

    graphics.sprite.setBackgroundDrawingCallback(
        function(x, y, width, height)
            backgroundImage:draw( 0, 0 )
        end
    )
end

local function myGameSetUp()

    local ceil <const> = math.ceil

    createPlayer() -- Create Player

    createFloor() -- Create Floor

    createBackground() -- Create Background

    setupAudio()
end

local function jump()
    if player.onGround then
        isJumping = true
        jumpStartTime = playdate.getCurrentTimeMilliseconds()
        player.jumpSound:play()
        player.currentAnimation = player.jump
        currentJumpVelocity = JUMP_VELOCITY
        player.onGround = false
    end
end

local function shoot()
    player.lazerSound:play()
end

local function continueJump()
    local currentTime = playdate.getCurrentTimeMilliseconds()
    local jumpTime = (currentTime - jumpStartTime) / 1000
    
    if jumpTime < JUMP_DURATION and playdate.buttonIsPressed("A") then
        currentJumpVelocity = JUMP_VELOCITY
    else
        isJumping = false
    end
end

local function applyPhysics()
    -- Apply gravity
    playerVelocity.y = playerVelocity.y + GRAVITY_CONSTANT * dt
    
    -- Apply jump force if jumping
    if isJumping then
        playerVelocity.y = currentJumpVelocity
    end
    
    -- Get current position
    local x, y = player:getPosition()
    
    -- Calculate new position
    local newX = x + playerVelocity.x * dt
    local newY = y + playerVelocity.y * dt
    
    -- Check ground collision
    local groundY = playdateHeight - 32 - 44
    if newY >= groundY then
        newY = groundY
        playerVelocity.y = 0
        player.onGround = true
        isJumping = false
    end
    
    -- Update position
    player:moveTo(newX, newY)
end

local function handleAnimations()
    if player.currentAnimation == player.jump or player.currentAnimation == player.crouch then
        -- Is a regular Image (not AnimatedImage)
        player:setImage(player.currentAnimation:scaledImage(1, 1), player.direction)
    else
        -- Is a Gif (AnimatedImage)
        player:setImage(player.currentAnimation:getImage():scaledImage(player.ratio, player.ratio), player.direction)
    end
end

function playdate.update()
    local function handleMovement()
        local didMove = false
        local speed = 120 -- pixels per second (higher because we're using velocity)
        
        -- Handle movement input
        if playdate.buttonIsPressed(playdate.kButtonLeft) then
            player.currentAnimation = player.moving
            playerVelocity.x = -speed
            player.direction = left
            didMove = true
        elseif playdate.buttonIsPressed(playdate.kButtonRight) then
            player.currentAnimation = player.moving
            playerVelocity.x = speed
            player.direction = right
            didMove = true
        else
            playerVelocity.x = 0 -- Stop horizontal movement when no input
        end


        -- Handle jumping
        if playdate.buttonJustPressed("A") and player.onGround then
            jump()
        elseif playdate.buttonIsPressed("A") and isJumping then
            continueJump()
        elseif not playdate.buttonIsPressed("A") and isJumping then
            currentJumpVelocity = -JUMP_VELOCITY * JUMP_CUT_SHORT_MULTIPLIER
        end

        if playdate.buttonJustPressed("B") then
            shoot()
        end

        if not didMove and player.onGround then
             -- Crouching
            if playdate.buttonIsPressed(playdate.kButtonDown) then
                player.currentAnimation = player.crouch
            else
                player.currentAnimation = player.idle
            end
        end
    end

    -- Movement Function
    handleMovement()
    applyPhysics()
    
    handleAnimations()
    -- player:setImage(player.currentAnimation:getImage():scaledImage(player.ratio, player.ratio) , player.direction)
    
    
    graphics.sprite.update()
    playdate.timer.updateTimers()
end


-- MAIN 
playdate.display.setRefreshRate(50)
myGameSetUp()