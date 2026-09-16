import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

import "../Support/animatedImage"
import "Shared/gravity"
import "Stages/stage"
import "Player/duck"
import "Enemies/Po/po"
import "Enemies/Frog/frog"
import "UI/healthbar"

local graphics <const> = playdate.graphics

local stage1
local duck
local po
local frog
local healthBar

local function myGameSetUp()
    stage1 = Stage.create()
    stage1:setupStage()

    local floorY = stage1:getFloorY()
    duck = Duck(80, floorY)
    po = Po(210, floorY)
    frog = Frog(340, floorY)
    healthBar = HealthBar.create()

    healthBar.drawHealth()
end

function playdate.update()
    local deltaTime = Physics.fixedDeltaTime

    duck:updateFrame(deltaTime)
    po:updateFrame(deltaTime)
    frog:updateFrame(deltaTime)

    graphics.sprite.update()
    playdate.timer.updateTimers()
end

playdate.display.setRefreshRate(50)
myGameSetUp()
