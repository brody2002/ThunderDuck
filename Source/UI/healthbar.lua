-- Playdate Imports
import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "../../Support/animatedImage"

local graphics <const> = playdate.graphics

Chicken = {}

Chicken.create = function ()
    local chicken = {}
    ---@class playdate.graphics.sprite
    chicken.sprite = graphics.sprite.new()
    chicken.ratio = 1
    
    chicken.full = graphics.image.new("UI/Assets/ChickenFull")
    chicken.half = graphics.image.new("UI/Assets/ChickenHalf")
    chicken.currentImage = chicken.full
    chicken.width, chicken.height = chicken.currentImage:scaledImage(chicken.ratio, chicken.ratio):getSize()
    print("Width: "..chicken.width.."Height: "..chicken.height)

    
    return chicken
end

HealthBar = {}

HealthBar.create = function ()
    local healthbar = {}
    local chickenSprite = Chicken.create()
    healthbar.hp = 6 -- One Whole Chicken per 2 hp points

    -- Methods: 
    healthbar.drawHealth = function ()
        -- if health bar is 1, draw half chicken from top left corner
        -- if health bar is 3, draw 1 chicken and 1 half chicken starting from left to right
        -- when the value changes this needs to be redrawn. Try to only update this when needed 
    end
end

