import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "/../Support/animatedimage"

-- ThunderDuck Imports  
import "../../../Support/animatedimage"
import "../../Shared/playdateConstants"

local graphics <const> = playdate.graphics

Po = {}

Po.create = function()
     -- Create the sprite object
    ---@class playdate.graphics.sprite
    local po = graphics.sprite.new()
    
    -- Directions
    local left, right = 1, 0 
    
    -- Properties
    po.direction = right
    po.onGround = true
    po.ratio = 1
    po.velocity = { x = 0, y = 0 }
    
    -- Private state
    local isJumping = false
    local jumpStartTime = 0
    local currentJumpVelocity = 0
    local movementVelocity = { x = 0, y = 0 }
    
    -- Load animations  Enemies/Po/Po-idle
    po.idleAnimation = graphics.imagetable.new
    po.idleAnimation = AnimatedImage.new("Enemies/Po/Sprites/Idle", {delay = 40, loop = true, first = 1, last = 36 })

    assert(po.idleAnimation, "animation not found!")
    po.currentAnimation = po.idleAnimation

    po.width, po.height = po.currentAnimation:getImage():scaledImage(po.ratio, po.ratio):getSize()

    -- Initial setup
    local initialImage = po.currentAnimation:getImage()
    po:setImage(initialImage)
    local floorLevel = playdateConstants.playdateHeight - po.height
    po:moveTo(200, 120)
    po:add()

    po.updateFrame = function(self)
         -- Is a Gif (AnimatedImage)
        po:setImage(po.currentAnimation:getImage():scaledImage(po.ratio, po.ratio), po.direction)
    end
    
    return po
end

return Po