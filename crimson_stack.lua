-- ============================================================
-- CRIMSON STACK — Unified Combat Suite
-- v2.0 — Loadable via HttpGet
-- Target: TSB-style Roblox fighting games
-- ============================================================
-- Loader line (after hosting):
-- loadstring(game:HttpGet("https://raw.githubusercontent.com/YOUR_USER/YOUR_REPO/main/crimson_stack.lua"))()
-- ============================================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer

-- ===== UI CONSTRUCTION =====

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = string.char(math.random(97,122), math.random(97,122), math.random(97,122))
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 9999

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 320, 0, 560)
MainFrame.Position = UDim2.new(0.5, -160, 0.5, -280)
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 8, 14)
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.Active = true
MainFrame.Parent = ScreenGui

local mainCorner = Instance.new("UICorner", MainFrame)
mainCorner.CornerRadius = UDim.new(0, 8)

local mainStroke = Instance.new("UIStroke", MainFrame)
mainStroke.Color = Color3.fromRGB(120, 20, 40)
mainStroke.Thickness = 2
mainStroke.Transparency = 0.2

local TitleBar = Instance.new("Frame", MainFrame)
TitleBar.Size = UDim2.new(1, 0, 0, 36)
TitleBar.BackgroundColor3 = Color3.fromRGB(20, 12, 22)
TitleBar.BorderSizePixel = 0

local titleCorner = Instance.new("UICorner", TitleBar)
titleCorner.CornerRadius = UDim.new(0, 8)

local Title = Instance.new("TextLabel", TitleBar)
Title.Text = "CRIMSON STACK"
Title.Size = UDim2.new(1, -20, 1, 0)
Title.Position = UDim2.new(0, 12, 0, 0)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.fromRGB(200, 50, 70)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left

local StatusDot = Instance.new("Frame", TitleBar)
StatusDot.Size = UDim2.new(0, 8, 0, 8)
StatusDot.Position = UDim2.new(1, -16, 0.5, -4)
StatusDot.BackgroundColor3 = Color3.fromRGB(80, 200, 120)
StatusDot.BorderSizePixel = 0
local dotCorner = Instance.new("UICorner", StatusDot)
dotCorner.CornerRadius = UDim.new(1, 0)

local Notification = Instance.new("TextLabel", MainFrame)
Notification.Text = ""
Notification.Size = UDim2.new(1, -20, 0, 18)
Notification.Position = UDim2.new(0, 10, 1, -22)
Notification.BackgroundTransparency = 1
Notification.TextColor3 = Color3.fromRGB(160, 160, 170)
Notification.Font = Enum.Font.Gotham
Notification.TextSize = 12
Notification.TextXAlignment = Enum.TextXAlignment.Left
Notification.Visible = false

local function notify(text, duration)
    Notification.Text = text
    Notification.Visible = true
    task.delay(duration or 2.5, function()
        Notification.Visible = false
    end)
end

-- ===== HELPER FUNCTIONS =====

local function makeSlider(parent, labelText, default, yPos, minVal, maxVal)
    local label = Instance.new("TextLabel", parent)
    label.Text = labelText .. ": " .. tostring(default)
    label.Position = UDim2.new(0, 12, 0, yPos)
    label.Size = UDim2.new(0, 180, 0, 22)
    label.TextColor3 = Color3.fromRGB(220, 220, 225)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Gotham
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left

    local box = Instance.new("TextBox", parent)
    box.Position = UDim2.new(1, -60, 0, yPos)
    box.Size = UDim2.new(0, 48, 0, 22)
    box.Text = tostring(default)
    box.TextColor3 = Color3.fromRGB(255, 255, 255)
    box.BackgroundColor3 = Color3.fromRGB(35, 20, 28)
    box.BorderSizePixel = 0
    box.Font = Enum.Font.Gotham
    box.TextSize = 13
    local bc = Instance.new("UICorner", box)
    bc.CornerRadius = UDim.new(0, 4)

    local current = default
    local function validate(text)
        local n = tonumber(text)
        if not n then return nil end
        if n < minVal then n = minVal end
        if n > maxVal then n = maxVal end
        return n
    end

    box:GetPropertyChangedSignal("Text"):Connect(function()
        local n = validate(box.Text)
        if n then
            current = n
            label.Text = labelText .. ": " .. tostring(n)
        end
    end)

    box.FocusLost:Connect(function()
        local n = validate(box.Text)
        if n then
            box.Text = tostring(n)
            current = n
            label.Text = labelText .. ": " .. tostring(n)
        else
            box.Text = tostring(current)
            label.Text = labelText .. ": " .. tostring(current)
        end
    end)

    return {
        label = label, box = box,
        get = function() return current end
    }
end

