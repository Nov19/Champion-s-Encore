--[[
    ScoreService.lua
    
    This module manages player score data with a secure API system that ensures proper access control.
    - Client applications can only read score data through designated read-only APIs
    - Server-side scripts can modify score data through official public methods
    - All operations include validation, error handling, and logging to maintain data integrity
]]

--[[
    Services
    Naming convention: PascalCase for service names
]]
local Players = game:GetService("Players")

--[[
    Modules
    Naming convention: camelCase for module references
]]

--[[
    Private Tables
    Naming convention: _camelCase for private variables
]]
-- Stores player score data securely with limited access
local _playerScores = {}

-- Access control flag to identify server context
local _isServerContext = game:GetService("RunService"):IsServer()

--[[
    Constants
    Naming convention: ALL_CAPS for constants
]]
local MAX_LEVEL = 100
local MIN_LEVEL = 1
local MIN_EXP = 0

--[[
    Local functions
    Naming convention: camelCase for function names
]]

--- Logs messages with timestamp and severity
---@param message string Message to log
---@param severity string Log severity: "INFO", "WARNING", "ERROR"
local function _log(message, severity)
	local timestamp = os.time()
	local formattedMessage = string.format("[%s][%s] %s", os.date("%Y-%m-%d %H:%M:%S", timestamp), severity, message)
	print(formattedMessage)

	-- In production, this could be connected to a proper logging service
	if severity == "ERROR" then
		warn(formattedMessage)
	end
end

--- Validates if a player object is valid
---@param player Player The player to validate
---@return boolean isValid Whether the player is valid
---@return string? errorMessage Optional error message if validation fails
local function _validatePlayer(player)
	if not player or typeof(player) ~= "Instance" or not player:IsA("Player") then
		return false, "Invalid player object"
	end
	if not player:IsDescendantOf(game) then
		return false, "Player is not in the game"
	end
	return true
end

--- Validates level value
---@param level number The level to validate
---@return boolean isValid Whether the level is valid
---@return string? errorMessage Optional error message if validation fails
local function _validateLevel(level)
	if typeof(level) ~= "number" then
		return false, "Level must be a number"
	end
	if level < MIN_LEVEL or level > MAX_LEVEL then
		return false, string.format("Level must be between %d and %d", MIN_LEVEL, MAX_LEVEL)
	end
	if not (level == math.floor(level)) then
		return false, "Level must be an integer"
	end
	return true
end

--- Validates experience value
---@param exp number The experience to validate
---@return boolean isValid Whether the experience is valid
---@return string? errorMessage Optional error message if validation fails
local function _validateExp(exp)
	if typeof(exp) ~= "number" then
		return false, "Experience must be a number"
	end
	if exp < MIN_EXP then
		return false, "Experience cannot be negative"
	end
	return true
end

--- Initializes a new player's score data
---@param player Player The player to initialize data for
local function _initializePlayerScore(player)
	if not _playerScores[player.UserId] then
		_playerScores[player.UserId] = {
			level = 1,
			exp = 0,
			lastUpdated = os.time(),
		}
		_log(string.format("Initialized score data for player %s (ID: %d)", player.Name, player.UserId), "INFO")
	end
end

--- Checks if caller is in server context (for modification methods)
---@return boolean isServer Whether the caller is in server context
local function _checkServerContext()
	return _isServerContext
end

--[[
    Public API
    Naming convention: PascalCase for function names
]]
local ScoreService = {}

--- Retrieves a player's current level
---@param player Player The player to get level for
---@return number|nil playerLevel The player's level, or nil if invalid
---@return string|nil errorMessage Optional error message if operation fails
---@access public (read-only, safe for client/server)
function ScoreService.GetLevel(player)
	-- Validate player
	local isValid, errorMsg = _validatePlayer(player)
	if not isValid then
		_log("GetLevel: " .. errorMsg, "WARNING")
		return nil, errorMsg
	end

	-- Initialize if not exists
	_initializePlayerScore(player)

	-- Return read-only value
	local level = _playerScores[player.UserId].level
	_log(string.format("GetLevel: Retrieved level %d for player %s", level, player.Name), "INFO")
	return level
end

--- Retrieves a player's current experience
---@param player Player The player to get experience for
---@return number|nil playerExp The player's experience, or nil if invalid
---@return string|nil errorMessage Optional error message if operation fails
---@access public (read-only, safe for client/server)
function ScoreService.GetExp(player)
	-- Validate player
	local isValid, errorMsg = _validatePlayer(player)
	if not isValid then
		_log("GetExp: " .. errorMsg, "WARNING")
		return nil, errorMsg
	end

	-- Initialize if not exists
	_initializePlayerScore(player)

	-- Return read-only value
	local exp = _playerScores[player.UserId].exp
	_log(string.format("GetExp: Retrieved exp %d for player %s", exp, player.Name), "INFO")
	return exp
