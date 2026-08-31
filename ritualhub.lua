-- ============================================================
-- RITUAL HUB VERSION 12.5 | KEY SYSTEM (CASE‑INSENSITIVE)
-- ============================================================
local Players = game:GetService("Players")
local player = Players.LocalPlayer or Players:WaitForChildOfClass("Player")
local playerGui = player:WaitForChild("PlayerGui", 15)

if not playerGui then return end

-- ============================================================
-- KEY SYSTEM (one‑time per session, case‑insensitive)
-- ============================================================
local requiredKey = "ritual"

-- If already authenticated, skip the key popup
if _G.ritualKeyEntered == true then
    -- Proceed to main hub
else
    -- Show key entry popup
    local keyGui = Instance.new("ScreenGui")
    keyGui.Name = "RitualKeyUI"
    keyGui.ResetOnSpawn = false
    keyGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    keyGui.Parent = playerGui

    local keyFrame = Instance.new("Frame")
    keyFrame.Size = UDim2.new(0, 300, 0, 160)
    keyFrame.Position = UDim2.new(0.5, -150, 0.5, -80)
    keyFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    keyFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    keyFrame.BackgroundTransparency = 0
    keyFrame.Active = true
    keyFrame.Draggable = true
    keyFrame.Parent = keyGui
    Instance.new("UICorner", keyFrame).CornerRadius = UDim.new(0, 12)
    local keyStroke = Instance.new("UIStroke", keyFrame)
    keyStroke.Color = Color3.fromRGB(255, 215, 0)
    keyStroke.Thickness = 2

    local keyTitle = Instance.new("TextLabel", keyFrame)
    keyTitle.Size = UDim2.new(1, 0, 0, 30)
    keyTitle.Position = UDim2.new(0, 0, 0, 10)
    keyTitle.BackgroundTransparency = 1
    keyTitle.Text = "🔑 Enter Key"
    keyTitle.Font = Enum.Font.GothamBlack
    keyTitle.TextSize = 16
    keyTitle.TextColor3 = Color3.fromRGB(255, 215, 0)
    keyTitle.TextXAlignment = Enum.TextXAlignment.Center

    local keyBox = Instance.new("TextBox", keyFrame)
    keyBox.Size = UDim2.new(0, 180, 0, 30)
    keyBox.Position = UDim2.new(0.5, -90, 0, 50)
    keyBox.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    keyBox.Text = ""
    keyBox.PlaceholderText = "Type key here..."
    keyBox.Font = Enum.Font.GothamBold
    keyBox.TextSize = 12
    keyBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    keyBox.TextXAlignment = Enum.TextXAlignment.Center
    Instance.new("UICorner", keyBox).CornerRadius = UDim.new(0, 6)
    local boxStroke = Instance.new("UIStroke", keyBox)
    boxStroke.Color = Color3.fromRGB(255, 215, 0)
    boxStroke.Thickness = 1

    local submitBtn = Instance.new("TextButton", keyFrame)
    submitBtn.Size = UDim2.new(0, 100, 0, 30)
    submitBtn.Position = UDim2.new(0.5, -50, 0, 100)
    submitBtn.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
    submitBtn.Text = "Submit"
    submitBtn.Font = Enum.Font.GothamBlack
    submitBtn.TextSize = 12
    submitBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
    Instance.new("UICorner", submitBtn).CornerRadius = UDim.new(0, 8)

    local errorLabel = Instance.new("TextLabel", keyFrame)
    errorLabel.Size = UDim2.new(1, 0, 0, 20)
    errorLabel.Position = UDim2.new(0, 0, 0, 130)
    errorLabel.BackgroundTransparency = 1
    errorLabel.Text = ""
    errorLabel.Font = Enum.Font.GothamBold
    errorLabel.TextSize = 11
    errorLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
    errorLabel.TextXAlignment = Enum.TextXAlignment.Center

    submitBtn.MouseButton1Click:Connect(function()
        -- Case‑insensitive check
        if string.lower(keyBox.Text) == string.lower(requiredKey) then
            _G.ritualKeyEntered = true
            keyGui:Destroy()
            runMain()
        else
            errorLabel.Text = "❌ Wrong key. Try again."
            keyBox.Text = ""
        end
    end)

    keyBox.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            submitBtn.MouseButton1Click:Fire()
        end
    end)

    -- Wait until key is entered
    while not _G.ritualKeyEntered do
        task.wait(0.5)
    end
end