local function makeToggle(parent, labelText, yPos, onEnable, onDisable)
    local enabled = false
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(1, -24, 0, 32)
    btn.Position = UDim2.new(0, 12, 0, yPos)
    btn.BackgroundColor3 = Color3.fromRGB(30, 18, 25)
    btn.Text = labelText .. ": OFF"
    btn.TextColor3 = Color3.fromRGB(200, 70, 90)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false

    local bc = Instance.new("UICorner", btn)
    bc.CornerRadius = UDim.new(0, 6)

    local bs = Instance.new("UIStroke", btn)
    bs.Color = Color3.fromRGB(60, 30, 40)
    bs.Thickness = 1

    btn.MouseButton1Click:Connect(function()
        enabled = not enabled
        if enabled then
            btn.BackgroundColor3 = Color3.fromRGB(45, 90, 60)
            btn.TextColor3 = Color3.fromRGB(220, 240, 220)
            btn.Text = labelText .. ": ON"
            if onEnable then onEnable() end
        else
            btn.BackgroundColor3 = Color3.fromRGB(30, 18, 25)
            btn.TextColor3 = Color3.fromRGB(200, 70, 90)
            btn.Text = labelText .. ": OFF"
            if onDisable then onDisable() end
        end
    end)

    return {
        button = btn,
        isEnabled = function() return enabled end
    }
end

-- ===== EMBER EFFECT =====
local function createEmber()
    local ember = Instance.new("TextLabel", MainFrame)
    ember.Text = "•"
    ember.Size = UDim2.new(0, 12, 0, 12)
    ember.BackgroundTransparency = 1
    ember.TextColor3 = Color3.fromRGB(
        math.random(140, 200),
        math.random(40, 80),
        math.random(30, 60)
    )
    ember.TextTransparency = math.random(0, 0.4)
    ember.Font = Enum.Font.GothamBold
    ember.TextSize = 14
    ember.ZIndex = 1

    local startX = math.random(8, 312)
    ember.Position = UDim2.new(0, startX, 0, MainFrame.Size.Y.Offset)

    task.spawn(function()
        local drift = math.random(-15, 15)
        for i = 1, 200 do
            if not ember.Parent then break end
            ember.Position = UDim2.new(
                0, startX + (drift * (i / 200)),
                0, MainFrame.Size.Y.Offset - (i * 1.8)
            )
            ember.TextTransparency = i / 200
            task.wait(0.025)
        end
        if ember.Parent then ember:Destroy() end
    end)
end

task.spawn(function()
    while MainFrame and MainFrame.Parent do
        if MainFrame.Visible then createEmber() end
        task.wait(0.6)
    end
end)

-- ===== SECTION LABEL HELPER =====
local yCursor = 50
local function sectionLabel(text)
    local lbl = Instance.new("TextLabel", MainFrame)
    lbl.Text = "─ " .. text .. " ─"
    lbl.Position = UDim2.new(0, 12, 0, yCursor)
    lbl.Size = UDim2.new(1, -24, 0, 18)
    lbl.TextColor3 = Color3.fromRGB(140, 60, 80)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 11
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    yCursor = yCursor + 22
end

-- ============================================================
-- HITBOX SECTION
-- ============================================================
sectionLabel("HITBOX")

local sizeSlider = makeSlider(MainFrame, "Size", 3, yCursor, 1, 20)
yCursor = yCursor + 28
local transparencySlider = makeSlider(MainFrame, "Transparency", 0.5, yCursor, 0, 1)
yCursor = yCursor + 28

local whitelist = {}
local originalProps = {}
local hbEnabled = false

local function storeOriginal(player)
    if not player.Character then return end
    local root = player.Character:FindFirstChild("HumanoidRootPart")
    if root and not originalProps[player] then
        originalProps[player] = {
            Size = root.Size,
            Transparency = root.Transparency,
            CanCollide = root.CanCollide,
            CanTouch = root.CanTouch,
            CanQuery = root.CanQuery
        }
    end
end

local function restorePlayer(player)
    local props = originalProps[player]
    if props and player.Character then
        local root = player.Character:FindFirstChild("HumanoidRootPart")
        if root then
            root.Size = props.Size
            root.Transparency = props.Transparency
            root.CanCollide = props.CanCollide
            root.CanTouch = props.CanTouch
            root.CanQuery = props.CanQuery
        end
    end
end

