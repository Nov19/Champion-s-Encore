--[[
    Services
    Naming convention: ???
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

--[[
    Modules
    Naming convention: ???
]]

local UIReferences = require(script.Parent.UIReferences)

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

UIReferences.StartMenuUI.PlayBtn.Activated:Connect(function()
	UIReferences.Guis.StartMenuUI.Enabled = false
	UIReferences.Guis.ControllerUI.Enabled = true
end)

--[[
    Code execution
]]
