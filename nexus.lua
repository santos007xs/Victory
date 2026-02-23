-- ╔══════════════════════════════════════════════════════════╗
-- ║              NEXUS LIB  v2.0  -  LIBRARY BASE            ║
-- ║  Uso: local Nexus = loadstring(game:HttpGet(URL))()      ║
-- ╚══════════════════════════════════════════════════════════╝

local NexusLib = {}

local Players          = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local RunService       = game:GetService("RunService")
local LocalPlayer      = Players.LocalPlayer

-- ══════════════════════════════════════
--  ESTADO INTERNO
-- ══════════════════════════════════════
local _modules       = {}   -- lista de módulos registrados
local _categories    = {}   -- lista de categorias registradas
local _moduleButtons = {}   -- [modName] = btnFrame
local _currentCat    = nil
local _menuOpen      = false
local _configOpen    = false
local _configTarget  = nil  -- módulo com config aberta

-- ══════════════════════════════════════
--  GUI ROOT
-- ══════════════════════════════════════
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name           = "NexusClient"
ScreenGui.ResetOnSpawn   = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent         = LocalPlayer:WaitForChild("PlayerGui")

-- ── OVERLAY ──
local Overlay = Instance.new("Frame")
Overlay.Name                 = "Overlay"
Overlay.Size                 = UDim2.new(1,0,1,0)
Overlay.BackgroundColor3     = Color3.fromRGB(0,0,0)
Overlay.BackgroundTransparency = 1
Overlay.BorderSizePixel      = 0
Overlay.ZIndex               = 1
Overlay.Visible              = false
Overlay.Parent               = ScreenGui

-- ── PAINEL PRINCIPAL ──
local Panel = Instance.new("Frame")
Panel.Name               = "Panel"
Panel.Size               = UDim2.new(0,640,0,440)
Panel.Position           = UDim2.new(0.5,-320,0.5,-220)
Panel.BackgroundColor3   = Color3.fromRGB(10,10,22)
Panel.BorderSizePixel    = 0
Panel.ZIndex             = 2
Panel.Visible            = false
Panel.Parent             = ScreenGui
Instance.new("UICorner",Panel).CornerRadius = UDim.new(0,8)
local PanelStroke = Instance.new("UIStroke")
PanelStroke.Color        = Color3.fromRGB(0,200,255)
PanelStroke.Thickness    = 1
PanelStroke.Transparency = 0.6
PanelStroke.Parent       = Panel

-- ── HEADER ──
local Header = Instance.new("Frame")
Header.Size              = UDim2.new(1,0,0,42)
Header.BackgroundColor3  = Color3.fromRGB(0,200,255)
Header.BackgroundTransparency = 0.85
Header.BorderSizePixel   = 0
Header.ZIndex            = 3
Header.Parent            = Panel
Instance.new("UICorner",Header).CornerRadius = UDim.new(0,8)
local HFix = Instance.new("Frame") -- fix cantos bottom
HFix.Size = UDim2.new(1,0,0.5,0); HFix.Position = UDim2.new(0,0,0.5,0)
HFix.BackgroundColor3 = Color3.fromRGB(0,200,255); HFix.BackgroundTransparency = 0.85
HFix.BorderSizePixel = 0; HFix.ZIndex = 3; HFix.Parent = Header

local HeaderLine = Instance.new("Frame")
HeaderLine.Size = UDim2.new(1,0,0,1); HeaderLine.Position = UDim2.new(0,0,1,0)
HeaderLine.BackgroundColor3 = Color3.fromRGB(0,200,255); HeaderLine.BackgroundTransparency = 0.55
HeaderLine.BorderSizePixel = 0; HeaderLine.ZIndex = 4; HeaderLine.Parent = Header

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(0,220,1,0); TitleLabel.Position = UDim2.new(0,14,0,0)
TitleLabel.BackgroundTransparency = 1; TitleLabel.Text = "NEXUS CLIENT"
TitleLabel.TextColor3 = Color3.fromRGB(0,220,255); TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 15; TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.ZIndex = 5; TitleLabel.Parent = Header

local VersionLabel = Instance.new("TextLabel")
VersionLabel.Size = UDim2.new(0,220,1,0); VersionLabel.Position = UDim2.new(1,-230,0,0)
VersionLabel.BackgroundTransparency = 1
VersionLabel.Text = "v2.0  |  " .. LocalPlayer.Name
VersionLabel.TextColor3 = Color3.fromRGB(255,255,255); VersionLabel.TextTransparency = 0.55
VersionLabel.Font = Enum.Font.Code; VersionLabel.TextSize = 12
VersionLabel.TextXAlignment = Enum.TextXAlignment.Right
VersionLabel.ZIndex = 5; VersionLabel.Parent = Header

-- ── TAB BAR ──
local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(1,0,0,32); TabBar.Position = UDim2.new(0,0,0,42)
TabBar.BackgroundTransparency = 1; TabBar.BorderSizePixel = 0; TabBar.ZIndex = 3
TabBar.Parent = Panel
local TabLayout = Instance.new("UIListLayout")
TabLayout.FillDirection = Enum.FillDirection.Horizontal; TabLayout.Padding = UDim.new(0,3)
TabLayout.VerticalAlignment = Enum.VerticalAlignment.Center; TabLayout.Parent = TabBar
local TabPad = Instance.new("UIPadding"); TabPad.PaddingLeft = UDim.new(0,12); TabPad.Parent = TabBar

local TabLine = Instance.new("Frame")
TabLine.Size = UDim2.new(1,0,0,1); TabLine.Position = UDim2.new(0,0,0,74)
TabLine.BackgroundColor3 = Color3.fromRGB(255,255,255); TabLine.BackgroundTransparency = 0.88
TabLine.BorderSizePixel = 0; TabLine.ZIndex = 3; TabLine.Parent = Panel

-- ── MÓDULO AREA ──
local ModuleArea = Instance.new("ScrollingFrame")
ModuleArea.Size = UDim2.new(1,-16,1,-114); ModuleArea.Position = UDim2.new(0,8,0,80)
ModuleArea.BackgroundTransparency = 1; ModuleArea.BorderSizePixel = 0
ModuleArea.ScrollBarThickness = 3; ModuleArea.ScrollBarImageColor3 = Color3.fromRGB(0,200,255)
ModuleArea.ScrollBarImageTransparency = 0.5; ModuleArea.CanvasSize = UDim2.new(0,0,0,0)
ModuleArea.ZIndex = 3; ModuleArea.Parent = Panel

