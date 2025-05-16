local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local HttpService = game:GetService("HttpService")

local ResponsiveUI = {
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
    IsMobile = UserInputService.TouchEnabled
}

-- Responsive scaling function
local function GetScale()
    if ResponsiveUI.IsMobile then
        return 1.5 -- Larger scale for mobile
    else
        return 1 -- Normal scale for PC
    end
end

-- Element creation functions
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
    ResponsiveUI.Elements[ElementName] = function(...)
        return ElementFunction(...)
    end
end

local function MakeElement(ElementName, ...)
    local NewElement = ResponsiveUI.Elements[ElementName](...)
    return NewElement
end

-- Basic UI elements
CreateElement("Corner", function(Scale, Offset)
    return Create("UICorner", {
        CornerRadius = UDim.new(Scale or 0, Offset or 10 * GetScale())
    })
end)

CreateElement("Stroke", function(Color, Thickness)
    return Create("UIStroke", {
        Color = Color or Color3.fromRGB(255, 255, 255),
        Thickness = Thickness or 1 * GetScale()
    })
end)

CreateElement("List", function(Scale, Offset)
    return Create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(Scale or 0, Offset or 0)
    })
end)

CreateElement("Padding", function(Bottom, Left, Right, Top)
    return Create("UIPadding", {
        PaddingBottom = UDim.new(0, (Bottom or 4) * GetScale()),
        PaddingLeft = UDim.new(0, (Left or 4) * GetScale()),
        PaddingRight = UDim.new(0, (Right or 4) * GetScale()),
        PaddingTop = UDim.new(0, (Top or 4) * GetScale())
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
            CornerRadius = UDim.new(Scale, Offset * GetScale())
        })
    })
end)

CreateElement("Button", function()
    return Create("TextButton", {
        Text = "",
        AutoButtonColor = false,
        BackgroundTransparency = 1,
        BorderSizePixel = 0
    })
end)

CreateElement("ScrollFrame", function(Color, Width)
    return Create("ScrollingFrame", {
        BackgroundTransparency = 1,
        ScrollBarImageColor3 = Color,
        BorderSizePixel = 0,
        ScrollBarThickness = (Width or 4) * GetScale(),
        CanvasSize = UDim2.new(0, 0, 0, 0)
    })
end)

CreateElement("Label", function(Text, TextSize, Transparency)
    return Create("TextLabel", {
        Text = Text or "",
        TextColor3 = Color3.fromRGB(240, 240, 240),
        TextTransparency = Transparency or 0,
        TextSize = (TextSize or 15) * GetScale(),
        Font = Enum.Font.Gotham,
        RichText = true,
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left
    })
end)

-- Main UI container
local UI = Instance.new("ScreenGui")
UI.Name = "ResponsiveUI"
if syn then
    syn.protect_gui(UI)
    UI.Parent = game.CoreGui
else
    UI.Parent = gethui() or game.CoreGui
end

-- Clean up any existing UI
if gethui then
    for _, Interface in ipairs(gethui():GetChildren()) do
        if Interface.Name == UI.Name and Interface ~= UI then
            Interface:Destroy()
        end
    end
else
    for _, Interface in ipairs(game.CoreGui:GetChildren()) do
        if Interface.Name == UI.Name and Interface ~= UI then
            Interface:Destroy()
        end
    end
end

