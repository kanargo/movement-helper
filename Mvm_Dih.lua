local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local Mouse = LocalPlayer:GetMouse()

if not cloneref then getgenv().cloneref = function(instance) return instance end end

local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

local Options = Library.Options
local Toggles = Library.Toggles

Library.ForceCheckbox = false
Library.ShowToggleFrameInKeybinds = true

local Window = Library:CreateWindow({
    Title = "Movement-Dih",
    Footer = "version : beta_V1",
    NotifySide = "Right",
    ShowCustomCursor = false,
})

local currentSettings = {
    Speed = 1500,
    JumpPowerValue = 3.5,
    JumpCap = 1,
    AirStrafeAcceleration = 187
}

getgenv().bhopHoldSystemEnabled = false
getgenv().bhopHoldActive = false        
getgenv().bhopMode = "Acceleration"
getgenv().bhopAccelValue = -0.5

local frictionTables = {}
local CurrentJumpCount = 0
local LastJump = 0
local maxJumpsValue = math.huge

local turnbindEnabled = false
local turnbindLeftKey = "A"   
local turnbindRightKey = "D"  

local autoBounceEnabled = false
local autoBounceKeybind = "B"
local bouncePowerValue = 50
local bounceDebounce = false
local bounceConnection = nil

local cosmetic1, cosmetic2 = "", ""
local isSwapped = false
local originalCosmetic1, originalCosmetic2 = "", ""

local headlessEnabled = false
local korbloxEnabled = false

local HEADLESS_MESH_ID = "rbxassetid://1095708"
local KORBLOX_MESH_ID = "rbxassetid://101851696"
local KORBLOX_TEXTURE_ID = "rbxassetid://101851254"

local CACTUS_WIDTH  = 5.0  
local CACTUS_HEIGHT = 2.0  
local CACTUS_LENGTH = 5.0  
local HITBOX_SIZE = Vector3.new(CACTUS_WIDTH, CACTUS_HEIGHT, CACTUS_LENGTH)
local HITBOX_TRANSPARERECY = 1 
local HITBOX_COLOR = Color3.fromRGB(0, 255, 255) 
local NO_FRICTION_PHYSICS = PhysicalProperties.new(0.7, 0, 1, 0, 1)

local customHitboxEnabled = false
local customHitboxWidth = 5
local customHitboxHeight = 5
local customHitboxLength = 5
local customHitboxColor = Color3.fromRGB(255, 0, 0)
local customHitboxTransparency = 0.5
local CustomHitboxFolder = Instance.new("Folder")
CustomHitboxFolder.Name = "ArgoHub_CustomHitboxes"
CustomHitboxFolder.Parent = workspace

local currentEmotes = {} 
local selectEmotes = {}  
local emoteEnabled = {}

for i = 1, 12 do 
    currentEmotes[i] = ""
    selectEmotes[i] = ""
    emoteEnabled[i] = false 
end

local Events = ReplicatedStorage:WaitForChild("Events", 10)
local CharacterFolder = Events and Events:WaitForChild("Character", 10)
local EmoteRemote = CharacterFolder and CharacterFolder:WaitForChild("Emote", 10)
local PassCharacterInfo = CharacterFolder and CharacterFolder:WaitForChild("PassCharacterInfo", 10)
local remoteSignal = PassCharacterInfo and PassCharacterInfo.OnClientEvent
local currentTag = nil
local pendingSlot = nil
local blockOriginalEmote = false

local auraColor = Color3.fromRGB(255, 0, 0)
local autoApplyAuraColor = false

local wallClimbEnabled = false
local wallClimbKeybind = "H"
local wallClimbMode = "Hold"
_G.IsHoldingH = false
local currentLockedY = 0

local RunningConnections = {}
local function SafeConnect(signal, callback)
    local conn = signal:Connect(callback)
    table.insert(RunningConnections, conn)
    return conn
end

local function parseKeyCode(key)
    if typeof(key) == "EnumItem" then return key end
    if type(key) == "string" then
        local success, result = pcall(function() return Enum.KeyCode[key] end)
        if success then return result end
    end
    return nil
end

local RealSpeed = 1500
local JumpHeight = 3
local AirStrafeAcceleration = 187
local jumpcap = 1
local SpringSpeedMultiplier = 1
local AirAcceleration = 1

local autoJumpEnabled = false
local bhopHoldFeature = false
local bhopHoldActive = false
local jumpCooldown = 0.05
local autoJumpType = "Bounce"
local accelerationMethod = "Acceleration"
local groundFriction = -0.5
local AutoAccelerationEnabled = false
local MaxSpeed = 70
local MaxAcceleration = 3
local MinAcceleration = -1

local bhopLoaded = false
local movementModule = nil
local originalApplyFriction = nil
local bhopConnection = nil

local function IsOnGround()
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not char or not hrp or not hum then return false end
    local success, result = pcall(function()
        local state = hum:GetState()
        if state == Enum.HumanoidStateType.Jumping or state == Enum.HumanoidStateType.Freefall or state == Enum.HumanoidStateType.Swimming then
            return false
        end
        local raycastParams = RaycastParams.new()
        raycastParams.FilterType = Enum.RaycastFilterType.Exclude
        raycastParams.FilterDescendantsInstances = {char}
        local raycastResult = Workspace:Raycast(hrp.Position, Vector3.new(0, -3.5, 0), raycastParams)
        if not raycastResult then return false end
        return true
    end)
    return success and result
