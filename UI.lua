local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local StatsService = game:GetService("Stats")

local Library = {}
Library.Windows = {}
Library.Notifications = {}
Library.StatsPanels = {}

local Themes = {
    Dark = {
        Background = Color3.fromRGB(12, 12, 12),
        Tab = Color3.fromRGB(20, 20, 20),
        TabSelected = Color3.fromRGB(30, 30, 30),
        Button = Color3.fromRGB(32, 32, 32),
        ButtonHover = Color3.fromRGB(50, 50, 50),
        Toggle = Color3.fromRGB(22, 22, 22),
        ToggleOn = Color3.fromRGB(65, 255, 65),
        ToggleOff = Color3.fromRGB(255, 65, 65),
        TextBox = Color3.fromRGB(22, 22, 22),
        Dropdown = Color3.fromRGB(22, 22, 22),
        DropdownSelected = Color3.fromRGB(40, 40, 40),
        Stroke = Color3.fromRGB(255, 255, 255),
        Text = Color3.fromRGB(255, 255, 255),
        TextMuted = Color3.fromRGB(130, 130, 130),
        Notification = Color3.fromRGB(25, 25, 25),
        NotificationSuccess = Color3.fromRGB(20, 120, 20),
        NotificationError = Color3.fromRGB(120, 20, 20),
        NotificationWarning = Color3.fromRGB(120, 80, 20),
        StatsPanel = Color3.fromRGB(15, 15, 15)
    }
}

local ScreenSize = workspace.CurrentCamera.ViewportSize

local function GetDeviceScale()
    local BaseScale = 1
    if ScreenSize.Y <= 720 then
        BaseScale = 0.85
    elseif ScreenSize.Y <= 900 then
        BaseScale = 0.9
    elseif ScreenSize.Y >= 1440 then
        BaseScale = 1.1
    end
    return BaseScale
end

local DeviceScale = GetDeviceScale()

-- Store notification positions to prevent overlap
local ActiveNotificationPositions = {}

