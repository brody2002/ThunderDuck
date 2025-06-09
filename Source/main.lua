import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "../Support/animatedimage"

local graphics <const> = playdate.graphics

---@class playdate.graphics.sprite
local player = nil
local playerImage = nil

-- Screen Dimensions
local playdateHeight = 240
local playdateWidth = 400

-- Sprite Directions
local left, right = 1, 2
local direction =  left



local function createPlayer()
    player = graphics.sprite.new()
    player.direction = direction
    player.idle = AnimatedImage.new("Images/Duck/Gifs/idle", {delay = 200, loop = true, first = 1, last = 2})
    player.moving = AnimatedImage.new("Images/Duck/Gifs/Walking", {delay = 200, loop = true, first = 1, last = 2})
    
    if not player.idle or not player.moving then
        print("⚠️ Failed to create animations!")
        return
    end
    
    player.currentAnimation = player.idle
    
    -- Verify we can get an image
    local initialImage = player.currentAnimation:getImage()
    
    player:setImage(initialImage)
    
    local floorLevel = playdateHeight - 32
    player:moveTo(200, floorLevel - 45)
    player:add()
end


local function createFloor()
    local tileImage = graphics.image.new("Images/stoneFloor") -- 1024x1024
    assert(tileImage, "⚠️ Couldn't load stoneFloor image")

    -- Scale down to 32x32
    local scaledTile = tileImage:scaledImage(32 / 1024, 32 / 1024)
    print(1024/32)
    assert(scaledTile, "⚠️ Failed to scale floor image")

    local tileWidth, tileHeight = scaledTile:getSize()
    local floorY = playdateHeight - tileHeight

    for x = 0, playdateWidth, tileWidth do
        local tileSprite = graphics.sprite.new(scaledTile)
        tileSprite:moveTo(x + tileWidth / 2, floorY + tileHeight / 2)
        tileSprite:add()
    end

end

local function createBackground() 
    local backgroundImage = graphics.image.new("Images/mountain")
    assert(backgroundImage)

    graphics.sprite.setBackgroundDrawingCallback(
        function(x, y, width, height)
            backgroundImage:draw( 0, 0 )
        end
    )
end

local function myGameSetUp()

    local ceil <const> = math.ceil

    createPlayer() -- Create Player

    createFloor() -- Create Floor

    createBackground() -- Create Background
end

function playdate.update()
    local movement = 2
    local didMove = false
    local function handleMovement()
        if playdate.buttonIsPressed(playdate.kButtonLeft) then
            player.currentAnimation = player.moving
            player:moveBy(-movement, 0)
            direction = left
            didMove = true
        elseif playdate.buttonIsPressed(playdate.kButtonRight) then
            player.currentAnimation = player.moving
            player:moveBy(movement, 0)
            direction = right
            didMove = true
        end
        if not didMove then
            player.currentAnimation = player.idle
        end
    end

    -- Movement Function
    handleMovement()
    
    -- Update animation and set sprite image
     -- Draw current animation frame at player position with flip
    local x, y = player:getPosition()
    local flip = direction == left and playdate.graphics.kImageFlippedX or playdate.graphics.kImageUnflipped

    player.currentAnimation:drawCentered(x,y,flip)
    player:setImage(player.currentAnimation:getImage(), direction)
    
    graphics.sprite.update()
    playdate.timer.updateTimers()
end


-- MAIN 
playdate.display.setRefreshRate(50)
myGameSetUp()
