local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Communication = require(ReplicatedStorage.Modules.Communication)

local REQUEST_EVENT_NAME = "RequestConfigs"
local PROVIDE_EVENT_NAME = "ProvideConfigs"

local ConfigLoader = {}

-- Internal state (separate caches per environment)
local hasInitialized = false
local serverConfigsCache = nil -- [string] -> table (server-only)
local clientConfigsCache = nil -- [string] -> table (client-only)

-- Utility: safe require for ModuleScripts
local function safeRequire(moduleScript)
	local ok, result = pcall(require, moduleScript)
	if not ok then
		warn("[ConfigLoader] Failed to require module '" .. moduleScript:GetFullName() .. "': " .. tostring(result))
		return nil
	end
	if type(result) ~= "table" then
		warn("[ConfigLoader] Module '" .. moduleScript:GetFullName() .. "' did not return a table; ignoring.")
		return nil
	end
	return result
end

-- Server: load all ModuleScripts under ServerStorage.Configs
local function loadAllServerConfigs()
	if serverConfigsCache ~= nil then
		return serverConfigsCache
	end

	serverConfigsCache = {}
	local configsFolder = ServerStorage:FindFirstChild("Configs")
	if not configsFolder then
		warn("[ConfigLoader] ServerStorage.Configs folder not found. No configs loaded.")
		return serverConfigsCache
	end

	for _, descendant in ipairs(configsFolder:GetDescendants()) do
		if descendant:IsA("ModuleScript") then
			local configTable = safeRequire(descendant)
			if configTable then
				local configName = descendant.Name
				if serverConfigsCache[configName] ~= nil then
					warn(
						"[ConfigLoader] Duplicate config name detected: '"
							.. configName
							.. "'. Overwriting previous entry."
					)
				end
				serverConfigsCache[configName] = configTable
			end
		end
	end

	return serverConfigsCache
end

-- Wire communication endpoints
local function initializeOnce()
	if hasInitialized then
		return
	end
	hasInitialized = true

	if RunService:IsServer() then
		-- Ensure server cache is built eagerly so first client gets immediate response
		loadAllServerConfigs()
		-- RemoteFunction for clients to request configs
		Communication.OnServerInvoke(REQUEST_EVENT_NAME, function(player)
			-- Defensive: reload only if cache missing
			if serverConfigsCache == nil then
				loadAllServerConfigs()
			end
			return serverConfigsCache or {}
		end)
	else
		-- Client: set up optional listener for server push updates (future-proof)
		Communication.OnClientEvent(PROVIDE_EVENT_NAME, function(provided)
			if type(provided) == "table" then
				clientConfigsCache = provided
			end
		end)
	end
end

-- Public API
function ConfigLoader:GetAllConfigs()
	initializeOnce()

	if RunService:IsServer() then
		return loadAllServerConfigs()
	end

	-- Client: fetch once, then cache
	if clientConfigsCache == nil then
		local ok, result = pcall(function()
			return Communication.InvokeServer(REQUEST_EVENT_NAME)
		end)
		if not ok then
			warn("[ConfigLoader] Failed to request configs from server: " .. tostring(result))
			clientConfigsCache = {}
		else
			if type(result) ~= "table" then
				warn("[ConfigLoader] Server returned non-table for configs; defaulting to empty table.")
				clientConfigsCache = {}
			else
				clientConfigsCache = result
			end
		end
	end

	return clientConfigsCache
end

--- Get a config by name
---@param name string
---@return table | nil
function ConfigLoader:GetConfig(name)
	if type(name) ~= "string" or name == "" then
		warn("ConfigLoader:GetConfig() - Name is not a string or is empty")
		return nil
	end
	local all = self:GetAllConfigs()

	if not all then
		warn("ConfigLoader:GetConfig() - All configs are not loaded")
		return nil
	end

	if not all[name] then
		warn("ConfigLoader:GetConfig() - Config with name '" .. name .. "' not found")
		return nil
	end

	return all and all[name] or nil
end

--- Remap configs by value
---@param configs table
---@param value string
---@return nil
function ConfigLoader:RemapConfigs(configs, value)
	if type(configs) ~= "table" or (type(value) ~= "string" and type(value) ~= "number") then
		return nil
	end

	if not configs then
		warn("ConfigLoader:RemapConfigs() - Configs are not loaded")
		return nil
	end

	if not value then
		warn("ConfigLoader:RemapConfigs() - Value is not a string or is empty")
		return nil
	end

	local remappedConfigs = {}
	for _, config in configs do
		if not config[value] then
			warn("ConfigLoader:RemapConfigs() - Config with name '" .. value .. "' not found")
			return nil
		end

		remappedConfigs[config[value]] = config
	end
	return remappedConfigs
end

return ConfigLoader
