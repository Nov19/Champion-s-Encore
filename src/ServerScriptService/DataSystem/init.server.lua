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

local ObjectHelper = require(ReplicatedStorage.Modules.Helpers.ObjectHelper)

local ProfileService = require(script.ProfileService)
local RankService = require(script.RankService)

--[[
    Tables
    Naming convention: ???
]]

--[[
    References & Parameters
]]

local SHUT_DOWN_DELAY = 5
local RANK_UPDATE_INTERVAL = 30
local SYNC_DATABASE_INTERVAL = 60

local rankEntry = ReplicatedStorage.Prefabs.UIComponents.Rank:WaitForChild("Prefab_RankEntry")
local levelRankSF = ObjectHelper.WaitForPath(workspace, "Boards.ExpRank.Board.SurfaceGui.MainFrame.ScrollingFrame")

--[[
    Local functions
]]

--- This function decodes the list of info retrieved from the remote database
---@param infoList table The list of info that contains player's iunfo
local function LevelRankDecode(infoList: table)
	-- First check if infoList is nil
	if infoList == nil then
		warn("DataSystem - Received nil data from RankService!")
		return
	end

	if #infoList == 0 then
		warn("DataSystem - Invalid format!") -- If the infoList is empty or not indexed by numbers, it is formated incorrectly.
	end

	-- Clear the current entries on the board
	for _, entry in levelRankSF:GetChildren() do
		if entry:IsA("Frame") then
			entry:Destroy()
		end
	end

	for rank, playerInfo in infoList do
		-- The string to display on the rank board
		local playerId = playerInfo.player_id
		local playerDisplayName = playerInfo.player_display_name
		local playerUsername = playerInfo.player_username
		local level = playerInfo.level
		local exp = playerInfo.exp

		local infoString = playerDisplayName .. "(@" .. playerUsername .. ") Lv." .. level .. " Exp." .. exp
		local icon = ProfileService.GetPlayerIcon(playerId)

		local entry = rankEntry:Clone()
		entry.PlayerIcon.Image = icon
		entry.PlayerInfo.Text = infoString
		entry.LayoutOrder = rank
		entry.Parent = levelRankSF

		if rank == 1 then
			entry.PlayerIcon.UIStroke.Color = Color3.fromRGB(255, 230, 0)
			entry.PlayerInfo.UIStroke.Color = Color3.fromRGB(255, 230, 0)
		elseif rank == 2 then
			entry.PlayerIcon.UIStroke.Color = Color3.fromRGB(161, 161, 159)
			entry.PlayerInfo.UIStroke.Color = Color3.fromRGB(161, 161, 159)
		elseif rank == 3 then
			entry.PlayerIcon.UIStroke.Color = Color3.fromRGB(226, 115, 30)
			entry.PlayerInfo.UIStroke.Color = Color3.fromRGB(226, 115, 30)
		end
	end
end

--[[
    Functions
]]

Players.PlayerAdded:Connect(function(player)
	local profile = ProfileService.GetPlayerProfile(player)

	-- Add the corresponding entries to leaderstats
	ProfileService.AddEntryToLeaderStats(player, "Exp.", profile.exp)
	ProfileService.AddEntryToLeaderStats(player, "Lv.", profile.level)
end)

Players.PlayerRemoving:Connect(function(player)
	ProfileService.UpdatePlayerProfile(player)
end)

--[[
    Event connections
    Conventional order: Remote events -> Bindable events -> Remote functions -> Bindable functions
]]

game:BindToClose(function()
	-- TODO Make sure all the players are saved.

	task.wait(SHUT_DOWN_DELAY)
end)

--[[
    Code execution
]]

-- The loop to update the board of the rank
task.spawn(function()
	while true do
		local topPlayers = RankService.GetTopExpPlayers()
		LevelRankDecode(topPlayers)

		task.wait(RANK_UPDATE_INTERVAL)
	end
end)

-- The loop to periodically update the remote database
task.spawn(function()
	while true do
		local onlinePlayer = Players:GetPlayers()

		-- Send all the players' info at once

		task.wait(SYNC_DATABASE_INTERVAL)
	end
end)
