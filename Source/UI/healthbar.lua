-- Playdate Imports
import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "../../Support/animatedImage"

local graphics <const> = playdate.graphics

local Chicken = {}

Chicken.create = function ()
    local chicken = {}
    ---@class playdate.graphics.sprite
    chicken.sprite = graphics.sprite.new()
    chicken.ratio = 1/32
    
    chicken.full = graphics.image.new("UI/Assets/ChickenFull"):scaledImage(chicken.ratio)
    chicken.half = graphics.image.new("UI/Assets/ChickenHalf"):scaledImage(chicken.ratio)
    chicken.setZIndex = 10
    chicken.currentImage = chicken.full
    
    -- Dimensions AFTER scaling
    chicken.width, chicken.height = chicken.currentImage:scaledImage(chicken.ratio, chicken.ratio):getSize()
    
    return chicken
end

HealthBar = {}

HealthBar.create = function ()
    local healthBar = {}
    local chickenSprite = Chicken.create()
    healthBar.hp = 6 -- One Whole Chicken per 2 hp points

    -- Position of the health bar
    healthBar.x = 200
    healthBar.y = 120

    -- Draws Full Chicken for every 2 hp points
    -- Draws Half Chicken if remaining 1hp point
    healthBar.drawHealth = function ()
        local hpLeft = healthBar.hp
        local offsetX = 0

        while hpLeft > 0 do
            ---@class graphics.image
            local image
            if hpLeft >= 2 then
                image = chickenSprite.full
                hpLeft -= 2
            else
                image = chickenSprite.half
                hpLeft = 0
            end

            -- function playdate.graphics.image:draw(x, y, flip, sourceRect)
            -- image:draw(healthBar.x + offsetX, healthBar.y)
            image:draw(healthBar.x + offsetX, healthBar.y)
            offsetX += chickenSprite.width + 20 -- 20 pixel Gap between Chicken 
        end
    end

    return healthBar
end

return HealthBar