-- ============================================================
--   RITUAL HUB - GOLD & BLACK (v16.0)
--   Hitbox Extender | NPC Pull | Auto Equip | Fast Attack
-- ============================================================

local player = game:GetService("Players").LocalPlayer
local TweenService = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser")
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")

-- ============================================================
--                WAIT FOR CHARACTER
-- ============================================================
local character, humanoid, rootPart

local function waitForCharacter()
    character = player.Character or player.CharacterAdded:Wait()
    humanoid = character:WaitForChild("Humanoid")
    rootPart = character:WaitForChild("HumanoidRootPart")
    print("✅ Character loaded:", character.Name)
end
waitForCharacter()

player.CharacterAdded:Connect(function(newChar)
    character = newChar
    humanoid = newChar:WaitForChild("Humanoid")
    rootPart = newChar:WaitForChild("HumanoidRootPart")
    print("✅ Character respawned")
end)

-- ============================================================
--                     GLOBAL TOGGLES
-- ============================================================
_G.Ritual = {
    Leveling = false,
    Quest = false,
    Chest = false,
    SeaBeast = false,
    ShipFarm = false,
    Raid = false,
    Dungeon = false,
    FruitSniper = false,
    ESP = false,
    AutoStats = false,
    AntiAFK = true,
    AutoRoll = false,
    AutoStore = false,
}

local selectedWeapon = "Melee" -- Options: "Melee", "Sword", "Gun", "Fruit"
print("✅ Toggles initialized")

-- ============================================================
--                HELPER: FASTER TWEEN (speed 350)
-- ============================================================
function tweenTo(pos, speed)
    speed = speed or 350
    if not rootPart then return end
    local dist = (pos - rootPart.Position).magnitude
    if dist < 3 then return end
    local dur = math.clamp(dist / speed, 0.1, 5)
    local tween = TweenService:Create(rootPart, TweenInfo.new(dur, Enum.EasingStyle.Linear), {CFrame = CFrame.new(pos)})
    tween:Play()
    tween.Completed:Wait()
end

-- ============================================================
--                HITBOX EXTENDER
-- ============================================================
function extendHitbox()
    pcall(function()
        if rootPart then
            rootPart.Size = Vector3.new(10, 6, 10)  -- Big hitbox, visually not too huge
        end
    end)
end

-- ============================================================
--                AUTO EQUIP SELECTED WEAPON
-- ============================================================
function equipWeapon(weaponType)
    pcall(function()
        local current = character:FindFirstChildOfClass("Tool")
        if current then
            local name = current.Name:lower()
            local match = false
            if weaponType == "Melee" and (name:find("sword") or name:find("blade") or name:find("katana") or name:find("club") or name:find("fist") or name:find("trident") or name:find("pole") or name:find("axe") or name:find("hammer")) then
                match = true
            elseif weaponType == "Sword" and (name:find("sword") or name:find("blade") or name:find("katana") or name:find("cutlass") or name:find("saber") or name:find("longsword")) then
                match = true
            elseif weaponType == "Gun" and (name:find("gun") or name:find("pistol") or name:find("rifle") or name:find("cannon") or name:find("flintlock") or name:find("revolver")) then
                match = true
            elseif weaponType == "Fruit" and (name:find("fruit") or name:find("leopard") or name:find("dragon") or name:find("venom") or name:find("dough") or name:find("buddha") or name:find("flame") or name:find("ice") or name:find("light") or name:find("dark") or name:find("shadow")) then
                match = true
            end
            if match then return current end
        end

        for _, tool in pairs(player.Backpack:GetChildren()) do
            if tool:IsA("Tool") then
                local name = tool.Name:lower()
                local match = false
                if weaponType == "Melee" and (name:find("sword") or name:find("blade") or name:find("katana") or name:find("club") or name:find("fist") or name:find("trident") or name:find("pole") or name:find("axe") or name:find("hammer")) then
                    match = true
                elseif weaponType == "Sword" and (name:find("sword") or name:find("blade") or name:find("katana") or name:find("cutlass") or name:find("saber") or name:find("longsword")) then
                    match = true
                elseif weaponType == "Gun" and (name:find("gun") or name:find("pistol") or name:find("rifle") or name:find("cannon") or name:find("flintlock") or name:find("revolver")) then
                    match = true
                elseif weaponType == "Fruit" and (name:find("fruit") or name:find("leopard") or name:find("dragon") or name:find("venom") or name:find("dough") or name:find("buddha") or name:find("flame") or name:find("ice") or name:find("light") or name:find("dark") or name:find("shadow")) then
                    match = true
                end
                if match then
                    tool.Parent = character
                    task.wait(0.1)
                    return tool
                end
            end
        end
        return nil
    end)
    return nil
end

