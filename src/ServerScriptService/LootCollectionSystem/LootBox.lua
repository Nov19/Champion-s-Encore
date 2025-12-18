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

local LootBox = {}
LootBox.__index = LootBox

--[[
    Tables
    Naming convention: ???
]]

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

local function GenerateLoot()
	local loot = {}

	warn("GenerateLoot - Not implemented yet")

	return loot
end

--[[ 
    Functions
]]

--- Create a new LootBox object
---@param spawnPoint BasePart The spawn point for the LootBox
---@param lootType string The type of loot to be contained in the LootBox
---@param rarity string The rarity of the LootBox
---@return table
function LootBox.new(spawnPoint: BasePart, lootType: string, rarity: string, model: Model)
	local self = setmetatable({}, LootBox)

	self.SpawnPoint = spawnPoint
	self.LootType = lootType
	self.Rarity = rarity
	self.State = LootBox.States.Idle
	self.Model = model
	self.SpawnTime = tick()
	self.DespawnTimer = nil
	self.ServerConnection = {}
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
	local model = self.Model or lootBoxModel:Clone()
	model.Parent = workspace
	model:SetPrimaryPartCFrame(self.SpawnPoint.CFrame)
end

--- Set up interactions for the LootBox
function LootBox:SetupInteractions()
	local proximityPrompt = self.Model:WaitForChild("ProximityPrompt")
	proximityPrompt.Triggered:Connect(function(player: Player)
		self:Collect(player)
	end)
end

--- Collect the LootBox
---@param player Player The player collecting the LootBox
function LootBox:Collect(player: Player)
	-- TODO Pop the player's LootBox collection UI
	Communication.FireClient(player, "OpenLootBoxCollectionUI", self.Loot)

	-- TODO Establish a connection between the collection UI and the LootBox collection data on the server
	-- TODO Store the event connection in a self.ServerConnection[player]
	self.ServerConnection[player] = task.spawn(function()
		while true do
			self:Update(0.16)
		end
	end)
end

--- This function should be called when the player is done collecting the LootBox
---@param player Player The player who is done collecting the LootBox
function LootBox:StopCollecting(player: Player)
	-- TODO Disconnect the connection between the collection UI and the LootBox collection data on the server
	if self.ServerConnection[player] then
		task.cancel(self.ServerConnection[player])
		self.ServerConnection[player] = nil
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

function LootBox:Update(deltaTime: number)
	Communication.OnClientEvent("CollectLootBox", function()
		warn("CollectLootBox - Not implemented yet")
	end)

	task.wait(deltaTime)
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
