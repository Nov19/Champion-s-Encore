--[[
    Services
    Naming convention: ???
]]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

--[[
    Modules
    Naming convention: ???Module
]]
local TeamManagerModule = require(ReplicatedStorage.Modules.Team)
local CommunicationModule = require(ReplicatedStorage.Modules.Communication)

--[[
    Tables
    Naming convention: Tab_???
]]
local ServerConfig = require(ServerStorage.Configs.ServerConfigs)

--[[
    References & Parameters
]]
-- Configuration
local TEAM_COLLECTION_INTERVAL = 120 -- 2 minutes in seconds
local TEAM_CHOICE_TIMEOUT = 30 -- 30 seconds timeout for team choice responses

-- State management
local playerTeamChoices = {} -- Stores player team choices
local teamCollectionTimer = 0
local isCollectingTeamChoices = false

-- Event names for communication
local TEAM_CHOICE_REQUEST = "TeamChoiceRequest"
local TEAM_CHOICE_RESPONSE = "TeamChoiceResponse"
local TEAM_ASSIGNMENT_UPDATE = "TeamAssignmentUpdate"

--[[
    Functions
]]
-- Initialize communication events
local function InitializeEvents()
	-- Server-side event handlers
	CommunicationModule.OnServerEvent(TEAM_CHOICE_RESPONSE, function(player, teamChoice)
		HandleTeamChoiceResponse(player, teamChoice)
	end)
end

-- Handle team choice response from client
function HandleTeamChoiceResponse(player, teamChoice)
	if not player or not player.Parent then
		return -- Player left
	end

	-- Validate team choice
	if type(teamChoice) == "string" and teamChoice ~= "" then
		-- Check if the team exists
		local team = TeamManagerModule:GetTeamByName(teamChoice)
		if team then
			playerTeamChoices[player.UserId] = {
				player = player,
				teamChoice = teamChoice,
				timestamp = tick(),
			}
			print("Player " .. player.Name .. " chose team: " .. teamChoice)
		else
			print("Invalid team choice from " .. player.Name .. ": " .. teamChoice)
		end
	elseif teamChoice == nil or teamChoice == "" then
		-- Player chose to remain neutral
		playerTeamChoices[player.UserId] = {
			player = player,
			teamChoice = nil,
			timestamp = tick(),
		}
		print("Player " .. player.Name .. " chose to remain neutral")
	end
end

-- Request team choices from all players
function RequestTeamChoices()
	if isCollectingTeamChoices then
		return -- Already collecting
	end

	isCollectingTeamChoices = true
	playerTeamChoices = {} -- Clear previous choices

	print("Requesting team choices from all players...")

	-- Fire event to all clients requesting team choices
	CommunicationModule.FireAllClients(TEAM_CHOICE_REQUEST)

	-- Set timeout for team choice collection
	spawn(function()
		wait(TEAM_CHOICE_TIMEOUT)
		ProcessTeamChoices()
	end)
end

-- Process collected team choices and assign teams
function ProcessTeamChoices()
	print("Processing team choices...")

	local playersProcessed = 0
	local playersAssigned = 0
	local playersNeutral = 0

	-- Process all current players
	for _, player in pairs(Players:GetPlayers()) do
		playersProcessed = playersProcessed + 1

		local choice = playerTeamChoices[player.UserId]

		if choice then
			-- Player made a choice
			if choice.teamChoice then
				-- Assign to chosen team
				local team = TeamManagerModule:GetTeamByName(choice.teamChoice)
				if team then
					TeamManagerModule:SetPlayerTeam(player, team)
					playersAssigned = playersAssigned + 1
					print("Assigned " .. player.Name .. " to team: " .. choice.teamChoice)
				else
					-- Fallback to neutral if team doesn't exist
					player.Neutral = true
					playersNeutral = playersNeutral + 1
					print("Team not found, set " .. player.Name .. " to neutral")
				end
			else
				-- Player chose neutral
				player.Neutral = true
				playersNeutral = playersNeutral + 1
				print("Set " .. player.Name .. " to neutral (player choice)")
			end
		else
			-- Player didn't respond, set to neutral
			player.Neutral = true
			playersNeutral = playersNeutral + 1
			print("No response from " .. player.Name .. ", set to neutral")
		end
	end

	-- Clean up choices for players who left
	for userId, choice in pairs(playerTeamChoices) do
		if not choice.player or not choice.player.Parent then
			playerTeamChoices[userId] = nil
		end
	end

	print(
		string.format(
			"Team assignment complete: %d processed, %d assigned to teams, %d set to neutral",
			playersProcessed,
			playersAssigned,
			playersNeutral
		)
	)

	-- Notify clients about team assignment update
	CommunicationModule.FireAllClients(TEAM_ASSIGNMENT_UPDATE, {
		playersProcessed = playersProcessed,
		playersAssigned = playersAssigned,
		playersNeutral = playersNeutral,
	})

	isCollectingTeamChoices = false
end

-- Handle player joining
function OnPlayerAdded(player)
	print("Player joined: " .. player.Name)

	-- Set new player to neutral initially
	player.Neutral = true
	print("Set " .. player.Name .. " to neutral (new player)")

	-- Clean up any old choices for this player (in case of rejoin)
	playerTeamChoices[player.UserId] = nil
end

-- Handle player leaving
function OnPlayerRemoving(player)
	print("Player left: " .. player.Name)

	-- Clean up player's team choice
	playerTeamChoices[player.UserId] = nil
end

-- Main update loop for periodic team collection
function Update(deltaTime)
	teamCollectionTimer = teamCollectionTimer + deltaTime

	if teamCollectionTimer >= TEAM_COLLECTION_INTERVAL then
		teamCollectionTimer = 0
		RequestTeamChoices()
	end
end

--[[
    Event connections
    Conventional order: Remote events -> Bindable events -> Remote functions -> Bindable functions
]]
-- Initialize communication events
InitializeEvents()

-- Connect player events
Players.PlayerAdded:Connect(OnPlayerAdded)
Players.PlayerRemoving:Connect(OnPlayerRemoving)

-- Start the update loop
RunService.Heartbeat:Connect(Update)

--[[
    Code execution
]]
-- Initialize the team management system
print("Initializing Team Management System...")

-- Set existing players to neutral
for _, player in pairs(Players:GetPlayers()) do
	OnPlayerAdded(player)
end

print("Team Management System initialized successfully")