local ModuleGrid = Instance.new("UIGridLayout")
ModuleGrid.CellSize = UDim2.new(0,134,0,60); ModuleGrid.CellPadding = UDim2.new(0,8,0,8)
ModuleGrid.SortOrder = Enum.SortOrder.LayoutOrder; ModuleGrid.Parent = ModuleArea

local ModuleGridPad = Instance.new("UIPadding")
ModuleGridPad.PaddingTop = UDim.new(0,6); ModuleGridPad.PaddingLeft = UDim.new(0,4)
ModuleGridPad.Parent = ModuleArea

-- ── STATUS BAR ──
local StatusBar = Instance.new("Frame")
StatusBar.Size = UDim2.new(1,0,0,28); StatusBar.Position = UDim2.new(0,0,1,-28)
StatusBar.BackgroundColor3 = Color3.fromRGB(255,255,255); StatusBar.BackgroundTransparency = 0.94
StatusBar.BorderSizePixel = 0; StatusBar.ZIndex = 3; StatusBar.Parent = Panel

local SBLine = Instance.new("Frame")
SBLine.Size = UDim2.new(1,0,0,1); SBLine.BackgroundColor3 = Color3.fromRGB(255,255,255)
SBLine.BackgroundTransparency = 0.88; SBLine.BorderSizePixel = 0; SBLine.ZIndex = 4; SBLine.Parent = StatusBar

local StatusLeft = Instance.new("TextLabel")
StatusLeft.Size = UDim2.new(0.5,0,1,0); StatusLeft.Position = UDim2.new(0,12,0,0)
StatusLeft.BackgroundTransparency = 1; StatusLeft.Text = "INSERT abrir/fechar  |  CLIQUE DIREITO configurar"
StatusLeft.TextColor3 = Color3.fromRGB(255,255,255); StatusLeft.TextTransparency = 0.65
StatusLeft.Font = Enum.Font.Code; StatusLeft.TextSize = 11
StatusLeft.TextXAlignment = Enum.TextXAlignment.Left; StatusLeft.ZIndex = 4; StatusLeft.Parent = StatusBar

local StatusRight = Instance.new("TextLabel")
StatusRight.Name = "StatusRight"; StatusRight.Size = UDim2.new(0.5,-12,1,0)
StatusRight.Position = UDim2.new(0.5,0,0,0); StatusRight.BackgroundTransparency = 1
StatusRight.Text = "0 módulos ativos"; StatusRight.TextColor3 = Color3.fromRGB(0,255,140)
StatusRight.Font = Enum.Font.Code; StatusRight.TextSize = 11
StatusRight.TextXAlignment = Enum.TextXAlignment.Right; StatusRight.ZIndex = 4; StatusRight.Parent = StatusBar

-- ══════════════════════════════════════
--  HUD
-- ══════════════════════════════════════
local HudFrame = Instance.new("Frame")
HudFrame.Name = "HUD"; HudFrame.Size = UDim2.new(0,160,1,0)
HudFrame.Position = UDim2.new(1,-165,0,6); HudFrame.BackgroundTransparency = 1
HudFrame.BorderSizePixel = 0; HudFrame.ZIndex = 1; HudFrame.Parent = ScreenGui
local HudLayout = Instance.new("UIListLayout")
HudLayout.FillDirection = Enum.FillDirection.Vertical; HudLayout.Padding = UDim.new(0,2)
HudLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
HudLayout.VerticalAlignment = Enum.VerticalAlignment.Top; HudLayout.Parent = HudFrame

-- ══════════════════════════════════════
--  JANELA DE CONFIGURAÇÃO (clique direito)
-- ══════════════════════════════════════
local ConfigWindow = Instance.new("Frame")
ConfigWindow.Name = "ConfigWindow"; ConfigWindow.Size = UDim2.new(0,260,0,50) -- altura dinâmica
ConfigWindow.Position = UDim2.new(0.5,-130,0.5,-25)
ConfigWindow.BackgroundColor3 = Color3.fromRGB(8,8,18); ConfigWindow.BorderSizePixel = 0
ConfigWindow.ZIndex = 20; ConfigWindow.Visible = false; ConfigWindow.Parent = ScreenGui
Instance.new("UICorner",ConfigWindow).CornerRadius = UDim.new(0,8)
local CWStroke = Instance.new("UIStroke"); CWStroke.Color = Color3.fromRGB(0,200,255)
CWStroke.Thickness = 1; CWStroke.Transparency = 0.4; CWStroke.Parent = ConfigWindow

-- Header da config
local CWHeader = Instance.new("Frame")
CWHeader.Size = UDim2.new(1,0,0,36); CWHeader.BackgroundColor3 = Color3.fromRGB(0,200,255)
CWHeader.BackgroundTransparency = 0.82; CWHeader.BorderSizePixel = 0; CWHeader.ZIndex = 21; CWHeader.Parent = ConfigWindow
Instance.new("UICorner",CWHeader).CornerRadius = UDim.new(0,8)
local CWHFix = Instance.new("Frame"); CWHFix.Size = UDim2.new(1,0,0.5,0); CWHFix.Position = UDim2.new(0,0,0.5,0)
CWHFix.BackgroundColor3 = Color3.fromRGB(0,200,255); CWHFix.BackgroundTransparency = 0.82
CWHFix.BorderSizePixel = 0; CWHFix.ZIndex = 21; CWHFix.Parent = CWHeader

local CWTitle = Instance.new("TextLabel")
CWTitle.Size = UDim2.new(1,-50,1,0); CWTitle.Position = UDim2.new(0,12,0,0)
CWTitle.BackgroundTransparency = 1; CWTitle.Text = "Configurar"
CWTitle.TextColor3 = Color3.fromRGB(0,220,255); CWTitle.Font = Enum.Font.GothamBold
CWTitle.TextSize = 13; CWTitle.TextXAlignment = Enum.TextXAlignment.Left
CWTitle.ZIndex = 22; CWTitle.Parent = CWHeader

local CWClose = Instance.new("TextButton")
CWClose.Size = UDim2.new(0,24,0,24); CWClose.Position = UDim2.new(1,-30,0.5,-12)
CWClose.BackgroundColor3 = Color3.fromRGB(200,50,50); CWClose.BorderSizePixel = 0
CWClose.Text = "✕"; CWClose.TextColor3 = Color3.fromRGB(255,255,255)
CWClose.Font = Enum.Font.GothamBold; CWClose.TextSize = 11; CWClose.AutoButtonColor = false
CWClose.ZIndex = 22; CWClose.Parent = CWHeader
Instance.new("UICorner",CWClose).CornerRadius = UDim.new(0,5)
CWClose.MouseButton1Click:Connect(function()
    ConfigWindow.Visible = false
    _configOpen = false; _configTarget = nil
end)

