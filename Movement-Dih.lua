local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local Mouse = LocalPlayer:GetMouse()
local StarterGui = game:GetService("StarterGui")
if not cloneref then getgenv().cloneref = function(instance) return instance end end

local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

;(function()
local Options = Library.Options
local Toggles = Library.Toggles
Library.ForceCheckbox = false
Library.ShowToggleFrameInKeybinds = true

local Window = Library:CreateWindow({
    Title = "Kenny gay",
    Footer = "version : Gayver",
    NotifySide = "Right",
    ShowCustomCursor = true,
})

local C = {
    Speed = 1500,
    JumpPowerValue = 3.5,
    JumpCap = 1,
    AirStrafeAcceleration = 187,
    
    bhopHoldSystemEnabled = false,
    bhopHoldActive = false,
    bhopMode = "Acceleration",
    bhopAccelValue = -0.5,
    frictionTables = {},
    autoJumpEnabled = false,
    bhopHoldFeature = false,
    jumpCooldown = 0.05,
    accelerationMethod = "Acceleration",
    groundFriction = -0.5,
    AutoAccelerationEnabled = false,
    MaxSpeed = 70,
    MaxAcceleration = 3,
    MinAcceleration = -1,
    bhopLoaded = false,
    movementModule = nil,
    originalApplyFriction = nil,
    bhopConnection = nil,
    LastJump = 0,
    CurrentJumpCount = 0,
    maxJumpsValue = math.huge,
    
    RealSpeed = 1500,
    JumpHeight = 3,
    AirStrafeAccelerationLegacy = 187,
    jumpcap = 1,
    SpringSpeedMultiplier = 1,
    AirAcceleration = 1,
    
    turnbindEnabled = false,
    turnbindLeftKey = "A",
    turnbindRightKey = "D",
    
    autoBounceEnabled = false,
    autoBounceKeybind = "B",
    bouncePowerValue = 50,
    bounceDebounce = false,
    bounceConnection = nil,
    
    cosmetic1 = "",
    cosmetic2 = "",
    isSwapped = false,
    originalCosmetic1 = "",
    originalCosmetic2 = "",
    headlessEnabled = false,
    korbloxEnabled = false,
    HEADLESS_MESH_ID = "rbxassetid://1095708",
    KORBLOX_MESH_ID = "rbxassetid://101851696",
    KORBLOX_TEXTURE_ID = "rbxassetid://101851254",
    
    downDashEnabled = false,
    downDashSpeed = 185,
    downDashCurrentSpeed = 0,
    downDashActive = false,
    downDashPreActivated = false,
    isDownedState = false,
    downDashHasUsed = false,
    
    customHitboxEnabled = false,
    customHitboxWidth = 5,
    customHitboxHeight = 5,
    customHitboxLength = 5,
    customHitboxColor = Color3.fromRGB(255, 0, 0),
    customHitboxTransparency = 0.5,
    CACTUS_WIDTH = 5.0,
    CACTUS_HEIGHT = 2.0,
    CACTUS_LENGTH = 5.0,
    HITBOX_SIZE = Vector3.new(5.0, 2.0, 5.0),
    HITBOX_TRANSPARENCY = 1,
    HITBOX_COLOR = Color3.fromRGB(0, 255, 255),
    NO_FRICTION_PHYSICS = PhysicalProperties.new(0.7, 0, 1, 0, 1),
    
    hideOthersEnabled = false,
    hideSelfEnabled = false,
    hideOthersConn = nil,
    removeInvisWallsEnabled = false,
    invisWallOriginals = {},
    edgeBoostEnabled = false,
    edgeBoostPower = 100,
    edgeBoostConn = nil,
    edgeVMin = 1.0,
    auraColor = Color3.fromRGB(255, 0, 0),
    autoApplyAuraColor = false,
    customAuraModelID = "",
    customAuraScale = 1,
    customAuraTransparency = 0,
    globalColorValue = Color3.fromRGB(255, 255, 255),
    globalColorOriginals = {},
    globalColorApplied = false,
    
    wallClimbEnabled = false,
    wallClimbKeybind = "J",
    wallClimbMode = "Auto",
    IsHoldingH = false,
    currentLockedY = 0,
    pixelSurfAutoConn = nil,
    
    currentEmotes = {},
    selectEmotes = {},
    emoteEnabled = {},
    feOriginalEmotes = {},
    feHookInstalled = false,
    feBlockRemote = false,
    fePendingEmotes = {},
    feValidEmotes = {},
    feEmoteInputs = {},
    feEmoteSpeedConn = nil,
    feEmotingConn = nil,
    feEmoteSpeedCache = {},
    feEmoteRunnerActive = false,
    currentTag = nil,
    pendingSlot = nil,
    blockOriginalEmote = false,
    
    mapID = "",
    spawnedMap = nil,
    
    is360HopEnabled = false,
    hop360Conn = nil,
    HOP360_SPEED = 0.70,
    
    fastTurnActive = false,
    fastTurnConnection = nil,
    
    lagConfig = { MSDelay = 200, Mode = "Normal" },
    lagActive = false,
    
    RunningConnections = {},
    CustomHitboxFolder = nil,
    psRayParams = RaycastParams.new(),
    currentSettings = {
        Speed = 1500,
        JumpPowerValue = 3.5,
        JumpCap = 1,
        AirStrafeAcceleration = 187
    },
    
    invisiWallStoredParts = {},
    invisiWallProcessedParts = {},
    invisiWallIsProcessing = false,
    invisiWallConnections = {},
    invisiWallRefreshKey = "J",
    invisiWallRepairKeywords = {
        "stair", "step", "ramp", "trimp", "platform", "invisibleplatform",
        "floor", "ground", "pad", "road", "path", "bridge"
    },
}

C.CustomHitboxFolder = Instance.new("Folder")
C.CustomHitboxFolder.Name = "MovementDih_CustomHitboxes"
C.CustomHitboxFolder.Parent = workspace
C.psRayParams.FilterType = Enum.RaycastFilterType.Exclude

local function safeConnect(signal, callback)
    local conn = signal:Connect(callback)
    table.insert(C.RunningConnections, conn)
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

local function isCharacterGrounded(char, hrp, hum)
    if hum:GetState() == Enum.HumanoidStateType.Running then return true end
    local jumpStates = {Enum.HumanoidStateType.Jumping, Enum.HumanoidStateType.Freefall, Enum.HumanoidStateType.Swimming}
    for _, state in ipairs(jumpStates) do
        if hum:GetState() == state then return false end
    end
    C.psRayParams.FilterDescendantsInstances = {char}
    local result = Workspace:Raycast(hrp.Position, Vector3.new(0, -4, 0), C.psRayParams)
    return result ~= nil
end

local function getCurrentSpeed()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then return (hrp.Velocity * Vector3.new(1, 0, 1)).Magnitude end
    return 0
end

local function checkIsPlayerDown(char, hum)
    if not hum or not char then return false end
    if hum.Health <= 0 then return true end
    if hum.WalkSpeed <= 0 and hum.JumpPower <= 0 then return true end
    if hum:GetState() == Enum.HumanoidStateType.Dead then return true end
    if char:FindFirstChild("Down") then return true end
    if char:FindFirstChild("Downed") then return true end
    if char:GetAttribute("Downed") then return true end
    if char:GetAttribute("Down") then return true end
    return false
end

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
    if not C.bhopLoaded then return end
    pcall(function()
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if not char or not hum then return end
        local isBhopActive = C.autoJumpEnabled or (C.bhopHoldFeature and C.bhopHoldActive)
        if isBhopActive then
            local now = tick()
            if IsOnGround() and (now - C.LastJump) > C.jumpCooldown then
                C.LastJump = now
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end)
end

local function checkBhopState()
    if C.autoJumpEnabled or (C.bhopHoldFeature and C.bhopHoldActive) then
        if not C.bhopLoaded then
            C.bhopLoaded = true
            if C.bhopConnection then C.bhopConnection:Disconnect() end
            C.bhopConnection = RunService.Heartbeat:Connect(updateBhop)
        end
    else
        if C.bhopLoaded then
            C.bhopLoaded = false
            if C.bhopConnection then C.bhopConnection:Disconnect(); C.bhopConnection = nil end
        end
        C.bhopHoldActive = false
    end
end

local function reapplyModifications()
    if not C.movementModule then return end
    if not C.originalApplyFriction then C.originalApplyFriction = C.movementModule.ApplyFriction end
    local isBhopActive = C.autoJumpEnabled or (C.bhopHoldFeature and C.bhopHoldActive)
    if isBhopActive then
        C.movementModule.ApplyFriction = function(self, frictionAmount)
            local isGrounded = self.a == true
            if isGrounded then
                if C.accelerationMethod == "No Acceleration" then
                    frictionAmount = 0
                elseif C.accelerationMethod == "Ground Acceleration" or C.accelerationMethod == "Acceleration" then
                    local finalFriction = C.groundFriction
                    if C.AutoAccelerationEnabled then
                        local currentSpeed = getCurrentSpeed()
                        if currentSpeed > C.MaxSpeed then finalFriction = C.MaxAcceleration
                        else finalFriction = C.MinAcceleration end
                    end
                    frictionAmount = finalFriction
                end
            end
            return C.originalApplyFriction(self, frictionAmount)
        end
    else
        C.movementModule.ApplyFriction = C.originalApplyFriction
    end
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
            tbl.Speed = C.currentSettings.Speed
            tbl.JumpCap = C.currentSettings.JumpCap
            tbl.AirStrafeAcceleration = C.currentSettings.AirStrafeAcceleration
        end)
    end
end

function applyBhopFriction(forceReset)
    if not forceReset and #C.frictionTables == 0 and C.bhopHoldSystemEnabled then
        for _, obj in pairs(getgc(true)) do
            if type(obj) == "table" and rawget(obj, "Friction") then
                table.insert(C.frictionTables, {obj = obj, original = obj.Friction})
            end
        end
    end
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local grounded = (char and hum and hrp) and isCharacterGrounded(char, hrp, hum)
    local isActive = C.bhopHoldSystemEnabled and C.bhopHoldActive and grounded and not forceReset
    for _, tableData in ipairs(C.frictionTables) do
        if tableData.obj and type(tableData.obj) == "table" then
            pcall(function()
                local isAccel = (isActive and C.bhopMode == "Acceleration")
                tableData.obj.Friction = isAccel and C.bhopAccelValue or tableData.original
            end)
        end
    end
end

local function sendKeyEvent(keyCode, isDown)
    pcall(function() VirtualInputManager:SendKeyEvent(isDown, keyCode, false, game) end)
end

function toggleAutoBounce(state)
    C.autoBounceEnabled = state
    if state then
        C.bounceDebounce = false
        if C.bounceConnection then C.bounceConnection:Disconnect() end
        C.bounceConnection = RunService.PostSimulation:Connect(function()
            if not C.autoBounceEnabled then return end
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hum and hrp and hum.Health > 0 then
                local isGrounded = (hum.FloorMaterial ~= Enum.Material.Air) or (hum:GetState() == Enum.HumanoidStateType.Landed)
                if isGrounded and not C.bounceDebounce then
                    C.bounceDebounce = true
                    hum:ChangeState(Enum.HumanoidStateType.Jumping)
                    hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, 0, hrp.AssemblyLinearVelocity.Z)
                    local customImpulse = (C.bouncePowerValue / 2) * hrp.Mass
                    hrp:ApplyImpulse(Vector3.new(0, customImpulse, 0))
                    task.delay(0.05, function() C.bounceDebounce = false end)
                end
            end
        end)
    else
        if C.bounceConnection then C.bounceConnection:Disconnect(); C.bounceConnection = nil end
    end
