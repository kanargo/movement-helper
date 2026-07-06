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
    Footer = "version : beta_V2",
    NotifySide = "Right",
    ShowCustomCursor = True,
})

local currentSettings = {
    Speed = 1500,
    JumpPowerValue = 3.5,
    JumpCap = 1,
    AirStrafeAcceleration = 187
}

getgenv().bhopHoldSystemEnabled = false
getgenv().bhopHoldActive        = false
getgenv().bhopMode              = "Acceleration"
getgenv().bhopAccelValue        = -0.5

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

local downDashEnabled = false
local downDashSpeed = 185
local downDashCurrentSpeed = 0
local downDashActive = false
local downDashPreActivated = false
local isDownedState = false
local downDashHasUsed = false

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

local feOriginalEmotes = {}
for i = 1, 6 do
    feOriginalEmotes[i] = LocalPlayer:GetAttribute("Emote" .. i) or ""
end

local feHookInstalled   = false
local feBlockRemote     = false
local fePendingEmotes   = {}
local feValidEmotes     = {}
local feEmoteInputs     = {}
local feEmoteSpeedConn    = nil 
local feEmotingConn       = nil
local feEmoteSpeedCache   = {}
local feEmoteRunnerActive = false 
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

feValidEmotes = feScanValidEmotes()

local function feIsValidEmote(name)
    if not name or name == "" then return false end
    return feValidEmotes[name] == true
end

local function feGetTagData()
    local char = LocalPlayer.Character
    if char then return char:GetAttribute("Tag") end
    return nil
end

local function feGetEmoteSpeedMult(emoteName)
    if not feIsValidEmote(emoteName) then return 1 end
    if feEmoteSpeedCache[emoteName] then return feEmoteSpeedCache[emoteName] end
    local itemsFolder = ReplicatedStorage:FindFirstChild("Items")
    if not itemsFolder then return 1 end
    local emotesFolder = itemsFolder:FindFirstChild("Emotes")
    if not emotesFolder then return 1 end
    local emoteModule = emotesFolder:FindFirstChild(emoteName)
    if not emoteModule or not emoteModule:IsA("ModuleScript") then return 1 end
    local ok, emoteData = pcall(require, emoteModule)
    if not ok or not emoteData then return 1 end
    local speedMult = emoteData.SpeedMult
        or (emoteData.EmoteInfo and emoteData.EmoteInfo.SpeedMult)
        or 1
    feEmoteSpeedCache[emoteName] = speedMult
    return speedMult
end

local function feSetupEmoteSpeedChange(apply)
    if feEmoteSpeedConn then
        feEmoteSpeedConn:Disconnect()
        feEmoteSpeedConn = nil
    end
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
            if esv then
                esv.Value = mult
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
        feEmoteSpeedConn = localModel:GetAttributeChangedSignal("Emoting"):Connect(function()
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
    if feEmotingConn then feEmotingConn:Disconnect(); feEmotingConn = nil end
    if not apply then return end
    local gamePlayers = Workspace:FindFirstChild("Game") and Workspace.Game:FindFirstChild("Players")
    if not gamePlayers then return end
    local localModel = gamePlayers:FindFirstChild(LocalPlayer.Name)
    if not localModel then return end
    feEmotingConn = localModel:GetAttributeChangedSignal("Emoting"):Connect(function()
        if localModel:GetAttribute("Emoting") == true then
            local char = LocalPlayer.Character
            if char then
                local clientEvent = char:FindFirstChild("Client")
                if clientEvent then
                    pcall(function()
                        firesignal(clientEvent.OnClientEvent, "TPCamera", { Zoom = 10 })
                    end)
                end
            end
        end
    end)
end

local function feTriggerTagEmote(slot)
    local swapName = fePendingEmotes[slot]
    if not swapName or swapName == "" then
        swapName = LocalPlayer:GetAttribute("Emote" .. slot)
    end
    if not swapName or swapName == "" then return end
    if not feIsValidEmote(swapName) then return end
    local tagData = feGetTagData()
    if not tagData then return end
    local emoteEvent = ReplicatedStorage:FindFirstChild("Events")
        and ReplicatedStorage.Events:FindFirstChild("Character")
        and ReplicatedStorage.Events.Character:FindFirstChild("Emote")
    if emoteEvent then
        task.defer(function()
            firesignal(emoteEvent.OnClientEvent, tagData, swapName)
        end)
    end
end

local function feInstallHook()
    if feHookInstalled then return end
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
                    if num:match("^[1-6]$") then
                        if feBlockRemote then
                            feTriggerTagEmote(tonumber(num))
                            return
                        end
                    end
                end
                return old(self, ...)
            end
            setreadonly(mt, true)
            feHookInstalled = true
        end
    end)
