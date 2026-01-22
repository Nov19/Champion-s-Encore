--[[
    Services
    Naming convention: ???
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

--[[
    Modules
    Naming convention: ???
]]

local Communication = require(ReplicatedStorage.Modules.Communication)
local IdGenerateHelper = require(ReplicatedStorage.Modules.Helpers.IdGenerateHelper)
local LootGenerator = require(script.Parent.LootGenerator)

local LootBox = {}
LootBox.__index = LootBox

--[[
    Tables
    Naming convention: ???
]]

local Possibility_To_Item_Counts = {
	[1] = 0.48,
	[2] = 0.76,
	[3] = 0.91,
	[4] = 0.98,
	[5] = 0.995,
	[6] = 0.999,
	[7] = 1.0,
}

LootBox.Snapshot = {
	boxID = "BOX_",
	position = Vector3.new(0, 0, 0),
	loot = {},
}

LootBox.States = {
	Idle = "Idle",
	Active = "Active",
	Collected = "Collected",
	Empty = "Empty",
	Despawning = "Despawning",
}

--[[
    References & Parameters
]]

local lootBoxModel = ReplicatedStorage.Prefabs.LootBoxes:WaitForChild("LootBox")
local openedLootBoxModel = ReplicatedStorage.Prefabs.LootBoxes:WaitForChild("OpenedLootBox")

--[[
    Local functions
]]

--- Generate a random rarity based on the Possibility_To_Rarity table
---@return number
local function GenerateCountsWithPossibility()
	local p = Possibility_To_Item_Counts
	local r = math.random()
	if r <= p[1] then
		return 1
	elseif r <= p[2] then
		return 2
	elseif r <= p[3] then
		return 3
	elseif r <= p[4] then
		return 4
	elseif r <= p[5] then
		return 5
	elseif r <= p[6] then
		return 6
	else
		return 7
	end
end

--- Generate loot for the LootBox
---@return table
local function GenerateLoot()
	local loot = {}

	local counts = GenerateCountsWithPossibility() -- Generate #loot

	-- Generate the specified number (counts) of loot items
	for i = 1, counts do
		local lootItem = LootGenerator.GenerateLoot()
		if lootItem then
			table.insert(loot, lootItem)
			print("  Generated loot:", lootItem)
		else
			warn("Failed to generate loot item " .. i)
		end
	end

	return loot
end

--- Handle the player collecting the LootBox
---@param player Player The player collecting the LootBox
---@param boxId string The ID of the LootBox being collected
local function OnPlayerCollectLootBox(player: Player, boxId: string)
	Communication.FireClient("OpenLootBoxCollectionUI", player, boxId)
end

--[[ 
    Functions
]]

--- Create a new LootBox object
---@class LootBox
---@return LootBox
function LootBox.new(spawnPoint: BasePart, model: Model)
	local self = setmetatable({}, LootBox)

	self.SpawnPoint = spawnPoint
	self.State = LootBox.States.Idle
	self.Model = model
	self.SpawnTime = tick()
	self.DespawnTimer = nil
	self.BoxId = IdGenerateHelper.GenerateTempId() .. "-" .. os.clock()
	self.Position = self.SpawnPoint.Position
	self.Loot = {}

	self:Initialize()

	return self
end

--- Initialize the LootBox
function LootBox:Initialize()
	self:CreateModel()
	self.Loot = GenerateLoot()
	self:SetupInteractions()
	self.State = LootBox.States.Active
end

--- Create the model for the LootBox
function LootBox:CreateModel()
	local model = lootBoxModel:Clone()
	self.Model = model
	model.Parent = workspace
	model:SetPrimaryPartCFrame(self.SpawnPoint.CFrame)
end

--- Set up interactions for the LootBox
function LootBox:SetupInteractions()
	local proximityPrompt = Instance.new("ProximityPrompt")
	proximityPrompt.Parent = self.Model
	proximityPrompt.ActionText = "Collect"
	proximityPrompt.RequiresLineOfSight = false
	proximityPrompt.Triggered:Connect(function(player: Player)
		OnPlayerCollectLootBox(player, self.BoxId)
	end)
end

--- Collect the LootBox
---@param player Player The player collecting the LootBox
function LootBox:PickUpLoot(player: Player, loot: table) end

--- This function should be called when the player is done collecting the LootBox
---@param player Player The player who is done collecting the LootBox
function LootBox:PlaceLoot(player: Player, isToLootBox: boolean)
	if isToLootBox then
		-- The loot will be placed back to the LootBox
	else
		-- The loot will be dropped to the ground
	end
end

function LootBox:Despawn()
	self.State = LootBox.States.Despawning

	for _, connection in pairs(self.ServerConnection) do
		task.cancel(connection)
	end

	if self.DespawnTimer then
		self.DespawnTimer:Cancel()
		self.DespawnTimer = nil
	end

	if self.Model then
		self.Model:Destroy()
		self.Model = nil
	end
end

--[[
    Event connections
    Conventional order: Remote events -> Bindable events -> Remote functions -> Bindable functions
]]

--[[
    Code execution
]]
table.freeze(LootBox.Snapshot)
table.freeze(LootBox.States)

return LootBox
