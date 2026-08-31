-- ============================================================
--   RITUAL HUB - NEON GLASS EDITION (v3.0)
--   Blox Fruits | All Grinding Features (No PvP)
--   Sea-aware Teleports | Anti-Cheat Tweens | English
-- ============================================================

-- ============================================================
--                     INITIALIZATION
-- ============================================================
local player = game:GetService("Players").LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")
local TweenService = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")

-- ============================================================
--                     GLOBAL TOGGLES
-- ============================================================
_G.Ritual = {
    Farm = false,
    Quest = false,
    Collect = false,
    SeaBeast = false,
    ShipFarm = false,
    Raid = false,
    Dungeon = false,
    FruitSniper = false,
    ESP = false,
    AutoStats = false,
    AntiAFK = true,
}

-- ============================================================
--                HELPER: SAFE TWEEN
-- ============================================================
function tweenTo(pos, speed)
    speed = speed or 150
    if not rootPart then return end
    local dist = (pos - rootPart.Position).magnitude
    if dist < 3 then return end
    local dur = math.clamp(dist / speed, 0.2, 8)
    local tween = TweenService:Create(rootPart, TweenInfo.new(dur, Enum.EasingStyle.Linear), {CFrame = CFrame.new(pos)})
    tween:Play()
    tween.Completed:Wait()
end

-- ============================================================
--                ENEMY DETECTION & ATTACK
-- ============================================================
function getNearestEnemy(range)
    range = range or 500
    local closest, bestDist = nil, math.huge
    for _, v in pairs(workspace:GetChildren()) do
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

function attackTarget(target)
    if not target or not rootPart then return end
    local hrp = target:FindFirstChild("HumanoidRootPart")
    if hrp then
        local pos = hrp.Position + Vector3.new(0, 5, 2)
        tweenTo(pos, 120)
        wait(0.15)
        local tool = character:FindFirstChildOfClass("Tool")
        if tool then tool:Activate() else humanoid:StartAttack(0.5) end
    end
end

-- ============================================================
--                  SEA DETECTION
-- ============================================================
function getSea()
    local p = rootPart.Position
    if p.X < 1000 and p.Z < 3000 then return "1st" end
    if p.X > 2000 and p.Z < 2000 then return "2nd" end
    if p.X > 3000 and p.Z > 1000 then return "3rd" end
    return "?"
end

-- ============================================================
--              ISLAND COORDINATES (BY SEA)
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
--              NEON GLASS UI - HORIZONTAL
-- ============================================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "RitualHub"
screenGui.Parent = CoreGui
screenGui.ResetOnSpawn = false

-- Background Blur (for glass effect)
local blur = Instance.new("BlurEffect")
blur.Size = 0
blur.Parent = Lighting

-- Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 780, 0, 120)
mainFrame.Position = UDim2.new(0.5, -390, 0, 5)
mainFrame.BackgroundColor3 = Color3.fromRGB(10, 8, 25)
mainFrame.BackgroundTransparency = 0.2
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

-- Glowing Border (animated gradient)
local border = Instance.new("Frame")
border.Size = UDim2.new(1, 0, 1, 0)
border.BackgroundTransparency = 1
border.BorderSizePixel = 0
border.Parent = mainFrame

local borderGrad = Instance.new("UIGradient")
borderGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 80, 255)),
    ColorSequenceKeypoint.new(0.3, Color3.fromRGB(80, 180, 255)),
    ColorSequenceKeypoint.new(0.7, Color3.fromRGB(255, 180, 80)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 80, 255))
})
borderGrad.Rotation = 0
borderGrad.Parent = border

-- Animate the border rotation
spawn(function()
    while wait(0.05) do
        borderGrad.Rotation = (borderGrad.Rotation + 0.5) % 360
    end
end)