local function applyHitbox(player)
    if player == LocalPlayer then return end
    if not whitelist[player] then return end
    if not player.Character then return end
    local root = player.Character:FindFirstChild("HumanoidRootPart")
    local hum = player.Character:FindFirstChildOfClass("Humanoid")
    if not root or not hum or hum.Health <= 0 then return end
    storeOriginal(player)
    local sz = sizeSlider.get()
    root.Size = Vector3.new(sz, sz, sz)
    root.Transparency = transparencySlider.get()
    root.CanCollide = false
    root.CanTouch = true
    root.CanQuery = true
    for _, part in ipairs(player.Character:GetChildren()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            part.CanCollide = false
        end
    end
end

local function checkKnocked(player)
    local live = Workspace:FindFirstChild("Live")
    if not live then return true end
    local entry = live:FindFirstChild(player.Name)
    if not entry then return true end
    local knocked = entry:FindFirstChild("Knocked")
    if knocked and knocked:IsA("BoolValue") and knocked.Value then
        return false
    end
    return true
end

local function evaluatePlayer(player)
    if player == LocalPlayer then return end
    if not player.Character then return end
    local hum = player.Character:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then
        whitelist[player] = nil
        restorePlayer(player)
        return
    end
    if checkKnocked(player) then
        whitelist[player] = true
        applyHitbox(player)
    else
        whitelist[player] = nil
        restorePlayer(player)
    end
end

local playerConns = {}
local function monitor(player)
    playerConns[player] = playerConns[player] or {}
    local conns = playerConns[player]
    local function charSetup(char)
        local hum = char:WaitForChild("Humanoid", 5)
        if not hum then return end
        if conns.health then conns.health:Disconnect() end
        if conns.died then conns.died:Disconnect() end
        conns.health = hum.HealthChanged:Connect(function() evaluatePlayer(player) end)
        conns.died = hum.Died:Connect(function()
            whitelist[player] = nil
            restorePlayer(player)
        end)
        evaluatePlayer(player)
    end
    if player.Character then charSetup(player.Character) end
    conns.charAdded = player.CharacterAdded:Connect(charSetup)
end

Players.PlayerAdded:Connect(monitor)
Players.PlayerRemoving:Connect(function(p)
    whitelist[p] = nil
    restorePlayer(p)
    if playerConns[p] then
        for _, c in pairs(playerConns[p]) do
            if c and c.Disconnect then pcall(c.Disconnect, c) end
        end
    end
    playerConns[p] = nil
end)
for _, p in ipairs(Players:GetPlayers()) do monitor(p) end

task.spawn(function()
    while true do
        if hbEnabled then
            for _, p in ipairs(Players:GetPlayers()) do evaluatePlayer(p) end
        end
        task.wait(0.5)
    end
end)

local hbToggle = makeToggle(MainFrame, "Hitbox Expander", yCursor,
    function()
        hbEnabled = true
        notify("Hitbox enabled")
        for _, p in ipairs(Players:GetPlayers()) do applyHitbox(p) end
    end,
    function()
        hbEnabled = false
        for p, _ in pairs(whitelist) do restorePlayer(p) end
        whitelist = {}
        notify("Hitbox disabled")
    end
)
yCursor = yCursor + 38

sizeSlider.box:GetPropertyChangedSignal("Text"):Connect(function()
    for _, p in ipairs(Players:GetPlayers()) do applyHitbox(p) end
end)
transparencySlider.box:GetPropertyChangedSignal("Text"):Connect(function()
    for _, p in ipairs(Players:GetPlayers()) do applyHitbox(p) end
end)

-- ============================================================
-- COMBAT SECTION
-- ============================================================
sectionLabel("COMBAT")

local punchIds = {
    ["rbxassetid://18312333191"] = true,
    ["rbxassetid://18312335714"] = true,
    ["rbxassetid://18312338197"] = true,
    ["rbxassetid://18312340119"] = true,
    ["rbxassetid://18312344029"] = true,
    ["rbxassetid://18312346524"] = true,
    ["rbxassetid://18312348771"] = true,
    ["rbxassetid://18312351760"] = true,
    ["rbxassetid://507768375"] = true,
    ["rbxassetid://507768442"] = true,
}

local stompIds = {
    ["rbxassetid://18312357156"] = true,
    ["rbxassetid://18312358234"] = true,
    ["rbxassetid://18312359891"] = true,
    ["rbxassetid://129867478"] = true,
}

local function isPunchTrack(track)
    if not track or not track.Animation then return false end
    return punchIds[tostring(track.Animation.AnimationId):lower()] or false
end

local function isStompTrack(track)
    if not track or not track.Animation then return false end
    return stompIds[tostring(track.Animation.AnimationId):lower()] or false
end

local function getLocalChar()
    local live = Workspace:FindFirstChild("Live")
    if not live then return nil end
    local model = live:FindFirstChild(LocalPlayer.Name)
    if not model then return nil end
    local hum = model:FindFirstChildOfClass("Humanoid")
    local anim = hum and hum:FindFirstChildOfClass("Animator")
    return model, hum, anim
end

-- Smooth speed ramp (avoids server-side delta flags)
local function smoothAdjustSpeed(track, target)
    if not track or not track.IsPlaying then return end
    local current = track.Speed
    local step = (target - current) / 8
    task.spawn(function()
        for i = 1, 8 do
            if not track or not track.IsPlaying then break end
            pcall(function() track:AdjustSpeed(current + (step * i)) end)
            task.wait(0.02)
        end
        pcall(function() track:AdjustSpeed(target) end)
    end)
end

-- Punch Speed
local punchSlider = makeSlider(MainFrame, "Punch Speed", 1.7, yCursor, 1, 5)
yCursor = yCursor + 28

local punchConns = {}
local function applyPunchSpeed()
    local speed = punchSlider.get()
    local model, hum, anim = getLocalChar()
    if not model then
        if not punchConns.liveWatch then
            punchConns.liveWatch = Workspace.ChildAdded:Connect(function(ch)
                if ch.Name == "Live" then task.defer(applyPunchSpeed) end
            end)
        end
        return
    end
    if punchConns.liveWatch then
        punchConns.liveWatch:Disconnect()
        punchConns.liveWatch = nil
    end
    if anim then
        for _, t in ipairs(anim:GetPlayingAnimationTracks()) do
            if isPunchTrack(t) then smoothAdjustSpeed(t, speed) end
        end
        if punchConns.animChild then punchConns.animChild:Disconnect() end
        punchConns.animChild = anim.ChildAdded:Connect(function(ch)
            if ch:IsA("AnimationTrack") and isPunchTrack(ch) then
                smoothAdjustSpeed(ch, speed)
            end
        end)
    end
    if hum then
        if punchConns.animPlayed then punchConns.animPlayed:Disconnect() end
        punchConns.animPlayed = hum.AnimationPlayed:Connect(function(t)
            if isPunchTrack(t) then smoothAdjustSpeed(t, speed) end
        end)
    end
    if punchConns.ancestry then punchConns.ancestry:Disconnect() end
    punchConns.ancestry = model.AncestryChanged:Connect(function(_, parent)
        if not parent then task.defer(applyPunchSpeed) end
    end)
end

punchSlider.box.FocusLost:Connect(function() pcall(applyPunchSpeed) end)
task.defer(applyPunchSpeed)

-- Stomp Speed
local stompSlider = makeSlider(MainFrame, "Stomp Speed", 1.5, yCursor, 1, 6)
yCursor = yCursor + 28

local stompConns = {}
local function applyStompSpeed()
    local speed = stompSlider.get()
    local model, hum, anim = getLocalChar()
    if not model or not anim then return end
    if stompConns.animChild then stompConns.animChild:Disconnect() end
    if stompConns.animPlayed then stompConns.animPlayed:Disconnect() end
    for _, t in ipairs(anim:GetPlayingAnimationTracks()) do
        if isStompTrack(t) then smoothAdjustSpeed(t, speed) end
    end
    stompConns.animChild = anim.ChildAdded:Connect(function(ch)
        if ch:IsA("AnimationTrack") and isStompTrack(ch) then
            smoothAdjustSpeed(ch, speed)
        end
    end)
    stompConns.animPlayed = hum.AnimationPlayed:Connect(function(t)
        if isStompTrack(t) then smoothAdjustSpeed(t, speed) end
    end)
end

stompSlider.box.FocusLost:Connect(applyStompSpeed)
task.defer(applyStompSpeed)

-- Punch Multiplier
local punchMultSlider = makeSlider(MainFrame, "Punch Multiplier", 1, yCursor, 1, 5)
yCursor = yCursor + 28
local punchMultEnabled = false
local punchMultConns = {}

local function hookPunchMultiplier()
    local live = Workspace:FindFirstChild("Live")
    if not live then
        punchMultConns.liveWatch = Workspace.ChildAdded:Connect(function(ch)
            if ch.Name == "Live" then task.defer(hookPunchMultiplier) end
        end)
        return
    end
    local model = live:FindFirstChild(LocalPlayer.Name)
    if not model then return end
    local hum = model:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    if punchMultConns.animPlayed then punchMultConns.animPlayed:Disconnect() end
    punchMultConns.animPlayed = hum.AnimationPlayed:Connect(function(track)
        if not punchMultEnabled then return end
        if not isPunchTrack(track) then return end
        local mult = math.floor(punchMultSlider.get())
        if mult <= 1 then return end
        task.spawn(function()
            for i = 2, mult do
                task.wait(0.08)
                if punchMultEnabled and track.IsPlaying then
                    pcall(function()
                        local VirtualUser = game:GetService("VirtualUser")
                        VirtualUser:CaptureController()
                        VirtualUser:Button1Down(Vector2.new())
                        task.wait(0.05)
                        VirtualUser:Button1Up(Vector2.new())
                    end)
                end
            end
        end)
    end)
end

task.defer(hookPunchMultiplier)

local punchMultToggle = makeToggle(MainFrame, "Punch Mult", yCursor,
    function() punchMultEnabled = true; notify("Punch multiplier engaged") end,
    function() punchMultEnabled = false; notify("Punch multiplier off") end
)
yCursor = yCursor + 38

-- ============================================================
-- MOVEMENT SECTION
-- ============================================================
sectionLabel("MOVEMENT")

local weaveSlider = makeSlider(MainFrame, "Weave Boost", 4, yCursor, 1, 15)
yCursor = yCursor + 28

local weaveEnabled = false
local weaveToggle = makeToggle(MainFrame, "Weave Extender", yCursor,
    function() weaveEnabled = true; notify("Weave boost active") end,
    function() weaveEnabled = false; notify("Weave boost off") end
)
yCursor = yCursor + 38

local function hookWeave(char)
    local root = char:WaitForChild("HumanoidRootPart", 8)
    if not root then return end
    root.ChildAdded:Connect(function(child)
        if not weaveEnabled then return end
        if child:IsA("BodyPosition") then
            local target = child.Position
            local origin = root.Position
            local delta = target - origin
            local dist = delta.Magnitude
            if dist > 0.1 and dist < 50 then
                local boost = weaveSlider.get()
                pcall(function()
                    child.Position = origin + (delta.Unit * (dist * boost / 2.5))
                end)
            end
        elseif child:IsA("BodyVelocity") then
            local boost = weaveSlider.get()
            pcall(function() child.MaxForce = child.MaxForce * boost end)
        end
    end)
end

if LocalPlayer.Character then hookWeave(LocalPlayer.Character) end
LocalPlayer.CharacterAdded:Connect(hookWeave)

-- Auto Weave (Stun Lock)
local weaveReactSlider = makeSlider(MainFrame, "Weave React Delay", 0.05, yCursor, 0.01, 0.5)
yCursor = yCursor + 28

local autoWeaveEnabled = false

local function triggerWeave()
    pcall(function()
        local VIM = game:GetService("VirtualInputManager")
        VIM:SendKeyEvent(true, Enum.KeyCode.Q, false, game)
        task.wait(0.03)
        VIM:SendKeyEvent(false, Enum.KeyCode.Q, false, game)
    end)
    pcall(function()
        local pg = LocalPlayer:WaitForChild("PlayerGui")
        for _, gui in ipairs(pg:GetChildren()) do
            if gui:IsA("ScreenGui") then
                for _, btn in ipairs(gui:GetDescendants()) do
                    if btn:IsA("TextButton") or btn:IsA("ImageButton") then
                        local name = string.lower(btn.Name)
                        if string.find(name, "dash") or string.find(name, "weave") or string.find(name, "evade") then
                            for _, c in ipairs(getconnections(btn.MouseButton1Click)) do
                                pcall(c.Fire, c)
                            end
                        end
                    end
                end
            end
        end
    end)
end

local function getNearestAttacker()
    local live = Workspace:FindFirstChild("Live")
    if not live then return nil end
    local myModel = live:FindFirstChild(LocalPlayer.Name)
    if not myModel then return nil end
    local myRoot = myModel:FindFirstChild("HumanoidRootPart")
    if not myRoot then return nil end
    local nearest, nearestDist = nil, 25
    for _, entry in ipairs(live:GetChildren()) do
        if entry.Name ~= LocalPlayer.Name then
            local root = entry:FindFirstChild("HumanoidRootPart")
            local hum = entry:FindFirstChildOfClass("Humanoid")
            local anim = hum and hum:FindFirstChildOfClass("Animator")
            if root and hum and anim and hum.Health > 0 then
                local dist = (root.Position - myRoot.Position).Magnitude
                if dist < nearestDist then
                    for _, track in ipairs(anim:GetPlayingAnimationTracks()) do
                        if (isPunchTrack(track) or isStompTrack(track)) and track.TimePosition < 0.3 then
                            nearest = entry
                            nearestDist = dist
                            break
                        end
                    end
                end
            end
        end
    end
    return nearest
end

local autoWeaveThread
local function startAutoWeaveLoop()
    if autoWeaveThread then return end
    autoWeaveThread = task.spawn(function()
        while autoWeaveEnabled do
            local attacker = getNearestAttacker()
            if attacker then
                triggerWeave()
                task.wait(0.4)
            else
                task.wait(0.05)
            end
        end
    end)
end

local function stopAutoWeaveLoop()
    autoWeaveEnabled = false
    if autoWeaveThread then
        pcall(function() task.cancel(autoWeaveThread) end)
        autoWeaveThread = nil
    end
end

-- Watch incoming stuns
task.spawn(function()
    while true do
        local live = Workspace:FindFirstChild("Live")
        if live then
            local model = live:FindFirstChild(LocalPlayer.Name)
            if model then
                if not model:FindFirstChild("CS_StunHook") then
                    local marker = Instance.new("BoolValue")
                    marker.Name = "CS_StunHook"
                    marker.Parent = model
                    model.ChildAdded:Connect(function(child)
                        if not autoWeaveEnabled then return end
                        local name = string.lower(child.Name)
                        if string.find(name, "stun") or string.find(name, "hit")
                            or string.find(name, "daze") or string.find(name, "ragdoll") then
                            task.wait(weaveReactSlider.get())
                            if autoWeaveEnabled then triggerWeave() end
                        end
                    end)
                end
            end
        end
        task.wait(1)
    end
end)

local autoWeaveToggle = makeToggle(MainFrame, "Auto Weave", yCursor,
    function()
        autoWeaveEnabled = true
        startAutoWeaveLoop()
        notify("Stun-lock engaged")
    end,
    function()
        stopAutoWeaveLoop()
        notify("Stun-lock released")
    end
)
yCursor = yCursor + 38

-- Auto Dash
local dashIntervalSlider = makeSlider(MainFrame, "Dash Interval", 2.5, yCursor, 1, 10)
yCursor = yCursor + 28

local autoDashEnabled = false

local function getNearestPlayerForPunch()
    local live = Workspace:FindFirstChild("Live")
    if not live then return nil end
    local myModel = live:FindFirstChild(LocalPlayer.Name)
    if not myModel then return nil end
    local myRoot = myModel:FindFirstChild("HumanoidRootPart")
    if not myRoot then return nil end
    local best, bestDist = nil, 18
    for _, entry in ipairs(live:GetChildren()) do
        if entry.Name ~= LocalPlayer.Name then
            local root = entry:FindFirstChild("HumanoidRootPart")
            local hum = entry:FindFirstChildOfClass("Humanoid")
            if root and hum and hum.Health > 0 then
                local knocked = entry:FindFirstChild("Knocked")
                if not (knocked and knocked:IsA("BoolValue") and knocked.Value) then
                    local dist = (root.Position - myRoot.Position).Magnitude
                    if dist < bestDist then
                        bestDist = dist
                        best = root
                    end
                end
            end
        end
    end
    return best
end

local function triggerDash()
    pcall(function()
        local VIM = game:GetService("VirtualInputManager")
        VIM:SendKeyEvent(true, Enum.KeyCode.W, false, game)
        VIM:SendKeyEvent(true, Enum.KeyCode.Q, false, game)
        task.wait(0.05)
        VIM:SendKeyEvent(false, Enum.KeyCode.Q, false, game)
        task.wait(0.1)
        VIM:SendKeyEvent(false, Enum.KeyCode.W, false, game)
    end)
end

local autoDashThread
local function startAutoDashLoop()
    if autoDashThread then return end
    autoDashThread = task.spawn(function()
        while autoDashEnabled do
            local target = getNearestPlayerForPunch()
            if target then triggerDash() end
            task.wait(dashIntervalSlider.get())
        end
    end)
end

local function stopAutoDashLoop()
    if autoDashThread then
        pcall(function() task.cancel(autoDashThread) end)
        autoDashThread = nil
    end
end

local autoDashToggle = makeToggle(MainFrame, "Auto Dash", yCursor,
    function() autoDashEnabled = true; startAutoDashLoop(); notify("Auto-dash engaged") end,
    function() autoDashEnabled = false; stopAutoDashLoop(); notify("Auto-dash off") end
)
yCursor = yCursor + 38

-- ============================================================
-- DEFENSE SECTION
-- ============================================================
sectionLabel("DEFENSE")

local antiStunEnabled = false
local stunNames = {
    "WeaveStun", "Stun", "Stunned", "HitStun", "Dazed",
    "Ragdoll", "Knocked", "Knockback"
}

local function sweepStuns()
    local live = Workspace:FindFirstChild("Live")
    if not live then return end
    local model = live:FindFirstChild(LocalPlayer.Name)
    if not model then return end
    for _, name in ipairs(stunNames) do
        local obj = model:FindFirstChild(name)
        if obj then pcall(function() obj:Destroy() end) end
    end
end

local stunConn
local function hookStunWatcher()
    if stunConn then stunConn:Disconnect() end
    local live = Workspace:FindFirstChild("Live")
    if not live then
        stunConn = Workspace.ChildAdded:Connect(function(ch)
            if ch.Name == "Live" then task.defer(hookStunWatcher) end
        end)
        return
    end
    local function attachToModel()
        local model = live:FindFirstChild(LocalPlayer.Name)
        if not model then return end
        stunConn = model.ChildAdded:Connect(function(child)
            if not antiStunEnabled then return end
            for _, name in ipairs(stunNames) do
                if child.Name == name then
                    pcall(function() child:Destroy() end)
                    notify("Blocked: " .. name)
                    break
                end
            end
        end)
        model.AncestryChanged:Connect(function(_, parent)
            if not parent then task.defer(hookStunWatcher) end
        end)
    end
    attachToModel()
    live.ChildAdded:Connect(function(ch)
        if ch.Name == LocalPlayer.Name then
            task.wait(0.1)
            attachToModel()
        end
    end)
end

task.spawn(function()
    while true do
        if antiStunEnabled then pcall(sweepStuns) end
        task.wait(0.1)
    end
end)

task.defer(hookStunWatcher)

local antiStunToggle = makeToggle(MainFrame, "Anti-Stun", yCursor,
    function() antiStunEnabled = true; notify("Anti-stun engaged"); sweepStuns() end,
    function() antiStunEnabled = false; notify("Anti-stun released") end
)
yCursor = yCursor + 38

-- Auto Block
local blockReactSlider = makeSlider(MainFrame, "Block React", 0.08, yCursor, 0.01, 0.5)
yCursor = yCursor + 28

local autoBlockEnabled = false

local function triggerBlock(state)
    pcall(function()
        local VIM = game:GetService("VirtualInputManager")
        VIM:SendKeyEvent(state, Enum.KeyCode.F, false, game)
    end)
end

local autoBlockThread
local function startAutoBlockLoop()
    if autoBlockThread then return end
    autoBlockThread = task.spawn(function()
        while autoBlockEnabled do
            local attacker = getNearestAttacker()
            if attacker then
                triggerBlock(true)
                task.wait(0.4)
                triggerBlock(false)
                task.wait(0.3)
            else
                task.wait(0.05)
            end
        end
    end)
end

local function stopAutoBlockLoop()
    if autoBlockThread then
        pcall(function() task.cancel(autoBlockThread) end)
        autoBlockThread = nil
    end
end

local autoBlockToggle = makeToggle(MainFrame, "Auto Block", yCursor,
    function() autoBlockEnabled = true; startAutoBlockLoop(); notify("Auto-block active") end,
    function() autoBlockEnabled = false; stopAutoBlockLoop(); notify("Auto-block off") end
)
yCursor = yCursor + 38

-- ============================================================
-- OFFENSE SECTION
-- ============================================================
sectionLabel("OFFENSE")

local acRangeSlider = makeSlider(MainFrame, "AC Range", 18, yCursor, 5, 40)
yCursor = yCursor + 28

local autoConnectEnabled = false

local function snapToTarget()
    local target = getNearestPlayerForPunch()
    if not target then return end
    local live = Workspace:FindFirstChild("Live")
    local model = live and live:FindFirstChild(LocalPlayer.Name)
    local root = model and model:FindFirstChild("HumanoidRootPart")
    if not root then return end
    pcall(function()
        root.CFrame = CFrame.lookAt(root.Position, target.Position)
    end)
end

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if not autoConnectEnabled then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.KeyCode == Enum.KeyCode.ButtonR2 then
        snapToTarget()
    end
end)

