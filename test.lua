local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local HttpService = game:GetService("HttpService")

local OrionMobile = {
    Elements = {},
    ThemeObjects = {},
    Connections = {},
    Flags = {},
    Themes = {
        Default = {
            Main = Color3.fromRGB(25, 25, 25),
            Second = Color3.fromRGB(32, 32, 32),
            Stroke = Color3.fromRGB(60, 60, 60),
            Divider = Color3.fromRGB(60, 60, 60),
            Text = Color3.fromRGB(240, 240, 240),
            TextDark = Color3.fromRGB(150, 150, 150)
        }
    },
    SelectedTheme = "Default",
    Folder = nil,
    SaveCfg = false,
    IsMobile = UserInputService.TouchEnabled,
    MobileScale = 1.5 -- Increased scale for mobile readability
}

-- Mobile-optimized element creation
local function Create(Name, Properties, Children)
    local Object = Instance.new(Name)
    for i, v in next, Properties or {} do
        Object[i] = v
    end
    for i, v in next, Children or {} do
        v.Parent = Object
    end
    return Object
end

local function CreateElement(ElementName, ElementFunction)
    OrionMobile.Elements[ElementName] = function(...)
        return ElementFunction(...)
    end
end

local function MakeElement(ElementName, ...)
    local NewElement = OrionMobile.Elements[ElementName](...)
    return NewElement
end

-- Mobile-optimized UI elements
CreateElement("Corner", function(Scale, Offset)
    return Create("UICorner", {
        CornerRadius = UDim.new(Scale or 0, (Offset or 10) * (OrionMobile.IsMobile and OrionMobile.MobileScale or 1))
    })
end)

CreateElement("Stroke", function(Color, Thickness)
    return Create("UIStroke", {
        Color = Color or Color3.fromRGB(255, 255, 255),
        Thickness = (Thickness or 1) * (OrionMobile.IsMobile and OrionMobile.MobileScale or 1)
    })
end)

CreateElement("List", function(Scale, Offset)
    return Create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(Scale or 0, (Offset or 0) * (OrionMobile.IsMobile and OrionMobile.MobileScale or 1))
    })
end)

CreateElement("Padding", function(Bottom, Left, Right, Top)
    return Create("UIPadding", {
        PaddingBottom = UDim.new(0, (Bottom or 4) * (OrionMobile.IsMobile and OrionMobile.MobileScale or 1)),
        PaddingLeft = UDim.new(0, (Left or 4) * (OrionMobile.IsMobile and OrionMobile.MobileScale or 1)),
        PaddingRight = UDim.new(0, (Right or 4) * (OrionMobile.IsMobile and OrionMobile.MobileScale or 1)),
        PaddingTop = UDim.new(0, (Top or 4) * (OrionMobile.IsMobile and OrionMobile.MobileScale or 1))
    })
end)

CreateElement("TFrame", function()
    return Create("Frame", {
        BackgroundTransparency = 1
    })
end)

CreateElement("Frame", function(Color)
    return Create("Frame", {
        BackgroundColor3 = Color or Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0
    })
end)

CreateElement("RoundFrame", function(Color, Scale, Offset)
    return Create("Frame", {
        BackgroundColor3 = Color or Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0
    }, {
        Create("UICorner", {
            CornerRadius = UDim.new(Scale, (Offset or 10) * (OrionMobile.IsMobile and OrionMobile.MobileScale or 1))
        })
    })
end)

CreateElement("Button", function()
    return Create("TextButton", {
        Text = "",
        AutoButtonColor = false,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        TextSize = 14 * (OrionMobile.IsMobile and OrionMobile.MobileScale or 1)
    })
end)

CreateElement("ScrollFrame", function(Color, Width)
    return Create("ScrollingFrame", {
        BackgroundTransparency = 1,
        ScrollBarImageColor3 = Color,
        BorderSizePixel = 0,
        ScrollBarThickness = (Width or 4) * (OrionMobile.IsMobile and OrionMobile.MobileScale or 1),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollingDirection = Enum.ScrollingDirection.Y
    })
end)

