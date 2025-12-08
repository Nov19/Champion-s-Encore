--[[
    Services
    Naming convention: ???
]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextChatService = game:GetService("TextChatService")

--[[
    Modules
    Naming convention: ???
]]

local Communication = require(ReplicatedStorage.Modules.Communication)
local TextChannelController = require(script.Parent.TextChannelController)

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

Communication.OnClientEvent("Greeting", function(message)
	repeat
		task.wait()
	until TextChannelController.Channel.System ~= nil

	TextChannelController.SendSystemMessage(message)
end)

Communication.OnClientEvent("WelcomeMessage", function(message)
	repeat
		task.wait()
	until TextChannelController.Channel.System ~= nil

	TextChannelController.SendSystemMessage(message)
end)

TextChatService.OnIncomingMessage = function(message)
	local properties = Instance.new("TextChatMessageProperties")
	properties.Text = message.Text
	return properties
end

--[[
    Code execution
]]
Communication.FireServer("CanSendGreeting")