end

local function updateBhop()
    if not bhopLoaded then return end
    pcall(function()
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if not char or not hum then return end
        local isBhopActive = autoJumpEnabled or bhopHoldActive
        if isBhopActive then
            local now = tick()
            if IsOnGround() and (now - LastJump) > jumpCooldown then
                LastJump = now
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end)
end

local function checkBhopState()
    if autoJumpEnabled or bhopHoldActive then
        if not bhopLoaded then
            bhopLoaded = true
            if bhopConnection then bhopConnection:Disconnect() end
            bhopConnection = RunService.Heartbeat:Connect(updateBhop)
        end
    else
        if bhopLoaded then
            bhopLoaded = false
            if bhopConnection then bhopConnection:Disconnect(); bhopConnection = nil end
        end
        bhopHoldActive = false
    end
end

local function getCurrentSpeed()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then return (hrp.Velocity * Vector3.new(1, 0, 1)).Magnitude end
    return 0
end

local function reapplyModifications()
    if not movementModule then return end
    if not originalApplyFriction then originalApplyFriction = movementModule.ApplyFriction end
    
    local isBhopActive = autoJumpEnabled or bhopHoldActive
    if isBhopActive then
        movementModule.ApplyFriction = function(self, frictionAmount)
            local isGrounded = self.a == true
            if isGrounded then
                if accelerationMethod == "No Acceleration" then
                    frictionAmount = 0
                elseif accelerationMethod == "Ground Acceleration" or accelerationMethod == "Acceleration" then
                    local finalFriction = groundFriction
                    if AutoAccelerationEnabled then
                        local currentSpeed = getCurrentSpeed()
                        if currentSpeed > MaxSpeed then 
                            finalFriction = MaxAcceleration
                        else 
                            finalFriction = MinAcceleration 
                        end
                    end
                    frictionAmount = finalFriction
                end
            end
            return originalApplyFriction(self, frictionAmount)
        end
    else
        movementModule.ApplyFriction = originalApplyFriction
    end
end

local function setupLegacyCharacter(character)
    local movement = character:WaitForChild("Movement", 10)
    if movement and movement:IsA("ModuleScript") then
        pcall(function()
            local module = require(movement)
            movementModule = module
            reapplyModifications()
            
            local originalUpdate = module.Update
            module.Update = function(self, dt)
                local originalSpeed = self.j
                self.j = RealSpeed * SpringSpeedMultiplier
                
                local originalAirMove = self.AirMove
                self.AirMove = function(airSelf, ...)
                    local originalAccelerate = airSelf.Accelerate
                    airSelf.Accelerate = function(accSelf, direction, targetSpeed, acceleration)
                        targetSpeed = targetSpeed * AirAcceleration
                        return originalAccelerate(accSelf, direction, targetSpeed, acceleration)
                    end
                    originalAirMove(airSelf, ...)
                    airSelf.Accelerate = originalAccelerate
                end
                
                originalUpdate(self, dt)
                self.AirMove = originalAirMove
                self.j = originalSpeed
            end
        end)
    end
    
    task.spawn(function()
        pcall(function()
            local playerFolder = Workspace:WaitForChild("Game"):WaitForChild("Players"):WaitForChild(LocalPlayer.Name)
            local movePath = playerFolder:WaitForChild("Movement")
            local moveMod = require(movePath)
            local oldAirMove = moveMod.AirMove
            moveMod.AirMove = function(self)
                oldAirMove(self)
                if self.f.a == 0 and self.f.b ~= 0 then
                    local v1 = LocalPlayer.PlayerScripts.CameraCFrame.Value:VectorToWorldSpace(Vector3.new(self.f.b, 0, self.f.a))
                    local v2 = Vector3.new(v1.X, 0, v1.Z)
                    local v4 = (v2 == Vector3.new(0, 0, 0)) and v2 or v2.Unit
                    self:Accelerate(v4, AirStrafeAcceleration, AirStrafeAcceleration)
                end
            end
        end)
    end)
    
    local hum = character:WaitForChild("Humanoid")
    hum.JumpHeight = JumpHeight
    
    local jumps = 0
    local jumpTick = tick()
    SafeConnect(hum.StateChanged, function(old, new)
        if new == Enum.HumanoidStateType.Landed then jumps = 0 end
    end)
    SafeConnect(UserInputService.JumpRequest, function()
        if jumps < jumpcap and tick() - jumpTick > 0.05 then
            jumpTick = tick()
            jumps = jumps + 1
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end)
    
    checkBhopState()
end

local function createHitboxOnTop(cactus)
    if cactus:FindFirstChild("HasBhopHitbox") then return end
    
    local cframe, size
    if cactus:IsA("Model") then
        cframe, size = cactus:GetBoundingBox()
    elseif cactus:IsA("BasePart") then
        cframe, size = cactus.CFrame, cactus.Size
    else
        local primary = cactus:FindFirstChildWhichIsA("BasePart", true)
        if primary then
            cframe, size = primary.CFrame, primary.Size
        else
            return
        end
    end
    
    local spawnPosition = cframe.Position + Vector3.new(0, size.Y / 2, 0)
    
    local hitbox = Instance.new("Part")
    hitbox.Name = "BhopHitbox_Cactus"
    hitbox.Size = HITBOX_SIZE
    hitbox.CFrame = CFrame.new(spawnPosition + Vector3.new(0, CACTUS_HEIGHT / 2, 0))
    hitbox.Transparency = HITBOX_TRANSPARERECY
    hitbox.Color = HITBOX_COLOR
    hitbox.Material = Enum.Material.Neon
    hitbox.Anchored = true
    hitbox.CanCollide = true
    hitbox.CustomPhysicalProperties = NO_FRICTION_PHYSICS
    
    local tag = Instance.new("BoolValue", cactus)
    tag.Name = "HasBhopHitbox"
    
    hitbox.Parent = workspace