-- Window creation function
function ResponsiveUI:MakeWindow(WindowConfig)
    WindowConfig = WindowConfig or {}
    WindowConfig.Name = WindowConfig.Name or "Responsive UI"
    WindowConfig.Size = WindowConfig.Size or UDim2.new(0, 500 * GetScale(), 0, 400 * GetScale())
    WindowConfig.Position = WindowConfig.Position or UDim2.new(0.5, -250 * GetScale(), 0.5, -200 * GetScale())
    
    local Minimized = false
    local UIHidden = false
    
    -- Main window frame
    local MainWindow = Create("Frame", {
        Name = "MainWindow",
        Size = WindowConfig.Size,
        Position = WindowConfig.Position,
        BackgroundColor3 = ResponsiveUI.Themes[ResponsiveUI.SelectedTheme].Main,
        Parent = UI,
        ClipsDescendants = true
    }, {
        MakeElement("Corner", 0, 10),
        MakeElement("Stroke", ResponsiveUI.Themes[ResponsiveUI.SelectedTheme].Stroke, 1)
    })
    
    -- Title bar
    local TitleBar = Create("Frame", {
        Name = "TitleBar",
        Size = UDim2.new(1, 0, 0, 40 * GetScale()),
        BackgroundColor3 = ResponsiveUI.Themes[ResponsiveUI.SelectedTheme].Second,
        Parent = MainWindow
    }, {
        MakeElement("Corner", 0, 10, 10, 0),
        MakeElement("Stroke", ResponsiveUI.Themes[ResponsiveUI.SelectedTheme].Stroke, 1)
    })
    
    -- Window title
    local TitleLabel = Create("TextLabel", {
        Name = "Title",
        Text = WindowConfig.Name,
        TextColor3 = ResponsiveUI.Themes[ResponsiveUI.SelectedTheme].Text,
        TextSize = 18 * GetScale(),
        Font = Enum.Font.GothamBold,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -100 * GetScale(), 1, 0),
        Position = UDim2.new(0, 10 * GetScale(), 0, 0),
        Parent = TitleBar
    })
    
    -- Close button
    local CloseButton = Create("TextButton", {
        Name = "CloseButton",
        Text = "X",
        TextColor3 = ResponsiveUI.Themes[ResponsiveUI.SelectedTheme].Text,
        TextSize = 16 * GetScale(),
        Font = Enum.Font.GothamBold,
        BackgroundColor3 = Color3.fromRGB(255, 50, 50),
        Size = UDim2.new(0, 30 * GetScale(), 0, 30 * GetScale()),
        Position = UDim2.new(1, -35 * GetScale(), 0.5, -15 * GetScale()),
        AnchorPoint = Vector2.new(1, 0.5),
        Parent = TitleBar
    }, {
        MakeElement("Corner", 0, 5)
    })
    
    -- Minimize button
    local MinimizeButton = Create("TextButton", {
        Name = "MinimizeButton",
        Text = "_",
        TextColor3 = ResponsiveUI.Themes[ResponsiveUI.SelectedTheme].Text,
        TextSize = 16 * GetScale(),
        Font = Enum.Font.GothamBold,
        BackgroundColor3 = ResponsiveUI.Themes[ResponsiveUI.SelectedTheme].Second,
        Size = UDim2.new(0, 30 * GetScale(), 0, 30 * GetScale()),
        Position = UDim2.new(1, -70 * GetScale(), 0.5, -15 * GetScale()),
        AnchorPoint = Vector2.new(1, 0.5),
        Parent = TitleBar
    }, {
        MakeElement("Corner", 0, 5)
    })
    
    -- Content area
    local ContentFrame = Create("ScrollingFrame", {
        Name = "Content",
        Size = UDim2.new(1, 0, 1, -40 * GetScale()),
        Position = UDim2.new(0, 0, 0, 40 * GetScale()),
        BackgroundTransparency = 1,
        ScrollBarThickness = 5 * GetScale(),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        Parent = MainWindow
    }, {
        MakeElement("List", 0, 10),
        MakeElement("Padding", 10, 10, 10, 10)
    })
    
    -- Dragging functionality
    local Dragging, DragInput, MousePos, FramePos = false
    
    TitleBar.InputBegan:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 then
            Dragging = true
            MousePos = Input.Position
            FramePos = MainWindow.Position
            
            Input.Changed:Connect(function()
                if Input.UserInputState == Enum.UserInputState.End then
                    Dragging = false
                end
            end)
        end
    end)
    
    TitleBar.InputChanged:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseMovement then
            DragInput = Input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(Input)
        if Input == DragInput and Dragging then
            local Delta = Input.Position - MousePos
            TweenService:Create(MainWindow, TweenInfo.new(0.45, Enum.EasingStyle.Quint), {
                Position = UDim2.new(FramePos.X.Scale, FramePos.X.Offset + Delta.X, FramePos.Y.Scale, FramePos.Y.Offset + Delta.Y)
            }):Play()
        end
    end)
    
    -- Button events
    CloseButton.MouseButton1Click:Connect(function()
        MainWindow.Visible = false
        UIHidden = true
        if WindowConfig.CloseCallback then
            WindowConfig.CloseCallback()
        end
    end)
    
    MinimizeButton.MouseButton1Click:Connect(function()
        Minimized = not Minimized
        if Minimized then
            TweenService:Create(MainWindow, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
                Size = UDim2.new(WindowConfig.Size.X.Scale, WindowConfig.Size.X.Offset, 0, 40 * GetScale())
            }):Play()
            ContentFrame.Visible = false
        else
            TweenService:Create(MainWindow, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
                Size = WindowConfig.Size
            }):Play()
            ContentFrame.Visible = true
        end
    end)
    
    -- Show/hide with RightShift
    UserInputService.InputBegan:Connect(function(Input)
        if Input.KeyCode == Enum.KeyCode.RightShift and UIHidden then
            MainWindow.Visible = true
            UIHidden = false
        end
    end)
    
    -- Tab system
    local TabFunctions = {}
    
    function TabFunctions:AddTab(TabName)
        local TabButton = Create("TextButton", {
            Name = TabName,
            Text = TabName,
            TextColor3 = ResponsiveUI.Themes[ResponsiveUI.SelectedTheme].Text,
            TextSize = 14 * GetScale(),
            Font = Enum.Font.GothamSemibold,
            BackgroundColor3 = ResponsiveUI.Themes[ResponsiveUI.SelectedTheme].Second,
            Size = UDim2.new(0, 100 * GetScale(), 0, 30 * GetScale()),
            Parent = ContentFrame
        }, {
            MakeElement("Corner", 0, 5)
        })
        
        local TabContent = Create("ScrollingFrame", {
            Name = TabName.."Content",
            Size = UDim2.new(1, 0, 1, -40 * GetScale()),
            Position = UDim2.new(0, 0, 0, 40 * GetScale()),
            BackgroundTransparency = 1,
            Visible = false,
            ScrollBarThickness = 5 * GetScale(),
            CanvasSize = UDim2.new(0, 0, 0, 0),
            Parent = MainWindow
        }, {
            MakeElement("List", 0, 10),
            MakeElement("Padding", 10, 10, 10, 10)
        })
        
        TabButton.MouseButton1Click:Connect(function()
            -- Hide all tab contents
            for _, child in pairs(MainWindow:GetChildren()) do
                if child.Name:find("Content") and child:IsA("ScrollingFrame") then
                    child.Visible = false
                end
            end
            
            -- Show this tab's content
            TabContent.Visible = true
        end)
        
        -- Make first tab visible by default
        if #ContentFrame:GetChildren() == 3 then -- 3 because of UIListLayout, UIPadding, and this tab
            TabContent.Visible = true
        end
        
        -- Element creation functions for this tab
        local ElementFunctions = {}
        
        function ElementFunctions:AddButton(ButtonConfig)
            ButtonConfig = ButtonConfig or {}
            ButtonConfig.Name = ButtonConfig.Name or "Button"
            ButtonConfig.Callback = ButtonConfig.Callback or function() end
            
            local Button = Create("TextButton", {
                Name = ButtonConfig.Name,
                Text = ButtonConfig.Name,
                TextColor3 = ResponsiveUI.Themes[ResponsiveUI.SelectedTheme].Text,
                TextSize = 14 * GetScale(),
                Font = Enum.Font.GothamSemibold,
                BackgroundColor3 = ResponsiveUI.Themes[ResponsiveUI.SelectedTheme].Second,
                Size = UDim2.new(1, 0, 0, 35 * GetScale()),
                Parent = TabContent
            }, {
                MakeElement("Corner", 0, 5),
                MakeElement("Stroke", ResponsiveUI.Themes[ResponsiveUI.SelectedTheme].Stroke, 1)
            })
            
            -- Button animations
            Button.MouseEnter:Connect(function()
                TweenService:Create(Button, TweenInfo.new(0.2), {
                    BackgroundColor3 = Color3.fromRGB(
                        ResponsiveUI.Themes[ResponsiveUI.SelectedTheme].Second.R * 255 + 10,
                        ResponsiveUI.Themes[ResponsiveUI.SelectedTheme].Second.G * 255 + 10,
                        ResponsiveUI.Themes[ResponsiveUI.SelectedTheme].Second.B * 255 + 10
                    )
                }):Play()
            end)
            
            Button.MouseLeave:Connect(function()
                TweenService:Create(Button, TweenInfo.new(0.2), {
                    BackgroundColor3 = ResponsiveUI.Themes[ResponsiveUI.SelectedTheme].Second
                }):Play()
            end)
            
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
                TextColor3 = ResponsiveUI.Themes[ResponsiveUI.SelectedTheme].Text,
                TextSize = 14 * GetScale(),
                Font = Enum.Font.GothamSemibold,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 30 * GetScale()),
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
            
            local ToggleFrame = Create("Frame", {
                Name = ToggleConfig.Name,
                BackgroundColor3 = ResponsiveUI.Themes[ResponsiveUI.SelectedTheme].Second,
                Size = UDim2.new(1, 0, 0, 35 * GetScale()),
                Parent = TabContent
            }, {
                MakeElement("Corner", 0, 5),
                MakeElement("Stroke", ResponsiveUI.Themes[ResponsiveUI.SelectedTheme].Stroke, 1)
            })
            
            local ToggleLabel = Create("TextLabel", {
                Name = "Label",
                Text = ToggleConfig.Name,
                TextColor3 = ResponsiveUI.Themes[ResponsiveUI.SelectedTheme].Text,
                TextSize = 14 * GetScale(),
                Font = Enum.Font.GothamSemibold,
                BackgroundTransparency = 1,
                Size = UDim2.new(0.7, 0, 1, 0),
                Position = UDim2.new(0, 10 * GetScale(), 0, 0),
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = ToggleFrame
            })
            
            local ToggleButton = Create("Frame", {
                Name = "Toggle",
                BackgroundColor3 = ToggleConfig.Default and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(170, 0, 0),
                Size = UDim2.new(0, 50 * GetScale(), 0, 25 * GetScale()),
                Position = UDim2.new(1, -60 * GetScale(), 0.5, -12.5 * GetScale()),
                AnchorPoint = Vector2.new(1, 0.5),
                Parent = ToggleFrame
            }, {
                MakeElement("Corner", 0, 12.5),
                MakeElement("Stroke", ResponsiveUI.Themes[ResponsiveUI.SelectedTheme].Stroke, 1)
            })
            
            local ToggleIndicator = Create("Frame", {
                Name = "Indicator",
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                Size = UDim2.new(0, 20 * GetScale(), 0, 20 * GetScale()),
                Position = ToggleConfig.Default and UDim2.new(1, -25 * GetScale(), 0.5, -10 * GetScale()) or UDim2.new(0, 5 * GetScale(), 0.5, -10 * GetScale()),
                AnchorPoint = Vector2.new(1, 0.5),
                Parent = ToggleButton
            }, {
                MakeElement("Corner", 0, 10),
                MakeElement("Stroke", ResponsiveUI.Themes[ResponsiveUI.SelectedTheme].Stroke, 1)
            })
            
            local ToggleClick = Create("TextButton", {
                Name = "ClickArea",
                Text = "",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                Parent = ToggleFrame
            })
            
            ToggleClick.MouseButton1Click:Connect(function()
                Toggle.Value = not Toggle.Value
                
                if Toggle.Value then
                    TweenService:Create(ToggleButton, TweenInfo.new(0.2), {
                        BackgroundColor3 = Color3.fromRGB(0, 170, 0)
                    }):Play()
                    TweenService:Create(ToggleIndicator, TweenInfo.new(0.2), {
                        Position = UDim2.new(1, -25 * GetScale(), 0.5, -10 * GetScale())
                    }):Play()
                else
                    TweenService:Create(ToggleButton, TweenInfo.new(0.2), {
                        BackgroundColor3 = Color3.fromRGB(170, 0, 0)
                    }):Play()
                    TweenService:Create(ToggleIndicator, TweenInfo.new(0.2), {
                        Position = UDim2.new(0, 5 * GetScale(), 0.5, -10 * GetScale())
                    }):Play()
                end
                
                ToggleConfig.Callback(Toggle.Value)
            end)
            
            local ToggleFunctions = {}
            
            function ToggleFunctions:SetValue(Value)
                Toggle.Value = Value
                
                if Toggle.Value then
                    ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
                    ToggleIndicator.Position = UDim2.new(1, -25 * GetScale(), 0.5, -10 * GetScale())
                else
                    ToggleButton.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
                    ToggleIndicator.Position = UDim2.new(0, 5 * GetScale(), 0.5, -10 * GetScale())
                end
                
                ToggleConfig.Callback(Toggle.Value)
            end
            
            return ToggleFunctions
        end
        
        return ElementFunctions
    end
    
    return TabFunctions