-- Área de conteúdo da config (onde os widgets são inseridos)
local CWContent = Instance.new("ScrollingFrame")
CWContent.Name = "CWContent"; CWContent.Size = UDim2.new(1,-8,1,-44)
CWContent.Position = UDim2.new(0,4,0,40); CWContent.BackgroundTransparency = 1
CWContent.BorderSizePixel = 0; CWContent.ScrollBarThickness = 3
CWContent.ScrollBarImageColor3 = Color3.fromRGB(0,200,255)
CWContent.ScrollBarImageTransparency = 0.5; CWContent.CanvasSize = UDim2.new(0,0,0,0)
CWContent.ZIndex = 21; CWContent.Parent = ConfigWindow

local CWLayout = Instance.new("UIListLayout")
CWLayout.FillDirection = Enum.FillDirection.Vertical; CWLayout.Padding = UDim.new(0,6)
CWLayout.SortOrder = Enum.SortOrder.LayoutOrder; CWLayout.Parent = CWContent
local CWPad = Instance.new("UIPadding"); CWPad.PaddingTop = UDim.new(0,4)
CWPad.PaddingLeft = UDim.new(0,4); CWPad.PaddingRight = UDim.new(0,4); CWPad.Parent = CWContent

-- Drag da janela de config
do
    local dr,ds,sp = false,nil,nil
    CWHeader.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            dr=true; ds=i.Position; sp=ConfigWindow.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dr and i.UserInputType == Enum.UserInputType.MouseMovement then
            local d = i.Position - ds
            ConfigWindow.Position = UDim2.new(sp.X.Scale,sp.X.Offset+d.X,sp.Y.Scale,sp.Y.Offset+d.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then dr=false end
    end)
end

-- ══════════════════════════════════════
--  FUNÇÕES INTERNAS
-- ══════════════════════════════════════
local function updateStatusCount()
    local n = 0
    for _,m in ipairs(_modules) do if m.enabled then n+=1 end end
    StatusRight.Text = n.." módulo"..(n==1 and "" or "s").." ativo"..(n==1 and "" or "s")
end

local function updateHUD()
    for _,c in ipairs(HudFrame:GetChildren()) do
        if c:IsA("Frame") then c:Destroy() end
    end
    for _,m in ipairs(_modules) do
        if m.enabled then
            local item = Instance.new("Frame")
            item.Size = UDim2.new(0,155,0,18); item.BackgroundColor3 = Color3.fromRGB(0,0,0)
            item.BackgroundTransparency = 0.35; item.BorderSizePixel = 0; item.ZIndex = 1
            local bar = Instance.new("Frame"); bar.Size = UDim2.new(0,3,1,0)
            bar.Position = UDim2.new(1,-3,0,0); bar.BackgroundColor3 = m.color
            bar.BorderSizePixel = 0; bar.ZIndex = 2; bar.Parent = item
            local lbl = Instance.new("TextLabel"); lbl.Size = UDim2.new(1,-8,1,0)
            lbl.BackgroundTransparency = 1; lbl.Text = m.name
            lbl.TextColor3 = Color3.fromRGB(255,255,255); lbl.Font = Enum.Font.Code
            lbl.TextSize = 12; lbl.TextXAlignment = Enum.TextXAlignment.Right
            lbl.ZIndex = 2; lbl.Parent = item
            item.Parent = HudFrame
        end
    end
end

local function refreshBtn(mod)
    local btn = _moduleButtons[mod.name]
    if not btn then return end
    if mod.enabled then
        btn.BackgroundColor3 = Color3.fromRGB(15,15,30); btn.BackgroundTransparency = 0
        local s = btn:FindFirstChildOfClass("UIStroke"); if s then s.Color=mod.color; s.Transparency=0 end
        local tb = btn:FindFirstChild("TopBar"); if tb then tb.BackgroundTransparency=0 end
        local nl = btn:FindFirstChild("NameLabel"); if nl then nl.TextColor3=mod.color end
        local sd = btn:FindFirstChild("StatusDot"); if sd then sd.BackgroundColor3=mod.color; sd.BackgroundTransparency=0 end
    else
        btn.BackgroundColor3 = Color3.fromRGB(255,255,255); btn.BackgroundTransparency = 0.95
        local s = btn:FindFirstChildOfClass("UIStroke"); if s then s.Color=Color3.fromRGB(255,255,255); s.Transparency=0.85 end
        local tb = btn:FindFirstChild("TopBar"); if tb then tb.BackgroundTransparency=1 end
        local nl = btn:FindFirstChild("NameLabel"); if nl then nl.TextColor3=Color3.fromRGB(255,255,255) end
        local sd = btn:FindFirstChild("StatusDot"); if sd then sd.BackgroundColor3=Color3.fromRGB(255,255,255); sd.BackgroundTransparency=0.7 end
    end
end

-- ══════════════════════════════════════
--  WIDGETS DA JANELA DE CONFIG
-- ══════════════════════════════════════
local widgetBuilders = {}

-- Label separador de seção
function widgetBuilders.section(title)
    local f = Instance.new("Frame"); f.Size = UDim2.new(1,0,0,20)
    f.BackgroundTransparency = 1; f.BorderSizePixel = 0; f.ZIndex = 22
    local lbl = Instance.new("TextLabel"); lbl.Size = UDim2.new(1,0,1,0)
    lbl.BackgroundTransparency = 1; lbl.Text = title:upper()
    lbl.TextColor3 = Color3.fromRGB(0,200,255); lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 10; lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.ZIndex = 23; lbl.Parent = f
    return f
end

