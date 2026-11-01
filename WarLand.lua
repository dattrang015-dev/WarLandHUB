--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then return end

-- ================================================================= --
-- CẤU HÌNH COMBAT
-- ================================================================= --
local CONFIG = {
    AttackDelay = 0.5,        -- Tốc độ đánh: 0.5 giây
    MaxDistance = 100,        -- Khoảng cách quét mục tiêu
    AutoEquip = true,         -- Tự động cầm vũ khí
    AutoHitbox = true,
    HitboxSize = Vector3.new(50, 50, 50),
    HitboxTransparency = 0.8,
}

_G.UniversalCombat = true

local function IsAlive(character): boolean
    local hum = character and character:FindFirstChildOfClass("Humanoid")
    return hum and hum.Health > 0
end

-- Hàm phóng to Hitbox
local function ApplyUniversalHitbox()
    if not CONFIG.AutoHitbox then return end
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart") :: BasePart?
    if not hrp then return end

    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj ~= char then
            local hum = obj:FindFirstChildOfClass("Humanoid")
            local targetHrp = obj:FindFirstChild("HumanoidRootPart") :: BasePart?
            local head = obj:FindFirstChild("Head") :: BasePart?

            if hum and IsAlive(obj) and targetHrp then
                local dist = (targetHrp.Position - hrp.Position).Magnitude
                if dist <= CONFIG.MaxDistance then
                    if targetHrp then
                        targetHrp.Size = CONFIG.HitboxSize
                        targetHrp.Transparency = CONFIG.HitboxTransparency
                        targetHrp.CanCollide = false
                    end
                    if head then
                        head.Size = CONFIG.HitboxSize
                        head.Transparency = CONFIG.HitboxTransparency
                        head.CanCollide = false
                    end
                end
            end
        end
    end
end

-- Hàm tấn công trực tiếp Tool
local function ExecuteCombat()
    local char = LocalPlayer.Character
    if not IsAlive(char) then return end

    local tool = char:FindFirstChildOfClass("Tool")
    if not tool and CONFIG.AutoEquip then
        local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
        if backpack then
            tool = backpack:FindFirstChildOfClass("Tool")
            if tool then tool.Parent = char end
        end
    end

    if tool and tool:IsA("Tool") then
        pcall(function()
            tool:Activate()
            local remote = tool:FindFirstChildOfClass("RemoteEvent")
            if remote then remote:FireServer() end
        end)
    end
end

-- Vòng lặp Combat chạy ngầm
task.spawn(function()
    while true do
        if _G.UniversalCombat then
            pcall(function()
                ExecuteCombat()
                ApplyUniversalHitbox()
            end)
        end
        task.wait(CONFIG.AttackDelay)
    end
end)

-- ================================================================= --
-- GIAO DIỆN UI HUB ĐA TAB (FIX HIỂN THỊ TRÊN MOBILE)
-- ================================================================= --
local function GetGuiParent(): Instance
    local success, result = pcall(function() return CoreGui end)
    if success and result then return result end
    return LocalPlayer:WaitForChild("PlayerGui")
end

local ParentGui = GetGuiParent()
local OldGui = ParentGui:FindFirstChild("MultiTabMobileHubFix")
if OldGui then OldGui:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MultiTabMobileHubFix"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = ParentGui

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 340, 0, 280)
MainFrame.Position = UDim2.new(0.05, 0, 0.2, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 26)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(0, 200, 255)
MainStroke.Thickness = 2
MainStroke.Parent = MainFrame

-- Tiêu đề
local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -40, 0, 35)
TitleLabel.Position = UDim2.new(0, 12, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "⚡ MOBILE HUB (FIXED 3 TABS)"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 13
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = MainFrame

-- Nút thu nhỏ (-)
local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 30, 0, 30)
MinimizeBtn.Position = UDim2.new(1, -35, 0, 3)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
MinimizeBtn.Text = "-"
MinimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeBtn.TextSize = 16
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.Parent = MainFrame

local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0, 6)
MinCorner.Parent = MinimizeBtn

-- Thanh Tab Bar
local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(1, -20, 0, 36)
TabBar.Position = UDim2.new(0, 10, 0, 38)
TabBar.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
TabBar.Parent = MainFrame

local TabBarCorner = Instance.new("UICorner")
TabBarCorner.CornerRadius = UDim.new(0, 6)
TabBarCorner.Parent = TabBar

