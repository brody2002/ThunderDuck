-- Physics owns the rules that every character shares. Character-specific values
-- (speed, jump velocity, gravity scale, etc.) live on character.stats.
Physics = {
    gravity = 1200,
    fixedDeltaTime = 1 / 50,
    maximumDeltaTime = 1 / 20,
    defaultMaximumFallSpeed = 500
}

local function clamp(value, minimum, maximum)
    return math.max(minimum, math.min(value, maximum))
end

function Physics.attach(character, stats)
    character.stats = stats
    character.velocity = {
        x = stats.initialVelocityX or 0,
        y = stats.initialVelocityY or 0
    }
    character.onGround = stats.startsOnGround == true

    local spriteWidth, spriteHeight = character:getSize()
    local collider = stats.collider or {}
    local colliderWidth = collider.width or spriteWidth
    local colliderHeight = collider.height or spriteHeight
    local colliderX = collider.x or (spriteWidth - colliderWidth) / 2
    local colliderY = collider.y or (spriteHeight - colliderHeight)

    character:setCollideRect(colliderX, colliderY, colliderWidth, colliderHeight)
    character.physicsColliderWidth = colliderWidth
    character.physicsGroundOffset = spriteHeight - (colliderY + colliderHeight)
end

function Physics.jump(character)
    if not character.onGround then
        return false
    end

    character.velocity.y = character.stats.jumpVelocity
    character.onGround = false
    return true
end

function Physics.cutJumpShort(character)
    if character.velocity.y < 0 then
        character.velocity.y *= character.stats.jumpCutMultiplier or 0.5
    end
end

function Physics.update(character, deltaTime)
    local stats = character.stats
    local velocity = character.velocity
    local dt = clamp(deltaTime or Physics.fixedDeltaTime, 0, Physics.maximumDeltaTime)
    local gravityScale = stats.gravityScale or 1
    local maximumFallSpeed = stats.maximumFallSpeed or Physics.defaultMaximumFallSpeed

    velocity.y = math.min(
        velocity.y + Physics.gravity * gravityScale * dt,
        maximumFallSpeed
    )

    local targetX = character.x + velocity.x * dt
    local targetY = character.y + velocity.y * dt
    local halfColliderWidth = character.physicsColliderWidth / 2
    local leftBoundary = stats.leftBoundary or halfColliderWidth
    local rightBoundary = stats.rightBoundary or (playdate.display.getWidth() - halfColliderWidth)
    local hitLeftBoundary = targetX < leftBoundary
    local hitRightBoundary = targetX > rightBoundary

    targetX = clamp(targetX, leftBoundary, rightBoundary)

    local _, _, collisions, collisionCount = character:moveWithCollisions(targetX, targetY)
    local isGrounded = false
    local blockedMovingLeft = false
    local blockedMovingRight = false
    local hitCharacter = false

    for index = 1, collisionCount do
        local collision = collisions[index]
        local isSolid = collision.other.isPlatform or collision.other.isCharacter

        if isSolid then
            if collision.normal.y == -1 and velocity.y >= 0 then
                velocity.y = 0
                isGrounded = true
            elseif collision.normal.y == 1 and velocity.y < 0 then
                velocity.y = 0
            end

            if collision.normal.x ~= 0 then
                velocity.x = 0
                blockedMovingLeft = blockedMovingLeft or collision.normal.x == 1
                blockedMovingRight = blockedMovingRight or collision.normal.x == -1
            end

            hitCharacter = hitCharacter or collision.other.isCharacter == true
        end
    end

    character.onGround = isGrounded

    return {
        hitLeftBoundary = hitLeftBoundary,
        hitRightBoundary = hitRightBoundary,
        blockedMovingLeft = blockedMovingLeft,
        blockedMovingRight = blockedMovingRight,
        hitCharacter = hitCharacter,
        landed = isGrounded
    }
end

return Physics