-- Toggle
function widgetBuilders.toggle(label, current, callback)
    local f = Instance.new("Frame"); f.Size = UDim2.new(1,0,0,30)
    f.BackgroundColor3 = Color3.fromRGB(255,255,255); f.BackgroundTransparency = 0.94
    f.BorderSizePixel = 0; f.ZIndex = 22
    Instance.new("UICorner",f).CornerRadius = UDim.new(0,5)
    local lbl = Instance.new("TextLabel"); lbl.Size = UDim2.new(1,-50,1,0); lbl.Position = UDim2.new(0,10,0,0)
    lbl.BackgroundTransparency = 1; lbl.Text = label
    lbl.TextColor3 = Color3.fromRGB(200,210,230); lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 12; lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.ZIndex = 23; lbl.Parent = f

    local state = current
    -- Track (fundo)
    local track = Instance.new("Frame"); track.Size = UDim2.new(0,36,0,18); track.Position = UDim2.new(1,-44,0.5,-9)
    track.BackgroundColor3 = state and Color3.fromRGB(0,180,255) or Color3.fromRGB(50,50,70)
    track.BorderSizePixel = 0; track.ZIndex = 23; track.Parent = f
    Instance.new("UICorner",track).CornerRadius = UDim.new(1,0)
    -- Thumb
    local thumb = Instance.new("Frame"); thumb.Size = UDim2.new(0,14,0,14)
    thumb.Position = state and UDim2.new(0,20,0.5,-7) or UDim2.new(0,2,0.5,-7)
    thumb.BackgroundColor3 = Color3.fromRGB(255,255,255); thumb.BorderSizePixel = 0; thumb.ZIndex = 24; thumb.Parent = track
    Instance.new("UICorner",thumb).CornerRadius = UDim.new(1,0)

    local btn = Instance.new("TextButton"); btn.Size = UDim2.new(1,0,1,0)
    btn.BackgroundTransparency = 1; btn.Text = ""; btn.ZIndex = 25; btn.Parent = f
    btn.MouseButton1Click:Connect(function()
        state = not state
        TweenService:Create(track,TweenInfo.new(0.15),{BackgroundColor3 = state and Color3.fromRGB(0,180,255) or Color3.fromRGB(50,50,70)}):Play()
        TweenService:Create(thumb,TweenInfo.new(0.15),{Position = state and UDim2.new(0,20,0.5,-7) or UDim2.new(0,2,0.5,-7)}):Play()
        if callback then callback(state) end
    end)
    return f
end

-- Slider
function widgetBuilders.slider(label, min, max, current, callback)
    local f = Instance.new("Frame"); f.Size = UDim2.new(1,0,0,46)
    f.BackgroundColor3 = Color3.fromRGB(255,255,255); f.BackgroundTransparency = 0.94
    f.BorderSizePixel = 0; f.ZIndex = 22
    Instance.new("UICorner",f).CornerRadius = UDim.new(0,5)
    local lbl = Instance.new("TextLabel"); lbl.Size = UDim2.new(0.7,0,0,20); lbl.Position = UDim2.new(0,10,0,4)
    lbl.BackgroundTransparency = 1; lbl.Text = label
    lbl.TextColor3 = Color3.fromRGB(200,210,230); lbl.Font = Enum.Font.Gotham; lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.ZIndex = 23; lbl.Parent = f
    local valLbl = Instance.new("TextLabel"); valLbl.Size = UDim2.new(0.3,-10,0,20); valLbl.Position = UDim2.new(0.7,0,0,4)
    valLbl.BackgroundTransparency = 1; valLbl.Text = tostring(current)
    valLbl.TextColor3 = Color3.fromRGB(0,200,255); valLbl.Font = Enum.Font.GothamBold; valLbl.TextSize = 12
    valLbl.TextXAlignment = Enum.TextXAlignment.Right; valLbl.ZIndex = 23; valLbl.Parent = f

    -- Track
    local track = Instance.new("Frame"); track.Size = UDim2.new(1,-20,0,4); track.Position = UDim2.new(0,10,0,30)
    track.BackgroundColor3 = Color3.fromRGB(40,40,60); track.BorderSizePixel = 0; track.ZIndex = 23; track.Parent = f
    Instance.new("UICorner",track).CornerRadius = UDim.new(1,0)
    -- Fill
    local fill = Instance.new("Frame"); fill.Size = UDim2.new((current-min)/(max-min),0,1,0)
    fill.BackgroundColor3 = Color3.fromRGB(0,180,255); fill.BorderSizePixel = 0; fill.ZIndex = 24; fill.Parent = track
    Instance.new("UICorner",fill).CornerRadius = UDim.new(1,0)
    -- Thumb
    local knob = Instance.new("Frame"); knob.Size = UDim2.new(0,12,0,12)
    knob.Position = UDim2.new((current-min)/(max-min),−6,0.5,−6)
    knob.BackgroundColor3 = Color3.fromRGB(0,220,255); knob.BorderSizePixel = 0; knob.ZIndex = 25; knob.Parent = track
    Instance.new("UICorner",knob).CornerRadius = UDim.new(1,0)

    local sliding = false
    local function updateSlider(absX)
        local tAbs = track.AbsolutePosition.X; local tW = track.AbsoluteSize.X
        local pct = math.clamp((absX - tAbs)/tW, 0, 1)
        local val = math.round(min + (max-min)*pct)
        valLbl.Text = tostring(val)
        TweenService:Create(fill,TweenInfo.new(0.05),{Size=UDim2.new(pct,0,1,0)}):Play()
        knob.Position = UDim2.new(pct,-6,0.5,-6)
        if callback then callback(val) end
    end
    local sliderBtn = Instance.new("TextButton"); sliderBtn.Size = UDim2.new(1,0,1,0)
    sliderBtn.BackgroundTransparency = 1; sliderBtn.Text = ""; sliderBtn.ZIndex = 26; sliderBtn.Parent = track
    sliderBtn.MouseButton1Down:Connect(function(x) sliding=true; updateSlider(x) end)
    UserInputService.InputChanged:Connect(function(i)
        if sliding and i.UserInputType == Enum.UserInputType.MouseMovement then
            updateSlider(i.Position.X)
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then sliding=false end
    end)
    return f
end

