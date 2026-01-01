local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local Library = {}

function Library:CreateWindow(title, mode)
    local Window = {}
    local CurrentTab = nil
    local IsMinimized = false
    
    local RoundedConfig = (mode == "Hybrid" and 4 or 10)
    if mode == "Square" then RoundedConfig = 0 end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "StrikerUI_" .. title
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Parent = (RunService:IsStudio() and game.Players.LocalPlayer:WaitForChild("PlayerGui") or CoreGui)
    
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 240, 0, 40)
    MainFrame.Position = UDim2.new(0.5, -120, 0.5, -100)
    MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui
    
    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, RoundedConfig)
    local Stroke = Instance.new("UIStroke", MainFrame)
    Stroke.Color = Color3.fromRGB(255, 255, 255)
    Stroke.Transparency = 0.8
    
    local Header = Instance.new("Frame", MainFrame)
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
    CloseBtn.Size = UDim2.new(0, 25, 0, 25)
    CloseBtn.Position = UDim2.new(1, -32, 0, 7)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    CloseBtn.Text = "X"
    CloseBtn.TextColor3 = Color3.new(1,1,1)
    CloseBtn.Font = Enum.Font.GothamBold
    Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 4)
    
    local MinBtn = Instance.new("TextButton", Header)
    MinBtn.Size = UDim2.new(0, 25, 0, 25)
    MinBtn.Position = UDim2.new(1, -62, 0, 7)
    MinBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    MinBtn.Text = "-"
    MinBtn.TextColor3 = Color3.new(1,1,1)
    MinBtn.Font = Enum.Font.GothamBold
    Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 4)

    local TabHolder = Instance.new("Frame", MainFrame)
    TabHolder.Size = UDim2.new(1, 0, 0, 30)
    TabHolder.Position = UDim2.new(0, 0, 0, 40)
    TabHolder.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
    TabHolder.BorderSizePixel = 0

    local TabList = Instance.new("UIListLayout", TabHolder)
    TabList.FillDirection = Enum.FillDirection.Horizontal
    TabList.SortOrder = Enum.SortOrder.LayoutOrder

    local Container = Instance.new("Frame", MainFrame)
    Container.Size = UDim2.new(1, 0, 1, -70)
    Container.Position = UDim2.new(0, 0, 0, 70)
    Container.BackgroundTransparency = 1

    local dragging, dragInput, dragStart, startPos
    local function update(input)
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end

    Header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            update(input)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)
    MinBtn.MouseButton1Click:Connect(function()
        IsMinimized = not IsMinimized
        local TargetH = IsMinimized and 40 or (Container:FindFirstChildOfClass("ScrollingFrame") and Container:FindFirstChildOfClass("ScrollingFrame").UIListLayout.AbsoluteContentSize.Y + 85 or 200)
        TweenService:Create(MainFrame, TweenInfo.new(0.3), {Size = UDim2.new(0, 240, 0, TargetH)}):Play()
    end)

    function Window:CreateTab(name)
        local TabBtn = Instance.new("TextButton", TabHolder)
        TabBtn.Size = UDim2.new(0, 80, 1, 0)
        TabBtn.BackgroundTransparency = 1
        TabBtn.Text = name
        TabBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
        TabBtn.Font = Enum.Font.GothamBold
        TabBtn.TextSize = 11

        local Page = Instance.new("ScrollingFrame", Container)
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.BackgroundTransparency = 1
        Page.Visible = false
        Page.CanvasSize = UDim2.new(0,0,0,0)
        Page.ScrollBarThickness = 0

        local PageList = Instance.new("UIListLayout", Page)
        PageList.Padding = UDim.new(0, 5)
        PageList.HorizontalAlignment = Enum.HorizontalAlignment.Center

        PageList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Page.CanvasSize = UDim2.new(0,0,0,PageList.AbsoluteContentSize.Y + 10)
            if not IsMinimized and Page.Visible then
                MainFrame.Size = UDim2.new(0, 240, 0, PageList.AbsoluteContentSize.Y + 85)
            end
        end)

        TabBtn.MouseButton1Click:Connect(function()
            for _, v in pairs(Container:GetChildren()) do v.Visible = false end
            for _, v in pairs(TabHolder:GetChildren()) do if v:IsA("TextButton") then v.TextColor3 = Color3.fromRGB(150, 150, 150) end end
            Page.Visible = true
            TabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            MainFrame.Size = UDim2.new(0, 240, 0, PageList.AbsoluteContentSize.Y + 85)
        end)

        if CurrentTab == nil then
            CurrentTab = Page
            Page.Visible = true
            TabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        end

        local TabItems = {}

        function TabItems:CreateToggle(text, callback)
            local Tgl = Instance.new("TextButton", Page)
            Tgl.Size = UDim2.new(0.92, 0, 0, 30)
            Tgl.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
            Tgl.Text = text .. ": OFF"
            Tgl.TextColor3 = Color3.fromRGB(255, 60, 60)
            Tgl.Font = Enum.Font.GothamBold
            Tgl.TextSize = 11
            Instance.new("UICorner", Tgl).CornerRadius = UDim.new(0, RoundedConfig)
            
            local s = false
            Tgl.MouseButton1Click:Connect(function()
                s = not s
                Tgl.Text = text .. ": " .. (s and "ON" or "OFF")
                Tgl.TextColor3 = s and Color3.fromRGB(60, 255, 60) or Color3.fromRGB(255, 60, 60)
                callback(s)
            end)
        end

        function TabItems:CreateSlider(text, min, max, default, callback)
            local SFrame = Instance.new("Frame", Page)
            SFrame.Size = UDim2.new(0.92, 0, 0, 40)
            SFrame.BackgroundTransparency = 1

            local L = Instance.new("TextLabel", SFrame)
            L.Size = UDim2.new(1, 0, 0, 15)
            L.Text = text .. ": " .. default
            L.TextColor3 = Color3.new(1,1,1)
            L.BackgroundTransparency = 1
            L.Font = Enum.Font.Gotham
            L.TextSize = 10

            local Bar = Instance.new("Frame", SFrame)
            Bar.Size = UDim2.new(1, 0, 0, 6)
            Bar.Position = UDim2.new(0, 0, 0, 22)
            Bar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
            Instance.new("UICorner", Bar)

            local Fill = Instance.new("Frame", Bar)
            Fill.Size = UDim2.new((default-min)/(max-min), 0, 1, 0)
            Fill.BackgroundColor3 = Color3.new(1,1,1)
            Instance.new("UICorner", Fill)

            local function upd(input)
                local p = math.clamp((input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
                local v = math.floor(min + (max-min)*p)
                Fill.Size = UDim2.new(p, 0, 1, 0)
                L.Text = text .. ": " .. v
                callback(v)
            end

            local d = false
            Bar.InputBegan:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 then
                    d = true
                    dragging = false
                    upd(i)
                end
            end)
            UserInputService.InputChanged:Connect(function(i)
                if d and i.UserInputType == Enum.UserInputType.MouseMovement then
                    upd(i)
                end
            end)
            UserInputService.InputEnded:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 then d = false end
            end)
        end

        function TabItems:CreateButton(text, callback)
            local B = Instance.new("TextButton", Page)
            B.Size = UDim2.new(0.92, 0, 0, 30)
            B.BackgroundColor3 = Color3.fromRGB(30,30,30)
            B.Text = text
            B.TextColor3 = Color3.new(1,1,1)
            B.Font = Enum.Font.GothamBold
            B.TextSize = 11
            Instance.new("UICorner", B).CornerRadius = UDim.new(0, RoundedConfig)
            B.MouseButton1Click:Connect(callback)
        end

        return TabItems
    end

    return Window
end

return Library