end

local function forceScanCactus()
    local count = 0
    for _, obj in ipairs(workspace:GetDescendants()) do
        local objName = string.lower(obj.Name)
        if string.find(objName, "cactus1") or string.find(objName, "cactus2") then
            if not obj:FindFirstChild("HasBhopHitbox") then
                count = count + 1
                task.spawn(function()
                    createHitboxOnTop(obj)
                end)
            end
        end
    end
    return count
end

local function getMatchingTables()
    local matched = {}
    local requiredFields = {Friction = true, AirStrafeAcceleration = true, JumpHeight = true, Speed = true, WalkSpeedMultiplier = true}
    for _, obj in pairs(getgc(true)) do
        if typeof(obj) == "table" then
            local ok = true
            for field in pairs(requiredFields) do
                if rawget(obj, field) == nil then ok = false; break end
            end
            if ok then table.insert(matched, obj) end
        end
    end
    return matched
end

local function applyMovementSettings()
    local targets = getMatchingTables()
    for _, tbl in ipairs(targets) do
        pcall(function()
            tbl.Speed = currentSettings.Speed
            tbl.JumpCap = currentSettings.JumpCap
            tbl.AirStrafeAcceleration = currentSettings.AirStrafeAcceleration
        end)
    end
end

local function isCharacterGrounded(char, hrp, hum)
    if hum:GetState() == Enum.HumanoidStateType.Running then return true end
    if table.find({Enum.HumanoidStateType.Jumping, Enum.HumanoidStateType.Freefall, Enum.HumanoidStateType.Swimming}, hum:GetState()) then return false end
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    raycastParams.FilterDescendantsInstances = {char}
    local result = Workspace:Raycast(hrp.Position, Vector3.new(0, -4, 0), raycastParams)
    return result ~= nil
end

function applyBhopFriction(forceReset)
    if #frictionTables == 0 then
        for _, obj in pairs(getgc(true)) do
            if type(obj) == "table" and rawget(obj, "Friction") then
                table.insert(frictionTables, {obj = obj, original = obj.Friction})
            end
        end
    end
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local grounded = (char and hum and hrp) and isCharacterGrounded(char, hrp, hum)
    local isActive = getgenv().bhopHoldSystemEnabled and getgenv().bhopHoldActive and grounded and not forceReset
    for _, tableData in ipairs(frictionTables) do
        if tableData.obj and type(tableData.obj) == "table" then
            pcall(function() 
                local isAccel = (isActive and getgenv().bhopMode == "Acceleration")
                tableData.obj.Friction = isAccel and getgenv().bhopAccelValue or tableData.original 
            end)
        end
    end
end

local function sendKeyEvent(keyCode, isDown)
    pcall(function()
        VirtualInputManager:SendKeyEvent(isDown, keyCode, false, game)
    end)
end

local function onBouncePostSimulation()
    if not autoBounceEnabled or bounceDebounce then return end
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    
    if hum and hrp and hum.Health > 0 then
        if hum.FloorMaterial ~= Enum.Material.Air then
            bounceDebounce = true
            task.wait(0.02)
            if hrp and hum and hum.FloorMaterial ~= Enum.Material.Air then
                hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, bouncePowerValue, hrp.AssemblyLinearVelocity.Z)
            end
            task.wait(0.1)
            bounceDebounce = false
        end
    end
end

function toggleAutoBounce(state)
    autoBounceEnabled = state
    if state then
        if bounceConnection then bounceConnection:Disconnect() end
        bounceConnection = RunService.PostSimulation:Connect(onBouncePostSimulation)
    else
        if bounceConnection then bounceConnection:Disconnect(); bounceConnection = nil end
        bounceDebounce = false
    end
end

local function checkNearWall()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    raycastParams.FilterDescendantsInstances = {char, Workspace:FindFirstChild("Game") and Workspace.Game:FindFirstChild("Effects")}
    local directions = {hrp.CFrame.LookVector * 3.5, -hrp.CFrame.LookVector * 3.5, hrp.CFrame.RightVector * 3.5, -hrp.CFrame.RightVector * 3.5}
    for _, dir in ipairs(directions) do
        local result = Workspace:Raycast(hrp.Position, dir, raycastParams)
        if result and result.Instance and result.Instance.CanCollide == true then return true end
    end
    return false
end

local function onWallClimbRenderStepped()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if _G.IsHoldingH and hrp and hum then
        if checkNearWall() then
            local currentPos = hrp.Position
            hrp.CFrame = CFrame.new(currentPos.X, currentLockedY, currentPos.Z) * hrp.CFrame.Rotation
            hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, 0, hrp.AssemblyLinearVelocity.Z)
            hum:ChangeState(Enum.HumanoidStateType.Physics)
        else
            _G.IsHoldingH = false
            if _G.WallClimbConnection then _G.WallClimbConnection:Disconnect(); _G.WallClimbConnection = nil end
            hum:ChangeState(Enum.HumanoidStateType.GettingUp)
        end
    end
end

