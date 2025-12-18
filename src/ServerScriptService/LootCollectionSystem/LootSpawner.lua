--[[
    Services
    Naming convention: ???
]]

local CollectionService = game:GetService("CollectionService")

--[[
    Modules
    Naming convention: ???
]]

local LootSpawn = {}

--[[
    Tables
    Naming convention: ???
]]

--[[
    References & Parameters
]]

LootSpawn.Spawn_Points = {}
LootSpawn.Spawn_Timers = {}
LootSpawn.Loot_Types = {
	Loot = "Loot",
	Shield = "Shield",
	Booster = "Booster",
	Regen = "Regen",
}

--[[
    Local functions
]]

--- Validate if a spawn point is valid
---@param spawnPoint Part The spawn point to validate
---@return boolean
local function ValidateSpawnPoints(spawnPoint)
	if #LootSpawn.Spawn_Points < 0 then
		warn("No spawn points found")
		return false
	end

	for _, point in ipairs(LootSpawn.Spawn_Points) do
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
	local spawnPoints = CollectionService:GetTagged("LootSpawnPoint")
	for _, spawnPoint in ipairs(spawnPoints) do
		table.insert(LootSpawn.Spawn_Points, spawnPoint)
	end
end

--[[
    Functions
]]

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
ValidateSpawnPoints(LootSpawn.Spawn_Points)

-- Freeze the tables
table.freeze(LootSpawn.Spawn_Points)
table.freeze(LootSpawn.Spawn_Timers)
table.freeze(LootSpawn.Loot_Types)

return LootSpawn