end

--- Retrieves a player's complete score data as a read-only table
---@param player Player The player to get score data for
---@return table|nil scoreData Table containing level, exp, and lastUpdated timestamp, or nil if invalid
---@return string|nil errorMessage Optional error message if operation fails
---@access public (read-only, safe for client/server)
function ScoreService.GetScoreData(player)
	-- Validate player
	local isValid, errorMsg = _validatePlayer(player)
	if not isValid then
		_log("GetScoreData: " .. errorMsg, "WARNING")
		return nil, errorMsg
	end

	-- Initialize if not exists
	_initializePlayerScore(player)

	-- Return read-only copy
	local playerData = _playerScores[player.UserId]
	local readOnlyData = {
		level = playerData.level,
		exp = playerData.exp,
		lastUpdated = playerData.lastUpdated,
	}

	_log(string.format("GetScoreData: Retrieved score data for player %s", player.Name), "INFO")
	return readOnlyData
end

--- Sets a player's level (SERVER-SIDE ONLY)
---@param player Player The player to set level for
---@param level number The new level to set
---@return boolean success Whether the operation succeeded
---@return string|nil errorMessage Optional error message if operation fails
---@access server-only (modification method, restricted access)
function ScoreService.SetLevel(player, level)
	-- Check server context
	if not _checkServerContext() then
		_log("SetLevel: Attempted modification from client context", "ERROR")
		return false, "This method can only be called from server scripts"
	end

	-- Validate player
	local isValidPlayer, playerError = _validatePlayer(player)
	if not isValidPlayer then
		_log("SetLevel: " .. playerError, "ERROR")
		return false, playerError
	end

	-- Validate level
	local isValidLevel, levelError = _validateLevel(level)
	if not isValidLevel then
		_log("SetLevel: " .. levelError, "ERROR")
		return false, levelError
	end

	-- Initialize if not exists
	_initializePlayerScore(player)

	-- Update level
	local oldLevel = _playerScores[player.UserId].level
	_playerScores[player.UserId].level = level
	_playerScores[player.UserId].lastUpdated = os.time()

	_log(string.format("SetLevel: Updated player %s level from %d to %d", player.Name, oldLevel, level), "INFO")
	return true
end

--- Sets a player's experience (SERVER-SIDE ONLY)
---@param player Player The player to set experience for
---@param exp number The new experience to set
---@return boolean success Whether the operation succeeded
---@return string|nil errorMessage Optional error message if operation fails
---@access server-only (modification method, restricted access)
function ScoreService.SetExp(player, exp)
	-- Check server context
	if not _checkServerContext() then
		_log("SetExp: Attempted modification from client context", "ERROR")
		return false, "This method can only be called from server scripts"
	end

	-- Validate player
	local isValidPlayer, playerError = _validatePlayer(player)
	if not isValidPlayer then
		_log("SetExp: " .. playerError, "ERROR")
		return false, playerError
	end

	-- Validate exp
	local isValidExp, expError = _validateExp(exp)
	if not isValidExp then
		_log("SetExp: " .. expError, "ERROR")
		return false, expError
	end

	-- Initialize if not exists
	_initializePlayerScore(player)

	-- Update exp
	local oldExp = _playerScores[player.UserId].exp
	_playerScores[player.UserId].exp = exp
	_playerScores[player.UserId].lastUpdated = os.time()

	_log(string.format("SetExp: Updated player %s exp from %d to %d", player.Name, oldExp, exp), "INFO")
	return true
end

--- Adds experience to a player (SERVER-SIDE ONLY)
---@param player Player The player to add experience to
---@param expAmount number The amount of experience to add
---@return boolean success Whether the operation succeeded
---@return number|nil newTotalExp The new total experience, or nil if operation failed
---@return string|nil errorMessage Optional error message if operation fails
---@access server-only (modification method, restricted access)
function ScoreService.AddExp(player, expAmount)
	-- Check server context
	if not _checkServerContext() then
		_log("AddExp: Attempted modification from client context", "ERROR")
		return false, nil, "This method can only be called from server scripts"
	end

	-- Validate player
	local isValidPlayer, playerError = _validatePlayer(player)
	if not isValidPlayer then
		_log("AddExp: " .. playerError, "ERROR")
		return false, nil, playerError
	end

	-- Validate exp amount
	if typeof(expAmount) ~= "number" then
		_log("AddExp: Experience amount must be a number", "ERROR")
		return false, nil, "Experience amount must be a number"
	end

	if expAmount < 0 then
		_log("AddExp: Experience amount cannot be negative", "ERROR")
		return false, nil, "Experience amount cannot be negative"
	end

	-- Initialize if not exists
	_initializePlayerScore(player)

	-- Update exp
	local oldExp = _playerScores[player.UserId].exp
	local newExp = oldExp + expAmount
	_playerScores[player.UserId].exp = newExp
	_playerScores[player.UserId].lastUpdated = os.time()

	_log(string.format("AddExp: Added %d exp to player %s (total: %d)", expAmount, player.Name, newExp), "INFO")
	return true, newExp
