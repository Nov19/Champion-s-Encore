--[[
    Services
    Naming convention: ???
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

--[[
    Modules
    Naming convention: ???
]]

local LootBoxManager = require(script.LootBoxManager)

--[[
    Tables
    Naming convention: ???
]]

local Communication = require(ReplicatedStorage.Modules.Communication)

--[[
    References & Parameters
]]

local lootMgr = LootBoxManager.new()

--[[
    Local functions
]]

--[[
    Functions
]]

--[[
    Event connections
    Conventional order: Remote events -> Bindable events -> Remote functions -> Bindable functions
]]

Communication.OnServerInvoke("FetchLoots", function()
	return lootMgr:GetLoots()
end)

--[[
    Code execution
]]

lootMgr:SpawnLootBox(lootMgr.Spawn_Points[math.random(1, #lootMgr.Spawn_Points)])
print(lootMgr.ActiveLootBoxes)
