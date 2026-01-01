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
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    ScreenGui.Parent = (RunService:IsStudio() and game.Players.LocalPlayer:WaitForChild("PlayerGui") or CoreGui)
    
    local Main = Instance.new("Frame")
    Main.Name = "Main"
    Main.Size = UDim2.new(0, 240, 0, 40)
    Main.Position = UDim2.new(0.5, -120, 0.5, -100)
    Main.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
    Main.BorderSizePixel = 0
    Main.Active = true
    Main.ClipsDescendants = true
    Main.Parent = ScreenGui
    
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 8)
    local Stroke = Instance.new("UIStroke", Main)
    Stroke.Color = Color3.fromRGB(255, 255, 255)
    Stroke.Transparency = 0.8

    local Header = Instance.new("Frame", Main)
    Header.Name = "Header"
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
    CloseBtn.Size = UDim2.new(0, 20, 0, 20)
    CloseBtn.Position = UDim2.new(1, -25, 0, 10)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    CloseBtn.Text = "X"
    CloseBtn.TextColor3 = Color3.new(1,1,1)
    CloseBtn.Font = Enum.Font.GothamBold
    Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 4)
    
    local MinBtn = Instance.new("TextButton", Header)
    MinBtn.Size = UDim2.new(0, 20, 0, 20)
    MinBtn.Position = UDim2.new(1, -50, 0, 10)
    MinBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    MinBtn.Text = "-"
    MinBtn.TextColor3 = Color3.new(1,1,1)
    MinBtn.Font = Enum.Font.GothamBold
    Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 4)

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

    -- // DRAGGING LOGIC (UIS BASED)
    local dragging, dragInput, dragStart, startPos
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

    -- // MINIMIZE / CLOSE
    CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)
    
    local function ToggleMinimize()
        IsMinimized = not IsMinimized
        local TargetH = IsMinimized and 40 or (Container:FindFirstChildOfClass("ScrollingFrame") and Container:FindFirstChildOfClass("ScrollingFrame").UIListLayout.AbsoluteContentSize.Y + 80 or 200)
        TweenService:Create(Main, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(0, 240, 0, TargetH)}):Play()
    end
    MinBtn.MouseButton1Click:Connect(ToggleMinimize)

    function Window:CreateTab(name)
        local TabBtn = Instance.new("TextButton", TabHolder)
        TabBtn.Size = UDim2.new(0, 80, 1, 0)
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
        PageList.Padding = UDim.new(0, 5)
        PageList.HorizontalAlignment = Enum.HorizontalAlignment.Center

        PageList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Page.CanvasSize = UDim2.new(0,0,0,PageList.AbsoluteContentSize.Y + 10)
            if not IsMinimized and Page.Visible then
                Main.Size = UDim2.new(0, 240, 0, PageList.AbsoluteContentSize.Y + 80)
            end
        end)

        TabBtn.MouseButton1Click:Connect(function()
            for _, v in pairs(Container:GetChildren()) do v.Visible = false end
            for _, v in pairs(TabHolder:GetChildren()) do if v:IsA("TextButton") then v.TextColor3 = Color3.fromRGB(120, 120, 120) end end
            Page.Visible = true
            TabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            if not IsMinimized then
                Main.Size = UDim2.new(0, 240, 0, PageList.AbsoluteContentSize.Y + 80)
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

        function TabItems:CreateButton(text, callback)
            local B = Instance.new("TextButton", Page)
            B.Size = UDim2.new(0.92, 0, 0, 32)
            B.BackgroundColor3 = Color3.fromRGB(30,30,30)
            B.Text = text
            B.TextColor3 = Color3.new(1,1,1)
            B.Font = Enum.Font.GothamBold
            B.TextSize = 11
            Instance.new("UICorner", B).CornerRadius = UDim.new(0, 6)
            B.MouseButton1Click:Connect(callback)
        end

        return TabItems
    end

    return Window
end

return Library
