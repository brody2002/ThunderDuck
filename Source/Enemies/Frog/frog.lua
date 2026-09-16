import "CoreLibs/graphics"

import "../../Characters/character"
import "../../Shared/playdateConstants"

local graphics <const> = playdate.graphics

class("Frog").extends(Character)

function Frog:init(spawnX, groundY)
    self.ratio = 28 / 96
    self.jumpTimer = 0
    self.frogImage = graphics.image.new("Images/frog"):scaledImage(self.ratio)
    assert(self.frogImage, "Frog failed to load")
    local frogWidth, frogHeight = self.frogImage:getSize()

    Frog.super.init(self, {
        name = "Frog",
        image = self.frogImage,
        spawnX = spawnX or 320,
        groundY = groundY,
        team = "enemy",
        tag = playdateConstants.tags.enemy,
        zIndex = 500,
        direction = graphics.kImageFlippedX,
        stats = {
            speed = 80,
            gravityScale = 1,
            jumpVelocity = -300,
            jumpInterval = 2,
            maximumFallSpeed = 450,
            maxHealth = 3,
            attackPower = 1,
            defense = 0,
            attackCooldown = 1,
            knockbackResistance = 0,
            startsOnGround = true,
            collider = {
                width = frogWidth,
                height = frogHeight
            }
        }
    })

    self:setMovement(-1)
end

function Frog:beforePhysics(deltaTime)
    if not self.onGround then
        return
    end

    self.jumpTimer += deltaTime

    if self.jumpTimer >= self.stats.jumpInterval then
        self.jumpTimer = 0
        self:jump()
    end
end

function Frog:afterPhysics(_deltaTime, physicsEvents)
    if physicsEvents.hitLeftBoundary or physicsEvents.blockedMovingLeft then
        self:setMovement(1)
        self.direction = graphics.kImageUnflipped
    elseif physicsEvents.hitRightBoundary or physicsEvents.blockedMovingRight then
        self:setMovement(-1)
        self.direction = graphics.kImageFlippedX
    end
end

function Frog:updateAnimation(_deltaTime)
    self:setImage(self.frogImage, self.direction)
end

return Frog