end

local function checkNearWall()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    C.psRayParams.FilterDescendantsInstances = {char, Workspace:FindFirstChild("Game") and Workspace.Game:FindFirstChild("Effects")}
    local dirs = {hrp.CFrame.LookVector * 3.5, -hrp.CFrame.LookVector * 3.5, hrp.CFrame.RightVector * 3.5, -hrp.CFrame.RightVector * 3.5}
    for _, dir in ipairs(dirs) do
        local result = Workspace:Raycast(hrp.Position, dir, C.psRayParams)
        if result and result.Instance and result.Instance.CanCollide then return true end
    end
    return false
end

local function isOnSlope()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    C.psRayParams.FilterDescendantsInstances = {char}
    local result = Workspace:Raycast(hrp.Position, Vector3.new(0, -4, 0), C.psRayParams)
    if not result then return false end
    local dot = result.Normal:Dot(Vector3.new(0, 1, 0))
    return dot < 0.95
end

local function stopWallHold()
    C.IsHoldingH = false
    if _G.WallClimbConnection then _G.WallClimbConnection:Disconnect(); _G.WallClimbConnection = nil end
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then hum:ChangeState(Enum.HumanoidStateType.GettingUp) end
end

local function startWallHold()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp and checkNearWall() and not isOnSlope() then
        C.IsHoldingH = true
        C.currentLockedY = hrp.Position.Y
        if not _G.WallClimbConnection then
            _G.WallClimbConnection = RunService.RenderStepped:Connect(function()
                local char2 = LocalPlayer.Character
                local hrp2 = char2 and char2:FindFirstChild("HumanoidRootPart")
                local hum2 = char2 and char2:FindFirstChildOfClass("Humanoid")
                if not (C.IsHoldingH and hrp2 and hum2) then return end
                if isOnSlope() then stopWallHold(); return end
                if checkNearWall() then
                    local pos = hrp2.Position
                    hrp2.CFrame = CFrame.new(pos.X, C.currentLockedY, pos.Z) * hrp2.CFrame.Rotation
                    hrp2.AssemblyLinearVelocity = Vector3.new(hrp2.AssemblyLinearVelocity.X, 0, hrp2.AssemblyLinearVelocity.Z)
                    hum2:ChangeState(Enum.HumanoidStateType.Physics)
                else
                    stopWallHold()
                end
            end)
        end
    end
end

local function startPixelSurfAuto()
    if C.pixelSurfAutoConn then C.pixelSurfAutoConn:Disconnect() end
    C.pixelSurfAutoConn = RunService.Heartbeat:Connect(function()
        if not C.wallClimbEnabled then return end
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        if checkNearWall() and not isOnSlope() and not C.IsHoldingH then
            startWallHold()
        elseif (not checkNearWall() or isOnSlope()) and C.IsHoldingH then
            stopWallHold()
        end
    end)
end

local function applyHeadless(character)
    if not C.headlessEnabled or not character then return end
    local head = character:FindFirstChild("Head")
    if not head then return end
    head.Transparency = 1
    head.CanCollide = false
    local face = head:FindFirstChildOfClass("Decal")
    if face then face:Destroy() end
    for _, v in ipairs(head:GetChildren()) do
        if v:IsA("SpecialMesh") or v:IsA("CharacterMesh") then v:Destroy() end
    end
    local mesh = Instance.new("SpecialMesh")
    mesh.MeshType = Enum.MeshType.FileMesh
    mesh.MeshId = C.HEADLESS_MESH_ID
    mesh.Scale = Vector3.new(0.001, 0.001, 0.001)
    mesh.Parent = head
end

local function applyKorblox(character)
    if not C.korbloxEnabled or not character then return end
    local rightLeg = character:FindFirstChild("Right Leg")
    if not rightLeg then return end
    for _, v in ipairs(rightLeg:GetChildren()) do
        if v:IsA("SpecialMesh") or v:IsA("CharacterMesh") then v:Destroy() end
    end
    local mesh = Instance.new("SpecialMesh")
    mesh.MeshType = Enum.MeshType.FileMesh
    mesh.MeshId = C.KORBLOX_MESH_ID
    mesh.TextureId = C.KORBLOX_TEXTURE_ID
    mesh.Scale = Vector3.new(1, 1, 1)
    mesh.Parent = rightLeg
end

local function setCharacterVisibility(character, visible)
    if not character then return end
    for _, obj in ipairs(character:GetDescendants()) do
        if obj:IsA("BasePart") or obj:IsA("MeshPart") or obj:IsA("SpecialMesh") then
            pcall(function() obj.Transparency = visible and 0 or 1 end)
        elseif obj:IsA("Decal") or obj:IsA("Texture") then
            pcall(function() obj.Transparency = visible and 0 or 1 end)
        elseif obj:IsA("BillboardGui") or obj:IsA("SurfaceGui") then
            pcall(function() obj.Enabled = visible end)
        end
    end
end

local function applyCosmetics()
    if C.cosmetic1 == "" or C.cosmetic2 == "" or C.cosmetic1 == C.cosmetic2 then return end
    pcall(function()
        local Cosmetics = ReplicatedStorage:WaitForChild("Items"):WaitForChild("Cosmetics")
        local a, b = Cosmetics:FindFirstChild(C.cosmetic1), Cosmetics:FindFirstChild(C.cosmetic2)
        if not a or not b then return end
        if not C.isSwapped then C.originalCosmetic1, C.originalCosmetic2 = C.cosmetic1, C.cosmetic2 end
        local tempRoot = Instance.new("Folder", Cosmetics)
        local tempA = Instance.new("Folder", tempRoot)
        local tempB = Instance.new("Folder", tempRoot)
        for _, c in ipairs(a:GetChildren()) do c.Parent = tempA end
        for _, c in ipairs(b:GetChildren()) do c.Parent = tempB end
        for _, c in ipairs(tempA:GetChildren()) do c.Parent = b end
        for _, c in ipairs(tempB:GetChildren()) do c.Parent = a end
        tempRoot:Destroy()
        C.isSwapped = true
    end)
end

local function resetCosmetics()
    if not C.isSwapped or C.originalCosmetic1 == "" or C.originalCosmetic2 == "" then return end
    pcall(function()
        local Cosmetics = ReplicatedStorage:WaitForChild("Items"):WaitForChild("Cosmetics")
        local a, b = Cosmetics:FindFirstChild(C.originalCosmetic1), Cosmetics:FindFirstChild(C.originalCosmetic2)
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
        C.isSwapped = false
        C.cosmetic1, C.cosmetic2 = "", ""
    end)
end

local function applyAuraColorEffect()
    local char = LocalPlayer.Character
    if not char then return end
    for _, obj in ipairs(char:GetDescendants()) do
        if obj:IsA("ParticleEmitter") or obj:IsA("Trail") then
            obj.Color = ColorSequence.new(C.auraColor)
        elseif obj:IsA("Highlight") then
            obj.FillColor = C.auraColor
            obj.OutlineColor = C.auraColor
        end
    end
end

local function feScanValidEmotes()
    local emotes = {}
    local itemsFolder = ReplicatedStorage:FindFirstChild("Items")
    if itemsFolder then
        local emotesFolder = itemsFolder:FindFirstChild("Emotes")
        if emotesFolder then
            for _, item in pairs(emotesFolder:GetChildren()) do
                if item:IsA("ModuleScript") then
                    emotes[item.Name] = true
                end
            end
        end
    end
    return emotes
end
C.feValidEmotes = feScanValidEmotes()

local function feIsValidEmote(name)
    if not name or name == "" then return false end
    return C.feValidEmotes[name] == true
end

local function feGetTagData()
    local char = LocalPlayer.Character
    if char then return char:GetAttribute("Tag") end
    return nil
end

local function feGetEmoteSpeedMult(emoteName)
    if not feIsValidEmote(emoteName) then return 1 end
    if C.feEmoteSpeedCache[emoteName] then return C.feEmoteSpeedCache[emoteName] end
    local itemsFolder = ReplicatedStorage:FindFirstChild("Items")
    if not itemsFolder then return 1 end
    local emotesFolder = itemsFolder:FindFirstChild("Emotes")
    if not emotesFolder then return 1 end
    local emoteModule = emotesFolder:FindFirstChild(emoteName)
    if not emoteModule or not emoteModule:IsA("ModuleScript") then return 1 end
    local ok, emoteData = pcall(require, emoteModule)
    if not ok or not emoteData then return 1 end
    local speedMult = emoteData.SpeedMult or (emoteData.EmoteInfo and emoteData.EmoteInfo.SpeedMult) or 1
    C.feEmoteSpeedCache[emoteName] = speedMult
    return speedMult
end

local function feSetupEmoteSpeedChange(apply)
    if C.feEmoteSpeedConn then C.feEmoteSpeedConn:Disconnect(); C.feEmoteSpeedConn = nil end
    local gamePlayers = Workspace:FindFirstChild("Game") and Workspace.Game:FindFirstChild("Players")
    if not gamePlayers then return end
    local localModel = gamePlayers:FindFirstChild(LocalPlayer.Name)
    if not localModel then return end
    local function getSpeedFolder()
        local sc = localModel:FindFirstChild("StatChanges")
        return sc and sc:FindFirstChild("Speed")
    end
    local function applySpeedValue(emoteName)
        local sp = getSpeedFolder()
        if not sp then return end
        local mult = feGetEmoteSpeedMult(emoteName)
        local esv = sp:FindFirstChild("EmoteSpeed")
        if apply then
            if esv then esv.Value = mult
            else
                esv = Instance.new("NumberValue")
                esv.Name = "EmoteSpeed"
                esv.Value = mult
                esv.Parent = sp
            end
        else
            if esv then esv:Destroy() end
        end
    end
    local function removeSpeedValue()
        local sp = getSpeedFolder()
        if not sp then return end
        local esv = sp:FindFirstChild("EmoteSpeed")
        if esv then esv:Destroy() end
    end
    if localModel:GetAttribute("Emoting") == true then
        for i = 1, 6 do
            local cur = LocalPlayer:GetAttribute("Emote" .. i)
            if cur and cur ~= "" and feIsValidEmote(cur) then
                if apply then applySpeedValue(cur) else removeSpeedValue() end
                break
            end
        end
    else
        removeSpeedValue()
    end
    if apply then
        C.feEmoteSpeedConn = localModel:GetAttributeChangedSignal("Emoting"):Connect(function()
            if localModel:GetAttribute("Emoting") == true then
                for i = 1, 6 do
                    local cur = LocalPlayer:GetAttribute("Emote" .. i)
                    if cur and cur ~= "" and feIsValidEmote(cur) then
                        applySpeedValue(cur)
                        break
                    end
                end
            else
                removeSpeedValue()
            end
        end)
    end
end