-- Actual glass background (with slight transparency)
local glass = Instance.new("Frame")
glass.Size = UDim2.new(1, -4, 1, -4)
glass.Position = UDim2.new(0, 2, 0, 2)
glass.BackgroundColor3 = Color3.fromRGB(15, 12, 35)
glass.BackgroundTransparency = 0.25
glass.BorderSizePixel = 0
glass.Parent = mainFrame

-- Title + Sea + Stats (top row)
local title = Instance.new("TextLabel")
title.Size = UDim2.new(0, 80, 0, 28)
title.Position = UDim2.new(0, 10, 0, 5)
title.BackgroundTransparency = 1
title.Text = "⚡RITUAL"
title.TextColor3 = Color3.fromRGB(255, 200, 100)
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.Parent = glass

local seaLabel = Instance.new("TextLabel")
seaLabel.Size = UDim2.new(0, 45, 0, 28)
seaLabel.Position = UDim2.new(0, 95, 0, 5)
seaLabel.BackgroundTransparency = 1
seaLabel.Text = "🌊 "..getSea()
seaLabel.TextColor3 = Color3.fromRGB(100, 220, 255)
seaLabel.TextScaled = true
seaLabel.Font = Enum.Font.GothamMedium
seaLabel.Parent = glass

local statsLabel = Instance.new("TextLabel")
statsLabel.Size = UDim2.new(0, 200, 0, 28)
statsLabel.Position = UDim2.new(0, 150, 0, 5)
statsLabel.BackgroundTransparency = 1
statsLabel.Text = "Lv.0  $0  🍎None  💎0"
statsLabel.TextColor3 = Color3.fromRGB(220, 220, 255)
statsLabel.TextScaled = true
statsLabel.Font = Enum.Font.GothamMedium
statsLabel.Parent = glass

-- Minimize / Close (neon buttons)
local function createNeonButton(text, posX, color, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 32, 0, 28)
    btn.Position = UDim2.new(1, posX, 0, 5)
    btn.BackgroundColor3 = color
    btn.BackgroundTransparency = 0.3
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.TextScaled = true
    btn.Font = Enum.Font.GothamBold
    btn.BorderSizePixel = 1
    btn.BorderColor3 = color
    btn.Parent = glass
    btn.MouseButton1Click:Connect(callback)
    return btn
end

local minBtn = createNeonButton("−", -70, Color3.fromRGB(100, 60, 200), function()
    minimized = not minimized
    if minimized then
        mainFrame:TweenSize(UDim2.new(0, 180, 0, 32), "Out", "Quad", 0.25, true)
        minBtn.Text = "+"
        for _, c in pairs(glass:GetChildren()) do
            if c ~= title and c ~= seaLabel and c ~= statsLabel and c ~= minBtn and c ~= closeBtn then
                c.Visible = false
            end
        end
    else
        mainFrame:TweenSize(UDim2.new(0, 780, 0, 120), "Out", "Quad", 0.25, true)
        minBtn.Text = "−"
        for _, c in pairs(glass:GetChildren()) do
            c.Visible = true
        end
    end
end)

local closeBtn = createNeonButton("✕", -35, Color3.fromRGB(200, 40, 40), function()
    screenGui:Destroy()
end)

local minimized = false

-- Teleport Button (opens teleport panel)
local teleBtn = Instance.new("TextButton")
teleBtn.Size = UDim2.new(0, 50, 0, 28)
teleBtn.Position = UDim2.new(1, -125, 0, 5)
teleBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 120)
teleBtn.BackgroundTransparency = 0.3
teleBtn.Text = "🗺️"
teleBtn.TextColor3 = Color3.fromRGB(255,255,255)
teleBtn.TextScaled = true
teleBtn.Font = Enum.Font.GothamBold
teleBtn.BorderSizePixel = 1
teleBtn.BorderColor3 = Color3.fromRGB(100, 80, 255)
teleBtn.Parent = glass