local TabListLayout = Instance.new("UIListLayout")
TabListLayout.FillDirection = Enum.FillDirection.Horizontal
TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabListLayout.Parent = TabBar -- Đã fix dòng này để các tab hiện ngang hàng chuẩn xác!

-- Khung chứa nội dung các Tab
local Container = Instance.new("Frame")
Container.Size = UDim2.new(1, -20, 1, -86)
Container.Position = UDim2.new(0, 10, 0, 78)
Container.BackgroundColor3 = Color3.fromRGB(25, 25, 38)
Container.BorderSizePixel = 0
Container.Parent = MainFrame

local ContainerCorner = Instance.new("UICorner")
ContainerCorner.CornerRadius = UDim.new(0, 6)
ContainerCorner.Parent = Container

-- Nút nổi thu nhỏ để mở lại menu
local OpenButton = Instance.new("TextButton")
OpenButton.Size = UDim2.new(0, 45, 0, 45)
OpenButton.Position = UDim2.new(0.05, 0, 0.2, 0)
OpenButton.BackgroundColor3 = Color3.fromRGB(18, 18, 26)
OpenButton.Text = "⚡"
OpenButton.TextColor3 = Color3.fromRGB(0, 200, 255)
OpenButton.TextSize = 20
OpenButton.Font = Enum.Font.GothamBold
OpenButton.Visible = false
OpenButton.Active = true
OpenButton.Draggable = true
OpenButton.Parent = ScreenGui

local OpenBtnCorner = Instance.new("UICorner")
OpenBtnCorner.CornerRadius = UDim.new(0, 10)
OpenBtnCorner.Parent = OpenButton

local OpenBtnStroke = Instance.new("UIStroke")
OpenBtnStroke.Color = Color3.fromRGB(0, 200, 255)
OpenBtnStroke.Thickness = 2
OpenBtnStroke.Parent = OpenButton

-- ================================================================= --
-- HÀM TẠO TAB CHUẨN XÁC
-- ================================================================= --
local tabs = {}
local currentActiveTab = nil

local function CreateTab(name: string)
    local tabBtn = Instance.new("TextButton")
    tabBtn.Size = UDim2.new(0.333, 0, 1, 0)
    tabBtn.BackgroundTransparency = 1
    tabBtn.Text = name
    tabBtn.TextColor3 = Color3.fromRGB(160, 160, 160)
    tabBtn.TextSize = 11
    tabBtn.Font = Enum.Font.GothamBold
    tabBtn.Parent = TabBar

    local tabContent = Instance.new("ScrollingFrame")
    tabContent.Size = UDim2.new(1, 0, 1, 0)
    tabContent.BackgroundTransparency = 1
    tabContent.BorderSizePixel = 0
    tabContent.Visible = false
    tabContent.AutomaticCanvasSize = Enum.AutomaticSize.Y
    tabContent.Parent = Container

    local list = Instance.new("UIListLayout")
    list.SortOrder = Enum.SortOrder.LayoutOrder
    list.Padding = UDim.new(0, 8)
    list.Parent = tabContent

    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, 10)
    padding.PaddingBottom = UDim.new(0, 10)
    padding.PaddingLeft = UDim.new(0, 10)
    padding.PaddingRight = UDim.new(0, 10)
    padding.Parent = tabContent

    tabBtn.MouseButton1Click:Connect(function()
        for _, t in pairs(tabs) do
            t.Content.Visible = false
            t.Button.TextColor3 = Color3.fromRGB(160, 160, 160)
        end
        tabContent.Visible = true
        tabBtn.TextColor3 = Color3.fromRGB(0, 200, 255)
    end)

    local tabData = {Button = tabBtn, Content = tabContent}
    table.insert(tabs, tabData)

    if not currentActiveTab then
        currentActiveTab = tabData
        tabContent.Visible = true
        tabBtn.TextColor3 = Color3.fromRGB(0, 200, 255)
    end

    return tabContent
end

-- ================================================================= --
-- NỘI DUNG 3 TAB
-- ================================================================= --

-- [TAB 1]: COMBAT
local CombatTab = CreateTab("⚔️ Combat")

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(1, 0, 0, 42)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(40, 180, 80)
ToggleBtn.Text = "COMBAT: ON"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.TextSize = 12
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.Parent = CombatTab

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 6)
ToggleCorner.Parent = ToggleBtn

