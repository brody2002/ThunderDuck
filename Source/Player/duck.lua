-- Playdate Imports
import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "../../Support/animatedimage"

-- ThunderDuck Imports  
import "./../Shared/playdateConstants"
import "./../Shared/gravity"

local graphics <const> = playdate.graphics
local sound <const> = playdate.sound

Duck = {}

Duck.create = function()
    -- Create the sprite object
    ---@class playdate.graphics.sprite
    local duck = graphics.sprite.new()
    
    -- Directions
    local left, right = 1, 0 
    
    -- Properties
    duck.direction = right
    duck.onGround = true
    duck.ratio = 32/96 -- Ratio for Gifs 
    duck.velocity = { x = 0, y = 0 }
    
    -- Private state
    local isJumping = false
    local jumpStartTime = 0
    local currentJumpVelocity = 0
    local movementVelocity = { x = 0, y = 0 }
    
    -- Load animations
    duck.idleAnimation = AnimatedImage.new("Images/Duck/Gifs/idle", {delay = 200, loop = true, first = 1, last = 2})
    duck.walkingAnimation = AnimatedImage.new("Images/Duck/Gifs/Walking", {delay = 200, loop = true, first = 1, last = 2})
    duck.crouchAnimation = graphics.image.new("Images/Duck/Sprites/Crouching/Crouching")
    duck.jumpAnimation = graphics.image.new("Images/Duck/Sprites/Jumping/Jumping")
    
    duck.currentAnimation = duck.idleAnimation

    duck.width, duck.height = duck.currentAnimation:getImage():scaledImage(duck.ratio, duck.ratio):getSize()

    -- Sound Effects
    duck.jumpSound = sound.fileplayer.new("Sounds/SoundEffects/Jump")
    duck.lazerSound = sound.fileplayer.new("Sounds/SoundEffects/Lazer")
    
    -- Initial setup
    local initialImage = duck.currentAnimation:getImage()
    duck:setImage(initialImage)
    local floorLevel = playdateConstants.playdateHeight - duck.height
    duck:moveTo(200, floorLevel - 44)
    duck:add()
    
    -- Define functions as properties of the duck object
    duck.jump = function()
        if duck.onGround then
            isJumping = true
            jumpStartTime = playdate.getCurrentTimeMilliseconds()
            duck.jumpSound:play()
            duck.currentAnimation = duck.jumpAnimation
            currentJumpVelocity = gravity.JUMP_VELOCITY
            duck.onGround = false
        end
    end

    duck.shoot = function()
        duck.lazerSound:play()
    end

    duck.continueJump = function()
        local currentTime = playdate.getCurrentTimeMilliseconds()
        local jumpTime = (currentTime - jumpStartTime) / 1000
        
        if jumpTime < gravity.JUMP_DURATION and playdate.buttonIsPressed("A") then
            currentJumpVelocity = gravity.JUMP_VELOCITY
        else
            isJumping = false
        end
    end

    duck.applyPhysics = function()
        -- Apply gravity
        movementVelocity.y = movementVelocity.y + gravity.GRAVITY_CONSTANT * gravity.dt
        
        -- Apply jump force if jumping
        if isJumping then
            movementVelocity.y = currentJumpVelocity
        end
        
        -- Get current position
        local x, y = duck:getPosition()
        
        -- Calculate new position
        local newX = x + movementVelocity.x * gravity.dt
        local newY = y + movementVelocity.y * gravity.dt
        
        -- Check ground collision
        local groundY = playdateConstants.playdateHeight - 32 - 44
        if newY >= groundY then
            newY = groundY
            movementVelocity.y = 0
            duck.onGround = true
            isJumping = false
        end
        
        -- Update position
        duck:moveTo(newX, newY)
    end

    duck.handleAnimations = function()
        -- Is a static Image
        if duck.currentAnimation == duck.jumpAnimation or duck.currentAnimation == duck.crouchAnimation then
            duck:setImage(duck.currentAnimation:scaledImage(1,1), duck.direction)
        else
            -- Is a Gif (AnimatedImage)
            duck:setImage(duck.currentAnimation:getImage():scaledImage(duck.ratio, duck.ratio), duck.direction)
        end
    end

    duck.handleMovement = function()
        local didMove = false
        local speed = 120
        
        -- Handle movement input
        if playdate.buttonIsPressed(playdate.kButtonLeft) then
            if duck.onGround then
                duck.currentAnimation = duck.walkingAnimation
            end
            movementVelocity.x = -speed
            duck.direction = left
            didMove = true
        elseif playdate.buttonIsPressed(playdate.kButtonRight) then
            if duck.onGround then 
                duck.currentAnimation = duck.walkingAnimation
            end
            movementVelocity.x = speed
            duck.direction = right
            didMove = true
        else
            movementVelocity.x = 0
        end

        -- Handle jumping
        if playdate.buttonJustPressed("A") and duck.onGround then
            duck:jump()
        elseif playdate.buttonIsPressed("A") and isJumping then
            duck:continueJump()
        elseif not playdate.buttonIsPressed("A") and isJumping then
            currentJumpVelocity = -gravity.JUMP_VELOCITY * gravity.JUMP_CUT_SHORT_MULTIPLIER
        end

        if playdate.buttonJustPressed("B") then
            duck:shoot()
        end

        if not didMove and duck.onGround then
            if playdate.buttonIsPressed(playdate.kButtonDown) then
                duck.currentAnimation = duck.crouchAnimation
            else
                duck.currentAnimation = duck.idleAnimation
            end
        end
    end

    duck.updateFrame = function()
        duck:handleMovement()
        duck:applyPhysics()
        duck:handleAnimations()
    end

    return duck
end

return Duck