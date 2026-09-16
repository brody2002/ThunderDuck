import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"

import "../Shared/gravity"

local graphics <const> = playdate.graphics
local screenWidth <const> = playdate.display.getWidth()
local screenHeight <const> = playdate.display.getHeight()
local removalMargin <const> = 40
local rotationStep <const> = 5

local sourceImage = graphics.image.new("Images/lightning-bolt")
assert(sourceImage, "Lightning bolt image failed to load")

local rotatedImages = {}

local function getRotatedImage(angle)
    local snappedAngle = (math.floor((angle + rotationStep / 2) / rotationStep) * rotationStep) % 360

    if not rotatedImages[snappedAngle] then
        -- The source artwork naturally points at roughly 45 degrees.
        rotatedImages[snappedAngle] = sourceImage:rotatedImage(snappedAngle - 45)
    end

    return rotatedImages[snappedAngle]
end

class("LightningBolt").extends(graphics.sprite)

function LightningBolt:init(x, y, angle)
    LightningBolt.super.init(self)

    local radians = math.rad(angle)
    self.speed = 360
    self.velocityX = math.sin(radians) * self.speed
    self.velocityY = -math.cos(radians) * self.speed

    self:setImage(getRotatedImage(angle))
    self:setZIndex(1200)
    self:moveTo(x, y)
    self:add()
end

function LightningBolt:update()
    self:moveBy(
        self.velocityX * Physics.fixedDeltaTime,
        self.velocityY * Physics.fixedDeltaTime
    )

    if self.x < -removalMargin
        or self.x > screenWidth + removalMargin
        or self.y < -removalMargin
        or self.y > screenHeight + removalMargin then
        self:remove()
    end
end

return LightningBolt