function Library:CreateWindow(Title, Options)
    local WindowSettings = Options or {}
    local ThemeName = WindowSettings.Theme or "Dark"
    local Keybind = WindowSettings.Keybind or Enum.KeyCode.RightShift
    local UseKeySystem = WindowSettings.UseKeySystem or false
    local RequiredKey = WindowSettings.RequiredKey or ""
    local Theme = Themes[ThemeName] or Themes.Dark
    local ScaleFactor = WindowSettings.Scale or DeviceScale
    local ForcePosition = WindowSettings.ForcePosition
    
    local Window = {}
    local IsMinimized = false
    local CurrentPage = nil
    local Elements = {}
    local OriginalHeight = 350
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "StrikerUI_" .. HttpService:GenerateGUID(false)
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = CoreGui
    
    local Main = Instance.new("Frame")
    Main.Name = "Main"
    Main.BackgroundColor3 = Theme.Background
    Main.BorderSizePixel = 0
    Main.Active = true
    Main.Draggable = true
    Main.ClipsDescendants = true
    Main.Parent = ScreenGui
    
    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 9)
    MainCorner.Parent = Main
    
    local MainStroke = Instance.new("UIStroke")
    MainStroke.Color = Theme.Stroke
    MainStroke.Transparency = 0.8
    MainStroke.Thickness = 1.5 * ScaleFactor
    MainStroke.Parent = Main
    
    local Header = Instance.new("Frame")
    Header.Size = UDim2.new(1, 0, 0, 40 * ScaleFactor)
    Header.BackgroundTransparency = 1
    Header.Parent = Main
    
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(1, -70 * ScaleFactor, 1, 0)
    TitleLabel.Position = UDim2.new(0, 12 * ScaleFactor, 0, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = Title
    TitleLabel.TextColor3 = Theme.Text
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextSize = 13 * ScaleFactor
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = Header
    
    -- Updated close button position and styling
    local CloseButton = Instance.new("TextButton")
    CloseButton.Size = UDim2.new(0, 22 * ScaleFactor, 0, 22 * ScaleFactor)
    CloseButton.Position = UDim2.new(1, -28 * ScaleFactor, 0, 9 * ScaleFactor)
    CloseButton.BackgroundColor3 = Theme.Background
    CloseButton.Text = "×"
    CloseButton.TextColor3 = Color3.fromRGB(200, 50, 50)
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.TextSize = 14 * ScaleFactor
    CloseButton.Parent = Header
    
    local CloseButtonCorner = Instance.new("UICorner")
    CloseButtonCorner.CornerRadius = UDim.new(0, 5)
    CloseButtonCorner.Parent = CloseButton
    
    -- Updated minimize button position and styling
    local MinButton = Instance.new("TextButton")
    MinButton.Size = UDim2.new(0, 22 * ScaleFactor, 0, 22 * ScaleFactor)
    MinButton.Position = UDim2.new(1, -58 * ScaleFactor, 0, 9 * ScaleFactor)
    MinButton.BackgroundColor3 = Theme.Background
    MinButton.Text = "−"
    MinButton.TextColor3 = Theme.Text
    MinButton.Font = Enum.Font.GothamBold
    MinButton.TextSize = 14 * ScaleFactor
    MinButton.Parent = Header
    
    local MinButtonCorner = Instance.new("UICorner")
    MinButtonCorner.CornerRadius = UDim.new(0, 5)
    MinButtonCorner.Parent = MinButton
    
    -- Make buttons blend in better
    local function UpdateButtonHover(button, isClose)
        button.MouseEnter:Connect(function()
            TweenService:Create(button, TweenInfo.new(0.2), {
                BackgroundColor3 = Theme.Button
            }):Play()
        end)
        
        button.MouseLeave:Connect(function()
            TweenService:Create(button, TweenInfo.new(0.2), {
                BackgroundColor3 = Theme.Background
            }):Play()
        end)
    end
    
    UpdateButtonHover(CloseButton, true)
    UpdateButtonHover(MinButton, false)
    
    local TabHolder = Instance.new("Frame")
    TabHolder.Size = UDim2.new(1, -20 * ScaleFactor, 0, 28 * ScaleFactor)
    TabHolder.Position = UDim2.new(0, 10 * ScaleFactor, 0, 40 * ScaleFactor)
    TabHolder.BackgroundColor3 = Theme.Tab
    TabHolder.Parent = Main
    
    local TabHolderCorner = Instance.new("UICorner")
    TabHolderCorner.CornerRadius = UDim.new(0, 5)
    TabHolderCorner.Parent = TabHolder
    
    local TabList = Instance.new("ScrollingFrame")
    TabList.Size = UDim2.new(1, 0, 1, 0)
    TabList.BackgroundTransparency = 1
    TabList.ScrollBarThickness = 2 * ScaleFactor
    TabList.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 60)
    TabList.CanvasSize = UDim2.new(0, 0, 0, 0)
    TabList.Parent = TabHolder
    
    local TabListLayout = Instance.new("UIListLayout")
    TabListLayout.Padding = UDim.new(0, 5 * ScaleFactor)
    TabListLayout.FillDirection = Enum.FillDirection.Horizontal
    TabListLayout.Parent = TabList
    
    local Content = Instance.new("Frame")
    Content.BackgroundTransparency = 1
    Content.Parent = Main
    
    TabListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        TabList.CanvasSize = UDim2.new(0, TabListLayout.AbsoluteContentSize.X, 0, 0)
    end)
    
    local function UpdateSize()
        local ContentHeight = CurrentPage and (CurrentPage.CanvasSize.Y.Offset + 30 * ScaleFactor) or 200
        local NewHeight = math.max(350 * ScaleFactor, 85 * ScaleFactor + ContentHeight)
        OriginalHeight = NewHeight
        
        Main.Size = UDim2.new(0, 250 * ScaleFactor, 0, NewHeight)
        Content.Size = UDim2.new(1, 0, 1, -85 * ScaleFactor)
        Content.Position = UDim2.new(0, 0, 0, 85 * ScaleFactor)
    end
    
    if ForcePosition then
        if ForcePosition == "TopLeft" then
            Main.Position = UDim2.new(0, 20, 0, 20)
        elseif ForcePosition == "TopRight" then
            Main.Position = UDim2.new(1, -270 * ScaleFactor, 0, 20)
        elseif ForcePosition == "MiddleLeft" then
            Main.Position = UDim2.new(0, 20, 0.5, -OriginalHeight/2)
        elseif ForcePosition == "MiddleRight" then
            Main.Position = UDim2.new(1, -270 * ScaleFactor, 0.5, -OriginalHeight/2)
        elseif ForcePosition == "BottomLeft" then
            Main.Position = UDim2.new(0, 20, 1, -OriginalHeight - 20)
        elseif ForcePosition == "BottomRight" then
            Main.Position = UDim2.new(1, -270 * ScaleFactor, 1, -OriginalHeight - 20)
        else
            Main.Position = UDim2.new(0.5, -125 * ScaleFactor, 0.5, -OriginalHeight/2)
        end
    else
        Main.Position = UDim2.new(0.5, -125 * ScaleFactor, 0.5, -OriginalHeight/2)
    end
    
    CloseButton.MouseButton1Click:Connect(function()
        local Tween = TweenService:Create(Main, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 0, 0, 0),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            BackgroundTransparency = 1
        })
        Tween:Play()
        task.wait(0.2)
        ScreenGui:Destroy()
    end)
    
    MinButton.MouseButton1Click:Connect(function()
        IsMinimized = not IsMinimized
        
        if IsMinimized then
            MinButton.Text = "+"
            TweenService:Create(TabHolder, TweenInfo.new(0.2), {
                BackgroundTransparency = 1
            }):Play()
            TweenService:Create(Content, TweenInfo.new(0.2), {
                BackgroundTransparency = 1
            }):Play()
            task.wait(0.1)
            TabHolder.Visible = false
            Content.Visible = false
            
            TweenService:Create(Main, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
                Size = UDim2.new(0, Main.Size.X.Offset, 0, 40 * ScaleFactor)
            }):Play()
        else
            MinButton.Text = "−"
            TabHolder.Visible = true
            Content.Visible = true
            TweenService:Create(TabHolder, TweenInfo.new(0.2), {
                BackgroundTransparency = 0
            }):Play()
            TweenService:Create(Content, TweenInfo.new(0.2), {
                BackgroundTransparency = 1
            }):Play()
            
            TweenService:Create(Main, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, Main.Size.X.Offset, 0, OriginalHeight)
            }):Play()
        end
    end)
    
    UserInputService.InputBegan:Connect(function(Input, Processed)
        if not Processed and Input.KeyCode == Keybind then
            Main.Visible = not Main.Visible
        end
    end)
    
    function Window:SetKeybind(NewKeybind)
        Keybind = NewKeybind
    end
    
    function Window:SetPosition(NewPosition)
        if NewPosition == "TopLeft" then
            Main.Position = UDim2.new(0, 20, 0, 20)
        elseif NewPosition == "TopRight" then
            Main.Position = UDim2.new(1, -270 * ScaleFactor, 0, 20)
        elseif NewPosition == "MiddleLeft" then
            Main.Position = UDim2.new(0, 20, 0.5, -OriginalHeight/2)
        elseif NewPosition == "MiddleRight" then
            Main.Position = UDim2.new(1, -270 * ScaleFactor, 0.5, -OriginalHeight/2)
        elseif NewPosition == "BottomLeft" then
            Main.Position = UDim2.new(0, 20, 1, -OriginalHeight - 20)
        elseif NewPosition == "BottomRight" then
            Main.Position = UDim2.new(1, -270 * ScaleFactor, 1, -OriginalHeight - 20)
        elseif NewPosition == "Center" then
            Main.Position = UDim2.new(0.5, -125 * ScaleFactor, 0.5, -OriginalHeight/2)
        else
            Main.Position = NewPosition
        end
    end
    
    function Window:CreateTab(Name)
        local TabButton = Instance.new("TextButton")
        TabButton.Size = UDim2.new(0, 70 * ScaleFactor, 1, 0)
        TabButton.BackgroundTransparency = 1
        TabButton.Text = Name
        TabButton.TextColor3 = Theme.TextMuted
        TabButton.Font = Enum.Font.GothamBold
        TabButton.TextSize = 9 * ScaleFactor
        TabButton.Parent = TabList
        
        local Page = Instance.new("ScrollingFrame")
        Page.BackgroundTransparency = 1
        Page.Visible = false
        Page.ScrollBarThickness = 2 * ScaleFactor
        Page.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 60)
        Page.CanvasSize = UDim2.new(0, 0, 0, 0)
        Page.Parent = Content
        
        local PageList = Instance.new("UIListLayout")
        PageList.Padding = UDim.new(0, 8 * ScaleFactor)
        PageList.HorizontalAlignment = Enum.HorizontalAlignment.Center
        PageList.Parent = Page
        
        PageList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Page.CanvasSize = UDim2.new(0, 0, 0, PageList.AbsoluteContentSize.Y + 20)
            CurrentPage = Page
            UpdateSize()
        end)
        
        TabButton.MouseButton1Click:Connect(function()
            for _, Child in pairs(Content:GetChildren()) do
                if Child:IsA("ScrollingFrame") then
                    Child.Visible = false
                end
            end
            for _, Child in pairs(TabList:GetChildren()) do
                if Child:IsA("TextButton") then
                    Child.TextColor3 = Theme.TextMuted
                end
            end
            Page.Visible = true
            TabButton.TextColor3 = Theme.Text
            CurrentPage = Page
            UpdateSize()
        end)
        
        if CurrentPage == nil then
            CurrentPage = Page
            Page.Visible = true
            TabButton.TextColor3 = Theme.Text
            UpdateSize()
        end
        
        Page.Size = UDim2.new(1, -10 * ScaleFactor, 1, -5 * ScaleFactor)
        Page.Position = UDim2.new(0, 5 * ScaleFactor, 0, 5 * ScaleFactor)
        
        local TabItems = {}
        
        function TabItems:CreateToggle(Text, Callback)
            local ToggleButton = Instance.new("TextButton")
            ToggleButton.Size = UDim2.new(0, 220 * ScaleFactor, 0, 32 * ScaleFactor)
            ToggleButton.BackgroundColor3 = Theme.Toggle
            ToggleButton.Text = Text .. ": OFF"
            ToggleButton.TextColor3 = Theme.ToggleOff
            ToggleButton.Font = Enum.Font.GothamBold
            ToggleButton.TextSize = 10 * ScaleFactor
            ToggleButton.Parent = Page
            
            Instance.new("UICorner", ToggleButton).CornerRadius = UDim.new(0, 6)
            
            local State = false
            
            ToggleButton.MouseButton1Click:Connect(function()
                State = not State
                ToggleButton.Text = Text .. ": " .. (State and "ON" or "OFF")
                local TargetColor = State and Theme.ToggleOn or Theme.ToggleOff
                TweenService:Create(ToggleButton, TweenInfo.new(0.2), {TextColor3 = TargetColor}):Play()
                Callback(State)
            end)
            
            local ToggleObject = {}
            
            function ToggleObject:SetState(NewState)
                State = NewState
                ToggleButton.Text = Text .. ": " .. (State and "ON" or "OFF")
                local TargetColor = State and Theme.ToggleOn or Theme.ToggleOff
                TweenService:Create(ToggleButton, TweenInfo.new(0.2), {TextColor3 = TargetColor}):Play()
                Callback(State)
            end
            
            function ToggleObject:GetState()
                return State
            end
            
            table.insert(Elements, ToggleObject)
            return ToggleObject
        end
        
        function TabItems:CreateButton(Text, Callback)
            local Button = Instance.new("TextButton")
            Button.Size = UDim2.new(0, 220 * ScaleFactor, 0, 32 * ScaleFactor)
            Button.BackgroundColor3 = Theme.Button
            Button.Text = Text
            Button.TextColor3 = Theme.Text
            Button.Font = Enum.Font.GothamBold
            Button.TextSize = 10 * ScaleFactor
            Button.Parent = Page
            
            Instance.new("UICorner", Button).CornerRadius = UDim.new(0, 6)
            
            Button.MouseEnter:Connect(function()
                TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundColor3 = Theme.ButtonHover}):Play()
            end)
            
            Button.MouseLeave:Connect(function()
                TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Button}):Play()
            end)
            
            Button.MouseButton1Click:Connect(function()
                local OriginalColor = Button.BackgroundColor3
                TweenService:Create(Button, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(60, 60, 60)}):Play()
                task.wait(0.1)
                TweenService:Create(Button, TweenInfo.new(0.1), {BackgroundColor3 = OriginalColor}):Play()
                Callback()
            end)
        end
        
        function TabItems:CreateTextBox(Text, Placeholder, Callback)
            local TextBoxFrame = Instance.new("Frame")
            TextBoxFrame.Size = UDim2.new(0, 220 * ScaleFactor, 0, 45 * ScaleFactor)
            TextBoxFrame.BackgroundTransparency = 1
            TextBoxFrame.Parent = Page
            
            local TextBoxTitle = Instance.new("TextLabel")
            TextBoxTitle.Size = UDim2.new(1, 0, 0, 18 * ScaleFactor)
            TextBoxTitle.BackgroundTransparency = 1
            TextBoxTitle.Text = Text
            TextBoxTitle.TextColor3 = Theme.Text
            TextBoxTitle.Font = Enum.Font.GothamBold
            TextBoxTitle.TextSize = 10 * ScaleFactor
            TextBoxTitle.TextXAlignment = Enum.TextXAlignment.Left
            TextBoxTitle.Parent = TextBoxFrame
            
            local TextBox = Instance.new("TextBox")
            TextBox.Size = UDim2.new(1, 0, 0, 22 * ScaleFactor)
            TextBox.Position = UDim2.new(0, 0, 0, 20 * ScaleFactor)
            TextBox.BackgroundColor3 = Theme.TextBox
            TextBox.TextColor3 = Theme.Text
            TextBox.PlaceholderText = Placeholder
            TextBox.Font = Enum.Font.Gotham
            TextBox.TextSize = 10 * ScaleFactor
            TextBox.ClearTextOnFocus = false
            TextBox.Parent = TextBoxFrame
            
            Instance.new("UICorner", TextBox).CornerRadius = UDim.new(0, 4)
            
            TextBox.FocusLost:Connect(function(EnterPressed)
                if EnterPressed then
                    Callback(TextBox.Text)
                end
            end)
            
            local TextBoxObject = {}
            
            function TextBoxObject:SetText(NewText)
                TextBox.Text = NewText
            end
            
            function TextBoxObject:GetText()
                return TextBox.Text
            end
            
            table.insert(Elements, TextBoxObject)
            return TextBoxObject
        end
        
        function TabItems:CreateLabel(Text)
            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(0, 220 * ScaleFactor, 0, 20 * ScaleFactor)
            Label.BackgroundTransparency = 1
            Label.Text = Text
            Label.TextColor3 = Theme.TextMuted
            Label.Font = Enum.Font.Gotham
            Label.TextSize = 10 * ScaleFactor
            Label.Parent = Page
        end
        
        function TabItems:CreateDropdown(Text, Options, Callback)
            local DropdownFrame = Instance.new("Frame")
            DropdownFrame.Size = UDim2.new(0, 220 * ScaleFactor, 0, 32 * ScaleFactor)
            DropdownFrame.BackgroundColor3 = Theme.Dropdown
            DropdownFrame.Parent = Page
            
            Instance.new("UICorner", DropdownFrame).CornerRadius = UDim.new(0, 6)
            
            local DropdownTitle = Instance.new("TextLabel")
            DropdownTitle.Size = UDim2.new(1, -30 * ScaleFactor, 1, 0)
            DropdownTitle.Position = UDim2.new(0, 8 * ScaleFactor, 0, 0)
            DropdownTitle.BackgroundTransparency = 1
            DropdownTitle.Text = Text .. ": " .. (Options[1] or "NONE")
            DropdownTitle.TextColor3 = Theme.Text
            DropdownTitle.Font = Enum.Font.GothamBold
            DropdownTitle.TextSize = 10 * ScaleFactor
            DropdownTitle.TextXAlignment = Enum.TextXAlignment.Left
            DropdownTitle.Parent = DropdownFrame
            
            local DropdownButton = Instance.new("TextButton")
            DropdownButton.Size = UDim2.new(0, 20 * ScaleFactor, 0, 20 * ScaleFactor)
            DropdownButton.Position = UDim2.new(1, -25 * ScaleFactor, 0.5, -10 * ScaleFactor)
            DropdownButton.BackgroundColor3 = Theme.Button
            DropdownButton.Text = "▼"
            DropdownButton.TextColor3 = Theme.Text
            DropdownButton.Font = Enum.Font.GothamBold
            DropdownButton.TextSize = 10 * ScaleFactor
            DropdownButton.Parent = DropdownFrame
            
            Instance.new("UICorner", DropdownButton).CornerRadius = UDim.new(0, 4)
            
            local DropdownList = Instance.new("ScrollingFrame")
            DropdownList.Size = UDim2.new(0, 220 * ScaleFactor, 0, 0)
            DropdownList.BackgroundColor3 = Theme.Dropdown
            DropdownList.ScrollBarThickness = 0
            DropdownList.CanvasSize = UDim2.new(0, 0, 0, 0)
            DropdownList.Visible = false
            DropdownList.ZIndex = 10
            DropdownList.Parent = ScreenGui
            
            Instance.new("UICorner", DropdownList).CornerRadius = UDim.new(0, 6)
            
            local ListLayout = Instance.new("UIListLayout")
            ListLayout.Parent = DropdownList
            
            ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                DropdownList.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y)
            end)
            
            local IsOpen = false
            local Selected = Options[1]
            
            local function UpdateDropdown()
                DropdownTitle.Text = Text .. ": " .. Selected
                for _, OptionButton in pairs(DropdownList:GetChildren()) do
                    if OptionButton:IsA("TextButton") then
                        OptionButton.BackgroundColor3 = OptionButton.Text == Selected and Theme.DropdownSelected or Theme.Dropdown
                    end
                end
                Callback(Selected)
            end
            
            local function CloseAllDropdowns()
                for _, Child in pairs(ScreenGui:GetChildren()) do
                    if Child:IsA("ScrollingFrame") and Child ~= TabList then
                        TweenService:Create(Child, TweenInfo.new(0.2), {Size = UDim2.new(0, 220 * ScaleFactor, 0, 0)}):Play()
                        task.wait(0.2)
                        Child.Visible = false
                    end
                end
            end
            
            local function ToggleDropdown()
                IsOpen = not IsOpen
                
                if IsOpen then
                    CloseAllDropdowns()
                    local Position = DropdownFrame.AbsolutePosition
                    DropdownList.Position = UDim2.new(0, Position.X, 0, Position.Y + DropdownFrame.AbsoluteSize.Y + 2)
                    DropdownList.Visible = true
                    TweenService:Create(DropdownList, TweenInfo.new(0.2), {
                        Size = UDim2.new(0, 220 * ScaleFactor, 0, math.min(#Options * 25 * ScaleFactor, 120 * ScaleFactor))
                    }):Play()
                else
                    TweenService:Create(DropdownList, TweenInfo.new(0.2), {Size = UDim2.new(0, 220 * ScaleFactor, 0, 0)}):Play()
                    task.wait(0.2)
                    DropdownList.Visible = false
                end
            end
            
            DropdownButton.MouseButton1Click:Connect(ToggleDropdown)
            
            UserInputService.InputBegan:Connect(function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 and IsOpen then
                    local MousePos = Input.Position
                    local ListPos = DropdownList.AbsolutePosition
                    local ListSize = DropdownList.AbsoluteSize
                    local FramePos = DropdownFrame.AbsolutePosition
                    local FrameSize = DropdownFrame.AbsoluteSize
                    
                    if not (MousePos.X >= FramePos.X and MousePos.X <= FramePos.X + FrameSize.X and
                           MousePos.Y >= FramePos.Y and MousePos.Y <= FramePos.Y + FrameSize.Y + ListSize.Y) then
                        ToggleDropdown()
                    end
                end
            end)
            
            for _, Option in pairs(Options) do
                local OptionButton = Instance.new("TextButton")
                OptionButton.Size = UDim2.new(1, 0, 0, 25 * ScaleFactor)
                OptionButton.BackgroundColor3 = Theme.Dropdown
                OptionButton.Text = Option
                OptionButton.TextColor3 = Theme.Text
                OptionButton.Font = Enum.Font.Gotham
                OptionButton.TextSize = 10 * ScaleFactor
                OptionButton.Parent = DropdownList
                
                Instance.new("UICorner", OptionButton).CornerRadius = UDim.new(0, 4)
                
                OptionButton.MouseButton1Click:Connect(function()
                    Selected = Option
                    UpdateDropdown()
                    ToggleDropdown()
                end)
            end
            
            UpdateDropdown()
            
            local DropdownObject = {}
            
            function DropdownObject:SetSelection(NewSelection)
                if table.find(Options, NewSelection) then
                    Selected = NewSelection
                    UpdateDropdown()
                end
            end
            
            function DropdownObject:GetSelection()
                return Selected
            end
            
            table.insert(Elements, DropdownObject)
            return DropdownObject
        end
        
        return TabItems
    end
    
    function Window:CreateNotification(Title, Message, Type, Duration)
        Type = Type or "Info"
        Duration = Duration or 3
        
        local NotificationGui = Instance.new("ScreenGui")
        NotificationGui.Name = "Notification_" .. HttpService:GenerateGUID(false)
        NotificationGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        NotificationGui.Parent = CoreGui
        
        -- Calculate available space for notifications
        local BaseY = 20 * ScaleFactor -- Start at top of screen
        local NotificationHeight = 60 * ScaleFactor
        local NotificationSpacing = 10 * ScaleFactor
        local MaxNotifications = math.floor((ScreenSize.Y * 0.7 - BaseY) / (NotificationHeight + NotificationSpacing))
        
        -- Find the first available Y position
        local AvailableY = BaseY
        local UsedPositions = {}
        
        -- Check existing notifications
        for _, Notif in pairs(Library.Notifications) do
            if Notif and Notif.Parent then
                local Frame = Notif:FindFirstChildWhichIsA("Frame")
                if Frame then
                    local FrameY = Frame.AbsolutePosition.Y
                    table.insert(UsedPositions, FrameY)
                end
            end
        end
        
        -- Check stats panels for overlap
        for _, Panel in pairs(Library.StatsPanels) do
            if Panel.Frame and Panel.Frame.Parent then
                local Frame = Panel.Frame
                local FramePos = Frame.AbsolutePosition
                local FrameSize = Frame.AbsoluteSize
                
                -- Only adjust if stats panel is on right side
                if FramePos.X > ScreenSize.X * 0.5 then
                    for y = BaseY, ScreenSize.Y - NotificationHeight, NotificationHeight + NotificationSpacing do
                        if y < FramePos.Y or y > FramePos.Y + FrameSize.Y then
                            -- Position doesn't overlap with stats panel
                            AvailableY = y
                            break
                        end
                    end
                end
            end
        end
        
        -- Sort and find first available position
        table.sort(UsedPositions)
        for i = 1, MaxNotifications do
            local TargetY = BaseY + (i-1) * (NotificationHeight + NotificationSpacing)
            local PositionAvailable = true
            
            for _, UsedY in pairs(UsedPositions) do
                if math.abs(UsedY - TargetY) < NotificationHeight then
                    PositionAvailable = false
                    break
                end
            end
            
            if PositionAvailable then
                AvailableY = TargetY
                break
            end
        end
        
        local Notification = Instance.new("Frame")
        Notification.Size = UDim2.new(0, 250 * ScaleFactor, 0, NotificationHeight)
        Notification.BackgroundColor3 = Theme.Notification
        Notification.Position = UDim2.new(1, -270 * ScaleFactor, 0, AvailableY)
        Notification.Parent = NotificationGui
        
        Instance.new("UICorner", Notification).CornerRadius = UDim.new(0, 8)
        
        local NotificationStroke = Instance.new("UIStroke")
        NotificationStroke.Color = Type == "Success" and Theme.NotificationSuccess or 
                                  Type == "Error" and Theme.NotificationError or
                                  Type == "Warning" and Theme.NotificationWarning or
                                  Theme.Stroke
        NotificationStroke.Thickness = 1.5 * ScaleFactor
        NotificationStroke.Parent = Notification
        
        local TitleLabel = Instance.new("TextLabel")
        TitleLabel.Size = UDim2.new(1, -15 * ScaleFactor, 0, 20 * ScaleFactor)
        TitleLabel.Position = UDim2.new(0, 8 * ScaleFactor, 0, 5 * ScaleFactor)
        TitleLabel.BackgroundTransparency = 1
        TitleLabel.Text = Title
        TitleLabel.TextColor3 = Theme.Text
        TitleLabel.Font = Enum.Font.GothamBold
        TitleLabel.TextSize = 11 * ScaleFactor
        TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
        TitleLabel.Parent = Notification
        
        local MessageLabel = Instance.new("TextLabel")
        MessageLabel.Size = UDim2.new(1, -15 * ScaleFactor, 1, -25 * ScaleFactor)
        MessageLabel.Position = UDim2.new(0, 8 * ScaleFactor, 0, 25 * ScaleFactor)
        MessageLabel.BackgroundTransparency = 1
        MessageLabel.Text = Message
        MessageLabel.TextColor3 = Theme.TextMuted
        MessageLabel.Font = Enum.Font.Gotham
        MessageLabel.TextSize = 9 * ScaleFactor
        MessageLabel.TextXAlignment = Enum.TextXAlignment.Left
        MessageLabel.TextYAlignment = Enum.TextYAlignment.Top
        MessageLabel.TextWrapped = true
        MessageLabel.Parent = Notification
        
        Notification.Visible = false
        
        table.insert(Library.Notifications, NotificationGui)
        
        task.spawn(function()
            task.wait(0.1)
            Notification.Visible = true
            Notification.Position = UDim2.new(1, -10 * ScaleFactor, 0, AvailableY)
            TweenService:Create(Notification, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Position = UDim2.new(1, -270 * ScaleFactor, 0, AvailableY)
            }):Play()
            
            task.wait(Duration)
            
            TweenService:Create(Notification, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
                Position = UDim2.new(1, -10 * ScaleFactor, 0, AvailableY)
            }):Play()
            
            task.wait(0.3)
            
            -- Remove from notifications table
            for i, Notif in pairs(Library.Notifications) do
                if Notif == NotificationGui then
                    table.remove(Library.Notifications, i)
                    break
                end
            end
            
            NotificationGui:Destroy()
        end)
    end
    
    function Window:CreateStatsPanel(Options)
        local PanelSettings = Options or {}
        local Position = PanelSettings.Position or "TopRight"
        local Size = PanelSettings.Size or UDim2.new(0, 180 * ScaleFactor, 0, 140 * ScaleFactor)
        local StatsList = PanelSettings.Stats or {}
        local RefreshRate = PanelSettings.RefreshRate or 1
        local Title = PanelSettings.Title or "Stats Panel"
        
        local Positions = {
            TopLeft = UDim2.new(0, 20, 0, 20),
            TopRight = UDim2.new(1, -Size.X.Offset - 20, 0, 20),
            MiddleLeft = UDim2.new(0, 20, 0.5, -Size.Y.Offset/2),
            MiddleRight = UDim2.new(1, -Size.X.Offset - 20, 0.5, -Size.Y.Offset/2),
            BottomLeft = UDim2.new(0, 20, 1, -Size.Y.Offset - 20),
            BottomRight = UDim2.new(1, -Size.X.Offset - 20, 1, -Size.Y.Offset - 20),
            Center = UDim2.new(0.5, -Size.X.Offset/2, 0.5, -Size.Y.Offset/2)
        }
        
        local StatsGui = Instance.new("ScreenGui")
        StatsGui.Name = "StatsPanel_" .. HttpService:GenerateGUID(false)
        StatsGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        StatsGui.Parent = CoreGui
        
        local StatsFrame = Instance.new("Frame")
        StatsFrame.Size = Size
        StatsFrame.Position = Positions[Position] or Positions["TopRight"]
        StatsFrame.BackgroundColor3 = Theme.StatsPanel
        StatsFrame.BorderSizePixel = 0
        StatsFrame.ClipsDescendants = true
        StatsFrame.Parent = StatsGui
        
        Instance.new("UICorner", StatsFrame).CornerRadius = UDim.new(0, 8)
        
        local StatsStroke = Instance.new("UIStroke")
        StatsStroke.Color = Theme.Stroke
        StatsStroke.Transparency = 0.8
        StatsStroke.Thickness = 1.5 * ScaleFactor
        StatsStroke.Parent = StatsFrame
        
        local StatsHeader = Instance.new("Frame")
        StatsHeader.Size = UDim2.new(1, 0, 0, 25 * ScaleFactor)
        StatsHeader.BackgroundColor3 = Theme.Tab
        StatsHeader.Parent = StatsFrame
        
        Instance.new("UICorner", StatsHeader).CornerRadius = UDim.new(0, 8, 0, 0)
        
        local StatsTitle = Instance.new("TextLabel")
        StatsTitle.Size = UDim2.new(1, -70 * ScaleFactor, 1, 0)
        StatsTitle.Position = UDim2.new(0, 10 * ScaleFactor, 0, 0)
        StatsTitle.BackgroundTransparency = 1
        StatsTitle.Text = Title
        StatsTitle.TextColor3 = Theme.Text
        StatsTitle.Font = Enum.Font.GothamBold
        StatsTitle.TextSize = 11 * ScaleFactor
        StatsTitle.TextXAlignment = Enum.TextXAlignment.Left
        StatsTitle.Parent = StatsHeader
        
        -- REMOVED the refresh button (useless top button)
        
        -- Updated minimize button with more spacing
        local MinButton = Instance.new("TextButton")
        MinButton.Size = UDim2.new(0, 18 * ScaleFactor, 0, 18 * ScaleFactor)
        MinButton.Position = UDim2.new(1, -40 * ScaleFactor, 0.5, -9 * ScaleFactor)
        MinButton.BackgroundColor3 = Theme.Background
        MinButton.Text = "−"
        MinButton.TextColor3 = Theme.Text
        MinButton.Font = Enum.Font.GothamBold
        MinButton.TextSize = 12 * ScaleFactor
        MinButton.Parent = StatsHeader
        
        local MinButtonCorner = Instance.new("UICorner")
        MinButtonCorner.CornerRadius = UDim.new(1, 0)
        MinButtonCorner.Parent = MinButton
        
        -- Updated close button with more spacing
        local CloseButton = Instance.new("TextButton")
        CloseButton.Size = UDim2.new(0, 18 * ScaleFactor, 0, 18 * ScaleFactor)
        CloseButton.Position = UDim2.new(1, -15 * ScaleFactor, 0.5, -9 * ScaleFactor)
        CloseButton.BackgroundColor3 = Theme.Background
        CloseButton.Text = "×"
        CloseButton.TextColor3 = Color3.fromRGB(200, 50, 50)
        CloseButton.Font = Enum.Font.GothamBold
        CloseButton.TextSize = 10 * ScaleFactor
        CloseButton.Parent = StatsHeader
        
        local CloseButtonCorner = Instance.new("UICorner")
        CloseButtonCorner.CornerRadius = UDim.new(1, 0)
        CloseButtonCorner.Parent = CloseButton
        
        -- Make buttons blend in better
        local function UpdateStatsButtonHover(button, isClose)
            button.MouseEnter:Connect(function()
                TweenService:Create(button, TweenInfo.new(0.2), {
                    BackgroundColor3 = Theme.Button
                }):Play()
            end)
            
            button.MouseLeave:Connect(function()
                TweenService:Create(button, TweenInfo.new(0.2), {
                    BackgroundColor3 = Theme.Background
                }):Play()
            end)
        end
        
        UpdateStatsButtonHover(CloseButton, true)
        UpdateStatsButtonHover(MinButton, false)
        
        -- Use a Frame instead of ScrollingFrame for stats content
        local StatsContent = Instance.new("Frame")
        StatsContent.Size = UDim2.new(1, -10 * ScaleFactor, 1, -30 * ScaleFactor)
        StatsContent.Position = UDim2.new(0, 5 * ScaleFactor, 0, 30 * ScaleFactor)
        StatsContent.BackgroundTransparency = 1
        StatsContent.ClipsDescendants = false
        StatsContent.Parent = StatsFrame
        
        local StatsListLayout = Instance.new("UIListLayout")
        StatsListLayout.Padding = UDim.new(0, 5 * ScaleFactor)
        StatsListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
        StatsListLayout.Parent = StatsContent
        
        StatsListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            local ContentHeight = StatsListLayout.AbsoluteContentSize.Y
            
            -- Auto-resize panel to fit all stats without scrolling
            if ContentHeight > 0 then
                local NewHeight = ContentHeight + 35 * ScaleFactor -- Add header height + padding
                StatsFrame.Size = UDim2.new(Size.X.Scale, Size.X.Offset, 0, NewHeight)
                StatsContent.Size = UDim2.new(1, -10 * ScaleFactor, 0, ContentHeight)
                
                -- Update position to maintain placement
                if Position == "TopRight" then
                    StatsFrame.Position = UDim2.new(1, -StatsFrame.AbsoluteSize.X - 20, 0, 20)
                elseif Position == "BottomRight" then
                    StatsFrame.Position = UDim2.new(1, -StatsFrame.AbsoluteSize.X - 20, 1, -StatsFrame.AbsoluteSize.Y - 20)
                elseif Position == "MiddleRight" then
                    StatsFrame.Position = UDim2.new(1, -StatsFrame.AbsoluteSize.X - 20, 0.5, -StatsFrame.AbsoluteSize.Y/2)
                end
            end
        end)
        
        local StatLabels = {}
        local StatFunctions = {}
        local PanelMinimized = false
        local PanelOriginalSize = StatsFrame.Size
        
        local function RefreshStats()
            for StatName, Label in pairs(StatLabels) do
                if StatFunctions[StatName] then
                    local Success, Result = pcall(StatFunctions[StatName])
                    if Success then
                        Label.Text = StatName .. ": " .. Result
                    else
                        Label.Text = StatName .. ": Error"
                    end
                end
            end
        end
        
        local function ToggleMinimize()
            PanelMinimized = not PanelMinimized
            
            if PanelMinimized then
                MinButton.Text = "+"
                StatsContent.Visible = false
                StatsFrame.Size = UDim2.new(PanelOriginalSize.X.Scale, PanelOriginalSize.X.Offset, 0, 30 * ScaleFactor)
            else
                MinButton.Text = "−"
                StatsContent.Visible = true
                StatsFrame.Size = PanelOriginalSize
            end
        end
        
        local LastTime = tick()
        local FrameCount = 0
        local FPS = 0
        
        local DefaultStats = {
            FPS = function()
                return FPS
            end,
            Ping = function()
                if game:GetService("Stats") then
                    return math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
                end
                return 0
            end,
            Memory = function()
                if game:GetService("Stats") then
                    return math.floor(game:GetService("Stats"):GetTotalMemoryUsageMb())
                end
                return 0
            end,
            Players = function()
                return #Players:GetPlayers()
            end,
            ServerTime = function()
                return math.floor(game:GetService("Workspace").DistributedGameTime/60) .. "m"
            end
        }
        
        if #StatsList == 0 then
            StatsList = {"FPS", "Ping", "Memory"}
        end
        
        for _, StatName in pairs(StatsList) do
            local StatLabel = Instance.new("TextLabel")
            StatLabel.Size = UDim2.new(1, 0, 0, 20 * ScaleFactor)
            StatLabel.BackgroundTransparency = 1
            StatLabel.Text = StatName .. ": "
            StatLabel.TextColor3 = Theme.Text
            StatLabel.Font = Enum.Font.Gotham
            StatLabel.TextSize = 10 * ScaleFactor
            StatLabel.TextXAlignment = Enum.TextXAlignment.Left
            StatLabel.Parent = StatsContent
            
            StatLabels[StatName] = StatLabel
            StatFunctions[StatName] = DefaultStats[StatName]
        end
        
        RunService.RenderStepped:Connect(function()
            FrameCount = FrameCount + 1
            local CurrentTime = tick()
            if CurrentTime - LastTime >= 1 then
                FPS = math.floor(FrameCount / (CurrentTime - LastTime))
                FrameCount = 0
                LastTime = CurrentTime
            end
        end)
        
        task.spawn(function()
            while StatsGui and StatsGui.Parent do
                RefreshStats()
                task.wait(RefreshRate)
            end
        end)
        
        MinButton.MouseButton1Click:Connect(function()
            ToggleMinimize()
        end)
        
        CloseButton.MouseButton1Click:Connect(function()
            TweenService:Create(StatsFrame, TweenInfo.new(0.2), {
                Size = UDim2.new(0, 0, 0, 0),
                Position = UDim2.new(0.5, StatsFrame.Position.X.Offset, 0.5, StatsFrame.Position.Y.Offset),
                BackgroundTransparency = 1
            }):Play()
            task.wait(0.2)
            StatsGui:Destroy()
            
            -- Remove from stats panels table
            for i, Panel in pairs(Library.StatsPanels) do
                if Panel.Frame == StatsFrame then
                    table.remove(Library.StatsPanels, i)
                    break
                end
            end
        end)
        
        local StatsPanelObject = {
            Frame = StatsFrame,
            Position = Position
        }
        
        function StatsPanelObject:AddStat(Name, Function)
            local StatLabel = Instance.new("TextLabel")
            StatLabel.Size = UDim2.new(1, 0, 0, 20 * ScaleFactor)
            StatLabel.BackgroundTransparency = 1
            StatLabel.Text = Name .. ": "
            StatLabel.TextColor3 = Theme.Text
            StatLabel.Font = Enum.Font.Gotham
            StatLabel.TextSize = 10 * ScaleFactor
            StatLabel.TextXAlignment = Enum.TextXAlignment.Left
            StatLabel.Parent = StatsContent
            
            StatLabels[Name] = StatLabel
            StatFunctions[Name] = Function
        end
        
        function StatsPanelObject:RemoveStat(Name)
            if StatLabels[Name] then
                StatLabels[Name]:Destroy()
                StatLabels[Name] = nil
                StatFunctions[Name] = nil
            end
        end
        
        function StatsPanelObject:SetPosition(NewPosition)
            Position = NewPosition
            StatsPanelObject.Position = NewPosition
            StatsFrame.Position = Positions[NewPosition] or Positions["TopRight"]
        end
        
        function StatsPanelObject:SetTitle(NewTitle)
            StatsTitle.Text = NewTitle
        end
        
        function StatsPanelObject:Refresh()
            RefreshStats()
        end
        
        function StatsPanelObject:ToggleMinimize()
            ToggleMinimize()
        end
        
        function StatsPanelObject:Destroy()
            StatsGui:Destroy()
        end
        
        table.insert(Library.StatsPanels, StatsPanelObject)
        return StatsPanelObject
    end
    
    function Window:ToggleVisibility()
        Main.Visible = not Main.Visible
    end
    
    function Window:Destroy()
        ScreenGui:Destroy()
    end
    
    UpdateSize()
    table.insert(Library.Windows, Window)
    return Window
