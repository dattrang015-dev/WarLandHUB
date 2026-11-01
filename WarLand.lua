--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then return end

-- ================================================================= --
-- SCRIPT QUÉT EVENT (REMOTE EVENT & REMOTE FUNCTION) TRONG GAME
-- ================================================================= --

local function GetGuiParent(): Instance
    local success, result = pcall(function() return CoreGui end)
    if success and result then return result end
    return LocalPlayer:WaitForChild("PlayerGui")
end

local ParentGui = GetGuiParent()
local OldGui = ParentGui:FindFirstChild("EventScannerHub")
if OldGui then OldGui:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "EventScannerHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = ParentGui

-- Khung chính
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 300, 0, 350)
MainFrame.Position = UDim2.new(0.5, -150, 0.3, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 26)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(255, 150, 0)
MainStroke.Thickness = 2
MainStroke.Parent = MainFrame

-- Tiêu đề
local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -40, 0, 40)
TitleLabel.Position = UDim2.new(0, 15, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "🔍 EVENT SCANNER (REMOTE)"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 13
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = MainFrame

-- Nút tắt/đóng giao diện
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0, 5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 14
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = MainFrame

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseBtn

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- ScrollFrame chứa danh sách event tìm được
local ScrollingFrame = Instance.new("ScrollingFrame")
ScrollingFrame.Size = UDim2.new(1, -20, 1, -100)
ScrollingFrame.Position = UDim2.new(0, 10, 0, 45)
ScrollingFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 38)
ScrollingFrame.BorderSizePixel = 0
ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
ScrollingFrame.Parent = MainFrame

local ScrollCorner = Instance.new("UICorner")
ScrollCorner.CornerRadius = UDim.new(0, 6)
ScrollCorner.Parent = ScrollingFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 5)
UIListLayout.Parent = ScrollingFrame

-- Nút Quét Lại (Scan)
local ScanBtn = Instance.new("TextButton")
ScanBtn.Size = UDim2.new(1, -20, 0, 40)
ScanBtn.Position = UDim2.new(0, 10, 1, -45)
ScanBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
ScanBtn.Text = "BẮT ĐẦU QUÉT EVENT"
ScanBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ScanBtn.TextSize = 13
ScanBtn.Font = Enum.Font.GothamBold
ScanBtn.Parent = MainFrame

local ScanCorner = Instance.new("UICorner")
ScanCorner.CornerRadius = UDim.new(0, 6)
ScanCorner.Parent = ScanBtn

-- Hàm thêm dòng kết quả lên UI
local function AddResultItem(name: string, className: string, fullName: string)
    local itemFrame = Instance.new("Frame")
    itemFrame.Size = UDim2.new(1, -10, 0, 45)
    itemFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    itemFrame.BorderSizePixel = 0
    itemFrame.Parent = ScrollingFrame

    local itemCorner = Instance.new("UICorner")
    itemCorner.CornerRadius = UDim.new(0, 4)
    itemCorner.Parent = itemFrame

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, -10, 0, 22)
    nameLabel.Position = UDim2.new(0, 5, 0, 2)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = "[" .. className .. "] " .. name
    nameLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
    nameLabel.TextSize = 11
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Parent = itemFrame

    local pathLabel = Instance.new("TextLabel")
    pathLabel.Size = UDim2.new(1, -10, 0, 18)
    pathLabel.Position = UDim2.new(0, 5, 0, 22)
    pathLabel.BackgroundTransparency = 1
    pathLabel.Text = "Đường dẫn: " .. fullName
    pathLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    pathLabel.TextSize = 9
    pathLabel.Font = Enum.Font.Gotham
    pathLabel.TextXAlignment = Enum.TextXAlignment.Left
    pathLabel.Parent = itemFrame
end

-- Hàm thực hiện quét
local function ScanEvents()
    -- Xóa danh sách cũ
    for _, child in ipairs(ScrollingFrame:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end

    print("--- BẮT ĐẦU QUÉT REMOTE EVENT/FUNCTION ---")
    
    local count = 0
    -- Quét toàn bộ các dịch vụ có khả năng chứa Event
    local foldersToScan = {ReplicatedStorage, workspace}
    local char = LocalPlayer.Character
    if char then table.insert(foldersToScan, char) end

    for _, folder in ipairs(foldersToScan) do
        for _, obj in ipairs(folder:GetDescendants()) do
            if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                count += 1
                local fullName = obj:GetFullName()
                print("Tìm thấy:", obj.ClassName, "->", fullName)
                AddResultItem(obj.Name, obj.ClassName, fullName)
            end
        end
    end

    print("--- QUÉT HOÀN TẤT. Tổng số:", count, "Event ---")
end

ScanBtn.MouseButton1Click:Connect(function()
    ScanEvents()
end)
