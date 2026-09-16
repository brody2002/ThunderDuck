local screenHeight <const> = 240
local screenWidth <const> = 400
local floorHeight <const> = 32

playdateConstants = {
    playdateHeight = screenHeight,
    playdateWidth = screenWidth,
    floorHeight = floorHeight,
    floorLevel = screenHeight - floorHeight,
    tags = {
        platform = 1,
        player = 2,
        enemy = 3
    }
}

return playdateConstants
