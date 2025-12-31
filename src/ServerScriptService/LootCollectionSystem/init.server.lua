--[[
    Services
    Naming convention: ???
]]

--[[
    Modules
    Naming convention: ???
]]

local LootBoxManager = require(script.LootBoxManager)

--[[
    Tables
    Naming convention: ???
]]

--[[
    References & Parameters
]]

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

--[[
    Code execution
]]

LootBoxManager.SpawnLootBox(LootBoxManager.Spawn_Points[math.random(1, #LootBoxManager.Spawn_Points)])
