local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local Library = {}

function Library:CreateWindow(title)
    local Window = {}
    local IsMinimized = false
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "StrikerUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    ScreenGui.Parent = (RunService:IsStudio() and game.Players.LocalPlayer:WaitForChild("PlayerGui") or CoreGui)
    
    local Main = Instance.new("Frame")
    Main.Name = "Main"
    Main.Size = UDim2.new(0, 220, 0, 45)
    Main.Position = UDim2.new(0.5, -110, 0.5, -100)
    Main.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
    Main.BorderSizePixel = 0
    Main.Active = true
    Main.Parent = ScreenGui
    
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 8)
    local Stroke = Instance.new("UIStroke", Main)
    Stroke.Color = Color3.fromRGB(255, 255, 255)
    Stroke.Transparency = 0.8

    -- THE DRAG HANDLE (This makes it draggable)
    local DragBar = Instance.new("Frame", Main)
    DragBar.Name = "DragBar"
    DragBar.Size = UDim2.new(1, 0, 0, 40)
    DragBar.BackgroundTransparency = 1
    DragBar.ZIndex = 10

    local TitleLabel = Instance.new("TextLabel", Main)
    TitleLabel.Size = UDim2.new(1, -60, 0, 40)
    TitleLabel.Position = UDim2.new(0, 12, 0, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = title:upper()
    TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextSize = 13
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.ZIndex = 11

    local Container = Instance.new("Frame", Main)
    Container.Name = "Container"
    Container.Size = UDim2.new(1, 0, 1, -45)
    Container.Position = UDim2.new(0, 0, 0, 45)
    Container.BackgroundTransparency = 1
    Container.ClipsDescendants = true
    Container.ZIndex = 5

    local List = Instance.new("UIListLayout", Container)
    List.Padding = UDim.new(0, 6)
    List.HorizontalAlignment = Enum.HorizontalAlignment.Center
    List.SortOrder = Enum.SortOrder.LayoutOrder

    -- DRAGGING LOGIC
    local dragging, dragInput, dragStart, startPos
    DragBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = Main.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)

    -- AUTO-RESIZE (Starts OPEN)
    List:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        if not IsMinimized then
            Main.Size = UDim2.new(0, 220, 0, List.AbsoluteContentSize.Y + 55)
        end
    end)

    function Window:CreateToggle(text, callback)
        local T = Instance.new("TextButton", Container)
        T.Name = "Toggle"
        T.Size = UDim2.new(0, 200, 0, 32)
        T.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
        T.Text = text .. ": OFF"
        T.TextColor3 = Color3.fromRGB(255, 65, 65)
        T.Font = Enum.Font.GothamBold
        T.TextSize = 11
        T.ZIndex = 15
        Instance.new("UICorner", T).CornerRadius = UDim.new(0, 6)
        
        local state = false
        T.MouseButton1Click:Connect(function()
            state = not state
            T.Text = text .. ": " .. (state and "ON" or "OFF")
            T.TextColor3 = state and Color3.fromRGB(65, 255, 65) or Color3.fromRGB(255, 65, 65)
            callback(state)
        end)
    end

    function Window:CreateButton(text, callback)
        local B = Instance.new("TextButton", Container)
        B.Name = "Button"
        B.Size = UDim2.new(0, 200, 0, 32)
        B.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        B.Text = text
        B.TextColor3 = Color3.new(1, 1, 1)
        B.Font = Enum.Font.GothamBold
        B.TextSize = 11
        B.ZIndex = 15
        Instance.new("UICorner", B).CornerRadius = UDim.new(0, 6)
        B.MouseButton1Click:Connect(callback)
    end

    return Window
end

return Library
