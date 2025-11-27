--[[
    Services
    Naming convention: Ser_???
]]
local Ser_TweenService = game:GetService("TweenService")
local Ser_Lighting = game:GetService("Lighting")

--[[
    Modules
    Naming convention: ???Module
]]

local DTC = {}

--[[
    Tables
    Naming convention: Tab_???
]]
local Tab_LightingPresets = {
	Day = {
		Brightness = 3,
		Ambient = Color3.fromRGB(255, 244, 214),
		OutdoorAmbient = Color3.fromRGB(255, 255, 255),
		ClockTime = 14, -- 2:00 PM
	},

	Night = {
		Brightness = 1,
		Ambient = Color3.fromRGB(70, 90, 150),
		OutdoorAmbient = Color3.fromRGB(80, 90, 140),
		ClockTime = 0, -- Midnight
	},
}

--[[
    References & Parameters
]]
local TRANSITION_DURATION = 100 -- seconds
local HOLD_DURATION = 5 -- seconds to hold before switching back
local TWEEN_STYLE = Enum.EasingStyle.Sine
local TWEEN_DIRECTION = Enum.EasingDirection.InOut

--[[
    Local functions
]]

--- Tween the lighting to a given preset (day/night)
---@param target table The target lighting properties to tween to
local function TweenLighting(target)
	local tweenInfo = TweenInfo.new(TRANSITION_DURATION, TWEEN_STYLE, TWEEN_DIRECTION)

	local tween = Ser_TweenService:Create(Ser_Lighting, tweenInfo, target)
	tween:Play()
	return tween
end

--[[
    Functions
]]

--- Run a continuous day/night cycle
local function RunDayNightCycle()
	while true do
		-- Day → Night
		local nightTween = TweenLighting(Tab_LightingPresets.Night)
		nightTween.Completed:Wait()
		task.wait(HOLD_DURATION)

		-- Night → Day
		local dayTween = TweenLighting(Tab_LightingPresets.Day)
		dayTween.Completed:Wait()
		task.wait(HOLD_DURATION)
	end
end

function DTC:RunDayNightCycle()
	RunDayNightCycle()
end

--[[
    Event connections
    Conventional order: Remote events -> Bindable events -> Remote functions -> Bindable functions
]]
-- (none required for this script)

--[[
    Code execution
]]

return DTC