end

--- Updates both level and experience for a player (SERVER-SIDE ONLY)
---@param player Player The player to update
---@param level number The new level to set
---@param exp number The new experience to set
---@return boolean success Whether the operation succeeded
---@return string|nil errorMessage Optional error message if operation fails
---@access server-only (modification method, restricted access)
function ScoreService.UpdateScore(player, level, exp)
	-- Check server context
	if not _checkServerContext() then
		_log("UpdateScore: Attempted modification from client context", "ERROR")
		return false, "This method can only be called from server scripts"
	end

	-- Validate player
	local isValidPlayer, playerError = _validatePlayer(player)
	if not isValidPlayer then
		_log("UpdateScore: " .. playerError, "ERROR")
		return false, playerError
	end

	-- Validate level and exp
	local isValidLevel, levelError = _validateLevel(level)
	if not isValidLevel then
		_log("UpdateScore: " .. levelError, "ERROR")
		return false, levelError
	end

	local isValidExp, expError = _validateExp(exp)
	if not isValidExp then
		_log("UpdateScore: " .. expError, "ERROR")
		return false, expError
	end

	-- Initialize if not exists
	_initializePlayerScore(player)

	-- Update score data
	local oldLevel = _playerScores[player.UserId].level
	local oldExp = _playerScores[player.UserId].exp

	_playerScores[player.UserId].level = level
	_playerScores[player.UserId].exp = exp
	_playerScores[player.UserId].lastUpdated = os.time()

	_log(
		string.format(
			"UpdateScore: Updated player %s - Level: %d -> %d, Exp: %d -> %d",
			player.Name,
			oldLevel,
			level,
			oldExp,
			exp
		),
		"INFO"
	)
	return true
end

--- Resets a player's score data to default values (SERVER-SIDE ONLY)
---@param player Player The player to reset score data for
---@return boolean success Whether the operation succeeded
---@return string|nil errorMessage Optional error message if operation fails
---@access server-only (modification method, restricted access)
function ScoreService.ResetScore(player)
	-- Check server context
	if not _checkServerContext() then
		_log("ResetScore: Attempted modification from client context", "ERROR")
		return false, "This method can only be called from server scripts"
	end

	-- Validate player
	local isValidPlayer, playerError = _validatePlayer(player)
	if not isValidPlayer then
		_log("ResetScore: " .. playerError, "ERROR")
		return false, playerError
	end

	-- Store old values for logging
	local oldData = _playerScores[player.UserId] or { level = 1, exp = 0 }

	-- Reset data
	_playerScores[player.UserId] = {
		level = 1,
		exp = 0,
		lastUpdated = os.time(),
	}

	_log(
		string.format(
			"ResetScore: Reset player %s score data from level %d exp %d to defaults",
			player.Name,
			oldData.level,
			oldData.exp
		),
		"INFO"
	)
	return true
end

--- Removes a player's score data (SERVER-SIDE ONLY)
---@param player Player The player to remove score data for
---@return boolean success Whether the operation succeeded
---@return string|nil errorMessage Optional error message if operation fails
---@access server-only (modification method, restricted access)
function ScoreService.RemovePlayerData(player)
	-- Check server context
	if not _checkServerContext() then
		_log("RemovePlayerData: Attempted modification from client context", "ERROR")
		return false, "This method can only be called from server scripts"
	end

	-- Validate player
	local isValidPlayer, playerError = _validatePlayer(player)
	if not isValidPlayer then
		_log("RemovePlayerData: " .. playerError, "ERROR")
		return false, playerError
	end

	-- Remove data
	_playerScores[player.UserId] = nil
	_log(string.format("RemovePlayerData: Removed score data for player %s", player.Name), "INFO")
	return true
end

--[[
    Event connections
    Conventional order: Remote events -> Bindable events -> Remote functions -> Bindable functions
]]

-- Clean up player data when they leave the game
Players.PlayerRemoving:Connect(function(player)
	-- This is a server-side only event, so no context check needed
	local userId = player.UserId
	if _playerScores[userId] then
		_log(string.format("Player left: Removing cached score data for %s", player.Name), "INFO")
		-- We could save data to persistence here if needed
	end
end)

--[[
    Code execution
]]

-- Return the ScoreService table with controlled access
return ScoreService
