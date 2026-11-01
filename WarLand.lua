--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
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
-- GIAO DIỆN UI HUB (TÍCH HỢP CẢ COMBAT & QUÉT EVENT)
-- ================================================================= --
local function GetGuiParent(): Instance
    local success, result = pcall(function() return CoreGui end)
    if success and result then return result end
    return LocalPlayer:WaitForChild("PlayerGui")
end

local ParentGui = GetGuiParent()
local OldGui = ParentGui:FindFirstChild("MasterMobileHub")
if OldGui then OldGui:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MasterMobileHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = ParentGui

-- Main Frame (Giao diện chính)
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 260, 0, 260)
MainFrame.Position = UDim2.new(0.05, 0, 0.25, 0)
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
TitleLabel.Text = "⚡ MASTER COMBAT & EVENT"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 12
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

-- Nút Bật/Tắt Combat
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0.9, 0, 0, 40)
ToggleBtn.Position = UDim2.new(0.05, 0, 0, 42)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(40, 180, 80)
ToggleBtn.Text = "COMBAT: ON"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.TextSize = 13
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.Parent = MainFrame

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 8)
ToggleCorner.Parent = ToggleBtn

-- Nút Mở Tab Quét Event
local OpenScannerBtn = Instance.new("TextButton")
OpenScannerBtn.Size = UDim2.new(0.9, 0, 0, 40)
OpenScannerBtn.Position = UDim2.new(0.05, 0, 0, 90)
OpenScannerBtn.BackgroundColor3 = Color3.fromRGB(255, 140, 0)
OpenScannerBtn.Text = "🔍 MỞ BẢNG QUÉT EVENT"
OpenScannerBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
OpenScannerBtn.TextSize = 13
OpenScannerBtn.Font = Enum.Font.GothamBold
OpenScannerBtn.Parent = MainFrame

local ScanBtnCorner = Instance.new("UICorner")
ScanBtnCorner.CornerRadius = UDim.new(0, 8)
ScanBtnCorner.Parent = OpenScannerBtn

-- Thông tin trạng thái
local InfoLabel = Instance.new("TextLabel")
InfoLabel.Size = UDim2.new(1, -20, 0, 40)
InfoLabel.Position = UDim2.new(0, 10, 0, 138)
InfoLabel.BackgroundTransparency = 1
InfoLabel.Text = "Delay: 0.5s | Hitbox: 50x50\nKéo thả menu thoải mái trên màn hình."
InfoLabel.TextColor3 = Color3.fromRGB(0, 220, 255)
InfoLabel.TextSize = 10
InfoLabel.Font = Enum.Font.GothamMedium
InfoLabel.TextWrapped = true
InfoLabel.Parent = MainFrame

-- Nút nổi thu nhỏ để mở lại menu
local OpenButton = Instance.new("TextButton")
OpenButton.Size = UDim2.new(0, 45, 0, 45)
OpenButton.Position = UDim2.new(0.05, 0, 0.25, 0)
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
OpenButton.Parent = OpenButton

local OpenBtnStroke = Instance.new("UIStroke")
OpenBtnStroke.Color = Color3.fromRGB(0, 200, 255)
OpenBtnStroke.Thickness = 2
OpenBtnStroke.Parent = OpenButton

-- ================================================================= --
-- CỬA SỔ QUÉT EVENT (HIỆN KHI BẤM NÚT)
-- ================================================================= --
local ScannerFrame = Instance.new("Frame")
ScannerFrame.Size = UDim2.new(0, 300, 0, 320)
ScannerFrame.Position = UDim2.new(0.35, 0, 0.2, 0)
ScannerFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 26)
ScannerFrame.BorderSizePixel = 0
ScannerFrame.Active = true
ScannerFrame.Draggable = true
ScannerFrame.Visible = false
ScannerFrame.Parent = ScreenGui

local ScanFrameCorner = Instance.new("UICorner")
ScanFrameCorner.CornerRadius = UDim.new(0, 10)
ScanFrameCorner.Parent = ScannerFrame

local ScanFrameStroke = Instance.new("UIStroke")
ScanFrameStroke.Color = Color3.fromRGB(255, 140, 0)
ScanFrameStroke.Thickness = 2
ScanFrameStroke.Parent = ScannerFrame