-- Dropdown
function widgetBuilders.dropdown(label, options, current, callback)
    local open = false
    local selectedIdx = 1
    for i,o in ipairs(options) do if o==current then selectedIdx=i end end

    local container = Instance.new("Frame"); container.Size = UDim2.new(1,0,0,30)
    container.BackgroundTransparency = 1; container.BorderSizePixel = 0; container.ZIndex = 22
    local contLayout = Instance.new("UIListLayout"); contLayout.FillDirection = Enum.FillDirection.Vertical
    contLayout.SortOrder = Enum.SortOrder.LayoutOrder; contLayout.Parent = container

    local mainRow = Instance.new("Frame"); mainRow.Name="mainRow"; mainRow.Size = UDim2.new(1,0,0,30)
    mainRow.LayoutOrder = 1; mainRow.BackgroundColor3 = Color3.fromRGB(255,255,255)
    mainRow.BackgroundTransparency = 0.94; mainRow.BorderSizePixel = 0; mainRow.ZIndex = 22
    Instance.new("UICorner",mainRow).CornerRadius = UDim.new(0,5); mainRow.Parent = container

    local lbl = Instance.new("TextLabel"); lbl.Size = UDim2.new(0.55,0,1,0); lbl.Position = UDim2.new(0,10,0,0)
    lbl.BackgroundTransparency = 1; lbl.Text = label
    lbl.TextColor3 = Color3.fromRGB(200,210,230); lbl.Font = Enum.Font.Gotham; lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.ZIndex = 23; lbl.Parent = mainRow

    local selLbl = Instance.new("TextLabel"); selLbl.Size = UDim2.new(0.4,-10,1,0); selLbl.Position = UDim2.new(0.55,0,0,0)
    selLbl.BackgroundTransparency = 1; selLbl.Text = options[selectedIdx] or "?"
    selLbl.TextColor3 = Color3.fromRGB(0,200,255); selLbl.Font = Enum.Font.GothamBold; selLbl.TextSize = 12
    selLbl.TextXAlignment = Enum.TextXAlignment.Right; selLbl.ZIndex = 23; selLbl.Parent = mainRow

    local arrow = Instance.new("TextLabel"); arrow.Size = UDim2.new(0,14,1,0); arrow.Position = UDim2.new(1,-18,0,0)
    arrow.BackgroundTransparency = 1; arrow.Text = "▾"
    arrow.TextColor3 = Color3.fromRGB(0,200,255); arrow.Font = Enum.Font.GothamBold
    arrow.TextSize = 12; arrow.ZIndex = 23; arrow.Parent = mainRow

    local dropFrame = Instance.new("Frame"); dropFrame.Name="dropFrame"; dropFrame.LayoutOrder = 2
    dropFrame.Size = UDim2.new(1,0,0,#options*26); dropFrame.BackgroundColor3 = Color3.fromRGB(12,12,24)
    dropFrame.BorderSizePixel = 0; dropFrame.ZIndex = 24; dropFrame.Visible = false
    Instance.new("UICorner",dropFrame).CornerRadius = UDim.new(0,5); dropFrame.Parent = container

    local dropLayout = Instance.new("UIListLayout"); dropLayout.FillDirection = Enum.FillDirection.Vertical
    dropLayout.Padding = UDim.new(0,0); dropLayout.Parent = dropFrame

    for i,opt in ipairs(options) do
        local optBtn = Instance.new("TextButton"); optBtn.Size = UDim2.new(1,0,0,26)
        optBtn.BackgroundTransparency = 1; optBtn.BorderSizePixel = 0
        optBtn.Text = opt; optBtn.TextColor3 = (i==selectedIdx) and Color3.fromRGB(0,200,255) or Color3.fromRGB(180,190,210)
        optBtn.Font = Enum.Font.Gotham; optBtn.TextSize = 12; optBtn.AutoButtonColor = false
        optBtn.ZIndex = 25; optBtn.Parent = dropFrame
        optBtn.MouseEnter:Connect(function()
            TweenService:Create(optBtn,TweenInfo.new(0.1),{BackgroundTransparency=0.88,BackgroundColor3=Color3.fromRGB(255,255,255)}):Play()
        end)
        optBtn.MouseLeave:Connect(function()
            TweenService:Create(optBtn,TweenInfo.new(0.1),{BackgroundTransparency=1}):Play()
        end)
        optBtn.MouseButton1Click:Connect(function()
            selectedIdx = i; selLbl.Text = opt
            -- Reset cores
            for _,c in ipairs(dropFrame:GetChildren()) do
                if c:IsA("TextButton") then c.TextColor3 = Color3.fromRGB(180,190,210) end
            end
            optBtn.TextColor3 = Color3.fromRGB(0,200,255)
            open = false; dropFrame.Visible = false
            container.Size = UDim2.new(1,0,0,30); arrow.Text = "▾"
            if callback then callback(opt) end
        end)
    end

    local toggleBtn = Instance.new("TextButton"); toggleBtn.Size = UDim2.new(1,0,1,0)
    toggleBtn.BackgroundTransparency = 1; toggleBtn.Text = ""; toggleBtn.ZIndex = 26; toggleBtn.Parent = mainRow
    toggleBtn.MouseButton1Click:Connect(function()
        open = not open; dropFrame.Visible = open
        container.Size = open and UDim2.new(1,0,0,30+#options*26) or UDim2.new(1,0,0,30)
        arrow.Text = open and "▴" or "▾"
    end)
    return container
end

-- Keybind
function widgetBuilders.keybind(label, current, callback)
    local listening = false
    local currentKey = current

    local f = Instance.new("Frame"); f.Size = UDim2.new(1,0,0,30)
    f.BackgroundColor3 = Color3.fromRGB(255,255,255); f.BackgroundTransparency = 0.94
    f.BorderSizePixel = 0; f.ZIndex = 22
    Instance.new("UICorner",f).CornerRadius = UDim.new(0,5)
    local lbl = Instance.new("TextLabel"); lbl.Size = UDim2.new(0.6,0,1,0); lbl.Position = UDim2.new(0,10,0,0)
    lbl.BackgroundTransparency = 1; lbl.Text = label
    lbl.TextColor3 = Color3.fromRGB(200,210,230); lbl.Font = Enum.Font.Gotham; lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.ZIndex = 23; lbl.Parent = f

    local keyBtn = Instance.new("TextButton")
    keyBtn.Size = UDim2.new(0,80,0,22); keyBtn.Position = UDim2.new(1,-88,0.5,-11)
    keyBtn.BackgroundColor3 = Color3.fromRGB(20,20,35); keyBtn.BorderSizePixel = 0
    keyBtn.Text = currentKey ~= Enum.KeyCode.Unknown and currentKey.Name or "Nenhum"
    keyBtn.TextColor3 = Color3.fromRGB(0,200,255); keyBtn.Font = Enum.Font.GothamBold
    keyBtn.TextSize = 11; keyBtn.AutoButtonColor = false; keyBtn.ZIndex = 23; keyBtn.Parent = f
    Instance.new("UICorner",keyBtn).CornerRadius = UDim.new(0,4)

    keyBtn.MouseButton1Click:Connect(function()
        listening = true
        keyBtn.Text = "..."; keyBtn.TextColor3 = Color3.fromRGB(255,200,0)
    end)

    UserInputService.InputBegan:Connect(function(input, gp)
        if not listening then return end
        if input.UserInputType == Enum.UserInputType.Keyboard then
            listening = false
            if input.KeyCode == Enum.KeyCode.Escape then
                keyBtn.Text = currentKey ~= Enum.KeyCode.Unknown and currentKey.Name or "Nenhum"
                keyBtn.TextColor3 = Color3.fromRGB(0,200,255)
            else
                currentKey = input.KeyCode
                keyBtn.Text = input.KeyCode.Name
                keyBtn.TextColor3 = Color3.fromRGB(0,200,255)
                if callback then callback(input.KeyCode) end
            end
        end
    end)
    return f
end

-- Textbox (entrada de texto)
function widgetBuilders.textinput(label, placeholder, callback)
    local f = Instance.new("Frame"); f.Size = UDim2.new(1,0,0,30)
    f.BackgroundColor3 = Color3.fromRGB(255,255,255); f.BackgroundTransparency = 0.94
    f.BorderSizePixel = 0; f.ZIndex = 22
    Instance.new("UICorner",f).CornerRadius = UDim.new(0,5)
    local lbl = Instance.new("TextLabel"); lbl.Size = UDim2.new(0.45,0,1,0); lbl.Position = UDim2.new(0,10,0,0)
    lbl.BackgroundTransparency = 1; lbl.Text = label
    lbl.TextColor3 = Color3.fromRGB(200,210,230); lbl.Font = Enum.Font.Gotham; lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.ZIndex = 23; lbl.Parent = f

    local box = Instance.new("TextBox"); box.Size = UDim2.new(0.5,-10,0,22); box.Position = UDim2.new(0.5,0,0.5,-11)
    box.BackgroundColor3 = Color3.fromRGB(15,15,30); box.BorderSizePixel = 0
    box.PlaceholderText = placeholder or ""; box.PlaceholderColor3 = Color3.fromRGB(80,90,110)
    box.Text = ""; box.TextColor3 = Color3.fromRGB(220,230,255)
    box.Font = Enum.Font.Code; box.TextSize = 11; box.ClearTextOnFocus = false
    box.ZIndex = 23; box.Parent = f
    Instance.new("UICorner",box).CornerRadius = UDim.new(0,4)
    box.FocusLost:Connect(function(enter)
        if enter and callback then callback(box.Text) end
    end)
    return f
end

-- Button de ação
function widgetBuilders.button(label, callback)
    local btn = Instance.new("TextButton"); btn.Size = UDim2.new(1,0,0,28)
    btn.BackgroundColor3 = Color3.fromRGB(0,140,200); btn.BackgroundTransparency = 0.6
    btn.BorderSizePixel = 0; btn.Text = label
    btn.TextColor3 = Color3.fromRGB(255,255,255); btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12; btn.AutoButtonColor = false; btn.ZIndex = 22
    Instance.new("UICorner",btn).CornerRadius = UDim.new(0,5)
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn,TweenInfo.new(0.1),{BackgroundTransparency=0.3}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn,TweenInfo.new(0.1),{BackgroundTransparency=0.6}):Play()
    end)
    btn.MouseButton1Click:Connect(function() if callback then callback() end end)
    return btn
