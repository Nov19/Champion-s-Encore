--[[
    Services
    Naming convention: ???
]]
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--[[
    Modules
    Naming convention: ???
]]
local TeamManager = require(ReplicatedStorage.Modules.Team)
local ConfigLoader = require(ReplicatedStorage.Modules.ConfigLoader)
local Communication = require(ReplicatedStorage.Modules.Communication)

--[[
    Tables
    Naming convention: Tab_???
]]

local ServerConfigs = ConfigLoader:RemapConfigs(ConfigLoader:GetConfig("ServerConfigs"), "ConstantName")

--[[
    References & Parameters
]]
-- Configuration
local TEAM_CHOICE_TIMEOUT = ServerConfigs.TEAM_CHOICE_TIMEOUT.Value -- 30 seconds timeout for team choice responses

-- State management
local playerTeamChoices = {} -- Stores player team choices
local isCollectingTeamChoices = false
local isStartARunExecuting = false -- Tracks if StartARun is currently executing
local activeRunId = nil
local runIdCounter = 0

-- Event names for communication
local TEAM_CHOICE_REQUEST = "TeamChoiceRequest"
local TEAM_CHOICE_RESPONSE = "TeamChoiceResponse"
local TEAM_ASSIGNMENT_UPDATE = "TeamAssignmentUpdate"
local GAME_COMPLETED = "GameCompleted"

--[[
	Local functions
]]
-- Handle team choice response from client
function HandleTeamChoiceResponse(player, teamChoice)
	if not player or not player.Parent then
		return -- Player left
	end

	-- Validate team choice
	if type(teamChoice) == "string" and teamChoice ~= "" then
		-- Check if the team exists
		local team = TeamManager:GetTeamByName(teamChoice)
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

-- Initialize communication events
local function InitializeEvents()
	-- Server-side event handlers
	Communication.OnServerEvent(TEAM_CHOICE_RESPONSE, function(player, teamChoice)
		HandleTeamChoiceResponse(player, teamChoice)
	end)
end

--[[
    Functions
]]

-- Process collected team choices and assign teams
function ProcessTeamChoices()
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
				local team = TeamManager:GetTeamByName(choice.teamChoice)
				if team then
					TeamManager:SetPlayerTeam(player, team)
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
	Communication.FireAllClients(TEAM_ASSIGNMENT_UPDATE, {
		playersProcessed = playersProcessed,
		playersAssigned = playersAssigned,
		playersNeutral = playersNeutral,
	})

	isCollectingTeamChoices = false
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
	Communication.FireAllClients(TEAM_CHOICE_REQUEST)

	-- Set timeout for team choice collection
	task.spawn(function()
		task.wait(TEAM_CHOICE_TIMEOUT)
		ProcessTeamChoices()
	end)
end

-- Invoke StartARun BindableFunction and wait for completion
function InvokeStartARun()
	-- Generate a new run ID
	runIdCounter = runIdCounter + 1
	activeRunId = runIdCounter
	print("Starting StartARun with ID:", activeRunId)
	Communication.Invoke("StartARun", activeRunId)
	print("StartARun finished")
end

-- Handle player joining
function OnPlayerAdded(player)
	-- Set new player to neutral initially
	player.Neutral = true

	-- Clean up any old choices for this player (in case of rejoin)
	playerTeamChoices[player.UserId] = nil
end

-- Handle player leaving
function OnPlayerRemoving(player)
	-- Clean up player's team choice
	playerTeamChoices[player.UserId] = nil
end

-- Handle game completion and start new team collection cycle
function OnGameCompleted()
	print("Game completed! Starting new team collection cycle...")
	-- Signal to stop the current run
	activeRunId = nil

	-- Start the team collection process
	RequestTeamChoices()

	-- Invoke StartARun BindableFunction after team processing is complete
	InvokeStartARun()
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

-- Connect to game completion event
Communication.Event(GAME_COMPLETED, function()
	print("Game completed!!!!")
	OnGameCompleted()
end)

--[[
    Code execution
]]

-- Set existing players to neutral
for _, player in pairs(Players:GetPlayers()) do
	OnPlayerAdded(player)
end

-- Start the initial team collection cycle
RequestTeamChoices()
InvokeStartARun()
