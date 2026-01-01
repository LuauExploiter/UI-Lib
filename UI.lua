local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local Library = {}

function Library:CreateWindow(title)
    local Window = {}
    local IsMinimized = false
    local CurrentPage = nil
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "StrikerUI"
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    ScreenGui.Parent = (RunService:IsStudio() and game.Players.LocalPlayer:WaitForChild("PlayerGui") or CoreGui)
    
    local Main = Instance.new("Frame")
    Main.Name = "Main"
    Main.Size = UDim2.new(0, 230, 0, 280)
    Main.Position = UDim2.new(0.5, -115, 0.5, -140)
    Main.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
    Main.BorderSizePixel = 0
    Main.Active = true
    Main.Draggable = true
    Main.ClipsDescendants = true
    Main.Parent = ScreenGui
    
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 9)
    local Stroke = Instance.new("UIStroke", Main)
    Stroke.Color = Color3.fromRGB(255, 255, 255)
    Stroke.Transparency = 0.8

    local Header = Instance.new("Frame", Main)
    Header.Size = UDim2.new(1, 0, 0, 40)
    Header.BackgroundTransparency = 1

    local TitleLabel = Instance.new("TextLabel", Header)
    TitleLabel.Size = UDim2.new(1, -70, 1, 0)
    TitleLabel.Position = UDim2.new(0, 12, 0, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = title:upper()
    TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextSize = 13
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

    local CloseBtn = Instance.new("TextButton", Header)
    CloseBtn.Size = UDim2.new(0, 22, 0, 22)
    CloseBtn.Position = UDim2.new(1, -28, 0, 9)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    CloseBtn.Text = "X"
    CloseBtn.TextColor3 = Color3.new(1,1,1)
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.TextSize = 11
    Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 5)
    
    local MinBtn = Instance.new("TextButton", Header)
    MinBtn.Size = UDim2.new(0, 22, 0, 22)
    MinBtn.Position = UDim2.new(1, -55, 0, 9)
    MinBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    MinBtn.Text = "-"
    MinBtn.TextColor3 = Color3.new(1,1,1)
    MinBtn.Font = Enum.Font.GothamBold
    MinBtn.TextSize = 14
    Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 5)

    local TabHolder = Instance.new("Frame", Main)
    TabHolder.Size = UDim2.new(1, -20, 0, 28)
    TabHolder.Position = UDim2.new(0, 10, 0, 40)
    TabHolder.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    TabHolder.BorderSizePixel = 0
    Instance.new("UICorner", TabHolder).CornerRadius = UDim.new(0, 5)

    local TabList = Instance.new("UIListLayout", TabHolder)
    TabList.FillDirection = Enum.FillDirection.Horizontal
    TabList.SortOrder = Enum.SortOrder.LayoutOrder

    local Container = Instance.new("Frame", Main)
    Container.Size = UDim2.new(1, 0, 1, -85)
    Container.Position = UDim2.new(0, 0, 0, 75) -- Added gap between tabs and buttons
    Container.BackgroundTransparency = 1

    CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)
    
    MinBtn.MouseButton1Click:Connect(function()
        IsMinimized = not IsMinimized
        local TargetH = IsMinimized and 40 or 280
        TweenService:Create(Main, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(0, 230, 0, TargetH)}):Play()
    end)

    function Window:CreateTab(name)
        local TabBtn = Instance.new("TextButton", TabHolder)
        TabBtn.Size = UDim2.new(0, 70, 1, 0)
        TabBtn.BackgroundTransparency = 1
        TabBtn.Text = name:upper()
        TabBtn.TextColor3 = Color3.fromRGB(130, 130, 130)
        TabBtn.Font = Enum.Font.GothamBold
        TabBtn.TextSize = 9

        local Page = Instance.new("ScrollingFrame", Container)
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.BackgroundTransparency = 1
        Page.Visible = false
        Page.ScrollBarThickness = 0
        Page.CanvasSize = UDim2.new(0,0,0,0)

        local PageList = Instance.new("UIListLayout", Page)
        PageList.Padding = UDim.new(0, 8) -- Spacing between buttons
        PageList.HorizontalAlignment = Enum.HorizontalAlignment.Center
        
        PageList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Page.CanvasSize = UDim2.new(0,0,0,PageList.AbsoluteContentSize.Y + 10)
        end)

        TabBtn.MouseButton1Click:Connect(function()
            for _, v in pairs(Container:GetChildren()) do v.Visible = false end
            for _, v in pairs(TabHolder:GetChildren()) do if v:IsA("TextButton") then v.TextColor3 = Color3.fromRGB(130, 130, 130) end end
            Page.Visible = true
            TabBtn.TextColor3 = Color3.new(1, 1, 1)
        end)

        if CurrentPage == nil then
            CurrentPage = Page
            Page.Visible = true
            TabBtn.TextColor3 = Color3.new(1, 1, 1)
        end

        local TabItems = {}

        function TabItems:CreateToggle(text, callback)
            local T = Instance.new("TextButton", Page)
            T.Size = UDim2.new(0, 200, 0, 32)
            T.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
            T.Text = text .. ": OFF"
            T.TextColor3 = Color3.fromRGB(255, 65, 65)
            T.Font = Enum.Font.GothamBold
            T.TextSize = 10
            Instance.new("UICorner", T).CornerRadius = UDim.new(0, 6)
            
            local s = false
            T.MouseButton1Click:Connect(function()
                s = not s
                T.Text = text .. ": " .. (s and "ON" or "OFF")
                local targetCol = s and Color3.fromRGB(65, 255, 65) or Color3.fromRGB(255, 65, 65)
                TweenService:Create(T, TweenInfo.new(0.2), {TextColor3 = targetCol}):Play()
                callback(s)
            end)
        end

        function TabItems:CreateButton(text, callback)
            local B = Instance.new("TextButton", Page)
            B.Size = UDim2.new(0, 200, 0, 32)
            B.BackgroundColor3 = Color3.fromRGB(32, 32, 32)
            B.Text = text
            B.TextColor3 = Color3.new(1, 1, 1)
            B.Font = Enum.Font.GothamBold
            B.TextSize = 10
            Instance.new("UICorner", B).CornerRadius = UDim.new(0, 6)
            
            B.MouseButton1Connect:Connect(function()
                local oldCol = B.BackgroundColor3
                TweenService:Create(B, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(50, 50, 50)}):Play()
                task.wait(0.1)
                TweenService:Create(B, TweenInfo.new(0.1), {BackgroundColor3 = oldCol}):Play()
                callback()
            end)
        end

        return TabItems
    end

    return Window
end

return Library
