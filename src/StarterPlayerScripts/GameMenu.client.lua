--[[
    Services
    Naming convention: ???
]]
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

--[[
    Modules
    Naming convention: ???
]]

local UIReferences = require(script.Parent.UIReferences)
local Communication = require(ReplicatedStorage.Modules.Communication)

--[[
    Tables
    Naming convention: ???
]]

--[[
    References & Parameters
]]

local DEFAULT_BLUR_SIZE = 36
local DEFAULT_BLUR_TWEEN_INFO = TweenInfo.new(1.3, Enum.EasingStyle.Linear)

local currentCamera = workspace.CurrentCamera
local startMenuCameraCFrame = workspace:WaitForChild("StartMenuCameraPart").CFrame

--[[
    Local functions
]]

--[[
    Functions
]]

local function OnGameLoaded()
	local blur = Lighting:FindFirstChild("Blur")

	Players.LocalPlayer.Character.Parent = nil -- Hide the player's character until the game starts

	-- Set the camera to Scriptable
	currentCamera.CameraType = Enum.CameraType.Scriptable
	currentCamera.CFrame = startMenuCameraCFrame

	blur.Size = DEFAULT_BLUR_SIZE
	blur.Enabled = true
end

--[[
    Event connections
    Conventional order: Remote events -> Bindable events -> Remote functions -> Bindable functions
]]

UIReferences.StartMenuUI.PlayBtn.Activated:Connect(function()
	UIReferences.Guis.StartMenuUI.Enabled = false
	Players.LocalPlayer.Character.Parent = workspace -- Show the player's character
	currentCamera.CameraType = Enum.CameraType.Custom

	task.spawn(function()
		local blur = Lighting:FindFirstChild("Blur")
		local tween = TweenService:Create(blur, DEFAULT_BLUR_TWEEN_INFO, {
			Size = 0,
		})
		tween:Play()
		tween.Completed:Wait()
		blur.Enabled = false
		blur.Size = DEFAULT_BLUR_SIZE
	end)

	Communication.Fire("PlayBtnActivated")
end)

--[[
    Code execution
]]
OnGameLoaded()