local function feSetupTPCameraOnEmoting(apply)
    if C.feEmotingConn then C.feEmotingConn:Disconnect(); C.feEmotingConn = nil end
    if not apply then return end
    local gamePlayers = Workspace:FindFirstChild("Game") and Workspace.Game:FindFirstChild("Players")
    if not gamePlayers then return end
    local localModel = gamePlayers:FindFirstChild(LocalPlayer.Name)
    if not localModel then return end
    C.feEmotingConn = localModel:GetAttributeChangedSignal("Emoting"):Connect(function()
        if localModel:GetAttribute("Emoting") == true then
            local char = LocalPlayer.Character
            if char then
                local clientEvent = char:FindFirstChild("Client")
                if clientEvent then
                    pcall(function() firesignal(clientEvent.OnClientEvent, "TPCamera", { Zoom = 10 }) end)
                end
            end
        end
    end)
end

local function feTriggerTagEmote(slot)
    local swapName = C.fePendingEmotes[slot]
    if not swapName or swapName == "" then swapName = LocalPlayer:GetAttribute("Emote" .. slot) end
    if not swapName or swapName == "" then return end
    if not feIsValidEmote(swapName) then return end
    local tagData = feGetTagData()
    if not tagData then return end
    local emoteEvent = ReplicatedStorage:FindFirstChild("Events")
        and ReplicatedStorage.Events:FindFirstChild("Character")
        and ReplicatedStorage.Events.Character:FindFirstChild("Emote")
    if emoteEvent then
        task.defer(function() firesignal(emoteEvent.OnClientEvent, tagData, swapName) end)
    end
end

local function feInstallHook()
    if C.feHookInstalled then return end
    local emoteRemoteFE = ReplicatedStorage:FindFirstChild("Events") and ReplicatedStorage.Events:FindFirstChild("Emote")
    if not emoteRemoteFE then return end
    pcall(function()
        local mt = getrawmetatable(emoteRemoteFE)
        if mt and mt.__namecall then
            local old = mt.__namecall
            setreadonly(mt, false)
            mt.__namecall = function(self, ...)
                local method = getnamecallmethod()
                if method == "FireServer" and self == emoteRemoteFE then
                    local args = {...}
                    local num = tostring(args[1])
                    if num:match("^[1-6]$") and C.feBlockRemote then
                        feTriggerTagEmote(tonumber(num))
                        return
                    end
                end
                return old(self, ...)
            end
            setreadonly(mt, true)
            C.feHookInstalled = true
        end
    end)
end

local function feApplyAllEmotes()
    C.feBlockRemote = true
    pcall(function()
        for i = 1, 6 do
            if C.fePendingEmotes[i] and C.fePendingEmotes[i] ~= "" and feIsValidEmote(C.fePendingEmotes[i]) then
                LocalPlayer:SetAttribute("Emote" .. i, C.fePendingEmotes[i])
            end
        end
        C.fePendingEmotes = {}
        feInstallHook()
        if not C.feEmoteRunnerActive then
            feSetupEmoteSpeedChange(true)
            feSetupTPCameraOnEmoting(true)
        end
    end)
end

local function feResetAllEmotes()
    C.feBlockRemote = false
    pcall(function()
        feSetupEmoteSpeedChange(false)
        feSetupTPCameraOnEmoting(false)
        C.fePendingEmotes = {}
        for i = 1, 6 do
            LocalPlayer:SetAttribute("Emote" .. i, C.feOriginalEmotes[i])
            pcall(function() Options["FEEmoteSlot" .. i]:SetValue(C.feOriginalEmotes[i] or "") end)
        end
    end)
end

local function extractCustomAuraEffects(obj, targetPart, scale, transparency)
    local effectClasses = {
        ParticleEmitter = true, Trail = true, Beam = true,
        PointLight = true, SpotLight = true, SurfaceLight = true,
        Sparkles = true, Fire = true, Smoke = true,
        BillboardGui = true, SurfaceGui = true,
    }
    for _, child in ipairs(obj:GetChildren()) do
        if effectClasses[child.ClassName] then
            local clone = child:Clone()
            if clone:IsA("ParticleEmitter") then
                clone.Size = NumberSequence.new(clone.Size.Keypoints[1].Value * scale)
                clone.Speed = NumberRange.new(clone.Speed.Min * scale, clone.Speed.Max * scale)
                clone.SpreadAngle = Vector2.new(180, 180)
                clone.Rate = clone.Rate * scale
                clone.Transparency = NumberSequence.new(transparency)
            elseif clone:IsA("Fire") then
                clone.Size = math.clamp(clone.Size * scale, 1, 30)
            elseif clone:IsA("Smoke") then
                clone.Size = math.clamp(clone.Size * scale, 1, 30)
                clone.Opacity = 1 - transparency
            elseif clone:IsA("PointLight") then
                clone.Range = math.clamp(clone.Range * scale, 1, 60)
                clone.Brightness = math.clamp(clone.Brightness * scale, 1, 10)
            elseif clone:IsA("SpotLight") then
                clone.Range = math.clamp(clone.Range * scale, 1, 60)
                clone.Brightness = math.clamp(clone.Brightness * scale, 1, 10)
            end
            clone.Parent = targetPart
        elseif child:IsA("Attachment") then
            child:Clone().Parent = targetPart
        end
        extractCustomAuraEffects(child, targetPart, scale, transparency)
    end
end

local function applyCustomAura()
    if C.customAuraModelID == "" then return end
    local character = LocalPlayer.Character
    if not character then return end
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    if character:FindFirstChild("CustomAuraFolder") then character.CustomAuraFolder:Destroy() end
    local id = C.customAuraModelID:match("%d+") or C.customAuraModelID
    local success, assets = pcall(function() return game:GetObjects("rbxassetid://" .. id) end)
    if not (success and assets and assets[1]) then return end
    local auraModel = assets[1]
    local auraFolder = Instance.new("Folder")
    auraFolder.Name = "CustomAuraFolder"
    auraFolder.Parent = character
    local anchor = Instance.new("Part")
    anchor.Name = "CustomAuraAnchor"
    anchor.Size = Vector3.new(0.1, 0.1, 0.1)
    anchor.Transparency = 1
    anchor.CanCollide = false
    anchor.Anchored = false
    anchor.Massless = true
    anchor.Parent = auraFolder
    local weld = Instance.new("Weld")
    weld.Part0 = hrp
    weld.Part1 = anchor
    weld.C0 = CFrame.new(0, 0, 0)
    weld.Parent = anchor
    extractCustomAuraEffects(auraModel, anchor, C.customAuraScale, C.customAuraTransparency)
end

local function clearCustomAura()
    local character = LocalPlayer.Character
    if character and character:FindFirstChild("CustomAuraFolder") then
        character.CustomAuraFolder:Destroy()
    end
end

local function applyEdgeBoost()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum or hum.Health <= 0 then return end
    if hrp.AssemblyLinearVelocity.Y >= -C.edgeVMin then return end
    local touching = hrp:GetTouchingParts()
    if #touching == 0 then return end
    local skipWords = {"bounce","boost","launch","jump","pad","ramp","platform"}
    local isBounce = false
    for _, pt in pairs(touching) do
        local n = string.lower(pt.Name)
        for _, w in pairs(skipWords) do
            if n:find(w) then isBounce = true; break end
        end
        if not isBounce and pt.Parent then
            local pn = string.lower(pt.Parent.Name)
            for _, w in pairs(skipWords) do
                if pn:find(w) then isBounce = true; break end
            end
        end
        if isBounce then break end
    end
    if not isBounce then
        local vel = hrp.AssemblyLinearVelocity
        hrp.AssemblyLinearVelocity = Vector3.new(vel.X, 0, vel.Z) + Vector3.new(0, C.edgeBoostPower, 0)
    end
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
        if primary then cframe, size = primary.CFrame, primary.Size else return end
    end
    local spawnPosition = cframe.Position + Vector3.new(0, size.Y / 2, 0)
    local hitbox = Instance.new("Part")
    hitbox.Name = "BhopHitbox_Cactus"
    hitbox.Size = C.HITBOX_SIZE
    hitbox.CFrame = CFrame.new(spawnPosition + Vector3.new(0, C.CACTUS_HEIGHT / 2, 0))
    hitbox.Transparency = C.HITBOX_TRANSPARENCY
    hitbox.Color = C.HITBOX_COLOR
    hitbox.Material = Enum.Material.Neon
    hitbox.Anchored = true
    hitbox.CanCollide = true
    hitbox.CustomPhysicalProperties = C.NO_FRICTION_PHYSICS
    local tag = Instance.new("BoolValue", cactus)
    tag.Name = "HasBhopHitbox"
    hitbox.Parent = workspace
end

local function forceScanCactus()
    for _, obj in ipairs(workspace:GetDescendants()) do
        local objName = string.lower(obj.Name)
        if string.find(objName, "cactus1") or string.find(objName, "cactus2") then
            if not obj:FindFirstChild("HasBhopHitbox") then
                task.spawn(function() createHitboxOnTop(obj) end)
            end
        end
    end
end

local function forceScanCarPole()
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj.Name == "CarPole" then
            if not obj:FindFirstChild("HasBhopHitbox") then
                task.spawn(function() createHitboxOnTop(obj) end)
            end
        end
    end
end

local function invisiWallIsGameplayPart(name)
    name = string.lower(name)
    for _, keyword in ipairs(C.invisiWallRepairKeywords) do
        if string.find(name, keyword, 1, true) then
            return true
        end
    end
    return false
end