local function startWallHold()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp and checkNearWall() then
        _G.IsHoldingH = true
        currentLockedY = hrp.Position.Y
        if not _G.WallClimbConnection then _G.WallClimbConnection = RunService.RenderStepped:Connect(onWallClimbRenderStepped) end
    end
end

local function stopWallHold()
    _G.IsHoldingH = false
    if _G.WallClimbConnection then _G.WallClimbConnection:Disconnect(); _G.WallClimbConnection = nil end
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then hum:ChangeState(Enum.HumanoidStateType.GettingUp) end
end

local function applyCosmetics()
    if cosmetic1 == "" or cosmetic2 == "" or cosmetic1 == cosmetic2 then return end
    pcall(function()
        local Cosmetics = ReplicatedStorage:WaitForChild("Items"):WaitForChild("Cosmetics")
        local a, b = Cosmetics:FindFirstChild(cosmetic1), Cosmetics:FindFirstChild(cosmetic2)
        if not a or not b then return end
        if not isSwapped then originalCosmetic1, originalCosmetic2 = cosmetic1, cosmetic2 end
        local tempRoot = Instance.new("Folder", Cosmetics)
        local tempA = Instance.new("Folder", tempRoot)
        local tempB = Instance.new("Folder", tempRoot)
        for _, c in ipairs(a:GetChildren()) do c.Parent = tempA end
        for _, c in ipairs(b:GetChildren()) do c.Parent = tempB end
        for _, c in ipairs(tempA:GetChildren()) do c.Parent = b end
        for _, c in ipairs(tempB:GetChildren()) do c.Parent = a end
        tempRoot:Destroy()
        isSwapped = true
    end)
end

local function resetCosmetics()
    if not isSwapped or originalCosmetic1 == "" or originalCosmetic2 == "" then return end
    pcall(function()
        local Cosmetics = ReplicatedStorage:WaitForChild("Items"):WaitForChild("Cosmetics")
        local a, b = Cosmetics:FindFirstChild(originalCosmetic1), Cosmetics:FindFirstChild(originalCosmetic2)
        if a and b then
            local tempRoot = Instance.new("Folder", Cosmetics)
            local tempA = Instance.new("Folder", tempRoot)
            local tempB = Instance.new("Folder", tempRoot)
            for _, c in ipairs(a:GetChildren()) do c.Parent = tempA end
            for _, c in ipairs(b:GetChildren()) do c.Parent = tempB end
            for _, c in ipairs(tempA:GetChildren()) do c.Parent = b end
            for _, c in ipairs(tempB:GetChildren()) do c.Parent = a end
            tempRoot:Destroy()
        end
        isSwapped = false
        cosmetic1, cosmetic2 = "", ""
    end)
end

local function applyAuraColorEffect()
    local char = LocalPlayer.Character
    if not char then return end
    for _, obj in ipairs(char:GetDescendants()) do
        if obj:IsA("ParticleEmitter") or obj:IsA("Trail") then
            obj.Color = ColorSequence.new(auraColor)
        elseif obj:IsA("Highlight") then
            obj.FillColor = auraColor
            obj.OutlineColor = auraColor
        end
    end
end

local function applyHeadless(character)
    if not headlessEnabled or not character then return end
    local head = character:FindFirstChild("Head")
    if not head then return end

    head.Transparency = 1
    head.CanCollide = false

    local face = head:FindFirstChildOfClass("Decal")
    if face then face:Destroy() end

    for _, v in ipairs(head:GetChildren()) do
        if v:IsA("SpecialMesh") or v:IsA("CharacterMesh") then
            v:Destroy()
        end
    end

    local mesh = Instance.new("SpecialMesh")
    mesh.MeshType = Enum.MeshType.FileMesh
    mesh.MeshId = HEADLESS_MESH_ID
    mesh.Scale = Vector3.new(0.001, 0.001, 0.001)
    mesh.Parent = head
end

local function applyKorblox(character)
    if not korbloxEnabled or not character then return end
    local rightLeg = character:FindFirstChild("Right Leg")
    if not rightLeg then return end

    for _, v in ipairs(rightLeg:GetChildren()) do
        if v:IsA("SpecialMesh") or v:IsA("CharacterMesh") then
            v:Destroy()
        end
    end

    local mesh = Instance.new("SpecialMesh")
    mesh.MeshType = Enum.MeshType.FileMesh
    mesh.MeshId = KORBLOX_MESH_ID
    mesh.TextureId = KORBLOX_TEXTURE_ID
    mesh.Scale = Vector3.new(1, 1, 1)
    mesh.Parent = rightLeg
end

local function fireSelectEmote(slot)
    if not currentTag or not selectEmotes[slot] or selectEmotes[slot] == "" then return end
    local tagNumber = tonumber(currentTag)
    if not tagNumber or tagNumber < 0 or tagNumber > 255 then return end
    if remoteSignal then
        pcall(function()
            local buf = buffer.create(2)
            buffer.writeu8(buf, 0, tagNumber)
            buffer.writeu8(buf, 1, 17)
            firesignal(remoteSignal, buf, {selectEmotes[slot]})
        end)
    end
end

