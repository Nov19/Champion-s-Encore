--[[
    Services
    Naming convention: ???
]]

local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--[[
    Modules
    Naming convention: ???
]]

local LootBox = require(script.Parent.LootBox)
local Communication = require(ReplicatedStorage.Modules.Communication)

local LootManager = {}
LootManager.__index = LootManager

--[[
    Tables
    Naming convention: ???
]]

--[[
    References & Parameters
]]

LootManager.Spawn_Points = {}
LootManager.Spawn_Timers = {}
LootManager.Loot_Types = {
	Loot = "Loot",
	Shield = "Shield",
	Booster = "Booster",
	Regen = "Regen",
}
LootManager.ActiveLootBoxes = {}

--[[
    Local functions
]]

--- Validate if a spawn point is valid
---@return boolean
local function ValidateSpawnPoints()
	if #LootManager.Spawn_Points < 0 then
		warn("No spawn points found")
		return false
	end

	for _, point in ipairs(LootManager.Spawn_Points) do
		-- Check if the spawn point is valid
		if not point or not point:IsA("BasePart") then
			warn("Invalid spawn point:", point)
			return false
		end
	end

	return true
end

--- Get all the spawn points
local function GetSpawnPoints()
	-- Get all the spawn points
	local spawnPoints = CollectionService:GetTagged("LootManagerPoint")
	for _, spawnPoint in ipairs(spawnPoints) do
		table.insert(LootManager.Spawn_Points, spawnPoint)
	end
end

--[[
    Functions
]]

--- Create a new LootManager object
---@class LootManager
---@return LootManager
function LootManager.new()
	local self = setmetatable({}, LootManager)

	return self
end

--- Spawn a new LootBox at the specified spawn point
---@param spawnPoint BasePart The spawn point to spawn the LootBox at
---@return LootBox
function LootManager:SpawnLootBox(spawnPoint: BasePart)
	local lootBox = LootBox.new(spawnPoint)

	self.ActiveLootBoxes[lootBox.BoxId] = lootBox

	return lootBox
end

--- Remove a lootbox from the ActiveLootBoxes table
---@param lootBox table The lootbox to remove
function LootManager:RemoveLootBox(lootBox: table)
	for i, activeBox in ipairs(self.ActiveLootBoxes) do
		if activeBox == lootBox then
			table.remove(self.ActiveLootBoxes, i)
			break
		end
	end
end

--- Get all active lootboxes
---@return table
function LootManager:GetActiveLootBoxes()
	return self.ActiveLootBoxes
end

--[[
    Event connections
    Conventional order: Remote events -> Bindable events -> Remote functions -> Bindable functions
]]

--[[
    Code execution
]]

-- Get all the spawn points
GetSpawnPoints()

-- Validate all the spawn points
ValidateSpawnPoints()

-- Freeze the tables
table.freeze(LootManager.Spawn_Points)
table.freeze(LootManager.Spawn_Timers)
table.freeze(LootManager.Loot_Types)

return LootManager