-- ============================================================
--                FAST ATTACK (spam M1)
-- ============================================================
local function fastAttack()
    pcall(function()
        local tool = character:FindFirstChildOfClass("Tool")
        if not tool then
            tool = equipWeapon(selectedWeapon)
        end
        if tool then
            tool:Activate()
        else
            humanoid:StartAttack(0.5)
        end
        task.wait(0.01)  -- Very fast
        if tool then
            tool:Activate()
        else
            humanoid:StartAttack(0.5)
        end
    end)
end

-- ============================================================
--                ENEMY DETECTION
-- ============================================================
function getNearestEnemy(range)
    range = range or 500
    if not rootPart then return nil end
    local closest, bestDist = nil, math.huge
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("Model") and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") then
            if v.Name ~= player.Name and not game:GetService("Players"):FindFirstChild(v.Name) then
                local hrp = v:FindFirstChild("HumanoidRootPart")
                if hrp and v.Humanoid.Health > 0 then
                    local d = (rootPart.Position - hrp.Position).magnitude
                    if d < bestDist and d < range then
                        bestDist = d
                        closest = v
                    end
                end
            end
        end
    end
    return closest
end

-- ============================================================
--                NPC PULL (brings NPCs under you)
-- ============================================================
function pullNPCs()
    pcall(function()
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("Model") and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") then
                if v.Name ~= player.Name and not game:GetService("Players"):FindFirstChild(v.Name) then
                    local hrp = v:FindFirstChild("HumanoidRootPart")
                    if hrp and v.Humanoid.Health > 0 then
                        local dist = (rootPart.Position - hrp.Position).magnitude
                        if dist < 300 and dist > 5 then
                            -- Move NPC toward player's position (but keep it slightly below)
                            local targetPos = rootPart.Position + Vector3.new(0, -2, 0)
                            hrp.CFrame = CFrame.new(hrp.Position + (targetPos - hrp.Position).unit * 3)
                        end
                    end
                end
            end
        end
    end)
end

function attackTarget(target)
    if not target or not rootPart then return end
    local hrp = target:FindFirstChild("HumanoidRootPart")
    if hrp then
        -- Position higher above NPC (12 studs)
        local pos = hrp.Position + Vector3.new(0, 12, 2)
        tweenTo(pos, 350)
        task.wait(0.05)
        extendHitbox()
        task.wait(0.05)
        -- Fast attack spam
        for i = 1, 4 do
            fastAttack()
            task.wait(0.02)
        end
        print("⚔️ Attacking:", target.Name)
    end
end

-- ============================================================
--              ROBUST SEA DETECTION
-- ============================================================
function getSea()
    if not rootPart then return "?" end
    local pos = rootPart.Position
    local x, z = pos.X, pos.Z
    if z > 2000 and x < 1000 then return "1st" end
    if z < 500 and z > -500 and x < 1000 and x > -1000 then return "2nd" end
    if x > 4000 and z < -500 then return "2nd" end
    if x > 2000 and z < -500 and z > -2000 then return "3rd" end
    if x > 2000 and z > 2000 then return "3rd" end
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") and v.Name:lower():find("sea") then
            local seaPos = v.Position
            if (pos - seaPos).magnitude < 2000 then
                if v.Name:lower():find("first") then return "1st" end
                if v.Name:lower():find("second") then return "2nd" end
                if v.Name:lower():find("third") then return "3rd" end
            end
        end
    end
    return "?"
end

-- ============================================================
--              FIND CHESTS & FRUITS (FIXED)
-- ============================================================
function findChests()
    local chests = {}
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") and v.Name:lower():find("chest") then
            table.insert(chests, v)
        elseif v:IsA("Model") and v.Name:lower():find("chest") then
            local mainPart = v:FindFirstChild("Handle") or v:FindFirstChild("Part") or v:FindFirstChildOfClass("BasePart")
            if mainPart then table.insert(chests, mainPart) end
        end
    end
    return chests
end

function findFruits()
    local fruits = {}
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("Tool") and v.Name:lower():find("fruit") then
            table.insert(fruits, v)
        elseif v:IsA("BasePart") and v.Name:lower():find("fruit") then
            table.insert(fruits, v)
        elseif v:IsA("Model") and v.Name:lower():find("fruit") then
            local mainPart = v:FindFirstChild("Handle") or v:FindFirstChild("Part") or v:FindFirstChildOfClass("BasePart")
            if mainPart then table.insert(fruits, mainPart) end
        end
    end
    return fruits
end