end

-- Notification system
function ResponsiveUI:MakeNotification(NotificationConfig)
    NotificationConfig = NotificationConfig or {}
    NotificationConfig.Name = NotificationConfig.Name or "Notification"
    NotificationConfig.Content = NotificationConfig.Content or "This is a notification"
    NotificationConfig.Time = NotificationConfig.Time or 5
    
    local Notification = Create("Frame", {
        Name = "Notification",
        Size = UDim2.new(0, 300 * GetScale(), 0, 100 * GetScale()),
        Position = UDim2.new(1, 10 * GetScale(), 1, -110 * GetScale()),
        AnchorPoint = Vector2.new(1, 1),
        BackgroundColor3 = ResponsiveUI.Themes[ResponsiveUI.SelectedTheme].Main,
        Parent = UI
    }, {
        MakeElement("Corner", 0, 10),
        MakeElement("Stroke", ResponsiveUI.Themes[ResponsiveUI.SelectedTheme].Stroke, 1)
    })
    
    local Title = Create("TextLabel", {
        Name = "Title",
        Text = NotificationConfig.Name,
        TextColor3 = ResponsiveUI.Themes[ResponsiveUI.SelectedTheme].Text,
        TextSize = 16 * GetScale(),
        Font = Enum.Font.GothamBold,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -20 * GetScale(), 0, 25 * GetScale()),
        Position = UDim2.new(0, 10 * GetScale(), 0, 10 * GetScale()),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Notification
    })
    
    local Content = Create("TextLabel", {
        Name = "Content",
        Text = NotificationConfig.Content,
        TextColor3 = ResponsiveUI.Themes[ResponsiveUI.SelectedTheme].TextDark,
        TextSize = 14 * GetScale(),
        Font = Enum.Font.Gotham,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -20 * GetScale(), 1, -45 * GetScale()),
        Position = UDim2.new(0, 10 * GetScale(), 0, 35 * GetScale()),
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        TextWrapped = true,
        Parent = Notification
    })
    
    -- Animation
    Notification.Position = UDim2.new(1, 310 * GetScale(), 1, -110 * GetScale())
    TweenService:Create(Notification, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {
        Position = UDim2.new(1, 10 * GetScale(), 1, -110 * GetScale())
    }):Play()
    
    -- Auto-close after time
    delay(NotificationConfig.Time, function()
        TweenService:Create(Notification, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {
            Position = UDim2.new(1, 310 * GetScale(), 1, -110 * GetScale())
        }):Play()
        wait(0.5)
        Notification:Destroy()
    end)
end

-- Destroy function
function ResponsiveUI:Destroy()
    UI:Destroy()
end

return ResponsiveUI
