--[[
    Services
    Naming convention: Ser_???
]]
local Workspace = game:GetService("Workspace")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

--[[
    Modules
    Naming convention: ???Module
]]
local EventBlock = require(script.Parent.EventBlock)
--- @type EventBlock
local Communication = require(ReplicatedStorage.Modules.Communication)
local ConfigLoader = require(ReplicatedStorage.Modules.ConfigLoader)

--[[
	Types
	Convention: ---@type ???
]]

--[[
    Tables
    Naming convention: Tab_???
]]
local ServerConfigs = ConfigLoader:RemapConfigs(ConfigLoader:GetConfig("ServerConfigs"), "ConstantName")

local Players_In_Game = {}
local EventBlockObjects = {}
--[[
    References & Parameters
]]
local EVENT_BLOCK_TAG = ServerConfigs.EVENT_BLOCK_TAG.Value
local EVENT_BLOCKS_FOLDER_NAME = ServerConfigs.EVENT_BLOCKS_FOLDER_NAME.Value
local INITIAL_TRIGGERED_EVENT_BLOCKS = ServerConfigs.INITIAL_TRIGGERED_EVENT_BLOCKS.Value

local isEventBlocksInitialized = false
--[[
    Local functions
]]

--- Check if a part has the EventBlock tag
---@param part BasePart
---@return boolean
local function HasEventBlockTag(part)
	return CollectionService:HasTag(part, EVENT_BLOCK_TAG)
end

--- Create EventBlock object for a tagged part
---@param model Model a event block model
---@param blockType string? Optional block type, will be determined from model name if not provided
local function CreateEventBlockForModel(model, blockType)
	-- Find the model that contains this part
	if not model or not model:IsA("Model") then
		warn("EventBlock part " .. model.Name .. " is a Model")
		return
	end

	-- Determine block type from model name if not provided
	local determinedBlockType = blockType
	if not determinedBlockType then
		-- Try to extract block type from model name (e.g., "FireBlock_1" -> "FireBlock")
		local modelName = model.Name
		for blockTypeName, _ in pairs(ConfigLoader:RemapConfigs(ConfigLoader:GetConfig("EventBlockConfigs"), "Name")) do
			if string.find(modelName, blockTypeName) then
				determinedBlockType = blockTypeName
				break
			end
		end
		-- Default to FireBlock if no match found
		determinedBlockType = determinedBlockType or "FireBlock"
	end

	-- Create EventBlock object
	local eventblock = EventBlock:New(model, determinedBlockType)

	-- Store these blocks in a table, for the GetRandomEventBlocks to use.
	table.insert(EventBlockObjects, eventblock)
end

--- Scan workspace.EventBlocks folder for existing tagged parts
local function ScanExistingEventBlocks()
	local existingEventBlocks = CollectionService:GetTagged(EVENT_BLOCK_TAG)

	for _, descendant in existingEventBlocks do
		if HasEventBlockTag(descendant) then
			CreateEventBlockForModel(descendant)
		end
	end

	isEventBlocksInitialized = true
end

--- Get random event blocks
---@param size number This is the number of event blocks to get
---@return table<number, EventBlock>
local function GetRandomEventBlocks(size)
	repeat
		task.wait()
	until isEventBlocksInitialized

	-- Create a copy of the original EventBlockObjects table to avoid modifying it
	local shuffledBlocks = {}
	for i = 1, #EventBlockObjects do
		shuffledBlocks[i] = EventBlockObjects[i]
	end

	-- Apply Fisher-Yates shuffle algorithm
	for i = #shuffledBlocks, 2, -1 do
		local j = math.random(i)
		shuffledBlocks[i], shuffledBlocks[j] = shuffledBlocks[j], shuffledBlocks[i]
	end

	-- Return only the requested number of blocks
	local result = {}
	for i = 1, math.min(size, #shuffledBlocks) do
		table.insert(result, shuffledBlocks[i])
	end

	return result
end

--- Get a random block type from available configurations
---@return string
local function GetRandomBlockType()
	local blockConfigs = ConfigLoader:GetConfig("EventBlockConfigs")
	if not blockConfigs or #blockConfigs == 0 then
		return "FireBlock"
	end

	local randomIndex = math.random(1, #blockConfigs)
	return blockConfigs[randomIndex].Name
end

--[[
    Functions
]]

--[[
    Event connections
    Conventional order: Remote events -> Bindable events -> Remote functions -> Bindable functions
]]

-- Once the game manager invoke this function, it runs after a player won the game.
Communication.OnInvoke("StartARun", function()
	-- Number of event blocks to target this cycle
	local currentBlockCount = INITIAL_TRIGGERED_EVENT_BLOCKS

	while true do -- run until a player wins...
		-- 1) Get the event blocks
		local blocks = GetRandomEventBlocks(currentBlockCount)

		-- 2) Activate event blocks with their specific effects
		for _, block in blocks do
			task.spawn(function()
				-- Get players currently on the block
				local hitPlayers = block:GetHitPlayers()

				-- Apply block-specific effects to each player
				for _, player in hitPlayers do
					block:Activate(player)
				end
			end)
		end

		-- 3) Gradually increase the number of event blocks over time
		local totalAvailable = #CollectionService:GetTagged(EVENT_BLOCK_TAG)
		if totalAvailable > 0 then
			currentBlockCount = math.min(currentBlockCount + 1, totalAvailable)
		end

		-- Small delay between cycles to avoid tight loop; adjust as needed
		task.wait(5)
	end
end)

--[[ 
    Code execution
]]

-- Scan for existing EventBlocks
local function SafeScanExistingEventBlocks()
	-- Check if dependencies are ready
	repeat
		if not ServerConfigs or not ServerConfigs.EVENT_BLOCK_TAG then
			warn("EventBlockMgr: Dependencies not ready, retrying...")
			task.wait(0.1)
		end
	until ServerConfigs and ServerConfigs.EVENT_BLOCK_TAG

	ScanExistingEventBlocks()
end

-- Replace line 136 with:
SafeScanExistingEventBlocks()
-- Handle when a part gets the EventBlock tag
CollectionService:GetInstanceAddedSignal(EVENT_BLOCK_TAG):Connect(function(part)
	-- Only process parts in the EventBlocks folder
	local eventBlocksFolder = Workspace:FindFirstChild(EVENT_BLOCKS_FOLDER_NAME)
	if eventBlocksFolder and part:IsDescendantOf(eventBlocksFolder) then
		CreateEventBlockForModel(part)
	end
end)
