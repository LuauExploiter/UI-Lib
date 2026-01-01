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
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Parent = (RunService:IsStudio() and game.Players.LocalPlayer:WaitForChild("PlayerGui") or CoreGui)
    
    local Main = Instance.new("Frame")
    Main.Name = "Main"
    Main.Size = UDim2.new(0, 225, 0, 150) -- Default starting size
    Main.Position = UDim2.new(0.5, -112, 0.5, -75)
    Main.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
    Main.BorderSizePixel = 0
    Main.Active = true
    Main.Draggable = true -- Using the property you requested
    Main.ClipsDescendants = true
    Main.Parent = ScreenGui
    
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 8)
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
    CloseBtn.TextSize = 12
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
    TabHolder.Size = UDim2.new(1, 0, 0, 30)
    TabHolder.Position = UDim2.new(0, 0, 0, 40)
    TabHolder.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
    TabHolder.BorderSizePixel = 0

    local TabList = Instance.new("UIListLayout", TabHolder)
    TabList.FillDirection = Enum.FillDirection.Horizontal
    TabList.SortOrder = Enum.SortOrder.LayoutOrder

    local Container = Instance.new("Frame", Main)
    Container.Size = UDim2.new(1, 0, 1, -70)
    Container.Position = UDim2.new(0, 0, 0, 70)
    Container.BackgroundTransparency = 1

    CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)
    
    MinBtn.MouseButton1Click:Connect(function()
        IsMinimized = not IsMinimized
        local TargetH = IsMinimized and 40 or (Container:FindFirstChildOfClass("ScrollingFrame") and Container:FindFirstChildOfClass("ScrollingFrame").UIListLayout.AbsoluteContentSize.Y + 85 or 200)
        TweenService:Create(Main, TweenInfo.new(0.3), {Size = UDim2.new(0, 225, 0, TargetH)}):Play()
    end)

    function Window:CreateTab(name)
        local TabBtn = Instance.new("TextButton", TabHolder)
        TabBtn.Size = UDim2.new(0, 75, 1, 0)
        TabBtn.BackgroundTransparency = 1
        TabBtn.Text = name:upper()
        TabBtn.TextColor3 = Color3.fromRGB(120, 120, 120)
        TabBtn.Font = Enum.Font.GothamBold
        TabBtn.TextSize = 10

        local Page = Instance.new("ScrollingFrame", Container)
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.BackgroundTransparency = 1
        Page.Visible = false
        Page.CanvasSize = UDim2.new(0,0,0,0)
        Page.ScrollBarThickness = 0

        local PageList = Instance.new("UIListLayout", Page)
        PageList.Padding = UDim.new(0, 6)
        PageList.HorizontalAlignment = Enum.HorizontalAlignment.Center

        PageList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Page.CanvasSize = UDim2.new(0,0,0,PageList.AbsoluteContentSize.Y + 10)
            if not IsMinimized and Page.Visible then
                Main.Size = UDim2.new(0, 225, 0, PageList.AbsoluteContentSize.Y + 85)
            end
        end)

        TabBtn.MouseButton1Click:Connect(function()
            for _, v in pairs(Container:GetChildren()) do v.Visible = false end
            for _, v in pairs(TabHolder:GetChildren()) do if v:IsA("TextButton") then v.TextColor3 = Color3.fromRGB(120, 120, 120) end end
            Page.Visible = true
            TabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            Main.Size = UDim2.new(0, 225, 0, PageList.AbsoluteContentSize.Y + 85)
        end)

        if CurrentTab == nil then
            CurrentTab = Page
            Page.Visible = true
            TabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        end

        local TabItems = {}

        function TabItems:CreateToggle(text, callback)
            local T = Instance.new("TextButton", Page)
            T.Size = UDim2.new(0.9, 0, 0, 30)
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
                T.TextColor3 = s and Color3.fromRGB(65, 255, 65) or Color3.fromRGB(255, 65, 65)
                callback(s)
            end)
        end

        function TabItems:CreateButton(text, callback)
            local B = Instance.new("TextButton", Page)
            B.Size = UDim2.new(0.9, 0, 0, 30)
            B.BackgroundColor3 = Color3.fromRGB(30,30,30)
            B.Text = text
            B.TextColor3 = Color3.new(1,1,1)
            B.Font = Enum.Font.GothamBold
            B.TextSize = 10
            Instance.new("UICorner", B).CornerRadius = UDim.new(0, 6)
            B.MouseButton1Click:Connect(callback)
        end

        return TabItems
    end

    return Window
end

return Library
