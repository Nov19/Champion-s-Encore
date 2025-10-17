--[[
    Services
    Naming convention: ???
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

--[[
    Modules
    Naming convention: ???
]]

local UIReferences = require(script.Parent.UIReferences)
local CameraLockOn = require(game.ReplicatedStorage.Modules.CameraLockOn)

--[[
    Tables
    Naming convention: ???
]]

--[[
    References & Parameters
]]

-- If true, the camera is finding the closest target.
-- If false, the camera is finding the closest target to the center of the viewport.
local isFindingClosestTarget = false
local isLockingOn = false

local camera = workspace.CurrentCamera

--[[
    Local functions
]]

--[[
    Functions
]]

--- Automatically hide the default jump button for touch devices
local function AutoHideDefaultJumpButton()
	-- The function only works for touch devices
	if not UserInputService.TouchEnabled then
		return
	end

	local jumpButton = Players.LocalPlayer
		:WaitForChild("PlayerGui")
		:WaitForChild("TouchGui")
		:WaitForChild("TouchControlFrame")
		:WaitForChild("JumpButton")
	jumpButton.Visible = false

	jumpButton:GetPropertyChangedSignal("Visible"):Connect(function()
		jumpButton.Visible = false
	end)
end

--- Initialize the controller based on the device type
local function InitializeController()
	AutoHideDefaultJumpButton()

	-- If the device is a touch device, show the controller UI
	if UserInputService.TouchEnabled then
		UIReferences.Guis.ControllerUI.Enabled = true

		-- TODO Show the touch binding hints
	else
		UIReferences.Guis.ControllerUI.Enabled = false

		-- TODO Show the key binding hints for keyboard and mouse devices
	end
end

--[[
    Event connections
    Conventional order: Remote events -> Bindable events -> Remote functions -> Bindable functions
]]

-- TODO: Lock on to the target
UIReferences.ControllerUI.LockOnBtn.Activated:Connect(function()
	if isLockingOn then
		isLockingOn = false
		CameraLockOn:CameraFollow(Players.LocalPlayer.Character, nil, camera)
	else
		isLockingOn = true
		CameraLockOn:CameraFollow(
			Players.LocalPlayer.Character,
			CameraLockOn:GetClosestTarget(isFindingClosestTarget, camera),
			camera
		)
	end
end)

--[[
    Code execution
]]
InitializeController()
