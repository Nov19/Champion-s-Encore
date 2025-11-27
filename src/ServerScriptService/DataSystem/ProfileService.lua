--[[
    Services
    Naming convention: ???
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

--[[
    Modules
    Naming convention: ???
]]

local SupabaseHelper = require(ReplicatedStorage.Modules.Helpers.SupabaseHelper)
local PlayersHelper = require(ReplicatedStorage.Modules.Helpers.PlayersHelper)

local ProfileService = {}

--[[
    Tables
    Naming convention: ???
]]

local PlayerProfiles = {} -- A table to cache the player profiles.
local PlayerIcons = {} -- -- A table to cache the player's icons.

--[[
    References & Parameters
]]

local PROFILE_CACHE_EXPIRATION_TIME = 30 -- 1/2 min
local ICON_CACHE_EXPIRATION_TIME = 300 -- 5 mins

--[[
    Local functions
]]

--[[
    Functions
]]

--- This function is used to update the player profile in the Supabase database.
---@param player Player The player
---@param level number The level of the player.
---@param exp number The experience of the player.
---@return table
function ProfileService.UpdatePlayerProfile(player, level, exp)
	SupabaseHelper.Functions.UpdatePlayerProfile(player.UserId, player.Name, player.DisplayName, level, exp)
end

--- This function is used to get the player profile from the Supabase database.
---@param player Player The player to get the profile for.
---@return table
function ProfileService.GetPlayerProfile(player)
	if PlayerProfiles[player.UserId] then
		if PlayerProfiles[player.UserId].LastUpdated + PROFILE_CACHE_EXPIRATION_TIME < os.time() then
			PlayerProfiles[player.UserId] = nil
		else
			return PlayerProfiles[player.UserId]
		end
	end

	local profile = SupabaseHelper.Functions.GetPlayerProfile(player.UserId, player.Name, player.DisplayName)
	if profile then
		PlayerProfiles[player.UserId] = profile
		PlayerProfiles[player.UserId].LastUpdated = os.time()
		return PlayerProfiles[player.UserId]
	else
		warn("ProfileService.GetPlayerProfile - Failed to retrieve profile for player " .. player.UserId)
		return nil
	end
end

--- This function returns the player icon for the given player or player id
--- @param player Player | number
function ProfileService.GetPlayerIcon(player: any)
	local thumbnail = nil

	local thumbType = Enum.ThumbnailType.HeadShot
	local thumbSize = Enum.ThumbnailSize.Size100x100
	local userId = nil

	if tonumber(player) then
		userId = tonumber(player)
	elseif tonumber(player.UserId) then
		userId = tonumber(player.UserId)
	else
		warn("ProfileService.GetPlayerIcon - Invalid input!")
		return
	end

	local currentTime = os.time()

	-- Use cached thumbnail if it exists and hasn't expired
	if
		PlayerIcons[userId]
		and PlayerIcons[userId].CreateAt
		and (currentTime - PlayerIcons[userId].CreateAt) < ICON_CACHE_EXPIRATION_TIME
		and PlayerIcons[userId].Thumbnail
	then
		thumbnail = PlayerIcons[userId].Thumbnail
	else
		thumbnail = PlayersHelper:GetUserThumbnailFast(userId, thumbType, thumbSize)
		-- Initialize cache entry before writing fields
		PlayerIcons[userId] = PlayerIcons[userId] or {}
		PlayerIcons[userId].CreateAt = currentTime
		PlayerIcons[userId].Thumbnail = thumbnail
	end

	-- This function returns the thumbnail with no delay
	return thumbnail
end

--- Adds or updates an entry in the player's leaderstats folder.
---@param player Player The player whose leaderstats you want to modify.
---@param entryName string The name of the leaderstats entry (e.g., "Level", "Exp").
---@param value number|string The value to set for the leaderstats entry.
function ProfileService.AddEntryToLeaderStats(player, entryName, value)
	if typeof(value) ~= "number" and typeof(value) ~= "string" then
		warn(`ProfileService.AddEntryToLeaderStats - Expected number or string, got {typeof(value)}`)
	end

	local leaderstats = player:FindFirstChild("leaderstats")

	if not leaderstats then
		leaderstats = Instance.new("Folder")
		leaderstats.Name = "leaderstats"
		leaderstats.Parent = player
	end

	if typeof(value) == "number" then
		local entry = Instance.new("NumberValue")
		entry.Name = entryName
		entry.Value = value
		entry.Parent = leaderstats
	end
end

--[[
    Event connections
    Conventional order: Remote events -> Bindable events -> Remote functions -> Bindable functions
]]

--[[
    Code execution
]]
return ProfileService
