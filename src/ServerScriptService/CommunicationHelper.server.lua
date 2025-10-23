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

--[[
    Tables
    Naming convention: ???
]]

local BindableEvents = {
	"PlayBtnActivated",
	"Attack",
}

local RemoteEvents = {}

local RemoteFunctions = {}

local BindableFunctions = {}

--[[
    References & Parameters
]]

--[[
    Local functions
]]

--[[
    Functions
]]

local function InitializeCommunication()
	for _, bindableEvent in pairs(BindableEvents) do
		Communication.GetBindableEvent(bindableEvent)
	end
	for _, remoteEvent in pairs(RemoteEvents) do
		Communication.GetRemoteEvent(remoteEvent)
	end
	for _, remoteFunction in pairs(RemoteFunctions) do
		Communication.GetRemoteFunction(remoteFunction)
	end
	for _, bindableFunction in pairs(BindableFunctions) do
		Communication.GetBindableFunction(bindableFunction)
	end
end

--[[
    Event connections
    Conventional order: Remote events -> Bindable events -> Remote functions -> Bindable functions
]]

--[[
    Code execution
]]
InitializeCommunication()