-- ============================================================
--              ISLAND COORDINATES
-- ============================================================
local islands = {
    ["1st"] = {
        {"Jungle", Vector3.new(-1220, 80, 2850)},
        {"Pirate Village", Vector3.new(-60, 10, 2850)},
        {"Marine Fort", Vector3.new(2700, 15, 2800)},
        {"Sky Islands", Vector3.new(3500, 700, 1200)},
    },
    ["2nd"] = {
        {"Kingdom of Rose", Vector3.new(-50, 50, -50)},
        {"Ice Castle", Vector3.new(4800, 350, -1100)},
        {"Raid Portal", Vector3.new(-100, 20, -50)},
        {"Sea of Treats", Vector3.new(2700, 10, -1200)},
    },
    ["3rd"] = {
        {"Castle on Sea", Vector3.new(2800, 10, -1300)},
        {"Great Tree", Vector3.new(2900, 200, 2900)},
        {"Floating Turtle", Vector3.new(-500, 100, 4100)},
        {"Mansion", Vector3.new(-2400, 10, -2400)},
    }
}

-- ============================================================
--              UI - GOLD & BLACK (Side Tabs)
-- ============================================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "RitualHub"
screenGui.Parent = CoreGui
screenGui.ResetOnSpawn = false

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 550, 0, 560)
mainFrame.Position = UDim2.new(0.5, -275, 0.5, -280)
mainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
mainFrame.BackgroundTransparency = 0.15
mainFrame.BorderSizePixel = 2
mainFrame.BorderColor3 = Color3.fromRGB(255, 215, 0)
mainFrame.ClipsDescendants = true
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local glass = Instance.new("Frame")
glass.Size = UDim2.new(1, -4, 1, -4)
glass.Position = UDim2.new(0, 2, 0, 2)
glass.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
glass.BackgroundTransparency = 0.2
glass.BorderSizePixel = 0
glass.Parent = mainFrame

-- Title Bar
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 40)
titleBar.BackgroundTransparency = 1
titleBar.Parent = glass

local dragHandle = Instance.new("TextLabel")
dragHandle.Size = UDim2.new(0, 20, 1, 0)
dragHandle.Position = UDim2.new(0, 5, 0, 0)
dragHandle.BackgroundTransparency = 1
dragHandle.Text = "≡"
dragHandle.TextColor3 = Color3.fromRGB(255, 215, 0)
dragHandle.TextScaled = true
dragHandle.Font = Enum.Font.GothamBold
dragHandle.Parent = titleBar

local title = Instance.new("TextLabel")
title.Size = UDim2.new(0, 90, 1, 0)
title.Position = UDim2.new(0, 30, 0, 0)
title.BackgroundTransparency = 1
title.Text = "⚡RITUAL"
title.TextColor3 = Color3.fromRGB(255, 215, 0)
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.Parent = titleBar

local seaLabel = Instance.new("TextLabel")
seaLabel.Size = UDim2.new(0, 60, 1, 0)
seaLabel.Position = UDim2.new(0, 130, 0, 0)
seaLabel.BackgroundTransparency = 1
seaLabel.Text = "🌊 "..getSea()
seaLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
seaLabel.TextScaled = true
seaLabel.Font = Enum.Font.GothamMedium
seaLabel.Parent = titleBar

local statsLabel = Instance.new("TextLabel")
statsLabel.Size = UDim2.new(0, 190, 1, 0)
statsLabel.Position = UDim2.new(0, 200, 0, 0)
statsLabel.BackgroundTransparency = 1
statsLabel.Text = "Lv.0  $0  🍎None  💎0"
statsLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
statsLabel.TextScaled = true
statsLabel.Font = Enum.Font.GothamMedium
statsLabel.Parent = titleBar

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(0, 150, 1, 0)
statusLabel.Position = UDim2.new(1, -160, 0, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "🟢 Idle"
statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
statusLabel.TextScaled = true
statusLabel.Font = Enum.Font.GothamMedium
statusLabel.Parent = titleBar

local function createGoldButton(text, posX, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 32, 0, 28)
    btn.Position = UDim2.new(1, posX, 0, 6)
    btn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    btn.BackgroundTransparency = 0.3
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 215, 0)
    btn.TextScaled = true
    btn.Font = Enum.Font.GothamBold
    btn.BorderSizePixel = 1
    btn.BorderColor3 = Color3.fromRGB(255, 215, 0)
    btn.Parent = titleBar
    btn.MouseButton1Click:Connect(callback)
    return btn
end

local minimized = false
local minBtn = createGoldButton("−", -70, function()
    minimized = not minimized
    if minimized then
        mainFrame:TweenSize(UDim2.new(0, 180, 0, 32), "Out", "Quad", 0.25, true)
        minBtn.Text = "+"
        for _, c in pairs(glass:GetChildren()) do
            if c ~= titleBar and c ~= minBtn and c ~= closeBtn then
                c.Visible = false
            end
        end
    else
        mainFrame:TweenSize(UDim2.new(0, 550, 0, 560), "Out", "Quad", 0.25, true)
        minBtn.Text = "−"
        for _, c in pairs(glass:GetChildren()) do
            c.Visible = true
        end
    end
end)

