--[[
    Services
    Naming convention: Ser_???
]]

local Players = game:GetService("Players")

local PlayerGui = Players.LocalPlayer.PlayerGui -- This is the prerequisite for the UIReferences

--[[
    Modules
    Naming convention: ???Module
]]
local UIReference = {}

--[[
    Remote events
    Naming convention: RE_???
]]

--[[
    Bindable events
    Naming convention: BE_???
]]

--[[
    Remote functions
    Naming convention: RF_???
]]

--[[
    Bindable functions
    Naming convention: BF_???
]]

--[[
    Tables
    Naming convention: Tab_???
]]

UIReference.Guis = {
	ControllerUI = PlayerGui:WaitForChild("ControllerUI"),
	StartMenuUI = PlayerGui:WaitForChild("StartMenuUI"),
}

UIReference.ControllerUI = {
	LockOnBtn = UIReference.Guis.ControllerUI:WaitForChild("LockOnBtn"),
}

UIReference.StartMenuUI = {
	PlayBtn = UIReference.Guis.StartMenuUI:WaitForChild("PlayBtn"),
}

--[[
    References & Parameters
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

return UIReference
