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

    -- Directions
    local left, right = 1, 0 

    -- Properties
    frog.direction = left
    frog.onGround = true
    frog.velocity = { x = 0, y = 0}
    frog.ratio = 28/96

    local jumpDelay = 0
    local movementVelocity = { x = 0, y = 0 }
    local x, y = frog:getPosition()
    

    -- Load animations (Needs work)
    local frogImage = graphics.image.new("Images/frog"):scaledImage(frog.ratio)
    assert(frogImage, "Frog failed to load")

    frog.width, frog.height = frogImage:getSize()

    -- Sound effects (N/A)

    -- Initial setup (Needs work)
    frog:setImage(frogImage)
    -- DON'T KNOW WHY frog.height NEEDS TO BE DIVIDED BY 4
    frog:moveTo(300, playdateConstants.floorLevel - frog.height/4)
    frog:add()

    local groundY = playdateConstants.floorLevel - frog.height/4

    -- Define functions where things happen LOL

    frog.applyPhysics = function ()

        -- Update current position
        x, y = frog:getPosition()

        -- Apply gravity
        local newX = x + movementVelocity.x * gravity.dt
        local newY = y + movementVelocity.y * gravity.dt

        -- Check ground collision
        if newY < 0 then
            newY = 0
            movementVelocity.y = 80
        elseif newY >= groundY then
            newY = groundY
            movementVelocity.y = 0
            frog.onGround = true
        end

        -- Check side collision
        -- THERE NEEDS TO BE SOME ADJUSTMENT ON THE FROG SPRITE WIDTH AND I DON'T KNOW WHY :(
        -- frog.width / 4 IS NOT PERFECT BUT IT'S CLOSE
        if newX >= playdateConstants.playdateWidth - frog.width / 4 then
            newX = playdateConstants.playdateWidth - frog.width / 4
            movementVelocity.x = movementVelocity.x * -1
            frog.direction = left
        elseif newX <= 0 + frog.width / 4 then
            newX = 0 + frog.width / 4
            movementVelocity.x = movementVelocity.x * -1
            frog.direction = right
        end

        -- Update position
        frog:moveTo(newX, newY)

    end

    frog.setDirection = function ()
        if frog.direction == left then
            frog:setImage(frogImage)
        elseif frog.direction == right then
            frog:setImage(frogImage, "flipX")
        end
    end

    frog.jumpCycle = function ()
        -- Increment delay if frog is on ground
        if frog.onGround == true then
            jumpDelay = jumpDelay + 1
        end
        -- Set velocity to going up and set not on ground (jump the frog lol)
        if jumpDelay / 100 == 1 then
            jumpDelay = 0
            movementVelocity.y = -120
            frog.onGround = false
        end
    end

    frog.initializeMovement = function ()
        movementVelocity.x = -80
        frog.direction = left
    end

    frog.updateFrame = function ()

        frog:applyPhysics()
        frog.setDirection()
        frog:jumpCycle()

    end

    return frog

end

return Frog