end

-- ══════════════════════════════════════
--  ABRIR JANELA DE CONFIGURAÇÃO
-- ══════════════════════════════════════
local function openConfig(mod, posX, posY)
    -- Limpa conteúdo anterior
    for _,c in ipairs(CWContent:GetChildren()) do
        if not c:IsA("UIListLayout") and not c:IsA("UIPadding") then c:Destroy() end
    end

    CWTitle.Text = mod.name

    -- Popula widgets com os options do módulo
    local totalH = 8
    local order = 1

    if mod.options then
        for _, opt in ipairs(mod.options) do
            local widget = nil
            local t = opt.type

            if t == "section" then
                widget = widgetBuilders.section(opt.label)
                widget.Size = UDim2.new(1,0,0,20)
            elseif t == "toggle" then
                widget = widgetBuilders.toggle(opt.label, opt.value, function(v)
                    opt.value = v
                    if opt.callback then opt.callback(v) end
                end)
            elseif t == "slider" then
                widget = widgetBuilders.slider(opt.label, opt.min or 0, opt.max or 100, opt.value or opt.min or 0, function(v)
                    opt.value = v
                    if opt.callback then opt.callback(v) end
                end)
            elseif t == "dropdown" then
                widget = widgetBuilders.dropdown(opt.label, opt.options, opt.value, function(v)
                    opt.value = v
                    if opt.callback then opt.callback(v) end
                end)
            elseif t == "keybind" then
                widget = widgetBuilders.keybind(opt.label, opt.value or Enum.KeyCode.Unknown, function(k)
                    opt.value = k
                    if opt.callback then opt.callback(k) end
                end)
            elseif t == "textinput" then
                widget = widgetBuilders.textinput(opt.label, opt.placeholder, function(v)
                    opt.value = v
                    if opt.callback then opt.callback(v) end
                end)
            elseif t == "button" then
                widget = widgetBuilders.button(opt.label, opt.callback)
            end

            if widget then
                widget.LayoutOrder = order; order+=1
                widget.Parent = CWContent
                totalH += widget.Size.Y.Offset + 6
            end
        end
    else
        -- Sem opções configuradas
        local msg = Instance.new("TextLabel"); msg.Size = UDim2.new(1,0,0,40)
        msg.BackgroundTransparency = 1; msg.Text = "Nenhuma opção disponível"
        msg.TextColor3 = Color3.fromRGB(120,130,150); msg.Font = Enum.Font.Gotham; msg.TextSize = 12
        msg.ZIndex = 23; msg.LayoutOrder = 1; msg.Parent = CWContent
        totalH = 48
    end

    -- Resize janela
    local winH = math.min(math.max(totalH + 52, 80), 400)
    CWContent.CanvasSize = UDim2.new(0,0,0,totalH)
    ConfigWindow.Size = UDim2.new(0,260,0,winH)

    -- Posição perto do módulo
    local scrSize = ScreenGui.AbsoluteSize
    local wx = math.clamp(posX + 10, 0, scrSize.X - 270)
    local wy = math.clamp(posY,      0, scrSize.Y - winH - 10)
    ConfigWindow.Position = UDim2.new(0, wx, 0, wy)

    ConfigWindow.Visible = true
    _configOpen = true
    _configTarget = mod
end