local function invisiWallDestroyAndStore()
    if C.invisiWallIsProcessing then return 0, 0 end
    C.invisiWallIsProcessing = true
    
    local destroyedCount = 0
    local storedCount = 0
    local parts = {}
    
    for _, obj in pairs(Workspace:GetDescendants()) do
        if (obj:IsA("BasePart") or obj:IsA("MeshPart")) and not C.invisiWallProcessedParts[obj] then
            table.insert(parts, obj)
        end
    end
    
    local chunkSize = 50
    for i = 1, #parts, chunkSize do
        for j = i, math.min(i + chunkSize - 1, #parts) do
            local obj = parts[j]
            if obj and obj.Parent then
                local name = string.lower(obj.Name)
                
                if invisiWallIsGameplayPart(name) then
                    if obj.CanCollide then
                        local newPart = obj:Clone()
                        newPart.Parent = nil
                        table.insert(C.invisiWallStoredParts, newPart)
                        pcall(function() obj:Destroy() end)
                        storedCount = storedCount + 1
                    end
                else
                    if obj.CanCollide and obj.Transparency >= 0.8 and obj.Position.Y > 50 then
                        pcall(function()
                            obj:Destroy()
                            destroyedCount = destroyedCount + 1
                        end)
                    end
                end
                C.invisiWallProcessedParts[obj] = true
            end
        end
        task.wait()
    end
    
    C.invisiWallIsProcessing = false
    return storedCount, destroyedCount
end

local function invisiWallRestoreStoredParts()
    local restoredCount = 0
    local mapParent = Workspace:FindFirstChild("Map") or Workspace:FindFirstChild("Level") or Workspace
    
    local chunkSize = 25
    for i = 1, #C.invisiWallStoredParts, chunkSize do
        for j = i, math.min(i + chunkSize - 1, #C.invisiWallStoredParts) do
            local part = C.invisiWallStoredParts[j]
            if part then
                pcall(function()
                    part.Parent = mapParent
                    restoredCount = restoredCount + 1
                end)
            end
        end
        task.wait()
    end
    
    C.invisiWallStoredParts = {}
    C.invisiWallProcessedParts = {}
    return restoredCount
end

local function invisiWallRunCleanAndFix()
    local stored, destroyed = invisiWallDestroyAndStore()
    task.wait(0.2)
    local restored = invisiWallRestoreStoredParts()
    
    if destroyed > 0 or restored > 0 then
        StarterGui:SetCore("SendNotification", {
            Title = "MAP REGENERATION",
            Text = string.format("Ramps: %d | Walls: %d | Restored: %d", stored, destroyed, restored),
            Duration = 5
        })
    else
        StarterGui:SetCore("SendNotification", {
            Title = "CLEAN",
            Text = "No issues found",
            Duration = 3
        })
    end
end

local function invisiWallRunRefresh()
    if #C.invisiWallStoredParts > 0 then
        local restored = invisiWallRestoreStoredParts()
        StarterGui:SetCore("SendNotification", {
            Title = "Map Refresh",
            Text = string.format("Restored %d parts", restored),
            Duration = 3
        })
    end
    invisiWallRunCleanAndFix()
end

local function invisiWallSetupKeybind()
    local conn = UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == Enum.KeyCode[C.invisiWallRefreshKey] then
            invisiWallRunRefresh()
        end
    end)
    table.insert(C.invisiWallConnections, conn)
    table.insert(C.RunningConnections, conn)
end

local function invisiWallSetRefreshKey(key)
    for _, conn in ipairs(C.invisiWallConnections) do
        pcall(function() conn:Disconnect() end)
    end
    C.invisiWallConnections = {}
    
    C.invisiWallRefreshKey = key
    if key ~= "None" then
        invisiWallSetupKeybind()
        StarterGui:SetCore("SendNotification", {
            Title = "Key Updated",
            Text = "Refresh key set to: " .. key,
            Duration = 3
        })
    end
end

local function fixNonmovableEmotes()
    local EmotesFolder = ReplicatedStorage:WaitForChild("Items"):WaitForChild("Emotes")
    local fixedCount = 0
    for _, emoteModule in pairs(EmotesFolder:GetChildren()) do
        if emoteModule:IsA("ModuleScript") then
            local ok, emoteData = pcall(require, emoteModule)
            if ok and emoteData then
                local currentSpeed = emoteData.SpeedMult 
                    or (emoteData.EmoteInfo and emoteData.EmoteInfo.SpeedMult) 
                    or 1
                
                if currentSpeed == 0 then
                    if emoteData.SpeedMult ~= nil then
                        emoteData.SpeedMult = 0.7
                    elseif emoteData.EmoteInfo and emoteData.EmoteInfo.SpeedMult ~= nil then
                        emoteData.EmoteInfo.SpeedMult = 0.7
                    else
                        -- Nếu không có SpeedMult, thêm vào
                        if not emoteData.EmoteInfo then
                            emoteData.EmoteInfo = {}
                        end
                        emoteData.EmoteInfo.SpeedMult = 0.7
                    end
                    fixedCount = fixedCount + 1
                end
            end
        end
    end
    
    if fixedCount > 0 then
        StarterGui:SetCore("SendNotification", {
            Title = "Nonmovable Emote Fix",
            Text = string.format("Đã sửa %d emote (SpeedMult 0 → 0.7)", fixedCount),
            Duration = 5
        })
    else
        StarterGui:SetCore("SendNotification", {
            Title = "Nonmovable Emote Fix",
            Text = "Không tìm thấy emote nào có SpeedMult = 0",
            Duration = 3
        })
    end
end

local function setupCharacter(character)
    task.wait(0.5)
    local humanoid = character:WaitForChild("Humanoid")
    local rootPart = character:WaitForChild("HumanoidRootPart")
    
    C.downDashCurrentSpeed = 0
    C.downDashActive = false
    C.downDashPreActivated = false
    C.isDownedState = false
    C.downDashHasUsed = false
    
    safeConnect(humanoid.StateChanged, function(_, newState)
        if newState == Enum.HumanoidStateType.Landed then C.CurrentJumpCount = 0 end
    end)
    
    safeConnect(humanoid.Jumping, function(isJumping)
        if isJumping and C.CurrentJumpCount < C.maxJumpsValue then
            C.CurrentJumpCount = C.CurrentJumpCount + 1
            humanoid.JumpHeight = C.currentSettings.JumpPowerValue
            if C.CurrentJumpCount > 1 and rootPart then
                rootPart:ApplyImpulse(Vector3.new(0, C.currentSettings.JumpPowerValue * rootPart.Mass, 0))
            end
        end
    end)
    
    local movement = character:WaitForChild("Movement", 10)
    if movement and movement:IsA("ModuleScript") then
        pcall(function()
            local module = require(movement)
            C.movementModule = module
            reapplyModifications()
            local originalUpdate = module.Update
            module.Update = function(self, dt)
                local originalSpeed = self.j
                self.j = C.RealSpeed * C.SpringSpeedMultiplier
                local originalAirMove = self.AirMove
                self.AirMove = function(airSelf, ...)
                    local originalAccelerate = airSelf.Accelerate
                    airSelf.Accelerate = function(accSelf, direction, targetSpeed, acceleration)
                        targetSpeed = targetSpeed * C.AirAcceleration
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
                    self:Accelerate(v4, C.AirStrafeAccelerationLegacy, C.AirStrafeAccelerationLegacy)
                end
            end
        end)
    end)
    
    humanoid.JumpHeight = C.JumpHeight
    local jumps = 0
    local jumpTick = tick()
    safeConnect(humanoid.StateChanged, function(old, new)
        if new == Enum.HumanoidStateType.Landed then jumps = 0 end
    end)
    safeConnect(UserInputService.JumpRequest, function()
        if C.jumpcap > 1 and jumps >= 1 and jumps < C.jumpcap and tick() - jumpTick > 0.05 then
            jumpTick = tick()
            jumps = jumps + 1
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end)
    checkBhopState()
    
    C.currentTag = nil
    C.pendingSlot = nil
    task.spawn(function()
        local startTime = tick()
        while tick() - startTime < 10 do
            if Workspace:FindFirstChild("Game") and Workspace.Game:FindFirstChild("Players") then
                local playerFolder = Workspace.Game.Players:FindFirstChild(LocalPlayer.Name)
                if playerFolder then
                    local tagAttr = playerFolder:GetAttribute("Tag") or (playerFolder:FindFirstChild("Tag") and playerFolder.Tag.Value)
                    if tagAttr then
                        local tagNum = tonumber(tagAttr)
                        if tagNum and tagNum >= 0 and tagNum <= 255 then C.currentTag = tagAttr; break end
                    end
                end
            end
            task.wait(0.5)
        end
    end)
    
    if C.autoApplyAuraColor then task.wait(1.5); applyAuraColorEffect() end
    task.wait(0.5)
    if C.headlessEnabled then applyHeadless(character) end
    if C.korbloxEnabled then applyKorblox(character) end
end

local Events = ReplicatedStorage:WaitForChild("Events", 10)
local CharacterFolder = Events and Events:WaitForChild("Character", 10)
local EmoteRemote = CharacterFolder and CharacterFolder:WaitForChild("Emote", 10)
local PassCharacterInfo = CharacterFolder and CharacterFolder:WaitForChild("PassCharacterInfo", 10)
local remoteSignal = PassCharacterInfo and PassCharacterInfo.OnClientEvent

if PassCharacterInfo and EmoteRemote then
    safeConnect(PassCharacterInfo.OnClientEvent, function(...)
        if not C.pendingSlot then return end
        local slot = C.pendingSlot
        C.pendingSlot = nil
        task.wait(0.1)
        local function fireSelectEmote(slot)
            if not C.currentTag or not C.selectEmotes[slot] or C.selectEmotes[slot] == "" then return end
            local tagNumber = tonumber(C.currentTag)
            if not tagNumber or tagNumber < 0 or tagNumber > 255 then return end
            if remoteSignal then
                pcall(function()
                    local buf = buffer.create(2)
                    buffer.writeu8(buf, 0, tagNumber)
                    buffer.writeu8(buf, 1, 17)
                    firesignal(remoteSignal, buf, {C.selectEmotes[slot]})
                end)
            end
        end
        fireSelectEmote(slot)
    end)
    
    local oldNamecall
    oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        local methodName = getnamecallmethod()
        local args = {...}
        if methodName == "FireServer" and self == EmoteRemote and type(args[1]) == "string" then
            for i = 1, 12 do
                if C.emoteEnabled[i] and C.currentEmotes[i] ~= "" and args[1]:gsub("%s+", ""):lower() == C.currentEmotes[i]:lower() then
                    C.pendingSlot = i
                    C.blockOriginalEmote = true
                    task.spawn(function()
                        task.wait(0.1)
                        C.blockOriginalEmote = false
                        if C.pendingSlot == i then
                            C.pendingSlot = nil
                            local function fireSelectEmote2(slot)
                                if not C.currentTag or not C.selectEmotes[slot] or C.selectEmotes[slot] == "" then return end
                                local tagNumber = tonumber(C.currentTag)
                                if not tagNumber or tagNumber < 0 or tagNumber > 255 then return end
                                if remoteSignal then
                                    pcall(function()
                                        local buf = buffer.create(2)
                                        buffer.writeu8(buf, 0, tagNumber)
                                        buffer.writeu8(buf, 1, 17)
                                        firesignal(remoteSignal, buf, {C.selectEmotes[slot]})
                                    end)
                                end
                            end
                            fireSelectEmote2(i)
                        end
                    end)
                    if C.blockOriginalEmote then return nil end
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
    Lighting = Window:AddTab("Adjust Lighting", "sun"),
    LagSwitch = Window:AddTab("Lag Switch", "wifi"),
    Settings = Window:AddTab("System Settings", "settings")
}

local MoveGroup1 = Tabs.Movement:AddLeftGroupbox("Player Modification Settings")
MoveGroup1:AddInput("PlayerSpeedModifier", { Default = "1500", Text = "Player Speed Modifier", Placeholder = "Default: 1500", Numeric = true, Callback = function(value) local val = tonumber(value) if val then C.currentSettings.Speed = val; applyMovementSettings() end end })
MoveGroup1:AddInput("PlayerJumpHeightPower", { Default = "3.5", Text = "Player Jump Height Power", Placeholder = "Default: 3.5", Numeric = true, Callback = function(value) if tonumber(value) then C.currentSettings.JumpPowerValue = tonumber(value) end end })
MoveGroup1:AddInput("PlayerJumpCapMultiplier", { Default = "1", Text = "Player Jump Cap Multiplier", Placeholder = "Default: 1", Numeric = true, Callback = function(value) local val = tonumber(value) if val then C.currentSettings.JumpCap = val; applyMovementSettings() end end })
MoveGroup1:AddInput("AirStrafeAcceleration", { Default = "187", Text = "Air Strafe Acceleration", Placeholder = "Default: 187", Numeric = true, Callback = function(value) local val = tonumber(value) if val then C.currentSettings.AirStrafeAcceleration = val; applyMovementSettings() end end })

local MoveGroup2 = Tabs.Movement:AddLeftGroupbox("Bhop")
MoveGroup2:AddToggle("EnableBhopSystem", { Text = "Enable Bhop System (Hold Space)", Default = false, Callback = function(state) C.bhopHoldSystemEnabled = state if not state then C.bhopHoldActive = false end applyBhopFriction(not state) end })

