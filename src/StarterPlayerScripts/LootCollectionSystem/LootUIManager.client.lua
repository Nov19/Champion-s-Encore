-- Loot Collection UI Manager
--[[
    Services
    Naming convention: ???
]]

local ContextActionService = game:GetService("ContextActionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

--[[
    Modules
    Naming convention: ???
]]

local Players = game:GetService("Players")
local Communication = require(ReplicatedStorage.Modules.Communication)
local UIReferences = require(Players.LocalPlayer.PlayerScripts.UIReferences)
local ObjectHelper = require(ReplicatedStorage.Modules.Helpers.ObjectHelper)

--[[
    Tables
    Naming convention: ???
]]

local Loots = {}

--[[
    References & Parameters
]]

local lootPrefab = ObjectHelper.WaitForPath(ReplicatedStorage.Prefabs.UIComponents.Loots, "Loot")

-- Item hover info
local LONG_PRESS_DURATION = 0.5 -- Long hold time in seconds
local detailFrame = nil
local isEngaged = false -- Is the player engaged in a hover action
local holdThread = nil

--[[
    Local functions
]]

local function ShowItemDetails()
	if isEngaged then
		return
	end
	isEngaged = true

	if detailFrame then
		detailFrame.Visible = true
	end
end

local function HideDetails()
	if not isEngaged then
		return
	end
	isEngaged = false

	if detailFrame then
		detailFrame.Visible = false
	end
end

--- Close the LootBoxCollectionFrame
---@param actionName string The name of the action
---@param inputState Enum.UserInputState The state of the input
---@param inputObject InputObject The input object
---@return any
local function CloseLootBoxCollectionUI(actionName, inputState, inputObject)
	if not UIReferences.Guis.LootCollectionUI.MainFrame then
		warn("LootCollectionUI.CloseLootBoxCollectionUI - MainFrame not found in LootCollectionUI")
	end

	if inputState == Enum.UserInputState.Begin then
		if not UIReferences.Guis.LootCollectionUI.MainFrame.Visible then
			return Enum.ContextActionResult.Pass
		else
			UIReferences.Guis.LootCollectionUI.MainFrame.Visible = false
		end

		return Enum.ContextActionResult.Sink
	end
end

-- Function to handle opening the loot box collection UI
---@param boxId string
local function OpenLootBoxCollectionUI(boxId: string)
	if UIReferences.Guis.LootCollectionUI.MainFrame then
		local mainFrame = UIReferences.Guis.LootCollectionUI.MainFrame
		if mainFrame then
			-- Clear all Loots in LootContainer
			for _, child in pairs(UIReferences.LootCollectionUI.LootContainer:GetChildren()) do
				if child:GetAttribute("Id") and child:GetAttribute("TempId") then
					child:Destroy()
				end
			end

			print(boxId, Loots)

			-- Add Loots to LootContainer
			for index, loot in pairs(Loots[boxId]) do
				local newLoot = lootPrefab:Clone()
				newLoot:SetAttribute("Id", loot.Id)
				newLoot:SetAttribute("TempId", loot.TempId)
				newLoot.LayoutOrder = index
				newLoot.Parent = UIReferences.LootCollectionUI.LootContainer
			end

			mainFrame.Visible = true
		else
			warn("MainFrame not found in LootCollectionUI")
		end
	else
		warn("LootCollectionUI not found in StarterGui")
	end
end

--- Hide the key hints on touch devices
local function HideKeyBindHint()
	if UIReferences.LootCollectionUI.CloseBtnHint then
		if UserInputService.TouchEnabled then
			UIReferences.LootCollectionUI.CloseBtnHint.Visible = false
		end
	end
end

local function FetchLoots()
	Loots = Communication.InvokeServer("FetchLoots")
end

--[[
    Functions
]]

--[[
    Event connections 
    Conventional order: Remote events -> Bindable events -> Remote functions -> Bindable functions
]]

-- Listen for the OpenLootBoxCollectionUI signal
Communication.OnClientEvent("OpenLootBoxCollectionUI", OpenLootBoxCollectionUI)
-- TODO Listen a signal to delete loot from LootCollectionUI
Communication.OnClientEvent("DeleteLootFromLootCollectionUI", function(lootID)
	-- TODO Delete loot from LootContainer
	-- Since someone else (teammates) might pick up the loot earlier than you.
end)

-- Connect the CloseBtn.Activated event to close the LootBoxCollectionFrame
UIReferences.LootCollectionUI.CloseBtn.Activated:Connect(function()
	CloseLootBoxCollectionUI("CloseLootBoxCollectionUI", Enum.UserInputState.Begin)
end)

ContextActionService:BindAction("CloseLootBoxCollectionUI", CloseLootBoxCollectionUI, false, Enum.KeyCode.Q)
ContextActionService:BindAction("HoverLoot", ShowLootInfo, false, Enum.UserInputType.Touch)

-- Hide item info on hover
UserInputService.WindowFocusReleased:Connect(HideLootInfo) -- If windows loses focus...
UserInputService.InputEnded:Connect(HideLootInfo) -- If user alt-tab out of the game

-- TODO GuiObject:GetPropertyChangedSignal("AbsolutePosition")

--[[
    Code execution
]]
HideKeyBindHint()
FetchLoots()
