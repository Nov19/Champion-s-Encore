--[[
    Services
    Naming convention: ???
]]

local HttpService = game:GetService("HttpService")

--[[
    Modules
    Naming convention: ???
]]

local SH = {}

--[[
    Tables
    Naming convention: ???
]]

--[[
    References & Parameters
]]

local PROJECT_REF = "rdwfzrnsvykwvkrxjlzs"
local DATABASE_URL = "https://" .. PROJECT_REF .. ".supabase.co/rest/v1/rpc/"
local SUPABASE_API_KEY =
	"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJkd2Z6cm5zdnlrd3ZrcnhqbHpzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjE5NzI2MTgsImV4cCI6MjA3NzU0ODYxOH0.g7gtauSKafzZlrPGeZgR4jAARMU1fRTGN9PzOI9Ocyc"
local Headers = {
	["Content-Type"] = "application/json",
	["apikey"] = SUPABASE_API_KEY,
	["Authorization"] = "Bearer " .. SUPABASE_API_KEY,
	["Prefer"] = "return=representation",
}

-- Base URL for your database API
local BASE_URL = "https://your-database-api.com" -- Update this URL to your actual database API

--[[
    Local functions
]]

--- This function is used to process the request to the Supabase database.
---@param functionName string The name of the function to call.
---@param method string The method to use for the request.
---@param data table The data to send to the function.
---@return table?
local function RequestProccess(functionName, method, data)
	local response
	local requestSuccess, err = pcall(function()
		local httpResponse = HttpService:RequestAsync({
			Url = DATABASE_URL .. functionName,
			Method = method,
			Headers = Headers,
			Body = HttpService:JSONEncode(data),
		})

		response = httpResponse
	end)

	if requestSuccess and response.Success and response.Body then
		return HttpService:JSONDecode(response.Body)
	else
		warn("❌ Request error:", err)
		if response then
			warn("❌ Response Status Code:", response.StatusCode)
			warn("❌ Response Body:", HttpService:JSONDecode(response.Body))
			warn("❌ TraceBack Info:", debug.traceback("Debug level 2", 2))
		end
		return nil
	end
end

--[[
    Functions
]]

SH.Functions = {
	--- This function is used to update the player profile in the Supabase database.
	---@param playerId string The ID of the player.
	---@param uniqueID string The player unique ID that is set when the account is created.
	---@param displayName string The name of the player.
	---@param level number The level of the player.
	---@param exp number The experience of the player.
	---@return table
	UpdatePlayerProfile = function(playerId, uniqueID, displayName, level, exp)
		local result = RequestProccess("playerupdateprofile", "POST", {
			p_player_id = playerId,
			p_player_username = uniqueID,
			p_player_display_name = displayName,
			p_level = level,
			p_exp = exp,
		})
		if result then
			return result
		end
	end,

	--- This function fetch the player's profile
	---@param playerId number The player ID.
	---@param uniqueID string The player unique ID that is set when the account is created.
	---@param displayName string The name that players can change in their settings.
	---@return any
	GetPlayerProfile = function(playerId, uniqueID, displayName)
		local result = RequestProccess(
			"getplayerprofile",
			"POST",
			{ p_player_id = playerId, p_player_username = uniqueID, p_player_display_name = displayName }
		)
		if result then
			return result
		end
	end,

	GetTopPlayersDynamic = function(orderBy, limit)
		local result = RequestProccess("gettopplayersdynamic", "POST", {
			p_order_by = orderBy,
			p_limit = limit,
		})

		if result then
			return result
		end
	end,
}

--[[
    Code execution
]]
return SH