local function onRespawnTagCheck()
    currentTag = nil; pendingSlot = nil
    task.spawn(function()
        local startTime = tick()
        while tick() - startTime < 10 do
            if Workspace:FindFirstChild("Game") and Workspace.Game:FindFirstChild("Players") then
                local playerFolder = Workspace.Game.Players:FindFirstChild(LocalPlayer.Name)
                if playerFolder then
                    local tagAttr = playerFolder:GetAttribute("Tag") or (playerFolder:FindFirstChild("Tag") and playerFolder.Tag.Value)
                    if tagAttr then
                        local tagNum = tonumber(tagAttr); if tagNum and tagNum >= 0 and tagNum <= 255 then currentTag = tagAttr; break end
                    end
                end
            end
            task.wait(0.5)
        end
    end)
end

if PassCharacterInfo and EmoteRemote then
    SafeConnect(PassCharacterInfo.OnClientEvent, function(...)
        if not pendingSlot then return end
        local slot = pendingSlot; pendingSlot = nil
        task.wait(0.1); fireSelectEmote(slot)
    end)
    local oldNamecall
    oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        local methodName = getnamecallmethod()
        local args = {...}
        if methodName == "FireServer" and self == EmoteRemote and type(args[1]) == "string" then
            for i = 1, 12 do
                if emoteEnabled[i] and currentEmotes[i] ~= "" and args[1]:gsub("%s+", ""):lower() == currentEmotes[i]:lower() then
                    pendingSlot = i; blockOriginalEmote = true
                    task.spawn(function() task.wait(0.1); blockOriginalEmote = false; if pendingSlot == i then pendingSlot = nil; fireSelectEmote(i) end end)
                    if blockOriginalEmote then return nil end
                end
            end
        end
        return oldNamecall(self, ...)
    end)
end

local Tabs = {
    Movement = Window:AddTab("Movement Physics", "user"),
    Legacy   = Window:AddTab("Legacy", "history"),
    Hitbox   = Window:AddTab("Hitbox Creator", "box"),
    Visuals  = Window:AddTab("Visuals", "eye"),
    Settings = Window:AddTab("System Settings", "settings")
}

local MoveGroup1 = Tabs.Movement:AddLeftGroupbox("Player Modification Settings")

MoveGroup1:AddInput("PlayerSpeedModifier", {
    Default = "1500", Text = "Player Speed Modifier", Placeholder = "Default: 1500", Numeric = true,
    Callback = function(value) local val = tonumber(value) if val then currentSettings.Speed = val; applyMovementSettings() end end
})
MoveGroup1:AddInput("PlayerJumpHeightPower", {
    Default = "3.5", Text = "Player Jump Height Power", Placeholder = "Default: 3.5", Numeric = true,
    Callback = function(value) if tonumber(value) then currentSettings.JumpPowerValue = tonumber(value) end end
})
MoveGroup1:AddInput("PlayerJumpCapMultiplier", {
    Default = "1", Text = "Player Jump Cap Multiplier", Placeholder = "Default: 1", Numeric = true,
    Callback = function(value) local val = tonumber(value) if val then currentSettings.JumpCap = val; applyMovementSettings() end end
})
MoveGroup1:AddInput("AirStrafeAcceleration", {
    Default = "187", Text = "Air Strafe Acceleration", Placeholder = "Default: 187", Numeric = true,
    Callback = function(value) local val = tonumber(value) if val then currentSettings.AirStrafeAcceleration = val; applyMovementSettings() end end
})

local MoveGroup2 = Tabs.Movement:AddLeftGroupbox("Bhop")
MoveGroup2:AddToggle("EnableBhopSystem", {
    Text = "Enable Bhop System (Hold Space)", Default = false,
    Callback = function(state) getgenv().bhopHoldSystemEnabled = state if not state then getgenv().bhopHoldActive = false end applyBhopFriction(not state) end
})

local MoveGroup3 = Tabs.Movement:AddRightGroupbox("Wall Cling Modifier")
MoveGroup3:AddToggle("EnableWallClingFunction", {
    Text = "Enable Wall Cling Function", Default = false,
    Callback = function(state) wallClimbEnabled = state if not state then stopWallHold() end end
})
MoveGroup3:AddDropdown("ActivationTriggerMode", {
    Values = { "Hold", "Toggle" }, Default = "Hold", Text = "Activation Trigger Mode",
    Callback = function(value) wallClimbMode = value stopWallHold() end
})
MoveGroup3:AddLabel("Wall Activation KeyBind"):AddKeyPicker("WallClimbKeybindPicker", {
    Default = "H", SyncToggleState = false, Mode = "Toggle", Text = "Wall Activation Key",
    ChangedCallback = function(key) wallClimbKeybind = key.Name end
})

local MoveGroup4 = Tabs.Movement:AddRightGroupbox("Auto Bounce Velocity")
MoveGroup4:AddToggle("EnableAutoBounceLoop", {
    Text = "Enable Auto Bounce Loop", Default = false,
    Callback = function(state) toggleAutoBounce(state) end
})
MoveGroup4:AddLabel("Auto Bounce Switch Key"):AddKeyPicker("AutoBounceKeybindPicker", {
    Default = "B", SyncToggleState = false, Mode = "Toggle", Text = "Auto Bounce Switch Key",
    ChangedCallback = function(key) autoBounceKeybind = key.Name end
})
MoveGroup4:AddSlider("BounceForceVelocity", {
    Text = "Bounce Force Velocity", Min = 10, Max = 150, Default = 50, Rounding = 0,
    Callback = function(value) bouncePowerValue = value end
})