local MoveGroup6 = Tabs.Movement:AddLeftGroupbox("Down Dash Overhaul")
MoveGroup6:AddToggle("EnableDownDashOverhaul", { Text = "Enable Down Dash Overhaul", Default = false, Callback = function(state) C.downDashEnabled = state if not state then C.downDashActive = false; C.downDashPreActivated = false; C.downDashCurrentSpeed = 0 end end })
MoveGroup6:AddSlider("DownDashSpeedSlider", { Text = "Down Dash Speed", Min = 20, Max = 300, Default = 185, Rounding = 0, Callback = function(value) C.downDashSpeed = value end })

local MoveGroup7 = Tabs.Movement:AddLeftGroupbox("Emote Utilities")
MoveGroup7:AddToggle("Enable360HopEmote", { Text = "360 Hop Emote", Default = false, Callback = function(state) C.is360HopEnabled = state; if state then 
    local function start360Hop()
        if C.hop360Conn then C.hop360Conn:Disconnect() end
        C.hop360Conn = RunService.Heartbeat:Connect(function(dt)
            if not C.is360HopEnabled then return end
            local char = LocalPlayer.Character
            local rootPart = char and char:FindFirstChild("HumanoidRootPart")
            if not rootPart then return end
            rootPart.CFrame = rootPart.CFrame * CFrame.Angles(0, 2 * math.pi / C.HOP360_SPEED * dt, 0)
        end)
    end
    start360Hop() else if C.hop360Conn then C.hop360Conn:Disconnect(); C.hop360Conn = nil end end end })

MoveGroup7:AddButton({ Text = "Nonmovable Emote", DoubleClick = false, Func = function()
    fixNonmovableEmotes()
end })

local MoveGroup8 = Tabs.Movement:AddRightGroupbox("Edge Boost")
MoveGroup8:AddToggle("EnableEdgeBoost", { Text = "Enable Edge Boost", Default = false, Callback = function(state) C.edgeBoostEnabled = state; if state then if C.edgeBoostConn then C.edgeBoostConn:Disconnect() end; C.edgeBoostConn = RunService.Stepped:Connect(applyEdgeBoost) else if C.edgeBoostConn then C.edgeBoostConn:Disconnect(); C.edgeBoostConn = nil end end end })
MoveGroup8:AddSlider("EdgeBoostPower", { Text = "Edge Power", Min = 10, Max = 500, Default = 100, Rounding = 0, Callback = function(value) C.edgeBoostPower = value end })

local MoveGroup3 = Tabs.Movement:AddRightGroupbox("Pixel Surf")
MoveGroup3:AddToggle("EnableWallClingFunction", { Text = "Enable Pixel Surf", Default = false, Callback = function(state) C.wallClimbEnabled = state; if not state then stopWallHold(); if C.pixelSurfAutoConn then C.pixelSurfAutoConn:Disconnect(); C.pixelSurfAutoConn = nil end end end })
MoveGroup3:AddDropdown("ActivationTriggerMode", { Values = { "Hold", "Toggle", "Auto" }, Default = "Hold", Text = "Activation Mode", Callback = function(value) C.wallClimbMode = value; stopWallHold(); if C.pixelSurfAutoConn then C.pixelSurfAutoConn:Disconnect(); C.pixelSurfAutoConn = nil end; if value == "Auto" and C.wallClimbEnabled then startPixelSurfAuto() end end })
MoveGroup3:AddLabel("Pixel Surf Key"):AddKeyPicker("WallClimbKeybindPicker", { Default = "H", SyncToggleState = false, Mode = "Toggle", Text = "Pixel Surf Key", ChangedCallback = function(key) C.wallClimbKeybind = key.Name end })

local MoveGroup4 = Tabs.Movement:AddRightGroupbox("Auto Bounce Velocity")
MoveGroup4:AddToggle("EnableAutoBounceLoop", { Text = "Enable Auto Bounce Loop", Default = false, Callback = function(state) toggleAutoBounce(state) end })
MoveGroup4:AddLabel("Auto Bounce Switch Key"):AddKeyPicker("AutoBounceKeybindPicker", { Default = "B", SyncToggleState = false, Mode = "Toggle", Text = "Auto Bounce Switch Key", ChangedCallback = function(key) C.autoBounceKeybind = key.Name end })
MoveGroup4:AddSlider("BounceForceVelocity", { Text = "Bounce Force Velocity", Min = 10, Max = 150, Default = 50, Rounding = 0, Callback = function(value) C.bouncePowerValue = value end })

local MoveGroup5 = Tabs.Movement:AddRightGroupbox("Turnbind Engineering")
MoveGroup5:AddToggle("EnableTurnbindModifier", { Text = "Enable Turnbind Modifier", Default = false, Callback = function(state) C.turnbindEnabled = state end })
MoveGroup5:AddInput("LeftTurnKeyBinding", { Default = "A", Text = "Left Turn Key Binding", Placeholder = "A", Callback = function(v) C.turnbindLeftKey = v:upper() end })
MoveGroup5:AddInput("RightTurnKeyBinding", { Default = "D", Text = "Right Turn Key Binding", Placeholder = "D", Callback = function(v) C.turnbindRightKey = v:upper() end })

local LegacyGroup1 = Tabs.Legacy:AddLeftGroupbox("Legacy Player Modification")
LegacyGroup1:AddInput("RealSpeedMultiplier", { Default = "1500", Text = "Real Speed Multiplier", Placeholder = "Default: 1500", Numeric = true, Callback = function(value) local n = tonumber(value) if n then C.RealSpeed = n end end })
LegacyGroup1:AddInput("LegacyJumpHeight", { Default = "3", Text = "Legacy Jump Height", Placeholder = "Default: 3", Numeric = true, Callback = function(value) local n = tonumber(value) if n then C.JumpHeight = n; local char = LocalPlayer.Character; local hum = char and char:FindFirstChildOfClass("Humanoid"); if hum then hum.JumpHeight = n end end end })
LegacyGroup1:AddInput("AirStrafeAccelerationLegacy", { Default = "187", Text = "Air Strafe Acceleration", Placeholder = "Default: 187", Numeric = true, Callback = function(value) local n = tonumber(value) if n then C.AirStrafeAccelerationLegacy = n end end })

local LegacyGroup2 = Tabs.Legacy:AddLeftGroupbox("Legacy Bhop")
LegacyGroup2:AddToggle("EnableBhopAutoJump", { Text = "Enable Bhop (Auto Jump)", Default = false, Callback = function(state) C.autoJumpEnabled = state; checkBhopState(); reapplyModifications() end })
LegacyGroup2:AddToggle("BhopKeyHoldingSpace", { Text = "Bhop Key Holding (Space / Mobile Jump)", Default = false, Callback = function(state) C.bhopHoldFeature = state; if not state then C.bhopHoldActive = false; checkBhopState(); reapplyModifications() end end })
LegacyGroup2:AddDropdown("BhopModeDropdown", { Values = {"No Acceleration", "Ground Acceleration", "Acceleration"}, Default = "Acceleration", Text = "Bhop Mode", Callback = function(value) C.accelerationMethod = value; reapplyModifications() end })
LegacyGroup2:AddInput("BhopAccelerationInput", { Default = "-0.5", Text = "Bhop Acceleration (Negative Value Only)", Placeholder = "-0.5", Callback = function(value) local n = tonumber(value) if n then C.groundFriction = n; reapplyModifications() end end })

local LegacyGroup3 = Tabs.Legacy:AddRightGroupbox("Legacy Auto Acceleration")
LegacyGroup3:AddToggle("EnableAutoAccelerationLegit", { Text = "Enable Auto Acceleration (Legit)", Default = false, Callback = function(state) C.AutoAccelerationEnabled = state; reapplyModifications() end })

local LegacyGroup4 = Tabs.Legacy:AddRightGroupbox("Legacy Exploits & Utilities")
LegacyGroup4:AddButton({ Text = "Scan & Apply Cactus Hitbox", DoubleClick = false, Func = function() forceScanCactus() end })
LegacyGroup4:AddButton({ Text = "Scan & Apply CarPole Hitbox", DoubleClick = false, Func = function() forceScanCarPole() end })

local LegacyGroup6 = Tabs.Legacy:AddLeftGroupbox("Invisible Wall Remover")
LegacyGroup6:AddToggle("EnableRemoveInvisWalls", { Text = "Enable Wall Remover", Default = false, Callback = function(state)
    C.removeInvisWallsEnabled = state
    if state then
        invisiWallRunCleanAndFix()
        if #C.invisiWallConnections == 0 then
            invisiWallSetupKeybind()
        end
        StarterGui:SetCore("SendNotification", {
            Title = "Wall Remover Active",
            Text = "Press " .. C.invisiWallRefreshKey .. " to refresh map",
            Duration = 5
        })
    else
        if #C.invisiWallStoredParts > 0 then
            invisiWallRestoreStoredParts()
        end
        for _, conn in ipairs(C.invisiWallConnections) do
            pcall(function() conn:Disconnect() end)
        end
        C.invisiWallConnections = {}
        C.invisiWallProcessedParts = {}
        StarterGui:SetCore("SendNotification", {
            Title = "Wall Remover Disabled",
            Text = "All parts restored",
            Duration = 3
        })
    end
end })

LegacyGroup6:AddInput("RefreshKeyBind", { Default = "J", Text = "Refresh Key", Placeholder = "J", Callback = function(value) 
    local key = value:upper():gsub("%s+", "")
    if key ~= "" then
        invisiWallSetRefreshKey(key)
    end
end })

LegacyGroup6:AddButton({ Text = "Manual Refresh Map", DoubleClick = false, Func = function()
    if C.removeInvisWallsEnabled then
        invisiWallRunRefresh()
    else
        StarterGui:SetCore("SendNotification", {
            Title = "Wall Remover Disabled",
            Text = "Enable Wall Remover first",
            Duration = 3
        })
    end
end })

LegacyGroup6:AddButton({ Text = "Restore All Parts", DoubleClick = false, Func = function()
    local restored = invisiWallRestoreStoredParts()
    StarterGui:SetCore("SendNotification", {
        Title = "Restored",
        Text = string.format("Restored %d parts", restored),
        Duration = 3
    })
end })

local LegacyGroup5 = Tabs.Legacy:AddRightGroupbox("Fast Turn")
LegacyGroup5:AddButton({ Text = "Fast Turn", Func = function()
    if C.fastTurnActive then return end
    C.fastTurnActive = true
    local char = LocalPlayer.Character
    if not char then return end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    local rootPart = char:FindFirstChild("HumanoidRootPart")
    if not humanoid or not rootPart then return end
    local TURN_SPEED = 22
    humanoid.AutoRotate = false
    if C.fastTurnConnection then C.fastTurnConnection:Disconnect() end
    C.fastTurnConnection = RunService.RenderStepped:Connect(function(dt)
        if not char or not humanoid or not rootPart then return end
        if humanoid.MoveDirection.Magnitude > 0 then
            local targetCFrame = CFrame.lookAt(rootPart.Position, rootPart.Position + humanoid.MoveDirection)
            rootPart.CFrame = rootPart.CFrame:lerp(targetCFrame, TURN_SPEED * dt)
        end
    end)
    LocalPlayer.CharacterAdded:Connect(function(newChar)
        C.fastTurnActive = false
        if C.fastTurnConnection then C.fastTurnConnection:Disconnect(); C.fastTurnConnection = nil end
    end)
end })

