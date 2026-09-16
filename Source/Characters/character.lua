import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"

import "../Shared/playdateConstants"
import "../Shared/gravity"

local graphics <const> = playdate.graphics

class("Character").extends(graphics.sprite)

Character.defaultStats = {
    speed = 0,
    gravityScale = 1,
    jumpVelocity = -350,
    jumpCutMultiplier = 0.5,
    maximumFallSpeed = 500,
    maxHealth = 1,
    attackPower = 1,
    defense = 0,
    attackCooldown = 1,
    knockbackResistance = 0,
    startsOnGround = false
}

local function copyStats(overrides)
    local stats = {}

    for key, value in pairs(Character.defaultStats) do
        stats[key] = value
    end

    for key, value in pairs(overrides or {}) do
        stats[key] = value
    end

    return stats
end

function Character:init(config)
    Character.super.init(self)

    assert(config, "Character requires a configuration")
    assert(config.image, "Character requires an initial image")

    self.characterName = config.name or "Character"
    self.isCharacter = true
    self.stats = copyStats(config.stats)
    self.health = self.stats.maxHealth
    self.team = config.team or "neutral"
    self.direction = config.direction or graphics.kImageUnflipped

    self:setImage(config.image)
    self:setCenter(0.5, 1)
    self:setTag(config.tag or playdateConstants.tags.enemy)
    self:setZIndex(config.zIndex or 500)

    Physics.attach(self, self.stats)
    local spawnX = config.spawnX or playdateConstants.playdateWidth / 2
    local groundY = config.groundY or playdateConstants.floorLevel
    local groundedY = groundY + self.physicsGroundOffset
    self:moveTo(spawnX, groundedY - (config.spawnHeight or 0))
    self:add()
end

-- This is the shared Character protocol. Subclasses customize the three hooks
-- instead of replacing the physics/update order.
function Character:updateFrame(deltaTime)
    self:beforePhysics(deltaTime)
    self.physicsEvents = Physics.update(self, deltaTime)
    self:afterPhysics(deltaTime, self.physicsEvents)
    self:updateAnimation(deltaTime)
end

function Character:beforePhysics(_deltaTime)
end

function Character:afterPhysics(_deltaTime, _physicsEvents)
end

function Character:updateAnimation(_deltaTime)
end

function Character:jump()
    return Physics.jump(self)
end

function Character:cutJumpShort()
    Physics.cutJumpShort(self)
end

function Character:setMovement(direction)
    self.velocity.x = direction * self.stats.speed
end

function Character:stopMoving()
    self.velocity.x = 0
end

function Character:placeOnGround(x, groundY)
    -- Some animation frames contain transparent padding below the artwork.
    -- Offset by the collider bottom so the character's feet touch the platform.
    self:moveTo(x, groundY + self.physicsGroundOffset)
end

function Character:takeDamage(amount)
    local damage = math.max(0, amount - self.stats.defense)
    self.health = math.max(0, self.health - damage)
    return damage
end

function Character:isAlive()
    return self.health > 0
end

function Character:collisionResponse(other)
    if other.isPlatform or other.isCharacter then
        return graphics.sprite.kCollisionTypeSlide
    end

    -- Attacks will use separate overlap hitboxes; character bodies stay solid.
    return graphics.sprite.kCollisionTypeOverlap
end

return Character
