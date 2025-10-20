--[[
    Services
    Naming convention: ???
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--[[
    Modules
    Naming convention: ???
]]

local Communication = require(ReplicatedStorage.Modules.Communication)
local Animations = require(ReplicatedStorage.Assets.Animations)

--[[
    Tables
    Naming convention: ???
]]

local Loaded_Tracks = {}

--[[
    References & Parameters
]]

local player = Players.LocalPlayer
local character = player.Character
local humanoid = character:WaitForChild("Humanoid")
local animator = humanoid:WaitForChild("Animator")

--[[
    Local functions
]]

--- Play the animation on the target's character
---@param animationId number The animation ID for the target to play
local function PlayAnimation(animationId: number)
	print("Animation played!")

	local track = Loaded_Tracks[animationId]
	if not track then
		local anim = Instance.new("Animation")
		anim.AnimationId = "rbxassetid://" .. animationId
		track = animator:LoadAnimation(anim)
		track.Priority = Enum.AnimationPriority.Action

		Loaded_Tracks[animationId] = track
	end

	track:Play()
end

--[[
    Functions
]]

--[[
    Event connections
    Conventional order: Remote events -> Bindable events -> Remote functions -> Bindable functions
]]

-- - This event plays sends the animation info to the server, and the server will distribute the info to clients.
Communication.Event("GlobalAnimation", function(animationName)
	local animationId = Animations:GetAnimationIdByName(animationName)

	PlayAnimation(animationId)

	Communication.FireServer("SyncAnimation", animationId)
end)

-- - This event player the animation locally, without sending any infomation to the server.
Communication.Event("LocalAnimation", function(animationName)
	local animationId = Animations:GetAnimationIdByName(animationName)

	-- TODO Play local animations
end)

Communication.OnClientEvent("SyncAnimation", function(animationId)
	PlayAnimation(animationId)
end)

--[[
    Code execution
]]
