-- TeamManager.lua
local Teams = game:GetService("Teams")

local TeamManager = {}

-- Utility: Get a team by name
function TeamManager:GetTeamByName(teamName)
	return Teams:FindFirstChild(teamName)
end

-- Utility: Get team with fewest players (respecting AutoAssignable)
function TeamManager:GetBalancedTeam()
	local lowestTeam = nil
	local lowestCount = math.huge

	for _, team in pairs(Teams:GetChildren()) do
		if team:IsA("Team") and team.AutoAssignable then
			local count = #team:GetPlayers()
			if count < lowestCount then
				lowestCount = count
				lowestTeam = team
			end
		end
	end

	return lowestTeam
end

-- Assign player to a specific team
function TeamManager:SetPlayerTeam(player, team)
	if team and team:IsA("Team") then
		player.Neutral = false
		player.Team = team
		player.TeamColor = team.TeamColor
	else
		-- Fallback: make Neutral
		player.Neutral = true
	end
end

-- Automatically assign (balanced)
function TeamManager:AutoAssign(player)
	local team = self:GetBalancedTeam()
	if team then
		self:SetPlayerTeam(player, team)
	else
		player.Neutral = true
	end
end

return TeamManager
