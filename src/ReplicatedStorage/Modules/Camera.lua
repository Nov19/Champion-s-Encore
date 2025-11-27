--[[
	Services
	Naming convention: ???
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

--[[
	Modules
	Naming convention: ???
]]

local CM = {}

--[[
	Tables
	Naming convention: ???
]]

--[[
	References & Parameters
]]

local cameraFollowConnection = nil

local targetIndicator = ReplicatedStorage.Prefabs.VFXs.TargetIndicator
local currentTargetIndicator = nil

--[[
	Local functions
]]

--- Indicate the target
---@param active boolean If true, indicate the target. If false, stop indicating the target.
---@param target table | nil The target to indicate. If nil, stop indicating the target.
local function IndicateTarget(active, target)
	if active then
		if currentTargetIndicator then
			currentTargetIndicator:Destroy()
		end

		local clonedTargetIndicator = targetIndicator:Clone()
		clonedTargetIndicator.Parent = target.PlayerObject.Character.HumanoidRootPart

		task.spawn(function()
			while clonedTargetIndicator.Parent == target.PlayerObject.Character.HumanoidRootPart do
				-- Check if ImageLabel still exists before proceeding
				if not clonedTargetIndicator.ImageLabel then
					break
				end

				local tween = TweenService:Create(
					clonedTargetIndicator.ImageLabel,
					TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, 1, true, 0),
					{
						Size = UDim2.fromScale(0.85, 0.85),
					}
				)
				tween:Play()
				tween.Completed:Wait()
				task.wait(0.1)

				-- Check again before the second tween
				if not clonedTargetIndicator.ImageLabel then
					break
				end

				tween = TweenService:Create(
					clonedTargetIndicator.ImageLabel,
					TweenInfo.new(0.35, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, 0, false, 0),
					{
						Rotation = 225,
					}
				)
				tween:Play()
				tween.Completed:Wait()

				-- Final check before setting rotation
				if clonedTargetIndicator.ImageLabel then
					clonedTargetIndicator.ImageLabel.Rotation = 45 -- Start the rotation from 45 degrees
				end
				task.wait(0.1)
			end
		end)

		currentTargetIndicator = clonedTargetIndicator
	else
		if currentTargetIndicator then
			currentTargetIndicator:Destroy()
		end
		currentTargetIndicator = nil
	end
end

--[[
	Functions
]]

--- Get the closest target
---@param isFindingClosestTarget boolean If true, find the closest target. If false, find the closest target to the center of the viewport.
---@param camera Camera
---@return table
function CM:GetClosestTarget(isFindingClosestTarget, camera)
	if RunService:IsServer() then
		warn("CameraLockOn:GetClosestTarget() - Server is not supported")
		return {}
	end
	if not camera then
		warn("CameraLockOn:GetClosestTarget() - Camera is nil")
		return {}
	end

	local targets = {}
	for _, player in Players:GetPlayers() do
		if player == Players.LocalPlayer then
			continue -- Skip the local player
		end

		local character = player.Character
		if character and character.Head and character.Humanoid.Health > 0 then
			table.insert(targets, {
				Position = character.HumanoidRootPart.CFrame.Position,
				AimingPart = character.Head,
				PlayerObject = player,
			}) -- { Position, Head, Player }
		end
	end

	if isFindingClosestTarget then
		-- TODO Find the closest target to the player's character
		warn("Not implemented yet")
	else
		-- Find the closest target to the center of the viewport
		local closestTarget = nil
		local closestDistance = math.huge
		for _, target in targets do
			local vector, onScreen = camera:WorldToScreenPoint(target.Position)
			local screenPoint = Vector2.new(vector.X, vector.Y)
			if onScreen then
				-- Calculate viewport center coordinates (in screen space)
				local viewportSize = workspace.CurrentCamera.ViewportSize
				local viewportCenter = Vector2.new(viewportSize.X / 2, viewportSize.Y / 2)

				-- Now we're comparing screen coordinates with screen coordinates
				local currentDistance = (screenPoint - viewportCenter).Magnitude
				if currentDistance < closestDistance then
					closestDistance = currentDistance
					closestTarget = target
				end
			end
		end

		return closestTarget
	end
end

--- Follow the target
---@param character Model The character to follow the target.
---@param target table | nil The target to follow. If nil, the camera will return to the player.
---@param camera Camera The camera to follow the target.
---@return table
function CM:CameraFollow(character, target, camera)
	if RunService:IsServer() then
		warn("CameraLockOn:CameraFollow() - Server is not supported")
		return {}
	end

	if not target then
		CM:CameraStopFollow(camera)
		IndicateTarget(false, nil)
	else
		IndicateTarget(true, target)
		camera.CameraType = Enum.CameraType.Scriptable

		local lastCameraCFrame = camera.CFrame
		local LERP_SPEED = 0.1 -- Adjust for responsiveness (0.01 = slow, 0.3 = fast)

		cameraFollowConnection = RunService.RenderStepped:Connect(function()
			if character and target.PlayerObject.Character then
				local characterCFrame = character.PrimaryPart.CFrame
				local targetPosition = target.PlayerObject.Character.HumanoidRootPart.CFrame.Position
				local distance = (characterCFrame.Position - targetPosition).Magnitude

				local offset
				if distance < 1.0 then
					-- Use a fixed offset when very close
					offset = Vector3.new(0, 5, 11)
				else
					offset = (characterCFrame.Position - targetPosition).Unit * 11 + Vector3.new(0, 5, 0)
				end

				local targetCameraCFrame =
					CFrame.lookAt(characterCFrame.Position + offset, target.AimingPart.CFrame.Position)

				-- Smooth the camera transition
				lastCameraCFrame = lastCameraCFrame:Lerp(targetCameraCFrame, LERP_SPEED)
				camera.CFrame = lastCameraCFrame
			end
		end)

		-- If the target dies or leaves the game, stop following the target
		local targetLeftConnection = nil
		targetLeftConnection = target.PlayerObject.Character.Humanoid.AncestryChanged:Connect(function()
			print("Target left the game")
			CM:CameraStopFollow(camera)
			targetLeftConnection:Disconnect()
		end)
	end
end

--- Stop following the target
---@param camera Camera The camera to stop following the target.
function CM:CameraStopFollow(camera)
	if RunService:IsServer() then
		warn("CameraLockOn:CameraStopFollow() - Server is not supported")
		return
	end
	if not camera then
		warn("CameraLockOn:CameraStopFollow() - Camera is nil")
		return
	end

	camera.CameraType = Enum.CameraType.Custom

	if cameraFollowConnection then
		cameraFollowConnection:Disconnect()
		cameraFollowConnection = nil
	end

	if currentTargetIndicator then
		currentTargetIndicator:Destroy()
		currentTargetIndicator = nil
	end
end

--[[
	Event connections
	Conventional order: Remote events -> Bindable events -> Remote functions -> Bindable functions
]]

--[[
	Code execution
]]
return CM
