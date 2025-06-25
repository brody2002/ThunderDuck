-- Playdate Imports
import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

-- ThunderDuck Imports
import "../Support/animatedImage"
import "Stages/stage"
import "Player/duck"
import "Enemies/Frog/frog"

local graphics <const> = playdate.graphics

local duck = Duck.create()
local stage1 = Stage.create()
local frog = Frog.create()


local function myGameSetUp()
    stage1:setupStage()
    frog:initializeMovement()
end

function playdate.update()
    duck:updateFrame()
    frog:updateFrame()
    graphics.sprite.update()
    playdate.timer.updateTimers()
end

-- MAIN 
playdate.display.setRefreshRate(50)
myGameSetUp()