CreateElement("Label", function(Text, TextSize, Transparency)
    return Create("TextLabel", {
        Text = Text or "",
        TextColor3 = Color3.fromRGB(240, 240, 240),
        TextTransparency = Transparency or 0,
        TextSize = (TextSize or 15) * (OrionMobile.IsMobile and OrionMobile.MobileScale or 1),
        Font = Enum.Font.Gotham,
        RichText = true,
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left
    })
end)

-- Main UI container with mobile protection
local Orion = Instance.new("ScreenGui")
Orion.Name = "OrionMobile"
if syn then
    syn.protect_gui(Orion)
    Orion.Parent = game.CoreGui
elseif gethui then
    Orion.Parent = gethui()
else
    Orion.Parent = game:GetService("CoreGui")
end

-- Clean up any existing UI
for _, Interface in ipairs(Orion.Parent:GetChildren()) do
    if Interface.Name == Orion.Name and Interface ~= Orion then
        Interface:Destroy()
    end
end

-- Mobile-specific adjustments
if OrionMobile.IsMobile then
    -- Increase touch target sizes
    OrionMobile.MobileButtonSize = UDim2.new(1, -20, 0, 50)
    OrionMobile.MobileToggleSize = UDim2.new(0, 70, 0, 35)
    OrionMobile.MobileTextSize = 16
else
    OrionMobile.MobileButtonSize = UDim2.new(1, -20, 0, 35)
    OrionMobile.MobileToggleSize = UDim2.new(0, 50, 0, 25)
    OrionMobile.MobileTextSize = 14
end

