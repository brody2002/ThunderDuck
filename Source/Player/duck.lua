import "CoreLibs/graphics"
import "../../Support/animatedimage"

import "../Characters/character"
import "../Shared/playdateConstants"

local graphics <const> = playdate.graphics
local sound <const> = playdate.sound

class("Duck").extends(Character)

function Duck:init(spawnX, groundY)
    self.ratio = 32 / 96
    self.weaponHeight = 38
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
    self.weaponImageRight = mjollnirSource:rotatedImage(45, weaponScale)
    self.weaponImageLeft = mjollnirSource:rotatedImage(-45, weaponScale)
    self.weaponSprite = graphics.sprite.new(self.weaponImageRight)
    self.weaponSprite:setZIndex(self:getZIndex() + 100)
    self.weaponSprite:add()
    self:updateWeapon()
end

function Duck:updateWeapon()
    local horizontalOffset = 19
    local verticalOffset = -33
    local weaponImage = self.weaponImageRight

    if self.currentAnimation == self.crouchAnimation then
        verticalOffset = -28
    end

    if self.direction == graphics.kImageFlippedX then
        horizontalOffset = -horizontalOffset
        weaponImage = self.weaponImageLeft
    end

    self.weaponSprite:setZIndex(self:getZIndex() + 100)
    self.weaponSprite:setImage(weaponImage)
    self.weaponSprite:moveTo(self.x + horizontalOffset, self.y + verticalOffset)
end

function Duck:beforePhysics(_deltaTime)
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

    if playdate.buttonJustPressed(playdate.kButtonB) and self.lazerSound then
        self.lazerSound:play()
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