local MoveGroup5 = Tabs.Movement:AddRightGroupbox("Turnbind Engineering")
MoveGroup5:AddToggle("EnableTurnbindModifier", {
    Text = "Enable Turnbind Modifier", Default = false,
    Callback = function(state) turnbindEnabled = state end
})
MoveGroup5:AddInput("LeftTurnKeyBinding", {
    Default = "A", Text = "Left Turn Key Binding", Placeholder = "A",
    Callback = function(v) turnbindLeftKey = v:upper() end
})
MoveGroup5:AddInput("RightTurnKeyBinding", {
    Default = "D", Text = "Right Turn Key Binding", Placeholder = "D",
    Callback = function(v) turnbindRightKey = v:upper() end
})

local LegacyGroup1 = Tabs.Legacy:AddLeftGroupbox("Legacy Player Modification")
LegacyGroup1:AddInput("RealSpeedMultiplier", {
    Default = "1500", Text = "Real Speed Multiplier", Placeholder = "Default: 1500", Numeric = true,
    Callback = function(value) local n = tonumber(value) if n then RealSpeed = n end end
})
LegacyGroup1:AddInput("LegacyJumpHeight", {
    Default = "3", Text = "Legacy Jump Height", Placeholder = "Default: 3", Numeric = true,
    Callback = function(value) local n = tonumber(value) if n then JumpHeight = n local char = LocalPlayer.Character local hum = char and char:FindFirstChildOfClass("Humanoid") if hum then hum.JumpHeight = n end end end
})
LegacyGroup1:AddInput("AirStrafeAccelerationLegacy", {
    Default = "187", Text = "Air Strafe Acceleration", Placeholder = "Default: 187", Numeric = true,
    Callback = function(value) local n = tonumber(value) if n then AirStrafeAcceleration = n end end
})

local LegacyGroup2 = Tabs.Legacy:AddLeftGroupbox("Legacy Bhop")
LegacyGroup2:AddToggle("EnableBhopAutoJump", {
    Text = "Enable Bhop (Auto Jump)", Default = false,
    Callback = function(state) autoJumpEnabled = state checkBhopState() reapplyModifications() end
})
LegacyGroup2:AddToggle("BhopKeyHoldingSpace", {
    Text = "Bhop Key Holding (Space / Mobile Jump)", Default = false,
    Callback = function(state) bhopHoldFeature = state if not state then bhopHoldActive = false checkBhopState() reapplyModifications() end end
})
LegacyGroup2:AddDropdown("BhopModeDropdown", {
    Values = {"No Acceleration", "Ground Acceleration", "Acceleration"}, Default = "Acceleration", Text = "Bhop Mode",
    Callback = function(value) accelerationMethod = value reapplyModifications() end
})
LegacyGroup2:AddInput("BhopAccelerationInput", {
    Default = "-0.5", Text = "Bhop Acceleration (Negative Value Only)", Placeholder = "-0.5",
    Callback = function(value) local n = tonumber(value) if n then groundFriction = n reapplyModifications() end end
})

local LegacyGroup3 = Tabs.Legacy:AddRightGroupbox("Legacy Auto Acceleration")
LegacyGroup3:AddToggle("EnableAutoAccelerationLegit", {
    Text = "Enable Auto Acceleration (Legit)", Default = false,
    Callback = function(state) AutoAccelerationEnabled = state reapplyModifications() end
})

local LegacyGroup4 = Tabs.Legacy:AddRightGroupbox("Legacy Exploits & Utilities")
LegacyGroup4:AddButton({
    Text = "Scan & Apply Cactus Hitbox", DoubleClick = false,
    Func = function() forceScanCactus() end
})

local HitboxGroup1 = Tabs.Hitbox:AddLeftGroupbox("Mouse Target Hitbox Settings")
HitboxGroup1:AddToggle("EnableCustomHitboxCreation", {
    Text = "Enable Custom Hitbox Creation", Default = false,
    Callback = function(state) customHitboxEnabled = state end
})
HitboxGroup1:AddButton({
    Text = "Clear All Created Hitboxes", DoubleClick = false,
    Func = function() CustomHitboxFolder:ClearAllChildren() end
})

local HitboxGroup2 = Tabs.Hitbox:AddLeftGroupbox("Hitbox Dimensions")
HitboxGroup2:AddSlider("HitboxWidth", { Text = "Hitbox Width", Min = 1, Max = 6, Default = 4, Rounding = 1, Callback = function(value) customHitboxWidth = value end })
HitboxGroup2:AddSlider("HitboxHeight", { Text = "Hitbox Height", Min = 1, Max = 6, Default = 4, Rounding = 1, Callback = function(value) customHitboxHeight = value end })
HitboxGroup2:AddSlider("HitboxLength", { Text = "Hitbox Length", Min = 1, Max = 6, Default = 4, Rounding = 1, Callback = function(value) customHitboxLength = value end })

local HitboxGroup3 = Tabs.Hitbox:AddRightGroupbox("Hitbox Styling")
HitboxGroup3:AddLabel("Select Hitbox Box Color"):AddColorPicker("HitboxColorPicker", {
    Default = Color3.fromRGB(255, 0, 0), Title = "Select Hitbox Box Color",
    Callback = function(color) customHitboxColor = color end
})
HitboxGroup3:AddSlider("HitboxTransparency", { Text = "Hitbox Transparency", Min = 0, Max = 1, Default = 0.5, Rounding = 2, Callback = function(value) customHitboxTransparency = value end })

