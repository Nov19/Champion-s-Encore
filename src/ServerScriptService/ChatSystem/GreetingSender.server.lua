--[[
    Services
    Naming convention: ???
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

--[[
    Modules
    Naming convention: ???
]]

local Communication = require(ReplicatedStorage.Modules.Communication)
local TextHelper = require(ReplicatedStorage.Modules.Helpers.TextHelper)

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

--- Sends a greeting message to all players.
---@param player Player The player to send the greeting to.
local function SendGreetingToAllPlayer(player)
	local greetingMessage = "🎊 "
	greetingMessage = greetingMessage .. TextHelper.Bold(player.DisplayName)
	greetingMessage = greetingMessage .. " (@" .. TextHelper.Italicized(player.Name) .. ")"
	greetingMessage = greetingMessage .. " just joined! Welcome to the game!"
	greetingMessage = TextHelper.Colored(greetingMessage, Color3.new(0.988235, 0.666666, 0.666666))

	Communication.FireAllClients("Greeting", greetingMessage)
end

local function SendWelcomeMessage(player)
	local welcomeMessage1 = "🥳 Welcome to the game, " .. TextHelper.Bold(player.DisplayName) .. "!"
	welcomeMessage1 = TextHelper.Colored(
		TextHelper.FontFaced(welcomeMessage1, "FredokaOne"),
		Color3.new(0.666666, 0.933333, 0.988235)
	)
	local welcomeMessage2 = "👏 Don't forget to leave a like if you enjoy the game!"
	welcomeMessage2 =
		TextHelper.Colored(TextHelper.FontFaced(welcomeMessage2, "FredokaOne"), Color3.new(1, 0.8, 0.988235))

	Communication.FireClient("WelcomeMessage", player, welcomeMessage1 .. "\n" .. welcomeMessage2)
end

--[[
    Functions
]]

--[[
    Event connections
    Conventional order: Remote events -> Bindable events -> Remote functions -> Bindable functions
]]

Communication.OnServerEvent("CanSendGreeting", function(player)
	SendWelcomeMessage(player)
	SendGreetingToAllPlayer(player)
end)

--[[
    Code execution
]]
