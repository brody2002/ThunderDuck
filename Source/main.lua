-- Playdate Imports
import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

-- ThunderDuck Imports
import "../Support/animatedImage"
local Stage = import "Stages/stage"
local Duck = import "Player/duck"

local stage = Stage:create()
local duck = Duck:create()

local graphics <const> = playdate.graphics


local function myGameSetUp()
    duck:add()
    stage:setupStage()
end

function playdate.update()
    duck:update()
    graphics.sprite.update()
    playdate.timer.updateTimers()
end

-- MAIN 
playdate.display.setRefreshRate(50)
myGameSetUp()