end

local function feApplyAllEmotes()
    feBlockRemote = true
    pcall(function()
        for i = 1, 6 do
            if fePendingEmotes[i] and fePendingEmotes[i] ~= "" and feIsValidEmote(fePendingEmotes[i]) then
                LocalPlayer:SetAttribute("Emote" .. i, fePendingEmotes[i])
            end
        end
        fePendingEmotes = {}
        feInstallHook()
        if not feEmoteRunnerActive then
            feSetupEmoteSpeedChange(true)
            feSetupTPCameraOnEmoting(true)
        end
    end)
end

local function feResetAllEmotes()
    feBlockRemote = false
    pcall(function()
        feSetupEmoteSpeedChange(false)
        feSetupTPCameraOnEmoting(false)
        fePendingEmotes = {}
        for i = 1, 6 do
            LocalPlayer:SetAttribute("Emote" .. i, feOriginalEmotes[i])
            pcall(function() Options["FEEmoteSlot" .. i]:SetValue(feOriginalEmotes[i] or "") end)
        end
    end)
end

local auraColor = Color3.fromRGB(255, 0, 0)
local autoApplyAuraColor = false

local customAuraModelID = ""
local customAuraScale = 1
local customAuraTransparency = 0

local CUSTOM_AURA_EFFECT_CLASSES = {
    ParticleEmitter = true, Trail = true, Beam = true,
    PointLight = true, SpotLight = true, SurfaceLight = true,
    Sparkles = true, Fire = true, Smoke = true,
    BillboardGui = true, SurfaceGui = true,
}

local function extractCustomAuraEffects(obj, targetPart, scale, transparency)
    for _, child in ipairs(obj:GetChildren()) do
        if CUSTOM_AURA_EFFECT_CLASSES[child.ClassName] then
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
    if customAuraModelID == "" then return end
    local character = LocalPlayer.Character
    if not character then return end
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    if character:FindFirstChild("CustomAuraFolder") then
        character.CustomAuraFolder:Destroy()
    end

    local id = customAuraModelID:match("%d+") or customAuraModelID
    local success, assets = pcall(function()
        return game:GetObjects("rbxassetid://" .. id)
    end)
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

    extractCustomAuraEffects(auraModel, anchor, customAuraScale, customAuraTransparency)
end

local function clearCustomAura()
    local character = LocalPlayer.Character
    if character and character:FindFirstChild("CustomAuraFolder") then
        character.CustomAuraFolder:Destroy()
    end