local closeBtn = createGoldButton("✕", -35, function()
    screenGui:Destroy()
end)

-- Side Tabs
local tabPanel = Instance.new("Frame")
tabPanel.Size = UDim2.new(0, 85, 1, -40)
tabPanel.Position = UDim2.new(0, 0, 0, 40)
tabPanel.BackgroundTransparency = 1
tabPanel.Parent = glass

local contentPanel = Instance.new("Frame")
contentPanel.Size = UDim2.new(1, -95, 1, -40)
contentPanel.Position = UDim2.new(0, 90, 0, 40)
contentPanel.BackgroundTransparency = 1
contentPanel.Parent = glass

local tabNames = {"Farm", "Raids", "Teleports", "Misc"}
local tabButtons = {}
local currentTab = "Farm"

for i, name in ipairs(tabNames) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 36)
    btn.Position = UDim2.new(0, 5, 0, 10 + (i-1)*44)
    btn.BackgroundColor3 = (name == currentTab) and Color3.fromRGB(255, 215, 0) or Color3.fromRGB(25, 25, 25)
    btn.BackgroundTransparency = 0.2
    btn.Text = name
    btn.TextColor3 = (name == currentTab) and Color3.fromRGB(10, 10, 10) or Color3.fromRGB(255, 215, 0)
    btn.TextScaled = true
    btn.Font = Enum.Font.GothamBold
    btn.BorderSizePixel = 1
    btn.BorderColor3 = Color3.fromRGB(255, 215, 0)
    btn.Parent = tabPanel
    tabButtons[name] = btn

    btn.MouseButton1Click:Connect(function()
        currentTab = name
        for _, v in pairs(tabButtons) do
            v.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            v.TextColor3 = Color3.fromRGB(255, 215, 0)
        end
        btn.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
        btn.TextColor3 = Color3.fromRGB(10, 10, 10)
        for _, child in pairs(contentPanel:GetChildren()) do
            if child:IsA("Frame") then child.Visible = false end
        end
        local content = contentPanel:FindFirstChild(name.."Content")
        if content then content.Visible = true end
    end)
end

-- ============================================================
--           HELPER: TOGGLE BUTTON
-- ============================================================
local function createToggle(parent, text, yPos, default, ref)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 170, 0, 36)
    btn.Position = UDim2.new(0, 10, 0, yPos)
    btn.BackgroundColor3 = default and Color3.fromRGB(255, 215, 0) or Color3.fromRGB(30, 30, 30)
    btn.BackgroundTransparency = 0.2
    btn.Text = text .. (default and " ✅" or " ❌")
    btn.TextColor3 = default and Color3.fromRGB(10, 10, 10) or Color3.fromRGB(255, 215, 0)
    btn.TextScaled = true
    btn.Font = Enum.Font.GothamBold
    btn.BorderSizePixel = 1
    btn.BorderColor3 = Color3.fromRGB(255, 215, 0)
    btn.Parent = parent
    if ref then _G.Ritual[ref] = default end
    btn.MouseButton1Click:Connect(function()
        local newState = not _G.Ritual[ref]
        _G.Ritual[ref] = newState
        btn.BackgroundColor3 = newState and Color3.fromRGB(255, 215, 0) or Color3.fromRGB(30, 30, 30)
        btn.TextColor3 = newState and Color3.fromRGB(10, 10, 10) or Color3.fromRGB(255, 215, 0)
        btn.Text = text .. (newState and " ✅" or " ❌")
        print("🔄 Toggle:", ref, "->", newState)
        updateStatus()
    end)
    return btn
end

-- ============================================================
--           WEAPON SELECTOR (Cycles)
-- ============================================================
local function createWeaponSelector(parent, yPos)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 170, 0, 36)
    frame.Position = UDim2.new(0, 10, 0, yPos)
    frame.BackgroundTransparency = 1
    frame.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.5, 0, 1, 0)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = "Weapon:"
    label.TextColor3 = Color3.fromRGB(255, 215, 0)
    label.TextScaled = true
    label.Font = Enum.Font.GothamMedium
    label.Parent = frame

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.5, 0, 1, 0)
    btn.Position = UDim2.new(0.5, 0, 0, 0)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 70)
    btn.BackgroundTransparency = 0.2
    btn.Text = selectedWeapon
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextScaled = true
    btn.Font = Enum.Font.GothamBold
    btn.BorderSizePixel = 1
    btn.BorderColor3 = Color3.fromRGB(255, 215, 0)
    btn.Parent = frame

    local weaponTypes = {"Melee", "Sword", "Gun", "Fruit"}
    local currentIndex = 1
    for i, w in ipairs(weaponTypes) do
        if w == selectedWeapon then currentIndex = i break end
    end

    btn.MouseButton1Click:Connect(function()
        currentIndex = currentIndex % #weaponTypes + 1
        selectedWeapon = weaponTypes[currentIndex]
        btn.Text = selectedWeapon
        print("🔧 Weapon changed to:", selectedWeapon)
    end)
    return frame