local ScanTitle = Instance.new("TextLabel")
ScanTitle.Size = UDim2.new(1, -40, 0, 35)
ScanTitle.Position = UDim2.new(0, 12, 0, 0)
ScanTitle.BackgroundTransparency = 1
ScanTitle.Text = "🔍 DANH SÁCH EVENT TRONG GAME"
ScanTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
ScanTitle.TextSize = 12
ScanTitle.Font = Enum.Font.GothamBold
ScanTitle.TextXAlignment = Enum.TextXAlignment.Left
ScanTitle.Parent = ScannerFrame

local CloseScanBtn = Instance.new("TextButton")
CloseScanBtn.Size = UDim2.new(0, 30, 0, 30)
CloseScanBtn.Position = UDim2.new(1, -35, 0, 3)
CloseScanBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseScanBtn.Text = "X"
CloseScanBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseScanBtn.TextSize = 14
CloseScanBtn.Font = Enum.Font.GothamBold
CloseScanBtn.Parent = ScannerFrame

local CloseScanCorner = Instance.new("UICorner")
CloseScanCorner.CornerRadius = UDim.new(0, 6)
CloseScanCorner.Parent = CloseScanBtn

local ScrollingFrame = Instance.new("ScrollingFrame")
ScrollingFrame.Size = UDim2.new(1, -20, 1, -95)
ScrollingFrame.Position = UDim2.new(0, 10, 0, 40)
ScrollingFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 38)
ScrollingFrame.BorderSizePixel = 0
ScrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
ScrollingFrame.Parent = ScannerFrame

local ScrollCorner = Instance.new("UICorner")
ScrollCorner.CornerRadius = UDim.new(0, 6)
ScrollCorner.Parent = ScrollingFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 5)
UIListLayout.Parent = ScrollingFrame

local RunScanBtn = Instance.new("TextButton")
RunScanBtn.Size = UDim2.new(1, -20, 0, 35)
RunScanBtn.Position = UDim2.new(0, 10, 1, -45)
RunScanBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
RunScanBtn.Text = "QUÉT LẠI (SCAN)"
RunScanBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
RunScanBtn.TextSize = 12
RunScanBtn.Font = Enum.Font.GothamBold
RunScanBtn.Parent = ScannerFrame

local RunScanCorner = Instance.new("UICorner")
RunScanCorner.CornerRadius = UDim.new(0, 6)
RunScanCorner.Parent = RunScanBtn

-- Hàm logic giao diện
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

MinimizeBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    OpenButton.Visible = true
end)

OpenButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = true
    OpenButton.Visible = false
end)

OpenScannerBtn.MouseButton1Click:Connect(function()
    ScannerFrame.Visible = not ScannerFrame.Visible
end)

CloseScanBtn.MouseButton1Click:Connect(function()
    ScannerFrame.Visible = false
end)

-- Hàm thực thi quét
local function ScanEvents()
    for _, child in ipairs(ScrollingFrame:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end

    local foldersToScan = {ReplicatedStorage, workspace}
    local char = LocalPlayer.Character
    if char then table.insert(foldersToScan, char) end

    for _, folder in ipairs(foldersToScan) do
        for _, obj in ipairs(folder:GetDescendants()) do
            if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                local itemFrame = Instance.new("Frame")
                itemFrame.Size = UDim2.new(1, -10, 0, 40)
                itemFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
                itemFrame.Parent = ScrollingFrame

                local corner = Instance.new("UICorner")
                corner.CornerRadius = UDim.new(0, 4)
                corner.Parent = itemFrame

                local lbl = Instance.new("TextLabel")
                lbl.Size = UDim2.new(1, -10, 1, 0)
                lbl.Position = UDim2.new(0, 5, 0, 0)
                lbl.BackgroundTransparency = 1
                lbl.Text = "["..obj.ClassName.."] "..obj.Name
                lbl.TextColor3 = Color3.fromRGB(0, 255, 150)
                lbl.TextSize = 11
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

-- Tự động quét 1 lần khi bật script
pcall(ScanEvents)