local autoConnectToggle = makeToggle(MainFrame, "Auto Connect", yCursor,
    function() autoConnectEnabled = true; notify("Punches auto-locked") end,
    function() autoConnectEnabled = false; notify("Punch lock off") end
)
yCursor = yCursor + 38

-- Cooldown Bypass
local cdSlider = makeSlider(MainFrame, "M1 Cooldown", 0.3, yCursor, 0.05, 1)
yCursor = yCursor + 28

local cdBypassEnabled = false

local function findCooldownTracker()
    local live = Workspace:FindFirstChild("Live")
    if not live then return nil end
    local model = live:FindFirstChild(LocalPlayer.Name)
    if not model then return nil end
    local names = {"M1Cooldown", "PunchCooldown", "AttackCooldown",
                   "ComboCooldown", "HitCooldown", "Debounce", "LastPunch"}
    for _, name in ipairs(names) do
        local obj = model:FindFirstChild(name)
        if obj then return obj end
    end
    for _, desc in ipairs(model:GetDescendants()) do
        local name = string.lower(desc.Name)
        if string.find(name, "cooldown") or string.find(name, "debounce") then
            return desc
        end
    end
    return nil
end

local cdBypassThread
local function startCDBypassLoop()
    if cdBypassThread then return end
    cdBypassThread = task.spawn(function()
        while cdBypassEnabled do
            local tracker = findCooldownTracker()
            if tracker then
                pcall(function()
                    if tracker:IsA("NumberValue") then tracker.Value = 0
                    elseif tracker:IsA("BoolValue") then tracker.Value = false
                    elseif tracker:IsA("IntValue") then tracker.Value = 0 end
                end)
            end
            task.wait(cdSlider.get())
        end
    end)
