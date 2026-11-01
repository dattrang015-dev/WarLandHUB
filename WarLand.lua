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
-- GIAO DIỆN UI HUB ĐA TAB (MULTI-TAB SYSTEM)
-- ================================================================= --
local function GetGuiParent(): Instance
    local success, result = pcall(function() return CoreGui end)
    if success and result then return result end
    return LocalPlayer:WaitForChild("PlayerGui")
end

local ParentGui = GetGuiParent()
local OldGui = ParentGui:FindFirstChild("MultiTabMobileHub")
if OldGui then OldGui:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MultiTabMobileHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = ParentGui

-- Main Frame (Khung chính)
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 320, 0, 260)
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
TitleLabel.Size = UDim2.new(1, -40, 0, 30)
TitleLabel.Position = UDim2.new(0, 10, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "⚡ MULTI-TAB MOBILE HUB"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 12
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = MainFrame

-- Nút thu nhỏ (-)
local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 26, 0, 26)
MinimizeBtn.Position = UDim2.new(1, -32, 0, 3)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
MinimizeBtn.Text = "-"
MinimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeBtn.TextSize = 14
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.Parent = MainFrame

local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0, 6)
MinCorner.Parent = MinimizeBtn

-- Thanh chuyển Tab (Tab Bar)
local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(1, -20, 0, 30)
TabBar.Position = UDim2.new(0, 10, 0, 32)
TabBar.BackgroundTransparency = 1
TabBar.Parent = MainFrame

local TabListLayout = Instance.new("UIListLayout")
TabListLayout.FillDirection = Enum.FillDirection.Horizontal
TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabListLayout.Padding = UDim.new(0, 5)
TabListLayout.Parent = TabBar

-- Khung chứa nội dung các Tab (Container)
local Container = Instance.new("Frame")
Container.Size = UDim2.new(1, -20, 1, -75)
Container.Position = UDim2.new(0, 10, 0, 68)
Container.BackgroundColor3 = Color3.fromRGB(25, 25, 38)
Container.BorderSizePixel = 0
Container.Parent = MainFrame

local ContainerCorner = Instance.new("UICorner")
ContainerCorner.CornerRadius = UDim.new(0, 6)
ContainerCorner.Parent = Container

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
OpenBtnCorner.Parent = OpenButton

local OpenBtnStroke = Instance.new("UIStroke")
OpenBtnStroke.Color = Color3.fromRGB(0, 200, 255)
OpenBtnStroke.Thickness = 2
OpenBtnStroke.Parent = OpenButton

-- ================================================================= --
-- TẠO CÁC TAB (COMBAT, EVENT SCANNER, SETTINGS)
-- ================================================================= --
local tabs = {}
local currentActiveTab = nil

local function CreateTab(name: string)
    -- Nút trên TabBar
    local tabBtn = Instance.new("TextButton")
    tabBtn.Size = UDim2.new(0.32, 0, 1, 0)
    tabBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    tabBtn.Text = name
    tabBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
    tabBtn.TextSize = 11
    tabBtn.Font = Enum.Font.GothamBold
    tabBtn.Parent = TabBar

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = tabBtn

    -- Khung nội dung của Tab
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
    padding.PaddingTop = UDim.N(10)
    padding.PaddingLeft = UDim.new(0, 10)
    padding.PaddingRight = UDim.new(0, 10)
    padding.Parent = tabContent

    -- Sự kiện chuyển tab
    tabBtn.MouseButton1Click:Connect(function()
        for _, t in pairs(tabs) do
            t.Content.Visible = false
            t.Button.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
            t.Button.TextColor3 = Color3.fromRGB(180, 180, 180)
        end
        tabContent.Visible = true
        tabBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
        tabBtn.TextColor3 = Color3.