-- ══════════════════════════════════════
--  CRIAR BOTÃO DE MÓDULO
-- ══════════════════════════════════════
local function createModuleButton(mod)
    local btn = Instance.new("TextButton")
    btn.Name = mod.name; btn.Size = UDim2.new(0,134,0,60)
    btn.BackgroundColor3 = Color3.fromRGB(255,255,255); btn.BackgroundTransparency = 0.95
    btn.BorderSizePixel = 0; btn.Text = ""; btn.AutoButtonColor = false
    btn.ZIndex = 4; btn.Visible = false; btn.Parent = ModuleArea
    Instance.new("UICorner",btn).CornerRadius = UDim.new(0,6)
    local stroke = Instance.new("UIStroke"); stroke.Color = Color3.fromRGB(255,255,255)
    stroke.Thickness = 1; stroke.Transparency = 0.85; stroke.Parent = btn

    local topBar = Instance.new("Frame"); topBar.Name="TopBar"
    topBar.Size = UDim2.new(1,0,0,2); topBar.BackgroundColor3 = mod.color
    topBar.BackgroundTransparency = 1; topBar.BorderSizePixel = 0; topBar.ZIndex = 5; topBar.Parent = btn
    Instance.new("UICorner",topBar).CornerRadius = UDim.new(0,6)

    local nameLabel = Instance.new("TextLabel"); nameLabel.Name="NameLabel"
    nameLabel.Size = UDim2.new(1,-20,0,22); nameLabel.Position = UDim2.new(0,10,0,10)
    nameLabel.BackgroundTransparency = 1; nameLabel.Text = mod.name
    nameLabel.TextColor3 = Color3.fromRGB(255,255,255); nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 13; nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.ZIndex = 5; nameLabel.Parent = btn

    local dot = Instance.new("Frame"); dot.Name="StatusDot"
    dot.Size = UDim2.new(0,6,0,6); dot.Position = UDim2.new(1,-14,0,12)
    dot.BackgroundColor3 = Color3.fromRGB(255,255,255); dot.BackgroundTransparency = 0.7
    dot.BorderSizePixel = 0; dot.ZIndex = 5; dot.Parent = btn
    Instance.new("UICorner",dot).CornerRadius = UDim.new(1,0)

    local catLabel = Instance.new("TextLabel")
    catLabel.Size = UDim2.new(1,-12,0,14); catLabel.Position = UDim2.new(0,10,1,-18)
    catLabel.BackgroundTransparency = 1; catLabel.Text = mod.category
    catLabel.TextColor3 = mod.color; catLabel.TextTransparency = 0.4
    catLabel.Font = Enum.Font.Code; catLabel.TextSize = 10
    catLabel.TextXAlignment = Enum.TextXAlignment.Left; catLabel.ZIndex = 5; catLabel.Parent = btn

    -- Clique esquerdo = toggle
    btn.MouseButton1Click:Connect(function()
        mod.enabled = not mod.enabled
        refreshBtn(mod)
        if mod.enabled and mod.onEnable then mod.onEnable() end
        if not mod.enabled and mod.onDisable then mod.onDisable() end
        updateStatusCount(); updateHUD()
    end)

    -- Clique direito = abrir config
    btn.MouseButton2Click:Connect(function()
        local absPos = btn.AbsolutePosition
        openConfig(mod, absPos.X + btn.AbsoluteSize.X, absPos.Y)
    end)

    btn.MouseEnter:Connect(function()
        if not mod.enabled then
            TweenService:Create(btn,TweenInfo.new(0.12),{BackgroundTransparency=0.88}):Play()
        end
    end)
    btn.MouseLeave:Connect(function()
        if not mod.enabled then
            TweenService:Create(btn,TweenInfo.new(0.12),{BackgroundTransparency=0.95}):Play()
        end
    end)

    return btn
end

-- ══════════════════════════════════════
--  DRAG DO PAINEL PRINCIPAL
-- ══════════════════════════════════════
do
    local dr,ds,sp = false,nil,nil
    Header.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then dr=true; ds=i.Position; sp=Panel.Position end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dr and i.UserInputType == Enum.UserInputType.MouseMovement then
            local d=i.Position-ds
            Panel.Position = UDim2.new(sp.X.Scale,sp.X.Offset+d.X,sp.Y.Scale,sp.Y.Offset+d.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then dr=false end
    end)
end

-- ══════════════════════════════════════
--  ABRIR / FECHAR (INSERT)
-- ══════════════════════════════════════
local function setVisible(v)
    _menuOpen = v
    Overlay.Visible = v; Panel.Visible = v
    if v then
        TweenService:Create(Overlay,TweenInfo.new(0.2),{BackgroundTransparency=0.6}):Play()
    end
    if not v then
        ConfigWindow.Visible = false
        _configOpen = false; _configTarget = nil
    end
end

UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Insert then
        setVisible(not _menuOpen)
    end
end)

-- ══════════════════════════════════════
--  API PÚBLICA
-- ══════════════════════════════════════

--- Cria uma categoria de módulos
function NexusLib:addCategory(name, color)
    if table.find(_categories, name) then return end
    table.insert(_categories, name)

    -- Cria tab
    local tabBtn = Instance.new("TextButton")
    tabBtn.Name = name; tabBtn.Size = UDim2.new(0,84,0,26)
    tabBtn.BackgroundColor3 = Color3.fromRGB(255,255,255); tabBtn.BackgroundTransparency = 1
    tabBtn.BorderSizePixel = 0; tabBtn.Text = name:upper()
    tabBtn.TextColor3 = Color3.fromRGB(255,255,255); tabBtn.TextTransparency = 0.5
    tabBtn.Font = Enum.Font.GothamBold; tabBtn.TextSize = 11; tabBtn.AutoButtonColor = false
    tabBtn.ZIndex = 4; tabBtn.Parent = TabBar
    Instance.new("UICorner",tabBtn).CornerRadius = UDim.new(0,5)
    local ts = Instance.new("UIStroke"); ts.Thickness=1; ts.Transparency=1; ts.Parent=tabBtn

    tabBtn.MouseButton1Click:Connect(function()
        NexusLib:showCategory(name)
    end)

    -- Seleciona primeira categoria automaticamente
    if #_categories == 1 then
        NexusLib:showCategory(name)
    end
end

