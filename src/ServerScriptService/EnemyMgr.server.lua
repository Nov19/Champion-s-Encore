local Workspace = game:GetService("Workspace")
local ServerStorage = game:GetService("ServerStorage")

local EnemyList = {}

-- XXX: This is a simple example of how to manage a list of enemies in a game
local Enemies =  {
    Melee = {
        TestRig = ServerStorage.Enemies:WaitForChild("TestRig")
    },
}

-- Whenever a new enemy (tagged by "Enemy") is spawned, it is added to the enemy list
Workspace.ChildAdded:Connect(function(child)
    if child:IsA("Model") and child:FindFirstChild("Humanoid") and child:FindFirstChild("Humanoid").Health > 0 then
        if child:FindFirstChild("Enemy") then
            table.insert(EnemyList, child)

            print("Enemy added to list. Name: " .. child.Name)
        end
    end
end)

while true do

    -- Every 10 seconds, spawn a new enemy around the spawn location (0, 0, 0). Randomize the position
    task.wait(10)
    
    -- Spawn enemy at spawnPosition
    local enemy = Enemies.Melee.TestRig:Clone()
    enemy.Parent = Workspace
    enemy:SetPrimaryPartCFrame(CFrame.new(Vector3.new(math.random(-10, 10), 0, math.random(-10, 10))))
end