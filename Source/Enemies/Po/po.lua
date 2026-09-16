import "CoreLibs/graphics"
import "../../../Support/animatedimage"

import "../../Characters/character"
import "../../Shared/playdateConstants"

local graphics <const> = playdate.graphics

class("Po").extends(Character)

function Po:init(spawnX, groundY)
    self.ratio = 1
    self.idleAnimation = AnimatedImage.new(
        "Enemies/Po/Sprites/Idle",
        { delay = 40, loop = true, first = 1, last = 36 }
    )
    assert(self.idleAnimation, "Panda animation failed to load")

    self.currentAnimation = self.idleAnimation
    local initialImage = self.currentAnimation:getImage():scaledImage(self.ratio, self.ratio)

    Po.super.init(self, {
        name = "Panda",
        image = initialImage,
        spawnX = spawnX or 210,
        groundY = groundY,
        spawnHeight = 80,
        team = "boss",
        tag = playdateConstants.tags.enemy,
        zIndex = 500,
        direction = graphics.kImageUnflipped,
        stats = {
            speed = 70,
            gravityScale = 1,
            jumpVelocity = -380,
            maximumFallSpeed = 450,
            maxHealth = 30,
            attackPower = 2,
            defense = 1,
            attackCooldown = 0.8,
            knockbackResistance = 0.4,
            startsOnGround = false,
            -- Panda's art occupies y=60..133 in a 256px animation frame.
            -- This collider aligns the visible feet instead of the transparent canvas.
            collider = {
                x = 98,
                y = 60,
                width = 61,
                height = 73
            }
        }
    })
end

function Po:updateAnimation(_deltaTime)
    self:setImage(
        self.currentAnimation:getImage():scaledImage(self.ratio, self.ratio),
        self.direction
    )
end

return Po