-- ============================================================
--           TOGGLE BUTTONS (two rows, neon style)
-- ============================================================
local toggleList = {
    {"Farm", "Farm"},
    {"Quest", "Quest"},
    {"Collect", "Collect"},
    {"SeaBeast", "SeaBeast"},
    {"Ship", "ShipFarm"},
    {"Raid", "Raid"},
    {"Dungeon", "Dungeon"},
    {"Sniper", "FruitSniper"},
    {"ESP", "ESP"},
    {"Stats", "AutoStats"},
    {"AntiAFK", "AntiAFK"}
}

local btnW = 62
local gap = 4
local startX = 5
local row1Y = 45
local row2Y = 78

for i, data in ipairs(toggleList) do
    local label = data[1]
    local ref = data[2]
    local row = (i <= 6) and 1 or 2
    local col = (i <= 6) and i or (i-6)
    local x = startX + (col-1) * (btnW + gap)
    local y = (row == 1) and row1Y or row2Y
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, btnW, 0, 30)
    btn.Position = UDim2.new(0, x, 0, y)
    btn.BackgroundColor3 = _G.Ritual[ref] and Color3.fromRGB(40, 200, 40) or Color3.fromRGB(50, 50, 90)
    btn.BackgroundTransparency = 0.2
    btn.Text = label
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.TextScaled = true
    btn.Font = Enum.Font.GothamBold
    btn.BorderSizePixel = 1
    btn.BorderColor3 = _G.Ritual[ref] and Color3.fromRGB(100,255,100) or Color3.fromRGB(100,80,220)
    btn.Parent = glass
    btn.MouseButton1Click:Connect(function()
        local newState = not _G.Ritual[ref]
        _G.Ritual[ref] = newState
        btn.BackgroundColor3 = newState and Color3.fromRGB(40,200,40) or Color3.fromRGB(50,50,90)
        btn.BorderColor3 = newState and Color3.fromRGB(100,255,100) or Color3.fromRGB(100,80,220)
    end)
    -- Hover glow
    btn.MouseEnter:Connect(function()
        btn.BackgroundTransparency = 0.05
        btn.BorderSizePixel = 2
    end)
    btn.MouseLeave:Connect(function()
        btn.BackgroundTransparency = 0.2
        btn.BorderSizePixel = 1
    end)
end

-- ============================================================
--              TELEPORT PANEL (Pop-up)
-- ============================================================
local telePanel = Instance.new("Frame")
telePanel.Size = UDim2.new(0, 320, 0, 270)
telePanel.Position = UDim2.new(0.5, -160, 0.5, -135)
telePanel.BackgroundColor3 = Color3.fromRGB(12, 8, 28)
telePanel.BackgroundTransparency = 0.15
telePanel.BorderSizePixel = 2
telePanel.BorderColor3 = Color3.fromRGB(120, 60, 255)
telePanel.Visible = false
telePanel.Active = true
telePanel.Draggable = true
telePanel.Parent = screenGui

-- Title bar with gradient
local teleTitleBar = Instance.new("Frame")
teleTitleBar.Size = UDim2.new(1, 0, 0, 35)
teleTitleBar.BackgroundColor3 = Color3.fromRGB(30, 20, 70)
teleTitleBar.BackgroundTransparency = 0.3
teleTitleBar.BorderSizePixel = 0
teleTitleBar.Parent = telePanel

local teleTitle = Instance.new("TextLabel")
teleTitle.Size = UDim2.new(1, -35, 1, 0)
teleTitle.Position = UDim2.new(0, 5, 0, 0)
teleTitle.BackgroundTransparency = 1
teleTitle.Text = "🗺️ Teleports (1st Sea)"
teleTitle.TextColor3 = Color3.fromRGB(255, 200, 100)
teleTitle.TextScaled = true
teleTitle.Font = Enum.Font.GothamBold
teleTitle.Parent = teleTitleBar

