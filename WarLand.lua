--!strict
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then return end

-- ================================================================= --
-- CẤU HÌNH MOBILE: AUTO CLICK, FAST ATTACK & HITBOX
-- ================================================================= --
local CONFIG = {
    AttackDelay = 0.5,        -- Đã chỉnh tốc độ đánh thành 0.5 giây
    MaxDistance = 100,        -- Khoảng cách quét mục tiêu
    AutoEquip = true,         -- Tự động cầm vũ khí trong balo
    
    -- Cấu hình Hitbox cho điện thoại
    AutoHitbox = true,
    HitboxSize = Vector3.new(50, 50, 50),
    HitboxTransparency = 0.8,
}

_G.UniversalCombat = true

-- Hàm kiểm tra nhân vật sống
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

-- Hàm thực thi tấn công tự động
local function ExecuteCombat()
    local char = LocalPlayer.Character
    if not IsAlive(char) then return end

    if CONFIG.AutoEquip then
        local tool = char:FindFirstChildOfClass("Tool")
        if not tool then
            local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
            if backpack then
                tool = backpack:FindFirstChildOfClass("Tool")
                if tool then tool.Parent = char end
            end
        end
    end

    local currentTool = char:FindFirstChildOfClass("Tool")
    if currentTool then
        currentTool:Activate()
    end

    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
end

-- Vòng lặp chạy ngầm
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
-- TẠO GIAO DIỆN MOBILE (UI THÂN THIỆN, CÓ NÚT THU NHỎ)
-- ================================================================= --
local function GetGuiParent(): Instance
    local success, result = pcall(function() return game:GetService("CoreGui") end)
    if success and result then return result end
    return LocalPlayer:WaitForChild("PlayerGui")
end

local ParentGui = GetGuiParent()
local OldGui = ParentGui:FindFirstChild("MobileCombatHub")
if OldGui then OldGui:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MobileCombatHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = ParentGui

-- Main Menu Frame
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 220, 0, 140)
MainFrame.Position = UDim2.new(0.05, 0, 0.3, 0)
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

-- Tiêu đề kèm nút ẩn menu (Minimize)
local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -40, 0, 35)
TitleLabel.Position = UDim2.new(0, 10, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "⚡ MOBILE COMBAT"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 12
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = MainFrame

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

-- Nút Bật/Tắt Combat chính
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0.9, 0, 0, 45)
ToggleBtn.Position = UDim2.new(0.05, 0, 0, 40)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(40, 180, 80)
ToggleBtn.Text = "COMBAT: ON"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.TextSize = 14
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.Parent = MainFrame

local ToggleBtnCorner = Instance.new("UICorner")
ToggleBtnCorner.CornerRadius = UDim.new(0, 8)
ToggleBtnCorner.Parent = ToggleBtn

-- Dòng chữ thông tin trạng thái
local InfoLabel = Instance.new("TextLabel")
InfoLabel.Size = UDim2.new(1, -20, 0, 30)
InfoLabel.Position = UDim2.new(0, 10, 0, 95)
InfoLabel.BackgroundTransparency = 1
InfoLabel.Text = "Delay: 0.5s | Hitbox: 50x50"
InfoLabel.TextColor3 = Color3.fromRGB(0, 220, 255)
InfoLabel.TextSize = 10
InfoLabel.Font = Enum.Font.GothamMedium
InfoLabel.TextWrapped = true
InfoLabel.Parent = MainFrame

-- Nút nổi nhỏ để bật lại menu khi bị ẩn
local OpenButton = Instance.new("TextButton")
OpenButton.Size = UDim2.new(0, 45, 0, 45)
OpenButton.Position = UDim2.new(0.05, 0, 0.3, 0)
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

-- Hàm cập nhật giao diện
local function UpdateUI()
    if _G.UniversalCombat then
        ToggleBtn.Text = "COMBAT: ON"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(40, 180, 80)
    else
        ToggleBtn.Text = "COMBAT: OFF"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
    end
end

ToggleBtn.MouseButton1Click:Connect(function()
    _G.UniversalCombat = not _G.UniversalCombat
    UpdateUI()
end)

MinimizeBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    OpenButton.Visible = true
end)

OpenButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = true
    OpenButton.Visible = false
end)
