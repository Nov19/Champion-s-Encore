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
local PlayerConfigs = require(ReplicatedStorage.Modules.PlayerConfigs)

--[[
	Tables
	Naming convention: ???
]]

local Behaviors = require(ReplicatedStorage.Assets.Behaviors)

--[[
	References & Parameters
]]

local configs = PlayerConfigs:GetConfigFor(Players.LocalPlayer)

--[[
	Local functions
]]

--[[
	Functions
]]

--[[
	Event connections
	Conventional order: Remote events -> Bindable events -> Remote functions -> Bindable functions
]]

Communication.Event("Attack", function()
	local playerAtkAnim = Behaviors[configs.Animations.Attack]
	if not playerAtkAnim then
		warn("Communication.Event() Attack - The attack animation saved in player's config is not found!")
	end

	playerAtkAnim:Execute(Players.LocalPlayer.Character)
end)

--[[
	Code execution
]]
for _, behavior in Behaviors do
	behavior:InitializeHitbox(Players.LocalPlayer.Character)
end
