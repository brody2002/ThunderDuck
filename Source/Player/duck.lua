import "CoreLibs/graphics"
import "../../Support/animatedimage"

import "../Characters/character"
import "../Shared/playdateConstants"
import "../Weapons/lightningBolt"

local graphics <const> = playdate.graphics
local sound <const> = playdate.sound

class("Duck").extends(Character)

function Duck:init(spawnX, groundY)
    self.ratio = 32 / 96
    self.weaponHeight = 38
    self.weaponRotationStep = 5
    self.weaponAngle = 45
    self.fireInterval = 0.4
    self.fireCooldown = 0
    self.idleAnimation = AnimatedImage.new(
        "Images/Duck/Gifs/idle",
        { delay = 200, loop = true, first = 1, last = 2 }
    )
    self.walkingAnimation = AnimatedImage.new(
        "Images/Duck/Gifs/Walking",
        { delay = 200, loop = true, first = 1, last = 2 }
    )
    self.crouchAnimation = graphics.image.new("Images/Duck/Sprites/Crouching/Crouching")
    self.jumpAnimation = graphics.image.new("Images/Duck/Sprites/Jumping/Jumping")

    assert(self.idleAnimation and self.walkingAnimation, "Duck animation failed to load")
    assert(self.crouchAnimation and self.jumpAnimation, "Duck image failed to load")

    self.currentAnimation = self.idleAnimation
    local initialImage = self.currentAnimation:getImage():scaledImage(self.ratio, self.ratio)

    Duck.super.init(self, {
        name = "Thunder Duck",
        image = initialImage,
        spawnX = spawnX or 80,
        groundY = groundY,
        team = "player",
        tag = playdateConstants.tags.player,
        zIndex = 1000,
        direction = graphics.kImageUnflipped,
        stats = {
            speed = 320,
            gravityScale = 2.0,
            jumpVelocity = -650,
            jumpCutMultiplier = 0.45,
            maximumFallSpeed = 500,
            maxHealth = 6,
            attackPower = 1,
            defense = 0,
            attackCooldown = 0.35,
            knockbackResistance = 0,
            startsOnGround = true,
            collider = {
                width = 28,
                height = 48
            }
        }
    })

    self.jumpSound = sound.fileplayer.new("Sounds/SoundEffects/Jump")
    self.lazerSound = sound.fileplayer.new("Sounds/SoundEffects/Lazer")

    local mjollnirSource = graphics.image.new("Images/mjolner")
    assert(mjollnirSource, "Mjollnir image failed to load")

    local _, mjollnirSourceHeight = mjollnirSource:getSize()
    local weaponScale = self.weaponHeight / mjollnirSourceHeight
    local weaponImage = mjollnirSource:scaledImage(weaponScale, weaponScale)
    local weaponWidth, weaponHeight = weaponImage:getSize()

    -- Put the bottom of the handle at the center of a transparent canvas.
    -- Rotating this canvas keeps that grip point pinned to Duck's hand.
    local pivotCanvasSize = self.weaponHeight * 2 + 4
    local pivot = pivotCanvasSize / 2
    self.weaponPivotImage = graphics.image.new(pivotCanvasSize, pivotCanvasSize)
    graphics.pushContext(self.weaponPivotImage)
        weaponImage:draw(
            math.floor(pivot - weaponWidth / 2),
            math.floor(pivot - weaponHeight)
        )
    graphics.popContext()

    self.weaponImageCache = {}
    self.weaponSprite = graphics.sprite.new(self:getWeaponImage(self.weaponAngle))
    self.weaponSprite:setZIndex(self:getZIndex() + 100)
    self.weaponSprite:add()
    self:updateWeapon()
end

function Duck:getWeaponImage(angle)
    local step = self.weaponRotationStep
    local snappedAngle = (math.floor((angle + step / 2) / step) * step) % 360

    if not self.weaponImageCache[snappedAngle] then
        self.weaponImageCache[snappedAngle] = self.weaponPivotImage:rotatedImage(snappedAngle)
    end

    return self.weaponImageCache[snappedAngle]
end

function Duck:getWeaponHandPosition()
    local horizontalOffset = 7
    local verticalOffset = -20

    if self.currentAnimation == self.crouchAnimation then
        verticalOffset = -15
    end

    if self.direction == graphics.kImageFlippedX then
        horizontalOffset = -horizontalOffset
    end

    return self.x + horizontalOffset, self.y + verticalOffset
end

function Duck:updateWeaponAngle()
    if playdate.isCrankDocked() then
        if self.direction == graphics.kImageFlippedX then
            self.weaponAngle = 315
        else
            self.weaponAngle = 45
        end
    else
        self.weaponAngle = playdate.getCrankPosition()
    end
end

function Duck:updateWeapon()
    local handX, handY = self:getWeaponHandPosition()
    self:updateWeaponAngle()

    self.weaponSprite:setZIndex(self:getZIndex() + 100)
    self.weaponSprite:setImage(self:getWeaponImage(self.weaponAngle))
    self.weaponSprite:moveTo(handX, handY)
end

function Duck:fireLightning()
    local handX, handY = self:getWeaponHandPosition()
    self:updateWeaponAngle()

    local radians = math.rad(self.weaponAngle)
    local muzzleDistance = self.weaponHeight - 4
    local spawnX = handX + math.sin(radians) * muzzleDistance
    local spawnY = handY - math.cos(radians) * muzzleDistance

    LightningBolt(spawnX, spawnY, self.weaponAngle)

    if self.lazerSound then
        self.lazerSound:play()
    end
end

function Duck:beforePhysics(deltaTime)
    local didMove = false

    if playdate.buttonIsPressed(playdate.kButtonLeft) then
        self:setMovement(-1)
        self.direction = graphics.kImageFlippedX
        didMove = true
    elseif playdate.buttonIsPressed(playdate.kButtonRight) then
        self:setMovement(1)
        self.direction = graphics.kImageUnflipped
        didMove = true
    else
        self:stopMoving()
    end

    if didMove and self.onGround then
        self.currentAnimation = self.walkingAnimation
    end

    if playdate.buttonJustPressed(playdate.kButtonA) and self:jump() then
        if self.jumpSound then
            self.jumpSound:play()
        end
        self.currentAnimation = self.jumpAnimation
    elseif playdate.buttonJustReleased(playdate.kButtonA) then
        self:cutJumpShort()
    end

    self.fireCooldown = math.max(0, self.fireCooldown - deltaTime)

    if playdate.buttonIsPressed(playdate.kButtonB) and self.fireCooldown <= 0 then
        self:fireLightning()
        self.fireCooldown = self.fireInterval
    end

    if not didMove and self.onGround then
        if playdate.buttonIsPressed(playdate.kButtonDown) then
            self.currentAnimation = self.crouchAnimation
        else
            self.currentAnimation = self.idleAnimation
        end
    elseif not self.onGround then
        self.currentAnimation = self.jumpAnimation
    end
end

function Duck:updateAnimation(_deltaTime)
    local image

    if self.currentAnimation == self.jumpAnimation or self.currentAnimation == self.crouchAnimation then
        image = self.currentAnimation
    else
        image = self.currentAnimation:getImage():scaledImage(self.ratio, self.ratio)
    end

    self:setImage(image, self.direction)
    self:updateWeapon()
end

return Duck