end

-- ============================================================
--              STATUS UPDATE
-- ============================================================
function updateStatus()
    local active = {}
    for k, v in pairs(_G.Ritual) do
        if v and k ~= "AntiAFK" and k ~= "ESP" and k ~= "AutoStats" then
            table.insert(active, k)
        end
    end
    if #active > 0 then
        statusLabel.Text = "🟢 " .. table.concat(active, ", ")
        statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
    else
        statusLabel.Text = "🟢 Idle"
        statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
    end
end

-- ============================================================
--           CONTENT FRAMES
-- ============================================================

-- 1. Farm Tab
local farmContent = Instance.new("Frame")
farmContent.Name = "FarmContent"
farmContent.Size = UDim2.new(1, 0, 1, 0)
farmContent.BackgroundTransparency = 1
farmContent.Parent = contentPanel

createToggle(farmContent, "Auto Leveling", 10, false, "Leveling")
createWeaponSelector(farmContent, 55)
createToggle(farmContent, "Auto Quest", 110, false, "Quest")
createToggle(farmContent, "Auto Chest", 155, false, "Chest")
createToggle(farmContent, "Auto Sea Beast", 200, false, "SeaBeast")
createToggle(farmContent, "Auto Ship Farm", 245, false, "ShipFarm")
createToggle(farmContent, "Anti AFK", 290, true, "AntiAFK")
createToggle(farmContent, "Auto Stats", 335, false, "AutoStats")

-- 2. Raids Tab
local raidContent = Instance.new("Frame")
raidContent.Name = "RaidsContent"
raidContent.Size = UDim2.new(1, 0, 1, 0)
raidContent.BackgroundTransparency = 1
raidContent.Visible = false
raidContent.Parent = contentPanel

createToggle(raidContent, "Auto Raid (Awaken)", 10, false, "Raid")
createToggle(raidContent, "Auto Dungeon", 55, false, "Dungeon")

local raidInfo = Instance.new("TextLabel")
raidInfo.Size = UDim2.new(0.9, 0, 0, 60)
raidInfo.Position = UDim2.new(0.05, 0, 0, 120)
raidInfo.BackgroundTransparency = 0.5
raidInfo.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
raidInfo.BorderSizePixel = 1
raidInfo.BorderColor3 = Color3.fromRGB(255, 215, 0)
raidInfo.Text = "⚔️ Auto Raid: enters and clears raids\n🏰 Auto Dungeon: clears Castle on Sea"
raidInfo.TextColor3 = Color3.fromRGB(200, 200, 200)
raidInfo.TextScaled = true
raidInfo.Font = Enum.Font.GothamMedium
raidInfo.Parent = raidContent

-- 3. Teleports Tab
local teleContent = Instance.new("Frame")
teleContent.Name = "TeleportsContent"
teleContent.Size = UDim2.new(1, 0, 1, 0)
teleContent.BackgroundTransparency = 1
teleContent.Visible = false
teleContent.Parent = contentPanel

local teleScroll = Instance.new("ScrollingFrame")
teleScroll.Size = UDim2.new(1, 0, 1, 0)
teleScroll.BackgroundTransparency = 1
teleScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
teleScroll.ScrollBarThickness = 4
teleScroll.Parent = teleContent

local function updateTeleportButtons()
    for _, child in pairs(teleScroll:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    local sea = getSea()
    local locs = islands[sea] or {}
    local y = 5
    for _, loc in ipairs(locs) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0.9, 0, 0, 38)
        btn.Position = UDim2.new(0.05, 0, 0, y)
        btn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        btn.BackgroundTransparency = 0.2
        btn.Text = loc[1]
        btn.TextColor3 = Color3.fromRGB(255, 215, 0)
        btn.TextScaled = true
        btn.Font = Enum.Font.GothamMedium
        btn.BorderSizePixel = 1
        btn.BorderColor3 = Color3.fromRGB(255, 215, 0)
        btn.Parent = teleScroll
        btn.MouseButton1Click:Connect(function()
            tweenTo(loc[2] + Vector3.new(0, 15, 0), 350)
        end)
        y = y + 44
    end
    teleScroll.CanvasSize = UDim2.new(0, 0, 0, y + 10)
end

updateTeleportButtons()
spawn(function()
    while wait(3) do
        updateTeleportButtons()
        seaLabel.Text = "🌊 "..getSea()
    end
end)

-- 4. Misc Tab
local miscContent = Instance.new("Frame")
miscContent.Name = "MiscContent"
miscContent.Size = UDim2.new(1, 0, 1, 0)
miscContent.BackgroundTransparency = 1
miscContent.Visible = false
miscContent.Parent = contentPanel