local LegacyGroupFE = Tabs.Legacy:AddLeftGroupbox("FE Change Emote")
for i = 1, 6 do
    local currentVal = LocalPlayer:GetAttribute("Emote" .. i) or ""
    C.feOriginalEmotes[i] = currentVal
    C.feEmoteInputs[i] = LegacyGroupFE:AddInput("FEEmoteSlot" .. i, { Default = currentVal, Text = "Emote Slot " .. i, Placeholder = "e.g. Wave, Dab...", Callback = function(value) C.fePendingEmotes[i] = value:gsub("%s+", "") end })
end
LegacyGroupFE:AddButton({ Text = "Apply Emotes", Func = function() feApplyAllEmotes() end })
LegacyGroupFE:AddButton({ Text = "Reset Emotes", Func = function() feResetAllEmotes() end })
LegacyGroupFE:AddToggle("EmoteRunner", { Text = "Emote Runner", Default = false, Callback = function(state) C.feEmoteRunnerActive = state; if state then feSetupEmoteSpeedChange(false); feSetupTPCameraOnEmoting(false) else feSetupEmoteSpeedChange(true); feSetupTPCameraOnEmoting(true); feInstallHook() end end })

local HitboxGroup1 = Tabs.Hitbox:AddLeftGroupbox("Mouse Target Hitbox Settings")
HitboxGroup1:AddToggle("EnableCustomHitboxCreation", { Text = "Enable Custom Hitbox Creation", Default = false, Callback = function(state) C.customHitboxEnabled = state end })
HitboxGroup1:AddButton({ Text = "Clear All Created Hitboxes", DoubleClick = false, Func = function() C.CustomHitboxFolder:ClearAllChildren() end })

local HitboxGroup2 = Tabs.Hitbox:AddLeftGroupbox("Hitbox Dimensions")
HitboxGroup2:AddSlider("HitboxWidth", { Text = "Hitbox Width", Min = 1, Max = 6, Default = 4, Rounding = 1, Callback = function(value) C.customHitboxWidth = value end })
HitboxGroup2:AddSlider("HitboxHeight", { Text = "Hitbox Height", Min = 1, Max = 6, Default = 4, Rounding = 1, Callback = function(value) C.customHitboxHeight = value end })
HitboxGroup2:AddSlider("HitboxLength", { Text = "Hitbox Length", Min = 1, Max = 6, Default = 4, Rounding = 1, Callback = function(value) C.customHitboxLength = value end })

local HitboxGroup3 = Tabs.Hitbox:AddRightGroupbox("Hitbox Styling")
HitboxGroup3:AddLabel("Select Hitbox Box Color"):AddColorPicker("HitboxColorPicker", { Default = Color3.fromRGB(255, 0, 0), Title = "Select Hitbox Box Color", Callback = function(color) C.customHitboxColor = color end })
HitboxGroup3:AddSlider("HitboxTransparency", { Text = "Hitbox Transparency", Min = 0, Max = 1, Default = 0.5, Rounding = 2, Callback = function(value) C.customHitboxTransparency = value end })

local HitboxGroup5 = Tabs.Hitbox:AddLeftGroupbox("Hide Players")
HitboxGroup5:AddToggle("HideOtherPlayers", { Text = "Hide Other Players", Default = false, Callback = function(state) C.hideOthersEnabled = state; 
    local function refreshHideOthers()
        for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
            if player ~= LocalPlayer then
                setCharacterVisibility(player.Character, not C.hideOthersEnabled)
            end
        end
    end
    refreshHideOthers(); 
    if state then 
        if C.hideOthersConn then C.hideOthersConn:Disconnect() end
        C.hideOthersConn = game:GetService("Players").PlayerAdded:Connect(function(player) 
            if C.hideOthersEnabled then 
                player.CharacterAdded:Connect(function(char) 
                    task.wait(0.5); 
                    if C.hideOthersEnabled then setCharacterVisibility(char, false) end 
                end) 
            end 
        end)
        for _, player in ipairs(game:GetService("Players"):GetPlayers()) do 
            if player ~= LocalPlayer then 
                player.CharacterAdded:Connect(function(char) 
                    task.wait(0.5); 
                    if C.hideOthersEnabled then setCharacterVisibility(char, false) end 
                end) 
            end 
        end
    else 
        if C.hideOthersConn then C.hideOthersConn:Disconnect(); C.hideOthersConn = nil end 
    end 
end })
HitboxGroup5:AddToggle("HideSelfPlayer", { Text = "Hide Myself", Default = false, Callback = function(state) C.hideSelfEnabled = state; setCharacterVisibility(LocalPlayer.Character, not state); safeConnect(LocalPlayer.CharacterAdded, function(char) task.wait(0.5); if C.hideSelfEnabled then setCharacterVisibility(char, false) end end) end })

local HitboxGroup4 = Tabs.Hitbox:AddRightGroupbox("Map System")
HitboxGroup4:AddInput("MapIDInput", { Default = "", Text = "Map Asset ID", Placeholder = "e.g. 12345678", Numeric = true, Callback = function(value) C.mapID = value:gsub("%D", "") end })
HitboxGroup4:AddButton({ Text = "Create Map", DoubleClick = false, Func = function()
    if C.spawnedMap then C.spawnedMap:Destroy(); C.spawnedMap = nil end
    local backup = workspace:FindFirstChild("MovementDih_CustomMap")
    if backup then backup:Destroy() end
    if C.mapID == "" then return end
    pcall(function()
        local obj = game:GetObjects("rbxassetid://" .. C.mapID)[1]
        if obj then
            C.spawnedMap = obj
            C.spawnedMap.Name = "MovementDih_CustomMap"
            C.spawnedMap.Parent = workspace
            if C.spawnedMap:IsA("Model") then C.spawnedMap:MoveTo(Vector3.new(0, 2500, 0)) end
        end
    end)
end })
HitboxGroup4:AddButton({ Text = "Teleport to Map", DoubleClick = false, Func = function()
    if C.spawnedMap and LocalPlayer.Character then
        LocalPlayer.Character:MoveTo(Vector3.new(0, 2515, 0))
    end
end })
HitboxGroup4:AddButton({ Text = "Delete Map", DoubleClick = false, Func = function()
    if C.spawnedMap then C.spawnedMap:Destroy(); C.spawnedMap = nil
    else local backup = workspace:FindFirstChild("MovementDih_CustomMap"); if backup then backup:Destroy() end end
end })

safeConnect(UserInputService.InputBegan, function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 and C.customHitboxEnabled then
        if Mouse.Target and Mouse.Hit then
            local targetObj = Mouse.Target
            if not targetObj:IsDescendantOf(C.CustomHitboxFolder) then
                pcall(function()
                    local exactClickPos = Mouse.Hit.Position
                    local surfaceNormal = Vector3.FromNormalId(Mouse.TargetSurface)
                    local spawnCFrame = CFrame.new(exactClickPos + (surfaceNormal * (C.customHitboxHeight / 2)))
                    local newHitbox = Instance.new("Part")
                    newHitbox.Name = "MovementDihCreated_Hitbox"
                    newHitbox.Size = Vector3.new(C.customHitboxWidth, C.customHitboxHeight, C.customHitboxLength)
                    newHitbox.CFrame = spawnCFrame
                    newHitbox.Transparency = C.customHitboxTransparency
                    newHitbox.Color = C.customHitboxColor
                    newHitbox.Material = Enum.Material.Neon
                    newHitbox.Anchored = true
                    newHitbox.CanCollide = true
                    newHitbox.CustomPhysicalProperties = C.NO_FRICTION_PHYSICS
                    newHitbox.Parent = C.CustomHitboxFolder
                end)
            end
        end
    end
end)

local VisualGroup1 = Tabs.Visuals:AddLeftGroupbox("Avatar Body Enhancements")
VisualGroup1:AddToggle("EnableHeadlessHead", { Text = "Enable Headless Head", Default = false, Callback = function(state) C.headlessEnabled = state; if state and LocalPlayer.Character then applyHeadless(LocalPlayer.Character) end end })
VisualGroup1:AddToggle("EnableKorbloxRightLeg", { Text = "Enable Korblox Right Leg", Default = false, Callback = function(state) C.korbloxEnabled = state; if state and LocalPlayer.Character then applyKorblox(LocalPlayer.Character) end end })

local VisualGroup2 = Tabs.Visuals:AddLeftGroupbox("Client Cosmetic Replacer")
VisualGroup2:AddInput("CurrentOwnedItemName", { Default = "", Text = "Current Owned Item Name", Placeholder = "Owned item...", Callback = function(v) C.cosmetic1 = v end })
VisualGroup2:AddInput("TargetSwapItemName", { Default = "", Text = "Target Swap Item Name", Placeholder = "Desired item...", Callback = function(v) C.cosmetic2 = v end })
VisualGroup2:AddButton({ Text = "Execute Cosmetic Replacement (Apply)", Func = function() applyCosmetics() end })
VisualGroup2:AddButton({ Text = "Reset Cosmetic & Restore Original", Func = function() resetCosmetics(); pcall(function() Options.CurrentOwnedItemName:SetValue("") end); pcall(function() Options.TargetSwapItemName:SetValue("") end) end })

local VisualGroup3 = Tabs.Visuals:AddRightGroupbox("Aura Color")
VisualGroup3:AddLabel("Pick Custom Aura Color"):AddColorPicker("CustomAuraColorPicker", { Default = Color3.fromRGB(255, 0, 0), Title = "Pick Custom Aura / Cosmetic Color", Callback = function(color) C.auraColor = color; applyAuraColorEffect() end })
VisualGroup3:AddButton({ Text = "Force Update Color Now", Func = function() applyAuraColorEffect() end })
VisualGroup3:AddToggle("AutoApplyColorsOnRespawn", { Text = "Auto Apply Colors On Respawn", Default = false, Callback = function(state) C.autoApplyAuraColor = state end })

local VisualGroupCC = Tabs.Visuals:AddLeftGroupbox("Custom Cosmetic")
VisualGroupCC:AddInput("CustomAuraModelID", { Default = "", Text = "Model Asset ID", Placeholder = "e.g. 10953055906", Callback = function(v) C.customAuraModelID = v:gsub("%s+", "") end })
VisualGroupCC:AddSlider("CustomAuraScaleSlider", { Text = "Aura Scale", Min = 0.1, Max = 10, Default = 1, Rounding = 1, Callback = function(value) C.customAuraScale = value end })
VisualGroupCC:AddSlider("CustomAuraTransparencySlider", { Text = "Aura Transparency", Min = 0, Max = 1, Default = 0, Rounding = 2, Callback = function(value) C.customAuraTransparency = value end })
VisualGroupCC:AddButton({ Text = "Load Aura", Func = function() applyCustomAura() end })
VisualGroupCC:AddButton({ Text = "Clear Aura", Func = function() clearCustomAura() end })