-- Enhanced mobile window creation
function OrionMobile:MakeWindow(WindowConfig)
    WindowConfig = WindowConfig or {}
    WindowConfig.Name = WindowConfig.Name or "Orion Mobile"
    WindowConfig.Size = WindowConfig.Size or (OrionMobile.IsMobile and UDim2.new(0, 350 * OrionMobile.MobileScale, 0, 500 * OrionMobile.MobileScale) or UDim2.new(0, 500, 0, 400))
    WindowConfig.Position = WindowConfig.Position or UDim2.new(0.5, -(WindowConfig.Size.X.Offset/2), 0.5, -(WindowConfig.Size.Y.Offset/2))
    
    local Minimized = false
    local UIHidden = false
    
    -- Main window with mobile styling
    local MainWindow = Create("Frame", {
        Name = "MainWindow",
        Size = WindowConfig.Size,
        Position = WindowConfig.Position,
        BackgroundColor3 = OrionMobile.Themes[OrionMobile.SelectedTheme].Main,
        Parent = Orion,
        ClipsDescendants = true,
        Active = true -- Important for mobile touch
    }, {
        MakeElement("Corner", 0, 10),
        MakeElement("Stroke", OrionMobile.Themes[OrionMobile.SelectedTheme].Stroke, 1.5)
    })

    -- Title bar with mobile-friendly sizing
    local TitleBar = Create("Frame", {
        Name = "TitleBar",
        Size = UDim2.new(1, 0, 0, OrionMobile.IsMobile and 50 * OrionMobile.MobileScale or 40),
        BackgroundColor3 = OrionMobile.Themes[OrionMobile.SelectedTheme].Second,
        Parent = MainWindow
    }, {
        MakeElement("Corner", 0, 10, 10, 0),
        MakeElement("Stroke", OrionMobile.Themes[OrionMobile.SelectedTheme].Stroke, 1)
    })

    -- Window title with mobile sizing
    local TitleLabel = Create("TextLabel", {
        Name = "Title",
        Text = WindowConfig.Name,
        TextColor3 = OrionMobile.Themes[OrionMobile.SelectedTheme].Text,
        TextSize = (OrionMobile.IsMobile and 20 or 18) * OrionMobile.MobileScale,
        Font = Enum.Font.GothamBold,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -100 * OrionMobile.MobileScale, 1, 0),
        Position = UDim2.new(0, 15 * OrionMobile.MobileScale, 0, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = TitleBar
    })

    -- Mobile-optimized close button
    local CloseButton = Create("TextButton", {
        Name = "CloseButton",
        Text = "×", -- Larger symbol for mobile
        TextColor3 = OrionMobile.Themes[OrionMobile.SelectedTheme].Text,
        TextSize = (OrionMobile.IsMobile and 24 or 20) * OrionMobile.MobileScale,
        Font = Enum.Font.GothamBold,
        BackgroundColor3 = Color3.fromRGB(200, 50, 50),
        Size = UDim2.new(0, OrionMobile.IsMobile and 40 * OrionMobile.MobileScale or 30, 0, OrionMobile.IsMobile and 40 * OrionMobile.MobileScale or 30),
        Position = UDim2.new(1, -50 * OrionMobile.MobileScale, 0.5, -20 * OrionMobile.MobileScale),
        AnchorPoint = Vector2.new(1, 0.5),
        Parent = TitleBar
    }, {
        MakeElement("Corner", 1, 0)
    })

    -- Mobile-optimized minimize button
    local MinimizeButton = Create("TextButton", {
        Name = "MinimizeButton",
        Text = OrionMobile.IsMobile and "━" or "_", -- Different symbol for mobile
        TextColor3 = OrionMobile.Themes[OrionMobile.SelectedTheme].Text,
        TextSize = (OrionMobile.IsMobile and 24 or 20) * OrionMobile.MobileScale,
        Font = Enum.Font.GothamBold,
        BackgroundColor3 = OrionMobile.Themes[OrionMobile.SelectedTheme].Second,
        Size = UDim2.new(0, OrionMobile.IsMobile and 40 * OrionMobile.MobileScale or 30, 0, OrionMobile.IsMobile and 40 * OrionMobile.MobileScale or 30),
        Position = UDim2.new(1, -95 * OrionMobile.MobileScale, 0.5, -20 * OrionMobile.MobileScale),
        AnchorPoint = Vector2.new(1, 0.5),
        Parent = TitleBar
    }, {
        MakeElement("Corner", 1, 0)
    })

    -- Content area with mobile scrolling
    local ContentFrame = Create("ScrollingFrame", {
        Name = "Content",
        Size = UDim2.new(1, 0, 1, -(OrionMobile.IsMobile and 50 * OrionMobile.MobileScale or 40)),
        Position = UDim2.new(0, 0, 0, OrionMobile.IsMobile and 50 * OrionMobile.MobileScale or 40),
        BackgroundTransparency = 1,
        ScrollBarThickness = OrionMobile.IsMobile and 8 or 5,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        Parent = MainWindow,
        ScrollingEnabled = true,
        ElasticBehavior = Enum.ElasticBehavior.Always -- Better for mobile
    }, {
        MakeElement("List", 0, OrionMobile.IsMobile and 15 or 10),
        MakeElement("Padding", OrionMobile.IsMobile and 15 or 10, OrionMobile.IsMobile and 15 or 10, OrionMobile.IsMobile and 15 or 10, OrionMobile.IsMobile and 15 or 10)
    })

    -- Mobile-optimized dragging
    local Dragging, DragInput, MousePos, FramePos = false
    
    local function UpdateDrag(input)
        local Delta = input.Position - MousePos
        local NewPos = UDim2.new(FramePos.X.Scale, FramePos.X.Offset + Delta.X, FramePos.Y.Scale, FramePos.Y.Offset + Delta.Y)
        
        -- Keep window on screen (especially important for mobile)
        local viewportSize = workspace.CurrentCamera.ViewportSize
        NewPos = UDim2.new(
            NewPos.X.Scale, math.clamp(NewPos.X.Offset, 0, viewportSize.X - MainWindow.AbsoluteSize.X),
            NewPos.Y.Scale, math.clamp(NewPos.Y.Offset, 0, viewportSize.Y - MainWindow.AbsoluteSize.Y)
        )
        
        TweenService:Create(MainWindow, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {
            Position = NewPos
        }):Play()
    end

    TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            Dragging = true
            MousePos = input.Position
            FramePos = MainWindow.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    Dragging = false
                end
            end)
        end
    end)

    TitleBar.InputChanged:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
            DragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if (input == DragInput and Dragging) then
            UpdateDrag(input)
        end
    end)

    -- Button events with mobile haptic feedback
    CloseButton.MouseButton1Click:Connect(function()
        if OrionMobile.IsMobile then
            -- Simulate haptic feedback on mobile
            game:GetService("VibrationService"):Vibrate(0.1)
        end
        
        MainWindow.Visible = false
        UIHidden = true
        if WindowConfig.CloseCallback then
            WindowConfig.CloseCallback()
        end
    end)

    MinimizeButton.MouseButton1Click:Connect(function()
        if OrionMobile.IsMobile then
            game:GetService("VibrationService"):Vibrate(0.05)
        end
        
        Minimized = not Minimized
        if Minimized then
            TweenService:Create(MainWindow, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
                Size = UDim2.new(WindowConfig.Size.X.Scale, WindowConfig.Size.X.Offset, 0, OrionMobile.IsMobile and 50 * OrionMobile.MobileScale or 40)
            }):Play()
            ContentFrame.Visible = false
        else
            TweenService:Create(MainWindow, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
                Size = WindowConfig.Size
            }):Play()
            ContentFrame.Visible = true
        end
    end)

    -- Show/hide with RightShift (or touch gesture for mobile)
    if OrionMobile.IsMobile then
        -- Add a hidden button to reopen UI
        local ReopenButton = Create("TextButton", {
            Name = "ReopenButton",
            Text = "≡",
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 24 * OrionMobile.MobileScale,
            BackgroundColor3 = Color3.fromRGB(40, 40, 40),
            Size = UDim2.new(0, 50 * OrionMobile.MobileScale, 0, 50 * OrionMobile.MobileScale),
            Position = UDim2.new(0, 20, 1, -70 * OrionMobile.MobileScale),
            AnchorPoint = Vector2.new(0, 1),
            Visible = false,
            Parent = Orion
        }, {
            MakeElement("Corner", 1, 0),
            MakeElement("Stroke", Color3.fromRGB(80, 80, 80), 2)
        })
        
        ReopenButton.MouseButton1Click:Connect(function()
            game:GetService("VibrationService"):Vibrate(0.1)
            MainWindow.Visible = true
            UIHidden = false
            ReopenButton.Visible = false
        end)
        
        CloseButton.MouseButton1Click:Connect(function()
            ReopenButton.Visible = true
        end)
    else
        UserInputService.InputBegan:Connect(function(input)
            if input.KeyCode == Enum.KeyCode.RightShift and UIHidden then
                MainWindow.Visible = true
                UIHidden = false
            end
        end)
    end

    -- Tab system with mobile gestures
    local TabFunctions = {}
    
    function TabFunctions:AddTab(TabName)
        -- Mobile-optimized tab button
        local TabButton = Create("TextButton", {
            Name = TabName,
            Text = TabName,
            TextColor3 = OrionMobile.Themes[OrionMobile.SelectedTheme].Text,
            TextSize = OrionMobile.MobileTextSize * OrionMobile.MobileScale,
            Font = Enum.Font.GothamSemibold,
            BackgroundColor3 = OrionMobile.Themes[OrionMobile.SelectedTheme].Second,
            Size = UDim2.new(0, OrionMobile.IsMobile and 120 * OrionMobile.MobileScale or 100, 0, OrionMobile.IsMobile and 40 * OrionMobile.MobileScale or 30),
            Parent = ContentFrame,
            AutoButtonColor = false
        }, {
            MakeElement("Corner", 0, 5),
            MakeElement("Stroke", OrionMobile.Themes[OrionMobile.SelectedTheme].Stroke, 1)
        })
        
        -- Mobile-optimized tab content
        local TabContent = Create("ScrollingFrame", {
            Name = TabName.."Content",
            Size = UDim2.new(1, 0, 1, -(OrionMobile.IsMobile and 50 * OrionMobile.MobileScale or 40)),
            Position = UDim2.new(0, 0, 0, OrionMobile.IsMobile and 50 * OrionMobile.MobileScale or 40),
            BackgroundTransparency = 1,
            Visible = false,
            ScrollBarThickness = OrionMobile.IsMobile and 8 or 5,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            Parent = MainWindow,
            ScrollingEnabled = true,
            ElasticBehavior = Enum.ElasticBehavior.Always
        }, {
            MakeElement("List", 0, OrionMobile.IsMobile and 15 or 10),
            MakeElement("Padding", OrionMobile.IsMobile and 15 or 10, OrionMobile.IsMobile and 15 or 10, OrionMobile.IsMobile and 15 or 10, OrionMobile.IsMobile and 15 or 10)
        })
        
        TabButton.MouseButton1Click:Connect(function()
            if OrionMobile.IsMobile then
                game:GetService("VibrationService"):Vibrate(0.05)
            end
            
            -- Hide all tab contents
            for _, child in pairs(MainWindow:GetChildren()) do
                if child.Name:find("Content") and child:IsA("ScrollingFrame") then
                    child.Visible = false
                end
            end
            
            -- Show this tab's content
            TabContent.Visible = true
            
            -- Highlight selected tab
            for _, btn in pairs(ContentFrame:GetChildren()) do
                if btn:IsA("TextButton") then
                    TweenService:Create(btn, TweenInfo.new(0.2), {
                        BackgroundColor3 = OrionMobile.Themes[OrionMobile.SelectedTheme].Second,
                        TextColor3 = OrionMobile.Themes[OrionMobile.SelectedTheme].TextDark
                    }):Play()
                end
            end
            
            TweenService:Create(TabButton, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(
                    OrionMobile.Themes[OrionMobile.SelectedTheme].Second.R * 255 + 20,
                    OrionMobile.Themes[OrionMobile.SelectedTheme].Second.G * 255 + 20,
                    OrionMobile.Themes[OrionMobile.SelectedTheme].Second.B * 255 + 20
                ),
                TextColor3 = OrionMobile.Themes[OrionMobile.SelectedTheme].Text
            }):Play()
        end)
        
        -- Make first tab visible by default
        if #ContentFrame:GetChildren() == 3 then -- UIListLayout, UIPadding, and this tab
            TabContent.Visible = true
            TweenService:Create(TabButton, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(
                    OrionMobile.Themes[OrionMobile.SelectedTheme].Second.R * 255 + 20,
                    OrionMobile.Themes[OrionMobile.SelectedTheme].Second.G * 255 + 20,
                    OrionMobile.Themes[OrionMobile.SelectedTheme].Second.B * 255 + 20
                ),
                TextColor3 = OrionMobile.Themes[OrionMobile.SelectedTheme].Text
            }):Play()
        end
        
        -- Element creation functions for this tab
        local ElementFunctions = {}
        
        function ElementFunctions:AddButton(ButtonConfig)
            ButtonConfig = ButtonConfig or {}
            ButtonConfig.Name = ButtonConfig.Name or "Button"
            ButtonConfig.Callback = ButtonConfig.Callback or function() end
            
            -- Mobile-optimized button
            local Button = Create("TextButton", {
                Name = ButtonConfig.Name,
                Text = ButtonConfig.Name,
                TextColor3 = OrionMobile.Themes[OrionMobile.SelectedTheme].Text,
                TextSize = OrionMobile.MobileTextSize * OrionMobile.MobileScale,
                Font = Enum.Font.GothamSemibold,
                BackgroundColor3 = OrionMobile.Themes[OrionMobile.SelectedTheme].Second,
                Size = OrionMobile.MobileButtonSize,
                Parent = TabContent,
                AutoButtonColor = false
            }, {
                MakeElement("Corner", 0, 5),
                MakeElement("Stroke", OrionMobile.Themes[OrionMobile.SelectedTheme].Stroke, 1)
            })
            
            -- Button animations with mobile feedback
            local function ButtonDown()
                TweenService:Create(Button, TweenInfo.new(0.1), {
                    BackgroundColor3 = Color3.fromRGB(
                        OrionMobile.Themes[OrionMobile.SelectedTheme].Second.R * 255 + 30,
                        OrionMobile.Themes[OrionMobile.SelectedTheme].Second.G * 255 + 30,
                        OrionMobile.Themes[OrionMobile.SelectedTheme].Second.B * 255 + 30
                    ),
                    Size = OrionMobile.IsMobile and UDim2.new(1, -15, 0, OrionMobile.MobileButtonSize.Y.Offset - 5) or OrionMobile.MobileButtonSize
                }):Play()
                
                if OrionMobile.IsMobile then
                    game:GetService("VibrationService"):Vibrate(0.05)
                end
            end
            
            local function ButtonUp()
                TweenService:Create(Button, TweenInfo.new(0.2), {
                    BackgroundColor3 = OrionMobile.Themes[OrionMobile.SelectedTheme].Second,
                    Size = OrionMobile.MobileButtonSize
                }):Play()
            end
            
            Button.MouseButton1Down:Connect(ButtonDown)
            if OrionMobile.IsMobile then
                Button.TouchLongPress:Connect(ButtonDown)
                Button.TouchEnded:Connect(ButtonUp)
            end
            Button.MouseButton1Up:Connect(ButtonUp)
            Button.MouseLeave:Connect(ButtonUp)
            
            Button.MouseButton1Click:Connect(function()
                ButtonConfig.Callback()
            end)
            
            local ButtonFunctions = {}
            
            function ButtonFunctions:SetText(NewText)
                Button.Text = NewText
            end
            
            return ButtonFunctions
        end
        
        function ElementFunctions:AddLabel(LabelConfig)
            LabelConfig = LabelConfig or {}
            LabelConfig.Text = LabelConfig.Text or "Label"
            
            local Label = Create("TextLabel", {
                Name = "Label",
                Text = LabelConfig.Text,
                TextColor3 = OrionMobile.Themes[OrionMobile.SelectedTheme].Text,
                TextSize = OrionMobile.MobileTextSize * OrionMobile.MobileScale,
                Font = Enum.Font.GothamSemibold,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, OrionMobile.IsMobile and 40 or 30),
                Parent = TabContent
            })
            
            local LabelFunctions = {}
            
            function LabelFunctions:SetText(NewText)
                Label.Text = NewText
            end
            
            return LabelFunctions
        end
        
        function ElementFunctions:AddToggle(ToggleConfig)
            ToggleConfig = ToggleConfig or {}
            ToggleConfig.Name = ToggleConfig.Name or "Toggle"
            ToggleConfig.Default = ToggleConfig.Default or false
            ToggleConfig.Callback = ToggleConfig.Callback or function() end
            
            local Toggle = {Value = ToggleConfig.Default}
            
            -- Mobile-optimized toggle
            local ToggleFrame = Create("Frame", {
                Name = ToggleConfig.Name,
                BackgroundColor3 = OrionMobile.Themes[OrionMobile.SelectedTheme].Second,
                Size = UDim2.new(1, 0, 0, OrionMobile.IsMobile and 50 or 35),
                Parent = TabContent
            }, {
                MakeElement("Corner", 0, 5),
                MakeElement("Stroke", OrionMobile.Themes[OrionMobile.SelectedTheme].Stroke, 1)
            })
            
            local ToggleLabel = Create("TextLabel", {
                Name = "Label",
                Text = ToggleConfig.Name,
                TextColor3 = OrionMobile.Themes[OrionMobile.SelectedTheme].Text,
                TextSize = OrionMobile.MobileTextSize * OrionMobile.MobileScale,
                Font = Enum.Font.GothamSemibold,
                BackgroundTransparency = 1,
                Size = UDim2.new(0.7, 0, 1, 0),
                Position = UDim2.new(0, 15 * OrionMobile.MobileScale, 0, 0),
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = ToggleFrame
            })
            
            local ToggleButton = Create("Frame", {
                Name = "Toggle",
                BackgroundColor3 = ToggleConfig.Default and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(170, 0, 0),
                Size = OrionMobile.MobileToggleSize,
                Position = UDim2.new(1, -80 * OrionMobile.MobileScale, 0.5, -OrionMobile.MobileToggleSize.Y.Offset/2),
                AnchorPoint = Vector2.new(1, 0.5),
                Parent = ToggleFrame
            }, {
                MakeElement("Corner", 0, OrionMobile.MobileToggleSize.Y.Offset/2),
                MakeElement("Stroke", OrionMobile.Themes[OrionMobile.SelectedTheme].Stroke, 1)
            })
            
            local ToggleIndicator = Create("Frame", {
                Name = "Indicator",
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                Size = UDim2.new(0, OrionMobile.MobileToggleSize.Y.Offset - 10, 0, OrionMobile.MobileToggleSize.Y.Offset - 10),
                Position = ToggleConfig.Default and UDim2.new(1, -(OrionMobile.MobileToggleSize.Y.Offset/2 + 5), 0.5, -(OrionMobile.MobileToggleSize.Y.Offset/2 - 5)) or UDim2.new(0, OrionMobile.MobileToggleSize.Y.Offset/2 + 5, 0.5, -(OrionMobile.MobileToggleSize.Y.Offset/2 - 5)),
                AnchorPoint = Vector2.new(1, 0.5),
                Parent = ToggleButton
            }, {
                MakeElement("Corner", 0, OrionMobile.MobileToggleSize.Y.Offset/2 - 5),
                MakeElement("Stroke", OrionMobile.Themes[OrionMobile.SelectedTheme].Stroke, 1)
            })
            
            local ToggleClick = Create("TextButton", {
                Name = "ClickArea",
                Text = "",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                Parent = ToggleFrame
            })
            
            ToggleClick.MouseButton1Click:Connect(function()
                if OrionMobile.IsMobile then
                    game:GetService("VibrationService"):Vibrate(0.05)
                end
                
                Toggle.Value = not Toggle.Value
                
                if Toggle.Value then
                    TweenService:Create(ToggleButton, TweenInfo.new(0.2), {
                        BackgroundColor3 = Color3.fromRGB(0, 170, 0)
                    }):Play()
                    TweenService:Create(ToggleIndicator, TweenInfo.new(0.2), {
                        Position = UDim2.new(1, -(OrionMobile.MobileToggleSize.Y.Offset/2 + 5), 0.5, -(OrionMobile.MobileToggleSize.Y.Offset/2 - 5))
                    }):Play()
                else
                    TweenService:Create(ToggleButton, TweenInfo.new(0.2), {
                        BackgroundColor3 = Color3.fromRGB(170, 0, 0)
                    }):Play()
                    TweenService:Create(ToggleIndicator, TweenInfo.new(0.2), {
                        Position = UDim2.new(0, OrionMobile.MobileToggleSize.Y.Offset/2 + 5, 0.5, -(OrionMobile.MobileToggleSize.Y.Offset/2 - 5))
                    }):Play()
                end
                
                ToggleConfig.Callback(Toggle.Value)
            end)
            
            local ToggleFunctions = {}
            
            function ToggleFunctions:SetValue(Value)
                Toggle.Value = Value
                
                if Toggle.Value then
                    ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
                    ToggleIndicator.Position = UDim2.new(1, -(OrionMobile.MobileToggleSize.Y.Offset/2 + 5), 0.5, -(OrionMobile.MobileToggleSize.Y.Offset/2 - 5))
                else
                    ToggleButton.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
                    ToggleIndicator.Position = UDim2.new(0, OrionMobile.MobileToggleSize.Y.Offset/2 + 5, 0.5, -(OrionMobile.MobileToggleSize.Y.Offset/2 - 5))
                end
                
                ToggleConfig.Callback(Toggle.Value)
            end
            
            return ToggleFunctions
        end
        
        return ElementFunctions
    end
    
    return TabFunctions