SafeConnect(UserInputService.InputBegan, function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 and customHitboxEnabled then
        if Mouse.Target and Mouse.Hit then
            local targetObj = Mouse.Target
            if not targetObj:IsDescendantOf(CustomHitboxFolder) then
                pcall(function()
                    local exactClickPos = Mouse.Hit.Position
                    local surfaceNormal = Vector3.FromNormalId(Mouse.TargetSurface)
                    local spawnCFrame = CFrame.new(exactClickPos + (surfaceNormal * (customHitboxHeight / 2)))
                    
                    local newHitbox = Instance.new("Part")
                    newHitbox.Name = "ArgoCreated_Hitbox"
                    newHitbox.Size = Vector3.new(customHitboxWidth, customHitboxHeight, customHitboxLength)
                    newHitbox.CFrame = spawnCFrame
                    newHitbox.Transparency = customHitboxTransparency
                    newHitbox.Color = customHitboxColor
                    newHitbox.Material = Enum.Material.Neon
                    newHitbox.Anchored = true
                    newHitbox.CanCollide = true
                    newHitbox.CustomPhysicalProperties = NO_FRICTION_PHYSICS
                    newHitbox.Parent = CustomHitboxFolder
                end)
            end
        end
    end
end)

local VisualGroup1 = Tabs.Visuals:AddLeftGroupbox("Avatar Body Enhancements")
VisualGroup1:AddToggle("EnableHeadlessHead", {
    Text = "Enable Headless Head ", Default = false,
    Callback = function(state) headlessEnabled = state if state and LocalPlayer.Character then applyHeadless(LocalPlayer.Character) end end
})
VisualGroup1:AddToggle("EnableKorbloxRightLeg", {
    Text = "Enable Korblox Right Leg", Default = false,
    Callback = function(state) korbloxEnabled = state if state and LocalPlayer.Character then applyKorblox(LocalPlayer.Character) end end
})

local VisualGroup2 = Tabs.Visuals:AddLeftGroupbox("Client Cosmetic Replacer")
VisualGroup2:AddInput("CurrentOwnedItemName", { Default = "", Text = "Current Owned Item Name", Placeholder = "Owned item...", Callback = function(v) cosmetic1 = v end })
VisualGroup2:AddInput("TargetSwapItemName", { Default = "", Text = "Target Swap Item Name", Placeholder = "Desired item...", Callback = function(v) cosmetic2 = v end })
VisualGroup2:AddButton({ Text = "Execute Cosmetic Replacement (Apply)", Func = function() applyCosmetics() end })
VisualGroup2:AddButton({
    Text = "Reset Cosmetic & Restore Original ",
    Func = function()
        resetCosmetics()
        pcall(function() Options.CurrentOwnedItemName:SetValue("") end)
        pcall(function() Options.TargetSwapItemName:SetValue("") end)
    end
})

local VisualGroup3 = Tabs.Visuals:AddRightGroupbox("Aura Color ")
VisualGroup3:AddLabel("Pick Custom Aura Color"):AddColorPicker("CustomAuraColorPicker", {
    Default = Color3.fromRGB(255, 0, 0), Title = "Pick Custom Aura / Cosmetic Color",
    Callback = function(color) auraColor = color applyAuraColorEffect() end
})
VisualGroup3:AddButton({ Text = "Force Update Color Now", Func = function() applyAuraColorEffect() end })
VisualGroup3:AddToggle("AutoApplyColorsOnRespawn", { Text = "Auto Apply Colors On Respawn", Default = false, Callback = function(state) autoApplyAuraColor = state end })

local VisualGroup4 = Tabs.Visuals:AddRightGroupbox("12 Owned Emotes & 12 Target Emotes")
for i = 1, 12 do
    VisualGroup4:AddInput("EmoteSlotGoc_"..i, {
        Default = "", Text = string.format("Slot %02d [own]", i), Placeholder = "name emote...",
        Callback = function(v) currentEmotes[i] = v:gsub("%s+", "") end
    })
    VisualGroup4:AddInput("EmoteSlotTrao_"..i, {
        Default = "", Text = string.format("Slot %02d [want to swap]", i), Placeholder = "name emote swap...",
        Callback = function(v) selectEmotes[i] = v:gsub("%s+", "") end
    })
end

local VisualGroup5 = Tabs.Visuals:AddRightGroupbox("Emote Remap Action Buttons")
VisualGroup5:AddButton({
    Text = "Apply Emotes Remap System",
    Func = function()
        for i = 1, 12 do
            if currentEmotes[i] ~= "" and selectEmotes[i] ~= "" then emoteEnabled[i] = true else emoteEnabled[i] = false end
        end
    end
})
VisualGroup5:AddButton({
    Text = "Reset All Emote Slots to Default",
    Func = function()
        for i = 1, 12 do
            currentEmotes[i] = "" selectEmotes[i] = "" emoteEnabled[i] = false
            pcall(function() Options["EmoteSlotGoc_"..i]:SetValue("") end)
            pcall(function() Options["EmoteSlotTrao_"..i]:SetValue("") end)
        end
    end
})

local SettingsGroup = Tabs.Settings:AddLeftGroupbox("Menu Settings")

SettingsGroup:AddLabel("Global Menu Open/Close Shortcut"):AddKeyPicker("MenuKeybind", {
    Default = "RightControl", NoUI = true, Text = "Menu keybind"
})
Library.ToggleKeybind = Options.MenuKeybind