local VisualGroupGC = Tabs.Visuals:AddLeftGroupbox("Global Color")
VisualGroupGC:AddLabel("Pick Global Color"):AddColorPicker("GlobalColorPicker", { Default = Color3.fromRGB(255, 255, 255), Title = "Pick Global Color", Callback = function(color) C.globalColorValue = color end })
VisualGroupGC:AddButton({ Text = "Apply Global Color", Func = function() 
    local function saveOriginalColors()
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") and not C.globalColorOriginals[obj] then
                C.globalColorOriginals[obj] = { Color = obj.Color, Material = obj.Material }
            end
        end
    end
    local function isPlayerPart(obj)
        for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
            if player.Character and obj:IsDescendantOf(player.Character) then return true end
        end
        return false
    end
    saveOriginalColors()
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and not isPlayerPart(obj) then
            pcall(function() obj.Color = C.globalColorValue end)
        end
    end
    C.globalColorApplied = true
end })
VisualGroupGC:AddButton({ Text = "Random Color", Func = function() 
    local function saveOriginalColors2()
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") and not C.globalColorOriginals[obj] then
                C.globalColorOriginals[obj] = { Color = obj.Color, Material = obj.Material }
            end
        end
    end
    local function isPlayerPart2(obj)
        for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
            if player.Character and obj:IsDescendantOf(player.Character) then return true end
        end
        return false
    end
    saveOriginalColors2()
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and not isPlayerPart2(obj) then
            pcall(function()
                obj.Color = Color3.fromRGB(math.random(0,255), math.random(0,255), math.random(0,255))
            end)
        end
    end
    C.globalColorApplied = true
end })
VisualGroupGC:AddButton({ Text = "Reset to Original Colors", Func = function()
    for obj, data in pairs(C.globalColorOriginals) do
        pcall(function()
            if obj and obj.Parent then
                obj.Color = data.Color
                obj.Material = data.Material
            end
        end)
    end
    C.globalColorOriginals = {}
    C.globalColorApplied = false
end })

local VisualGroup4 = Tabs.Visuals:AddRightGroupbox("12 Owned Emotes & 12 Target Emotes")
for i = 1, 12 do
    VisualGroup4:AddInput("EmoteSlotGoc_"..i, { Default = "", Text = string.format("Slot %02d [own]", i), Placeholder = "name emote...", Callback = function(v) C.currentEmotes[i] = v:gsub("%s+", "") end })
    VisualGroup4:AddInput("EmoteSlotTrao_"..i, { Default = "", Text = string.format("Slot %02d [want to swap]", i), Placeholder = "name emote swap...", Callback = function(v) C.selectEmotes[i] = v:gsub("%s+", "") end })
end

local VisualGroup5 = Tabs.Visuals:AddRightGroupbox("Emote Remap Action Buttons")
VisualGroup5:AddButton({ Text = "Apply Emotes Remap System", Func = function()
    for i = 1, 12 do
        if C.currentEmotes[i] ~= "" and C.selectEmotes[i] ~= "" then C.emoteEnabled[i] = true else C.emoteEnabled[i] = false end
    end
end })
VisualGroup5:AddButton({ Text = "Reset All Emote Slots to Default", Func = function()
    for i = 1, 12 do
        C.currentEmotes[i] = ""; C.selectEmotes[i] = ""; C.emoteEnabled[i] = false
        pcall(function() Options["EmoteSlotGoc_"..i]:SetValue("") end)
        pcall(function() Options["EmoteSlotTrao_"..i]:SetValue("") end)
    end
end })

local Lighting = game:GetService("Lighting")
local lightingOriginals = {
    Brightness = Lighting.Brightness,
    ClockTime = Lighting.ClockTime,
    Ambient = Lighting.Ambient,
    OutdoorAmbient = Lighting.OutdoorAmbient,
}
local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
local atmosphereOriginals = atmosphere and {
    Density = atmosphere.Density,
    Offset = atmosphere.Offset,
    Color = atmosphere.Color,
    Decay = atmosphere.Decay,
    Haze = atmosphere.Haze,
} or nil

local sunRaysEffect = Lighting:FindFirstChild("MovementDihSunRays")
if not sunRaysEffect then
    sunRaysEffect = Instance.new("SunRaysEffect")
    sunRaysEffect.Name = "MovementDihSunRays"
    sunRaysEffect.Enabled = false
    sunRaysEffect.Intensity = 0.5
    sunRaysEffect.Spread = 0.5
    sunRaysEffect.Parent = Lighting
end

local colorCorrection = Lighting:FindFirstChild("MovementDihColorCorrection")
if not colorCorrection then
    colorCorrection = Instance.new("ColorCorrectionEffect")
    colorCorrection.Name = "MovementDihColorCorrection"
    colorCorrection.Parent = Lighting
end

local originalSky = Lighting:FindFirstChildOfClass("Sky")
local customSkyModelID = ""
local customSkyModelObj = nil
local customImageSkyID = ""

local function getOrCreateAtmosphere()
    if not atmosphere or not atmosphere.Parent then
        atmosphere = Instance.new("Atmosphere")
        atmosphere.Parent = Lighting
    end
    return atmosphere
end

local function applyCustomSkyModel()
    if customSkyModelID == "" then return end
    if originalSky then originalSky.Parent = nil end
    if customSkyModelObj then customSkyModelObj:Destroy(); customSkyModelObj = nil end
    pcall(function()
        local id = customSkyModelID:match("%d+") or customSkyModelID
        local assets = game:GetObjects("rbxassetid://" .. id)
        if assets and assets[1] and assets[1]:IsA("Sky") then
            customSkyModelObj = assets[1]
            customSkyModelObj.Name = "MovementDihCustomSky"
            customSkyModelObj.Parent = Lighting
        end
    end)
end

local function applyImageSky()
    if customImageSkyID == "" then return end
    local assetId = "rbxassetid://" .. customImageSkyID
    local sky = Lighting:FindFirstChildOfClass("Sky")
    if not sky then
        sky = Instance.new("Sky")
        sky.Name = "MovementDihImageSky"
        sky.Parent = Lighting
    end
    sky.SkyboxBk = assetId
    sky.SkyboxDn = assetId
    sky.SkyboxFt = assetId
    sky.SkyboxLf = assetId
    sky.SkyboxRt = assetId
    sky.SkyboxUp = assetId
end

local function resetSky()
    if customSkyModelObj then customSkyModelObj:Destroy(); customSkyModelObj = nil end
    local argoSky = Lighting:FindFirstChild("MovementDihCustomSky")
    if argoSky then argoSky:Destroy() end
    local argoImg = Lighting:FindFirstChild("MovementDihImageSky")
    if argoImg then argoImg:Destroy() end
    if originalSky then originalSky.Parent = Lighting end
end

local function resetLighting()
    Lighting.Brightness = lightingOriginals.Brightness
    Lighting.ClockTime = lightingOriginals.ClockTime
    Lighting.Ambient = lightingOriginals.Ambient
    Lighting.OutdoorAmbient = lightingOriginals.OutdoorAmbient
    colorCorrection.Brightness = 0
    colorCorrection.Contrast = 0
    colorCorrection.Saturation = 0
    colorCorrection.TintColor = Color3.new(1, 1, 1)
    sunRaysEffect.Enabled = false
    if atmosphere and atmosphereOriginals then
        atmosphere.Density = atmosphereOriginals.Density
        atmosphere.Offset = atmosphereOriginals.Offset
        atmosphere.Color = atmosphereOriginals.Color
        atmosphere.Decay = atmosphereOriginals.Decay
        atmosphere.Haze = atmosphereOriginals.Haze
    end
    resetSky()
end

local LightGroup1 = Tabs.Lighting:AddLeftGroupbox("Lighting Controls")
LightGroup1:AddSlider("LightBrightness", { Text = "Brightness", Min = 0, Max = 10, Default = math.floor(Lighting.Brightness * 10 + 0.5) / 10, Rounding = 1, Callback = function(value) Lighting.Brightness = value end })
LightGroup1:AddSlider("LightSaturation", { Text = "Saturation", Min = -1, Max = 1, Default = 0, Rounding = 2, Callback = function(value) colorCorrection.Saturation = value end })
LightGroup1:AddSlider("LightContrast", { Text = "Contrast", Min = -1, Max = 1, Default = 0, Rounding = 2, Callback = function(value) colorCorrection.Contrast = value end })
LightGroup1:AddSlider("LightExposure", { Text = "Exposure", Min = -1, Max = 1, Default = 0, Rounding = 2, Callback = function(value) colorCorrection.Brightness = value end })
LightGroup1:AddSlider("LightClockTime", { Text = "Time of Day", Min = 0, Max = 24, Default = Lighting.ClockTime, Rounding = 1, Callback = function(value) Lighting.ClockTime = value end })
LightGroup1:AddButton({ Text = "Reset Lighting to Original", Func = function() resetLighting() end })

local LightGroupSun = Tabs.Lighting:AddLeftGroupbox("Sun Rays")
LightGroupSun:AddToggle("EnableSunRays", { Text = "Enable Sun Rays", Default = false, Callback = function(state) sunRaysEffect.Enabled = state end })
LightGroupSun:AddSlider("SunRaysIntensity", { Text = "Intensity", Min = 0, Max = 1, Default = 0.5, Rounding = 2, Callback = function(value) sunRaysEffect.Intensity = value end })
LightGroupSun:AddSlider("SunRaysSpread", { Text = "Spread", Min = 0, Max = 1, Default = 0.5, Rounding = 2, Callback = function(value) sunRaysEffect.Spread = value end })

local LightGroupAtmo = Tabs.Lighting:AddLeftGroupbox("Fog & Sky Temperature")
LightGroupAtmo:AddSlider("AtmoFogDensity", { Text = "Fog Density", Min = 0, Max = 1, Default = atmosphere and atmosphere.Density or 0, Rounding = 2, Callback = function(value) getOrCreateAtmosphere().Density = value end })
LightGroupAtmo:AddLabel("Fog Color"):AddColorPicker("AtmoFogColor", { Default = atmosphere and atmosphere.Color or Color3.fromRGB(199, 199, 199), Title = "Fog Color", Callback = function(color) getOrCreateAtmosphere().Color = color end })
LightGroupAtmo:AddSlider("AtmoHaze", { Text = "Sky Temperature (Haze)", Min = 0, Max = 10, Default = atmosphere and atmosphere.Haze or 0, Rounding = 1, Callback = function(value) getOrCreateAtmosphere().Haze = value end })
LightGroupAtmo:AddLabel("Sky Tint (Warm = orange/red, Cool = blue)"):AddColorPicker("AtmoDecay", { Default = atmosphere and atmosphere.Decay or Color3.fromRGB(255, 100, 30), Title = "Sky Tint Color", Callback = function(color) getOrCreateAtmosphere().Decay = color end })

local LightGroup2 = Tabs.Lighting:AddRightGroupbox("Sky Box (Model ID)")
LightGroup2:AddInput("SkyboxModelIDInput", { Default = "", Text = "Sky Object ID", Placeholder = "Model ID from Toolbox", Numeric = true, Callback = function(value) customSkyModelID = value:gsub("%D", "") end })
LightGroup2:AddButton({ Text = "Apply Sky", Func = function() applyCustomSkyModel() end })
LightGroup2:AddButton({ Text = "Reset Sky", Func = function() resetSky() end })

local LightGroup3 = Tabs.Lighting:AddRightGroupbox("Sky Box (Image ID)")
LightGroup3:AddInput("SkyImageIDInput", { Default = "", Text = "Image Asset ID", Placeholder = "e.g. 123280270736635", Numeric = true, Callback = function(value) customImageSkyID = value:gsub("%D", "") end })
LightGroup3:AddButton({ Text = "Apply Image Sky", Func = function() applyImageSky() end })
LightGroup3:AddButton({ Text = "Reset Sky", Func = function() resetSky() end })

