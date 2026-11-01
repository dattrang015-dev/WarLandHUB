--!strict
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then return end

-- ================================================================= --
-- CẤU HÌNH UNIVERSAL: AUTO CLICK, FAST ATTACK & HITBOX
-- ================================================================= --
local CONFIG = {
    AttackDelay = 0.5,       -- Tốc độ đánh liên tục (càng nhỏ càng nhanh)
    MaxDistance = 100,        -- Khoảng cách tối đa để quét mục tiêu
    AutoEquip = true,         -- Tự động cầm vũ khí/tool trong balo
    ToggleKey = Enum.KeyCode.End, -- Phím End để bật/tắt nhanh

    -- Cấu hình Hitbox cho mọi game
    AutoHitbox = true,
    HitboxSize = Vector3.new(60, 60, 60),
    HitboxTransparency = 0.8,
}

_G.UniversalCombat = true

-- Hàm kiểm tra nhân vật sống
local function IsAlive(character): boolean
    local hum = character and character:FindFirstChildOfClass("Humanoid")
    return hum and hum.Health > 0
end

-- Hàm phóng to Hitbox bất kỳ mục tiêu nào ở gần
local function ApplyUniversalHitbox()
    if not CONFIG.AutoHitbox then return end
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart") :: BasePart?
    if not hrp then return end

    -- Quét toàn bộ model trong workspace
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

    -- Tự động cầm Tool nếu có
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

    -- Kích hoạt Tool hiện tại
    local currentTool = char:FindFirstChildOfClass("Tool")
    if currentTool then
        currentTool:Activate()
    end

    -- Giả lập click chuột trái hệ thống
    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
end

-- Vòng lặp chạy ngầm 24/7
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
-- TẠO GIAO DIỆN MENU (UI HUB) KÉO THẢ
-- ================================================================= --
local function GetGuiParent(): Instance
    local success, result = pcall(function() return game:GetService("CoreGui") end)
    if success and result then return result end
    return LocalPlayer:WaitForChild("PlayerGui")
end

local ParentGui = GetGuiParent()
local OldGui = ParentGui:FindFirstChild("UniversalCombatHub")
if OldGui then OldGui:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "UniversalCombatHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = ParentGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 240, 0, 130)
MainFrame.Position = UDim2.new(0.05, 0, 0.2, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 26)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true -- Kéo thả đi khắp màn hình
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 8)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(0, 200, 255)
MainStroke.Thickness = 1.5
MainStroke.Parent = MainFrame

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, 0, 0, 30)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "⚡ UNIVERSAL COMBAT HUB"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 11
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.Parent = MainFrame

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0.85, 0, 0, 38)
ToggleBtn.Position = UDim2.new(0.075, 0, 0, 38)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(40, 180, 80)
ToggleBtn.Text = "COMBAT: ON"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.TextSize = 12
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.Parent = MainFrame

local ToggleBtnCorner = Instance.new("UICorner")
ToggleBtnCorner.CornerRadius = UDim.new(0, 6)
ToggleBtnCorner.Parent = ToggleBtn

local InfoLabel = Instance.new("TextLabel")
InfoLabel.Size = UDim2.new(1, -20, 0, 30)
InfoLabel.Position = UDim2.new(0, 10, 0, 85)
InfoLabel.BackgroundTransparency = 1
InfoLabel.Text = "Phím tắt: [End] | Hitbox: 60x60"
InfoLabel.TextColor3 = Color3.fromRGB(0, 220, 255)
InfoLabel.TextSize = 10
InfoLabel.Font = Enum.Font.GothamMedium
InfoLabel.TextWrapped = true
InfoLabel.Parent = MainFrame

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

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == CONFIG.ToggleKey then
        _G.UniversalCombat = not _G.UniversalCombat
        UpdateUI()
    end
end)
