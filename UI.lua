local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local Library = {}
Library.Windows = {}

function Library:CreateWindow(Title)
    local Window = {}
    local IsMinimized = false
    local CurrentPage = nil
    local Elements = {}
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "StrikerUI_" .. HttpService:GenerateGUID(false)
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = RunService:IsStudio() and game.Players.LocalPlayer:WaitForChild("PlayerGui") or CoreGui
    
    local Main = Instance.new("Frame")
    Main.Name = "Main"
    Main.Size = UDim2.new(0, 230, 0, 350)
    Main.Position = UDim2.new(0.5, -115, 0.5, -175)
    Main.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
    Main.BorderSizePixel = 0
    Main.Active = true
    Main.ClipsDescendants = true
    Main.Parent = ScreenGui
    
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 9)
    UICorner.Parent = Main
    
    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(255, 255, 255)
    Stroke.Transparency = 0.8
    Stroke.Parent = Main
    
    local Header = Instance.new("Frame")
    Header.Size = UDim2.new(1, 0, 0, 40)
    Header.BackgroundTransparency = 1
    Header.Parent = Main
    
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(1, -70, 1, 0)
    TitleLabel.Position = UDim2.new(0, 12, 0, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = Title:upper()
    TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextSize = 13
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = Header
    
    local CloseButton = Instance.new("TextButton")
    CloseButton.Size = UDim2.new(0, 22, 0, 22)
    CloseButton.Position = UDim2.new(1, -28, 0, 9)
    CloseButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    CloseButton.Text = "X"
    CloseButton.TextColor3 = Color3.new(1, 1, 1)
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.TextSize = 11
    CloseButton.Parent = Header
    
    local CloseButtonUICorner = Instance.new("UICorner")
    CloseButtonUICorner.CornerRadius = UDim.new(0, 5)
    CloseButtonUICorner.Parent = CloseButton
    
    local MinButton = Instance.new("TextButton")
    MinButton.Size = UDim2.new(0, 22, 0, 22)
    MinButton.Position = UDim2.new(1, -55, 0, 9)
    MinButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    MinButton.Text = "-"
    MinButton.TextColor3 = Color3.new(1, 1, 1)
    MinButton.Font = Enum.Font.GothamBold
    MinButton.TextSize = 14
    MinButton.Parent = Header
    
    local MinButtonUICorner = Instance.new("UICorner")
    MinButtonUICorner.CornerRadius = UDim.new(0, 5)
    MinButtonUICorner.Parent = MinButton
    
    local TabHolder = Instance.new("Frame")
    TabHolder.Size = UDim2.new(1, -20, 0, 28)
    TabHolder.Position = UDim2.new(0, 10, 0, 40)
    TabHolder.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    TabHolder.BorderSizePixel = 0
    TabHolder.Parent = Main
    
    local TabHolderUICorner = Instance.new("UICorner")
    TabHolderUICorner.CornerRadius = UDim.new(0, 5)
    TabHolderUICorner.Parent = TabHolder
    
    local TabList = Instance.new("UIListLayout")
    TabList.FillDirection = Enum.FillDirection.Horizontal
    TabList.SortOrder = Enum.SortOrder.LayoutOrder
    TabList.Parent = TabHolder
    
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, 0, 1, -85)
    Container.Position = UDim2.new(0, 0, 0, 75)
    Container.BackgroundTransparency = 1
    Container.Parent = Main
    
    local Dragging = false
    local DragStart = nil
    local StartPosition = nil
    
    Header.InputBegan:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 then
            Dragging = true
            DragStart = Input.Position
            StartPosition = Main.Position
        end
    end)
    
    Header.InputEnded:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 then
            Dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(Input)
        if Dragging and Input.UserInputType == Enum.UserInputType.MouseMovement then
            local Delta = Input.Position - DragStart
            Main.Position = UDim2.new(StartPosition.X.Scale, StartPosition.X.Offset + Delta.X, StartPosition.Y.Scale, StartPosition.Y.Offset + Delta.Y)
        end
    end)
    
    CloseButton.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)
    
    MinButton.MouseButton1Click:Connect(function()
        IsMinimized = not IsMinimized
        local TargetHeight = IsMinimized and 40 or 350
        TweenService:Create(Main, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(0, 230, 0, TargetHeight)}):Play()
    end)
    
    local Keybind = Enum.KeyCode.RightShift
    UserInputService.InputBegan:Connect(function(Input, Processed)
        if not Processed and Input.KeyCode == Keybind then
            Main.Visible = not Main.Visible
        end
    end)
    
    function Window:SetKeybind(NewKeybind)
        Keybind = NewKeybind
    end
    
    function Window:CreateTab(Name)
        local TabButton = Instance.new("TextButton")
        TabButton.Size = UDim2.new(0, 70, 1, 0)
        TabButton.BackgroundTransparency = 1
        TabButton.Text = Name:upper()
        TabButton.TextColor3 = Color3.fromRGB(130, 130, 130)
        TabButton.Font = Enum.Font.GothamBold
        TabButton.TextSize = 9
        TabButton.Parent = TabHolder
        
        local Page = Instance.new("ScrollingFrame")
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.BackgroundTransparency = 1
        Page.Visible = false
        Page.ScrollBarThickness = 0
        Page.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 60)
        Page.CanvasSize = UDim2.new(0, 0, 0, 0)
        Page.Parent = Container
        
        local PageList = Instance.new("UIListLayout")
        PageList.Padding = UDim.new(0, 8)
        PageList.HorizontalAlignment = Enum.HorizontalAlignment.Center
        PageList.Parent = Page
        
        PageList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Page.CanvasSize = UDim2.new(0, 0, 0, PageList.AbsoluteContentSize.Y + 10)
        end)
        
        TabButton.MouseButton1Click:Connect(function()
            for _, Child in pairs(Container:GetChildren()) do
                if Child:IsA("ScrollingFrame") then
                    Child.Visible = false
                end
            end
            for _, Child in pairs(TabHolder:GetChildren()) do
                if Child:IsA("TextButton") then
                    Child.TextColor3 = Color3.fromRGB(130, 130, 130)
                end
            end
            Page.Visible = true
            TabButton.TextColor3 = Color3.new(1, 1, 1)
        end)
        
        if CurrentPage == nil then
            CurrentPage = Page
            Page.Visible = true
            TabButton.TextColor3 = Color3.new(1, 1, 1)
        end
        
        local TabItems = {}
        
        function TabItems:CreateToggle(Text, Callback)
            local ToggleButton = Instance.new("TextButton")
            ToggleButton.Size = UDim2.new(0, 200, 0, 32)
            ToggleButton.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
            ToggleButton.Text = Text .. ": OFF"
            ToggleButton.TextColor3 = Color3.fromRGB(255, 65, 65)
            ToggleButton.Font = Enum.Font.GothamBold
            ToggleButton.TextSize = 10
            ToggleButton.Parent = Page
            
            local ToggleUICorner = Instance.new("UICorner")
            ToggleUICorner.CornerRadius = UDim.new(0, 6)
            ToggleUICorner.Parent = ToggleButton
            
            local State = false
            
            ToggleButton.MouseButton1Click:Connect(function()
                State = not State
                ToggleButton.Text = Text .. ": " .. (State and "ON" or "OFF")
                local TargetColor = State and Color3.fromRGB(65, 255, 65) or Color3.fromRGB(255, 65, 65)
                TweenService:Create(ToggleButton, TweenInfo.new(0.2), {TextColor3 = TargetColor}):Play()
                Callback(State)
            end)
            
            local ToggleObject = {
                SetState = function(self, NewState)
                    State = NewState
                    ToggleButton.Text = Text .. ": " .. (State and "ON" or "OFF")
                    local TargetColor = State and Color3.fromRGB(65, 255, 65) or Color3.fromRGB(255, 65, 65)
                    TweenService:Create(ToggleButton, TweenInfo.new(0.2), {TextColor3 = TargetColor}):Play()
                    Callback(State)
                end,
                GetState = function(self)
                    return State
                end
            }
            
            table.insert(Elements, ToggleObject)
            return ToggleObject
        end
        
        function TabItems:CreateButton(Text, Callback)
            local Button = Instance.new("TextButton")
            Button.Size = UDim2.new(0, 200, 0, 32)
            Button.BackgroundColor3 = Color3.fromRGB(32, 32, 32)
            Button.Text = Text
            Button.TextColor3 = Color3.new(1, 1, 1)
            Button.Font = Enum.Font.GothamBold
            Button.TextSize = 10
            Button.Parent = Page
            
            local ButtonUICorner = Instance.new("UICorner")
            ButtonUICorner.CornerRadius = UDim.new(0, 6)
            ButtonUICorner.Parent = Button
            
            Button.MouseButton1Click:Connect(function()
                local OriginalColor = Button.BackgroundColor3
                TweenService:Create(Button, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(50, 50, 50)}):Play()
                task.wait(0.1)
                TweenService:Create(Button, TweenInfo.new(0.1), {BackgroundColor3 = OriginalColor}):Play()
                Callback()
            end)
        end
        
        function TabItems:CreateSlider(Text, MinValue, MaxValue, DefaultValue, Callback)
            local SliderFrame = Instance.new("Frame")
            SliderFrame.Size = UDim2.new(0, 200, 0, 45)
            SliderFrame.BackgroundTransparency = 1
            SliderFrame.Parent = Page
            
            local SliderTitle = Instance.new("TextLabel")
            SliderTitle.Size = UDim2.new(1, 0, 0, 15)
            SliderTitle.BackgroundTransparency = 1
            SliderTitle.Text = Text .. ": " .. DefaultValue
            SliderTitle.TextColor3 = Color3.new(1, 1, 1)
            SliderTitle.Font = Enum.Font.GothamBold
            SliderTitle.TextSize = 9
            SliderTitle.TextXAlignment = Enum.TextXAlignment.Left
            SliderTitle.Parent = SliderFrame
            
            local SliderBackground = Instance.new("Frame")
            SliderBackground.Size = UDim2.new(1, 0, 0, 20)
            SliderBackground.Position = UDim2.new(0, 0, 0, 20)
            SliderBackground.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
            SliderBackground.Parent = SliderFrame
            
            local SliderBackgroundUICorner = Instance.new("UICorner")
            SliderBackgroundUICorner.CornerRadius = UDim.new(0, 4)
            SliderBackgroundUICorner.Parent = SliderBackground
            
            local SliderFill = Instance.new("Frame")
            SliderFill.Size = UDim2.new((DefaultValue - MinValue) / (MaxValue - MinValue), 0, 1, 0)
            SliderFill.BackgroundColor3 = Color3.fromRGB(65, 255, 65)
            SliderFill.Parent = SliderBackground
            
            local SliderFillUICorner = Instance.new("UICorner")
            SliderFillUICorner.CornerRadius = UDim.new(0, 4)
            SliderFillUICorner.Parent = SliderFill
            
            local SliderButton = Instance.new("TextButton")
            SliderButton.Size = UDim2.new(1, 0, 1, 0)
            SliderButton.BackgroundTransparency = 1
            SliderButton.Text = ""
            SliderButton.Parent = SliderBackground
            
            local IsSliding = false
            
            local function UpdateSlider(Input)
                local X = math.clamp((Input.Position.X - SliderBackground.AbsolutePosition.X) / SliderBackground.AbsoluteSize.X, 0, 1)
                local Value = math.floor(MinValue + (MaxValue - MinValue) * X + 0.5)
                SliderFill.Size = UDim2.new(X, 0, 1, 0)
                SliderTitle.Text = Text .. ": " .. Value
                Callback(Value)
            end
            
            SliderButton.MouseButton1Down:Connect(function()
                IsSliding = true
                UpdateSlider(UserInputService:GetMouseLocation())
            end)
            
            UserInputService.InputChanged:Connect(function(Input)
                if IsSliding and Input.UserInputType == Enum.UserInputType.MouseMovement then
                    UpdateSlider(Input)
                end
            end)
            
            UserInputService.InputEnded:Connect(function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                    IsSliding = false
                end
            end)
            
            local SliderObject = {
                SetValue = function(self, Value)
                    local X = math.clamp((Value - MinValue) / (MaxValue - MinValue), 0, 1)
                    SliderFill.Size = UDim2.new(X, 0, 1, 0)
                    SliderTitle.Text = Text .. ": " .. Value
                    Callback(Value)
                end
            }
            
            table.insert(Elements, SliderObject)
            return SliderObject
        end
        
        function TabItems:CreateTextBox(Text, Placeholder, Callback)
            local TextBoxFrame = Instance.new("Frame")
            TextBoxFrame.Size = UDim2.new(0, 200, 0, 40)
            TextBoxFrame.BackgroundTransparency = 1
            TextBoxFrame.Parent = Page
            
            local TextBoxTitle = Instance.new("TextLabel")
            TextBoxTitle.Size = UDim2.new(1, 0, 0, 15)
            TextBoxTitle.BackgroundTransparency = 1
            TextBoxTitle.Text = Text
            TextBoxTitle.TextColor3 = Color3.new(1, 1, 1)
            TextBoxTitle.Font = Enum.Font.GothamBold
            TextBoxTitle.TextSize = 9
            TextBoxTitle.TextXAlignment = Enum.TextXAlignment.Left
            TextBoxTitle.Parent = TextBoxFrame
            
            local TextBox = Instance.new("TextBox")
            TextBox.Size = UDim2.new(1, 0, 0, 20)
            TextBox.Position = UDim2.new(0, 0, 0, 20)
            TextBox.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
            TextBox.TextColor3 = Color3.new(1, 1, 1)
            TextBox.PlaceholderText = Placeholder
            TextBox.Font = Enum.Font.Gotham
            TextBox.TextSize = 10
            TextBox.ClearTextOnFocus = false
            TextBox.Parent = TextBoxFrame
            
            local TextBoxUICorner = Instance.new("UICorner")
            TextBoxUICorner.CornerRadius = UDim.new(0, 4)
            TextBoxUICorner.Parent = TextBox
            
            TextBox.FocusLost:Connect(function(EnterPressed)
                if EnterPressed then
                    Callback(TextBox.Text)
                end
            end)
            
            local TextBoxObject = {
                SetText = function(self, NewText)
                    TextBox.Text = NewText
                end,
                GetText = function(self)
                    return TextBox.Text
                end
            }
            
            table.insert(Elements, TextBoxObject)
            return TextBoxObject
        end
        
        function TabItems:CreateLabel(Text)
            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(0, 200, 0, 20)
            Label.BackgroundTransparency = 1
            Label.Text = Text
            Label.TextColor3 = Color3.new(1, 1, 1)
            Label.Font = Enum.Font.GothamBold
            Label.TextSize = 10
            Label.Parent = Page
        end
        
        function TabItems:CreateDropdown(Text, Options, Callback)
            local DropdownFrame = Instance.new("Frame")
            DropdownFrame.Size = UDim2.new(0, 200, 0, 32)
            DropdownFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
            DropdownFrame.Parent = Page
            
            local DropdownUICorner = Instance.new("UICorner")
            DropdownUICorner.CornerRadius = UDim.new(0, 6)
            DropdownUICorner.Parent = DropdownFrame
            
            local DropdownTitle = Instance.new("TextLabel")
            DropdownTitle.Size = UDim2.new(1, -30, 1, 0)
            DropdownTitle.Position = UDim2.new(0, 8, 0, 0)
            DropdownTitle.BackgroundTransparency = 1
            DropdownTitle.Text = Text .. ": " .. (Options[1] or "NONE")
            DropdownTitle.TextColor3 = Color3.new(1, 1, 1)
            DropdownTitle.Font = Enum.Font.GothamBold
            DropdownTitle.TextSize = 10
            DropdownTitle.TextXAlignment = Enum.TextXAlignment.Left
            DropdownTitle.Parent = DropdownFrame
            
            local DropdownButton = Instance.new("TextButton")
            DropdownButton.Size = UDim2.new(0, 20, 0, 20)
            DropdownButton.Position = UDim2.new(1, -25, 0.5, -10)
            DropdownButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            DropdownButton.Text = "▼"
            DropdownButton.TextColor3 = Color3.new(1, 1, 1)
            DropdownButton.Font = Enum.Font.GothamBold
            DropdownButton.TextSize = 10
            DropdownButton.Parent = DropdownFrame
            
            local DropdownButtonUICorner = Instance.new("UICorner")
            DropdownButtonUICorner.CornerRadius = UDim.new(0, 4)
            DropdownButtonUICorner.Parent = DropdownButton
            
            local DropdownList = Instance.new("ScrollingFrame")
            DropdownList.Size = UDim2.new(1, 0, 0, 0)
            DropdownList.Position = UDim2.new(0, 0, 1, 2)
            DropdownList.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
            DropdownList.ScrollBarThickness = 0
            DropdownList.CanvasSize = UDim2.new(0, 0, 0, 0)
            DropdownList.Visible = false
            DropdownList.Parent = DropdownFrame
            
            local DropdownListUICorner = Instance.new("UICorner")
            DropdownListUICorner.CornerRadius = UDim.new(0, 4)
            DropdownListUICorner.Parent = DropdownList
            
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
                        OptionButton.BackgroundColor3 = OptionButton.Text == Selected and Color3.fromRGB(50, 50, 50) or Color3.fromRGB(22, 22, 22)
                    end
                end
                Callback(Selected)
            end
            
            local function ToggleDropdown()
                IsOpen = not IsOpen
                DropdownList.Visible = IsOpen
                local TargetSize = IsOpen and math.min(#Options * 22, 110) or 0
                TweenService:Create(DropdownList, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, TargetSize)}):Play()
            end
            
            DropdownButton.MouseButton1Click:Connect(ToggleDropdown)
            
            for _, Option in pairs(Options) do
                local OptionButton = Instance.new("TextButton")
                OptionButton.Size = UDim2.new(1, 0, 0, 22)
                OptionButton.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
                OptionButton.Text = Option
                OptionButton.TextColor3 = Color3.new(1, 1, 1)
                OptionButton.Font = Enum.Font.Gotham
                OptionButton.TextSize = 10
                OptionButton.Parent = DropdownList
                
                OptionButton.MouseButton1Click:Connect(function()
                    Selected = Option
                    UpdateDropdown()
                    ToggleDropdown()
                end)
            end
            
            UpdateDropdown()
            
            local DropdownObject = {
                SetSelection = function(self, NewSelection)
                    if table.find(Options, NewSelection) then
                        Selected = NewSelection
                        UpdateDropdown()
                    end
                end,
                GetSelection = function(self)
                    return Selected
                end
            }
            
            table.insert(Elements, DropdownObject)
            return DropdownObject
        end
        
        return TabItems
    end
    
    function Window:ToggleVisibility()
        Main.Visible = not Main.Visible
    end
    
    function Window:Destroy()
        ScreenGui:Destroy()
    end
    
    function Window:SetPosition(Position)
        Main.Position = Position
    end
    
    function Window:SetSize(Size)
        Main.Size = Size
    end
    
    table.insert(Library.Windows, Window)
    return Window
end

function Library:GetAllWindows()
    return Library.Windows
end

return Library