createToggle(miscContent, "Fruit Sniper", 10, false, "FruitSniper")
createToggle(miscContent, "Auto Roll Fruit", 55, false, "AutoRoll")
createToggle(miscContent, "Auto Store Fruit", 100, false, "AutoStore")
createToggle(miscContent, "ESP (Fruits/Chests)", 145, false, "ESP")

local miscInfo = Instance.new("TextLabel")
miscInfo.Size = UDim2.new(0.9, 0, 0, 80)
miscInfo.Position = UDim2.new(0.05, 0, 0, 210)
miscInfo.BackgroundTransparency = 0.5
miscInfo.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
miscInfo.BorderSizePixel = 1
miscInfo.BorderColor3 = Color3.fromRGB(255, 215, 0)
miscInfo.Text = "🍎 Fruit Sniper: tweens to fruits\n🎲 Auto Roll: uses fragments at Fruit Dealer\n📦 Auto Store: stores picked fruits in inventory\n👁️ ESP: highlights fruits (red) & chests (yellow)"
miscInfo.TextColor3 = Color3.fromRGB(200, 200, 200)
miscInfo.TextScaled = true
miscInfo.Font = Enum.Font.GothamMedium
miscInfo.Parent = miscContent

-- ============================================================
--              STATS UPDATE LOOP
-- ============================================================
spawn(function()
    while wait(1) do
        pcall(function()
            local data = player:FindFirstChild("Data")
            if data then
                local lvl = data:FindFirstChild("Level") and data.Level.Value or 0
                local beli = data:FindFirstChild("Beli") and data.Beli.Value or 0
                local fruit = data:FindFirstChild("Fruit") and data.Fruit.Value or "None"
                local frags = data:FindFirstChild("Fragments") and data.Fragments.Value or 0
                statsLabel.Text = "Lv."..lvl.."  $"..beli.."  🍎"..fruit.."  💎"..frags
            end
            seaLabel.Text = "🌊 "..getSea()
        end)
    end
end)

-- ============================================================
--           FEATURE LOOPS
-- ============================================================

function getQuestNPC()
    local lvl = player:FindFirstChild("Data") and player.Data:FindFirstChild("Level") and player.Data.Level.Value or 0
    local names = {"Pirate", "Monkey", "Soldier", "Bandit", "Mob Leader", "Marine", "Raider"}
    for _, name in pairs(names) do
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("Model") and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") then
                if string.find(v.Name:lower(), name:lower()) then
                    return v
                end
            end
        end
    end
    return nil
end

function getFruitDealer()
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("Model") and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") then
            if v.Name:lower():find("dealer") or (v.Name:lower():find("fruit") and v.Name:lower():find("npc")) then
                return v
            end
        end
    end
    return nil
end

function storeFruit(fruitTool)
    if not fruitTool then return end
    pcall(function()
        local remote = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes")
        if remote then
            local storeEvent = remote:FindFirstChild("StoreFruit") or remote:FindFirstChild("FruitStorage")
            if storeEvent then
                storeEvent:FireServer(fruitTool)
                print("📦 Stored fruit:", fruitTool.Name)
                return
            end
        end
    end)
end

-- ============================================================
-- 1. AUTO LEVELING (with hitbox extender + NPC pull)
-- ============================================================
spawn(function()
    print("✅ Auto Leveling loop started")
    while wait(0.05) do
        if _G.Ritual.Leveling and character and rootPart then
            pcall(function()
                -- Extend hitbox once per loop
                extendHitbox()
                -- Pull NPCs towards you
                pullNPCs()
                -- Attack nearest enemy
                local enemy = getNearestEnemy(500)
                if enemy then
                    attackTarget(enemy)
                end
            end)
        end
    end
end)

-- ============================================================
-- 2. AUTO QUEST (interacts with NPC)
-- ============================================================
spawn(function()
    print("✅ Auto Quest loop started")
    while wait(1) do
        if _G.Ritual.Quest and character and rootPart then
            pcall(function()
                local npc = getQuestNPC()
                if npc then
                    print("📝 Found NPC:", npc.Name)
                    local npcPos = npc.HumanoidRootPart.Position
                    if (rootPart.Position - npcPos).magnitude > 15 then
                        tweenTo(npcPos + Vector3.new(0, 7, 3), 350)
                    end
                    task.wait(0.2)
                    tweenTo(npcPos + Vector3.new(0, 7, 0), 350)
                    task.wait(0.2)
                    local clickDetector = npc:FindFirstChild("ClickDetector")
                    if clickDetector then
                        fireclickdetector(clickDetector)
                        print("📞 Interacted with NPC:", npc.Name)
                    else
                        local remote = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes")
                        if remote then
                            local questRemote = remote:FindFirstChild("Quest") or remote:FindFirstChild("GetQuest")
                            if questRemote then
                                questRemote:FireServer(npc)
                                print("📞 Sent quest request to:", npc.Name)
                            end
                        end
                    end
                    task.wait(0.5)
                end
            end)
        end
    end
end)