end

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
    if not bhopLoaded then return end
    pcall(function()
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if not char or not hum then return end
        local isBhopActive = autoJumpEnabled or (bhopHoldFeature and bhopHoldActive)
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
    if autoJumpEnabled or (bhopHoldFeature and bhopHoldActive) then
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

    local isBhopActive = autoJumpEnabled or (bhopHoldFeature and bhopHoldActive)
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
        if jumpcap > 1 and jumps >= 1 and jumps < jumpcap and tick() - jumpTick > 0.05 then
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

local function forceScanCarPole()
    local count = 0
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj.Name == "CarPole" then
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
    if not autoBounceEnabled then return end
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")

    if hum and hrp and hum.Health > 0 then
        local isGrounded = (hum.FloorMaterial ~= Enum.Material.Air) or (hum:GetState() == Enum.HumanoidStateType.Landed)

        if isGrounded and not bounceDebounce then
            bounceDebounce = true

            hum:ChangeState(Enum.HumanoidStateType.Jumping)

            hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, 0, hrp.AssemblyLinearVelocity.Z)

            local customImpulse = (bouncePowerValue / 2) * hrp.Mass
            hrp:ApplyImpulse(Vector3.new(0, customImpulse, 0))

            task.delay(0.05, function()
                bounceDebounce = false
            end)
        end
    end
end

function toggleAutoBounce(state)
    autoBounceEnabled = state
    if state then
        bounceDebounce = false
        if bounceConnection then bounceConnection:Disconnect() end
        bounceConnection = RunService.PostSimulation:Connect(onBouncePostSimulation)
    else
        if bounceConnection then bounceConnection:Disconnect(); bounceConnection = nil end
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

local MoveGroup6 = Tabs.Movement:AddLeftGroupbox("Down Dash Overhaul")
MoveGroup6:AddToggle("EnableDownDashOverhaul", {
    Text = "Enable Down Dash Overhaul", Default = false,
    Callback = function(state)
        downDashEnabled = state
        if not state then
            downDashActive = false
            downDashPreActivated = false
            downDashCurrentSpeed = 0
        end
    end
})
MoveGroup6:AddSlider("DownDashSpeedSlider", {
    Text = "Down Dash Speed", Min = 20, Max = 300, Default = 185, Rounding = 0,
    Callback = function(value) downDashSpeed = value end
})

local MoveGroup7 = Tabs.Movement:AddLeftGroupbox("Emote Utilities")
MoveGroup7:AddButton({
    Text = "Nonmovable Emote", DoubleClick = false,
    Func = function()
        local EmotesFolder = ReplicatedStorage:WaitForChild("Items"):WaitForChild("Emotes")
        for _, emoteModule in pairs(EmotesFolder:GetChildren()) do
            if emoteModule:IsA("ModuleScript") then
                local ok, emoteData = pcall(require, emoteModule)
                if ok and emoteData and emoteData.EmoteInfo and emoteData.EmoteInfo.SpeedMult == 0 then
                    emoteData.EmoteInfo.SpeedMult = 0.7
                end
            end
        end
    end
})

local edgeBoostEnabled = false
local edgeBoostPower   = 100
local edgeBoostConn    = nil
local edgeVMin         = 1.0

local function applyEdgeBoost()
    local char = LocalPlayer.Character
    local hrp  = char and char:FindFirstChild("HumanoidRootPart")
    local hum  = char and char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum or hum.Health <= 0 then return end
    if hrp.AssemblyLinearVelocity.Y >= -edgeVMin then return end

    local touching = hrp:GetTouchingParts()
    if #touching == 0 then return end

    local skipWords = {"bounce","boost","launch","jump","pad","ramp","platform"}
    local isBounce  = false
    for _, pt in pairs(touching) do
        local n = string.lower(pt.Name)
        for _, w in pairs(skipWords) do
            if n:find(w) then isBounce = true break end
        end
        if not isBounce and pt.Parent then
            local pn = string.lower(pt.Parent.Name)
            for _, w in pairs(skipWords) do
                if pn:find(w) then isBounce = true break end
            end
        end
        if isBounce then break end
    end

    if not isBounce then
        local vel = hrp.AssemblyLinearVelocity
        hrp.AssemblyLinearVelocity = Vector3.new(vel.X, 0, vel.Z) + Vector3.new(0, edgeBoostPower, 0)
    end
end

