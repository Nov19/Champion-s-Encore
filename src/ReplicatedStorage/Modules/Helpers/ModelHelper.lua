--[[
    Services
    Naming convention: Ser_???
]]

--[[
    Modules
    Naming convention: ???Module
]]
local MH = {}

--[[
    Tables
    Naming convention: Tab_???
]]

--[[
    References & Parameters
]]
local RunService = game:GetService("RunService")

--[[
    Functions
]]

--- Check if the recived player's character is jumping or falling
---@param char Model A player's character
---@return boolean _ True if the player is not stading on a solid ground, otherwise, return false.
function MH.IsCharacterFloating(char)
	if not char then
		warn("Received character is nil!")
		return -- Return when an invalid input is received.
	end

	local humanoid = char.Humanoid
	if not humanoid then
		warn("No humanoid found in the character model!")
	end

	local state = humanoid:GetState()

	return (state == Enum.HumanoidStateType.Jumping) or (state == Enum.HumanoidStateType.Freefall)
end

--- Teleports a model to a specified position.
--- This function checks if the model has a PrimaryPart and then attempts to teleport it to the specified position.
--- The position can be specified as either a Vector3 or a CFrame.
--- If the position is not a Vector3 or CFrame, a warning is logged and the function returns without teleporting the model.
---@param model Model The model to be move
---@param pos any CFrame, Vector3
function MH.TPWithPos(model, pos)
	-- Check if the model has a PrimaryPart
	if not model.PrimaryPart then
		warn("No primary part found!")
		return
	end

	-- Get the original CFrame of the PrimaryPart
	local originalCFrame = model.PrimaryPart.CFrame

	-- Determine the new position
	local newPosition
	if typeof(pos) == "CFrame" then
		newPosition = pos.Position
	elseif typeof(pos) == "Vector3" then
		newPosition = pos
	else
		warn("TPWithPos: pos must be a Vector3 or CFrame")
		return
	end

	newPosition = newPosition + Vector3.new(0, 6, 0)

	-- Construct a new CFrame with the new position and original rotation
	local newCFrame = CFrame.new(newPosition) * (originalCFrame - originalCFrame.Position)

	-- Teleport the model to the specified position, preserving rotation
	model:PivotTo(newCFrame)
end

--- This function returns the orientation of a given CFrame.
--- The orientation is a table with keys x, y, and z, each representing a rotation in radians.
---@param cFrame CFrame The CFrame to get the orientation from.
---@return table _ The orientation of the CFrame.
function MH.GetOrientation(cFrame)
	local orientation = {}

	local x, y, z = cFrame:ToOrientation()
	orientation.X = x
	orientation.Y = y
	orientation.Z = z

	return orientation
end

--- This method returns the corrseaponding humanoid for the passed player
---@param player Player | Instance The player object or player model
---@return Instance | nil _ If the player does have a character and the humanoid does exist, return the humanoid, otherwise, return nil
function MH.GetPlayerHumanoid(player)
	if not player then
		warn("Received player is nil!")
		return
	end
	if player:IsA("Player") then
		local humanoid = player.Character and player.Character:FindFirstChild("Humanoid")
		if not humanoid then
			warn("No humanoid found in the player's character (Player object received) !")
			return nil
		end

		return humanoid
	elseif player:IsA("Model") then
		local humanoid = player:FindFirstChild("Humanoid")
		if not humanoid then
			warn("No humanoid found in the player's character (Model received) !")
			return nil
		end
		return humanoid
	end
end

--- Apply anti-gravity to a character for a specified duration.
---@param character Model The character model to apply anti-gravity to.
---@param duration number The duration of the anti-gravity effect in seconds.
---@param delay number? The delay before the anti-gravity effect starts in seconds.
---@param strength number? The strength of the anti-gravity effect (0.0 = no effect, 1.0 = full anti-gravity, 0.5 = half gravity, etc.)
function MH.ApplyAntiGravity(character, duration, delay, strength)
    delay = delay or 0
    strength = math.clamp(strength or 1, 0, 1)
    if not character or not character.PrimaryPart then return end

    task.delay(delay, function()
        local rootPart = character.PrimaryPart
        if not rootPart then return end

		local force = rootPart:FindFirstChild("AntiGravityForce")
        if not force then
			-- Create a VectorForce to counteract gravity based on strength parameter
			force = Instance.new("VectorForce")
			force.Force = Vector3.new(0, workspace.Gravity * rootPart.AssemblyMass * strength, 0)
			force.Attachment0 = Instance.new("Attachment")
			force.Attachment0.Parent = rootPart
			force.RelativeTo = Enum.ActuatorRelativeTo.World
			force.Parent = rootPart
			force.Name = "AntiGravityForce" 
		else
			force.Force = Vector3.new(0, workspace.Gravity * rootPart.AssemblyMass * strength, 0)
        end

        -- Destroy the force after the duration
		force.Enabled = true
        task.wait(duration)
        force.Enabled = false
    end)
end

--- Make a CFrame from a position and rotation
---@param position Vector3 The position of the CFrame
---@param rotation Vector3 The rotation of the CFrame
---@return CFrame cFrame
function MH.MakeCFrame(position, rotation)
	return CFrame.new(position) * CFrame.Angles(rotation.X, rotation.Y, rotation.Z)
end

--- 把一个模型附加到角色身上（使用 WeldConstraint）
---@param model Model 要附加的模型（必须有 PrimaryPart）
---@param character Model 玩家角色
---@param offset CFrame 附加的相对位置（相对 HumanoidRootPart）
---@param duration number 附加持续时长，单位秒
function MH.AttachModelToCharacter(model, character, offset, duration)
    if not (model and model.PrimaryPart) then
        warn("AttachModelToCharacter: model 没有 PrimaryPart")
        return
    end

    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
    if not rootPart then
        warn("AttachModelToCharacter: 角色没有 HumanoidRootPart")
        return
    end

    -- 把模型放到指定的相对位置
    local spawnCFrame = rootPart.CFrame * offset
    model:PivotTo(spawnCFrame)

    -- 用 WeldConstraint 绑定
    local weld = Instance.new("WeldConstraint")
    weld.Part0 = model.PrimaryPart
    weld.Part1 = rootPart
    weld.Parent = model.PrimaryPart

    -- 延迟清理
    task.delay(duration, function()
		weld:Destroy()
    end)
end

--[[
    Event connections
    Conventional order: Remote events -> Bindable events -> Remote functions -> Bindable functions
]]

--[[
    Code execution
]]
return MH