end

-- Mobile-optimized notification system
function OrionMobile:MakeNotification(NotificationConfig)
    NotificationConfig = NotificationConfig or {}
    NotificationConfig.Name = NotificationConfig.Name or "Notification"
    NotificationConfig.Content = NotificationConfig.Content or "This is a notification"
    NotificationConfig.Time = NotificationConfig.Time or 5
    
    -- Mobile-optimized notification
    local Notification = Create("Frame", {
        Name = "Notification",
        Size = UDim2.new(0, OrionMobile.IsMobile and 300 * OrionMobile.MobileScale or 300, 0, OrionMobile.IsMobile and 120 * OrionMobile.MobileScale or 100),
        Position = UDim2.new(1, 10 * OrionMobile.MobileScale, 1, -130 * OrionMobile.MobileScale),
        AnchorPoint = Vector2.new(1, 1),
        BackgroundColor3 = OrionMobile.Themes[OrionMobile.SelectedTheme].Main,
        Parent = Orion,
        Active = true
    }, {
        MakeElement("Corner", 0, 10),
        MakeElement("Stroke", OrionMobile.Themes[OrionMobile.SelectedTheme].Stroke, 1.5)
    })
    
    local Title = Create("TextLabel", {
        Name = "Title",
        Text = NotificationConfig.Name,
        TextColor3 = OrionMobile.Themes[OrionMobile.SelectedTheme].Text,
        TextSize = (OrionMobile.IsMobile and 18 or 16) * OrionMobile.MobileScale,
        Font = Enum.Font.GothamBold,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -20 * OrionMobile.MobileScale, 0, OrionMobile.IsMobile and 30 * OrionMobile.MobileScale or 25),
        Position = UDim2.new(0, 15 * OrionMobile.MobileScale, 0, 10 * OrionMobile.MobileScale),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Notification
    })
    
    local Content = Create("TextLabel", {
        Name = "Content",
        Text = NotificationConfig.Content,
        TextColor3 = OrionMobile.Themes[OrionMobile.SelectedTheme].TextDark,
        TextSize = (OrionMobile.IsMobile and 16 or 14) * OrionMobile.MobileScale,
        Font = Enum.Font.Gotham,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -20 * OrionMobile.MobileScale, 1, -(OrionMobile.IsMobile and 50 * OrionMobile.MobileScale or 45)),
        Position = UDim2.new(0, 15 * OrionMobile.MobileScale, 0, OrionMobile.IsMobile and 45 * OrionMobile.MobileScale or 35),
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        TextWrapped = true,
        Parent = Notification
    })
    
    -- Mobile vibration when notification appears
    if OrionMobile.IsMobile then
        game:GetService("VibrationService"):Vibrate(0.1)
    end
    
    -- Animation
    Notification.Position = UDim2.new(1, 310 * OrionMobile.MobileScale, 1, -130 * OrionMobile.MobileScale)
    TweenService:Create(Notification, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {
        Position = UDim2.new(1, 10 * OrionMobile.MobileScale, 1, -130 * OrionMobile.MobileScale)
    }):Play()
    
    -- Auto-close after time
    delay(NotificationConfig.Time, function()
        TweenService:Create(Notification, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {
            Position = UDim2.new(1, 310 * OrionMobile.MobileScale, 1, -130 * OrionMobile.MobileScale)
        }):Play()
        wait(0.5)
        Notification:Destroy()
    end)
end

-- Destroy function
function OrionMobile:Destroy()
    Orion:Destroy()
end

return OrionMobile
