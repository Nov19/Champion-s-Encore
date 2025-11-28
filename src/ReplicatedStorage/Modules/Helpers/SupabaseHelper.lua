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
	--- This function is used to update player profile(s) in the Supabase database using batch processing.
	---@param playersData table Either a single player data table or an array of player data tables
	--- Each player data table must contain:
	---   - playerId/userId: The player's unique identifier
	---   - uniqueID/username: The player's username
	---   - displayName: The player's display name
	---   - level: The player's level
	---   - exp: The player's experience points
	---@return table|nil Returns the updated player profile data or nil if the update fails
	UpdatePlayerProfile = function(playersData)
		-- 确保输入是表格类型
		assert(type(playersData) == "table", "Players data must be a table")

		-- 准备批量数据数组
		local batchData = {}

		-- 处理单个玩家数据表格或多个玩家数据数组
		if #playersData > 0 then
			-- 多个玩家数据数组
			for _, playerInfo in ipairs(playersData) do
				table.insert(batchData, {
					player_id = playerInfo.playerId or playerInfo.userId,
					player_username = playerInfo.uniqueID or playerInfo.username,
					player_display_name = playerInfo.displayName,
					level = playerInfo.level,
					exp = playerInfo.exp,
				})
			end
		else
			-- 单个玩家数据表格
			table.insert(batchData, {
				player_id = playersData.playerId or playersData.userId,
				player_username = playersData.uniqueID or playersData.username,
				player_display_name = playersData.displayName,
				level = playersData.level,
				exp = playersData.exp,
			})
		end

		-- 调用SQL函数进行批量更新
		local result = RequestProccess("playerupdateprofile", "POST", {
			p_batch_data = batchData,
		})

		return result
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