ToggleBtn.MouseButton1Click:Connect(function()
    _G.UniversalCombat = not _G.UniversalCombat
    if _G.UniversalCombat then
        ToggleBtn.Text = "COMBAT: ON"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(40, 180, 80)
    else
        ToggleBtn.Text = "COMBAT: OFF"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
    end
end)

local InfoCombat = Instance.new("TextLabel")
InfoCombat.Size = UDim2.new(1, 0, 0, 60)
InfoCombat.BackgroundTransparency = 1
InfoCombat.Text = "• Tốc độ đánh: 0.5s\n• Hitbox: 50x50\n• Tự động cầm vũ khí và quét mục tiêu."
InfoCombat.TextColor3 = Color3.fromRGB(0, 220, 255)
InfoCombat.TextSize = 11
InfoCombat.Font = Enum.Font.GothamMedium
InfoCombat.TextWrapped = true
InfoCombat.Parent = CombatTab

-- [TAB 2]: EVENT SCANNER
local ScannerTab = CreateTab("🔍 Scanner")

local RunScanBtn = Instance.new("TextButton")
RunScanBtn.Size = UDim2.new(1, 0, 0, 38)
RunScanBtn.BackgroundColor3 = Color3.fromRGB(255, 140, 0)
RunScanBtn.Text = "BẮT ĐẦU QUÉT EVENT"
RunScanBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
RunScanBtn.TextSize = 12
RunScanBtn.Font = Enum.Font.GothamBold
RunScanBtn.Parent = ScannerTab

local ScanCorner = Instance.new("UICorner")
ScanCorner.CornerRadius = UDim.new(0, 6)
ScanCorner.Parent = RunScanBtn

local ScrollRes = Instance.new("ScrollingFrame")
ScrollRes.Size = UDim2.new(1, 0, 0, 120)
ScrollRes.BackgroundTransparency = 1
ScrollRes.AutomaticCanvasSize = Enum.AutomaticSize.Y
ScrollRes.Parent = ScannerTab

local ResListLayout = Instance.new("UIListLayout")
ResListLayout.SortOrder = Enum.SortOrder.LayoutOrder
ResListLayout.Padding = UDim.new(0, 4)
ResListLayout.Parent = ScrollRes

local function ScanEvents()
    for _, child in ipairs(ScrollRes:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end

    local foldersToScan = {ReplicatedStorage, workspace}
    local char = LocalPlayer.Character
    if char then table.insert(foldersToScan, char) end

    for _, folder in ipairs(foldersToScan) do
        for _, obj in ipairs(folder:GetDescendants()) do
            if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                local itemFrame = Instance.new("Frame")
                itemFrame.Size = UDim2.new(1, 0, 0, 30)
                itemFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
                itemFrame.Parent = ScrollRes

                local corner = Instance.new("UICorner")
                corner.CornerRadius = UDim.new(0, 4)
                corner.Parent = itemFrame

                local lbl = Instance.new("TextLabel")
                lbl.Size = UDim2.new(1, -6, 1, 0)
                lbl.Position = UDim2.new(0, 3, 0, 0)
                lbl.BackgroundTransparency = 1
                lbl.Text = "["..obj.ClassName.."] "..obj.Name
                lbl.TextColor3 = Color3.fromRGB(0, 255, 150)
                lbl.TextSize = 10
                lbl.Font = Enum.Font.GothamBold
                lbl.TextXAlignment = Enum.TextXAlignment.Left
                lbl.TextWrapped = true
                lbl.Parent = itemFrame
            end
        end
    end
end

RunScanBtn.MouseButton1Click:Connect(function()
    ScanEvents()
end)

-- [TAB 3]: SETTINGS
local SettingsTab = CreateTab("⚙️ Settings")

local InfoLabel = Instance.new("TextLabel")
InfoLabel.Size = UDim2.new(1, 0, 0, 90)
InfoLabel.BackgroundTransparency = 1
InfoLabel.Text = "• Đã fix hiển thị đủ 3 Tab ngang nhau.\n• Bấm nút [-] góc trên phải để thu nhỏ menu.\n• Kéo thả khung mượt mà trên màn hình."
InfoLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
InfoLabel.TextSize = 11
InfoLabel.Font = Enum.Font.GothamMedium
InfoLabel.TextWrapped = true
InfoLabel.Parent = SettingsTab

-- ================================================================= --
-- SỰ KIỆN THU NHỎ / MỞ RỘNG
-- ================================================================= --
MinimizeBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    OpenButton.Visible = true
end)

OpenButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = true
    OpenButton.Visible = false
end)