end

function Library:CreateNotification(Title, Message, Type, Duration)
    Type = Type or "Info"
    Duration = Duration or 3
    
    local NotificationGui = Instance.new("ScreenGui")
    NotificationGui.Name = "Notification_" .. HttpService:GenerateGUID(false)
    NotificationGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    NotificationGui.Parent = CoreGui
    
    local ScaleFactor = DeviceScale
    local Theme = Themes.Dark
    
    -- Calculate available space for notifications
    local BaseY = 20 * ScaleFactor -- Start at top of screen
    local NotificationHeight = 60 * ScaleFactor
    local NotificationSpacing = 10 * ScaleFactor
    local MaxNotifications = math.floor((ScreenSize.Y * 0.7 - BaseY) / (NotificationHeight + NotificationSpacing))
    
    -- Find the first available Y position
    local AvailableY = BaseY
    local UsedPositions = {}
    
    -- Check existing notifications
    for _, Notif in pairs(Library.Notifications) do
        if Notif and Notif.Parent then
            local Frame = Notif:FindFirstChildWhichIsA("Frame")
            if Frame then
                local FrameY = Frame.AbsolutePosition.Y
                table.insert(UsedPositions, FrameY)
            end
        end
    end
    
    -- Check stats panels for overlap
    for _, Panel in pairs(Library.StatsPanels) do
        if Panel.Frame and Panel.Frame.Parent then
            local Frame = Panel.Frame
            local FramePos = Frame.AbsolutePosition
            local FrameSize = Frame.AbsoluteSize
            
            -- Only adjust if stats panel is on right side
            if FramePos.X > ScreenSize.X * 0.5 then
                for y = BaseY, ScreenSize.Y - NotificationHeight, NotificationHeight + NotificationSpacing do
                    if y < FramePos.Y or y > FramePos.Y + FrameSize.Y then
                        -- Position doesn't overlap with stats panel
                        AvailableY = y
                        break
                    end
                end
            end
        end
    end
    
    -- Sort and find first available position
    table.sort(UsedPositions)
    for i = 1, MaxNotifications do
        local TargetY = BaseY + (i-1) * (NotificationHeight + NotificationSpacing)
        local PositionAvailable = true
        
        for _, UsedY in pairs(UsedPositions) do
            if math.abs(UsedY - TargetY) < NotificationHeight then
                PositionAvailable = false
                break
            end
        end
        
        if PositionAvailable then
            AvailableY = TargetY
            break
        end
    end
    
    local Notification = Instance.new("Frame")
    Notification.Size = UDim2.new(0, 250 * ScaleFactor, 0, NotificationHeight)
    Notification.BackgroundColor3 = Theme.Notification
    Notification.Position = UDim2.new(1, -270 * ScaleFactor, 0, AvailableY)
    Notification.Parent = NotificationGui
    
    Instance.new("UICorner", Notification).CornerRadius = UDim.new(0, 8)
    
    local NotificationStroke = Instance.new("UIStroke")
    NotificationStroke.Color = Type == "Success" and Theme.NotificationSuccess or 
                              Type == "Error" and Theme.NotificationError or
                              Type == "Warning" and Theme.NotificationWarning or
                              Theme.Stroke
    NotificationStroke.Thickness = 1.5 * ScaleFactor
    NotificationStroke.Parent = Notification
    
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(1, -15 * ScaleFactor, 0, 20 * ScaleFactor)
    TitleLabel.Position = UDim2.new(0, 8 * ScaleFactor, 0, 5 * ScaleFactor)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = Title
    TitleLabel.TextColor3 = Theme.Text
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextSize = 11 * ScaleFactor
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = Notification
    
    local MessageLabel = Instance.new("TextLabel")
    MessageLabel.Size = UDim2.new(1, -15 * ScaleFactor, 1, -25 * ScaleFactor)
    MessageLabel.Position = UDim2.new(0, 8 * ScaleFactor, 0, 25 * ScaleFactor)
    MessageLabel.BackgroundTransparency = 1
    MessageLabel.Text = Message
    MessageLabel.TextColor3 = Theme.TextMuted
    MessageLabel.Font = Enum.Font.Gotham
    MessageLabel.TextSize = 9 * ScaleFactor
    MessageLabel.TextXAlignment = Enum.TextXAlignment.Left
    MessageLabel.TextYAlignment = Enum.TextYAlignment.Top
    MessageLabel.TextWrapped = true
    MessageLabel.Parent = Notification
    
    Notification.Visible = false
    
    table.insert(Library.Notifications, NotificationGui)
    
    task.spawn(function()
        task.wait(0.1)
        Notification.Visible = true
        Notification.Position = UDim2.new(1, -10 * ScaleFactor, 0, AvailableY)
        TweenService:Create(Notification, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Position = UDim2.new(1, -270 * ScaleFactor, 0, AvailableY)
        }):Play()
        
        task.wait(Duration or 3)
        
        TweenService:Create(Notification, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
            Position = UDim2.new(1, -10 * ScaleFactor, 0, AvailableY)
        }):Play()
        
        task.wait(0.3)
        
        -- Remove from notifications table
        for i, Notif in pairs(Library.Notifications) do
            if Notif == NotificationGui then
                table.remove(Library.Notifications, i)
                break
            end
        end
        
        NotificationGui:Destroy()
    end)
end

function Library:GetAllWindows()
    return Library.Windows
end

return Library
