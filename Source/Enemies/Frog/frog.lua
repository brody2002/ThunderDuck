-- Playdate Imports
import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "../Support/animatedimage"


-- ThunderDuck Imports  
import "../../Shared/playdateConstants"
import "../../Shared/gravity"

local graphics <const> = playdate.graphics
local sound <const> = playdate.sound

Frog = {}

Frog.create = function()
    -- create the sprite
    ---@class playdate.graphics.sprite
    local frog = graphics.sprite.new()
    local tongueExtra = graphics.sprite.new()
    local spitball = graphics.sprite.new()

    -- Directions
    local left, right = 1, 0 

    -- Properties
    frog.direction = left
    frog.onGround = true
    frog.velocity = { x = 0, y = 0}

    local movementVelocity = { x = 0, y = 0 }
    local x, y = frog:getPosition()
    

    -- Load animations (Needs work)
    frog.defaultImage = graphics.image.new("Images/Frog/frog"):scaledImage(2)
    frog.tongueAttackImage = graphics.image.new("Images/Frog/frogAttack"):scaledImage(2)
    assert(frog.defaultImage, "Frog failed to load")
    
    tongueExtra.defaultImage = graphics.image.new("Images/Frog/frogTongue"):scaledImage(2)

    spitball.defaultImage = graphics.image.new("Images/Frog/frogSpitball"):scaledImage(2)

    -- Sound effects (N/A)

    -- Initial setup (Needs work)
    frog:setImage(frog.defaultImage)
    tongueExtra:setImage(tongueExtra.defaultImage)
    spitball:setImage(spitball.defaultImage)

    frog:setZIndex(playdateConstants.frogZIndex)
    tongueExtra:setZIndex(playdateConstants.tongueZIndex)
    spitball:setZIndex(playdateConstants.spitballZIndex)

    frog.enterSFX = sound.fileplayer.new("Sounds/SoundEffects/CTMR")
    
    -- Don't know WHY THE FUCK there need to be scalars on these but they are necessary AFAIK
    local frogWidth = 96
    local frogHeight = 96
    local frogWidthPadding = 29
    local frogHeightPadding = 70
    local extraTonguePadding = 66 + 96
    local spitballVelocity = 60
    frog.tonguePadding = 16

    local groundY = playdateConstants.floorLevel - frogHeight
    frog:moveTo(1000, groundY)
    frog:add()

    frog.patternCounter = 0
    frog.patternStage = 0
    frog.attackDelay = 0
    frog.jumpVelocity = 0

    local initialDirection

    frog.fallVelocity = 80

    frog.stageEntered = false
    frog.entering = true
    frog.attacking = false

    -- Define functions where things happen LOL

    frog.applyPhysics = function ()

        -- Update current position
        x, y = frog:getPosition()

        -- Apply gravity
        local newX = x + movementVelocity.x * gravity.dt
        local newY = y + movementVelocity.y * gravity.dt

        -- Check ground collision
        if newY < 0 - frogHeightPadding then
            -- If travelling off the top of the screen, fix position and change the y velocity to falling velocity
            newY = 0 - frogHeightPadding
            movementVelocity.y = frog.fallVelocity
        elseif newY > groundY then
            -- If travelling below the floor, fix position and zero the y velocity
            newY = groundY
            movementVelocity.y = 0
            frog.onGround = true
        end

        -- Check side collision
        if newX > playdateConstants.playdateWidth - frogWidthPadding then
            -- If off the right of the screen fix position, change velocity, and switch direction
            newX = playdateConstants.playdateWidth - frogWidthPadding
            movementVelocity.x = movementVelocity.x * -1
            frog.direction = left
            frog:setImage(frog.defaultImage)
        elseif newX < 0 + frogWidthPadding then
            -- If off the left of the screen fix position, change velocity, and switch direction
            newX = 0 + frogWidthPadding
            movementVelocity.x = movementVelocity.x * -1
            frog.direction = right
            frog:setImage(frog.defaultImage, "flipX")
        end

        -- Update position
        frog:moveTo(newX, newY)

    end


    frog.initializeMovement = function ()
        -- Spawn in the frog off screen
        frog:moveTo(playdateConstants.playdateWidth - frogWidthPadding, groundY)
    end


    frog.enterMove = function ()
        -- Update current position
        x, y = frog:getPosition()

        -- While frog is still coming on screen
        if frog.entering == true then

            -- Slow jump cycle on screen
            if frog.patternCounter < 25 then
                -- Going up
                
                -- Only increment x every other frame so as to move a bit slower
                if frog.patternCounter % 2 == 0 then
                    frog:moveTo(x, y - 1)
                else
                    frog:moveTo(x - 1, y - 1)
                end

                -- Update position and spot in cycle
                x, y = frog:getPosition()
                frog.patternCounter = frog.patternCounter + 1

            elseif frog.patternCounter < 50 then
                -- Going down

                -- Same idea as before
                if frog.patternCounter % 2 == 0 then
                    frog:moveTo(x, y + 1)
                else
                    frog:moveTo(x - 1, y + 1)
                end

                -- Update positiona and spot in cycle
                x, y = frog:getPosition()
                frog.patternCounter = frog.patternCounter + 1

            -- Wait on the ground for a bit between jumps
            elseif frog.patternCounter < 100 then
                frog.patternCounter = frog.patternCounter + 1

            -- Reset slow jump cycle
            else
                frog.patternCounter = 0
            end
            
        end

        -- If the frog is far enough on screen, frog is now considered to have finished "entering" the stage
        if x <= 300 and y == groundY and frog.entering == true then
            -- Play SFX, update status etc
            frog.enterSFX:play()
            frog.entering = false
            frog.patternCounter = 0
        end

        -- Final bit of waiting while SFX plays before frog has fully "entered"
        if frog.entering == false and frog.patternCounter < 85 then
            -- Wait a bit lol
            frog.patternCounter = frog.patternCounter + 1
        elseif frog.entering == false then
            -- Reset counter for other usages, go to initial battle spot, set "entered"
            frog.patternCounter = 0
            frog:moveTo(playdateConstants.playdateWidth - frogWidthPadding, groundY)
            frog.stageEntered = true
        end

    end


    frog.tongueAttack = function()
        -- Toggle the status of the frog doing a tongueAttack attack or not, while updating the image
        if frog.attacking == false then
            -- If not attacking, change to an attack image based on direction
            if frog.direction == left then
                frog:setImage(frog.tongueAttackImage)
            else
                frog:setImage(frog.tongueAttackImage, "flipX")
            end
            
            -- Set attacking
            frog.attacking = true
        elseif frog.attacking == true then
            -- If attacking, change to an idle image based on direction
            if frog.direction == left then
                frog:setImage(frog.defaultImage)
            else
                frog:setImage(frog.defaultImage, "flipX")
            end

            -- Set not attacking
            frog.attacking = false
        end

    end


    frog.attackPattern = function ()
        -- Attack pattern for the frog. Does a tongue attack, then jumps across the screen.
        if frog.patternStage == 0 then
            -- Stage 0: Generate delay for tongue attack
            frog.attackDelay = math.random(25, 45)
            frog.patternStage += 1
        elseif frog.patternStage == 1 then
            -- Stage 1: Perform tongue attack

            -- Wait frog.attackDelay frames, then attack, and regenerate delay
            if frog.patternCounter > frog.attackDelay then
                frog.tongueAttack()
                -- Add extra tongue piece
                tongueExtra:add()

                -- Fix positioning and sprite of extra tongue piece as well as wider attacking frog sprite
                if frog.direction == left then
                    frog:moveBy(-frog.tonguePadding, 0)
                    tongueExtra:setImage(tongueExtra.defaultImage)
                    tongueExtra:moveTo(playdateConstants.playdateWidth - frogWidthPadding - extraTonguePadding, y)
                else
                    frog:moveBy(frog.tonguePadding, 0)
                    tongueExtra:setImage(tongueExtra.defaultImage, "flipX")
                    tongueExtra:moveTo(0 + frogWidthPadding + extraTonguePadding, y)
                end
                frog.patternCounter = 0
                frog.patternStage += 1
                frog.attackDelay = math.random(25, 40)
            else
                frog.patternCounter += 1
            end

        elseif frog.patternStage == 2 then
            -- Stage 2: Wait a bit, retract tongue, and prepare to jump

            -- Wait the specified delay for the tongue being out
            if frog.patternCounter < frog.attackDelay then
                frog.patternCounter += 1
            elseif frog.patternCounter == frog.attackDelay then
                -- Retract tongue, randomize jump delay and speed, set initial direction
                frog.tongueAttack()
                tongueExtra:remove()
                -- Correct for switching back to narrower idle sprite
                if frog.direction == left then
                    frog:moveBy(frog.tonguePadding, 0)
                else
                    frog:moveBy(-frog.tonguePadding, 0)
                end
                frog.patternCounter = 0
                frog.patternStage += 1
                frog.attackDelay = math.random(20, 35)
                frog.jumpVelocity = math.random(-110, -60)
                movementVelocity.x = math.random(35, 55)
                initialDirection = frog.direction
            end

        elseif frog.patternStage == 3 then
            -- Stage 3: Jump around a bit, stop at the other side
            if frog.direction ~= initialDirection then
                -- If other wall has been reached stop moving
                movementVelocity.x = 0
                frog.patternCounter = 0
                if frog.onGround == true then
                    -- After landing on ground, reset
                    frog.patternStage = 0
                end
            elseif frog.onGround == true then
                -- If on ground and have not reached other wall, start jumping
                if frog.patternCounter >= frog.attackDelay then
                    movementVelocity.y = frog.jumpVelocity
                    frog.onGround = false
                else
                    frog.patternCounter += 1
                end

            end

        end

    end


    frog.updateFrame = function ()
        -- Wait for the frog to enter the stage, then proceed with the pattern
        if frog.stageEntered == true then
            frog:attackPattern()
            frog:applyPhysics()
        elseif frog.stageEntered == false then
            frog:enterMove()
        end
        print(frog:getPosition())

    end


    -- Setup the FROGGGG
    frog:initializeMovement()
    return frog

end


return Frog