end

local function stopCDBypassLoop()
    if cdBypassThread then
        pcall(function() task.cancel(cdBypassThread) end)
        cdBypassThread = nil
    end
end

local cdBypassToggle = makeToggle(MainFrame, "CD Bypass", yCursor,
    function() cdBypassEnabled = true; startCDBypassLoop(); notify("Cooldown bypassed") end,
    function() cdBypassEnabled = false; stopCDBypassLoop(); notify("Cooldown restored") end
)
yCursor = yCursor + 38

-- Auto Crit
local autoCritEnabled = false

local function isCritAvailable()
    local live = Workspace:FindFirstChild("Live")
    if not live then return false end
    local model = live:FindFirstChild(LocalPlayer.Name)
    if not model then return false end
    local critNames = {"CritReady", "CriticalReady", "CanCrit", "CritAvailable", "CritWindow"}
    for _, name in ipairs(critNames) do
        local obj = model:FindFirstChild(name)
        if obj then
            if obj:IsA("BoolValue") and obj.Value then return true end
            if obj:IsA("NumberValue") and obj.Value > 0 then return true end
        end
    end
    return false
end

local function triggerCrit()
    pcall(function()
        local VIM = game:GetService("VirtualInputManager")
        VIM:SendKeyEvent(true, Enum.KeyCode.E, false, game)
        task.wait(0.05)
        VIM:SendKeyEvent(false, Enum.KeyCode.E, false, game)
    end)
