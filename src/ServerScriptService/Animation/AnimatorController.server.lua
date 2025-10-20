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

--[[
    Tables
    Naming convention: ???
]]

--[[
    References & Parameters
]]

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

Communication.OnServerEvent("SyncAnimation", function(player, animationId)
	local character = player.Character
	if not character then
		return
	end

	-- Tell other players only
	for _, otherPlayer in ipairs(game.Players:GetPlayers()) do
		if otherPlayer ~= player then
			Communication.FireClient("SyncAnimation", otherPlayer, animationId)
		end
	end
end)

--[[
    Code execution
]]
