local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local Library = {}

function Library:CreateWindow(title)
    local Window = {}
    local CurrentTab = nil
    local IsMinimized = false
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "StrikerUI"
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = (RunService:IsStudio() and game.Players.LocalPlayer:WaitForChild("PlayerGui") or CoreGui)
    
    local Main = Instance.new("Frame")
    Main.Name = "Main"
    Main.Size = UDim2.new(0, 240, 0, 45)
    Main.Position = UDim2.new(0.5, -120, 0.5, -100)
    Main.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
    Main.BorderSizePixel = 0
    Main.ClipsDescendants = true
    Main.Active = true -- Important for dragging
    Main.Parent = ScreenGui
    
    -- "Squircle" Corners
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 8)
    
    local Stroke = Instance.new("UIStroke", Main)
    Stroke.Color = Color3.fromRGB(255, 255, 255)
    Stroke.Transparency = 0.8
    Stroke.Thickness = 1

    -- Header Area (Title + Buttons)
    local TitleLabel = Instance.new("TextLabel", Main)
    TitleLabel.Size = UDim2.new(1, -70, 0, 40)
    TitleLabel.Position = UDim2.new(0, 12, 0, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = title:upper()
    TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextSize = 13
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.ZIndex = 2

    -- Close Button (Fixed Text)
    local CloseBtn = Instance.new("TextButton", Main)
    CloseBtn.Size = UDim2.new(0, 22, 0, 22)
    CloseBtn.Position = UDim2.new(1, -28, 0, 9)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    CloseBtn.Text = "X" -- Standard X
    CloseBtn.TextColor3 = Color3.new(1,1,1)
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.TextSize = 12
    CloseBtn.ZIndex = 5
    Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 5)
    
    -- Minimize Button (Fixed Text)
    local MinBtn = Instance.new("TextButton", Main)
    MinBtn.Size = UDim2.new(0, 22, 0, 22)
    MinBtn.Position = UDim2.new(1, -55, 0, 9)
    MinBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    MinBtn.Text = "-" -- Standard Dash
    MinBtn.TextColor3 = Color3.new(1,1,1)
    MinBtn.Font = Enum.Font.GothamBold
    MinBtn.TextSize = 18 -- Slightly larger to make the dash visible
    MinBtn.TextYAlignment = Enum.TextYAlignment.Bottom -- Aligns dash to center better
    MinBtn.ZIndex = 5
    Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 5)

    -- Tab Container
    local TabHolder = Instance.new("Frame", Main)
    TabHolder.Size = UDim2.new(1, 0, 0, 30)
    TabHolder.Position = UDim2.new(0, 0, 0, 40)
    TabHolder.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
    TabHolder.BorderSizePixel = 0
    TabHolder.ZIndex = 3

    local TabList = Instance.new("UIListLayout", TabHolder)
    TabList.FillDirection = Enum.FillDirection.Horizontal
    TabList.SortOrder = Enum.SortOrder.LayoutOrder

    -- Content Container
    local Container = Instance.new("Frame", Main)
    Container.Size = UDim2.new(1, 0, 1, -70)
    Container.Position = UDim2.new(0, 0, 0, 70)
    Container.BackgroundTransparency = 1
    Container.ZIndex = 3

    -- // FULLY DRAGGABLE LOGIC (Drags from anywhere)
    local dragging, dragInput, dragStart, startPos
    
    Main.InputBegan:Connect(function(input)
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

    -- // BUTTON LOGIC
    CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)
    
    MinBtn.MouseButton1Click:Connect(function()
        IsMinimized = not IsMinimized
        local TargetH = IsMinimized and 40 or (Container:FindFirstChildOfClass("ScrollingFrame") and Container:FindFirstChildOfClass("ScrollingFrame").UIListLayout.AbsoluteContentSize.Y + 80 or 200)
        TweenService:Create(Main, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {Size = UDim2.new(0, 240, 0, TargetH)}):Play()
    end)

    function Window:CreateTab(name)
        local TabBtn = Instance.new("TextButton", TabHolder)
        TabBtn.Size = UDim2.new(0, 80, 1, 0)
        TabBtn.BackgroundTransparency = 1
        TabBtn.Text = name:upper()
        TabBtn.TextColor3 = Color3.fromRGB(120, 120, 120)
        TabBtn.Font = Enum.Font.GothamBold
        TabBtn.TextSize = 10
        TabBtn.ZIndex = 5

        local Page = Instance.new("ScrollingFrame", Container)
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.BackgroundTransparency = 1
        Page.Visible = false
        Page.CanvasSize = UDim2.new(0,0,0,0)
        Page.ScrollBarThickness = 0
        Page.ZIndex = 4

        local PageList = Instance.new("UIListLayout", Page)
        PageList.Padding = UDim.new(0, 6)
        PageList.HorizontalAlignment = Enum.HorizontalAlignment.Center

        PageList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Page.CanvasSize = UDim2.new(0,0,0,PageList.AbsoluteContentSize.Y + 10)
            if not IsMinimized and Page.Visible then
                Main.Size = UDim2.new(0, 240, 0, PageList.AbsoluteContentSize.Y + 85)
            end
        end)

        TabBtn.MouseButton1Click:Connect(function()
            for _, v in pairs(Container:GetChildren()) do v.Visible = false end
            for _, v in pairs(TabHolder:GetChildren()) do if v:IsA("TextButton") then v.TextColor3 = Color3.fromRGB(120, 120, 120) end end
            Page.Visible = true
            TabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            if not IsMinimized then
                Main.Size = UDim2.new(0, 240, 0, PageList.AbsoluteContentSize.Y + 85)
            end
        end)

        if CurrentTab == nil then
            CurrentTab = Page
            Page.Visible = true
            TabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        end

        local TabItems = {}

        function TabItems:CreateToggle(text, callback)
            local T = Instance.new("TextButton", Page)
            T.Size = UDim2.new(0.92, 0, 0, 32)
            T.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
            T.Text = text .. ": OFF"
            T.TextColor3 = Color3.fromRGB(255, 65, 65)
            T.Font = Enum.Font.GothamBold
            T.TextSize = 11
            T.ZIndex = 10 -- Higher ZIndex so it clicks instead of dragging
            Instance.new("UICorner", T).CornerRadius = UDim.new(0, 6)
            
            local s = false
            T.MouseButton1Click:Connect(function()
                s = not s
                T.Text = text .. ": " .. (s and "ON" or "OFF")
                T.TextColor3 = s and Color3.fromRGB(65, 255, 65) or Color3.fromRGB(255, 65, 65)
                callback(s)
            end)
        end

        function TabItems:CreateButton(text, callback)
            local B = Instance.new("TextButton", Page)
            B.Size = UDim2.new(0.92, 0, 0, 32)
            B.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            B.Text = text
            B.TextColor3 = Color3.new(1, 1, 1)
            B.Font = Enum.Font.GothamBold
            B.TextSize = 11
            B.ZIndex = 10 -- Higher ZIndex so it clicks instead of dragging
            Instance.new("UICorner", B).CornerRadius = UDim.new(0, 6)
            B.MouseButton1Click:Connect(callback)
        end

        return TabItems
    end

    return Window
end

return Library