end

local autoCritThread
local function startAutoCritLoop()
    if autoCritThread then return end
    autoCritThread = task.spawn(function()
        while autoCritEnabled do
            local target = getNearestPlayerForPunch()
            if target and isCritAvailable() then
                triggerCrit()
                task.wait(0.5)
            else
                task.wait(0.05)
            end
        end
    end)
end

local function stopAutoCritLoop()
    if autoCritThread then
        pcall(function() task.cancel(autoCritThread) end)
        autoCritThread = nil
    end
end

local autoCritToggle = makeToggle(MainFrame, "Auto Crit", yCursor,
    function() autoCritEnabled = true; startAutoCritLoop(); notify("Crit detection active") end,
    function() autoCritEnabled = false; stopAutoCritLoop(); notify("Crit detection off") end
)
yCursor = yCursor + 38

-- ============================================================
-- MISC SECTION
-- ============================================================
sectionLabel("MISC")

local fovSlider = makeSlider(MainFrame, "FOV", 70, yCursor, 1, 120)
yCursor = yCursor + 28

fovSlider.box.FocusLost:Connect(function()
    local cam = Workspace.CurrentCamera
    if cam then
        pcall(function() cam.FieldOfView = fovSlider.get() end)
    end
end)

local fpsToggle = makeToggle(MainFrame, "FPS Boost", yCursor,
    function()
        pcall(function()
            for _, v in ipairs(Workspace:GetDescendants()) do
                if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Beam") then
                    v.Enabled = false
                end
            end
            settings().Rendering.QualityLevel = Enum.QualityLevel.Level02
            notify("Graphics reduced")
        end)
    end,
    function() notify("Restore manually") end
)

