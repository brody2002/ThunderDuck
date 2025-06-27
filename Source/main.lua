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
import "Enemies/Frog/frog"
import "UI/healthbar"

local graphics <const> = playdate.graphics

-- Player
local duck = Duck.create()

-- Enemies
local po = Po.create()
local frog = Frog.create()

-- Stage
local stage1 = Stage.create()
local frog = Frog.create()

-- UI
local healthBar = HealthBar.create()

local function myGameSetUp()
    stage1:setupStage()
    frog:initializeMovement()
    healthBar.drawHealth()
end

function playdate.update()
    -- Characters
    duck:updateFrame()
    po:updateFrame()
    frog:updateFrame()

    if playdate.buttonJustPressed("B") then
        healthBar.damageReceived()
    end

    -- UI
    graphics.sprite.update()
    playdate.timer.updateTimers()
end

-- MAIN 
playdate.display.setRefreshRate(50)
myGameSetUp()