local closeTele = Instance.new("TextButton")
closeTele.Size = UDim2.new(0, 30, 1, 0)
closeTele.Position = UDim2.new(1, -30, 0, 0)
closeTele.BackgroundColor3 = Color3.fromRGB(200,40,40)
closeTele.BackgroundTransparency = 0.3
closeTele.Text = "✕"
closeTele.TextColor3 = Color3.fromRGB(255,255,255)
closeTele.TextScaled = true
closeTele.Font = Enum.Font.GothamBold
closeTele.BorderSizePixel = 0
closeTele.Parent = teleTitleBar
closeTele.MouseButton1Click:Connect(function() telePanel.Visible = false end)

-- Scrollable frame for buttons
local teleScroll = Instance.new("ScrollingFrame")
teleScroll.Size = UDim2.new(1, 0, 1, -35)
teleScroll.Position = UDim2.new(0, 0, 0, 35)
teleScroll.BackgroundTransparency = 1
teleScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
teleScroll.ScrollBarThickness = 4
teleScroll.Parent = telePanel

teleBtn.MouseButton1Click:Connect(function()
    telePanel.Visible = not telePanel.Visible
    updateTeleports()
end)

-- Function to update teleport buttons based on current sea
local function updateTeleports()
    for _, child in pairs(teleScroll:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    local sea = getSea()
    teleTitle.Text = "🗺️ Teleports ("..sea.." Sea)"
    local locs = islands[sea] or {}
    local y = 5
    for _, loc in ipairs(locs) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0.9, 0, 0, 38)
        btn.Position = UDim2.new(0.05, 0, 0, y)
        btn.BackgroundColor3 = Color3.fromRGB(40, 35, 80)
        btn.BackgroundTransparency = 0.2
        btn.Text = loc[1]
        btn.TextColor3 = Color3.fromRGB(255,255,255)
        btn.TextScaled = true
        btn.Font = Enum.Font.GothamMedium
        btn.BorderSizePixel = 1
        btn.BorderColor3 = Color3.fromRGB(100, 80, 220)
        btn.Parent = teleScroll
        btn.MouseButton1Click:Connect(function()
            tweenTo(loc[2] + Vector3.new(0, 15, 0), 200)
            telePanel.Visible = false
        end)
        y = y + 44
    end
    teleScroll.CanvasSize = UDim2.new(0, 0, 0, y + 10)
end

-- Update teleports every 3 seconds (sea change)
spawn(function()
    while wait(3) do
        updateTeleports()
    end
end)

-- ============================================================
--                  STATS UPDATE LOOP
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
--                  ALL FEATURE LOOPS
-- ============================================================

-- 1. Auto Farm
spawn(function()
    while wait(0.1) do
        if _G.Ritual.Farm and character and rootPart then
            pcall(function()
                local enemy = getNearestEnemy(500)
                if enemy then attackTarget(enemy) end
            end)
        end
    end
end)

-- 2. Auto Quest
function getQuestNPC()
    local lvl = player:FindFirstChild("Data") and player.Data:FindFirstChild("Level") and player.Data.Level.Value or 0
    local names = {"Pirate", "Monkey", "Soldier", "Bandit", "Mob Leader", "Marine", "Raider"}
    for _, name in pairs(names) do
        for _, v in pairs(workspace:GetChildren()) do
            if v:IsA("Model") and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") then
                if string.find(v.Name:lower(), name:lower()) then
                    return v
                end
            end
        end
    end
    return nil
end

spawn(function()
    while wait(1) do
        if _G.Ritual.Quest and character and rootPart then
            pcall(function()
                local npc = getQuestNPC()
                if npc then
                    local npcPos = npc.HumanoidRootPart.Position
                    if (rootPart.Position - npcPos).magnitude > 15 then
                        tweenTo(npcPos + Vector3.new(0, 5, 3), 100)
                    end
                    wait(0.3)
                    tweenTo(npcPos + Vector3.new(0, 5, 0), 50)
                    wait(0.2)
                end
            end)
        end
    end
end)

