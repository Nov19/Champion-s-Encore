--[[
    Services
    Naming convention: ???
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

--[[
    Modules
    Naming convention: ???
]]

local Behaviors = {}

--[[
    Tables
    Naming convention: ???
]]

Behaviors = { Push = require(ReplicatedStorage.Assets.Push) }

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
return Behaviors