-- ============================================================
-- INPUT HANDLING
-- ============================================================

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.M then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

-- Draggable main frame
local dragging = false
local dragStart, startPos

MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement
    or input.UserInputType == Enum.UserInputType.Touch then
        if dragging then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end
end)

-- Mobile open button
local OpenButton = Instance.new("TextButton", ScreenGui)
OpenButton.Size = UDim2.new(0, 50, 0, 50)
OpenButton.Position = UDim2.new(0, 12, 0, 12)
OpenButton.Text = "CS"
OpenButton.BackgroundColor3 = Color3.fromRGB(80, 20, 35)
OpenButton.TextColor3 = Color3.fromRGB(220, 200, 200)
OpenButton.Font = Enum.Font.GothamBold
OpenButton.TextSize = 14
OpenButton.Active = true
OpenButton.Draggable = true

local obCorner = Instance.new("UICorner", OpenButton)
obCorner.CornerRadius = UDim.new(0, 8)
local obStroke = Instance.new("UIStroke", OpenButton)
obStroke.Color = Color3.fromRGB(160, 40, 60)
obStroke.Thickness = 2

OpenButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

local obDragging = false
local obStart, obStartPos

OpenButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch
    or input.UserInputType == Enum.UserInputType.MouseButton1 then
        obDragging = true
        obStart = input.Position
        obStartPos = OpenButton.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                obDragging = false
            end
        end)
    end
