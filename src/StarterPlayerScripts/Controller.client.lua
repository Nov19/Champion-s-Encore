--[[
    Services
    Naming convention: ???
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--[[
    Modules
    Naming convention: ???
]]

local UIReferences = require(script.Parent.UIReferences)
local Camera = require(ReplicatedStorage.Modules.Camera)
local Communication = require(ReplicatedStorage.Modules.Communication)

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

local currentCamera = workspace.CurrentCamera

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
	if UserInputService.TouchEnabled then
		-- If the device is a touch device, show the controller UI
		UIReferences.Guis.TouchControllerUI.Enabled = true
		UIReferences.Guis.PCKeyBindingUI.Enabled = false
	else
		-- else, show the key binding UI
		UIReferences.Guis.PCKeyBindingUI.Enabled = true
		UIReferences.Guis.TouchControllerUI.Enabled = false
	end
end

--[[ 
    Event connections
    Conventional order: Remote events -> Bindable events -> Remote functions -> Bindable functions
]]

-- TODO: Lock on to the target
UIReferences.TouchControllerUI.LockOnBtn.Activated:Connect(function()
	if isLockingOn then
		isLockingOn = false
		Camera:CameraFollow(Players.LocalPlayer.Character, nil, currentCamera)
	else
		isLockingOn = true
		Camera:CameraFollow(
			Players.LocalPlayer.Character,
			Camera:GetClosestTarget(isFindingClosestTarget, currentCamera),
			currentCamera
		)
	end
end)

Communication.Event("PlayBtnActivated", function()
	InitializeController()
end)

--[[
    Code execution
]]
AutoHideDefaultJumpButton()