-- 3. Auto Collect
spawn(function()
    while wait(0.3) do
        if _G.Ritual.Collect and character and rootPart then
            pcall(function()
                for _, v in pairs(workspace:GetChildren()) do
                    if v:IsA("Tool") or (v:IsA("Part") and (v.Name:find("Fruit") or v.Name:find("Money") or v.Name:find("Chest"))) then
                        local pos = v:IsA("Tool") and v:FindFirstChild("Handle") and v.Handle.Position or (v:IsA("Part") and v.Position)
                        if pos and (pos - rootPart.Position).magnitude < 150 then
                            tweenTo(pos + Vector3.new(0, 3, 0), 80)
                            wait(0.1)
                        end
                    end
                end
            end)
        end
    end
end)

-- 4. Auto Sea Beast
spawn(function()
    while wait(1) do
        if _G.Ritual.SeaBeast and character then
            pcall(function()
                for _, v in pairs(workspace:GetChildren()) do
                    if v:IsA("Model") and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") then
                        if v.Name:lower():find("sea") or v.Name:lower():find("beast") then
                            local dist = (rootPart.Position - v.HumanoidRootPart.Position).magnitude
                            if dist < 800 then
                                attackTarget(v)
                            else
                                tweenTo(v.HumanoidRootPart.Position + Vector3.new(0, 20, 50), 200)
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- 5. Auto Ship Farm
spawn(function()
    while wait(1) do
        if _G.Ritual.ShipFarm and character then
            pcall(function()
                for _, v in pairs(workspace:GetChildren()) do
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

-- 6. Auto Raid
spawn(function()
    while wait(1) do
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
                            tweenTo(center.Position + Vector3.new(0, 10, 0), 150)
                        end
                    end
                else
                    tweenTo(Vector3.new(-100, 20, -50) + Vector3.new(0, 5, 0), 200)
                end
            end)
        end
    end
end)

-- 7. Auto Dungeon
spawn(function()
    while wait(1) do
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
                            tweenTo(part.Position + Vector3.new(0, 10, 5), 150)
                        end
                    end
                else
                    tweenTo(Vector3.new(2800, 10, -1300) + Vector3.new(0, 5, 0), 200)
                end
            end)
        end
    end
end)

-- 8. Fruit Sniper
spawn(function()
    while wait(0.5) do
        if _G.Ritual.FruitSniper and character and rootPart then
            pcall(function()
                for _, v in pairs(workspace:GetChildren()) do
                    if v:IsA("Tool") and v:FindFirstChild("Handle") then
                        if v.Name:lower():find("fruit") then
                            local pos = v.Handle.Position
                            if pos and (pos - rootPart.Position).magnitude < 600 then
                                tweenTo(pos + Vector3.new(0, 3, 0), 120)
                                wait(0.2)
                                tweenTo(pos + Vector3.new(0, 2, 0), 60)
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- 9. ESP
spawn(function()
    while wait(0.5) do
        if _G.Ritual.ESP then
            pcall(function()
                for _, v in pairs(workspace:GetChildren()) do
                    if v:IsA("Tool") or (v:IsA("Part") and (v.Name:find("Chest") or v.Name:find("Fruit"))) then
                        local isFruit = v.Name:lower():find("fruit") or (v:IsA("Tool") and v:FindFirstChild("Handle"))
                        local isChest = v.Name:lower():find("chest")
                        if isFruit or isChest then
                            if not v:FindFirstChild("RitualESP") then
                                local h = Instance.new("Highlight")
                                h.Name = "RitualESP"
                                h.FillColor = isFruit and Color3.fromRGB(255,50,50) or Color3.fromRGB(255,255,0)
                                h.FillTransparency = 0.4
                                h.OutlineColor = Color3.fromRGB(255,255,255)
                                h.Parent = v
                            end
                        end
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

-- 10. Auto Stats
spawn(function()
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

-- 11. Anti AFK
spawn(function()
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

print("⚡ Ritual Hub (Neon Glass Edition) loaded successfully!")