end)

OpenButton.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch
    or input.UserInputType == Enum.UserInputType.MouseMovement then
        if obDragging then
            local delta = input.Position - obStart
            OpenButton.Position = UDim2.new(
                obStartPos.X.Scale, obStartPos.X.Offset + delta.X,
                obStartPos.Y.Scale, obStartPos.Y.Offset + delta.Y
            )
        end
    end
end)

-- ============================================================
-- STEALTH LAYER
-- ============================================================

-- Mask instance names
pcall(function()
    for _, name in ipairs({"CrimsonStack", "MainFrame", "ScreenGui"}) do
        local obj = LocalPlayer:FindFirstChild("PlayerGui"):FindFirstChild(name)
        if obj then
            obj.Name = string.char(math.random(97,122), math.random(97,122),
                                     math.random(97,122), math.random(97,122))
        end
    end
end)

-- Remote throttle
local remoteHistory = {}
local function safeRemoteCall(remote, args)
    local now = tick()
    if not remoteHistory[remote] then
        remoteHistory[remote] = {count = 0, windowStart = now}
    end
    local hist = remoteHistory[remote]
    if now - hist.windowStart > 1 then
        hist.windowStart = now
        hist.count = 0
    end
    if hist.count >= 30 then return false end
    hist.count = hist.count + 1
    pcall(function()
        remote:FireServer(table.unpack(args or {}))
    end)
    return true
end

-- Init notification
task.wait(0.5)
notify("Crimson Stack loaded — press M")
