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
	TouchControllerUI = PlayerGui:WaitForChild("TouchControllerUI"),
	StartMenuUI = PlayerGui:WaitForChild("StartMenuUI"),
	PCKeyBindingUI = PlayerGui:WaitForChild("PCKeyBindingUI"),
}

UIReference.TouchControllerUI = {
	LockOnBtn = UIReference.Guis.TouchControllerUI:WaitForChild("LockOnBtn"),
	AttackBtn = UIReference.Guis.TouchControllerUI:WaitForChild("AttackBtn"),
	JumpBtn = UIReference.Guis.TouchControllerUI:WaitForChild("JumpBtn"),
}

UIReference.StartMenuUI = {
	PlayBtn = UIReference.Guis.StartMenuUI:WaitForChild("PlayBtn"),
}

UIReference.PCKeyBindingUI = {
	JumpKeyBind = UIReference.Guis.PCKeyBindingUI:WaitForChild("JumpKeyBind"),
	AttackKeyBind = UIReference.Guis.PCKeyBindingUI:WaitForChild("AttackKeyBind"),
	LockOnKeyBind = UIReference.Guis.PCKeyBindingUI:WaitForChild("LockOnKeyBind"),
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