local LagGroup1 = Tabs.LagSwitch:AddLeftGroupbox("Lag Switch")
LagGroup1:AddDropdown("LagModeDropdown", { Values = {"Normal", "Demon", "FastFlag"}, Default = "Normal", Text = "Lag Mode", Callback = function(v) C.lagConfig.Mode = v end })
LagGroup1:AddSlider("LagDelayMS", { Text = "Delay (ms)", Min = 50, Max = 2000, Default = 200, Rounding = 0, Callback = function(v) C.lagConfig.MSDelay = v end })
LagGroup1:AddLabel("Lag Switch Key"):AddKeyPicker("LagSwitchKey", { Default = "H", SyncToggleState = false, Mode = "Toggle", Text = "Lag Switch Key", ChangedCallback = function() end })

safeConnect(UserInputService.InputBegan, function(input, gp)
    if gp then return end
    local kp = Options["LagSwitchKey"]
    if kp then
        local ok, kc = pcall(function() return Enum.KeyCode[kp.Value] end)
        if ok and kc and input.KeyCode == kc then
            if C.lagActive then return end
            C.lagActive = true
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if not char or not hrp then C.lagActive = false; return end
            local vel = hrp.AssemblyLinearVelocity
            if vel.Magnitude < 1 then C.lagActive = false; return end
            local t = tick(); while tick() - t < C.lagConfig.MSDelay * 0.002 do end
            if C.lagConfig.Mode == "FastFlag" then
                pcall(function() setfflag("MaxMissedWorldStepsRemembered", "9999") end)
            elseif C.lagConfig.Mode == "Demon" then
                C.psRayParams.FilterDescendantsInstances = {char}
                local dir = Vector3.new(vel.X, 0, vel.Z)
                if dir.Magnitude > 0 then dir = dir.Unit end
                local dist = math.min(vel.Magnitude * C.lagConfig.MSDelay * 0.002 * math.random(2, 10), 30)
                local tgt = hrp.Position + dir * dist
                local hit = workspace:Raycast(hrp.Position, tgt - hrp.Position, C.psRayParams)
                if hit then tgt = hit.Position - dir * 2 end
                local safe = workspace:Raycast(hrp.Position, tgt - hrp.Position, C.psRayParams)
                if safe then tgt = safe.Position + Vector3.new(0, 2, 0) - dir * 2 end
                hrp.CFrame = CFrame.new(tgt, tgt + hrp.CFrame.LookVector)
                hrp.AssemblyLinearVelocity = vel
            end
            C.lagActive = false
        end
    end
end)

local LagGroup2 = Tabs.LagSwitch:AddRightGroupbox("Mode Info")
LagGroup2:AddLabel("Normal: freeze only, no teleport")
LagGroup2:AddLabel("FastFlag: freeze + MaxMissedWorldSteps")
LagGroup2:AddLabel("Demon: freeze + smart forward teleport")

local SettingsGroup = Tabs.Settings:AddLeftGroupbox("Menu Settings")
SettingsGroup:AddLabel("Global Menu Open/Close Shortcut"):AddKeyPicker("MenuKeybind", { Default = "RightControl", NoUI = true, Text = "Menu keybind" })
Library.ToggleKeybind = Options.MenuKeybind

SettingsGroup:AddButton({ Text = "Terminate Script & Clear Cache", Func = function()
    for _, conn in ipairs(C.RunningConnections) do if conn then conn:Disconnect() end end
    if C.bounceConnection then C.bounceConnection:Disconnect() end
    if _G.WallClimbConnection then _G.WallClimbConnection:Disconnect() end
    if C.bhopConnection then C.bhopConnection:Disconnect() end
    if C.feEmoteSpeedConn then C.feEmoteSpeedConn:Disconnect() end
    if C.feEmotingConn then C.feEmotingConn:Disconnect() end
    if C.edgeBoostConn then C.edgeBoostConn:Disconnect() end
    if C.hideOthersConn then C.hideOthersConn:Disconnect() end
    
    for _, conn in ipairs(C.invisiWallConnections) do
        pcall(function() conn:Disconnect() end)
    end
    C.invisiWallConnections = {}
    if #C.invisiWallStoredParts > 0 then
        invisiWallRestoreStoredParts()
    end
    
    for _, player in ipairs(game:GetService("Players"):GetPlayers()) do setCharacterVisibility(player.Character, true) end
    C.bhopHoldSystemEnabled = false
    C.bhopHoldActive = false
    toggleAutoBounce(false)
    C.customHitboxEnabled = false
    C.CustomHitboxFolder:Destroy()
    resetLighting()
    if colorCorrection then colorCorrection:Destroy() end
    if sunRaysEffect then sunRaysEffect:Destroy() end
    if C.hop360Conn then C.hop360Conn:Disconnect() end
    if C.pixelSurfAutoConn then C.pixelSurfAutoConn:Disconnect() end
    Library:Unload()
end })

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind" })
ThemeManager:SetFolder("MovementDihConfigs")
SaveManager:SetFolder("MovementDihConfigs/MvmDih")
SaveManager:BuildConfigSection(Tabs.Settings)
ThemeManager:ApplyToTab(Tabs.Settings)
SaveManager:LoadAutoloadConfig()

safeConnect(RunService.RenderStepped, function()
    if C.bhopHoldSystemEnabled and C.bhopHoldActive then applyBhopFriction() end
end)

safeConnect(RunService.Heartbeat, function()
    local isBhopActive = C.bhopHoldSystemEnabled and C.bhopHoldActive
    if isBhopActive then
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hum and hrp and hum.Health > 0 then
            local now = tick()
            if isCharacterGrounded(char, hrp, hum) and (now - C.LastJump) > 0.15 then
                C.LastJump = now
                pcall(function()
                    LocalPlayer.PlayerScripts.Events.temporary_events.JumpReact:Fire()
                    LocalPlayer.PlayerScripts.Events.temporary_events.EndJump:Fire()
                end)
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end
    
    if C.downDashEnabled and LocalPlayer.Character then
        local char = LocalPlayer.Character
        local hum = char:FindFirstChildOfClass("Humanoid")
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local camera = workspace.CurrentCamera
        if hum and hrp and camera then
            local wasDown = C.isDownedState
            C.isDownedState = checkIsPlayerDown(char, hum)
            if wasDown and not C.isDownedState then
                C.downDashPreActivated = false
                C.downDashActive = false
                C.downDashCurrentSpeed = 0
            end
            if not wasDown and C.isDownedState then
                if not C.downDashHasUsed then C.downDashHasUsed = true end
            end
            local canDash = C.isDownedState and (C.downDashActive or C.downDashPreActivated)
            if canDash then
                C.downDashCurrentSpeed = C.downDashCurrentSpeed + (C.downDashSpeed - C.downDashCurrentSpeed) * 0.2
                if C.downDashCurrentSpeed > C.downDashSpeed then C.downDashCurrentSpeed = C.downDashSpeed end
                local camLook = camera.CFrame.LookVector
                local moveDir = Vector3.new(camLook.X, 0, camLook.Z)
                if moveDir.Magnitude >= 0.01 then
                    moveDir = moveDir.Unit
                    local vy = hrp.AssemblyLinearVelocity.Y
                    hrp.AssemblyLinearVelocity = Vector3.new(moveDir.X * C.downDashCurrentSpeed, vy, moveDir.Z * C.downDashCurrentSpeed)
                end
            else
                if C.downDashCurrentSpeed > 0.5 then
                    C.downDashCurrentSpeed = C.downDashCurrentSpeed * 0.85
                    local camLook = camera.CFrame.LookVector
                    local moveDir = Vector3.new(camLook.X, 0, camLook.Z)
                    if moveDir.Magnitude > 0.01 then
                        moveDir = moveDir.Unit
                        local vy = hrp.AssemblyLinearVelocity.Y
                        hrp.AssemblyLinearVelocity = Vector3.new(moveDir.X * C.downDashCurrentSpeed, vy, moveDir.Z * C.downDashCurrentSpeed)
                    end
                else
                    C.downDashCurrentSpeed = 0
                end
            end
        end
    end
end)
safeConnect(UserInputService.InputBegan, function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Space then
        if C.bhopHoldSystemEnabled then C.bhopHoldActive = true; applyBhopFriction() end
        if C.bhopHoldFeature then C.bhopHoldActive = true; checkBhopState() end
    end
    if C.downDashEnabled and (input.KeyCode == Enum.KeyCode.LeftControl or input.KeyCode == Enum.KeyCode.C) then
        C.downDashActive = true
        if not C.isDownedState then C.downDashPreActivated = true end
    end
    if C.turnbindEnabled then
        local leftEnum = parseKeyCode(C.turnbindLeftKey)
        local rightEnum = parseKeyCode(C.turnbindRightKey)
        if leftEnum and input.KeyCode == leftEnum then sendKeyEvent(Enum.KeyCode.Left, true)
        elseif rightEnum and input.KeyCode == rightEnum then sendKeyEvent(Enum.KeyCode.Right, true) end
    end
    if input.KeyCode == Enum.KeyCode[C.autoBounceKeybind] then
        local newState = not C.autoBounceEnabled
        toggleAutoBounce(newState)
        pcall(function() Toggles.EnableAutoBounceLoop:SetValue(newState) end)
    end
    if C.wallClimbEnabled and C.wallClimbMode ~= "Auto" and input.KeyCode == Enum.KeyCode[C.wallClimbKeybind] then
        if C.wallClimbMode == "Toggle" then
            if C.IsHoldingH then stopWallHold() else startWallHold() end
        elseif C.wallClimbMode == "Hold" then
            startWallHold()
        end
    end
end)

safeConnect(UserInputService.InputEnded, function(input)
    if input.KeyCode == Enum.KeyCode.Space then
        C.bhopHoldActive = false
        applyBhopFriction(true)
        C.bhopHoldActive = false
        checkBhopState()
    end
    if input.KeyCode == Enum.KeyCode.LeftControl or input.KeyCode == Enum.KeyCode.C then
        C.downDashActive = false
        if not C.isDownedState then C.downDashPreActivated = false end
        C.downDashCurrentSpeed = 0
    end
    if C.turnbindEnabled then
        local leftEnum = parseKeyCode(C.turnbindLeftKey)
        local rightEnum = parseKeyCode(C.turnbindRightKey)
        if leftEnum and input.KeyCode == leftEnum then sendKeyEvent(Enum.KeyCode.Left, false)
        elseif rightEnum and input.KeyCode == rightEnum then sendKeyEvent(Enum.KeyCode.Right, false) end
    end
    if C.wallClimbEnabled and C.wallClimbMode == "Hold" and input.KeyCode == Enum.KeyCode[C.wallClimbKeybind] then
        stopWallHold()
    end
end)

if LocalPlayer.Character then task.spawn(setupCharacter, LocalPlayer.Character) end
safeConnect(LocalPlayer.CharacterAdded, setupCharacter)

safeConnect(LocalPlayer.CharacterAdded, function()
    task.wait(1)
    if not C.feEmoteRunnerActive then
        pcall(function()
            feSetupEmoteSpeedChange(true)
            feSetupTPCameraOnEmoting(true)
        end)
    end
end)

task.wait(1)
if C.removeInvisWallsEnabled then
    invisiWallRunCleanAndFix()
    invisiWallSetupKeybind()
end

Library:Notify({ Title = "Movement Dih", Description = "Done!, please follow my tiktok account : @thatoneargo", Time = 5 })
end)()
