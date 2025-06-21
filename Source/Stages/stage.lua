import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "../Support/animatedimage"

local graphics <const> = playdate.graphics
local sound <const> = playdate.sound

-- Objects
import "Shared/playdateConstants"


Stage = {}

Stage.create = function()
    local self = {}
    function self:setupAudio()
        -- Create a fileplayer for your soundtrack
        local soundtrack = sound.fileplayer.new("Sounds/SoundTracks/SoundTrack")  -- Assumes your file is in Sounds/soundtrack.wav
        if soundtrack then
            -- Set to loop when it reaches the end
            soundtrack:setLoopRange(0, soundtrack:getLength())
            soundtrack:play(0)  -- Play immediately from position 0
        else
            print("⚠️ Couldn't load soundtrack")
        end
    end

    function self:createFloor()
        local tileImage = graphics.image.new("Images/stoneFloor") -- 1024x1024
        assert(tileImage, "⚠️ Couldn't load stoneFloor image")

        -- Scale down to 32x32
        local scaledTile = tileImage:scaledImage(32 / 1024, 32 / 1024)
        assert(scaledTile, "⚠️ Failed to scale floor image")

        local tileWidth, tileHeight = scaledTile:getSize()
        local floorY = playdateConstants.playdateHeight - tileHeight

        for x = 0, playdateConstants.playdateWidth, tileWidth do
            local tileSprite = graphics.sprite.new(scaledTile)
            tileSprite:moveTo(x + tileWidth / 2, floorY + tileHeight / 2)
            tileSprite:add()
        end

    end

    function self:createBackground() 
        local backgroundImage = graphics.image.new("Images/mountain")
        assert(backgroundImage)

        graphics.sprite.setBackgroundDrawingCallback(
            function(x, y, width, height)
                backgroundImage:draw( 0, 0 )
            end
        )
    end

    function self:setupStage()
        self:createFloor()
        self:createBackground()
        self:setupAudio()
    end

    return self
end

return Stage