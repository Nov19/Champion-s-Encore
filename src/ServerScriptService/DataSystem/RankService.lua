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

local RankService = {}

--[[
    Tables
    Naming convention: ???
]]

local PlayerRanks = {} -- A table to cache the player profiles.
local RankCache = {} -- A table to cache rank information by type
local CacheTimestamps = {} -- A table to store cache timestamps

--[[
    References & Parameters
]]

local CACHE_EXPIRATION_TIME = 120 -- 120 seconds (2 minutes)

--[[
    Local functions
]]

--- Check if the cache is valid and clean up expired data
---@param cacheKey string The key to identify the cache
---@return boolean Whether the cache is valid
local function isCacheValid(cacheKey)
	-- Validate cacheKey parameter
	if type(cacheKey) ~= "string" or cacheKey == "" then
		warn("[RankService] Invalid cacheKey in isCacheValid")
		return false
	end

	if not CacheTimestamps[cacheKey] then
		return false
	end

	local currentTime = os.time()
	local cacheTime = CacheTimestamps[cacheKey]

	-- Validate cacheTime is a number
	if type(cacheTime) ~= "number" then
		warn("[RankService] Invalid cache timestamp in isCacheValid")
		-- Clean up invalid entry
		RankCache[cacheKey] = nil
		CacheTimestamps[cacheKey] = nil
		return false
	end

	-- If cache is expired, clean up the old data
	if (currentTime - cacheTime) >= CACHE_EXPIRATION_TIME then
		-- Clean up both the cache data and timestamp
		RankCache[cacheKey] = nil
		CacheTimestamps[cacheKey] = nil
		return false
	end

	return true
end

--- Update the cache with new data
---@param cacheKey string The key to identify the cache
---@param data any The data to store in the cache
local function updateCache(cacheKey, data)
	-- Validate parameters
	if type(cacheKey) ~= "string" or cacheKey == "" then
		warn("[RankService] Invalid cacheKey in updateCache")
		return
	end

	if data == nil then
		warn("[RankService] Attempting to cache nil data in updateCache")
		return
	end

	RankCache[cacheKey] = data
	CacheTimestamps[cacheKey] = os.time()
end

--- Get a cache key based on rank type and limit
---@param rankType string The type of rank (e.g., "exp")
---@param limit number The number of players to retrieve
---@return string The cache key
local function getCacheKey(rankType, limit)
	-- Validate rankType parameter
	if type(rankType) ~= "string" or rankType == "" then
		warn("[RankService] Invalid rankType in getCacheKey")
		return "unknown_50" -- Fallback to a safe default
	end

	return string.format("%s_%d", rankType, limit or 50)
end

--[[
    Functions
]]

--- Get the top players ordered by exp
---@param limit number The number of players you want to retrieve. By default, it is 50.
function RankService.GetTopExpPlayers(limit)
	-- Validate limit parameter
	if limit and type(limit) ~= "number" then
		warn("[RankService] Invalid limit parameter type in GetTopExpPlayers. Must be a number.")
		return nil
	end

	if limit and (limit < 1 or limit > 1000) then
		warn("[RankService] Limit value out of reasonable range (1-1000) in GetTopExpPlayers")
		return nil
	end

	local cacheKey = getCacheKey("exp", limit)

	-- Check if cache is valid
	if isCacheValid(cacheKey) and RankCache[cacheKey] then
		return RankCache[cacheKey]
	end

	-- If cache is invalid or doesn't exist, fetch from Supabase with error handling
	local success, data = pcall(function()
		return SupabaseHelper.Functions.GetTopPlayersDynamic("exp", limit or 50)
	end)

	if not success then
		warn("[RankService] Error fetching top players from Supabase: " .. tostring(data))
		return nil
	end

	-- Validate returned data
	if not data then
		warn("[RankService] No data returned from Supabase in GetTopExpPlayers")
		return nil
	end

	if type(data) ~= "table" then
		warn("[RankService] Invalid data type returned from Supabase in GetTopExpPlayers")
		return nil
	end

	-- Update cache with new data
	updateCache(cacheKey, data)

	return data
end

--- Clear a specific cache entry by rank type and limit
---@param rankType string The type of rank to clear (e.g., "exp")
---@param limit number Optional: The specific limit to clear. If not provided, clears all caches for this rank type.
function RankService.ClearCache(rankType, limit)
	-- Validate rankType parameter
	if not rankType then
		warn("[RankService] Missing rankType parameter in ClearCache")
		return "Invalid parameters. Please provide at least a rankType."
	end

	if type(rankType) ~= "string" then
		warn("[RankService] Invalid rankType parameter in ClearCache. Must be a string.")
		return "Invalid parameters. rankType must be a string."
	end

	-- Validate limit parameter if provided
	if limit and type(limit) ~= "number" then
		warn("[RankService] Invalid limit parameter in ClearCache. Must be a number.")
		return "Invalid parameters. limit must be a number."
	end

	if limit then
		-- Clear a specific cache entry
		local cacheKey = getCacheKey(rankType, limit)
		RankCache[cacheKey] = nil
		CacheTimestamps[cacheKey] = nil
		return string.format("Cache for %s (limit: %d) cleared.", rankType, limit)
	else
		-- Clear all caches for a specific rank type
		local clearedCount = 0
		for cacheKey, _ in pairs(RankCache) do
			if string.find(cacheKey, "^" .. rankType .. "_") then
				RankCache[cacheKey] = nil
				CacheTimestamps[cacheKey] = nil
				clearedCount = clearedCount + 1
			end
		end
		return string.format("Cleared %d cache entries for %s.", clearedCount, rankType)
	end
end

--- Clear all cache entries
---@return string Status message with number of cleared entries
function RankService.ClearAllCache()
	-- Use pcall to handle any potential errors during cache clearing
	local success, result = pcall(function()
		local clearedCount = 0
		for cacheKey, _ in pairs(RankCache) do
			RankCache[cacheKey] = nil
			CacheTimestamps[cacheKey] = nil
			clearedCount = clearedCount + 1
		end
		return clearedCount
	end)

	if not success then
		warn("[RankService] Error clearing all cache entries: " .. tostring(result))
		return "Error occurred while clearing cache."
	end

	return string.format("Cleared all %d cache entries.", result)
end

--[[
    Event connections
    Conventional order: Remote events -> Bindable events -> Remote functions -> Bindable functions
]]

--[[
    Code execution
]]
return RankService