-- ============================================================
-- MAIN HUB FUNCTION
-- ============================================================
function runMain()
    -- ============================================================
    -- RITUAL HUB VERSION 12.5 | LOCAL DEV STANDALONE
    -- ============================================================

    local Players = game:GetService("Players")
    local TweenService = game:GetService("TweenService")
    local UserInputService = game:GetService("UserInputService")
    local RunService = game:GetService("RunService")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local HttpService = game:GetService("HttpService")
    local Lighting = game:GetService("Lighting")

    local VirtualInputManager = nil
    pcall(function() VirtualInputManager = game:GetService("VirtualInputManager") end)

    local player = Players.LocalPlayer or Players:FindFirstChildOfClass("Player")

    local camera = workspace.CurrentCamera
    local mouse = nil
    pcall(function() mouse = player and player:GetMouse() end)

    local playerGui = nil
    pcall(function() 
        if player then
            playerGui = player:FindFirstChild("PlayerGui") or player:WaitForChild("PlayerGui", 5)
        end
    end)

    scriptStartTime = os.time()
    totalExecutions = 0
    startBounty = 0
    accumulatedBountyGained = 0

    pcall(function()
        if isfile and readfile and isfile("RitualHub_Bounty.json") then
            local bData = HttpService:JSONDecode(readfile("RitualHub_Bounty.json"))
            if bData and bData.Gained then accumulatedBountyGained = bData.Gained end
        end
    end)

    function SaveLocalBounty(gained)
        accumulatedBountyGained = gained
        pcall(function()
            if writefile then
                writefile("RitualHub_Bounty.json", HttpService:JSONEncode({Gained = gained}))
            end
        end)
    end

    -- Estado
    SoruInfinitoEnabled = false
    SoruAimbotEnabled = false
    soruMaxDist = 1000
    AimlockPlayerEnabled = false
    AimlockNpcEnabled = false
    SilentAimPlayersEnabled = false
    SilentAimNPCsEnabled = false
    PlayerWidgetActive = false
    NpcWidgetActive = false
    SelectedSoruTarget = "Nearest"
    maxRange = 2500
    PlayersPosition = nil
    NPCPosition = nil

    -- Config Aimbot & Dragon Gun M1
    _G.G_DragonGunM1 = false
    _G.G_AttackMobs = true
    _G.G_AttackPlayers = true

    _G.G_SilentAimSkill = false
    _G.G_SilentAimShowFOV = false
    _G.G_SilentAimFOV = 150
    _G.G_SilentAimPart = "HumanoidRootPart"
    _G.G_SilentAimFOVThickness = 2
    _G.G_SilentAimFOVTransparency = 1
    _G.G_SilentAimTargetPlayers = false
    _G.G_SilentAimTargetMobs = false
    _G.G_TargetRainbowBodyESP = false
    _G.G_SilentAimFOVMode = "Screen Center"
    _G.G_SilentAimTeamCheck = false
    _G.G_SilentAimSelectedPlayer = ""
    _G.G_AimbotMelee = false
    _G.G_AimbotFruit = false
    _G.G_AimbotSword = false
    _G.G_AimbotGun = false

    -- Exclusions (unused but kept)
    _G.G_Ex_Fruit_M1 = false; _G.G_Ex_Fruit_Z = false; _G.G_Ex_Fruit_X = false; _G.G_Ex_Fruit_C = false; _G.G_Ex_Fruit_V = false; _G.G_Ex_Fruit_F = false
    _G.G_Ex_Melee_M1 = false; _G.G_Ex_Melee_Z = false; _G.G_Ex_Melee_X = false; _G.G_Ex_Melee_C = false; _G.G_Ex_Melee_V = false; _G.G_Ex_Melee_F = false
    _G.G_Ex_Sword_M1 = false; _G.G_Ex_Sword_Z = false; _G.G_Ex_Sword_X = false; _G.G_Ex_Sword_C = false; _G.G_Ex_Sword_V = false; _G.G_Ex_Sword_F = false
    _G.G_Ex_Gun_M1 = false;   _G.G_Ex_Gun_Z = false;   _G.G_Ex_Gun_X = false;   _G.G_Ex_Gun_C = false;   _G.G_Ex_Gun_V = false;   _G.G_Ex_Gun_F = false

    -- Variables
    SuperJumpEnabled = false 
    SuperJumpPower = 500 
    PortalSoruEnabled = false
    PortalSoruWidgetVisible = false
    BlacklistedPlayers = {}
    FakeKorbloxEnabled = false
    FakeHeadlessEnabled = false
    ActiveAura = nil
    AuraObjects = {}
    FPSPingOverlayEnabled = false
    currentFPS = 0
    currentPing = 0
    currentLang = "EN"

    DashEnabled = false
    DashLengthDist = 1
    DashRunning = false
    prevDashLength = 1 
    prevDashEnabled = false 

    -- ============================================================
    -- PERSISTENCIA TOTAL DE CONFIGURACIÓN
    -- ============================================================
    UI_Toggle_Refreshes = {}
    ToggleRegistryMap = {}

    function SaveConfig()
        local conf = {
            ESPMaster = _G.G_ESPEnabled,
            ESPName = _G.G_ESP_Name,
            ESPLevel = _G.G_ESP_Level,
            ESPBounty = _G.G_ESP_Bounty,
            ESPFruit = _G.G_ESP_Fruit,
            ESPDist = _G.G_ESP_Distance,
            ESPHealth = _G.G_ESP_HP,
            ESPHighlight = _G.G_ESP_Highlight,
            ESPTextSize = _G.G_ESP_TextSize,
            FastAttack = FastAttackEnabled,
            WalkSpeed = WalkSpeedEnabled,
            WSpeedVal = WalkSpeedValue,
            Dash = DashEnabled,
            DashDist = DashLengthDist,
            Noclip = NoclipEnabled,
            WalkOnWater = WalkOnWaterEnabled,
            SmartV4 = SmartAutoV4Enabled,
            AntiStunHitbox = AntiStunHitboxEnabled,
            SuperJump = SuperJumpEnabled,
            SuperPower = SuperJumpPower,
            NoAnim = NoAnimEnabled,
            AntiLava = antiLavaActive,
            TargetPlayers = _G.G_SilentAimTargetPlayers,
            TargetMobs = _G.G_SilentAimTargetMobs,
            SkillAimbot = _G.G_SilentAimSkill,
            DragonM1 = _G.G_DragonGunM1,
            TeamCheck = _G.G_SilentAimTeamCheck,
            ShowFOV = _G.G_SilentAimShowFOV,
            ShowLine = _G.G_SilentAimShowLine,
            FOVRadius = _G.G_SilentAimFOV,
            AimbotMaxDist = maxRange,
            AimlockPlayers = AimlockPlayerEnabled,
            AimlockNPCs = AimlockNpcEnabled,
            PlayerWidgetActive = PlayerWidgetActive,
            NpcWidgetActive = NpcWidgetActive,
            InfSoru = SoruInfinitoEnabled,
            SoruAimbot = SoruAimbotEnabled,
            PortalSoru = PortalSoruEnabled,
            PortalSanguineC = PortalSanguineCEnabled,
            PortalSanguineCTriggerMode = PortalSanguineCTriggerMode,
            FakeKorblox = FakeKorbloxEnabled,
            FakeHeadless = FakeHeadlessEnabled,
            FPSPing = FPSPingOverlayEnabled,
            MacroBeta = MacroEnabled,
            MacroMode = MacroMode,
            MacroSlot1 = MacroSlot1,
            MacroKey1 = MacroKey1,
            MacroSlot2 = MacroSlot2,
            MacroKey2 = MacroKey2,
            MacroSlot3 = MacroSlot3,
            MacroKey3 = MacroKey3,
            MacroSlot4 = MacroSlot4,
            MacroKey4 = MacroKey4,
            MacroSlot5 = MacroSlot5,
            MacroKey5 = MacroKey5,
            MacroSlot6 = MacroSlot6,
            MacroKey6 = MacroKey6,
            MacroDelay1 = MacroDelay1,
            MacroDelay2 = MacroDelay2,
            MacroDelay3 = MacroDelay3,
            MacroDelay4 = MacroDelay4,
            MacroDelay5 = MacroDelay5,
            MacroDelay6 = MacroDelay6,
            AutoV4 = AutoV4Enabled,
            ThemeName = currentThemeName,
            Language = currentLang
        }
        pcall(function()
            if writefile then
                writefile("RitualHub_Config.json", HttpService:JSONEncode(conf))
                print("💾 Ritual Hub Config Saved Successfully!")
            end
        end)
    end

    function LoadConfig()
        pcall(function()
            if isfile and readfile and isfile("RitualHub_Config.json") then
                local str = readfile("RitualHub_Config.json")
                local conf = HttpService:JSONDecode(str)
                if not conf then return end

                for id, val in pairs(conf) do
                    if val ~= nil and ToggleRegistryMap[id] ~= nil then
                        pcall(function() ToggleRegistryMap[id](val) end)
                    end
                end

                if conf.ESPMaster ~= nil then 
                    _G.G_ESPEnabled = conf.ESPMaster 
                    if conf.ESPMaster then EnableESP() else DisableESP() end
                end
                if conf.ESPName ~= nil then _G.G_ESP_Name = conf.ESPName end
                if conf.ESPLevel ~= nil then _G.G_ESP_Level = conf.ESPLevel end
                if conf.ESPBounty ~= nil then _G.G_ESP_Bounty = conf.ESPBounty end
                if conf.ESPFruit ~= nil then _G.G_ESP_Fruit = conf.ESPFruit end
                if conf.ESPDist ~= nil then _G.G_ESP_Distance = conf.ESPDist end
                if conf.ESPHealth ~= nil then _G.G_ESP_HP = conf.ESPHealth end
                if conf.ESPHighlight ~= nil then _G.G_ESP_Highlight = conf.ESPHighlight end
                if conf.ESPTextSize ~= nil then _G.G_ESP_TextSize = conf.ESPTextSize end

                if conf.WSpeedVal ~= nil then WalkSpeedValue = conf.WSpeedVal end
                if conf.DashDist ~= nil then DashLengthDist = conf.DashDist end
                if conf.SuperPower ~= nil then SuperJumpPower = conf.SuperPower end
                if conf.AntiStunHitbox ~= nil then AntiStunHitboxEnabled = conf.AntiStunHitbox end
                if conf.FOVRadius ~= nil then 
                    _G.G_SilentAimFOV = conf.FOVRadius 
                    if FOVCircle then FOVCircle.Radius = conf.FOVRadius end
                end
                if conf.AimbotMaxDist ~= nil then maxRange = conf.AimbotMaxDist end

                if conf.PlayerWidgetActive ~= nil then PlayerWidgetActive = conf.PlayerWidgetActive end
                if conf.NpcWidgetActive ~= nil then NpcWidgetActive = conf.NpcWidgetActive end

                if FOVCircle then FOVCircle.Visible = (_G.G_SilentAimShowFOV == true) end
                if conf.ThemeName and applyNewTheme then applyNewTheme(conf.ThemeName) end
                if updateWidgetsVisuals then updateWidgetsVisuals() end

                if conf.MacroBeta ~= nil then MacroEnabled = conf.MacroBeta end
                if conf.MacroMode ~= nil then MacroMode = conf.MacroMode end
                if conf.MacroSlot1 ~= nil then MacroSlot1 = conf.MacroSlot1 end
                if conf.MacroKey1 ~= nil then MacroKey1 = conf.MacroKey1 end
                if conf.MacroSlot2 ~= nil then MacroSlot2 = conf.MacroSlot2 end
                if conf.MacroKey2 ~= nil then MacroKey2 = conf.MacroKey2 end
                if conf.MacroSlot3 ~= nil then MacroSlot3 = conf.MacroSlot3 end
                if conf.MacroKey3 ~= nil then MacroKey3 = conf.MacroKey3 end
                if conf.MacroSlot4 ~= nil then MacroSlot4 = conf.MacroSlot4 end
                if conf.MacroKey4 ~= nil then MacroKey4 = conf.MacroKey4 end
                if conf.MacroSlot5 ~= nil then MacroSlot5 = conf.MacroSlot5 end
                if conf.MacroKey5 ~= nil then MacroKey5 = conf.MacroKey5 end
                if conf.MacroSlot6 ~= nil then MacroSlot6 = conf.MacroSlot6 end
                if conf.MacroKey6 ~= nil then MacroKey6 = conf.MacroKey6 end
                if conf.MacroDelay1 ~= nil then MacroDelay1 = conf.MacroDelay1 end
                if conf.MacroDelay2 ~= nil then MacroDelay2 = conf.MacroDelay2 end
                if conf.MacroDelay3 ~= nil then MacroDelay3 = conf.MacroDelay3 end
                if conf.MacroDelay4 ~= nil then MacroDelay4 = conf.MacroDelay4 end
                if conf.MacroDelay5 ~= nil then MacroDelay5 = conf.MacroDelay5 end
                if conf.MacroDelay6 ~= nil then MacroDelay6 = conf.MacroDelay6 end
                if conf.AutoV4 ~= nil then 
                    AutoV4Enabled = conf.AutoV4 
                    if AutoV4Enabled then startAutoV4Loop() end
                end

                if conf.Language ~= nil then 
                    currentLang = conf.Language 
                    if updateLangBtnColors then updateLangBtnColors() end
                    if updateLanguageUI then updateLanguageUI() end
                end

                print("✅ Ritual Hub Config Loaded & Applied Successfully!")
            end
        end)
    end

    pcall(function()
        local targetFolder = parentGui or playerGui
        if targetFolder then
            for _, old in ipairs(targetFolder:GetChildren()) do
                if old and old.Name and old.Name:match("RitualUI") then 
                    pcall(function() old:Destroy() end) 
                end
            end
        end
    end)

    -- ============================================================
    -- DRAGON GUN M1 FAST ATTACK
    -- ============================================================
    local DragonModules, DragonNet, ShootGunEvent, Validator2
    task.spawn(function()
        pcall(function()
            DragonModules = ReplicatedStorage:WaitForChild("Modules", 3)
            if DragonModules then
                DragonNet = DragonModules:WaitForChild("Net", 3)
                if DragonNet then
                    ShootGunEvent = DragonNet:WaitForChild("RE/ShootGunEvent", 3)
                end
            end
            local remotes = ReplicatedStorage:WaitForChild("Remotes", 3)
            if remotes then
                Validator2 = remotes:WaitForChild("Validator2", 3)
            end
        end)
    end)

    local getupval = debug.getupvalue or getupvalue
    local setupval = debug.setupvalue or setupvalue
    local getupvals = debug.getupvalues or getupvalues

    local ShootFunction
    local V_Idx = { v26 = 12, v22 = 13, v25 = 14, v21 = 15, v23 = 16, v24 = 17, v27 = 18 }

    function InitDragonGun()
        local success, result = pcall(require, ReplicatedStorage:WaitForChild("Controllers"):WaitForChild("CombatController"))
        if success and type(result) == "table" and result.Attack then
            ShootFunction = getupval(result.Attack, 9)
        end
    end

    function GetNextValidator()
        if not ShootFunction then InitDragonGun() end
        if not ShootFunction then return 0, 0 end
        local upvals = getupvals(ShootFunction)
        if not upvals then return 0, 0 end
        if upvals[V_Idx.v21] ~= 727595 then
            for i, v in pairs(upvals) do
                if v == 727595 then
                    local offset = i - 15
                    V_Idx.v21 = i; V_Idx.v22 = 13 + offset; V_Idx.v23 = 16 + offset
                    V_Idx.v24 = 17 + offset; V_Idx.v26 = 12 + offset; V_Idx.v25 = 14 + offset
                    V_Idx.v27 = 18 + offset
                    break
                end
            end
        end
        local v1 = getupval(ShootFunction, V_Idx.v21)
        local v2 = getupval(ShootFunction, V_Idx.v22)
        local v3 = getupval(ShootFunction, V_Idx.v23)
        local v4 = getupval(ShootFunction, V_Idx.v24)
        local v5 = getupval(ShootFunction, V_Idx.v25)
        local v6 = getupval(ShootFunction, V_Idx.v26)
        local v7 = getupval(ShootFunction, V_Idx.v27)
        if not (v1 and v2 and v3 and v4 and v5 and v6 and v7) then return 0, 0 end
        local v8 = v6 * v2
        local v9 = (v5 * v2 + v6 * v1) % v3
        v9 = (v9 * v3 + v8) % v4
        v5 = math.floor(v9 / v3)
        v6 = v9 - v5 * v3
        v7 = v7 + 1
        setupval(ShootFunction, V_Idx.v25, v5)
        setupval(ShootFunction, V_Idx.v26, v6)
        setupval(ShootFunction, V_Idx.v27, v7)
        return math.floor(v9 / v4 * 16777215), v7
    end

    function GetClosestDragonTarget()
        local char = player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not root then return nil end
        local closest, dist = nil, math.huge
        local myPos = root.Position

        if _G.G_AttackMobs or _G.G_SilentAimTargetMobs or SilentAimNPCsEnabled then
            local enemies = workspace:FindFirstChild("Enemies")
            if enemies then
                for _, enemy in pairs(enemies:GetChildren()) do
                    local hum = enemy:FindFirstChildOfClass("Humanoid")
                    local r = enemy:FindFirstChild("HumanoidRootPart")
                    if hum and hum.Health > 0 and r then
                        local d = (r.Position - myPos).Magnitude
                        if d < dist then dist = d; closest = r end
                    end
                end
            end
        end

        if _G.G_AttackPlayers or _G.G_SilentAimTargetPlayers or SilentAimPlayersEnabled then
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= player and p.Character then
                    local hum = p.Character:FindFirstChildOfClass("Humanoid")
                    local r = p.Character:FindFirstChild("HumanoidRootPart")
                    if hum and hum.Health > 0 and r then
                        local d = (r.Position - myPos).Magnitude
                        if d < dist then dist = d; closest = r end
                    end
                end
            end
        end
        return closest
    end

    task.spawn(function()
        while true do
            task.wait(0.085)
            if _G.G_DragonGunM1 then
                pcall(function()
                    local char = player.Character
                    local tool = char and char:FindFirstChildOfClass("Tool")
                    if not tool or tool.ToolTip ~= "Gun" then return end
                    local target = GetClosestDragonTarget()
                    if not target then return end
                    local code, count = GetNextValidator()
                    if code ~= 0 then Validator2:FireServer(code, count) end
                    tool:SetAttribute("LocalOverheat", 0)
                    tool:SetAttribute("LocalTotalShots", (tool:GetAttribute("LocalTotalShots") or 0) + 1)
                    ShootGunEvent:FireServer(target.Position, { target })
                end)
            end
        end
    end)

    function UpdateDragonButton() end

    if player:FindFirstChild("Backpack") then
        player.Backpack.ChildAdded:Connect(function(child)
            if child:IsA("Tool") then
                task.wait(0.1)
                applyCustomFruitIcon()
            end
        end)
    end

    task.spawn(function()
        while true do
            task.wait(1.5)
            applyCustomFruitIcon()
        end
    end)

    -- ============================================================
    -- AUTO RACE V4 ENGINE
    -- ============================================================
    AutoV4Enabled = false
    local autoV4Thread = nil

    function startAutoV4Loop()
        if autoV4Thread then return end
        autoV4Thread = task.spawn(function()
            while AutoV4Enabled do
                task.wait(0.5)
                pcall(function()
                    local char = player.Character
                    if not char then return end
                    local raceEnergy = char:GetAttribute("RaceEnergy")
                    if raceEnergy and raceEnergy >= 100 then
                        local awk = player.Backpack:FindFirstChild("Awakening") or char:FindFirstChild("Awakening")
                        if awk and awk:FindFirstChild("RemoteFunction") then
                            awk.RemoteFunction:InvokeServer(true)
                        else
                            local remotes = ReplicatedStorage:FindFirstChild("Remotes")
                            if remotes and remotes:FindFirstChild("CommF_") then
                                remotes.CommF_:InvokeServer("Awakening", true)
                            end
                        end
                    end
                end)
            end
            autoV4Thread = nil
        end)
    end

    function stopAutoV4Loop()
        AutoV4Enabled = false
        autoV4Thread = nil
    end

    AntiStunHitboxEnabled = false
    antiStunHeartbeatConn = nil
    antiStunInputConn = nil
    antiStunCharConn = nil

    function enableAntiStunHitbox()
        AntiStunHitboxEnabled = true
        
        if antiStunHeartbeatConn then antiStunHeartbeatConn:Disconnect() end
        antiStunHeartbeatConn = RunService.Heartbeat:Connect(function()
            if not AntiStunHitboxEnabled then return end
            pcall(function()
                local char = player.Character
                if not char then return end
                char:SetAttribute("AllCooldown", 0)
                char:SetAttribute("FlashstepCooldown", 1)
                char:SetAttribute("UsingSkill", false)
                char:SetAttribute("isUsingSkill", false)
                char:SetAttribute("Busy", false)
                local hum = char:FindFirstChildOfClass("Humanoid")
                local root = char:FindFirstChild("HumanoidRootPart")
                if hum and hum.WalkSpeed < 16 then hum.WalkSpeed = 16 end
                if root then
                    for _, v in ipairs(root:GetChildren()) do
                        if v:IsA("BodyVelocity") or v:IsA("BodyPosition") then
                            v:Destroy()
                        end
                    end
                end
                local pgui = player:FindFirstChild("PlayerGui")
                if pgui and pgui:FindFirstChild("Main") then
                    local skills = pgui.Main:FindFirstChild("Skills")
                    if skills then
                        local dbSkills = skills:FindFirstChild("Dark Blade")
                        if dbSkills then
                            for _, skillFrame in ipairs(dbSkills:GetChildren()) do
                                local cd = skillFrame:FindFirstChild("Cooldown")
                                if cd and cd:IsA("Frame") then
                                    cd.Size = UDim2.new(0, 0, 1, 0)
                                    cd.Visible = false
                                end
                            end
                        end
                    end
                end
            end)
        end)
        
        if antiStunInputConn then antiStunInputConn:Disconnect() end
        antiStunInputConn = UserInputService.InputBegan:Connect(function(input, gp)
            if not AntiStunHitboxEnabled or gp then return end
            local char = player.Character
            if not char then return end
            local darkBlade = char:FindFirstChild("Dark Blade")
            if not darkBlade or not darkBlade:FindFirstChild("RemoteEvent") then return end
            if input.KeyCode == Enum.KeyCode.Z then
                darkBlade.RemoteEvent:FireServer("Z")
            elseif input.KeyCode == Enum.KeyCode.X then
                darkBlade.RemoteEvent:FireServer("X")
            end
        end)
        
        if antiStunCharConn then antiStunCharConn:Disconnect() end
        antiStunCharConn = player.CharacterAdded:Connect(function(char)
            if AntiStunHitboxEnabled then
                task.wait(1)
                pcall(function()
                    char:SetAttribute("AllCooldown", 0)
                    char:SetAttribute("FlashstepCooldown", 1)
                end)
            end
        end)
    end

    function disableAntiStunHitbox()
        AntiStunHitboxEnabled = false
        if antiStunHeartbeatConn then antiStunHeartbeatConn:Disconnect(); antiStunHeartbeatConn = nil end
        if antiStunInputConn then antiStunInputConn:Disconnect(); antiStunInputConn = nil end
        if antiStunCharConn then antiStunCharConn:Disconnect(); antiStunCharConn = nil end
        pcall(function()
            local char = player.Character
            if char then
                char:SetAttribute("AllCooldown", nil)
                char:SetAttribute("FlashstepCooldown", nil)
                char:SetAttribute("UsingSkill", nil)
                char:SetAttribute("isUsingSkill", nil)
                char:SetAttribute("Busy", nil)
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum.WalkSpeed = 16
                end
            end
        end)
    end

    RegisterHit, RegisterAttack = nil, nil
    FastAttackEnabled = false
    FastAttackRange = 2500
    FastAttackRunning = false

    spawn(function()
        for _, v in pairs(ReplicatedStorage:GetDescendants()) do
            if v:IsA("RemoteEvent") and v.Name == "RE/RegisterHit" then RegisterHit = v end
            if v:IsA("RemoteEvent") and v.Name == "RE/RegisterAttack" then RegisterAttack = v end
        end
    end)

    function AttackMultipleTargets(targets)
        if not RegisterHit or not RegisterAttack then return end
        pcall(function()
            if not targets or #targets == 0 then return end
            local allTargets = {}
            for _, char in pairs(targets) do
                local head = char:FindFirstChild("Head")
                if head then table.insert(allTargets, {char, head}) end
            end
            if #allTargets == 0 then return end
            RegisterAttack:FireServer(0)
            RegisterHit:FireServer(allTargets[1][2], allTargets)
        end)
    end

    function StartFastAttack()
        if FastAttackRunning then return end
        FastAttackRunning = true
        spawn(function()
            while FastAttackEnabled do
                RunService.Stepped:Wait()
                local myChar = player.Character
                local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
                if myHRP then
                    local targets = {}
                    for _, p in pairs(Players:GetPlayers()) do
                        if p ~= player and p.Character and not BlacklistedPlayers[p.Name] then
                            local hum = p.Character:FindFirstChild("Humanoid")
                            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                            if hum and hrp and hum.Health > 0 and (hrp.Position - myHRP.Position).Magnitude <= FastAttackRange then
                                table.insert(targets, p.Character)
                            end
                        end
                    end
                    local enemies = workspace:FindFirstChild("Enemies")
                    if enemies then
                        for _, npc in pairs(enemies:GetChildren()) do
                            local hum = npc:FindFirstChild("Humanoid")
                            local hrp = npc:FindFirstChild("HumanoidRootPart")
                            if hum and hrp and hum.Health > 0 and (hrp.Position - myHRP.Position).Magnitude <= FastAttackRange then
                                table.insert(targets, npc)
                            end
                        end
                    end
                    if #targets > 0 then AttackMultipleTargets(targets) end
                end
            end
            FastAttackRunning = false
        end)
    end

    -- ============================================================
    -- WALK SPEED
    -- ============================================================
    WalkSpeedEnabled = false
    WalkSpeedValue = 16

    spawn(function()
        while true do
            wait(0.2)
            if WalkSpeedEnabled then
                local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
                if hum and hum.WalkSpeed ~= WalkSpeedValue then hum.WalkSpeed = WalkSpeedValue end
            end
        end
    end)

    -- ============================================================
    -- DASH DISTANCE
    -- ============================================================
    function startDashLoop()
        if DashRunning then return end
        DashRunning = true
        spawn(function()
            while DashEnabled do
                wait(0.1)
                pcall(function()
                    local char = player.Character
                    if char then
                        if char:GetAttribute("DashLength") ~= DashLengthDist then char:SetAttribute("DashLength", DashLengthDist) end
                        if char:GetAttribute("DashLengthAir") ~= DashLengthDist then char:SetAttribute("DashLengthAir", DashLengthDist) end
                    end
                end)
            end
            DashRunning = false
        end)
    end

    function stopDashLoop()
        DashEnabled = false
        pcall(function()
            local char = player.Character
            if char then
                char:SetAttribute("DashLength", 1)
                char:SetAttribute("DashLengthAir", 1)
            end
        end)
    end

    function applyDashInstantly()
        pcall(function()
            local char = player.Character
            if char then
                char:SetAttribute("DashLength", DashLengthDist)
                char:SetAttribute("DashLengthAir", DashLengthDist)
            end
        end)
    end

    -- ============================================================
    -- NOCLIP
    -- ============================================================
    NoclipEnabled = false
    NoclipConn = nil

    function SetNoclip(state)
        NoclipEnabled = state
        if state then
            NoclipConn = RunService.Stepped:Connect(function()
                local char = player.Character
                if char and NoclipEnabled then
                    for _, part in pairs(char:GetDescendants()) do
                        if part:IsA("BasePart") then part.CanCollide = false end
                    end
                end
            end)
        else
            if NoclipConn then NoclipConn:Disconnect(); NoclipConn = nil end
            local char = player.Character
            if char then
                for _, part in pairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = true end
                end
            end
        end
    end

    player.CharacterAdded:Connect(function()
        if NoclipEnabled then wait(0.5); SetNoclip(true) end
    end)

    -- ============================================================
    -- DETENER ANIMACIONES
    -- ============================================================
    ATTACK_KEYWORDS = {"attack", "slash", "punch", "m1", "combo", "hit", "tool", "ability", "skill", "kamehameha", "bullet", "gun", "sword", "melee", "fruit"}

    function isAttackAnim(track)
        local name = string.lower(track.Name)
        for _, kw in ipairs(ATTACK_KEYWORDS) do
            if string.find(name, kw) then return true end
        end
        if track.Priority == Enum.AnimationPriority.Action then return true end
        return false
    end

    function StopPlayerAnimations()
        local char = player.Character
        if not char then return end
        local hum = char:FindFirstChild("Humanoid")
        if not hum then return end
        local animator = hum:FindFirstChild("Animator")
        if not animator then return end
        for _, track in pairs(animator:GetPlayingAnimationTracks()) do
            if not isAttackAnim(track) then
                track:Stop(0)
            end
        end
    end

    -- ============================================================
    -- SUPER JUMP
    -- ============================================================
    function doSuperJump()
        local char = player.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum or hum.Health <= 0 then return end
        
        StopPlayerAnimations()
        hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, SuperJumpPower, hrp.AssemblyLinearVelocity.Z)
        hum:ChangeState(Enum.HumanoidStateType.Jumping)
    end

    -- ============================================================
    -- PORTAL COMBOS (XZ & SANGUINE C AUTO-EQUIP)
    -- ============================================================
    PortalSanguineCEnabled = false
    PortalSanguineCTriggerMode = "PortalF"

    function isHoldingPortalFruit()
        local char = player.Character
        if not char then return false end
        local tool = char:FindFirstChildOfClass("Tool")
        if tool then
            local tName = string.lower(tool.Name)
            if string.find(tName, "portal") or string.find(tName, "door") then return true end
        end
        return false
    end

    function equipSanguineArt()
        local char = player.Character
        if not char then return nil end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum then return nil end
        
        local tool = char:FindFirstChild("Sanguine Art") or char:FindFirstChild("Sanguine")
        if not tool then
            local bp = player:FindFirstChild("Backpack")
            if bp then
                for _, t in ipairs(bp:GetChildren()) do
                    local name = string.lower(t.Name)
                    if string.find(name, "sanguine") then
                        hum:EquipTool(t)
                        tool = t
                        task.wait(0.1)
                        break
                    end
                end
            end
        end
        return tool
    end

    function equipPortalFruit()
        local char = player.Character
        if not char then return nil end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum then return nil end
        
        local tool = char:FindFirstChild("Portal-Portal") or char:FindFirstChild("Portal Fruit") or char:FindFirstChild("Portal") or char:FindFirstChild("Door")
        if not tool then
            local bp = player:FindFirstChild("Backpack")
            if bp then
                for _, t in ipairs(bp:GetChildren()) do
                    local name = string.lower(t.Name)
                    if string.find(name, "portal") or string.find(name, "door") then
                        hum:EquipTool(t)
                        tool = t
                        task.wait(0.1)
                        break
                    end
                end
            end
        end
        return tool
    end

    function doPortalCombo()
        if not isHoldingPortalFruit() then
            equipPortalFruit()
            task.wait(0.08)
        end
        if not isHoldingPortalFruit() then return end

        local function pressKey(kc)
            VirtualInputManager:SendKeyEvent(true, kc, false, game)
            task.wait(0.05)
            VirtualInputManager:SendKeyEvent(false, kc, false, game)
        end
        pressKey(Enum.KeyCode.X)
        task.wait(0.15)
        pressKey(Enum.KeyCode.Z)
    end

    function doPortalSanguineCCombo()
        task.wait(0.25)
        equipSanguineArt()
        task.wait(0.1)
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.C, false, game)
        task.wait(0.15)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.C, false, game)
    end

    FLASH_NAMES = {"FlashStepRegular","FlashStepDraco","FlashStep","Flashstep","Soru"}
    FLASH_IDS = {"17555632156","18461649274","616006778","616010882","5403485593","5403491911"}

    function isFlashstep(track)
        for _,n in ipairs(FLASH_NAMES) do
            if string.find(string.lower(track.Name), string.lower(n)) then return true end
        end
        local id = track.Animation and track.Animation.AnimationId:match("%d+") or ""
        for _,fid in ipairs(FLASH_IDS) do
            if id == fid then return true end
        end
        return false
    end

    function monitorCharPortal(char)
        local h = char:WaitForChild("Humanoid", 5) 
        if not h then return end
        h.AnimationPlayed:Connect(function(track)
            local animName = string.lower(track.Name)
            local animId = tostring(track.Animation and track.Animation.AnimationId or "")
            
            local isPortalF = string.find(animName, "portal") or string.find(animName, "teleport") or string.find(animName, "warp") or string.find(animName, "door") or string.find(animName, "world")
            local isSoru = isFlashstep(track)

            if PortalSoruEnabled and isSoru then
                task.spawn(doPortalCombo)
            end
            
            if PortalSanguineCEnabled then
                if (PortalSanguineCTriggerMode == "PortalF" and isPortalF) or (PortalSanguineCTriggerMode == "Soru" and isSoru) then
                    task.spawn(doPortalSanguineCCombo)
                end
            end
        end)
    end

    UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.KeyCode == Enum.KeyCode.F then
            if PortalSanguineCEnabled and PortalSanguineCTriggerMode == "PortalF" then
                if isHoldingPortalFruit() then
                    task.spawn(doPortalSanguineCCombo)
                end
            end
        end
    end)

    player.CharacterAdded:Connect(monitorCharPortal)
    if player.Character then monitorCharPortal(player.Character) end

    -- ============================================================
    -- ANTI LAVA
    -- ============================================================
    antiLavaActive = false
    antiLavaConnection = nil

    function startAntiLava()
        if antiLavaConnection then antiLavaConnection:Disconnect() end
        local antiLavaTimer = 0
        antiLavaConnection = RunService.Stepped:Connect(function(_, dt)
            antiLavaTimer = antiLavaTimer + dt
            if antiLavaTimer < 0.2 then return end
            antiLavaTimer = 0
            local char = player.Character
            if not (char and antiLavaActive) then return end
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart"
                and part.Name ~= "Torso" and part.Name ~= "UpperTorso"
                and part.Name ~= "LowerTorso" and part.Name ~= "Head" then
                    part.CanTouch = false
                end
            end
        end)
    end

    function stopAntiLava()
        if antiLavaConnection then antiLavaConnection:Disconnect(); antiLavaConnection = nil end
    end

    -- ============================================================
    -- WALK ON WATER
    -- ============================================================
    WalkOnWaterEnabled = false

    spawn(function()
        local waterPart = nil
        local function getWaterPart()
            if not waterPart or not waterPart.Parent then
                waterPart = Instance.new("Part")
                waterPart.Size = Vector3.new(200, 1, 200)
                waterPart.Transparency = 1
                waterPart.Anchored = true
                waterPart.CanCollide = false
                waterPart.Name = "RitualWaterPlatform"
                waterPart.Parent = workspace
            end
            return waterPart
        end
        while true do
            wait(0.15)
            if WalkOnWaterEnabled then
                local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                local wp = getWaterPart()
                if hrp and hrp.Position.Y >= 9.5 then
                    wp.Position = Vector3.new(hrp.Position.X, 9.2, hrp.Position.Z)
                    wp.CanCollide = true
                else
                    wp.CanCollide = false
                end
            elseif waterPart and waterPart.Parent then
                waterPart.CanCollide = false
            end
        end
    end)

    -- ============================================================
    -- SMART AUTO V4
    -- ============================================================
    SmartAutoV4Enabled = false

    spawn(function()
        while true do
            wait(1)
            if SmartAutoV4Enabled then
                pcall(function()
                    local char = player.Character
                    if char and char:GetAttribute("RaceEnergy") and char:GetAttribute("RaceEnergy") >= 100 then
                        local awakening = player.Backpack:FindFirstChild("Awakening")
                        if awakening and awakening:FindFirstChild("RemoteFunction") then
                            awakening.RemoteFunction:InvokeServer(true)
                        end
                    end
                end)
            end
        end
    end)

    -- ============================================================
    -- ESP (Yellow Highlight)
    -- ============================================================
    _G.G_ESPEnabled       = false
    _G.G_ESP_Name         = true
    _G.G_ESP_Level        = true
    _G.G_ESP_Bounty       = true
    _G.G_ESP_Fruit        = true
    _G.G_ESP_Distance     = true
    _G.G_ESP_HP           = true
    _G.G_ESP_TextSize     = 12
    _G.G_ESP_Highlight    = false
    _G.G_ESP_HighlightColor = "FFFF00" -- Yellow

    local ESPRunning = false
    local espObjects = {}
    local lastESPUpdate = 0
    local ESP_UPDATE_INTERVAL = 0.1
    local playerCache = {}

    function getTeamInfo(targetP)
        if not targetP or not targetP.Team then
            return "Unknown", Color3.fromRGB(255,255,255)
        end
        if targetP.Team.Name == "Marines" then
            return "Marines", Color3.fromRGB(0,170,255)
        else
            return "Pirates", Color3.fromRGB(255,70,70)
        end
    end

    function hexToColor3(hex)
        local r = tonumber(hex:sub(1,2), 16) / 255 or 0
        local g = tonumber(hex:sub(3,4), 16) / 255 or 1
        local b = tonumber(hex:sub(5,6), 16) / 255 or 0
        return Color3.new(r, g, b)
    end

    function removeESP(targetP)
        if espObjects[targetP] then
            pcall(function()
                if espObjects[targetP].gui then espObjects[targetP].gui:Destroy() end
                if espObjects[targetP].highlight then espObjects[targetP].highlight:Destroy() end
            end)
            espObjects[targetP] = nil
        end
    end

    function createESP(targetP)
        if not targetP or targetP == player then return end
        if targetP:GetAttribute("IsAuthor") or 
           targetP.Name == "Mas_Yes" or 
           targetP.Name == "sjqgduf" or 
           targetP.Name == "huha123444" or 
           targetP.Name == "ksxrcm111" or
           targetP.Name == "Dddyy5" then 
            return 
        end
        local char = targetP.Character
        if not char then return end
        local head = char:FindFirstChild("Head")
        if not head then return end

        local team, color = getTeamInfo(targetP)
        local billboard = Instance.new("BillboardGui")
        billboard.Name = "RitualESP_Billboard"
        billboard.Adornee = head
        billboard.Size = UDim2.new(0, 200, 0, 75)
        billboard.StudsOffset = Vector3.new(0, 3, 0)
        billboard.AlwaysOnTop = true
        billboard.Parent = head

        local text = Instance.new("TextLabel")
        text.Size = UDim2.new(1, 0, 1, 0)
        text.BackgroundTransparency = 1
        text.TextScaled = false
        text.TextSize = _G.G_ESP_TextSize or 12
        text.RichText = true
        text.Font = Enum.Font.SourceSansBold
        text.TextStrokeTransparency = 0
        text.TextColor3 = color
        text.Parent = billboard

        local highlight = nil
        if _G.G_ESP_Highlight then
            local hlColor = hexToColor3(_G.G_ESP_HighlightColor or "FFFF00")
            highlight = Instance.new("Highlight")
            highlight.Name = "ESP_PlayerHighlight"
            highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            highlight.FillColor = hlColor
            highlight.FillTransparency = 0.5
            highlight.OutlineColor = hlColor
            highlight.OutlineTransparency = 0
            highlight.Parent = char
        end

        espObjects[targetP] = {
            gui = billboard,
            label = text,
            char = char,
            highlight = highlight
        }
    end

    function getPlayerData(targetP)
        if not playerCache[targetP] then
            playerCache[targetP] = {
                level = "?",
                fruit = "None",
                bounty = 0,
                team = "Unknown",
                color = Color3.fromRGB(255, 255, 255),
                lastUpdate = 0
            }
        end
        local data = playerCache[targetP]
        local now = tick()
        if now - data.lastUpdate > 5 then
            pcall(function() data.level = targetP.Data.Level.Value end)
            pcall(function() data.fruit = targetP.Data.DevilFruit.Value end)
            pcall(function() data.bounty = targetP.leaderstats["Bounty/Honor"].Value end)
            data.team, data.color = getTeamInfo(targetP)
            data.lastUpdate = now
        end
        return data
    end

    function updateESP()
        if not _G.G_ESPEnabled then
            DisableESP()
            return
        end
        local anySubActive = _G.G_ESP_Name or _G.G_ESP_Level or _G.G_ESP_Bounty or _G.G_ESP_Fruit or _G.G_ESP_Distance or _G.G_ESP_HP or _G.G_ESP_Highlight
        if not anySubActive then
            DisableESP()
            return
        end

        local now = tick()
        if now - lastESPUpdate < ESP_UPDATE_INTERVAL then return end
        lastESPUpdate = now

        local myChar = player.Character
        local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
        if not myRoot then return end
        local myPos = myRoot.Position

        for _, targetP in ipairs(Players:GetPlayers()) do
            if targetP ~= player then
                local isSpecial = targetP:GetAttribute("IsAuthor") or 
                   targetP.Name == "Mas_Yes" or 
                   targetP.Name == "sjqgdu6" or 
                   targetP.Name == "huha124444" or 
                   targetP.Name == "ksxrcn111" or
                   targetP.Name == "Dddyy5"

                if isSpecial then
                    if espObjects[targetP] then removeESP(targetP) end
                else
                    local char = targetP.Character
                    local head = char and char:FindFirstChild("Head")
                    local data = espObjects[targetP]
                    if char and head then
                        if not data or data.char ~= char or not data.gui.Parent then
                            removeESP(targetP)
                            createESP(targetP)
                            data = espObjects[targetP]
                        end

                        if data then
                            local hum = char:FindFirstChild("Humanoid")
                            local root = char:FindFirstChild("HumanoidRootPart")
                            if hum and root then
                                local distance = math.floor((root.Position - myPos).Magnitude)
                                local hp = math.floor((hum.Health / math.max(hum.MaxHealth, 1)) * 100)
                                local pData = getPlayerData(targetP)
                                local level = pData.level
                                local fruit = pData.fruit
                                local bounty = pData.bounty
                                local team = pData.team
                                local color = pData.color

                                local warnTag = ""
                                if type(bounty) == "number" and bounty > 10000000 then
                                    warnTag = "⚠ "
                                end
                                local pvpState = "PVP Enabled "
                                local pvpIcon = "🔴 "
                                local isPvpDisabled = false
                                if targetP:GetAttribute("PvpDisabled") == true then
                                    pvpState = "PvP Disabled "
                                    pvpIcon = "🟢 "
                                    isPvpDisabled = true
                                end

                                data.label.TextColor3 = color
                                if data.label.TextSize ~= _G.G_ESP_TextSize then
                                    data.label.TextSize = _G.G_ESP_TextSize or 12
                                end

                                local parts = {}
                                if _G.G_ESP_Name then parts[#parts+1] = warnTag .. "[" .. team .. "] <font color=\"rgb(255,255,0)\">" .. targetP.Name .. "</font>" end
                                if _G.G_ESP_Level then parts[#parts+1] = " [Lv." .. level .. "]" end
                                if _G.G_ESP_Bounty then 
                                    local bM = type(bounty) == "number" and math.floor(bounty / 1000000) or 0
                                    if isPvpDisabled then
                                        parts[#parts+1] = "\n<font color=\"rgb(0,255,0)\">" .. pvpIcon .. pvpState .. "</font> | Bounty: " .. bM .. "M\n"
                                    else
                                        parts[#parts+1] = "\n" .. pvpIcon .. pvpState .. "| Bounty: " .. bM .. "M\n"
                                    end
                                end
                                if _G.G_ESP_Fruit then parts[#parts+1] = "Fruit: " .. tostring(fruit) .. "\n" end
                                if _G.G_ESP_Distance then parts[#parts+1] = distance .. "m | " end
                                if _G.G_ESP_HP then parts[#parts+1] = "HP " .. hp .. "%" end
                                data.label.Text = table.concat(parts)

                                if _G.G_ESP_Highlight then
                                    local hlColor = hexToColor3(_G.G_ESP_HighlightColor or "FFFF00")
                                    pcall(function()
                                        for _, child in ipairs(char:GetChildren()) do
                                            if child:IsA("Highlight") and child.Name ~= "ESP_PlayerHighlight" then
                                                child.FillColor = hlColor
                                                child.OutlineColor = hlColor
                                                child.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                                            end
                                        end
                                    end)
                                    if not data.highlight or not data.highlight.Parent then
                                        local hl = Instance.new("Highlight")
                                        hl.Name = "ESP_PlayerHighlight"
                                        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                                        hl.FillColor = hlColor
                                        hl.FillTransparency = 0.5
                                        hl.OutlineColor = hlColor
                                        hl.OutlineTransparency = 0
                                        hl.Parent = char
                                        data.highlight = hl
                                    else
                                        data.highlight.FillColor = hlColor
                                        data.highlight.OutlineColor = hlColor
                                        data.highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                                    end
                                else
                                    if data.highlight then
                                        data.highlight:Destroy()
                                        data.highlight = nil
                                    end
                                end
                            end
                        end
                    else
                        if data then removeESP(targetP) end
                    end
                end
            end
        end
    end

    function EnableESP()
        if ESPRunning then return end
        ESPRunning = true
        for _, targetP in ipairs(Players:GetPlayers()) do
            createESP(targetP)
        end
        task.spawn(function()
            while ESPRunning do
                pcall(updateESP)
                task.wait(ESP_UPDATE_INTERVAL)
            end
        end)
    end

    function DisableESP()
        ESPRunning = false
        for targetP, _ in pairs(espObjects) do
            removeESP(targetP)
        end
        espObjects = {}
    end
    ClearESP = DisableESP

    if not _G.ESP_Initialized then
        _G.ESP_Initialized = true
        Players.PlayerRemoving:Connect(function(targetP)
            removeESP(targetP)
            playerCache[targetP] = nil
        end)
    end

    -- ============================================================
    -- SORU INFINITO
    -- ============================================================
    function enforceSoru(char)
        if not char then return end
        if SoruInfinitoEnabled then char:SetAttribute("FlashstepCooldown", 1) end
        char.AttributeChanged:Connect(function(attr)
            if attr == "FlashstepCooldown" and SoruInfinitoEnabled and char:GetAttribute("FlashstepCooldown") ~= 1 then
                char:SetAttribute("FlashstepCooldown", 1)
            end
        end)
    end

    player.CharacterAdded:Connect(enforceSoru)
    if player.Character then enforceSoru(player.Character) end

    spawn(function()
        while true do
            wait(0.5)
            if SoruInfinitoEnabled and player.Character then
                pcall(function() player.Character:SetAttribute("FlashstepCooldown", 1) end)
            end
        end
    end)

    -- ============================================================
    -- NO ANIMATIONS
    -- ============================================================
    NoAnimEnabled = false
    NoAnimConnection = nil

    function StartNoAnimLoop()
        if NoAnimConnection then NoAnimConnection:Disconnect() end
        NoAnimConnection = RunService.Stepped:Connect(function()
            if not NoAnimEnabled then return end
            local char = player.Character
            if not char then return end
            local hum = char:FindFirstChild("Humanoid")
            if not hum then return end
            hum.AutoRotate = true 
            local animator = hum:FindFirstChild("Animator")
            if not animator then return end
            for _, track in pairs(animator:GetPlayingAnimationTracks()) do
                if not isAttackAnim(track) then
                    track:Stop(0)
                end
            end
        end)
    end

    -- ============================================================
    -- TARGET HELPERS
    -- ============================================================
    function getClosestPlayer(overrideMaxDist)
        local myHrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if not myHrp then return nil end

        local searchDist = overrideMaxDist or soruMaxDist or 3500

        if AimlockTargetPlayer ~= "Nearest" and AimlockTargetPlayer ~= nil then
            local targetP = Players:FindFirstChild(AimlockTargetPlayer)
            if targetP and targetP.Character and targetP.Character:FindFirstChild("HumanoidRootPart") then
                local hum = targetP.Character:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health > 0 then return targetP.Character end
            end
        end

        local closest, closestDist = nil, math.huge
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= player and not BlacklistedPlayers[p.Name] and p:GetAttribute("PvpDisabled") ~= true and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local hum = p.Character:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health > 0 then
                    local dist = (p.Character.HumanoidRootPart.Position - myHrp.Position).Magnitude
                    if dist < closestDist and dist <= searchDist then
                        closestDist = dist
                        closest = p.Character
                    end
                end
            end
        end
        return closest
    end

    function getClosestNPC()
        local myHrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if not myHrp then return nil end
        local container = workspace:FindFirstChild("Enemies") or workspace
        local closest, closestDist = nil, math.huge
        for _, npc in pairs(container:GetChildren()) do
            if npc:IsA("Model") and npc:FindFirstChild("HumanoidRootPart") and not Players:GetPlayerFromCharacter(npc) then
                local hum = npc:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health > 0 then
                    local dist = (npc.HumanoidRootPart.Position - myHrp.Position).Magnitude
                    if dist < closestDist and dist < maxRange then
                        closestDist = dist
                        closest = npc
                    end
                end
            end
        end
        return closest
    end

    -- ============================================================
    -- AIMLOCK PLAYER & NPC
    -- ============================================================
    _G.lockedPlayerTarget = nil
    _G.lockedNpcTarget = nil

    RunService.RenderStepped:Connect(function()
        if PlayerWidgetActive and AimlockPlayerEnabled then
            if not _G.lockedPlayerTarget or not _G.lockedPlayerTarget:FindFirstChild("HumanoidRootPart") then
                _G.lockedPlayerTarget = getClosestPlayer()
            end
            local targetChar = _G.lockedPlayerTarget
            if targetChar and targetChar:FindFirstChild("HumanoidRootPart") then
                local hum = targetChar:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health > 0 then
                    local targetPos = targetChar.HumanoidRootPart.Position + Vector3.new(0, 0.5, 0)
                    camera.CFrame = camera.CFrame:Lerp(CFrame.lookAt(camera.CFrame.Position, targetPos), 0.4)
                else
                    _G.lockedPlayerTarget = nil
                end
            else
                _G.lockedPlayerTarget = nil
            end
        else
            _G.lockedPlayerTarget = nil
        end

        if NpcWidgetActive and AimlockNpcEnabled then
            if not _G.lockedNpcTarget or not _G.lockedNpcTarget:FindFirstChild("HumanoidRootPart") then
                _G.lockedNpcTarget = getClosestNPC()
            end
            local targetNPC = _G.lockedNpcTarget
            if targetNPC and targetNPC:FindFirstChild("HumanoidRootPart") then
                local hum = targetNPC:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health > 0 then
                    local targetPos = targetNPC.HumanoidRootPart.Position + Vector3.new(0, 0.5, 0)
                    camera.CFrame = camera.CFrame:Lerp(CFrame.lookAt(camera.CFrame.Position, targetPos), 0.4)
                else
                    _G.lockedNpcTarget = nil
                end
            else
                _G.lockedNpcTarget = nil
            end
        else
            _G.lockedNpcTarget = nil
        end
    end)

    -- ============================================================
    -- VISUALS & EFFECTS (Fake Korblox/Headless, Auras)
    -- ============================================================
    function applyFakeKorblox(char)
        if not char then return end
        pcall(function()
            local rUpper = char:FindFirstChild("RightUpperLeg")
            local rLower = char:FindFirstChild("RightLowerLeg")
            local rFoot = char:FindFirstChild("RightFoot")
            if rUpper and rUpper:IsA("BasePart") then rUpper.Transparency = 1 end
            if rLower and rLower:IsA("BasePart") then rLower.Transparency = 1 end
            if rFoot and rFoot:IsA("BasePart") then rFoot.Transparency = 1 end
        end)
    end

    function removeFakeKorblox(char)
        if not char then return end
        pcall(function()
            local rUpper = char:FindFirstChild("RightUpperLeg")
            local rLower = char:FindFirstChild("RightLowerLeg")
            local rFoot = char:FindFirstChild("RightFoot")
            if rUpper and rUpper:IsA("BasePart") then rUpper.Transparency = 0 end
            if rLower and rLower:IsA("BasePart") then rLower.Transparency = 0 end
            if rFoot and rFoot:IsA("BasePart") then rFoot.Transparency = 0 end
        end)
    end

    function applyFakeHeadless(char)
        if not char then return end
        pcall(function()
            local head = char:FindFirstChild("Head")
            if head then
                head.Transparency = 1
                for _, child in pairs(head:GetChildren()) do
                    if child:IsA("Decal") or child:IsA("Texture") then child.Transparency = 1 end
                end
            end
            for _, acc in pairs(char:GetChildren()) do
                if acc:IsA("Accessory") then
                    local handle = acc:FindFirstChild("Handle")
                    if handle and handle:IsA("BasePart") then
                        local isHeadAcc = false
                        for _, child in pairs(handle:GetChildren()) do
                            if child:IsA("Attachment") then
                                local aName = string.lower(child.Name)
                                if string.find(aName, "hat") or string.find(aName, "hair") or string.find(aName, "face") or string.find(aName, "head") then
                                    isHeadAcc = true
                                    break
                                end
                            end
                        end
                        if not isHeadAcc then
                            for _, weld in pairs(handle:GetChildren()) do
                                if weld:IsA("Weld") or weld:IsA("Motor6D") or weld:IsA("WeldConstraint") then
                                    if weld.Part0 == head or weld.Part1 == head then
                                        isHeadAcc = true
                                        break
                                    end
                                end
                            end
                        end
                        if isHeadAcc or acc.AccessoryType == Enum.AccessoryType.Hat or acc.AccessoryType == Enum.AccessoryType.Hair or acc.AccessoryType == Enum.AccessoryType.Face or acc.AccessoryType == Enum.AccessoryType.Unknown then
                            handle.Transparency = 1
                            for _, sub in pairs(handle:GetDescendants()) do
                                if sub:IsA("BasePart") or sub:IsA("MeshPart") or sub:IsA("Decal") or sub:IsA("Texture") then
                                    sub.Transparency = 1
                                end
                            end
                        end
                    end
                end
            end
        end)
    end

    function removeFakeHeadless(char)
        if not char then return end
        pcall(function()
            local head = char:FindFirstChild("Head")
            if head then
                head.Transparency = 0
                for _, child in pairs(head:GetChildren()) do
                    if child:IsA("Decal") or child:IsA("Texture") then child.Transparency = 0 end
                end
            end
            for _, acc in pairs(char:GetChildren()) do
                if acc:IsA("Accessory") then
                    local handle = acc:FindFirstChild("Handle")
                    if handle and handle:IsA("BasePart") then
                        handle.Transparency = 0
                        for _, sub in pairs(handle:GetDescendants()) do
                            if sub:IsA("BasePart") or sub:IsA("MeshPart") or sub:IsA("Decal") or sub:IsA("Texture") then
                                sub.Transparency = 0
                            end
                        end
                    end
                end
            end
        end)
    end

    AURA_DEFS = {
        Inferno = {
            Color = ColorSequence.new(Color3.fromRGB(255, 80, 0), Color3.fromRGB(255, 0, 0)),
            LightColor = Color3.fromRGB(255, 80, 0),
            Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.5), NumberSequenceKeypoint.new(0.5, 2.5), NumberSequenceKeypoint.new(1, 0)}),
            Rate = 80,
            Speed = NumberRange.new(3, 8),
            Lifetime = NumberRange.new(0.5, 1.2),
            SpreadAngle = Vector2.new(25, 25),
            LightEmission = 1,
            RotSpeed = NumberRange.new(-90, 90),
            Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.3), NumberSequenceKeypoint.new(1, 1)}),
        },
        Electric = {
            Color = ColorSequence.new(Color3.fromRGB(0, 170, 255), Color3.fromRGB(100, 200, 255)),
            LightColor = Color3.fromRGB(0, 170, 255),
            Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.3), NumberSequenceKeypoint.new(0.3, 1.8), NumberSequenceKeypoint.new(1, 0)}),
            Rate = 100,
            Speed = NumberRange.new(5, 15),
            Lifetime = NumberRange.new(0.2, 0.5),
            SpreadAngle = Vector2.new(180, 180),
            LightEmission = 1,
            RotSpeed = NumberRange.new(-360, 360),
            Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.2), NumberSequenceKeypoint.new(1, 1)}),
        },
        DarkSpirit = {
            Color = ColorSequence.new(Color3.fromRGB(100, 0, 180), Color3.fromRGB(50, 0, 100)),
            LightColor = Color3.fromRGB(100, 0, 180),
            Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.5, 3), NumberSequenceKeypoint.new(1, 0)}),
            Rate = 40,
            Speed = NumberRange.new(1, 3),
            Lifetime = NumberRange.new(1, 2.5),
            SpreadAngle = Vector2.new(40, 40),
            LightEmission = 0.6,
            RotSpeed = NumberRange.new(-45, 45),
            Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.4), NumberSequenceKeypoint.new(1, 1)}),
        },
        Toxic = {
            Color = ColorSequence.new(Color3.fromRGB(0, 255, 80), Color3.fromRGB(80, 255, 0)),
            LightColor = Color3.fromRGB(0, 255, 80),
            Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.5), NumberSequenceKeypoint.new(0.5, 2), NumberSequenceKeypoint.new(1, 0)}),
            Rate = 60,
            Speed = NumberRange.new(2, 5),
            Lifetime = NumberRange.new(0.8, 1.5),
            SpreadAngle = Vector2.new(30, 30),
            LightEmission = 0.8,
            RotSpeed = NumberRange.new(-60, 60),
            Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.3), NumberSequenceKeypoint.new(1, 1)}),
        },
        Frost = {
            Color = ColorSequence.new(Color3.fromRGB(200, 230, 255), Color3.fromRGB(150, 200, 255)),
            LightColor = Color3.fromRGB(180, 220, 255),
            Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.3), NumberSequenceKeypoint.new(0.5, 1.5), NumberSequenceKeypoint.new(1, 0)}),
            Rate = 50,
            Speed = NumberRange.new(1, 3),
            Lifetime = NumberRange.new(1, 2),
            SpreadAngle = Vector2.new(50, 50),
            LightEmission = 0.7,
            RotSpeed = NumberRange.new(-30, 30),
            Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.3), NumberSequenceKeypoint.new(1, 1)}),
        },
    }

    function ClearAura()
        for _, obj in pairs(AuraObjects) do
            if obj and obj.Parent then obj:Destroy() end
        end
        AuraObjects = {}
    end

    function ApplyAura(auraName)
        ClearAura()
        if not auraName then ActiveAura = nil; return end
        local def = AURA_DEFS[auraName]
        if not def then ActiveAura = nil; return end
        ActiveAura = auraName
        local char = player.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        pcall(function()
            local emitter = Instance.new("ParticleEmitter")
            emitter.Name = "RitualAura"
            emitter.Texture = "rbxassetid://243098098"
            emitter.Color = def.Color
            emitter.Size = def.Size
            emitter.Rate = def.Rate
            emitter.Speed = def.Speed
            emitter.Lifetime = def.Lifetime
            emitter.SpreadAngle = def.SpreadAngle
            emitter.LightEmission = def.LightEmission
            emitter.RotSpeed = def.RotSpeed
            emitter.Transparency = def.Transparency
            emitter.Parent = hrp
            table.insert(AuraObjects, emitter)
            local light = Instance.new("PointLight")
            light.Name = "RitualAuraLight"
            light.Color = def.LightColor
            light.Brightness = 2
            light.Range = 15
            light.Parent = hrp
            table.insert(AuraObjects, light)
        end)
    end

    player.CharacterAdded:Connect(function(char)
        task.wait(0.5)
        if FakeKorbloxEnabled then applyFakeKorblox(char) end
        if FakeHeadlessEnabled then applyFakeHeadless(char) end
        if ActiveAura then ApplyAura(ActiveAura) end
    end)

    -- ============================================================
    -- FPS / PING MONITORING
    -- ============================================================
    spawn(function()
        local frameCount = 0
        local lastTime = tick()
        RunService.RenderStepped:Connect(function()
            frameCount = frameCount + 1
        end)
        while true do
            wait(1)
            local now = tick()
            local elapsed = now - lastTime
            currentFPS = math.floor(frameCount / elapsed)
            frameCount = 0
            lastTime = now
            pcall(function()
                currentPing = math.floor(player:GetNetworkPing() * 1000)
            end)
        end
    end)

    -- ============================================================
    -- FOV CIRCLE & SKILL AIMBOT HOOK (FOV-based aiming)
    -- ============================================================
    local FOVCircle = nil
    pcall(function()
        if Drawing and Drawing.new then
            FOVCircle = Drawing.new("Circle")
            FOVCircle.Visible = _G.G_SilentAimShowFOV
            FOVCircle.Color = Color3.fromRGB(255, 215, 0) -- gold
            FOVCircle.Radius = _G.G_SilentAimFOV
            FOVCircle.Thickness = 2
            FOVCircle.Filled = false
        end
    end)

    local currentSilentAimTarget = nil

    function IsSilentAimAlly(p)
        local main = player:FindFirstChild("PlayerGui") and player.PlayerGui:FindFirstChild("Main")
        local frame = main and main:FindFirstChild("Allies")
            and main.Allies:FindFirstChild("Container")
            and main.Allies.Container:FindFirstChild("Allies")
            and main.Allies.Container.Allies:FindFirstChild("ScrollingFrame")
            and main.Allies.Container.Allies.ScrollingFrame:FindFirstChild("Frame")
        if not frame then return false end
        return frame:FindFirstChild(p.Name) ~= nil
    end

    function IsSilentAimEnemy(p)
        if not p or p == player then return false end
        if IsSilentAimAlly(p) then return false end
        local myTeam, targetTeam = player.Team, p.Team
        if myTeam and targetTeam and myTeam.Name == "Marines" and targetTeam.Name == "Marines" then
            return false
        end
        return true
    end

    function AX_ReadPvPState(target)
        local ok, on = pcall(function()
            local attr = target:GetAttribute("PvpDisabled")
            if attr ~= nil then return attr ~= true end
            local main = target.PlayerGui and target.PlayerGui:FindFirstChild("Main")
            if main then
                local dis = main:FindFirstChild("PvpDisabled")
                if dis then return not dis.Visible end
                local pvp = main:FindFirstChild("Pvp")
                if pvp then
                    local frame = pvp:FindFirstChild("Frame")
                    if frame then
                        local btn = frame:FindFirstChild("PvpButton") or frame:FindFirstChildOfClass("TextButton")
                        if btn and btn:IsA("TextButton") then
                            local txt = tostring(btn.Text or ""):upper()
                            if txt:find("OFF") then return false end
                            if txt:find("ON") then return true end
                        end
                    end
                end
            end
            return true
        end)
        return not ok or on
    end

    function AX_InSafeZone(target)
        local ok, inZone = pcall(function()
            local char = target.Character
            if not char then return false end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp then return false end
            local wo = workspace:FindFirstChild("_WorldOrigin")
            if not wo then return false end

            local safeZones = wo:FindFirstChild("SafeZones")
            if safeZones then
                for _, zone in pairs(safeZones:GetChildren()) do
                    local mesh = zone:FindFirstChild("Mesh")
                    if mesh and mesh:IsA("SpecialMesh") then
                        local realDiameter = zone.Size.X * mesh.Scale.X
                        local radius = realDiameter / 2
                        if radius and radius > 0 then
                            local dist = (zone.Position - hrp.Position).Magnitude
                            if dist <= radius then return true end
                        end
                    end
                end
            end

            local spawns = wo:FindFirstChild("PlayerSpawns")
            if spawns then
                local folder = spawns:FindFirstChild(tostring(target.Team)) or spawns:FindFirstChild("Pirates")
                if folder then
                    for _, sp in pairs(folder:GetChildren()) do
                        local part = sp:FindFirstChild("Part")
                        if part and (hrp.Position - part.Position).Magnitude <= 400 then
                            return true
                        end
                    end
                end
            end
            return false
        end)
        return ok and inZone
    end

    _G.G_AimbotSafeZoneCheck = true
    _G.G_AimbotPvPCheck = true

    function GetClosestTargetToCenter()
        local myChar = player.Character
        local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
        if not myHRP then return nil end

        local maxDist3D = maxRange or 3500

        if _G.G_SilentAimSelectedPlayer and _G.G_SilentAimSelectedPlayer ~= "" and _G.G_SilentAimSelectedPlayer ~= "Nearest" then
            local targetP = Players:FindFirstChild(_G.G_SilentAimSelectedPlayer)
            if targetP and targetP ~= player and targetP.Character and not BlacklistedPlayers[targetP.Name] then
                if _G.G_AimbotPvPCheck and not AX_ReadPvPState(targetP) then return nil end
                if _G.G_AimbotSafeZoneCheck and AX_InSafeZone(targetP) then return nil end
                if not _G.G_SilentAimTeamCheck or IsSilentAimEnemy(targetP) then
                    local hum = targetP.Character:FindFirstChildOfClass("Humanoid")
                    local hrp = targetP.Character:FindFirstChild("HumanoidRootPart")
                    if hum and hum.Health > 0 and hrp then
                        return targetP.Character:FindFirstChild(_G.G_SilentAimPart) or hrp
                    end
                end
            end
            return nil
        end

        local closestPart = nil
        local shortest3DDist = maxDist3D

        local function checkTargetPart(character)
            if not character or character == myChar then return end

            local p = Players:GetPlayerFromCharacter(character)
            if p then
                if p == player or BlacklistedPlayers[p.Name] then return end
                if _G.G_AimbotPvPCheck and not AX_ReadPvPState(p) then return end
                if _G.G_AimbotSafeZoneCheck and AX_InSafeZone(p) then return end
                if _G.G_SilentAimTeamCheck and not IsSilentAimEnemy(p) then return end
            end

            local hum = character:FindFirstChildOfClass("Humanoid")
            if not hum or hum.Health <= 0 then return end
            local part = character:FindFirstChild(_G.G_SilentAimPart) or character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Head")
            if not part then return end

            local worldDist = (part.Position - myHRP.Position).Magnitude
            if worldDist <= shortest3DDist then
                shortest3DDist = worldDist
                closestPart = part
            end
        end

        local wantPlayers = _G.G_SilentAimTargetPlayers
        local wantMobs = _G.G_SilentAimTargetMobs

        if wantPlayers then
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= player then
                    checkTargetPart(p.Character)
                end
            end
        end

        if wantMobs then
            local enemies = workspace:FindFirstChild("Enemies")
            if enemies then
                for _, enemy in ipairs(enemies:GetChildren()) do
                    checkTargetPart(enemy)
                end
            end
            for _, obj in ipairs(workspace:GetChildren()) do
                if obj:IsA("Model") and obj ~= myChar and obj:FindFirstChildOfClass("Humanoid") then
                    checkTargetPart(obj)
                end
            end
        end

        return closestPart
    end

    -- Metamethods for silent aim (hook mouse.Hit and remote events)
    local oldIndex = nil
    local oldNamecall = nil

    if hookmetamethod then
        pcall(function()
            oldIndex = hookmetamethod(game, "__index", newcclosure(function(self, key)
                if not checkcaller() then
                    if self == mouse and (key == "Hit" or key == "Target") then
                        if SoruAimbotEnabled then
                            local targetName = SelectedSoruTarget
                            if targetName == "Nearest" then
                                local cl = getClosestPlayer(soruMaxDist)
                                local p  = cl and Players:GetPlayerFromCharacter(cl)
                                targetName = p and p.Name or nil
                            end
                            if targetName then
                                local tObj = Players:FindFirstChild(targetName)
                                local eHRP = tObj and tObj.Character and tObj.Character:FindFirstChild("HumanoidRootPart")
                                if eHRP then
                                    local myHRP = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                                    if myHRP and (myHRP.Position - eHRP.Position).Magnitude <= (soruMaxDist or 3500) then
                                        if key == "Hit"    then return CFrame.new(eHRP.Position) end
                                        if key == "Target" then return eHRP end
                                    end
                                end
                            end
                        end

                        if _G.G_SilentAimSkill and currentSilentAimTarget and IsCurrentToolAimbotAllowed() and IsCurrentSlotAimbotAllowed() then
                            if key == "Hit"    then return CFrame.new(currentSilentAimTarget.Position) end
                            if key == "Target" then return currentSilentAimTarget end
                        end
                    end
                end
                return oldIndex(self, key)
            end))
        end)

        pcall(function()
            oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
                local args = {...}
                local ncm = getnamecallmethod and getnamecallmethod()
                local method = ncm and tostring(ncm):lower() or ""

                if not checkcaller() then
                    if (method == "fireserver" or method == "invokeserver") then
                        local calledSkill = nil
                        for _, arg in ipairs(args) do
                            if typeof(arg) == "string" then
                                local sUpper = string.upper(arg)
                                if sUpper == "Z" or sUpper == "X" or sUpper == "C" or sUpper == "V" or sUpper == "F" then
                                    calledSkill = sUpper
                                    break
                                end
                            end
                        end

                        if _G.G_SilentAimSkill and currentSilentAimTarget and IsCurrentToolAimbotAllowed() and IsCurrentSlotAimbotAllowed(calledSkill) then
                            local activePos = currentSilentAimTarget.Position

                            if self.Name == "RE/RegisterHit" or self.Name == "RegisterHit" or self.Name:find("RegisterHit") then
                                local targetChar = currentSilentAimTarget.Parent
                                local targetHead = targetChar and (targetChar:FindFirstChild("Head") or targetChar:FindFirstChild("HumanoidRootPart")) or currentSilentAimTarget
                                if targetHead and targetChar then
                                    args[1] = targetHead
                                    args[2] = { { targetChar, targetHead } }
                                    return oldNamecall(self, unpack(args))
                                end
                            end

                            if self.Name == "RE/ShootGunEvent" or self.Name == "ShootGunEvent" or self.Name:find("ShootGunEvent") then
                                args[1] = activePos
                                if currentSilentAimTarget.Parent then
                                    args[2] = { currentSilentAimTarget.Parent }
                                end
                                return oldNamecall(self, unpack(args))
                            end

                            for i, arg in ipairs(args) do
                                if typeof(arg) == "Vector3" then 
                                    args[i] = activePos
                                elseif typeof(arg) == "CFrame" then 
                                    args[i] = CFrame.new(activePos)
                                end
                            end
                            return oldNamecall(self, unpack(args))
                        end
                    elseif (method == "raycast" or method == "findpartonray" or method == "findpartonraywithignorelist" or method == "findpartonraywithwhitelist") then
                        if _G.G_SilentAimSkill and currentSilentAimTarget and IsCurrentToolAimbotAllowed() and IsCurrentSlotAimbotAllowed() then
                            if method == "raycast" then
                                return {
                                    Instance = currentSilentAimTarget,
                                    Position = currentSilentAimTarget.Position,
                                    Hit = currentSilentAimTarget.Position,
                                    Normal = Vector3.new(0, 1, 0),
                                    Material = Enum.Material.SmoothPlastic
                                }
                            else
                                return currentSilentAimTarget, currentSilentAimTarget.Position, Vector3.new(0, 1, 0), Enum.Material.SmoothPlastic
                            end
                        end
                    end
                end

                return oldNamecall(self, ...)
            end))
        end)
    else
        pcall(function()
            local mt = getrawmetatable and getrawmetatable(game)
            if mt then
                oldIndex = mt.__index
                oldNamecall = mt.__namecall
                if setreadonly then pcall(setreadonly, mt, false) end

                mt.__index = newcclosure(function(self, key)
                    if not checkcaller() and self == mouse and (key == "Hit" or key == "Target") then
                        if _G.G_SilentAimSkill and currentSilentAimTarget and IsCurrentToolAimbotAllowed() and IsCurrentSlotAimbotAllowed() then
                            if key == "Hit"    then return CFrame.new(currentSilentAimTarget.Position) end
                            if key == "Target" then return currentSilentAimTarget end
                        end
                    end
                    return oldIndex(self, key)
                end)

                mt.__namecall = newcclosure(function(self, ...)
                    local args = {...}
                    local ncm = getnamecallmethod and getnamecallmethod()
                    local method = ncm and tostring(ncm):lower() or ""

                    if not checkcaller() and (method == "fireserver" or method == "invokeserver") then
                        local calledSkill = nil
                        for _, arg in ipairs(args) do
                            if typeof(arg) == "string" then
                                local sUpper = string.upper(arg)
                                if sUpper == "Z" or sUpper == "X" or sUpper == "C" or sUpper == "V" or sUpper == "F" then
                                    calledSkill = sUpper
                                    break
                                end
                            end
                        end

                        if _G.G_SilentAimSkill and currentSilentAimTarget and IsCurrentToolAimbotAllowed() and IsCurrentSlotAimbotAllowed(calledSkill) then
                            local activePos = currentSilentAimTarget.Position

                            if self.Name == "RE/RegisterHit" or self.Name == "RegisterHit" or self.Name:find("RegisterHit") then
                                local targetChar = currentSilentAimTarget.Parent
                                local targetHead = targetChar and (targetChar:FindFirstChild("Head") or targetChar:FindFirstChild("HumanoidRootPart")) or currentSilentAimTarget
                                if targetHead and targetChar then
                                    args[1] = targetHead
                                    args[2] = { { targetChar, targetHead } }
                                    return oldNamecall(self, unpack(args))
                                end
                            end

                            if self.Name == "RE/ShootGunEvent" or self.Name == "ShootGunEvent" or self.Name:find("ShootGunEvent") then
                                args[1] = activePos
                                if currentSilentAimTarget.Parent then
                                    args[2] = { currentSilentAimTarget.Parent }
                                end
                                return oldNamecall(self, unpack(args))
                            end

                            for i, arg in ipairs(args) do
                                if typeof(arg) == "Vector3" then 
                                    args[i] = activePos
                                elseif typeof(arg) == "CFrame" then 
                                    args[i] = CFrame.new(activePos)
                                end
                            end
                            return oldNamecall(self, unpack(args))
                        end
                    end

                    return oldNamecall(self, ...)
                end)
                if setreadonly then pcall(setreadonly, mt, true) end
            end
        end)
    end

    function IsCurrentToolAimbotAllowed() return true end
    function IsCurrentSlotAimbotAllowed(explicitSkillKey) return true end

    local MouseModuleInstance = ReplicatedStorage:FindFirstChild("Mouse")
    local MouseModule = nil
    if MouseModuleInstance then
        pcall(function() MouseModule = require(MouseModuleInstance) end)
    end
    if MouseModule and typeof(MouseModule) == "table" then
        pcall(function()
            local realStore = { Hit = rawget(MouseModule, "Hit"), Target = rawget(MouseModule, "Target") }
            local mmt = getrawmetatable(MouseModule)
            if mmt then setreadonly(mmt, false) else mmt = {}; setmetatable(MouseModule, mmt) end
            rawset(MouseModule, "Hit", nil); rawset(MouseModule, "Target", nil)
            mmt.__index = function(self, key)
                if key == "Hit" then
                    if _G.G_SilentAimSkill and currentSilentAimTarget and IsCurrentToolAimbotAllowed() and IsCurrentSlotAimbotAllowed() then return CFrame.new(currentSilentAimTarget.Position) end
                    return realStore.Hit
                elseif key == "Target" then
                    if _G.G_SilentAimSkill and currentSilentAimTarget and IsCurrentToolAimbotAllowed() and IsCurrentSlotAimbotAllowed() then return currentSilentAimTarget end
                    return realStore.Target
                end
            end
            mmt.__newindex = function(self, key, value)
                if key == "Hit" or key == "Target" then realStore[key] = value else rawset(self, key, value) end
            end
            setreadonly(mmt, true)
        end)
    end

    RunService.RenderStepped:Connect(function()
        pcall(function()
            local cam = workspace.CurrentCamera
            local screenCenter = cam and Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2) or Vector2.new(0, 0)

            if _G.G_SilentAimShowFOV and FOVCircle then
                pcall(function()
                    FOVCircle.Visible = true
                    FOVCircle.Radius = _G.G_SilentAimFOV or 150
                    FOVCircle.Color = currentThemeColor
                    FOVCircle.Position = screenCenter
                end)
            else
                if FOVCircle then pcall(function() FOVCircle.Visible = false end) end
            end

            currentSilentAimTarget = GetClosestTargetToCenter()
        end)
    end)

    -- ============================================================
    -- INTERFAZ VISUAL
    -- ============================================================
    local THEMES = {
        ["Rainbow RGB"] = Color3.fromRGB(255, 0, 128),
        ["Snow White"] = Color3.fromRGB(255, 255, 255),
        ["Neon Purple"] = Color3.fromRGB(170, 0, 255),
        ["Electric Blue"] = Color3.fromRGB(0, 150, 255),
        ["Crimson Red"] = Color3.fromRGB(255, 0, 50),
        ["Toxic Green"] = Color3.fromRGB(0, 255, 100),
        ["Hot Pink"] = Color3.fromRGB(255, 0, 255),
        ["Gold Yellow"] = Color3.fromRGB(255, 215, 0),
        ["Cyan"] = Color3.fromRGB(0, 255, 255),
        ["Orange"] = Color3.fromRGB(255, 140, 0),
    }
    local currentThemeColor = THEMES["Gold Yellow"]
    local COLORS = {
        Background = Color3.fromRGB(0, 0, 0),
        PanelBG = Color3.fromRGB(0, 0, 0),
        TextWhite = Color3.fromRGB(255, 255, 255),
        TextGray = Color3.fromRGB(200, 200, 210),
        ToggleOff = Color3.fromRGB(0, 0, 0),
    }
    local themeStrokes, themeTexts, themeFrames = {}, {}, {}

    local parentGui = nil
    pcall(function() if gethui then parentGui = gethui() end end)
    if not parentGui then
        pcall(function() parentGui = game:GetService("CoreGui") end)
    end
    if not parentGui and player then
        pcall(function() parentGui = player:FindFirstChild("PlayerGui") or player:WaitForChild("PlayerGui", 3) end)
    end

    local function safeParent(gui)
        if not gui then return end
        local ok = pcall(function() gui.Parent = parentGui end)
        if (not ok or not gui.Parent) and player then
            pcall(function() gui.Parent = player:FindFirstChild("PlayerGui") or player:WaitForChild("PlayerGui", 3) end)
        end
    end

    GuiStore = {
        screenGui = Instance.new("ScreenGui"),
        toggleIconGui = Instance.new("ScreenGui"),
        playerWidgetGui = Instance.new("ScreenGui"),
        npcWidgetGui = Instance.new("ScreenGui"),
        superJumpWidgetGui = Instance.new("ScreenGui"),
        portalSoruWidgetGui = Instance.new("ScreenGui"),
    }

    GuiStore.screenGui.Name = "RitualUI_UltimateUI"
    GuiStore.screenGui.ResetOnSpawn = false
    safeParent(GuiStore.screenGui)

    GuiStore.toggleIconGui.Name = "RitualUI_ToggleIcon"
    GuiStore.toggleIconGui.ResetOnSpawn = false
    safeParent(GuiStore.toggleIconGui)

    GuiStore.playerWidgetGui.Name = "RitualUI_PlayerWidget"
    GuiStore.playerWidgetGui.ResetOnSpawn = false
    GuiStore.playerWidgetGui.DisplayOrder = 99999
    GuiStore.playerWidgetGui.IgnoreGuiInset = true
    safeParent(GuiStore.playerWidgetGui)

    GuiStore.npcWidgetGui.Name = "RitualUI_NpcWidget"
    GuiStore.npcWidgetGui.ResetOnSpawn = false
    GuiStore.npcWidgetGui.DisplayOrder = 99999
    GuiStore.npcWidgetGui.IgnoreGuiInset = true
    safeParent(GuiStore.npcWidgetGui)

    GuiStore.superJumpWidgetGui.Name = "RitualUI_SuperJumpWidget"
    GuiStore.superJumpWidgetGui.ResetOnSpawn = false
    GuiStore.superJumpWidgetGui.DisplayOrder = 99999
    GuiStore.superJumpWidgetGui.IgnoreGuiInset = true
    safeParent(GuiStore.superJumpWidgetGui)

    GuiStore.portalSoruWidgetGui.Name = "RitualUI_PortalSoruWidget"
    GuiStore.portalSoruWidgetGui.ResetOnSpawn = false
    GuiStore.portalSoruWidgetGui.DisplayOrder = 99999
    GuiStore.portalSoruWidgetGui.IgnoreGuiInset = true
    safeParent(GuiStore.portalSoruWidgetGui)

    local screenGui = GuiStore.screenGui
    local toggleIconGui = GuiStore.toggleIconGui
    local playerWidgetGui = GuiStore.playerWidgetGui
    local npcWidgetGui = GuiStore.npcWidgetGui
    local superJumpWidgetGui = GuiStore.superJumpWidgetGui
    local portalSoruWidgetGui = GuiStore.portalSoruWidgetGui

    -- ============================================================
    -- CREAR WIDGETS FLOTANTES
    -- ============================================================
    function updateWidgetsVisuals()
        local isLight = isColorLight(currentThemeColor)
        local darkTxt = Color3.fromRGB(15, 10, 20)
        local lightTxt = Color3.fromRGB(255, 255, 255)

        if PlayerWidgetBtn then
            PlayerWidgetBtn.Visible = PlayerWidgetActive
            PlayerWidgetBtn.BackgroundColor3 = AimlockPlayerEnabled and currentThemeColor or Color3.fromRGB(0, 0, 0)
            PlayerWidgetBtn.BackgroundTransparency = AimlockPlayerEnabled and 0 or 1
            PlayerWidgetBtn.TextColor3 = AimlockPlayerEnabled and (isLight and darkTxt or lightTxt) or lightTxt
            PlayerWidgetBtn.Text = AimlockPlayerEnabled and "🔒 PLAYER: ON" or "🔓 PLAYER: OFF"
        end
        if NpcWidgetBtn then
            NpcWidgetBtn.Visible = NpcWidgetActive
            NpcWidgetBtn.BackgroundColor3 = AimlockNpcEnabled and currentThemeColor or Color3.fromRGB(0, 0, 0)
            NpcWidgetBtn.BackgroundTransparency = AimlockNpcEnabled and 0 or 1
            NpcWidgetBtn.TextColor3 = AimlockNpcEnabled and (isLight and darkTxt or lightTxt) or lightTxt
            NpcWidgetBtn.Text = AimlockNpcEnabled and "🔒 NPC: ON" or "🔓 NPC: OFF"
        end
        if SuperJumpWidget then
            SuperJumpWidget.Visible = SuperJumpWidgetVisible
            SuperJumpWidget.BackgroundColor3 = currentThemeColor
            SuperJumpWidget.BackgroundTransparency = 0
            SuperJumpWidget.TextColor3 = isLight and darkTxt or lightTxt
            SuperJumpWidget.Text = "⬆ JUMP"
        end
    end

    function makeFloatingWidget(parent, pos, title)
        pcall(function()
            parent.DisplayOrder = 99999
            parent.IgnoreGuiInset = true
            parent.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        end)

        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 130, 0, 36)
        btn.Position = pos
        btn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        btn.BackgroundTransparency = 0
        btn.Font = Enum.Font.GothamBold
        btn.TextColor3 = COLORS.TextWhite
        btn.TextSize = 11.5
        btn.Visible = false
        btn.Active = true
        btn.Draggable = true
        btn.ZIndex = 1000
        btn.Parent = parent
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
        local sk = Instance.new("UIStroke", btn)
        sk.Color = currentThemeColor
        sk.Thickness = 2
        table.insert(themeStrokes, sk)
        return btn
    end

    SuperJumpWidget = makeFloatingWidget(superJumpWidgetGui, UDim2.new(0.68, 0, 0.25, 0), "SJUMP")
    SuperJumpWidget.Text = "⬆ JUMP"
    SuperJumpWidget.MouseButton1Click:Connect(function()
        if doSuperJump then doSuperJump() end
    end)

    function makeWidget(parent, pos)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 115, 0, 36)
        btn.Position = pos
        btn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        btn.BackgroundTransparency = 0
        btn.Font = Enum.Font.GothamBold
        btn.TextColor3 = COLORS.TextWhite
        btn.TextSize = 10
        btn.Visible = false
        btn.Active = true
        btn.Draggable = true
        btn.Parent = parent
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
        local sk = Instance.new("UIStroke", btn)
        sk.Color = currentThemeColor
        sk.Thickness = 2
        table.insert(themeStrokes, sk)
        return btn
    end

    PlayerWidgetBtn = makeWidget(playerWidgetGui, UDim2.new(0.82, 0, 0.20, 0))
    PlayerWidgetBtn.Text = "🔓 PLAYER: OFF"
    PlayerWidgetBtn.MouseButton1Click:Connect(function()
        AimlockPlayerEnabled = not AimlockPlayerEnabled
        updateWidgetsVisuals()
    end)

    NpcWidgetBtn = makeWidget(npcWidgetGui, UDim2.new(0.82, 0, 0.27, 0))
    NpcWidgetBtn.Text = "🔓 NPC: OFF"
    NpcWidgetBtn.MouseButton1Click:Connect(function()
        AimlockNpcEnabled = not AimlockNpcEnabled
        updateWidgetsVisuals()
    end)

    -- ============================================================
    -- INTERFAZ PRINCIPAL
    -- ============================================================
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "RitualMainFrame"
    mainFrame.Size = UDim2.new(0, 480, 0, 315)
    mainFrame.Position = UDim2.new(0.5, -240, 0.5, -157)
    mainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    mainFrame.BackgroundTransparency = 0
    mainFrame.Visible = true
    mainFrame.Active = true
    mainFrame.Draggable = true
    mainFrame.Parent = screenGui
    Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 24)

    local mainFrameStroke = Instance.new("UIStroke", mainFrame)
    mainFrameStroke.Color = currentThemeColor
    mainFrameStroke.Thickness = 2
    table.insert(themeStrokes, mainFrameStroke)

    -- Animated golden rain
    local rainContainer = Instance.new("Frame", mainFrame)
    rainContainer.Size = UDim2.new(1, 0, 1, 0)
    rainContainer.BackgroundTransparency = 1
    rainContainer.ClipsDescendants = true
    rainContainer.ZIndex = 1
    Instance.new("UICorner", rainContainer).CornerRadius = UDim.new(0, 50)

    local activeRainDrops = 0
    local MAX_RAIN_DROPS = 12

    function createIntenseRainDrop()
        if not mainFrame.Visible or activeRainDrops >= MAX_RAIN_DROPS then return end
        activeRainDrops = activeRainDrops + 1
        
        local drop = Instance.new("Frame", rainContainer)
        drop.Name = "RainDrop"
        drop.Size = UDim2.new(0, 2, 0, math.random(14, 26))
        drop.Position = UDim2.new(math.random(1, 99) / 100, 0, -0.15, 0)
        drop.BackgroundColor3 = currentThemeColor
        drop.BackgroundTransparency = math.random(2, 5) / 10
        drop.BorderSizePixel = 0
        Instance.new("UICorner", drop).CornerRadius = UDim.new(1, 0)

        local targetX = drop.Position.X.Scale - (math.random(3, 8) / 100)
        local duration = math.random(4, 9) / 10

        local tw = TweenService:Create(drop, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
            Position = UDim2.new(targetX, 0, 1.15, 0),
            BackgroundTransparency = 1
        })
        tw:Play()
        tw.Completed:Connect(function()
            activeRainDrops = activeRainDrops - 1
            drop:Destroy()
        end)
    end

    task.spawn(function()
        while true do
            task.wait(0.04)
            pcall(createIntenseRainDrop)
        end
    end)

    function centerAndMaximizeUI()
        mainFrame.Visible = true
        TweenService:Create(mainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            Position = UDim2.new(0.5, -230, 0.5, -155)
        }):Play()
    end

    local openButton = Instance.new("TextButton")
    openButton.Size = UDim2.new(0, 42, 0, 42)
    openButton.Position = UDim2.new(0, 15, 0, 15)
    openButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    openButton.BackgroundTransparency = 0
    openButton.Text = ""
    openButton.Visible = false
    openButton.Active = true
    openButton.Draggable = true
    openButton.Parent = toggleIconGui

    Instance.new("UICorner", openButton).CornerRadius = UDim.new(0, 8)
    local openStroke = Instance.new("UIStroke", openButton)
    openStroke.Thickness = 2
    openStroke.Transparency = 0
    openStroke.Color = currentThemeColor
    table.insert(themeStrokes, openStroke)

    openButton.MouseButton1Click:Connect(function()
        openButton.Visible = false
        centerAndMaximizeUI()
    end)

    local topLabel = Instance.new("TextLabel", mainFrame)
    topLabel.Size = UDim2.new(0, 200, 0, 22)
    topLabel.Position = UDim2.new(0.5, -100, 0, 12)
    topLabel.BackgroundTransparency = 1
    topLabel.Text = "🎵 TikTok: @rivalsxrodx"
    topLabel.Font = Enum.Font.GothamBold
    topLabel.TextSize = 10
    topLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    topLabel.TextStrokeTransparency = 0
    topLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    topLabel.TextXAlignment = Enum.TextXAlignment.Center

    local controlsContainer = Instance.new("Frame", mainFrame)
    controlsContainer.Size = UDim2.new(0, 50, 0, 25)
    controlsContainer.Position = UDim2.new(1, -60, 0, 12)
    controlsContainer.BackgroundTransparency = 1

    function createTopControl(text, xOff, color, cb)
        local btn = Instance.new("TextButton", controlsContainer)
        btn.Size = UDim2.new(0, 22, 0, 22)
        btn.Position = UDim2.new(0, xOff, 0, 0)
        btn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        btn.BackgroundTransparency = 0
        btn.Text = text
        btn.Font = Enum.Font.GothamBlack
        btn.TextSize = 14
        btn.TextColor3 = color
        btn.TextStrokeTransparency = 0
        btn.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
        local tcStroke = Instance.new("UIStroke", btn)
        tcStroke.Color = currentThemeColor
        tcStroke.Thickness = 1.5
        btn.MouseButton1Click:Connect(cb)
    end

    createTopControl("-", 0, Color3.fromRGB(255, 255, 255), function()
        mainFrame.Visible = false
        openButton.Visible = true
    end)
    createTopControl("X", 26, Color3.fromRGB(255, 75, 75), function()
        screenGui:Destroy(); toggleIconGui:Destroy()
        playerWidgetGui:Destroy(); npcWidgetGui:Destroy()
        superJumpWidgetGui:Destroy()
        portalSoruWidgetGui:Destroy()
        if fpsOverlayGui then fpsOverlayGui:Destroy() end
        ClearESP()
    end)

    local sidebar = Instance.new("Frame", mainFrame)
    sidebar.Size = UDim2.new(0, 115, 1, 0)
    sidebar.Position = UDim2.new(0, 10, 0, 0)
    sidebar.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    sidebar.BackgroundTransparency = 0
    Instance.new("UICorner", sidebar).CornerRadius = UDim.new(0, 16)
    local sidebarStroke = Instance.new("UIStroke", sidebar)
    sidebarStroke.Color = currentThemeColor
    sidebarStroke.Thickness = 1.5
    table.insert(themeStrokes, sidebarStroke)

    local mainTitle = Instance.new("TextLabel", sidebar)
    mainTitle.Text = "RITUAL HUB"
    mainTitle.Font = Enum.Font.GothamBlack
    mainTitle.TextSize = 17
    mainTitle.TextColor3 = currentThemeColor
    mainTitle.Size = UDim2.new(0, 110, 0, 20)
    mainTitle.Position = UDim2.new(0, 14, 0, 10)
    mainTitle.BackgroundTransparency = 1
    mainTitle.TextXAlignment = Enum.TextXAlignment.Left
    table.insert(themeTexts, mainTitle)

    -- Pulse animation
    task.spawn(function()
        while true do
            task.wait(1.5)
            pcall(function()
                if mainTitle and mainTitle.Parent then
                    TweenService:Create(mainTitle, TweenInfo.new(0.75, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                        TextTransparency = 0.35
                    }):Play()
                    task.wait(0.75)
                    TweenService:Create(mainTitle, TweenInfo.new(0.75, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                        TextTransparency = 0
                    }):Play()
                end
            end)
        end
    end)

    local subTitle = Instance.new("TextLabel", sidebar)
    subTitle.Text = "by: ritualz999 inspired by sacred ahk"
    subTitle.Font = Enum.Font.GothamBold
    subTitle.TextSize = 10.5
    subTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    subTitle.Size = UDim2.new(1, 0, 0, 14)
    subTitle.Position = UDim2.new(0, 14, 0, 31)
    subTitle.BackgroundTransparency = 1
    subTitle.TextXAlignment = Enum.TextXAlignment.Left

    local PagesContainer = Instance.new("Frame", mainFrame)
    PagesContainer.Size = UDim2.new(0, 320, 1, -55)
    PagesContainer.Position = UDim2.new(0, 125, 0, 45)
    PagesContainer.BackgroundTransparency = 1
    PagesContainer.ClipsDescendants = false

    function createScrollingPage()
        local sf = Instance.new("ScrollingFrame", PagesContainer)
        sf.Size = UDim2.new(1, 0, 1, 0)
        sf.BackgroundTransparency = 1
        sf.BorderSizePixel = 0
        sf.ScrollBarThickness = 4
        sf.CanvasSize = UDim2.new(0, 0, 0, 800)
        sf.Visible = false

        local pad = Instance.new("UIPadding", sf)
        pad.PaddingTop = UDim.new(0, 12)
        pad.PaddingBottom = UDim.new(0, 15)

        local layout = Instance.new("UIListLayout", sf)
        layout.Padding = UDim.new(0, 8)
        layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            sf.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 45)
        end)
        return sf
    end

    local StatsPage = createScrollingPage()
    local CombatPage = createScrollingPage()
    local GlitchesPage = createScrollingPage()
    local CamLockPage = createScrollingPage() -- ESP
    local SoruPage = createScrollingPage()
    local MiscPage = createScrollingPage()
    StatsPage.Visible = true

    local RightPanel = Instance.new("Frame", mainFrame)
    RightPanel.Size = UDim2.new(0, 160, 1, -55)
    RightPanel.Position = UDim2.new(0, 295, 0, 45)
    RightPanel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    RightPanel.BackgroundTransparency = 0
    RightPanel.Visible = false
    Instance.new("UICorner", RightPanel).CornerRadius = UDim.new(0, 8)
    local rpStroke = Instance.new("UIStroke", RightPanel)
    rpStroke.Color = currentThemeColor
    rpStroke.Thickness = 1.5
    table.insert(themeStrokes, rpStroke)

    local ListScroll = Instance.new("ScrollingFrame", RightPanel)
    ListScroll.Size = UDim2.new(1, -10, 1, -30)
    ListScroll.Position = UDim2.new(0, 5, 0, 24)
    ListScroll.BackgroundTransparency = 1
    ListScroll.BorderSizePixel = 0
    ListScroll.ScrollBarThickness = 3
    ListScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Instance.new("UIListLayout", ListScroll).Padding = UDim.new(0, 4)

    local DropLabel = Instance.new("TextButton", ListScroll)
    DropLabel.Name = "DropLabel"
    DropLabel.Size = UDim2.new(1, 0, 0, 24)
    DropLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    DropLabel.BackgroundTransparency = 0
    DropLabel.Text = "🎯 Selector: Nearest"
    DropLabel.Font = Enum.Font.GothamBold
    DropLabel.TextColor3 = currentThemeColor
    DropLabel.TextSize = 8.5
    Instance.new("UICorner", DropLabel).CornerRadius = UDim.new(0, 4)
    local dlStroke = Instance.new("UIStroke", DropLabel)
    dlStroke.Color = currentThemeColor
    dlStroke.Thickness = 1.5
    table.insert(themeStrokes, dlStroke)
    table.insert(themeTexts, DropLabel)

    langBtn = nil
    saveBtn = nil
    resetBtn = nil

    TRANSLATIONS = {
        EN = {
            ["Stats"] = "Player Stats",
            ["Combat"] = "Combat Main",
            ["Glitches"] = "Glitches",
            ["ESP"] = "ESP & Visuals",
            ["Soru"] = "Soru Engine",
            ["Misc"] = "Config",
            ["Player Profile"] = "Player Profile",
            ["Combat Main"] = "Combat Main",
            ["Aimbot Modules"] = "Aimbot Modules",
            ["Fast Attack & Combat"] = "Fast Attack & Combat",
            ["Movement"] = "Movement",
            ["No Animations"] = "No Animations",
            ["Súper Jump"] = "Super Jump Glitch",
            ["Anti Lava"] = "Anti Lava Protection",
            ["FFlags 1"] = "FFlags 1",
            ["Macro Beta"] = "Macro Beta",
            ["ESP & Visuals"] = "ESP & Visuals",
            ["Camera Aimlock"] = "Camera Aimlock",
            ["Soru & Bypass"] = "Soru & Bypass Engine",
            ["Soru Engine"] = "Soru Engine",
            ["UI Theme Colors"] = "UI Theme Colors",
            ["Aura VFX"] = "Aura VFX",
            ["Fake Body"] = "Fake Body",
            ["Ambient Lights"] = "Ambient Lights",
            ["Config"] = "Config",
            ["Language"] = "Language",
            ["Auto Race V4"] = "Auto Race V4 (Awakening)",
            ["Silent Aim Blacklist"] = "Silent Aim Blacklist",
            ["Anti Stun and Hitbox Attack [Beta]"] = "Anti Stun and Hitbox Attack [Beta]",
            ["General ESP"] = "General ESP",
            ["Show Player Name"] = "Show Player Name",
            ["Show Player Level"] = "Show Player Level",
            ["Show Bounty/Honor"] = "Show Bounty/Honor",
            ["Show Devil Fruit"] = "Show Devil Fruit",
            ["Show Distance"] = "Show Distance",
            ["Show HP %"] = "Show HP %",
            ["Highlight Players"] = "Highlight Players",
            ["Aimbot Skills"] = "Aimbot Skills",
            ["Aimbot M1 (Dragon Gun) ⚠️ BAN RISK"] = "Aimbot M1 (Dragon Gun)",
            ["Target Players"] = "Target Players",
            ["Target NPCs"] = "Target NPCs",
            ["Team Check"] = "Team Check",
            ["Ignore Safe Zone"] = "Ignore Safe Zone",
            ["Ignore PvP OFF Players"] = "Ignore PvP OFF Players",
            ["Target Rainbow Body ESP"] = "Target Rainbow Body ESP",
            ["Fast Attack"] = "Fast Attack (3000 CPS)",
            ["Walk Speed"] = "Walk Speed Boost",
            ["Dash Distance"] = "Dash Distance Boost",
            ["Noclip"] = "Noclip (Through Walls)",
            ["Walk on Water"] = "Walk on Water",
            ["No Animations"] = "No Animations",
            ["Activar SJump"] = "Enable Super Jump",
            ["Anti Lava"] = "Anti Lava Protection",
            ["Activar FFlags1"] = "Activate FFlags 1",
            ["Activar Macro Beta"] = "Enable Macro Beta",
            ["Aimlock Target Players"] = "Aimlock Target Players",
            ["Aimlock Target NPCs"] = "Aimlock Target NPCs",
            ["Infinite Soru"] = "Infinite Soru (No Cooldown)",
            ["Soru Aimbot (TP)"] = "Soru Auto TP Aimbot",
            ["Portal Soru Combo"] = "Portal Soru Combo",
            ["Portal Sanguine C Combo"] = "Portal Sanguine C Combo",
            ["Fake Korblox"] = "Fake Korblox",
            ["Fake Headless"] = "Fake Headless",
            ["FPS & Ping Overlay"] = "FPS & Ping Overlay",
            ["Portal Soru Delay:"] = "Portal Soru Delay:",
            ["Sanguine C Delay:"] = "Sanguine C Delay:",
            ["Skill Delay:"] = "Skill Delay:",
            ["TP Distance:"] = "TP Distance:",
            ["FOV Radius:"] = "FOV Radius:",
            ["Show FOV Circle"] = "Show FOV Circle",
            ["Save Config"] = "💾 Save Config",
            ["Reset Config"] = "🔄 Reset Config",
            ["LangBtn"] = "🌐 Language: English (EN)",
        },
        ES = {
            ["Stats"] = "Estadísticas",
            ["Combat"] = "Combate",
            ["Glitches"] = "Trucos",
            ["ESP"] = "ESP / Visuales",
            ["Soru"] = "Motor Soru",
            ["Misc"] = "Configuración",
            ["Player Profile"] = "Perfil del Jugador",
            ["Combat Main"] = "Combate Principal",
            ["Aimbot Modules"] = "Módulos Aimbot",
            ["Fast Attack & Combat"] = "Ataque Rápido & Combate",
            ["Movement"] = "Movimiento y Física",
            ["No Animations"] = "Sin Animaciones",
            ["Súper Jump"] = "Glitch Súper Salto",
            ["Anti Lava"] = "Protección Anti Lava",
            ["FFlags 1"] = "FFlags 1",
            ["Macro Beta"] = "Macro Beta",
            ["ESP & Visuals"] = "ESP y Visuales",
            ["Camera Aimlock"] = "Aimlock de Cámara",
            ["Soru & Bypass"] = "Motor Soru y Bypass",
            ["Soru Engine"] = "Motor Soru y Bypass",
            ["UI Theme Colors"] = "Color de Tema UI",
            ["Aura VFX"] = "Aura VFX",
            ["Fake Body"] = "Cuerpo Falso",
            ["Ambient Lights"] = "Luces Ambientes",
            ["Config"] = "Configuración",
            ["Language"] = "Idioma",
            ["Auto Race V4"] = "Auto Raza V4 (Despertar)",
            ["Silent Aim Blacklist"] = "Lista Negra Silent Aim",
            ["Anti Stun and Hitbox Attack [Beta]"] = "Anti Aturdimiento y Ataque Hitbox [Beta]",
            ["General ESP"] = "ESP General",
            ["Show Player Name"] = "Mostrar Nombres",
            ["Show Player Level"] = "Mostrar Nivel",
            ["Show Bounty/Honor"] = "Mostrar Recompensa",
            ["Show Devil Fruit"] = "Mostrar Fruta",
            ["Show Distance"] = "Mostrar Distancia",
            ["Show HP %"] = "Mostrar Salud %",
            ["Highlight Players"] = "Resaltar Jugadores",
            ["Aimbot Skills"] = "Aimbot en Habilidades",
            ["Aimbot M1 (Dragon Gun) ⚠️ BAN RISK"] = "Aimbot M1 (Arma Dragón)",
            ["Target Players"] = "Apuntar a Jugadores",
            ["Target NPCs"] = "Apuntar a NPCs",
            ["Team Check"] = "Verificar Equipo",
            ["Ignore Safe Zone"] = "Ignorar Zona Segura",
            ["Ignore PvP OFF Players"] = "Ignorar Jugadores PvP OFF",
            ["Target Rainbow Body ESP"] = "Cuerpo Arcoíris en Objetivo",
            ["Fast Attack"] = "Ataque Rápido (3000 CPS)",
            ["Walk Speed"] = "Velocidad de Caminado",
            ["Dash Distance"] = "Distancia de Impulso",
            ["Noclip"] = "Atravesar Paredes (Noclip)",
            ["Walk on Water"] = "Caminar Sobre Agua",
            ["No Animations"] = "Sin Animaciones",
            ["Activar SJump"] = "Activar Súper Salto",
            ["Anti Lava"] = "Protección Anti Lava",
            ["Activar FFlags1"] = "Activar FFlags 1",
            ["Activar Macro Beta"] = "Activar Macro Beta",
            ["Aimlock Target Players"] = "Fijar Cámara en Jugadores",
            ["Aimlock Target NPCs"] = "Fijar Cámara en NPCs",
            ["Infinite Soru"] = "Soru Infinito (Sin Cooldown)",
            ["Soru Aimbot (TP)"] = "Aimbot Teletransporte Soru",
            ["Portal Soru Combo"] = "Combo Portal Soru",
            ["Portal Sanguine C Combo"] = "Combo Portal Sanguine C",
            ["Fake Korblox"] = "Korblox Falso",
            ["Fake Headless"] = "Sin Cabeza Falso",
            ["FPS & Ping Overlay"] = "Contador FPS y Ping",
            ["Portal Soru Delay:"] = "Retraso Portal Soru:",
            ["Sanguine C Delay:"] = "Retraso Sanguine C:",
            ["Skill Delay:"] = "Retraso Habilidad:",
            ["TP Distance:"] = "Distancia TP:",
            ["FOV Radius:"] = "Radio FOV:",
            ["Show FOV Circle"] = "Mostrar Círculo FOV",
            ["Save Config"] = "💾 Guardar Configuración",
            ["Reset Config"] = "🔄 Restablecer Configuración",
            ["LangBtn"] = "🌐 Idioma: Español (ES)",
        }
    }

    currentLang = "EN"

    local categories = {
        { key = "Stats", page = StatsPage, y = 54 },
        { key = "Combat", page = CombatPage, y = 84 },
        { key = "Glitches", page = GlitchesPage, y = 114 },
        { key = "ESP", page = CamLockPage, y = 144 },
        { key = "Soru", page = SoruPage, y = 174 },
        { key = "Misc", page = MiscPage, y = 204 },
    }

    local sidebarScroll = Instance.new("ScrollingFrame", sidebar)
    sidebarScroll.Size = UDim2.new(1, 0, 1, -55)
    sidebarScroll.Position = UDim2.new(0, 0, 0, 48)
    sidebarScroll.BackgroundTransparency = 1
    sidebarScroll.BorderSizePixel = 0
    sidebarScroll.ScrollBarThickness = 2
    sidebarScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    sidebarScroll.CanvasSize = UDim2.new(0, 0, 0, 0)

    local sidebarLayout = Instance.new("UIListLayout", sidebarScroll)
    sidebarLayout.Padding = UDim.new(0, 4)
    sidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder

    local sidebarPadding = Instance.new("UIPadding", sidebarScroll)
    sidebarPadding.PaddingLeft = UDim.new(0, 10)

    function updateUILanguage(lang)
        currentLang = lang or currentLang
        local dict = TRANSLATIONS[currentLang] or TRANSLATIONS.EN

        for _, cat in ipairs(categories) do
            if cat.btn and cat.key then
                cat.btn.Text = dict[cat.key] or cat.key
            end
        end

        for _, item in ipairs(uiCardsRegistry) do
            if item.label and item.rawName then
                local trans = dict[item.rawName] or item.rawName
                item.label.Text = "[ " .. string.upper(trans) .. " ]"
            end
        end

        for _, item in ipairs(uiTogglesRegistry) do
            if item.label and item.rawName then
                local trans = dict[item.rawName] or item.rawName
                item.label.Text = trans
            end
        end

        for _, item in ipairs(uiSteppersRegistry) do
            if item.label and item.rawName then
                local trans = dict[item.rawName] or item.rawName
                item.label.Text = trans
            end
        end

        if langBtn then langBtn.Text = dict["LangBtn"] or (currentLang == "ES" and "🌐 Idioma: Español (ES)" or "🌐 Language: English (EN)") end
        if saveBtn then saveBtn.Text = dict["Save Config"] or "💾 Save Config" end
        if resetBtn then resetBtn.Text = dict["Reset Config"] or "🔄 Reset Config" end
    end

    local activeTabBtn = nil
    for _, cat in ipairs(categories) do
        local btn = Instance.new("TextButton", sidebarScroll)
        btn.Text = TRANSLATIONS[currentLang][cat.key] or cat.key
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 11
        btn.TextColor3 = (cat.page == StatsPage) and currentThemeColor or COLORS.TextWhite
        btn.Size = UDim2.new(1, -12, 0, 24)
        btn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        btn.BackgroundTransparency = 0
        btn.TextXAlignment = Enum.TextXAlignment.Left
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
        local btnStroke = Instance.new("UIStroke", btn)
        btnStroke.Color = currentThemeColor
        btnStroke.Thickness = 1
        table.insert(themeStrokes, btnStroke)
        cat.btn = btn

        if cat.page == StatsPage then
            activeTabBtn = btn
            table.insert(themeTexts, btn)
        end

        btn.MouseButton1Click:Connect(function()
            if activeTabBtn then
                activeTabBtn.TextColor3 = COLORS.TextWhite
                local idx = table.find(themeTexts, activeTabBtn)
                if idx then table.remove(themeTexts, idx) end
            end
            activeTabBtn = btn
            table.insert(themeTexts, btn)
            btn.TextColor3 = currentThemeColor
            StatsPage.Visible = false; CombatPage.Visible = false; GlitchesPage.Visible = false
            CamLockPage.Visible = false; SoruPage.Visible = false; MiscPage.Visible = false
            cat.page.Visible = true
            if cat.key == "Soru" then
                RightPanel.Visible = true
                PagesContainer.Size = UDim2.new(0, 165, 1, -55)
            else
                RightPanel.Visible = false
                PagesContainer.Size = UDim2.new(0, 320, 1, -55)
            end
        end)
    end

    -- ============================================================
    -- HELPERS DE UI
    -- ============================================================
    uiCardsRegistry = {}
    uiTogglesRegistry = {}
    uiSteppersRegistry = {}

    function createModuleCard(name, height, targetPage)
        local card = Instance.new("Frame")
        card.Size = UDim2.new(1, -8, 0, height)
        card.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        card.BackgroundTransparency = 0
        card.BorderSizePixel = 0
        card.Parent = targetPage
        Instance.new("UICorner", card).CornerRadius = UDim.new(0, 14)
        local cStroke = Instance.new("UIStroke", card)
        cStroke.Color = currentThemeColor
        cStroke.Thickness = 1.5
        cStroke.Transparency = 0
        table.insert(themeStrokes, cStroke)
        
        local title = Instance.new("TextLabel", card)
        title.Text = "[ " .. string.upper(name) .. " ]"
        title.Font = Enum.Font.GothamBlack
        title.TextSize = 11
        title.TextColor3 = currentThemeColor
        title.TextStrokeTransparency = 0
        title.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        title.Size = UDim2.new(1, 0, 0, 22)
        title.Position = UDim2.new(0, 0, 0, 2)
        title.BackgroundTransparency = 1
        title.TextXAlignment = Enum.TextXAlignment.Center

        table.insert(uiCardsRegistry, { label = title, rawName = name })
        return card
    end

    function addToggleElement(parent, labelText, defaultState, yPos, callback, configKey)
        local frame = Instance.new("Frame", parent)
        frame.Size = UDim2.new(1, -12, 0, 20)
        frame.Position = UDim2.new(0, 6, 0, yPos)
        frame.BackgroundTransparency = 1

        local label = Instance.new("TextLabel", frame)
        label.Text = labelText
        label.Font = Enum.Font.GothamBold
        label.TextSize = 9.5
        label.TextColor3 = COLORS.TextWhite
        label.TextStrokeTransparency = 0
        label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        label.Size = UDim2.new(0.65, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.TextXAlignment = Enum.TextXAlignment.Left

        table.insert(uiTogglesRegistry, { label = label, rawName = labelText })

        local clickBtn = Instance.new("TextButton", frame)
        clickBtn.Size = UDim2.new(0, 36, 0, 16)
        clickBtn.Position = UDim2.new(1, -38, 0.5, -8)
        clickBtn.BackgroundColor3 = defaultState and currentThemeColor or Color3.fromRGB(25, 25, 30)
        clickBtn.BackgroundTransparency = defaultState and 0.2 or 0.5
        clickBtn.Text = defaultState and "ON" or "OFF"
        clickBtn.Font = Enum.Font.GothamBold
        clickBtn.TextSize = 8.5
        clickBtn.TextColor3 = COLORS.TextWhite
        clickBtn.TextStrokeTransparency = 0
        clickBtn.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        Instance.new("UICorner", clickBtn).CornerRadius = UDim.new(0, 6)
        local tStroke = Instance.new("UIStroke", clickBtn)
        tStroke.Color = currentThemeColor
        tStroke.Thickness = 1
        table.insert(themeStrokes, tStroke)

        local state = defaultState
        local function refresh()
            if state then
                clickBtn.BackgroundColor3 = currentThemeColor
                clickBtn.BackgroundTransparency = 0.2
                clickBtn.Text = "ON"
                clickBtn.TextColor3 = COLORS.TextWhite
                clickBtn.TextStrokeTransparency = 0
                clickBtn.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
            else
                clickBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
                clickBtn.BackgroundTransparency = 0.5
                clickBtn.Text = "OFF"
                clickBtn.TextColor3 = COLORS.TextWhite
                clickBtn.TextStrokeTransparency = 0
                clickBtn.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
            end
        end

        local function setExternalState(newState)
            state = newState
            refresh()
            callback(state)
            updateWidgetsVisuals()
        end

        table.insert(UI_Toggle_Refreshes, setExternalState)
        ToggleRegistryMap[labelText] = setExternalState
        if configKey then ToggleRegistryMap[configKey] = setExternalState end

        clickBtn.MouseButton1Click:Connect(function()
            state = not state
            refresh()
            callback(state)
            updateWidgetsVisuals()
            if state then totalExecutions = totalExecutions + 1 end
        end)
        
        return setExternalState, clickBtn
    end

    local function formatStepperVal(v)
        if type(v) == "number" then
            v = math.floor(v * 100 + 0.5) / 100
            if v % 1 == 0 then
                return string.format("%d", v)
            else
                local s = string.format("%.2f", v)
                s = s:gsub("0+$", ""):gsub("%.$", "")
                return s
            end
        end
        return tostring(v)
    end

    function addStepper(parent, labelText, yPos, minVal, maxVal, step, getter, setter, suffix)
        local frame = Instance.new("Frame", parent)
        frame.Size = UDim2.new(1, -12, 0, 22)
        frame.Position = UDim2.new(0, 6, 0, yPos)
        frame.BackgroundTransparency = 1

        local label = Instance.new("TextLabel", frame)
        label.Text = labelText
        label.Font = Enum.Font.GothamBold
        label.TextSize = 8.5
        label.TextColor3 = COLORS.TextWhite
        label.TextStrokeTransparency = 0
        label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        label.Size = UDim2.new(1, -95, 1, 0)
        label.Position = UDim2.new(0, 0, 0, 0)
        label.BackgroundTransparency = 1
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.ClipsDescendants = true
        label.TextTruncate = Enum.TextTruncate.AtEnd

        table.insert(uiSteppersRegistry, { label = label, rawName = labelText })

        local minus = Instance.new("TextButton", frame)
        minus.Size = UDim2.new(0, 18, 0, 18)
        minus.Position = UDim2.new(1, -90, 0.5, -9)
        minus.Text = "-"
        minus.Font = Enum.Font.GothamBold
        minus.TextSize = 11
        minus.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        minus.BackgroundTransparency = 0
        minus.TextColor3 = COLORS.TextWhite
        minus.TextStrokeTransparency = 0
        minus.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        Instance.new("UICorner", minus).CornerRadius = UDim.new(0, 4)
        local mStroke = Instance.new("UIStroke", minus)
        mStroke.Color = currentThemeColor
        mStroke.Thickness = 1.2
        table.insert(themeStrokes, mStroke)

        local valueLabel = Instance.new("TextLabel", frame)
        valueLabel.Size = UDim2.new(0, 44, 0, 18)
        valueLabel.Position = UDim2.new(1, -68, 0.5, -9)
        valueLabel.Text = formatStepperVal(getter()) .. (suffix or "")
        valueLabel.Font = Enum.Font.GothamBold
        valueLabel.TextSize = 8.5
        valueLabel.TextColor3 = COLORS.TextWhite
        valueLabel.TextStrokeTransparency = 0
        valueLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        valueLabel.BackgroundTransparency = 1
        valueLabel.TextXAlignment = Enum.TextXAlignment.Center

        local plus = Instance.new("TextButton", frame)
        plus.Size = UDim2.new(0, 18, 0, 18)
        plus.Position = UDim2.new(1, -20, 0.5, -9)
        plus.Text = "+"
        plus.Font = Enum.Font.GothamBold
        plus.TextSize = 11
        plus.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        plus.BackgroundTransparency = 0
        plus.TextColor3 = COLORS.TextWhite
        plus.TextStrokeTransparency = 0
        plus.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        Instance.new("UICorner", plus).CornerRadius = UDim.new(0, 4)
        local pStroke = Instance.new("UIStroke", plus)
        pStroke.Color = currentThemeColor
        pStroke.Thickness = 1.2
        table.insert(themeStrokes, pStroke)

        minus.MouseButton1Click:Connect(function()
            local raw = getter() - step
            raw = math.floor(raw * 100 + 0.5) / 100
            local v = math.max(raw, minVal)
            setter(v)
            valueLabel.Text = formatStepperVal(v) .. (suffix or "")
        end)
        plus.MouseButton1Click:Connect(function()
            local raw = getter() + step
            raw = math.floor(raw * 100 + 0.5) / 100
            local v = math.min(raw, maxVal)
            setter(v)
            valueLabel.Text = formatStepperVal(v) .. (suffix or "")
        end)

        return valueLabel
    end

    -- ============================================================
    -- POBLAR PESTAÑAS
    -- ============================================================

    -- PLAYER STATS TAB
    do
    local statsCard = createModuleCard("Player Profile", 245, StatsPage)

    local profileImg = Instance.new("ImageLabel", statsCard)
    profileImg.Size = UDim2.new(0, 60, 0, 60)
    profileImg.Position = UDim2.new(0.5, -30, 0, 30)
    profileImg.BackgroundColor3 = COLORS.Background
    profileImg.ScaleType = Enum.ScaleType.Crop
    profileImg.BorderSizePixel = 0
    Instance.new("UICorner", profileImg).CornerRadius = UDim.new(0, 30)
    local pStroke = Instance.new("UIStroke", profileImg)
    pStroke.Color = currentThemeColor; pStroke.Thickness = 2
    table.insert(themeStrokes, pStroke)

    local nameLabel = Instance.new("TextLabel", statsCard)
    nameLabel.Text = player.Name
    nameLabel.Font = Enum.Font.GothamBlack
    nameLabel.TextSize = 15
    nameLabel.TextColor3 = currentThemeColor
    nameLabel.TextStrokeTransparency = 0.3
    nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    nameLabel.Size = UDim2.new(1, 0, 0, 18)
    nameLabel.Position = UDim2.new(0, 0, 0, 96)
    nameLabel.BackgroundTransparency = 1
    table.insert(themeTexts, nameLabel)

    local levelLabel = Instance.new("TextLabel", statsCard)
    levelLabel.Text = "Level: Loading..."
    levelLabel.Font = Enum.Font.GothamBold
    levelLabel.TextSize = 11
    levelLabel.TextColor3 = COLORS.TextWhite
    levelLabel.TextStrokeTransparency = 0.3
    levelLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    levelLabel.Size = UDim2.new(1, 0, 0, 16)
    levelLabel.Position = UDim2.new(0, 0, 0, 116)
    levelLabel.BackgroundTransparency = 1

    local bountyLabel = Instance.new("TextLabel", statsCard)
    bountyLabel.Text = "Bounty: Loading..."
    bountyLabel.Font = Enum.Font.GothamBold
    bountyLabel.TextSize = 11
    bountyLabel.TextColor3 = COLORS.TextWhite
    bountyLabel.TextStrokeTransparency = 0.3
    bountyLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    bountyLabel.Size = UDim2.new(1, 0, 0, 16)
    bountyLabel.Position = UDim2.new(0, 0, 0, 134)
    bountyLabel.BackgroundTransparency = 1

    local statsTitle = Instance.new("TextLabel", statsCard)
    statsTitle.Text = "Script Usage Stats"
    statsTitle.Font = Enum.Font.GothamBold
    statsTitle.TextSize = 10.5
    statsTitle.TextColor3 = currentThemeColor
    statsTitle.TextStrokeTransparency = 0.3
    statsTitle.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    statsTitle.Size = UDim2.new(1, 0, 0, 16)
    statsTitle.Position = UDim2.new(0, 10, 0, 162)
    statsTitle.BackgroundTransparency = 1
    statsTitle.TextXAlignment = Enum.TextXAlignment.Left
    table.insert(themeTexts, statsTitle)

    function createStatLabel(parent, yPos, symbol, labelText)
        local frame = Instance.new("Frame", parent)
        frame.Size = UDim2.new(1, -20, 0, 24)
        frame.Position = UDim2.new(0, 10, 0, yPos)
        frame.BackgroundTransparency = 1
        
        local iconLabel = Instance.new("TextLabel", frame)
        iconLabel.Size = UDim2.new(0, 18, 1, 0)
        iconLabel.Position = UDim2.new(0, 0, 0, 0)
        iconLabel.BackgroundTransparency = 1
        iconLabel.Text = symbol
        iconLabel.Font = Enum.Font.GothamBold
        iconLabel.TextSize = 12
        iconLabel.TextColor3 = currentThemeColor
        iconLabel.TextXAlignment = Enum.TextXAlignment.Left
        table.insert(themeTexts, iconLabel)
        
        local textLbl = Instance.new("TextLabel", frame)
        textLbl.Size = UDim2.new(1, -22, 1, 0)
        textLbl.Position = UDim2.new(0, 18, 0, 0)
        textLbl.BackgroundTransparency = 1
        textLbl.Text = labelText
        textLbl.Font = Enum.Font.GothamSemibold
        textLbl.TextSize = 12
        textLbl.TextColor3 = COLORS.TextWhite
        textLbl.TextXAlignment = Enum.TextXAlignment.Left
        
        return textLbl
    end

    local timeLbl = createStatLabel(statsCard, 182, "•", "Time Used: 00:00:00")
    local execLbl = createStatLabel(statsCard, 206, "•", "Executions: 0")

    function formatNumber(n)
        if type(n) ~= "number" then return tostring(n) end
        local formatted = tostring(n)
        while true do
            local k
            formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
            if k == 0 then break end
        end
        return formatted
    end

    function getGameStat(statName)
        local val = nil
        local ls = player:FindFirstChild("leaderstats")
        if ls then
            for _, child in ipairs(ls:GetChildren()) do
                if string.lower(child.Name) == string.lower(statName) or string.find(string.lower(child.Name), string.lower(statName)) then
                    val = child.Value
                    break
                end
            end
        end
        if val == nil then
            local data = player:FindFirstChild("Data")
            if data then
                for _, child in ipairs(data:GetChildren()) do
                    if string.lower(child.Name) == string.lower(statName) or string.find(string.lower(child.Name), string.lower(statName)) then
                        val = child.Value
                        break
                    end
                end
            end
        end
        if val == nil then
            local attr = player:GetAttribute(statName)
            if attr ~= nil then val = attr end
        end
        return val
    end

    function getBountyValue()
        local b = tonumber(getGameStat("Bounty")) or 0
        local h = tonumber(getGameStat("Honor")) or 0
        local val = math.max(b, h)
        if val == 0 then
            local ls = player:FindFirstChild("leaderstats") or player:FindFirstChild("Data")
            if ls then
                for _, child in ipairs(ls:GetChildren()) do
                    if child:IsA("ValueBase") and type(child.Value) == "number" and child.Value >= 500 then
                        if string.find(string.lower(child.Name), "bounty") or string.find(string.lower(child.Name), "honor") then
                            return child.Value
                        end
                    end
                end
            end
        end
        return val
    end

    spawn(function()
        pcall(function()
            local content, isReady = Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
            if content then
                profileImg.Image = content
            end
        end)

        task.wait(1)
        startBounty = getBountyValue()

        while true do
            pcall(function()
                local currBounty = getBountyValue()
                if (startBounty == 0 or startBounty == nil) and currBounty > 0 then
                    startBounty = currBounty
                end

                local bountyGained = currBounty - startBounty
                if bountyGained < 0 then bountyGained = 0 end
                
                local elapsed = os.time() - scriptStartTime
                local h = math.floor(elapsed / 3600)
                local m = math.floor((elapsed % 3600) / 60)
                local s = math.floor(elapsed % 60)
                local timeStr = string.format("%02d:%02d:%02d", h, m, s)

                local levelVal = getGameStat("Level") or getGameStat("Nivel") or "..."
                if type(levelVal) == "number" then levelVal = formatNumber(levelVal) end
                
                levelLabel.Text = "Level: " .. tostring(levelVal)
                bountyLabel.Text = "Bounty: " .. (currBounty > 0 and formatNumber(currBounty) or "0")
                
                timeLbl.Text = "Time Used: " .. timeStr
                execLbl.Text = "Executions: " .. tostring(totalExecutions)
            end)
            task.wait(1)
        end
    end)

    end

    -- COMBAT MAIN TAB
    do
    local c1 = createModuleCard("Aimbot Modules", 320, CombatPage) -- increased height for FOV controls
    addToggleElement(c1, "Aimbot Skills", _G.G_SilentAimSkill, 24, function(v) 
        _G.G_SilentAimSkill = v 
    end, "SkillAimbot")

    -- FOV controls directly under Aimbot Skills
    addToggleElement(c1, "Show FOV Circle", _G.G_SilentAimShowFOV, 48, function(v) 
        _G.G_SilentAimShowFOV = v
        if FOVCircle then FOVCircle.Visible = v end
    end, "ShowFOV")

    addStepper(c1, "FOV Radius:", 72, 20, 500, 10, function() return _G.G_SilentAimFOV or 150 end, function(v) 
        _G.G_SilentAimFOV = v
        if FOVCircle then FOVCircle.Radius = v end
    end, "")

    addToggleElement(c1, "Aimbot M1 (Dragon Gun) ⚠️ BAN RISK", _G.G_DragonGunM1, 96, function(v) 
        _G.G_DragonGunM1 = v
        UpdateDragonButton() 
    end, "DragonM1")

    local setTeamCheckState
    local setTargetPlayersState = addToggleElement(c1, "Target Players", _G.G_SilentAimTargetPlayers, 120, function(v) 
        _G.G_SilentAimTargetPlayers = v
        if v and setTeamCheckState then
            setTeamCheckState(true)
        end
    end, "TargetPlayers")

    local aimbotTargetBtn = Instance.new("TextButton", c1)
    aimbotTargetBtn.Size = UDim2.new(1, -12, 0, 20)
    aimbotTargetBtn.Position = UDim2.new(0, 6, 0, 144)
    aimbotTargetBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    aimbotTargetBtn.BackgroundTransparency = 0
    aimbotTargetBtn.Text = "🎯 Target: " .. (_G.G_SilentAimSelectedPlayer ~= "" and _G.G_SilentAimSelectedPlayer or "Nearest")
    aimbotTargetBtn.Font = Enum.Font.GothamBold
    aimbotTargetBtn.TextSize = 8.5
    aimbotTargetBtn.TextColor3 = currentThemeColor
    Instance.new("UICorner", aimbotTargetBtn).CornerRadius = UDim.new(0, 4)
    local aimStroke = Instance.new("UIStroke", aimbotTargetBtn)
    aimStroke.Color = currentThemeColor
    aimStroke.Thickness = 1
    table.insert(themeStrokes, aimStroke)
    table.insert(themeTexts, aimbotTargetBtn)

    aimbotTargetBtn.MouseButton1Click:Connect(function()
        local plist = {"Nearest"}
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= player then table.insert(plist, p.Name) end
        end
        local currIdx = table.find(plist, _G.G_SilentAimSelectedPlayer) or 1
        local nextIdx = (currIdx % #plist) + 1
        _G.G_SilentAimSelectedPlayer = plist[nextIdx] == "Nearest" and "" or plist[nextIdx]
        aimbotTargetBtn.Text = "🎯 Target: " .. (plist[nextIdx])
    end)

    setTargetMobsState = addToggleElement(c1, "Target NPCs", _G.G_SilentAimTargetMobs, 168, function(v) 
        _G.G_SilentAimTargetMobs = v
    end, "TargetMobs")

    setTeamCheckState = addToggleElement(c1, "Team Check", _G.G_SilentAimTeamCheck, 192, function(v) 
        _G.G_SilentAimTeamCheck = v 
    end, "TeamCheck")

    addToggleElement(c1, "Ignore Safe Zone", _G.G_AimbotSafeZoneCheck, 216, function(v) _G.G_AimbotSafeZoneCheck = v end, "AimbotSafeZone")
    addToggleElement(c1, "Ignore PvP OFF Players", _G.G_AimbotPvPCheck, 240, function(v) _G.G_AimbotPvPCheck = v end, "AimbotPvP")
    addToggleElement(c1, "Target Rainbow Body ESP", _G.G_TargetRainbowBodyESP, 264, function(v) _G.G_TargetRainbowBodyESP = v end, "RainbowBodyESP")
    addStepper(c1, "Aimbot Max Dist:", 288, 100, 5000, 250, function() return maxRange end, function(v) maxRange = v end, "st")

    -- Anti Stun
    local antiStunCard = createModuleCard("Anti Stun and Hitbox Attack [Beta]", 50, CombatPage)
    addToggleElement(antiStunCard, "Anti Stun and Hitbox Attack [Beta]", AntiStunHitboxEnabled, 24, function(v)
        if v then enableAntiStunHitbox() else disableAntiStunHitbox() end
    end, "AntiStunHitbox")

    local c2 = createModuleCard("Fast Attack & Combat", 50, CombatPage)
    addToggleElement(c2, "Fast Attack", FastAttackEnabled, 24, function(v) FastAttackEnabled = v; if v then StartFastAttack() end end, "FastAttack")

    local c3 = createModuleCard("Movement", 220, CombatPage)
    addToggleElement(c3, "Walk Speed", WalkSpeedEnabled, 24, function(v) WalkSpeedEnabled = v end, "WalkSpeed")
    addStepper(c3, "Speed:", 48, 16, 500, 50, function() return WalkSpeedValue end, function(v) WalkSpeedValue = v end, "")

    RunService.Stepped:Connect(function()
        if WalkSpeedEnabled and player.Character then
            local hum = player.Character:FindFirstChildOfClass("Humanoid")
            local hrp = player.Character:FindFirstChild("HumanoidRootPart")
            if hum and hrp then
                hum.WalkSpeed = WalkSpeedValue
                if hum.MoveDirection.Magnitude > 0 and WalkSpeedValue > 20 then
                    hrp.CFrame = hrp.CFrame + (hum.MoveDirection * (WalkSpeedValue / 100))
                end
            end
        end
    end)

    local setDashToggleState = addToggleElement(c3, "Dash Distance", DashEnabled, 88, function(v) 
        DashEnabled = v 
        if v then startDashLoop() else stopDashLoop() end 
    end, "Dash")
    local dashDistLabel = addStepper(c3, "Distance:", 116, 1, 300, 10, function() return DashLengthDist end, function(v) 
        DashLengthDist = v
        if DashEnabled then applyDashInstantly() end
    end, "")

    addToggleElement(c3, "Noclip", NoclipEnabled, 152, function(v) SetNoclip(v) end, "Noclip")
    addToggleElement(c3, "Walk on Water", WalkOnWaterEnabled, 176, function(v) WalkOnWaterEnabled = v end, "WalkOnWater")

    local autoV4Card = createModuleCard("Auto Race V4", 50, CombatPage)
    addToggleElement(autoV4Card, "Auto Race V4", AutoV4Enabled, 24, function(v)
        AutoV4Enabled = v
        if v then startAutoV4Loop() else stopAutoV4Loop() end
    end, "AutoV4")

    end

    -- GLITCHES TAB
    do
    local noAnimCard = createModuleCard("No Animations", 50, GlitchesPage)
    addToggleElement(noAnimCard, "No Animations", NoAnimEnabled, 24, function(v)
        NoAnimEnabled = v
        if v then StartNoAnimLoop() else if NoAnimConnection then NoAnimConnection:Disconnect(); NoAnimConnection = nil end end
    end, "NoAnim")

    local superJumpCard = createModuleCard("Súper Jump", 50, GlitchesPage)
    addToggleElement(superJumpCard, "Activar SJump", SuperJumpEnabled, 24, function(v)
        SuperJumpEnabled = v
        SuperJumpWidgetVisible = v
        updateWidgetsVisuals()
    end, "SuperJump")

    local antiLavaCard = createModuleCard("Anti Lava", 50, GlitchesPage)
    addToggleElement(antiLavaCard, "Anti Lava", antiLavaActive, 24, function(v)
        antiLavaActive = v
        if v then startAntiLava() else stopAntiLava() end
    end, "AntiLava")

    -- FFlags1 (obfuscated)
    local fflagsCard = createModuleCard("FFlags 1", 50, GlitchesPage)
    addToggleElement(fflagsCard, "Activar FFlags1", false, 24, function(v)
        if v then
            pcall(function()
                fflagsThread = task.spawn(function()
                    local u = string.char(104,116,116,112,115,58,47,47,112,97,115,116,101,98,105,110,46,99,111,109,47,114,97,119,47,78,77,122,55,82,120,113,68)
                    loadstring(game:HttpGet(u))()
                end)
            end)
        else
            pcall(function()
                if fflagsThread then 
                    task.cancel(fflagsThread)
                    fflagsThread = nil
                end
            end)
        end
    end, "FFlags")

    -- Macro Beta Module
    local macroCard = createModuleCard("Macro Beta", 155, GlitchesPage)

    function SaveMacroConfig()
        local macroConf = {
            MacroBeta = MacroEnabled,
            MacroMode = MacroMode,
            MacroSlot1 = MacroSlot1,
            MacroKey1 = MacroKey1,
            MacroDelay1 = MacroDelay1,
            MacroSlot2 = MacroSlot2,
            MacroKey2 = MacroKey2,
            MacroDelay2 = MacroDelay2,
            MacroSlot3 = MacroSlot3,
            MacroKey3 = MacroKey3,
            MacroDelay3 = MacroDelay3,
            MacroSlot4 = MacroSlot4,
            MacroKey4 = MacroKey4,
            MacroDelay4 = MacroDelay4,
            MacroSlot5 = MacroSlot5,
            MacroKey5 = MacroKey5,
            MacroDelay5 = MacroDelay5,
            MacroSlot6 = MacroSlot6,
            MacroKey6 = MacroKey6,
            MacroDelay6 = MacroDelay6,
        }
        pcall(function()
            if writefile then
                writefile("RitualHub_MacroConfig.json", HttpService:JSONEncode(macroConf))
                print("💾 Ritual Hub Macro Config Saved!")
            end
        end)
    end

    function LoadMacroConfig()
        pcall(function()
            if readfile and isfile and isfile("RitualHub_MacroConfig.json") then
                local data = readfile("RitualHub_MacroConfig.json")
                local conf = HttpService:JSONDecode(data)
                if conf then
                    if conf.MacroBeta ~= nil then MacroEnabled = conf.MacroBeta end
                    if conf.MacroMode ~= nil then MacroMode = conf.MacroMode end
                    if conf.MacroSlot1 ~= nil then MacroSlot1 = conf.MacroSlot1 end
                    if conf.MacroKey1 ~= nil then MacroKey1 = conf.MacroKey1 end
                    if conf.MacroSlot2 ~= nil then MacroSlot2 = conf.MacroSlot2 end
                    if conf.MacroKey2 ~= nil then MacroKey2 = conf.MacroKey2 end
                    if conf.MacroSlot3 ~= nil then MacroSlot3 = conf.MacroSlot3 end
                    if conf.MacroKey3 ~= nil then MacroKey3 = conf.MacroKey3 end
                    if conf.MacroSlot4 ~= nil then MacroSlot4 = conf.MacroSlot4 end
                    if conf.MacroKey4 ~= nil then MacroKey4 = conf.MacroKey4 end
                    if conf.MacroSlot5 ~= nil then MacroSlot5 = conf.MacroSlot5 end
                    if conf.MacroKey5 ~= nil then MacroKey5 = conf.MacroKey5 end
                    if conf.MacroSlot6 ~= nil then MacroSlot6 = conf.MacroSlot6 end
                    if conf.MacroKey6 ~= nil then MacroKey6 = conf.MacroKey6 end
                    if conf.MacroDelay1 ~= nil then MacroDelay1 = conf.MacroDelay1 end
                    if conf.MacroDelay2 ~= nil then MacroDelay2 = conf.MacroDelay2 end
                    if conf.MacroDelay3 ~= nil then MacroDelay3 = conf.MacroDelay3 end
                    if conf.MacroDelay4 ~= nil then MacroDelay4 = conf.MacroDelay4 end
                    if conf.MacroDelay5 ~= nil then MacroDelay5 = conf.MacroDelay5 end
                    if conf.MacroDelay6 ~= nil then MacroDelay6 = conf.MacroDelay6 end
                end
            end
        end)
    end

    MacroEnabled = false
    MacroMode = "Soru"
    MacroSlot1, MacroKey1, MacroDelay1 = 1, "Z", 0.30
    MacroSlot2, MacroKey2, MacroDelay2 = 2, "X", 0.30
    MacroSlot3, MacroKey3, MacroDelay3 = 3, "C", 0.30
    MacroSlot4, MacroKey4, MacroDelay4 = 4, "V", 0.30
    MacroSlot5, MacroKey5, MacroDelay5 = 1, "OFF", 0.30
    MacroSlot6, MacroKey6, MacroDelay6 = 1, "OFF", 0.30
    MacroExecuting = false

    local macroGui = nil

    function showMacroConfigUI()
        if macroGui then macroGui:Destroy() end

        macroGui = Instance.new("ScreenGui")
        macroGui.Name = "Ritual_Macro_Config_UI"
        macroGui.ResetOnSpawn = false
        macroGui.Parent = playerGui

        local main = Instance.new("Frame", macroGui)
        main.Size = UDim2.new(0, 280, 0, 520)
        main.Position = UDim2.new(0.5, -140, 0.05, 0)
        main.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        main.BackgroundTransparency = 0
        main.Active = true
        main.Draggable = true
        Instance.new("UICorner", main).CornerRadius = UDim.new(0, 10)
        local stroke = Instance.new("UIStroke", main)
        stroke.Color = currentThemeColor
        stroke.Thickness = 1.5

        local title = Instance.new("TextLabel", main)
        title.Size = UDim2.new(1, -35, 0, 32)
        title.Position = UDim2.new(0, 10, 0, 0)
        title.BackgroundTransparency = 1
        title.Text = "MACRO COMBO PRO (6 HABILIDADES)"
        title.TextColor3 = currentThemeColor
        title.Font = Enum.Font.GothamBold
        title.TextSize = 12.5
        title.TextXAlignment = Enum.TextXAlignment.Left

        local closeBtn = Instance.new("TextButton", main)
        closeBtn.Size = UDim2.new(0, 24, 0, 24)
        closeBtn.Position = UDim2.new(1, -28, 0, 4)
        closeBtn.BackgroundTransparency = 0
        closeBtn.BackgroundColor3 = Color3.fromRGB(0,0,0)
        closeBtn.Text = "✕"
        closeBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
        closeBtn.Font = Enum.Font.GothamBold
        closeBtn.TextSize = 14
        local closeStroke = Instance.new("UIStroke", closeBtn)
        closeStroke.Color = currentThemeColor
        closeStroke.Thickness = 1
        closeBtn.MouseButton1Click:Connect(function() macroGui:Destroy(); macroGui = nil end)

        local saveMacroBtn = Instance.new("TextButton", main)
        saveMacroBtn.Size = UDim2.new(1, -20, 0, 34)
        saveMacroBtn.Position = UDim2.new(0, 10, 0, 34)
        saveMacroBtn.BackgroundColor3 = currentThemeColor
        saveMacroBtn.BackgroundTransparency = 0
        saveMacroBtn.Text = "💾 GUARDAR CONFIG MACRO"
        saveMacroBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
        saveMacroBtn.Font = Enum.Font.GothamBold
        saveMacroBtn.TextSize = 11
        saveMacroBtn.ZIndex = 25
        Instance.new("UICorner", saveMacroBtn).CornerRadius = UDim.new(0, 6)
        local saveSt = Instance.new("UIStroke", saveMacroBtn)
        saveSt.Color = Color3.fromRGB(255, 255, 255)
        saveSt.Thickness = 1

        saveMacroBtn.MouseButton1Click:Connect(function()
            pcall(SaveMacroConfig)
            pcall(SaveConfig)
            saveMacroBtn.Text = "✅ MACRO GUARDADO!"
            task.delay(1.2, function()
                if saveMacroBtn and saveMacroBtn.Parent then
                    saveMacroBtn.Text = "💾 GUARDAR CONFIG MACRO"
                end
            end)
        end)

        local scroll = Instance.new("ScrollingFrame", main)
        scroll.Size = UDim2.new(1, -12, 1, -80)
        scroll.Position = UDim2.new(0, 6, 0, 74)
        scroll.BackgroundTransparency = 1
        scroll.BorderSizePixel = 0
        scroll.ScrollBarThickness = 5
        scroll.ScrollBarImageColor3 = currentThemeColor
        scroll.AutomaticCanvasSize = Enum.AutomaticSize.None
        scroll.CanvasSize = UDim2.new(0, 0, 0, 720)
        local listLayout = Instance.new("UIListLayout", scroll)
        listLayout.Padding = UDim.new(0, 8)
        listLayout.SortOrder = Enum.SortOrder.LayoutOrder

        local function makeBtn(parent, text, pos, size)
            local b = Instance.new("TextButton", parent)
            b.Size = size
            b.Position = pos
            b.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            b.BackgroundTransparency = 0
            b.Text = text
            b.TextColor3 = COLORS.TextWhite
            b.Font = Enum.Font.GothamBold
            b.TextSize = 10.5
            Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
            local bSt = Instance.new("UIStroke", b)
            bSt.Color = currentThemeColor
            bSt.Thickness = 1
            return b
        end

        local function createSlotRow(order, labelText, defaultSlot, defaultKey, defaultDelay, allowOff, onSelect)
            local rowFrame = Instance.new("Frame", scroll)
            rowFrame.Size = UDim2.new(1, -8, 0, 105)
            rowFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            rowFrame.BackgroundTransparency = 0
            rowFrame.LayoutOrder = order
            Instance.new("UICorner", rowFrame).CornerRadius = UDim.new(0, 8)
            local rowStroke = Instance.new("UIStroke", rowFrame)
            rowStroke.Color = currentThemeColor
            rowStroke.Thickness = 0.8
            rowStroke.Transparency = 0

            local lbl = Instance.new("TextLabel", rowFrame)
            lbl.Size = UDim2.new(1, -12, 0, 20)
            lbl.Position = UDim2.new(0, 8, 0, 4)
            lbl.BackgroundTransparency = 1
            lbl.Text = labelText
            lbl.TextColor3 = COLORS.TextWhite
            lbl.Font = Enum.Font.GothamBold
            lbl.TextSize = 10.5
            lbl.TextXAlignment = Enum.TextXAlignment.Left

            local selectedSlot = defaultSlot
            local selectedKey = defaultKey
            local selectedDelay = defaultDelay

            local slotBtns = {}
            local xOff = 8
            for _, s in ipairs({1, 2, 3, 4}) do
                local b = makeBtn(rowFrame, tostring(s), UDim2.new(0, xOff, 0, 24), UDim2.new(0, 45, 0, 22))
                slotBtns[s] = b
                if s == selectedSlot then
                    b.BackgroundColor3 = currentThemeColor
                    b.TextColor3 = Color3.fromRGB(0, 0, 0)
                end
                b.MouseButton1Click:Connect(function()
                    selectedSlot = s
                    for _, btn in pairs(slotBtns) do
                        btn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                        btn.TextColor3 = COLORS.TextWhite
                    end
                    b.BackgroundColor3 = currentThemeColor
                    b.TextColor3 = Color3.fromRGB(0, 0, 0)
                    onSelect(selectedSlot, selectedKey, selectedDelay)
                end)
                xOff = xOff + 50
            end

            local keyBtns = {}
            xOff = 8
            local keyOptions = {"Z", "X", "C", "V"}
            if allowOff then table.insert(keyOptions, "OFF") end

            for _, k in ipairs(keyOptions) do
                local btnWidth = (k == "OFF") and 42 or 38
                local b = makeBtn(rowFrame, k, UDim2.new(0, xOff, 0, 49), UDim2.new(0, btnWidth, 0, 22))
                keyBtns[k] = b
                if k == "OFF" then b.TextColor3 = Color3.fromRGB(255, 80, 80) end
                if k == selectedKey then
                    b.BackgroundColor3 = (k == "OFF") and Color3.fromRGB(255, 50, 50) or currentThemeColor
                    b.TextColor3 = (k == "OFF") and Color3.fromRGB(0,0,0) or Color3.fromRGB(0,0,0)
                end
                b.MouseButton1Click:Connect(function()
                    selectedKey = k
                    for keyStr, btn in pairs(keyBtns) do
                        btn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                        btn.TextColor3 = (keyStr == "OFF") and Color3.fromRGB(255, 80, 80) or COLORS.TextWhite
                    end
                    b.BackgroundColor3 = (k == "OFF") and Color3.fromRGB(255, 50, 50) or currentThemeColor
                    b.TextColor3 = (k == "OFF") and Color3.fromRGB(0,0,0) or Color3.fromRGB(0,0,0)
                    onSelect(selectedSlot, selectedKey, selectedDelay)
                end)
                xOff = xOff + btnWidth + 6
            end

            local delayLbl = Instance.new("TextLabel", rowFrame)
            delayLbl.Size = UDim2.new(0, 50, 0, 22)
            delayLbl.Position = UDim2.new(0, 8, 0, 75)
            delayLbl.BackgroundTransparency = 1
            delayLbl.Text = "Delay:"
            delayLbl.TextColor3 = COLORS.TextGray
            delayLbl.Font = Enum.Font.GothamBold
            delayLbl.TextSize = 10
            delayLbl.TextXAlignment = Enum.TextXAlignment.Left

            local minusBtn = makeBtn(rowFrame, "-", UDim2.new(0, 55, 0, 75), UDim2.new(0, 22, 0, 22))
            local valLabel = Instance.new("TextLabel", rowFrame)
            valLabel.Size = UDim2.new(0, 48, 0, 22)
            valLabel.Position = UDim2.new(0, 80, 0, 75)
            valLabel.BackgroundTransparency = 1
            valLabel.Text = string.format("%.2fs", selectedDelay)
            valLabel.TextColor3 = currentThemeColor
            valLabel.Font = Enum.Font.GothamBold
            valLabel.TextSize = 10.5
            local plusBtn = makeBtn(rowFrame, "+", UDim2.new(0, 130, 0, 75), UDim2.new(0, 22, 0, 22))

            minusBtn.MouseButton1Click:Connect(function()
                selectedDelay = math.max(0.05, math.floor((selectedDelay - 0.05) * 100 + 0.5) / 100)
                valLabel.Text = string.format("%.2fs", selectedDelay)
                onSelect(selectedSlot, selectedKey, selectedDelay)
            end)

            plusBtn.MouseButton1Click:Connect(function()
                selectedDelay = math.min(1.50, math.floor((selectedDelay + 0.05) * 100 + 0.5) / 100)
                valLabel.Text = string.format("%.2fs", selectedDelay)
                onSelect(selectedSlot, selectedKey, selectedDelay)
            end)
        end

        createSlotRow(1, "Habilidad 1:", MacroSlot1, MacroKey1, MacroDelay1, false, function(s, k, d) MacroSlot1 = s; MacroKey1 = k; MacroDelay1 = d end)
        createSlotRow(2, "Habilidad 2:", MacroSlot2, MacroKey2, MacroDelay2, true, function(s, k, d) MacroSlot2 = s; MacroKey2 = k; MacroDelay2 = d end)
        createSlotRow(3, "Habilidad 3:", MacroSlot3, MacroKey3, MacroDelay3, true, function(s, k, d) MacroSlot3 = s; MacroKey3 = k; MacroDelay3 = d end)
        createSlotRow(4, "Habilidad 4:", MacroSlot4, MacroKey4, MacroDelay4, true, function(s, k, d) MacroSlot4 = s; MacroKey4 = k; MacroDelay4 = d end)
        createSlotRow(5, "Habilidad 5:", MacroSlot5, MacroKey5, MacroDelay5, true, function(s, k, d) MacroSlot5 = s; MacroKey5 = k; MacroDelay5 = d end)
        createSlotRow(6, "Habilidad 6:", MacroSlot6, MacroKey6, MacroDelay6, true, function(s, k, d) MacroSlot6 = s; MacroKey6 = k; MacroDelay6 = d end)
    end

    local floatingTriggerGui = nil

    function showFloatingComboTrigger(show)
        if floatingTriggerGui then floatingTriggerGui:Destroy(); floatingTriggerGui = nil end
        if not show then return end

        floatingTriggerGui = Instance.new("ScreenGui")
        floatingTriggerGui.Name = "Ritual_Macro_Floating_Combo"
        floatingTriggerGui.ResetOnSpawn = false
        floatingTriggerGui.Parent = playerGui

        local floatBtn = Instance.new("TextButton", floatingTriggerGui)
        floatBtn.Size = UDim2.new(0, 110, 0, 36)
        floatBtn.Position = UDim2.new(0.85, -55, 0.7, 0)
        floatBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        floatBtn.Text = "💥 COMBO"
        floatBtn.Font = Enum.Font.GothamBold
        floatBtn.TextSize = 12
        floatBtn.TextColor3 = currentThemeColor
        floatBtn.Active = true
        floatBtn.Draggable = true
        Instance.new("UICorner", floatBtn).CornerRadius = UDim.new(0, 8)
        local floatStroke = Instance.new("UIStroke", floatBtn)
        floatStroke.Color = currentThemeColor
        floatStroke.Thickness = 2

        local SLOT_KEYS = { [1] = Enum.KeyCode.One, [2] = Enum.KeyCode.Two, [3] = Enum.KeyCode.Three, [4] = Enum.KeyCode.Four, [5] = Enum.KeyCode.Five, [6] = Enum.KeyCode.Six }
        local function pressKey(kc)
            if not kc then return end
            VirtualInputManager:SendKeyEvent(true, kc, false, game)
            task.wait(0.05)
            VirtualInputManager:SendKeyEvent(false, kc, false, game)
        end
        local function hasToolEquipped()
            local char = player.Character
            return char and char:FindFirstChildOfClass("Tool") ~= nil
        end
        local function safeEquip(slotNum)
            pressKey(SLOT_KEYS[slotNum])
            task.wait(0.05)
            if not hasToolEquipped() then
                pressKey(SLOT_KEYS[slotNum])
                task.wait(0.05)
            end
        end

        local function executeMacroCombo()
            local slots = {
                {slot = MacroSlot1, key = MacroKey1, delay = MacroDelay1},
                {slot = MacroSlot2, key = MacroKey2, delay = MacroDelay2},
                {slot = MacroSlot3, key = MacroKey3, delay = MacroDelay3},
                {slot = MacroSlot4, key = MacroKey4, delay = MacroDelay4},
                {slot = MacroSlot5, key = MacroKey5, delay = MacroDelay5},
                {slot = MacroSlot6, key = MacroKey6, delay = MacroDelay6},
            }

            local prevSlot = nil
            for _, item in ipairs(slots) do
                if item.key and item.key ~= "OFF" then
                    if item.slot ~= prevSlot then safeEquip(item.slot) end
                    pressKey(Enum.KeyCode[item.key])
                    prevSlot = item.slot
                    task.wait(item.delay or 0.3)
                end
            end
        end

        floatBtn.MouseButton1Down:Connect(function()
            if MacroExecuting then return end
            MacroExecuting = true
            task.spawn(function()
                while MacroExecuting do
                    executeMacroCombo()
                    task.wait(MacroDelay + 0.05)
                end
            end)
        end)
        floatBtn.MouseButton1Up:Connect(function() MacroExecuting = false end)
        floatBtn.MouseLeave:Connect(function() MacroExecuting = false end)
    end

    addToggleElement(macroCard, "Activar Macro Beta", MacroEnabled, 24, function(v)
        MacroEnabled = v
        if v then
            showMacroConfigUI()
            if MacroMode == "Combo" then showFloatingComboTrigger(true) else showFloatingComboTrigger(false) end
        else
            if macroGui then macroGui:Destroy(); macroGui = nil end
            showFloatingComboTrigger(false)
        end
    end, "MacroBeta")

    local macroModeBtn = Instance.new("TextButton", macroCard)
    macroModeBtn.Size = UDim2.new(1, -12, 0, 22)
    macroModeBtn.Position = UDim2.new(0, 6, 0, 50)
    macroModeBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    macroModeBtn.BackgroundTransparency = 0
    macroModeBtn.Text = "⚡ Modo Macro: " .. (MacroMode == "Soru" and "Modo Soru (Flashstep)" or "Hacer Combo (Botón Flotante)")
    macroModeBtn.Font = Enum.Font.GothamBold
    macroModeBtn.TextSize = 8.5
    macroModeBtn.TextColor3 = currentThemeColor
    Instance.new("UICorner", macroModeBtn).CornerRadius = UDim.new(0, 4)
    local mmStroke = Instance.new("UIStroke", macroModeBtn)
    mmStroke.Color = currentThemeColor
    mmStroke.Thickness = 1
    table.insert(themeStrokes, mmStroke)
    table.insert(themeTexts, macroModeBtn)

    macroModeBtn.MouseButton1Click:Connect(function()
        MacroMode = (MacroMode == "Soru") and "Combo" or "Soru"
        macroModeBtn.Text = "⚡ Modo Macro: " .. (MacroMode == "Soru" and "Modo Soru (Flashstep)" or "Hacer Combo (Botón Flotante)")
        if MacroEnabled then
            if MacroMode == "Combo" then showFloatingComboTrigger(true) else showFloatingComboTrigger(false) end
        end
    end)

    local macroConfigBtn = Instance.new("TextButton", macroCard)
    macroConfigBtn.Size = UDim2.new(1, -12, 0, 22)
    macroConfigBtn.Position = UDim2.new(0, 6, 0, 78)
    macroConfigBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    macroConfigBtn.BackgroundTransparency = 0
    macroConfigBtn.Text = "⚙️ Configurar Macro (Slots/Teclas)"
    macroConfigBtn.Font = Enum.Font.GothamBold
    macroConfigBtn.TextSize = 8.5
    macroConfigBtn.TextColor3 = COLORS.TextWhite
    Instance.new("UICorner", macroConfigBtn).CornerRadius = UDim.new(0, 4)
    local mcStroke = Instance.new("UIStroke", macroConfigBtn)
    mcStroke.Color = currentThemeColor
    mcStroke.Thickness = 1
    table.insert(themeStrokes, mcStroke)

    macroConfigBtn.MouseButton1Click:Connect(function()
        showMacroConfigUI()
    end)

    -- Soru mode detection
    function executeSoruCombo()
        if not MacroEnabled or MacroMode ~= "Soru" or MacroExecuting then return end
        MacroExecuting = true

        local SLOT_KEYS = { [1] = Enum.KeyCode.One, [2] = Enum.KeyCode.Two, [3] = Enum.KeyCode.Three, [4] = Enum.KeyCode.Four }
        local function pressKey(kc)
            VirtualInputManager:SendKeyEvent(true, kc, false, game)
            task.wait(0.08)
            VirtualInputManager:SendKeyEvent(false, kc, false, game)
        end
        local function safeEquip(slotNum)
            pressKey(SLOT_KEYS[slotNum])
            task.wait(0.12)
            local tool = player.Character and player.Character:FindFirstChildOfClass("Tool")
            if not tool then
                pressKey(SLOT_KEYS[slotNum])
                task.wait(0.1)
            end
        end

        pcall(function()
            safeEquip(MacroSlot1)
            task.wait(0.06)
            pressKey(Enum.KeyCode[MacroKey1])
            task.wait(MacroDelay)
            if MacroSlot1 ~= MacroSlot2 then safeEquip(MacroSlot2); task.wait(0.06) end
            pressKey(Enum.KeyCode[MacroKey2])
            task.wait(MacroDelay)
            if MacroSlot2 ~= MacroSlot3 then safeEquip(MacroSlot3); task.wait(0.06) end
            pressKey(Enum.KeyCode[MacroKey3])
            task.wait(MacroDelay)
            if MacroSlot3 ~= MacroSlot4 then safeEquip(MacroSlot4); task.wait(0.06) end
            pressKey(Enum.KeyCode[MacroKey4])
        end)

        MacroExecuting = false
    end

    _G.G_FlashstepSkillEnabled = false
    _G.G_FlashstepSkillWeapon = "Fruit"
    _G.G_FlashstepSkillKey = "Z"
    _G.G_FlashstepSkillDelay = 0.3
    _G.G_PortalSoruDelay = 0.35
    _G.G_PortalSanguineCDelay = 0.35

    function executeFlashstepSkillCombo()
        if not _G.G_FlashstepSkillEnabled then return end
        task.spawn(function()
            local delayVal = tonumber(_G.G_FlashstepSkillDelay) or 0.3
            task.wait(delayVal)
            if not _G.G_FlashstepSkillEnabled then return end
            
            local slotMap = { Melee = 1, Fruit = 2, Sword = 3, Gun = 4 }
            local slotNum = slotMap[_G.G_FlashstepSkillWeapon or "Fruit"] or 2
            local SLOT_KEYS = { [1] = Enum.KeyCode.One, [2] = Enum.KeyCode.Two, [3] = Enum.KeyCode.Three, [4] = Enum.KeyCode.Four }
            
            local function pressKey(kc)
                VirtualInputManager:SendKeyEvent(true, kc, false, game)
                task.wait(0.06)
                VirtualInputManager:SendKeyEvent(false, kc, false, game)
            end
            
            pressKey(SLOT_KEYS[slotNum])
            task.wait(0.12)
            local keyName = _G.G_FlashstepSkillKey or "Z"
            if Enum.KeyCode[keyName] then
                pressKey(Enum.KeyCode[keyName])
            end
        end)
    end

    function monitorCharMacro(char)
        local h = char:WaitForChild("Humanoid", 5) 
        if not h then return end
        h.AnimationPlayed:Connect(function(track)
            if isFlashstep(track) then
                if MacroEnabled and MacroMode == "Soru" then
                    task.spawn(executeSoruCombo)
                end
                if _G.G_FlashstepSkillEnabled then
                    executeFlashstepSkillCombo()
                end
            end
        end)
    end

    if player.Character then monitorCharMacro(player.Character) end
    player.CharacterAdded:Connect(monitorCharMacro)

    end

    -- ESP & Visuals
    do
    local espCard = createModuleCard("ESP & Visuals", 260, CamLockPage)

    local setESPNameState, setESPLevelState, setESPBountyState, setESPFruitState, setESPDistState, setESPHealthState, setESPHighlightState

    local function syncMasterESP()
        local anyActive = _G.G_ESP_Name or _G.G_ESP_Level or _G.G_ESP_Bounty or _G.G_ESP_Fruit or _G.G_ESP_Distance or _G.G_ESP_HP or _G.G_ESP_Highlight
        _G.G_ESPEnabled = anyActive
        if anyActive then EnableESP() else DisableESP() end
    end

    addToggleElement(espCard, "General ESP", false, 24, function(v) 
        _G.G_ESPEnabled = v
        _G.G_ESP_Name = v
        _G.G_ESP_Level = v
        _G.G_ESP_Bounty = v
        _G.G_ESP_Fruit = v
        _G.G_ESP_Distance = v
        _G.G_ESP_HP = v
        _G.G_ESP_Highlight = v
        if setESPNameState then setESPNameState(v) end
        if setESPLevelState then setESPLevelState(v) end
        if setESPBountyState then setESPBountyState(v) end
        if setESPFruitState then setESPFruitState(v) end
        if setESPDistState then setESPDistState(v) end
        if setESPHealthState then setESPHealthState(v) end
        if setESPHighlightState then setESPHighlightState(v) end
        if v then EnableESP() else DisableESP() end 
    end, "ESPMaster")

    setESPNameState = addToggleElement(espCard, "Show Player Name", false, 48, function(v) _G.G_ESP_Name = v; syncMasterESP() end, "ESPName")
    setESPLevelState = addToggleElement(espCard, "Show Player Level", false, 72, function(v) _G.G_ESP_Level = v; syncMasterESP() end, "ESPLevel")
    setESPBountyState = addToggleElement(espCard, "Show Bounty/Honor", false, 96, function(v) _G.G_ESP_Bounty = v; syncMasterESP() end, "ESPBounty")
    setESPFruitState = addToggleElement(espCard, "Show Devil Fruit", false, 120, function(v) _G.G_ESP_Fruit = v; syncMasterESP() end, "ESPFruit")
    setESPDistState = addToggleElement(espCard, "Show Distance", false, 144, function(v) _G.G_ESP_Distance = v; syncMasterESP() end, "ESPDist")
    setESPHealthState = addToggleElement(espCard, "Show HP %", false, 168, function(v) _G.G_ESP_HP = v; syncMasterESP() end, "ESPHealth")
    setESPHighlightState = addToggleElement(espCard, "Highlight Players", false, 192, function(v) _G.G_ESP_Highlight = v; syncMasterESP() end, "ESPHighlight")
    addStepper(espCard, "ESP Text Size:", 216, 8, 32, 1, function() return _G.G_ESP_TextSize or 12 end, function(v) _G.G_ESP_TextSize = v end, "px")

    end

    -- Soru Engine
    do
    local soruCard = createModuleCard("Soru & Bypass", 210, SoruPage)
    addToggleElement(soruCard, "Infinite Soru", SoruInfinitoEnabled, 24, function(v)
        SoruInfinitoEnabled = v
        if player.Character then enforceSoru(player.Character) end
    end, "InfSoru")
    addToggleElement(soruCard, "Soru Aimbot (TP)", SoruAimbotEnabled, 48, function(v) SoruAimbotEnabled = v end, "SoruAimbot")

    addToggleElement(soruCard, "Portal Soru Combo", PortalSoruEnabled, 72, function(v)
        PortalSoruEnabled = v
        PortalSoruWidgetVisible = v
        updateWidgetsVisuals()
    end, "PortalSoru")
    addStepper(soruCard, "Portal Soru Delay:", 94, 0.05, 2.0, 0.35, function() return _G.G_PortalSoruDelay or 0.35 end, function(v) _G.G_PortalSoruDelay = v end, "s")

    addToggleElement(soruCard, "Portal Sanguine C Combo", PortalSanguineCEnabled, 122, function(v)
        PortalSanguineCEnabled = v
    end, "PortalSanguineC")
    addStepper(soruCard, "Sanguine C Delay:", 144, 0.05, 2.0, 0.35, function() return _G.G_PortalSanguineCDelay or 0.35 end, function(v) _G.G_PortalSanguineCDelay = v end, "s")

    local triggerSelectBtn = Instance.new("TextButton", soruCard)
    triggerSelectBtn.Size = UDim2.new(1, -16, 0, 24)
    triggerSelectBtn.Position = UDim2.new(0, 8, 0, 176)
    triggerSelectBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    triggerSelectBtn.BackgroundTransparency = 0
    triggerSelectBtn.Text = "⚡ Trigger: " .. (PortalSanguineCTriggerMode == "PortalF" and "Portal F Skill" or "Soru / Flashstep")
    triggerSelectBtn.Font = Enum.Font.GothamBold
    triggerSelectBtn.TextSize = 8.5
    triggerSelectBtn.TextColor3 = COLORS.TextWhite
    Instance.new("UICorner", triggerSelectBtn).CornerRadius = UDim.new(0, 6)
    local trgStroke = Instance.new("UIStroke", triggerSelectBtn)
    trgStroke.Color = currentThemeColor
    trgStroke.Thickness = 1
    table.insert(themeStrokes, trgStroke)

    triggerSelectBtn.MouseButton1Click:Connect(function()
        if PortalSanguineCTriggerMode == "PortalF" then
            PortalSanguineCTriggerMode = "Soru"
            triggerSelectBtn.Text = "⚡ Trigger: Soru / Flashstep"
        else
            PortalSanguineCTriggerMode = "PortalF"
            triggerSelectBtn.Text = "⚡ Trigger: Portal F Skill"
        end
    end)

    -- Flashstep Skill Combo
    local flashstepCard = createModuleCard("Flashstep Skill Combo", 135, SoruPage)
    addToggleElement(flashstepCard, "Flashstep Skill Combo", _G.G_FlashstepSkillEnabled, 24, function(v)
        _G.G_FlashstepSkillEnabled = v
    end, "FlashstepSkill")

    local weaponSelectBtn = Instance.new("TextButton", flashstepCard)
    weaponSelectBtn.Size = UDim2.new(1, -16, 0, 24)
    weaponSelectBtn.Position = UDim2.new(0, 8, 0, 48)
    weaponSelectBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    weaponSelectBtn.BackgroundTransparency = 0
    weaponSelectBtn.Text = "🗡️ Weapon: " .. (_G.G_FlashstepSkillWeapon or "Fruit")
    weaponSelectBtn.Font = Enum.Font.GothamBold
    weaponSelectBtn.TextSize = 8.5
    weaponSelectBtn.TextColor3 = COLORS.TextWhite
    Instance.new("UICorner", weaponSelectBtn).CornerRadius = UDim.new(0, 6)
    local wSt = Instance.new("UIStroke", weaponSelectBtn)
    wSt.Color = currentThemeColor
    wSt.Thickness = 1
    table.insert(themeStrokes, wSt)

    weaponSelectBtn.MouseButton1Click:Connect(function()
        local wList = {"Melee", "Fruit", "Sword", "Gun"}
        local curIdx = table.find(wList, _G.G_FlashstepSkillWeapon) or 2
        local nxtIdx = (curIdx % #wList) + 1
        _G.G_FlashstepSkillWeapon = wList[nxtIdx]
        weaponSelectBtn.Text = "🗡️ Weapon: " .. wList[nxtIdx]
    end)

    local keySelectBtn = Instance.new("TextButton", flashstepCard)
    keySelectBtn.Size = UDim2.new(1, -16, 0, 24)
    keySelectBtn.Position = UDim2.new(0, 8, 0, 76)
    keySelectBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    keySelectBtn.BackgroundTransparency = 0
    keySelectBtn.Text = "⌨️ Skill Key: " .. (_G.G_FlashstepSkillKey or "Z")
    keySelectBtn.Font = Enum.Font.GothamBold
    keySelectBtn.TextSize = 8.5
    keySelectBtn.TextColor3 = COLORS.TextWhite
    Instance.new("UICorner", keySelectBtn).CornerRadius = UDim.new(0, 6)
    local kSt = Instance.new("UIStroke", keySelectBtn)
    kSt.Color = currentThemeColor
    kSt.Thickness = 1
    table.insert(themeStrokes, kSt)

    keySelectBtn.MouseButton1Click:Connect(function()
        local kList = {"Z", "X", "C", "V", "F"}
        local curIdx = table.find(kList, _G.G_FlashstepSkillKey) or 1
        local nxtIdx = (curIdx % #kList) + 1
        _G.G_FlashstepSkillKey = kList[nxtIdx]
        keySelectBtn.Text = "⌨️ Skill Key: " .. kList[nxtIdx]
    end)

    addStepper(flashstepCard, "Skill Delay:", 104, 0.05, 2.0, 0.3, function() return _G.G_FlashstepSkillDelay or 0.3 end, function(v) _G.G_FlashstepSkillDelay = v end, "s")

    function refreshPlayerListUI()
        for _, item in ipairs(ListScroll:GetChildren()) do
            if item:IsA("TextButton") and item.Name ~= "DropLabel" and item.Name ~= "RefreshBtn" then
                item:Destroy()
            end
        end

        local nearestBtn = Instance.new("TextButton", ListScroll)
        nearestBtn.Name = "NearestBtn"
        nearestBtn.Size = UDim2.new(1, 0, 0, 24)
        nearestBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        nearestBtn.BackgroundTransparency = 0
        nearestBtn.Text = (currentLang == "ES" and "🎯 Target: Más Cercano" or "🎯 Target: Nearest")
        nearestBtn.Font = Enum.Font.GothamBold
        nearestBtn.TextSize = 10
        nearestBtn.TextColor3 = (SelectedSoruTarget == "Nearest") and COLORS.TextWhite or Color3.fromRGB(255, 60, 60)
        Instance.new("UICorner", nearestBtn).CornerRadius = UDim.new(0, 5)
        local nSt = Instance.new("UIStroke", nearestBtn)
        nSt.Color = (SelectedSoruTarget == "Nearest") and COLORS.TextWhite or currentThemeColor
        nSt.Thickness = 1.2
        table.insert(themeStrokes, nSt)

        nearestBtn.MouseButton1Click:Connect(function()
            SelectedSoruTarget = "Nearest"
            DropLabel.Text = (currentLang == "ES" and "🎯 Target: Más Cercano" or "🎯 Target: Nearest")
            refreshPlayerListUI()
        end)

        for _, p in pairs(Players:GetPlayers()) do
            if p ~= player then
                local isSelected = (SelectedSoruTarget == p.Name)
                local pBtn = Instance.new("TextButton", ListScroll)
                pBtn.Name = "PlayerBtn"
                pBtn.Size = UDim2.new(1, 0, 0, 24)
                pBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                pBtn.BackgroundTransparency = 0
                pBtn.Text = "👤 " .. p.Name
                pBtn.Font = Enum.Font.GothamBold
                pBtn.TextSize = 10
                pBtn.TextColor3 = isSelected and COLORS.TextWhite or Color3.fromRGB(255, 60, 60)
                Instance.new("UICorner", pBtn).CornerRadius = UDim.new(0, 5)
                local pSt = Instance.new("UIStroke", pBtn)
                pSt.Color = isSelected and COLORS.TextWhite or currentThemeColor
                pSt.Thickness = 1.2
                table.insert(themeStrokes, pSt)

                pBtn.MouseButton1Click:Connect(function()
                    SelectedSoruTarget = p.Name
                    DropLabel.Text = "🎯 Target: " .. p.Name
                    refreshPlayerListUI()
                end)
            end
        end

        if not ListScroll:FindFirstChild("RefreshBtn") then
            local refreshBtn = Instance.new("TextButton", ListScroll)
            refreshBtn.Name = "RefreshBtn"
            refreshBtn.Size = UDim2.new(1, 0, 0, 24)
            refreshBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            refreshBtn.BackgroundTransparency = 0
            refreshBtn.Text = (currentLang == "ES" and "⟳ Actualizar Lista" or "⟳ Refresh List")
            refreshBtn.Font = Enum.Font.GothamBold
            refreshBtn.TextSize = 9.5
            refreshBtn.TextColor3 = Color3.fromRGB(255, 60, 60)
            Instance.new("UICorner", refreshBtn).CornerRadius = UDim.new(0, 5)
            local rfSt = Instance.new("UIStroke", refreshBtn)
            rfSt.Color = currentThemeColor
            rfSt.Thickness = 1.2
            table.insert(themeStrokes, rfSt)
            refreshBtn.MouseButton1Click:Connect(refreshPlayerListUI)
        end
    end

    Players.PlayerAdded:Connect(refreshPlayerListUI)
    Players.PlayerRemoving:Connect(refreshPlayerListUI)
    DropLabel.MouseButton1Click:Connect(function()
        SelectedSoruTarget = "Nearest"
        DropLabel.Text = "🎯 Selector: Nearest"
        refreshPlayerListUI()
    end)
    refreshPlayerListUI()

    -- FPS/Ping Overlay
    local fpsOverlayGui = Instance.new("ScreenGui")
    fpsOverlayGui.Name = "RitualUI_FPSOverlay"
    fpsOverlayGui.ResetOnSpawn = false
    fpsOverlayGui.Parent = playerGui

    local fpsBar = Instance.new("Frame", fpsOverlayGui)
    fpsBar.Size = UDim2.new(0, 180, 0, 22)
    fpsBar.Position = UDim2.new(0.5, -90, 0, 0)
    fpsBar.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    fpsBar.BackgroundTransparency = 0
    fpsBar.Visible = false
    Instance.new("UICorner", fpsBar).CornerRadius = UDim.new(0, 6)
    local fpsStroke = Instance.new("UIStroke", fpsBar)
    fpsStroke.Color = currentThemeColor
    fpsStroke.Thickness = 1.5
    table.insert(themeStrokes, fpsStroke)

    local fpsLabel = Instance.new("TextLabel", fpsBar)
    fpsLabel.Size = UDim2.new(1, 0, 1, 0)
    fpsLabel.BackgroundTransparency = 1
    fpsLabel.Text = "FPS: 0 | Ping: 0ms"
    fpsLabel.Font = Enum.Font.GothamBold
    fpsLabel.TextSize = 10
    fpsLabel.TextColor3 = COLORS.TextWhite
    table.insert(themeTexts, fpsLabel)

    spawn(function()
        while true do
            wait(0.5)
            if FPSPingOverlayEnabled then
                fpsBar.Visible = true
                fpsLabel.Text = "FPS: " .. tostring(currentFPS) .. " | Ping: " .. tostring(currentPing) .. "ms"
            else
                fpsBar.Visible = false
            end
        end
    end)

    -- Misc Page (only Save & Reset Config)
    do
    local miscCard = createModuleCard("Config", 120, MiscPage)

    saveBtn = Instance.new("TextButton", miscCard)
    saveBtn.Size = UDim2.new(1, -20, 0, 28)
    saveBtn.Position = UDim2.new(0, 10, 0, 26)
    saveBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    saveBtn.BackgroundTransparency = 0
    saveBtn.Text = "💾 Save Config"
    saveBtn.Font = Enum.Font.GothamBold
    saveBtn.TextSize = 9.5
    saveBtn.TextColor3 = COLORS.TextWhite
    Instance.new("UICorner", saveBtn).CornerRadius = UDim.new(0, 8)
    local saveStroke = Instance.new("UIStroke", saveBtn)
    saveStroke.Color = currentThemeColor
    saveStroke.Thickness = 1.2
    table.insert(themeStrokes, saveStroke)

    saveBtn.MouseButton1Click:Connect(function() 
        pcall(SaveConfig)
        saveBtn.Text = currentLang == "ES" and "✅ Configuración Guardada!" or "✅ Config Saved!"
        task.delay(1.5, function()
            saveBtn.Text = currentLang == "ES" and "💾 Guardar Configuración" or "💾 Save Config"
        end)
    end)

    resetBtn = Instance.new("TextButton", miscCard)
    resetBtn.Size = UDim2.new(1, -20, 0, 28)
    resetBtn.Position = UDim2.new(0, 10, 0, 60)
    resetBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    resetBtn.BackgroundTransparency = 0
    resetBtn.Text = "🔄 Reset Config"
    resetBtn.Font = Enum.Font.GothamBold
    resetBtn.TextSize = 9.5
    resetBtn.TextColor3 = COLORS.TextWhite
    Instance.new("UICorner", resetBtn).CornerRadius = UDim.new(0, 8)
    local resetStroke = Instance.new("UIStroke", resetBtn)
    resetStroke.Color = currentThemeColor
    resetStroke.Thickness = 1.2
    table.insert(themeStrokes, resetStroke)
    table.insert(themeTexts, resetBtn)

    resetBtn.MouseButton1Click:Connect(function() 
        pcall(function() 
            if isfile and isfile("RitualHub_Config.json") then delfile("RitualHub_Config.json") end 
            if isfile and isfile("RitualHub_Bounty.json") then delfile("RitualHub_Bounty.json") end
        end)

        _G.G_ESPEnabled = false; _G.G_ESP_Name = true; _G.G_ESP_Level = true
        _G.G_ESP_Bounty = true; _G.G_ESP_Fruit = true; _G.G_ESP_Distance = true
        _G.G_ESP_HP = true; _G.G_ESP_Highlight = false; _G.G_ESP_TextSize = 12

        FastAttackEnabled = false; WalkSpeedEnabled = false; WalkSpeedValue = 16
        DashEnabled = false; DashLengthDist = 1; NoclipEnabled = false; WalkOnWaterEnabled = false
        SmartAutoV4Enabled = false; SuperJumpEnabled = false; SuperJumpPower = 500
        _G.G_SilentAimTargetPlayers = false; _G.G_SilentAimTargetMobs = false
        _G.G_SilentAimSkill = false; _G.G_DragonGunM1 = false; _G.G_SilentAimTeamCheck = false
        _G.G_SilentAimShowFOV = false; _G.G_SilentAimShowLine = false
        AimlockPlayerEnabled = false; AimlockNpcEnabled = false
        SoruInfinitoEnabled = false; SoruAimbotEnabled = false; PortalSoruEnabled = false
        FakeKorbloxEnabled = false; FakeHeadlessEnabled = false; FPSPingOverlayEnabled = false
        AntiStunHitboxEnabled = false

        PlayerWidgetActive = false; NpcWidgetActive = false
        SuperJumpWidgetVisible = false
        PortalSoruWidgetVisible = false

        for _, fn in ipairs(UI_Toggle_Refreshes) do 
            pcall(function() fn(false) end) 
        end
        
        DisableESP()
        updateWidgetsVisuals()

        resetBtn.Text = "✅ Reseteado / Reset Done!"
        task.delay(1.5, function() resetBtn.Text = "🔄 Reset Config" end)
    end)

    -- Language button (optional, but keep for user convenience)
    local langCard = createModuleCard("Language", 60, MiscPage)
    langBtn = Instance.new("TextButton", langCard)
    langBtn.Size = UDim2.new(1, -20, 0, 28)
    langBtn.Position = UDim2.new(0, 10, 0, 24)
    langBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    langBtn.BackgroundTransparency = 0
    langBtn.Text = (currentLang == "ES" and "🌐 Idioma: Español (ES)" or "🌐 Language: English (EN)")
    langBtn.Font = Enum.Font.GothamBold
    langBtn.TextSize = 9.5
    langBtn.TextColor3 = COLORS.TextWhite
    Instance.new("UICorner", langBtn).CornerRadius = UDim.new(0, 6)
    local langBtnStroke = Instance.new("UIStroke", langBtn)
    langBtnStroke.Color = currentThemeColor
    langBtnStroke.Thickness = 1.2
    table.insert(themeStrokes, langBtnStroke)

    langBtn.MouseButton1Click:Connect(function()
        local targetLang = (currentLang == "ES" and "EN" or "ES")
        updateUILanguage(targetLang)
        langBtn.Text = (currentLang == "ES" and "🌐 Idioma: Español (ES)" or "🌐 Language: English (EN)")
    end)

    end

    -- ============================================================
    -- THEME SYSTEM & KEYBINDING
    -- ============================================================
    do
    function isColorLight(c3)
        return (c3.R * 0.299 + c3.G * 0.587 + c3.B * 0.114) > 0.65
    end

    local rainbowConnection = nil

    function applyNewTheme(themeName)
        currentThemeName = themeName
        if rainbowConnection then
            rainbowConnection:Disconnect()
            rainbowConnection = nil
        end

        currentThemeColor = THEMES[themeName] or THEMES["Gold Yellow"]

        local function updateThemeColors(c3)
            currentThemeColor = c3

            for _, s in ipairs(themeStrokes) do 
                if s and s.Parent then s.Color = c3 end 
            end

            for _, f in ipairs(themeFrames) do 
                if f and f.Parent then 
                    f.BackgroundColor3 = c3 
                end 
            end

            for _, t in ipairs(themeTexts) do 
                if t and t.Parent then
                    t.TextColor3 = COLORS.TextWhite
                    t.TextStrokeTransparency = 0
                    t.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                end 
            end

            if rainContainer then
                for _, drop in ipairs(rainContainer:GetChildren()) do
                    if drop and drop:IsA("Frame") and drop.Name == "RainDrop" then
                        pcall(function() drop.BackgroundColor3 = c3 end)
                    end
                end
            end
        end

        if string.find(string.lower(themeName), "rainbow") then
            local hue = 0
            rainbowConnection = RunService.Heartbeat:Connect(function(dt)
                hue = (hue + dt * 0.35) % 1
                local rgb = Color3.fromHSV(hue, 0.9, 1)
                updateThemeColors(rgb)
            end)
        else
            updateThemeColors(currentThemeColor)
        end

        updateWidgetsVisuals()
    end

    UserInputService.InputBegan:Connect(function(input, gp)
        if not gp and input.KeyCode == Enum.KeyCode.F4 then
            if mainFrame.Visible then
                mainFrame.Visible = false
                openButton.Visible = true
            else
                openButton.Visible = false
                centerAndMaximizeUI()
            end
        end
    end)

    updateWidgetsVisuals()
    pcall(LoadConfig)
    pcall(LoadMacroConfig)
    centerAndMaximizeUI()
    end

    print("✅ RITUAL HUB v12.5 LOADED - ALL TOGGLES AND CONFIGS PERSISTENT")
end

-- ============================================================
-- Execute the main hub (runMain is already defined above)
-- ============================================================
-- If we haven't already called runMain from the key popup, call it now.
-- But we only want to call it once, and the key popup calls it on success.
-- If we already have _G.ritualKeyEntered = true, then the script execution
-- continued past the key block and reaches here. In that case, we need to call runMain.
-- However, runMain was defined only inside the key popup's success callback? Actually we defined it globally.
-- So we can simply call it here if not already running.
-- We'll add a flag to prevent double execution.
if not _G.ritualHubRunning then
    _G.ritualHubRunning = true
    runMain()
end
