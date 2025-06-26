-- Playdate Imports
import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

-- ThunderDuck Imports
import "../Support/animatedImage"
import "Stages/stage"
import "Player/duck"
import "Enemies/Po/po"

local graphics <const> = playdate.graphics

local duck = Duck.create()
local stage1 = Stage.create()
local po = Po.create()


local function myGameSetUp()
    stage1:setupStage()
end

function playdate.update()
    -- Characters
    duck:updateFrame()
    po:updateFrame()

    graphics.sprite.update()
    playdate.timer.updateTimers()
end

-- MAIN 
playdate.display.setRefreshRate(50)
myGameSetUp()