SettingsGroup:AddButton({
    Text = "Terminate Script & Clear Cache",
    Func = function()
        for _, conn in ipairs(RunningConnections) do if conn then conn:Disconnect() end end
        if bounceConnection then bounceConnection:Disconnect() end
        if _G.WallClimbConnection then _G.WallClimbConnection:Disconnect() end
        if bhopConnection then bhopConnection:Disconnect() end
        getgenv().bhopHoldSystemEnabled = false
        getgenv().bhopHoldActive = false
        toggleAutoBounce(false)
        customHitboxEnabled = false
        CustomHitboxFolder:Destroy()
        Library:Unload()
    end
})

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind" })

ThemeManager:SetFolder("ArgoHubConfigs")
SaveManager:SetFolder("ArgoHubConfigs/MvmDih")

SaveManager:BuildConfigSection(Tabs.Settings)
ThemeManager:ApplyToTab(Tabs.Settings)
SaveManager:LoadAutoloadConfig()

SafeConnect(RunService.RenderStepped, function() 
    if getgenv().bhopHoldSystemEnabled and getgenv().bhopHoldActive then applyBhopFriction() end 
end)

SafeConnect(RunService.Heartbeat, function()
    local isActive = getgenv().bhopHoldSystemEnabled and getgenv().bhopHoldActive
    if isActive then
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hum and hrp and hum.Health > 0 then
            local now = tick()
            if isCharacterGrounded(char, hrp, hum) and (now - LastJump) > 0.15 then
                LastJump = now 
                pcall(function() 
                    LocalPlayer.PlayerScripts.Events.temporary_events.JumpReact:Fire() 
                    LocalPlayer.PlayerScripts.Events.temporary_events.EndJump:Fire() 
                end)
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end
end)

SafeConnect(UserInputService.InputBegan, function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.Space then
        if getgenv().bhopHoldSystemEnabled then 
            getgenv().bhopHoldActive = true 
            applyBhopFriction() 
        end
        if bhopHoldFeature then
            bhopHoldActive = true
            checkBhopState()
        end
    end
    
    if turnbindEnabled then
        local leftEnum = parseKeyCode(turnbindLeftKey)
        local rightEnum = parseKeyCode(turnbindRightKey)
        
        if leftEnum and input.KeyCode == leftEnum then
            sendKeyEvent(Enum.KeyCode.Left, true)
        elseif rightEnum and input.KeyCode == rightEnum then
            sendKeyEvent(Enum.KeyCode.Right, true)
        end
    end
    
    if input.KeyCode == Enum.KeyCode[autoBounceKeybind] then 
        local newState = not autoBounceEnabled
        toggleAutoBounce(newState) 
        pcall(function() Toggles.EnableAutoBounceLoop:SetValue(newState) end)
    end
    
    if input.KeyCode == Enum.KeyCode[wallClimbKeybind] and wallClimbEnabled and wallClimbMode == "Toggle" then
        if _G.IsHoldingH then stopWallHold() else startWallHold() end
    elseif input.KeyCode == Enum.KeyCode[wallClimbKeybind] and wallClimbEnabled and wallClimbMode == "Hold" then
        startWallHold()
    end
end)

SafeConnect(UserInputService.InputEnded, function(input) 
    if input.KeyCode == Enum.KeyCode.Space then 
        getgenv().bhopHoldActive = false 
        applyBhopFriction(true) 
        
        bhopHoldActive = false
        checkBhopState()
    end
    
    if turnbindEnabled then
        local leftEnum = parseKeyCode(turnbindLeftKey)
        local rightEnum = parseKeyCode(turnbindRightKey)
        
        if leftEnum and input.KeyCode == leftEnum then
            sendKeyEvent(Enum.KeyCode.Left, false)
        elseif rightEnum and input.KeyCode == rightEnum then
            sendKeyEvent(Enum.KeyCode.Right, false)
        end
    end
    
    if input.KeyCode == Enum.KeyCode[wallClimbKeybind] and wallClimbEnabled and wallClimbMode == "Hold" then
        stopWallHold()
    end
end)

local function setupCharacter(character)
    task.wait(0.5)
    local humanoid = character:WaitForChild("Humanoid")
    local rootPart = character:WaitForChild("HumanoidRootPart")
    
    SafeConnect(humanoid.StateChanged, function(_, newState) 
        if newState == Enum.HumanoidStateType.Landed then CurrentJumpCount = 0 end 
    end)
    
    SafeConnect(humanoid.Jumping, function(isJumping)
        if isJumping and CurrentJumpCount < maxJumpsValue then
            CurrentJumpCount = CurrentJumpCount + 1
            humanoid.JumpHeight = currentSettings.JumpPowerValue
            if CurrentJumpCount > 1 and rootPart then 
                rootPart:ApplyImpulse(Vector3.new(0, currentSettings.JumpPowerValue * rootPart.Mass, 0)) 
            end
        end
    end)
    
    onRespawnTagCheck()
    if autoApplyAuraColor then task.wait(1.5); applyAuraColorEffect() end
    
    task.wait(0.5)
    if headlessEnabled then applyHeadless(character) end
    if korbloxEnabled then applyKorblox(character) end
    
    setupLegacyCharacter(character)
end

if LocalPlayer.Character then task.spawn(setupCharacter, LocalPlayer.Character) end
SafeConnect(LocalPlayer.CharacterAdded, setupCharacter)

Library:Notify({
    Title = "Movement Dih",
    Description = "Done!, please follow my tiktok account : @thatoneargo",
    Time = 5
})
