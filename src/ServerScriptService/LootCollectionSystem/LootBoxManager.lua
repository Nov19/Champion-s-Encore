--[[
    Services
    Naming convention: ???
]]

local CollectionService = game:GetService("CollectionService")

--[[
    Modules
    Naming convention: ???
]]

local LootBox = require(script.Parent.LootBox)

local LootManager = {}
LootManager.__index = LootManager

--[[
    Tables
    Naming convention: ???
]]

--[[
    References & Parameters
]]

local LOOT_BOX_SPAWN_POINT_TAG = "LootSpawnPoint"

LootManager.Loot_Types = {
	Loot = "Loot",
	Shield = "Shield",
	Booster = "Booster",
	Regen = "Regen",
}

--[[
    Local functions
]]

--- Validate if a spawn point is valid
---@return boolean
local function ValidateSpawnPoints(self)
	if #self.Spawn_Points < 0 then
		warn("No spawn points found")
		return false
	end

	for _, point in ipairs(self.Spawn_Points) do
		-- Check if the spawn point is valid
		if not point or not point:IsA("BasePart") then
			warn("Invalid spawn point:", point)
			return false
		end
	end

	return true
end

--- Get all the spawn points
---@return table
local function GetSpawnPoints()
	local points = {}

	-- Get all the spawn points
	local spawnPoints = CollectionService:GetTagged(LOOT_BOX_SPAWN_POINT_TAG)
	for _, spawnPoint in ipairs(spawnPoints) do
		table.insert(points, spawnPoint)
	end

	return points
end

--[[
    Functions
]]

--- Create a new LootManager object
---@class LootManager
---@return LootManager
function LootManager.new()
	local self = setmetatable({}, LootManager)

	self.Spawn_Points = GetSpawnPoints()
	self.Spawn_Timers = {}
	self.ActiveLootBoxes = {}

	table.freeze(self.Spawn_Points)

	-- Validate all the spawn points
	if not ValidateSpawnPoints(self) then
		return nil
	end

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
	self.ActiveLootBoxes[lootBox.BoxId] = nil
end

function LootManager:GetLootBox(boxId: string)
	return self.ActiveLootBoxes[boxId]
end

--- Get all active lootboxes
---@return table
function LootManager:GetLoots()
	-- Check if there are any active lootboxes
	if not self.ActiveLootBoxes then
		return {}
	end

	local loots = {}

	-- Iterate through all active lootboxes
	for boxId, box in pairs(self.ActiveLootBoxes) do
		loots[boxId] = {}

		for index, item in ipairs(box.Loot) do
			loots[boxId][index] = {
				Id = item.loot.LootId,
				TempId = item.tempId,
				Price = item.loot.Price,
				Name = item.loot.Name,
			}
		end
	end

	return loots
end

--- Grant a loot item to a player
---@param player Player The player to grant the loot to
---@param boxId string The ID of the LootBox
---@param tempId string The temporary ID of the loot item
function LootManager:GrantLootToPlayer(player, boxId, tempId)
	local box = self:GetLootBox(boxId)
	if not box then
		warn("LootBox not found:", boxId)
		return
	end

	-- TODO First pick first get the item, unless the player has no capacity
end

--[[
    Event connections
    Conventional order: Remote events -> Bindable events -> Remote functions -> Bindable functions
]]

--[[
    Code execution
]]

-- Freeze the tables
table.freeze(LootManager.Loot_Types)

return LootManager
