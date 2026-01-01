local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local Library = {}

function Library:Create(Config)
    -- // Config Extraction
    local Name = Config.Name or "UI Library"
    local ThemeColor = Config.Color or Color3.fromRGB(255, 255, 255)
    
    local Window = {}
    local CurrentTab = nil
    local IsMinimized = false
    
    -- // Main GUI
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "StrikerLib"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Parent = (RunService:IsStudio() and game.Players.LocalPlayer:WaitForChild("PlayerGui") or CoreGui)

    -- // Main Frame
    local Main = Instance.new("Frame")
    Main.Name = "Main"
    Main.Size = UDim2.new(0, 240, 0, 40) -- Starts small
    Main.Position = UDim2.new(0.5, -120, 0.5, -100)
    Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    Main.BorderSizePixel = 0
    Main.ClipsDescendants = true
    Main.Parent = ScreenGui

    -- // Styling
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 6)
    local Stroke = Instance.new("UIStroke", Main)
    Stroke.Color = Color3.fromRGB(50, 50, 50)
    Stroke.Transparency = 0.5
    Stroke.Thickness = 1

    -- // Header (The Draggable Part)
    local Header = Instance.new("TextButton") -- TextButton for input catching
    Header.Name = "Header"
    Header.Size = UDim2.new(1, 0, 0, 40)
    Header.BackgroundTransparency = 1
    Header.Text = ""
    Header.Parent = Main

    local TitleLabel = Instance.new("TextLabel", Header)
    TitleLabel.Size = UDim2.new(1, -60, 1, 0)
    TitleLabel.Position = UDim2.new(0, 12, 0, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = Name
    TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextSize = 13
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

    -- // Blended Buttons (No Backgrounds)
    local CloseBtn = Instance.new("TextButton", Header)
    CloseBtn.Size = UDim2.new(0, 30, 1, 0)
    CloseBtn.Position = UDim2.new(1, -30, 0, 0)
    CloseBtn.BackgroundTransparency = 1
    CloseBtn.Text = "✕"
    CloseBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.TextSize = 14

    local MinBtn = Instance.new("TextButton", Header)
    MinBtn.Size = UDim2.new(0, 30, 1, 0)
    MinBtn.Position = UDim2.new(1, -60, 0, 0)
    MinBtn.BackgroundTransparency = 1
    MinBtn.Text = "—"
    MinBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
    MinBtn.Font = Enum.Font.GothamBold
    MinBtn.TextSize = 14

    -- // Content Holders
    local TabContainer = Instance.new("Frame", Main)
    TabContainer.Name = "TabContainer"
    TabContainer.Size = UDim2.new(1, -20, 0, 25)
    TabContainer.Position = UDim2.new(0, 10, 0, 40)
    TabContainer.BackgroundTransparency = 1
    
    local TabListLayout = Instance.new("UIListLayout", TabContainer)
    TabListLayout.FillDirection = Enum.FillDirection.Horizontal
    TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabListLayout.Padding = UDim.new(0, 5)

    local PageContainer = Instance.new("Frame", Main)
    PageContainer.Name = "PageContainer"
    PageContainer.Size = UDim2.new(1, 0, 1, -75)
    PageContainer.Position = UDim2.new(0, 0, 0, 75)
    PageContainer.BackgroundTransparency = 1

    -- // DRAGGING (Universal Method)
    local Dragging, DragInput, DragStart, StartPos
    Header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            Dragging = true
            DragStart = input.Position
            StartPos = Main.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            DragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == DragInput and Dragging then
            local Delta = input.Position - DragStart
            Main.Position = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + Delta.X, StartPos.Y.Scale, StartPos.Y.Offset + Delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            Dragging = false
        end
    end)

    -- // CLOSE / MINIMIZE LOGIC
    CloseBtn.MouseEnter:Connect(function() CloseBtn.TextColor3 = Color3.fromRGB(255, 50, 50) end)
    CloseBtn.MouseLeave:Connect(function() CloseBtn.TextColor3 = Color3.fromRGB(150, 150, 150) end)
    CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

    MinBtn.MouseEnter:Connect(function() MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255) end)
    MinBtn.MouseLeave:Connect(function() MinBtn.TextColor3 = Color3.fromRGB(150, 150, 150) end)
    MinBtn.MouseButton1Click:Connect(function()
        IsMinimized = not IsMinimized
        local TargetH = IsMinimized and 40 or (PageContainer:FindFirstChildOfClass("Frame") and PageContainer:FindFirstChildOfClass("Frame").UIListLayout.AbsoluteContentSize.Y + 85 or 200)
        Main:TweenSize(UDim2.new(0, 240, 0, TargetH), "Out", "Quad", 0.3, true)
        PageContainer.Visible = not IsMinimized
        TabContainer.Visible = not IsMinimized
    end)

    -- // TABS
    function Window:Tab(Name)
        local TabObj = {}
        
        local TabBtn = Instance.new("TextButton", TabContainer)
        TabBtn.Size = UDim2.new(0, 0, 1, 0) -- Auto sized
        TabBtn.AutomaticSize = Enum.AutomaticSize.X
        TabBtn.BackgroundTransparency = 1
        TabBtn.Text = Name
        TabBtn.TextColor3 = Color3.fromRGB(100, 100, 100)
        TabBtn.Font = Enum.Font.GothamBold
        TabBtn.TextSize = 11
        
        local Page = Instance.new("Frame", PageContainer)
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.BackgroundTransparency = 1
        Page.Visible = false
        
        local PageList = Instance.new("UIListLayout", Page)
        PageList.Padding = UDim.new(0, 6)
        PageList.HorizontalAlignment = Enum.HorizontalAlignment.Center
        PageList.SortOrder = Enum.SortOrder.LayoutOrder

        -- Auto-Resize Window Height
        PageList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            if Page.Visible and not IsMinimized then
                Main:TweenSize(UDim2.new(0, 240, 0, PageList.AbsoluteContentSize.Y + 85), "Out", "Quad", 0.2, true)
            end
        end)

        TabBtn.MouseButton1Click:Connect(function()
            for _, v in pairs(PageContainer:GetChildren()) do v.Visible = false end
            for _, v in pairs(TabContainer:GetChildren()) do 
                if v:IsA("TextButton") then 
                    TweenService:Create(v, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(100, 100, 100)}):Play()
                end 
            end
            
            Page.Visible = true
            TweenService:Create(TabBtn, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
            Main:TweenSize(UDim2.new(0, 240, 0, PageList.AbsoluteContentSize.Y + 85), "Out", "Quad", 0.2, true)
        end)

        -- Select first tab automatically
        if CurrentTab == nil then
            CurrentTab = Page
            Page.Visible = true
            TabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        end

        function TabObj:Toggle(Text, Callback)
            local Tgl = Instance.new("TextButton", Page)
            Tgl.Size = UDim2.new(0.9, 0, 0, 30)
            Tgl.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
            Tgl.Text = Text
            Tgl.TextColor3 = Color3.fromRGB(255, 255, 255)
            Tgl.Font = Enum.Font.GothamSemibold
            Tgl.TextSize = 11
            Tgl.AutoButtonColor = false
            Instance.new("UICorner", Tgl).CornerRadius = UDim.new(0, 4)
            
            local Indicator = Instance.new("Frame", Tgl)
            Indicator.Size = UDim2.new(0, 8, 0, 8)
            Indicator.Position = UDim2.new(1, -20, 0.5, -4)
            Indicator.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            Instance.new("UICorner", Indicator).CornerRadius = UDim.new(1, 0)

            local State = false
            Tgl.MouseButton1Click:Connect(function()
                State = not State
                local Goal = State and ThemeColor or Color3.fromRGB(40, 40, 40)
                TweenService:Create(Indicator, TweenInfo.new(0.2), {BackgroundColor3 = Goal}):Play()
                Callback(State)
            end)
        end

        function TabObj:Button(Text, Callback)
            local Btn = Instance.new("TextButton", Page)
            Btn.Size = UDim2.new(0.9, 0, 0, 30)
            Btn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            Btn.Text = Text
            Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            Btn.Font = Enum.Font.GothamSemibold
            Btn.TextSize = 11
            Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 4)
            
            Btn.MouseButton1Click:Connect(function()
                TweenService:Create(Btn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(40,40,40)}):Play()
                task.wait(0.1)
                TweenService:Create(Btn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(25,25,25)}):Play()
                Callback()
            end)
        end

        return TabObj
    end

    return Window
end

return Library