--- Adiciona módulo a uma categoria
-- mod = { name, category, color, onEnable, onDisable, options = { {type,label,...} } }
function NexusLib:addModule(mod)
    mod.enabled  = mod.enabled or false
    mod.color    = mod.color or Color3.fromRGB(0,200,255)
    mod.category = mod.category or _categories[1] or "Misc"

    -- Garante categoria existe
    if not table.find(_categories, mod.category) then
        NexusLib:addCategory(mod.category)
    end

    table.insert(_modules, mod)
    local btn = createModuleButton(mod)
    _moduleButtons[mod.name] = btn

    -- Atualiza canvas se na categoria atual
    if _currentCat == mod.category then
        NexusLib:showCategory(_currentCat)
    end
    return mod
end

--- Mostra uma categoria no painel
function NexusLib:showCategory(cat)
    _currentCat = cat
    local order = 1
    local count = 0
    for _,m in ipairs(_modules) do
        local btn = _moduleButtons[m.name]
        if btn then
            local vis = m.category == cat
            btn.Visible = vis
            if vis then btn.LayoutOrder = order; order+=1; count+=1 end
        end
    end
    -- Tabs visuais
    for _,c in ipairs(TabBar:GetChildren()) do
        if c:IsA("TextButton") then
            local active = c.Name == cat
            local col = Color3.fromRGB(0,200,255)
            -- Tenta achar cor da categoria
            for _,m in ipairs(_modules) do
                if m.category == cat then col = m.color; break end
            end
            if active then
                c.TextColor3 = col; c.BackgroundColor3 = col; c.BackgroundTransparency = 0.85
                local s = c:FindFirstChildOfClass("UIStroke"); if s then s.Color=col; s.Transparency=0.3 end
            else
                c.TextColor3 = Color3.fromRGB(255,255,255); c.BackgroundColor3 = Color3.fromRGB(255,255,255); c.BackgroundTransparency = 1
                local s = c:FindFirstChildOfClass("UIStroke"); if s then s.Color=Color3.fromRGB(255,255,255); s.Transparency=1 end
            end
        end
    end
    local rows = math.ceil(count/4)
    ModuleArea.CanvasSize = UDim2.new(0,0,0,math.max(0,rows*68+10))
    ModuleArea.CanvasPosition = Vector2.new(0,0)
end

--- Remove um módulo pelo nome
function NexusLib:removeModule(name)
    for i,m in ipairs(_modules) do
        if m.name == name then
            table.remove(_modules,i)
            local btn = _moduleButtons[name]
            if btn then btn:Destroy() end
            _moduleButtons[name] = nil
            updateStatusCount(); updateHUD()
            NexusLib:showCategory(_currentCat)
            return
        end
    end
end

--- Retorna módulo pelo nome
function NexusLib:getModule(name)
    for _,m in ipairs(_modules) do
        if m.name == name then return m end
    end
    return nil
end

--- Ativa/desativa módulo por código
function NexusLib:setEnabled(name, state)
    local mod = NexusLib:getModule(name)
    if not mod then return end
    mod.enabled = state
    refreshBtn(mod)
    if mod.enabled and mod.onEnable then mod.onEnable() end
    if not mod.enabled and mod.onDisable then mod.onDisable() end
    updateStatusCount(); updateHUD()
end

--- Abre/fecha o menu
function NexusLib:setVisible(v) setVisible(v) end
function NexusLib:toggle() setVisible(not _menuOpen) end
function NexusLib:isOpen() return _menuOpen end

--- Define título
function NexusLib:setTitle(t) TitleLabel.Text = t end

--- Notificação rápida no canto
function NexusLib:notify(msg, duration)
    duration = duration or 3
    local nGui = Instance.new("ScreenGui"); nGui.ResetOnSpawn=false; nGui.IgnoreGuiInset=true
    nGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    local nFrame = Instance.new("Frame"); nFrame.Size = UDim2.new(0,240,0,36)
    nFrame.Position = UDim2.new(0,10,1,-50); nFrame.BackgroundColor3 = Color3.fromRGB(8,8,18)
    nFrame.BorderSizePixel=0; nFrame.ZIndex=50; nFrame.Parent=nGui
    Instance.new("UICorner",nFrame).CornerRadius=UDim.new(0,8)
    local ns = Instance.new("UIStroke"); ns.Color=Color3.fromRGB(0,200,255); ns.Transparency=0.4; ns.Parent=nFrame
    local nl = Instance.new("TextLabel"); nl.Size=UDim2.new(1,-12,1,0); nl.Position=UDim2.new(0,12,0,0)
    nl.BackgroundTransparency=1; nl.Text=msg; nl.TextColor3=Color3.fromRGB(200,220,255)
    nl.Font=Enum.Font.Gotham; nl.TextSize=12; nl.TextXAlignment=Enum.TextXAlignment.Left
    nl.ZIndex=51; nl.Parent=nFrame
    task.delay(duration, function()
        TweenService:Create(nFrame,TweenInfo.new(0.5),{BackgroundTransparency=1}):Play()
        TweenService:Create(nl,TweenInfo.new(0.5),{TextTransparency=1}):Play()
        TweenService:Create(ns,TweenInfo.new(0.5),{Transparency=1}):Play()
        task.delay(0.55, function() nGui:Destroy() end)
    end)
end

-- Hint inicial
do
    local hGui = Instance.new("ScreenGui"); hGui.ResetOnSpawn=false; hGui.IgnoreGuiInset=true
    hGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    local hF = Instance.new("Frame"); hF.Size=UDim2.new(0,240,0,28); hF.Position=UDim2.new(0.5,-120,0,10)
    hF.BackgroundColor3=Color3.fromRGB(10,10,18); hF.BorderSizePixel=0; hF.ZIndex=50; hF.Parent=hGui
    Instance.new("UICorner",hF).CornerRadius=UDim.new(0,14)
    local hs=Instance.new("UIStroke"); hs.Color=Color3.fromRGB(0,180,255); hs.Transparency=0.4; hs.Parent=hF
    local hl=Instance.new("TextLabel"); hl.Size=UDim2.new(1,0,1,0); hl.BackgroundTransparency=1
    hl.Text="INSERT  —  abrir / fechar"; hl.TextColor3=Color3.fromRGB(120,180,255)
    hl.Font=Enum.Font.Code; hl.TextSize=12; hl.ZIndex=51; hl.Parent=hF
    task.delay(4, function()
        TweenService:Create(hF,TweenInfo.new(1),{BackgroundTransparency=1}):Play()
        TweenService:Create(hl,TweenInfo.new(1),{TextTransparency=1}):Play()
        TweenService:Create(hs,TweenInfo.new(1),{Transparency=1}):Play()
        task.delay(1.1,function() hGui:Destroy() end)
    end)
end

print("[NexusLib] Library carregada!")
return NexusLib