local MoveGroup8 = Tabs.Movement:AddRightGroupbox("Edge Boost")
MoveGroup8:AddToggle("EnableEdgeBoost", {
    Text = "Enable Edge Boost", Default = false,
    Callback = function(state)
        edgeBoostEnabled = state
        if state then
            if edgeBoostConn then edgeBoostConn:Disconnect() end
            edgeBoostConn = RunService.Stepped:Connect(applyEdgeBoost)
        else
            if edgeBoostConn then edgeBoostConn:Disconnect(); edgeBoostConn = nil end
        end
    end
})
MoveGroup8:AddSlider("EdgeBoostPower", {
    Text = "Edge Power", Min = 10, Max = 500, Default = 100, Rounding = 0,
    Callback = function(value) edgeBoostPower = value end
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
LegacyGroup4:AddButton({
    Text = "Scan & Apply CarPole Hitbox", DoubleClick = false,
    Func = function() forceScanCarPole() end
})

local fastTurnConnection = nil
local fastTurnActive = false

local function runFastTurn()
    if fastTurnActive then return end
    fastTurnActive = true
    local char = LocalPlayer.Character
    if not char then return end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    local rootPart = char:FindFirstChild("HumanoidRootPart")
    if not humanoid or not rootPart then return end
    local TURN_SPEED = 22
    humanoid.AutoRotate = false
    if fastTurnConnection then fastTurnConnection:Disconnect() end
    fastTurnConnection = RunService.RenderStepped:Connect(function(dt)
        if not char or not humanoid or not rootPart then return end
        if humanoid.MoveDirection.Magnitude > 0 then
            local targetCFrame = CFrame.lookAt(rootPart.Position, rootPart.Position + humanoid.MoveDirection)
            rootPart.CFrame = rootPart.CFrame:lerp(targetCFrame, TURN_SPEED * dt)
        end
    end)
    LocalPlayer.CharacterAdded:Connect(function(newChar)
        fastTurnActive = false
        if fastTurnConnection then fastTurnConnection:Disconnect(); fastTurnConnection = nil end
    end)
end

local LegacyGroup5 = Tabs.Legacy:AddRightGroupbox("Fast Turn")
LegacyGroup5:AddButton({
    Text = "Fast Turn",
    Func = function() runFastTurn() end
})

SafeConnect(LocalPlayer.CharacterAdded, function()
    task.wait(1)
    if not feEmoteRunnerActive then
        pcall(function()
            feSetupEmoteSpeedChange(true)
            feSetupTPCameraOnEmoting(true)
        end)
    end
end)

local LegacyGroupFE = Tabs.Legacy:AddLeftGroupbox("FE Change Emote")
for i = 1, 6 do
    local currentVal = LocalPlayer:GetAttribute("Emote" .. i) or ""
    feEmoteInputs[i] = LegacyGroupFE:AddInput("FEEmoteSlot" .. i, {
        Default = currentVal,
        Text = "Emote Slot " .. i,
        Placeholder = "e.g. Wave, Dab...",
        Callback = function(value)
            fePendingEmotes[i] = value:gsub("%s+", "")
        end
    })
end
LegacyGroupFE:AddButton({
    Text = "Apply Emotes",
    Func = function() feApplyAllEmotes() end
})
LegacyGroupFE:AddButton({
    Text = "Reset Emotes",
    Func = function() feResetAllEmotes() end
})
LegacyGroupFE:AddToggle("EmoteRunner", {
    Text = "Emote Runner",
    Default = false,
    Callback = function(state)
        feEmoteRunnerActive = state
        if state then
            feSetupEmoteSpeedChange(false)
            feSetupTPCameraOnEmoting(false)
        else
            feSetupEmoteSpeedChange(true)
            feSetupTPCameraOnEmoting(true)
            feInstallHook()
        end
    end
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

local VisualGroupCC = Tabs.Visuals:AddLeftGroupbox("Custom Cosmetic")
VisualGroupCC:AddInput("CustomAuraModelID", {
    Default = "", Text = "Model Asset ID", Placeholder = "e.g. 10953055906",
    Callback = function(v) customAuraModelID = v:gsub("%s+", "") end
})
VisualGroupCC:AddSlider("CustomAuraScaleSlider", {
    Text = "Aura Scale", Min = 0.1, Max = 10, Default = 1, Rounding = 1,
    Callback = function(value) customAuraScale = value end
})
VisualGroupCC:AddSlider("CustomAuraTransparencySlider", {
    Text = "Aura Transparency", Min = 0, Max = 1, Default = 0, Rounding = 2,
    Callback = function(value) customAuraTransparency = value end
})
VisualGroupCC:AddButton({
    Text = "Load Aura",
    Func = function() applyCustomAura() end
})
VisualGroupCC:AddButton({
    Text = "Clear Aura",
    Func = function() clearCustomAura() end
})

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
        if feEmoteSpeedConn then feEmoteSpeedConn:Disconnect() end
        if feEmotingConn then feEmotingConn:Disconnect() end
        if edgeBoostConn then edgeBoostConn:Disconnect() end
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

    local isBhopActive = getgenv().bhopHoldSystemEnabled and getgenv().bhopHoldActive
    if isBhopActive then
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

    if downDashEnabled and LocalPlayer.Character then
        local char = LocalPlayer.Character
        local hum = char:FindFirstChildOfClass("Humanoid")
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local camera = workspace.CurrentCamera

        if hum and hrp and camera then
            local wasDown = isDownedState
            isDownedState = checkIsPlayerDown(char, hum)

            if wasDown and not isDownedState then
                downDashPreActivated = false
                downDashActive = false
                downDashCurrentSpeed = 0
            end

            if not wasDown and isDownedState then
                if not downDashHasUsed then
                    downDashHasUsed = true
                end
            end

            local canDash = isDownedState and (downDashActive or downDashPreActivated)

            if canDash then
                downDashCurrentSpeed = downDashCurrentSpeed + (downDashSpeed - downDashCurrentSpeed) * 0.2
                if downDashCurrentSpeed > downDashSpeed then downDashCurrentSpeed = downDashSpeed end

                local camLook = camera.CFrame.LookVector
                local moveDir = Vector3.new(camLook.X, 0, camLook.Z)
                if moveDir.Magnitude >= 0.01 then
                    moveDir = moveDir.Unit
                    local vy = hrp.AssemblyLinearVelocity.Y
                    hrp.AssemblyLinearVelocity = Vector3.new(
                        moveDir.X * downDashCurrentSpeed,
                        vy,
                        moveDir.Z * downDashCurrentSpeed
                    )
                end
            else
                if downDashCurrentSpeed > 0.5 then
                    downDashCurrentSpeed = downDashCurrentSpeed * 0.85
                    local camLook = camera.CFrame.LookVector
                    local moveDir = Vector3.new(camLook.X, 0, camLook.Z)
                    if moveDir.Magnitude > 0.01 then
                        moveDir = moveDir.Unit
                        local vy = hrp.AssemblyLinearVelocity.Y
                        hrp.AssemblyLinearVelocity = Vector3.new(
                            moveDir.X * downDashCurrentSpeed,
                            vy,
                            moveDir.Z * downDashCurrentSpeed
                        )
                    end
                else
                    downDashCurrentSpeed = 0
                end
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

    if downDashEnabled and (input.KeyCode == Enum.KeyCode.LeftControl or input.KeyCode == Enum.KeyCode.C) then
        downDashActive = true
        if not isDownedState then
            downDashPreActivated = true
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

    if input.KeyCode == Enum.KeyCode.LeftControl or input.KeyCode == Enum.KeyCode.C then
        downDashActive = false
        if not isDownedState then
            downDashPreActivated = false
        end
        downDashCurrentSpeed = 0
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

    downDashCurrentSpeed = 0
    downDashActive = false
    downDashPreActivated = false
    isDownedState = false
    downDashHasUsed = false

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
