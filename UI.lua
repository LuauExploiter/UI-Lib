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
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Parent = (RunService:IsStudio() and game.Players.LocalPlayer:WaitForChild("PlayerGui") or CoreGui)
    
    local Main = Instance.new("Frame")
    Main.Name = "Main"
    Main.Size = UDim2.new(0, 220, 0, 40)
    Main.Position = UDim2.new(0.5, -110, 0.5, -100)
    Main.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
    Main.BorderSizePixel = 0
    Main.ClipsDescendants = true
    Main.Active = true
    Main.Parent = ScreenGui
    
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 6) -- The "Squircle" Look
    local Stroke = Instance.new("UIStroke", Main)
    Stroke.Color = Color3.fromRGB(255, 255, 255)
    Stroke.Transparency = 0.8

    local Header = Instance.new("TextButton", Main)
    Header.Size = UDim2.new(1, 0, 0, 40)
    Header.BackgroundTransparency = 1
    Header.Text = ""

    local TitleLabel = Instance.new("TextLabel", Main)
    TitleLabel.Size = UDim2.new(1, -60, 0, 40)
    TitleLabel.Position = UDim2.new(0, 12, 0, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = title:upper()
    TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextSize = 13
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

    local CloseBtn = Instance.new("TextButton", Main)
    CloseBtn.Size = UDim2.new(0, 20, 0, 20)
    CloseBtn.Position = UDim2.new(1, -28, 0, 10)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    CloseBtn.Text = "X"
    CloseBtn.TextColor3 = Color3.new(1,1,1)
    CloseBtn.Font = Enum.Font.GothamBold
    Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 4)
    
    local MinBtn = Instance.new("TextButton", Main)
    MinBtn.Size = UDim2.new(0, 20, 0, 20)
    MinBtn.Position = UDim2.new(1, -53, 0, 10)
    MinBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    MinBtn.Text = "-"
    MinBtn.TextColor3 = Color3.new(1,1,1)
    MinBtn.Font = Enum.Font.GothamBold
    Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 4)

    local Content = Instance.new("Frame", Main)
    Content.Size = UDim2.new(1, 0, 0, 0)
    Content.Position = UDim2.new(0, 0, 0, 45)
    Content.BackgroundTransparency = 1

    local List = Instance.new("UIListLayout", Content)
    List.Padding = UDim.new(0, 6)
    List.HorizontalAlignment = Enum.HorizontalAlignment.Center

    -- DRAGGING FIX: Simplified
    local dragStart, startPos, dragging
    Header.InputBegan:Connect(function(input)
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

    CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)
    MinBtn.MouseButton1Click:Connect(function()
        IsMinimized = not IsMinimized
        local TargetH = IsMinimized and 40 or (List.AbsoluteContentSize.Y + 55)
        TweenService:Create(Main, TweenInfo.new(0.3), {Size = UDim2.new(0, 220, 0, TargetH)}):Play()
    end)

    List:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        if not IsMinimized then
            Main.Size = UDim2.new(0, 220, 0, List.AbsoluteContentSize.Y + 55)
        end
    end)

    function Window:CreateToggle(text, callback)
        local T = Instance.new("TextButton", Content)
        T.Size = UDim2.new(0.9, 0, 0, 32)
        T.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        T.Text = text .. ": OFF"
        T.TextColor3 = Color3.fromRGB(255, 60, 60)
        T.Font = Enum.Font.GothamBold
        T.TextSize = 11
        Instance.new("UICorner", T).CornerRadius = UDim.new(0, 6)
        
        local s = false
        T.MouseButton1Click:Connect(function()
            s = not s
            T.Text = text .. ": " .. (s and "ON" or "OFF")
            T.TextColor3 = s and Color3.fromRGB(60, 255, 60) or Color3.fromRGB(255, 60, 60)
            callback(s)
        end)
    end

    function Window:CreateButton(text, callback)
        local B = Instance.new("TextButton", Content)
        B.Size = UDim2.new(0.9, 0, 0, 32)
        B.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        B.Text = text
        B.TextColor3 = Color3.new(1, 1, 1)
        B.Font = Enum.Font.GothamBold
        B.TextSize = 11
        Instance.new("UICorner", B).CornerRadius = UDim.new(0, 6)
        B.MouseButton1Click:Connect(callback)
    end

    function Window:CreateKeybind(text, default, callback)
        local K = Instance.new("TextButton", Content)
        K.Size = UDim2.new(0.9, 0, 0, 32)
        K.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        K.Text = text .. ": " .. default.Name
        K.TextColor3 = Color3.new(0.8, 0.8, 0.8)
        K.Font = Enum.Font.GothamBold
        K.TextSize = 11
        Instance.new("UICorner", K).CornerRadius = UDim.new(0, 6)

        local current = default
        local binding = false

        K.MouseButton1Click:Connect(function()
            binding = true
            K.Text = "..."
        end)

        UserInputService.InputBegan:Connect(function(i, p)
            if binding and i.UserInputType == Enum.UserInputType.Keyboard then
                current = i.KeyCode
                binding = false
                K.Text = text .. ": " .. current.Name
            elseif not p and i.KeyCode == current then
                callback()
            end
        end)
    end

    return Window
end

return Library
