--[[
    Services
    Naming convention: Ser_???
]]
-- local Players = game:GetService("Players")

--[[
    Modules
    Naming convention: ???Module
]]
local PH = {}

--[[
    Tables
    Naming convention: Tab_???
]]

--[[
    References & Parameters
]]

--[[
    Functions
]]

--- This function returns the leaderstate folder that belongs to the given player, not the folder does not exist, a new folder will be created.
---@param player Player The player to get the leaderstats folder for
---@return Instance _ The leaderstats folder
function PH:GetPlayerLeaderStats(player)
	local leaderstats = player:FindFirstChild("leaderstats")
	if not leaderstats then
		leaderstats = Instance.new("Folder")
		leaderstats.Name = "leaderstats"
		leaderstats.Parent = player
	end

	return leaderstats
end

--[[
    Event connections
    Conventional order: Remote events -> Bindable events -> Remote functions -> Bindable functions
]]

--[[
    Code execution
]]

return PH