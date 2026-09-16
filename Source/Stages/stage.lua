import "CoreLibs/graphics"
import "CoreLibs/sprites"

import "Shared/playdateConstants"

local graphics <const> = playdate.graphics
local sound <const> = playdate.sound

Stage = {}

local function makeTiledPlatformImage(tileImage, width, height)
    local platformImage = graphics.image.new(width, height)
    local tileWidth, tileHeight = tileImage:getSize()

    graphics.pushContext(platformImage)
        for y = 0, height - 1, tileHeight do
            for x = 0, width - 1, tileWidth do
                tileImage:draw(x, y)
            end
        end
    graphics.popContext()

    return platformImage
end

function Stage.create()
    local stage = {
        platforms = {},
        platformDefinitions = {
            {
                x = 0,
                y = playdateConstants.floorLevel,
                width = playdateConstants.playdateWidth,
                height = playdateConstants.floorHeight,
                tileSize = 32,
                imagePath = "Images/stoneFloor"
            }
        }
    }

    function stage:createPlatform(definition)
        local sourceImage = graphics.image.new(definition.imagePath)
        assert(sourceImage, "Couldn't load platform image: " .. definition.imagePath)

        local sourceWidth, sourceHeight = sourceImage:getSize()
        local tileImage = sourceImage:scaledImage(
            definition.tileSize / sourceWidth,
            definition.tileSize / sourceHeight
        )
        assert(tileImage, "Couldn't scale platform image: " .. definition.imagePath)

        -- Tile once into a single image instead of keeping one sprite per tile.
        local platformImage = makeTiledPlatformImage(tileImage, definition.width, definition.height)
        local platform = graphics.sprite.new(platformImage)
        platform:setCenter(0, 0)
        platform:moveTo(definition.x, definition.y)
        platform:setCollideRect(0, 0, definition.width, definition.height)
        platform:setTag(playdateConstants.tags.platform)
        platform:setZIndex(100)
        platform.isPlatform = true
        platform:add()

        table.insert(stage.platforms, platform)
        return platform
    end

    function stage:createPlatforms()
        for _, definition in ipairs(stage.platformDefinitions) do
            stage:createPlatform(definition)
        end
    end

    function stage:createBackground()
        local backgroundImage = graphics.image.new("Images/mountain")
        assert(backgroundImage, "Couldn't load mountain background")

        graphics.sprite.setBackgroundDrawingCallback(function()
            backgroundImage:draw(0, 0)
        end)
    end

    function stage:setupAudio()
        stage.soundtrack = sound.fileplayer.new("Sounds/SoundTracks/SoundTrack")

        if stage.soundtrack then
            stage.soundtrack:setLoopRange(0, stage.soundtrack:getLength())
            stage.soundtrack:play(0)
        else
            print("Couldn't load soundtrack")
        end
    end

    function stage:getFloorY()
        return stage.platformDefinitions[1].y
    end

    function stage:setupStage()
        stage:createBackground()
        stage:createPlatforms()
        stage:setupAudio()
    end

    return stage
end

return Stage