-- ============================================================
-- 3. AUTO CHEST (continuous)
-- ============================================================
spawn(function()
    print("✅ Auto Chest loop started")
    while wait(0.2) do
        if _G.Ritual.Chest and character and rootPart then
            pcall(function()
                for _, chest in pairs(findChests()) do
                    local pos = chest.Position
                    if pos and (pos - rootPart.Position).magnitude < 150 then
                        print("📦 Collecting Chest:", chest.Name)
                        tweenTo(pos + Vector3.new(0, 3, 0), 350)
                        task.wait(0.1)
                        local clickDetector = chest.Parent:FindFirstChild("ClickDetector")
                        if clickDetector then
                            fireclickdetector(clickDetector)
                        end
                    end
                end
            end)
        end
    end
end)

-- ============================================================
-- 4. AUTO SEA BEAST
-- ============================================================
spawn(function()
    print("✅ Auto Sea Beast loop started")
    while wait(0.5) do
        if _G.Ritual.SeaBeast and character then
            pcall(function()
                for _, v in pairs(workspace:GetDescendants()) do
                    if v:IsA("Model") and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") then
                        if v.Name:lower():find("sea") or v.Name:lower():find("beast") then
                            local dist = (rootPart.Position - v.HumanoidRootPart.Position).magnitude
                            if dist < 800 then 
                                attackTarget(v) 
                            else 
                                tweenTo(v.HumanoidRootPart.Position + Vector3.new(0,20,50), 350) 
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- ============================================================
-- 5. AUTO SHIP FARM
-- ============================================================
spawn(function()
    print("✅ Auto Ship Farm loop started")
    while wait(0.5) do
        if _G.Ritual.ShipFarm and character then
            pcall(function()
                for _, v in pairs(workspace:GetDescendants()) do
                    if v:IsA("Model") and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") then
                        if v.Name:lower():find("ship") or v.Name:lower():find("boat") then
                            attackTarget(v)
                        end
                    end
                end
            end)
        end
    end
end)

-- ============================================================
-- 6. AUTO RAID
-- ============================================================
spawn(function()
    print("✅ Auto Raid loop started")
    while wait(0.5) do
        if _G.Ritual.Raid and character then
            pcall(function()
                local raidIsland = workspace:FindFirstChild("Raid") or workspace:FindFirstChild("RaidIsland")
                if raidIsland then
                    local enemy = getNearestEnemy(1000)
                    if enemy then 
                        attackTarget(enemy)
                    else
                        local center = raidIsland:FindFirstChild("HumanoidRootPart") or raidIsland:FindFirstChild("Part")
                        if center then 
                            tweenTo(center.Position + Vector3.new(0,10,0), 350) 
                        end
                    end
                else
                    tweenTo(Vector3.new(-100,20,-50) + Vector3.new(0,5,0), 350)
                end
            end)
        end
    end
end)

-- ============================================================
-- 7. AUTO DUNGEON
-- ============================================================
spawn(function()
    print("✅ Auto Dungeon loop started")
    while wait(0.5) do
        if _G.Ritual.Dungeon and character then
            pcall(function()
                local dungeon = workspace:FindFirstChild("Castle") or workspace:FindFirstChild("Dungeon")
                if dungeon then
                    local enemy = getNearestEnemy(1000)
                    if enemy then 
                        attackTarget(enemy)
                    else
                        local part = dungeon:FindFirstChild("HumanoidRootPart") or dungeon:FindFirstChild("Part")
                        if part then 
                            tweenTo(part.Position + Vector3.new(0,10,5), 350) 
                        end
                    end
                else
                    tweenTo(Vector3.new(2800,10,-1300) + Vector3.new(0,5,0), 350)
                end
            end)
        end
    end
end)

-- ============================================================
-- 8. FRUIT SNIPER (FIXED)
-- ============================================================
spawn(function()
    print("✅ Fruit Sniper loop started")
    while wait(0.3) do
        if _G.Ritual.FruitSniper and character and rootPart then
            pcall(function()
                for _, fruit in pairs(findFruits()) do
                    local pos = fruit:IsA("Tool") and fruit:FindFirstChild("Handle") and fruit.Handle.Position or fruit.Position
                    if pos and (pos - rootPart.Position).magnitude < 600 then
                        print("🍎 Fruit found:", fruit.Name)
                        tweenTo(pos + Vector3.new(0,3,0), 350)
                        task.wait(0.2)
                        tweenTo(pos + Vector3.new(0,2,0), 350)
                        if _G.Ritual.AutoStore then
                            task.wait(0.3)
                            local held = character:FindFirstChild(fruit.Name) or player.Backpack:FindFirstChild(fruit.Name)
                            if held then storeFruit(held) end
                        end
                    end
                end
            end)
        end
    end
end)

-- ============================================================
-- 9. AUTO ROLL
-- ============================================================
spawn(function()
    print("✅ Auto Roll loop started")
    while wait(5) do
        if _G.Ritual.AutoRoll and character and rootPart then
            pcall(function()
                local dealer = getFruitDealer()
                if dealer then
                    local pos = dealer.HumanoidRootPart.Position
                    if (rootPart.Position - pos).magnitude > 15 then 
                        tweenTo(pos + Vector3.new(0,7,3), 350) 
                    end
                    task.wait(0.3)
                    tweenTo(pos + Vector3.new(0,7,0), 350)
                    task.wait(0.2)
                    local cd = dealer:FindFirstChild("ClickDetector")
                    if cd then 
                        fireclickdetector(cd)
                        print("🎲 Rolled for a fruit!")
                    end
                end
            end)
        end
    end
end)

-- ============================================================
-- 10. AUTO STORE
-- ============================================================
spawn(function()
    print("✅ Auto Store loop started")
    while wait(0.5) do
        if _G.Ritual.AutoStore and character then
            pcall(function()
                local fruitTool = nil
                for _, t in pairs(character:GetChildren()) do
                    if t:IsA("Tool") and (t.Name:lower():find("fruit") or t.Name:lower():find("leopard") or t.Name:lower():find("dragon")) then
                        fruitTool = t; break
                    end
                end
                if not fruitTool then
                    for _, t in pairs(player.Backpack:GetChildren()) do
                        if t:IsA("Tool") and (t.Name:lower():find("fruit") or t.Name:lower():find("leopard") or t.Name:lower():find("dragon")) then
                            fruitTool = t; break
                        end
                    end
                end
                if fruitTool then storeFruit(fruitTool) end
            end)
        end
    end
end)

-- ============================================================
-- 11. ESP (FIXED)
-- ============================================================
spawn(function()
    print("✅ ESP loop started")
    while wait(0.3) do
        if _G.Ritual.ESP then
            pcall(function()
                for _, fruit in pairs(findFruits()) do
                    local parent = fruit:IsA("Tool") and fruit or fruit.Parent
                    if parent and not parent:FindFirstChild("RitualESP") then
                        local h = Instance.new("Highlight")
                        h.Name = "RitualESP"
                        h.FillColor = Color3.fromRGB(255, 50, 50)
                        h.FillTransparency = 0.3
                        h.OutlineColor = Color3.fromRGB(255, 255, 255)
                        h.OutlineTransparency = 0.1
                        h.Parent = parent
                    end
                end
                for _, chest in pairs(findChests()) do
                    local parent = chest:IsA("BasePart") and chest.Parent or chest
                    if parent and not parent:FindFirstChild("RitualESP") then
                        local h = Instance.new("Highlight")
                        h.Name = "RitualESP"
                        h.FillColor = Color3.fromRGB(255, 215, 0)
                        h.FillTransparency = 0.3
                        h.OutlineColor = Color3.fromRGB(255, 255, 255)
                        h.OutlineTransparency = 0.1
                        h.Parent = parent
                    end
                end
            end)
        else
            for _, v in pairs(workspace:GetDescendants()) do
                if v.Name == "RitualESP" then v:Destroy() end
            end
        end
    end
end)

-- ============================================================
-- 12. AUTO STATS
-- ============================================================
spawn(function()
    print("✅ Auto Stats loop started")
    while wait(2) do
        if _G.Ritual.AutoStats then
            pcall(function()
                local stats = player:FindFirstChild("Data") and player.Data:FindFirstChild("Stats")
                if stats then
                    local melee = stats:FindFirstChild("Melee")
                    if melee then
                        local points = player:FindFirstChild("Data") and player.Data:FindFirstChild("StatPoints")
                        if points and points.Value > 0 then
                            for i = 1, points.Value do
                                melee.Value = melee.Value + 1
                                points.Value = points.Value - 1
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- ============================================================
-- 13. ANTI AFK
-- ============================================================
spawn(function()
    print("✅ Anti-AFK loop started")
    while wait(15) do
        if _G.Ritual.AntiAFK then
            pcall(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
                if rootPart then
                    TweenService:Create(rootPart, TweenInfo.new(0.3), {CFrame = rootPart.CFrame * CFrame.new(0,0,0.5)}):Play()
                end
            end)
        end
    end
end)

updateStatus()
print("⚡ Ritual Hub (v16.0) loaded – Hitbox extender + NPC pull active!")
