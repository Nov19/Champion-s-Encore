--[[
    Services
    Naming convention: ???
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

--[[
    Modules
    Naming convention: ???
]]

local ConfigLoader = require(ReplicatedStorage.Modules.ConfigLoader)

local Loot = {}

--[[
    Tables
    Naming convention: ???
]]

local Loot_Configs = ConfigLoader:GetConfig("LootConfigs")
local Rarity_To_Loots = ConfigLoader:RemapConfigs(Loot_Configs, "Rarity")
local Possibility_To_Rarity = {
	[1] = 0.48, -- Common: 48%
	[2] = 0.76, -- Uncommon: 28%
	[3] = 0.91, -- Rare: 15%
	[4] = 0.98, -- Epic: 7%
	[5] = 0.995, -- Legendary: 1.5%
	[6] = 1.0, -- Mythical: 0.5%
}

Loot.Rarity_Levels = {
	Common = {
		Weight = 1,
		Color = Color3.fromRGB(255, 255, 255),
	},
	Uncommon = {
		Weight = 2,
		Color = Color3.fromRGB(128, 255, 0),
	},
	Rare = {
		Weight = 3,
		Color = Color3.fromRGB(0, 128, 255),
	},
	Epic = {
		Weight = 4,
		Color = Color3.fromRGB(119, 19, 185),
	},
	Legendary = {
		Weight = 5,
		Color = Color3.fromRGB(242, 255, 0),
	},
	Mythical = {
		Weight = 6,
		Color = Color3.fromRGB(255, 0, 0),
	},
}

--[[
    References & Parameters
]]

-- Pre-cache CHARSET length for faster access
local CHAR_SET = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
local CHAR_SET_LENGTH = #CHAR_SET
local ID_LENGTH = 12

--[[
    Local functions
]]

--- Generate a temporary ID for the LootBox
---@return string
local function GenerateTempId()
	local result = table.create(ID_LENGTH)
	for i = 1, ID_LENGTH do
		-- Use bit32.band for faster random range (if available)
		local index = math.random(1, CHAR_SET_LENGTH)
		result[i] = string.sub(CHAR_SET, index, index) -- string.sub is slightly faster than :sub()
	end
	return table.concat(result)
end

--- Generate a random rarity based on the Possibility_To_Rarity table
---@return number
local function GenerateRandomRarity()
	local p = Possibility_To_Rarity
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
	else
		return 6
	end
end

--[[
    Functions
]]

--- Generate a Loot object
---@param boxId string The ID of the LootBox
---@return table
function Loot.GenerateLoot(boxId: string)
	local tempId = boxId .. "-" .. GenerateTempId() .. "-" .. os.clock()
	local rarity = GenerateRandomRarity()
	local lootPool = Rarity_To_Loots[rarity]
	local loot

	-- Handle both single loot items and arrays of loot items
	if typeof(lootPool) == "table" and #lootPool > 0 then
		-- It's an array of loot items
		loot = lootPool[math.random(1, #lootPool)]
	elseif typeof(lootPool) == "table" and lootPool.LootId then
		-- It's a single loot item
		loot = lootPool
	else
		warn("GenerateLoot(): No valid loot found for rarity " .. rarity)
		return nil
	end

	return {
		tempId = tempId,
		rarity = rarity,
		loot = loot,
	}
end

--[[
    Event connections
    Conventional order: Remote events -> Bindable events -> Remote functions -> Bindable functions
]]

--[[
    Code execution
]]

table.freeze(Loot_Configs)
table.freeze(Rarity_To_Loots)
table.freeze(Possibility_To_Rarity)
table.freeze(Loot.Rarity_Levels)

return Loot
