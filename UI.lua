--[[ 
Random Ui lib
    Features: 
    - Minimize/Close Buttons
    - Rounded or Rectangular Modes
    - Drag-Locking (Sliders don't move the UI)
    - Smooth Tween Animations
]]

local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local Library = {}

function Library:CreateWindow(title, mode)
    local Window = {}
    local IsMinimized = false
    local CornerRadius = (mode == "Rectangular" and 0 or 10)
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "StrikerUI_" .. title
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Parent = (RunService:IsStudio() and game.Players.LocalPlayer:WaitForChild("PlayerGui") or CoreGui)
    
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 230, 0, 40)
    MainFrame.Position = UDim2.new(0.5, -115, 0.5, -100)
    MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui
    
    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, CornerRadius)
    local Stroke = Instance.new("UIStroke", MainFrame)
    Stroke.Color = Color3.fromRGB(255, 255, 255)
    Stroke.Transparency = 0.85
    
    -- Title Bar Container
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

    -- Close/Minimize Buttons
    local CloseBtn = Instance.new("TextButton", Header)
    CloseBtn.Size = UDim2.new(0, 25, 0, 25)
    CloseBtn.Position = UDim2.new(1, -30, 0, 7)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    CloseBtn.Text = "X"
    CloseBtn.TextColor3 = Color3.new(1,1,1)
    CloseBtn.Font = Enum.Font.GothamBold
    Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 4)
    
    local MinBtn = Instance.new("TextButton", Header)
    MinBtn.Size = UDim2.new(0, 25, 0, 25)
    MinBtn.Position = UDim2.new(1, -60, 0, 7)
    MinBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    MinBtn.Text = "-"
    MinBtn.TextColor3 = Color3.new(1,1,1)
    MinBtn.Font = Enum.Font.GothamBold
    Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 4)

    local Content = Instance.new("Frame", MainFrame)
    Content.Name = "Content"
    Content.Size = UDim2.new(1, 0, 0, 0)
    Content.Position = UDim2.new(0, 0, 0, 40)
    Content.BackgroundTransparency = 1
    
    local List = Instance.new("UIListLayout", Content)
    List.Padding = UDim.new(0, 6)
    List.HorizontalAlignment = Enum.HorizontalAlignment.Center

    -- Logic: Dragging
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

    -- Logic: Close/Minimize
    CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)
    
    MinBtn.MouseButton1Click:Connect(function()
        IsMinimized = not IsMinimized
        local TargetHeight = IsMinimized and 40 or (List.AbsoluteContentSize.Y + 50)
        TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back), {Size = UDim2.new(0, 230, 0, TargetHeight)}):Play()
    end)

    -- Auto-Resizing Content
    List:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        if not IsMinimized then
            MainFrame.Size = UDim2.new(0, 230, 0, List.AbsoluteContentSize.Y + 50)
        end
    end)

    -- ELEMENTS
    function Window:CreateToggle(text, callback)
        local Tgl = Instance.new("TextButton", Content)
        Tgl.Size = UDim2.new(0.92, 0, 0, 32)
        Tgl.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
        Tgl.Text = text .. ": OFF"
        Tgl.TextColor3 = Color3.fromRGB(255, 60, 60)
        Tgl.Font = Enum.Font.GothamBold
        Tgl.TextSize = 11
        Instance.new("UICorner", Tgl).CornerRadius = UDim.new(0, CornerRadius == 0 and 0 or 6)
        
        local state = false
        Tgl.MouseButton1Click:Connect(function()
            state = not state
            Tgl.Text = text .. ": " .. (state and "ON" or "OFF")
            local color = state and Color3.fromRGB(60, 255, 60) or Color3.fromRGB(255, 60, 60)
            TweenService:Create(Tgl, TweenInfo.new(0.2), {TextColor3 = color}):Play()
            callback(state)
        end)
    end

    function Window:CreateSlider(text, min, max, default, callback)
        local SliderFrame = Instance.new("Frame", Content)
        SliderFrame.Size = UDim2.new(0.92, 0, 0, 45)
        SliderFrame.BackgroundTransparency = 1

        local Label = Instance.new("TextLabel", SliderFrame)
        Label.Size = UDim2.new(1, 0, 0, 20)
        Label.Text = text .. ": " .. default
        Label.TextColor3 = Color3.new(0.8, 0.8, 0.8)
        Label.BackgroundTransparency = 1
        Label.Font = Enum.Font.Gotham
        Label.TextSize = 10

        local SliderBar = Instance.new("Frame", SliderFrame)
        SliderBar.Size = UDim2.new(1, 0, 0, 6)
        SliderBar.Position = UDim2.new(0, 0, 0, 25)
        SliderBar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        Instance.new("UICorner", SliderBar)

        local Fill = Instance.new("Frame", SliderBar)
        Fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
        Fill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Instance.new("UICorner", Fill)

        local function updateSlider(input)
            -- IMPORTANT: This stops the window from dragging when you slide
            dragging = false 
            local size = math.clamp((input.Position.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X, 0, 1)
            local value = math.floor(min + (max - min) * size)
            Fill.Size = UDim2.new(size, 0, 1, 0)
            Label.Text = text .. ": " .. value
            callback(value)
        end

        local sliderDragging = false
        SliderBar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                sliderDragging = true
                updateSlider(input)
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if sliderDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                updateSlider(input)
            end
        end)

        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                sliderDragging = false
            end
        end)
    end

    function Window:CreateButton(text, callback)
        local Btn = Instance.new("TextButton", Content)
        Btn.Size = UDim2.new(0.92, 0, 0, 32)
        Btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        Btn.Text = text
        Btn.TextColor3 = Color3.new(1, 1, 1)
        Btn.Font = Enum.Font.GothamBold
        Btn.TextSize = 11
        Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, CornerRadius == 0 and 0 or 6)
        
        Btn.MouseButton1Click:Connect(callback)
    end

    return Window
end

return Library
