-- Playdate Imports
import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "../../Support/animatedImage"

local graphics <const> = playdate.graphics

local Chicken = {}

Chicken.create = function ()
    ---@class playdate.graphics.sprite
    local chicken = graphics.sprite.new()
    chicken.ratio = 1/32 -- Input Pngs are 1024x1024 by default
    
    chicken.full = graphics.image.new("UI/Assets/ChickenFull"):scaledImage(chicken.ratio)
    chicken.half = graphics.image.new("UI/Assets/ChickenHalf"):scaledImage(chicken.ratio)
    chicken.width, chicken.height = chicken.full:getSize()
    chicken.setZIndex = 10000
    
    return chicken
end

HealthBar = {}

HealthBar.create = function ()
    local healthBar = {}
    local chicken = Chicken.create()
    healthBar.hp = 6 -- One Whole Chicken per 2 hp points

    -- Position of the health bar
    healthBar.x = 32
    healthBar.y = 32

    -- Array to store Chickens
    healthBar.deletionArray = {}

    -- Draws Full Chicken for every 2 hp points
    -- Draws Half Chicken if remaining 1hp point
    -- 
    healthBar.drawHealth = function ()
        -- Clear Sprites 
        healthBar.deleteSprites()

        local fullCount = math.floor(healthBar.hp / 2)
        local hasHalf = (healthBar.hp % 2 == 1)
        local offsetX = 0
        local zIndex = 10000

        for _ = 1, fullCount do
            local fullChicken = graphics.sprite.new(chicken.full)
            fullChicken:moveTo(healthBar.x + offsetX, healthBar.y)
            fullChicken:setZIndex(zIndex)
            fullChicken:add()
            table.insert(healthBar.deletionArray, fullChicken)
            offsetX += chicken.width + 5
        end

        if hasHalf then
            local halfChicken = graphics.sprite.new(chicken.half)
            halfChicken:moveTo(healthBar.x + offsetX, healthBar.y)
            halfChicken:setZIndex(zIndex)
            halfChicken:add()
            table.insert(healthBar.deletionArray, halfChicken)
        end
    end

    healthBar.deleteSprites = function ()
        for _, sprite in ipairs(healthBar.deletionArray) do
            sprite:remove()
        end
        healthBar.deletionArray = {} 
    end

    healthBar.damageReceived = function ()
        if healthBar.hp > 0 then
            healthBar.hp -= 1
        end
        healthBar.drawHealth()
    end

    return healthBar
end

return HealthBar