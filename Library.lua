local multihubx = {}
multihubx.__index = multihubx

local tweenservice = game:GetService("TweenService")
local uis          = game:GetService("UserInputService")
local players      = game:GetService("Players")
local lp           = players.LocalPlayer

local function makecorner(radius, parent)
    local c = Instance.new("UICorner")
    c.CornerRadius = radius or UDim.new(0, 0)
    c.Parent = parent
    return c
end

local function makestroke(color, thickness, parent)
    local s = Instance.new("UIStroke")
    s.Color     = color     or Color3.fromRGB(210, 25, 25)
    s.Thickness = thickness or 1
    s.Parent    = parent
    return s
end

local function makepad(t, l, r, b, parent)
    local p = Instance.new("UIPadding")
    p.PaddingTop    = UDim.new(0, t or 0)
    p.PaddingLeft   = UDim.new(0, l or 0)
    p.PaddingRight  = UDim.new(0, r or 0)
    p.PaddingBottom = UDim.new(0, b or 0)
    p.Parent = parent
    return p
end

local DARK  = Color3.fromRGB(15,  15,  15 )
local DARK2 = Color3.fromRGB(18,  18,  18 )
local DARK3 = Color3.fromRGB(22,  22,  22 )
local DARK4 = Color3.fromRGB(25,  25,  25 )
local DARK5 = Color3.fromRGB(20,  20,  20 )
local GREY1 = Color3.fromRGB(150, 150, 150)
local GREY2 = Color3.fromRGB(200, 200, 200)
local GREY3 = Color3.fromRGB(210, 210, 210)
local GREY4 = Color3.fromRGB(38,  38,  38 )
local GREY5 = Color3.fromRGB(45,  45,  45 )
local GREY6 = Color3.fromRGB(28,  28,  28 )
local GREY7 = Color3.fromRGB(55,  55,  55 )
local WHITE = Color3.fromRGB(255, 255, 255)

function multihubx:createwindow(config)
    config = config or {}
    local title     = config.title     or "multi hub x"
    local subtitle  = config.subtitle  or ""
    local size      = config.size      or UDim2.new(0, 580, 0, 390)
    local togglekey = config.togglekey or Enum.KeyCode.RightShift

    local playergui = lp:WaitForChild("PlayerGui")
    local screengui = Instance.new("ScreenGui")
    screengui.Name           = "multihubx_" .. title:lower():gsub("%s","")
    screengui.ResetOnSpawn   = false
    screengui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screengui.Parent         = playergui

    -- blur effect (behind game world, toggled with GUI visibility)
    local lighting = game:GetService("Lighting")
    local blureffect = Instance.new("BlurEffect")
    blureffect.Size    = 0
    blureffect.Enabled = false
    blureffect.Parent  = lighting
    local blurenabled  = false
    local blurintensity = 20  -- default blur size when enabled

    local accentcolor    = Color3.fromRGB(210, 25, 25)
    local accentobjs     = {}
    local keybindregistry = {}
    local notifstack     = {}

    -- ── floating keybind panel (right side, draggable) ──────────────────────
    local kbfloat = Instance.new("Frame")
    kbfloat.Name = "keybindpanel"
    kbfloat.Size = UDim2.new(0, 200, 0, 28)
    kbfloat.Position = UDim2.new(1, -210, 0.5, -80)
    kbfloat.BackgroundColor3 = DARK
    kbfloat.BorderSizePixel = 0
    kbfloat.ZIndex = 30
    kbfloat.Visible = false
    kbfloat.Parent = screengui

    local kbfloatstroke = Instance.new("UIStroke")
    kbfloatstroke.Color = accentcolor; kbfloatstroke.Thickness = 1; kbfloatstroke.Parent = kbfloat

    local kbfloatherbar = Instance.new("Frame")
    kbfloatherbar.Size = UDim2.new(1, 0, 0, 22)
    kbfloatherbar.BackgroundColor3 = DARK5
    kbfloatherbar.BorderSizePixel = 0; kbfloatherbar.ZIndex = 31; kbfloatherbar.Parent = kbfloat

    local kbfloatherlbl = Instance.new("TextLabel")
    kbfloatherlbl.Size = UDim2.new(1, -8, 1, 0)
    kbfloatherlbl.Position = UDim2.new(0, 6, 0, 0)
    kbfloatherlbl.BackgroundTransparency = 1; kbfloatherlbl.Text = "keybinds"
    kbfloatherlbl.TextColor3 = accentcolor
    kbfloatherlbl.TextSize = 11; kbfloatherlbl.Font = Enum.Font.GothamBold
    kbfloatherlbl.TextXAlignment = Enum.TextXAlignment.Left
    kbfloatherlbl.ZIndex = 32; kbfloatherlbl.Parent = kbfloatherbar

    local kbfloatlist = Instance.new("Frame")
    kbfloatlist.Size = UDim2.new(1, 0, 1, -22)
    kbfloatlist.Position = UDim2.new(0, 0, 0, 22)
    kbfloatlist.BackgroundTransparency = 1; kbfloatlist.BorderSizePixel = 0
    kbfloatlist.ZIndex = 31; kbfloatlist.Parent = kbfloat

    local kbfloatlayout = Instance.new("UIListLayout")
    kbfloatlayout.SortOrder = Enum.SortOrder.LayoutOrder
    kbfloatlayout.Padding = UDim.new(0, 1); kbfloatlayout.Parent = kbfloatlist

    local kbfloatpad = Instance.new("UIPadding")
    kbfloatpad.PaddingTop = UDim.new(0, 3); kbfloatpad.PaddingBottom = UDim.new(0, 3)
    kbfloatpad.PaddingLeft = UDim.new(0, 4); kbfloatpad.PaddingRight = UDim.new(0, 4)
    kbfloatpad.Parent = kbfloatlist

    -- header dragging
    local kbfdrag, kbfdragstart, kbfstartpos = false, nil, nil
    kbfloatherbar.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            kbfdrag = true; kbfdragstart = inp.Position; kbfstartpos = kbfloat.Position
        end
    end)
    kbfloatherbar.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then kbfdrag = false end
    end)
    uis.InputChanged:Connect(function(inp)
        if kbfdrag and inp.UserInputType == Enum.UserInputType.MouseMovement then
            local d = inp.Position - kbfdragstart
            kbfloat.Position = UDim2.new(kbfstartpos.X.Scale, kbfstartpos.X.Offset + d.X,
                kbfstartpos.Y.Scale, kbfstartpos.Y.Offset + d.Y)
        end
    end)
    uis.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then kbfdrag = false end
    end)

    local kbfrows = {}
    local function refreshkbfloat()
        for _, r in ipairs(kbfrows) do r:Destroy() end
        kbfrows = {}
        for _, entry in ipairs(keybindregistry) do
            local r = Instance.new("Frame")
            r.Size = UDim2.new(1, 0, 0, 20)
            r.BackgroundTransparency = 1; r.BorderSizePixel = 0
            r.ZIndex = 32; r.Parent = kbfloatlist
            table.insert(kbfrows, r)

            local isactive = entry.getstate()
            local dot = Instance.new("Frame")
            dot.Size = UDim2.new(0, 7, 0, 7)
            dot.Position = UDim2.new(0, 0, 0.5, -3)
            dot.BackgroundColor3 = isactive and accentcolor or GREY5
            dot.BorderSizePixel = 0; dot.ZIndex = 33; dot.Parent = r
            Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

            local keylbl = Instance.new("TextLabel")
            keylbl.Size = UDim2.new(0, 55, 1, 0)
            keylbl.Position = UDim2.new(0, 12, 0, 0)
            keylbl.BackgroundTransparency = 1
            keylbl.Text = "[" .. string.lower(entry.getkey()) .. "]"
            keylbl.TextColor3 = isactive and accentcolor or GREY1
            keylbl.TextSize = 10; keylbl.Font = Enum.Font.GothamSemibold
            keylbl.TextXAlignment = Enum.TextXAlignment.Left
            keylbl.ZIndex = 33; keylbl.Parent = r

            local namelbl = Instance.new("TextLabel")
            namelbl.Size = UDim2.new(1, -70, 1, 0)
            namelbl.Position = UDim2.new(0, 70, 0, 0)
            namelbl.BackgroundTransparency = 1
            namelbl.Text = entry.title
            namelbl.TextColor3 = isactive and GREY3 or GREY1
            namelbl.TextSize = 10; namelbl.Font = Enum.Font.Gotham
            namelbl.TextXAlignment = Enum.TextXAlignment.Left
            namelbl.TextTruncate = Enum.TextTruncate.AtEnd
            namelbl.ZIndex = 33; namelbl.Parent = r
        end
        local cnt = #keybindregistry
        kbfloat.Size = UDim2.new(0, 200, 0, 22 + math.max(1, cnt) * 21 + 6)
    end

    task.spawn(function()
        while screengui.Parent do task.wait(0.25); refreshkbfloat() end
    end)

    local function regaccent(obj, prop)
        table.insert(accentobjs, { obj = obj, prop = prop })
    end

    local function applyaccent(obj, prop, instant)
        if instant then
            obj[prop] = accentcolor
        else
            tweenservice:Create(obj, TweenInfo.new(0.25), { [prop] = accentcolor }):Play()
        end
    end

    local function updatetheme(color)
        accentcolor = color
        kbfloatstroke.Color = color
        kbfloatherlbl.TextColor3 = color
        for _, item in ipairs(accentobjs) do
            tweenservice:Create(item.obj, TweenInfo.new(0.25), { [item.prop] = color }):Play()
        end
    end

    local notifstackframe = Instance.new("Frame")
    notifstackframe.Size = UDim2.new(0, 240, 1, 0)
    notifstackframe.Position = UDim2.new(1, -250, 0, 0)
    notifstackframe.BackgroundTransparency = 1
    notifstackframe.BorderSizePixel = 0
    notifstackframe.ZIndex = 50
    notifstackframe.Parent = screengui

    -- sendnotif accepts either a string OR {title=..., text=...}
    local function sendnotif(data)
        local ntitle, ntext
        if type(data) == "table" then
            ntitle = data.title or "notice"
            ntext  = data.text  or ""
        else
            ntitle = nil
            ntext  = tostring(data)
        end

        local nfH = ntitle and 54 or 40
        local nf = Instance.new("Frame")
        nf.Size = UDim2.new(1, 0, 0, nfH)
        nf.Position = UDim2.new(0, 0, 1, -((nfH + 4) * (#notifstack + 1) + 10))
        nf.BackgroundColor3 = DARK2
        nf.BackgroundTransparency = 1
        nf.BorderSizePixel = 0
        nf.ZIndex = 51
        nf.Parent = notifstackframe
        local ns = makestroke(accentcolor, 1, nf)

        -- left accent bar
        local accentbar = Instance.new("Frame")
        accentbar.Size = UDim2.new(0, 3, 1, -4)
        accentbar.Position = UDim2.new(0, 0, 0, 2)
        accentbar.BackgroundColor3 = accentcolor
        accentbar.BorderSizePixel = 0
        accentbar.ZIndex = 52
        accentbar.Parent = nf
        regaccent(accentbar, "BackgroundColor3")

        if ntitle then
            local ntlbl = Instance.new("TextLabel")
            ntlbl.Size = UDim2.new(1, -16, 0, 18)
            ntlbl.Position = UDim2.new(0, 10, 0, 5)
            ntlbl.BackgroundTransparency = 1
            ntlbl.Text = ntitle
            ntlbl.TextColor3 = accentcolor
            ntlbl.TextSize = 12
            ntlbl.Font = Enum.Font.GothamBold
            ntlbl.TextXAlignment = Enum.TextXAlignment.Left
            ntlbl.ZIndex = 52
            ntlbl.Parent = nf
            regaccent(ntlbl, "TextColor3")

            local nfl = Instance.new("TextLabel")
            nfl.Size = UDim2.new(1, -16, 0, 22)
            nfl.Position = UDim2.new(0, 10, 0, 24)
            nfl.BackgroundTransparency = 1
            nfl.Text = ntext
            nfl.TextColor3 = GREY2
            nfl.TextSize = 11
            nfl.Font = Enum.Font.Gotham
            nfl.TextXAlignment = Enum.TextXAlignment.Left
            nfl.TextWrapped = true
            nfl.ZIndex = 52
            nfl.Parent = nf

            table.insert(notifstack, nf)
            tweenservice:Create(nf, TweenInfo.new(0.2), { BackgroundTransparency = 0 }):Play()
            local bar = Instance.new("Frame")
            bar.Size = UDim2.new(1, 0, 0, 2); bar.Position = UDim2.new(0, 0, 1, -2)
            bar.BackgroundColor3 = accentcolor; bar.BorderSizePixel = 0; bar.ZIndex = 52; bar.Parent = nf
            tweenservice:Create(bar, TweenInfo.new(3.5, Enum.EasingStyle.Linear), { Size = UDim2.new(0,0,0,2) }):Play()
            task.delay(3.5, function()
                tweenservice:Create(nf,   TweenInfo.new(0.3), { BackgroundTransparency = 1 }):Play()
                tweenservice:Create(nfl,  TweenInfo.new(0.3), { TextTransparency = 1 }):Play()
                tweenservice:Create(ntlbl,TweenInfo.new(0.3), { TextTransparency = 1 }):Play()
                task.wait(0.3)
                for i, v in ipairs(notifstack) do if v == nf then table.remove(notifstack, i); break end end
                nf:Destroy()
            end)
        else
            local nfl = Instance.new("TextLabel")
            nfl.Size = UDim2.new(1, -16, 1, -6)
            nfl.Position = UDim2.new(0, 10, 0, 2)
            nfl.BackgroundTransparency = 1
            nfl.Text = ntext
            nfl.TextColor3 = GREY3
            nfl.TextSize = 11
            nfl.Font = Enum.Font.Gotham
            nfl.TextXAlignment = Enum.TextXAlignment.Left
            nfl.TextWrapped = true
            nfl.ZIndex = 52
            nfl.Parent = nf

            table.insert(notifstack, nf)
            tweenservice:Create(nf, TweenInfo.new(0.2), { BackgroundTransparency = 0 }):Play()
            local bar = Instance.new("Frame")
            bar.Size = UDim2.new(1, 0, 0, 2); bar.Position = UDim2.new(0, 0, 1, -2)
            bar.BackgroundColor3 = accentcolor; bar.BorderSizePixel = 0; bar.ZIndex = 52; bar.Parent = nf
            tweenservice:Create(bar, TweenInfo.new(3.5, Enum.EasingStyle.Linear), { Size = UDim2.new(0,0,0,2) }):Play()
            task.delay(3.5, function()
                tweenservice:Create(nf,  TweenInfo.new(0.3), { BackgroundTransparency = 1 }):Play()
                tweenservice:Create(nfl, TweenInfo.new(0.3), { TextTransparency = 1 }):Play()
                task.wait(0.3)
                for i, v in ipairs(notifstack) do if v == nf then table.remove(notifstack, i); break end end
                nf:Destroy()
            end)
        end
    end

    local confirmpopup = Instance.new("Frame")
    confirmpopup.Size = UDim2.new(0, 310, 0, 165)
    confirmpopup.Position = UDim2.new(0.5, -155, 0.5, -82)
    confirmpopup.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
    confirmpopup.BorderSizePixel = 0
    confirmpopup.ZIndex = 100
    confirmpopup.Visible = false
    confirmpopup.Parent = screengui
    local cpstroke = makestroke(accentcolor, 2, confirmpopup)
    regaccent(cpstroke, "Color")

    local cptitle = Instance.new("TextLabel")
    cptitle.Size = UDim2.new(1, -16, 0, 28)
    cptitle.Position = UDim2.new(0, 8, 0, 8)
    cptitle.BackgroundTransparency = 1
    cptitle.Text = "are you sure?"
    cptitle.TextColor3 = accentcolor
    cptitle.TextSize = 14
    cptitle.Font = Enum.Font.GothamBold
    cptitle.TextXAlignment = Enum.TextXAlignment.Left
    cptitle.ZIndex = 101
    cptitle.Parent = confirmpopup
    regaccent(cptitle, "TextColor3")

    local cpwarn = Instance.new("TextLabel")
    cpwarn.Size = UDim2.new(1, -16, 0, 60)
    cpwarn.Position = UDim2.new(0, 8, 0, 38)
    cpwarn.BackgroundTransparency = 1
    cpwarn.Text = ""
    cpwarn.TextColor3 = Color3.fromRGB(155, 155, 155)
    cpwarn.TextSize = 11
    cpwarn.Font = Enum.Font.Gotham
    cpwarn.TextXAlignment = Enum.TextXAlignment.Left
    cpwarn.TextWrapped = true
    cpwarn.ZIndex = 101
    cpwarn.Parent = confirmpopup

    local cpdiv = Instance.new("Frame")
    cpdiv.Size = UDim2.new(1, -16, 0, 1)
    cpdiv.Position = UDim2.new(0, 8, 0, 105)
    cpdiv.BackgroundColor3 = GREY4
    cpdiv.BorderSizePixel = 0
    cpdiv.ZIndex = 101
    cpdiv.Parent = confirmpopup

    local yesbtn = Instance.new("TextButton")
    yesbtn.Size = UDim2.new(0.45, -4, 0, 32)
    yesbtn.Position = UDim2.new(0, 8, 0, 116)
    yesbtn.BackgroundColor3 = Color3.fromRGB(140, 20, 20)
    yesbtn.Text = "yes"
    yesbtn.TextColor3 = WHITE
    yesbtn.TextSize = 12
    yesbtn.Font = Enum.Font.GothamBold
    yesbtn.BorderSizePixel = 0
    yesbtn.ZIndex = 102
    yesbtn.Parent = confirmpopup

    local nobtn = Instance.new("TextButton")
    nobtn.Size = UDim2.new(0.45, -4, 0, 32)
    nobtn.Position = UDim2.new(0.55, -4, 0, 116)
    nobtn.BackgroundColor3 = GREY6
    nobtn.Text = "no"
    nobtn.TextColor3 = GREY2
    nobtn.TextSize = 12
    nobtn.Font = Enum.Font.GothamBold
    nobtn.BorderSizePixel = 0
    nobtn.ZIndex = 102
    nobtn.Parent = confirmpopup
    makestroke(GREY7, 1, nobtn)

    local pendingyes, pendingrevert = nil, nil

    yesbtn.MouseButton1Click:Connect(function()
        confirmpopup.Visible = false
        if pendingyes then pendingyes() end
        pendingyes = nil; pendingrevert = nil
    end)
    nobtn.MouseButton1Click:Connect(function()
        confirmpopup.Visible = false
        if pendingrevert then pendingrevert() end
        pendingyes = nil; pendingrevert = nil
    end)

    local mainframe = Instance.new("Frame")
    mainframe.Name = "mainframe"
    mainframe.Size = size
    mainframe.Position = UDim2.new(0.5, -size.X.Offset/2, 0.5, -size.Y.Offset/2)
    mainframe.BackgroundColor3 = DARK
    mainframe.BackgroundTransparency = 0
    mainframe.BorderSizePixel = 0
    mainframe.ClipsDescendants = true
    mainframe.Parent = screengui
    local mainstroke = makestroke(accentcolor, 2, mainframe)
    regaccent(mainstroke, "Color")

    local titlebarH = subtitle ~= "" and 46 or 34

    local titlebar = Instance.new("Frame")
    titlebar.Size = UDim2.new(1, 0, 0, titlebarH)
    titlebar.BackgroundColor3 = DARK5
    titlebar.BorderSizePixel = 0
    titlebar.ZIndex = 2
    titlebar.Parent = mainframe

    local titlelbl = Instance.new("TextLabel")
    titlelbl.Size = UDim2.new(1, -70, 0, subtitle ~= "" and 22 or 34)
    titlelbl.Position = UDim2.new(0, 10, 0, subtitle ~= "" and 4 or 0)
    titlelbl.BackgroundTransparency = 1
    titlelbl.Text = title
    titlelbl.TextColor3 = accentcolor
    titlelbl.TextSize = 14
    titlelbl.Font = Enum.Font.GothamBold
    titlelbl.TextXAlignment = Enum.TextXAlignment.Left
    titlelbl.ZIndex = 2
    titlelbl.Parent = titlebar
    regaccent(titlelbl, "TextColor3")

    if subtitle ~= "" then
        local sublbl = Instance.new("TextLabel")
        sublbl.Size = UDim2.new(1, -70, 0, 16)
        sublbl.Position = UDim2.new(0, 10, 0, 27)
        sublbl.BackgroundTransparency = 1
        sublbl.Text = subtitle
        sublbl.TextColor3 = Color3.fromRGB(110, 110, 110)
        sublbl.TextSize = 11
        sublbl.Font = Enum.Font.Gotham
        sublbl.TextXAlignment = Enum.TextXAlignment.Left
        sublbl.ZIndex = 2
        sublbl.Parent = titlebar
    end

    local function maketitlebtn(txt, xoff, bg)
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(0, 28, 0, 24)
        b.Position = UDim2.new(1, xoff, 0, (titlebarH - 24) / 2)
        b.BackgroundColor3 = bg
        b.Text = txt
        b.TextColor3 = WHITE
        b.TextSize = 12
        b.Font = Enum.Font.GothamBold
        b.BorderSizePixel = 0
        b.ZIndex = 3
        b.Parent = titlebar
        return b
    end

    local closebtn = maketitlebtn("x", -32, Color3.fromRGB(150, 20, 20))
    local minbtn   = maketitlebtn("-", -64, GREY7)

    local kbtogbtn = maketitlebtn("kb", -96, GREY7)
    kbtogbtn.TextSize = 10
    local kbpanelopen = false
    kbtogbtn.MouseButton1Click:Connect(function()
        kbpanelopen = not kbpanelopen
        kbfloat.Visible = kbpanelopen
        kbtogbtn.BackgroundColor3 = kbpanelopen and Color3.fromRGB(30, 10, 10) or GREY7
    end)

    local sep = Instance.new("Frame")
    sep.Size = UDim2.new(1, 0, 0, 1)
    sep.Position = UDim2.new(0, 0, 0, titlebarH)
    sep.BackgroundColor3 = accentcolor
    sep.BorderSizePixel = 0
    sep.ZIndex = 2
    sep.Parent = mainframe
    regaccent(sep, "BackgroundColor3")

    local tabpanel = Instance.new("Frame")
    tabpanel.Size = UDim2.new(0, 120, 1, -(titlebarH+1))
    tabpanel.Position = UDim2.new(0, 0, 0, titlebarH+1)
    tabpanel.BackgroundColor3 = DARK2
    tabpanel.BorderSizePixel = 0
    tabpanel.ClipsDescendants = true
    tabpanel.Parent = mainframe

    local tabdiv = Instance.new("Frame")
    tabdiv.Size = UDim2.new(0, 1, 1, -(titlebarH+1))
    tabdiv.Position = UDim2.new(0, 120, 0, titlebarH+1)
    tabdiv.BackgroundColor3 = accentcolor
    tabdiv.BorderSizePixel = 0
    tabdiv.Parent = mainframe
    regaccent(tabdiv, "BackgroundColor3")

    local tablayout = Instance.new("UIListLayout")
    tablayout.SortOrder = Enum.SortOrder.LayoutOrder
    tablayout.Padding = UDim.new(0, 0)
    tablayout.Parent = tabpanel

    local contentarea = Instance.new("Frame")
    contentarea.Size = UDim2.new(1, -121, 1, -(titlebarH+1))
    contentarea.Position = UDim2.new(0, 121, 0, titlebarH+1)
    contentarea.BackgroundTransparency = 1
    contentarea.BorderSizePixel = 0
    contentarea.ClipsDescendants = true
    contentarea.Parent = mainframe

    local miniwidget = Instance.new("Frame")
    miniwidget.Name = "miniwidget"
    miniwidget.Size = UDim2.new(0, 54, 0, 54)
    miniwidget.Position = UDim2.new(0, 30, 0.5, -27)
    miniwidget.BackgroundColor3 = DARK
    miniwidget.BorderSizePixel = 0
    miniwidget.Visible = false
    miniwidget.ZIndex = 20
    miniwidget.Parent = screengui
    makecorner(UDim.new(1, 0), miniwidget)
    local ministr = makestroke(accentcolor, 2, miniwidget)
    regaccent(ministr, "Color")

    local minilbl = Instance.new("TextLabel")
    minilbl.Size = UDim2.new(1, 0, 0.6, 0)
    minilbl.Position = UDim2.new(0, 0, 0.1, 0)
    minilbl.BackgroundTransparency = 1
    minilbl.Text = "m-x"
    minilbl.TextColor3 = accentcolor
    minilbl.TextSize = 12
    minilbl.Font = Enum.Font.GothamBold
    minilbl.ZIndex = 21
    minilbl.Parent = miniwidget
    regaccent(minilbl, "TextColor3")

    local restorestrip = Instance.new("Frame")
    restorestrip.Size = UDim2.new(0, 120, 0, 28)
    restorestrip.Position = UDim2.new(0.5, -60, 1, -36)
    restorestrip.BackgroundColor3 = DARK2
    restorestrip.BorderSizePixel = 0
    restorestrip.Visible = false
    restorestrip.ZIndex = 20
    restorestrip.Parent = screengui
    local restorestroke = makestroke(accentcolor, 1, restorestrip)
    regaccent(restorestroke, "Color")

    local restorebtn = Instance.new("TextButton")
    restorebtn.Size = UDim2.new(1, 0, 1, 0)
    restorebtn.BackgroundTransparency = 1
    restorebtn.Text = "show ui"
    restorebtn.TextColor3 = accentcolor
    restorebtn.TextSize = 11
    restorebtn.Font = Enum.Font.GothamBold
    restorebtn.ZIndex = 21
    restorebtn.Parent = restorestrip
    regaccent(restorebtn, "TextColor3")

    -- restore strip dragging
    local rsdragging, rsdragstart, rsstartpos, rshasmoved = false, nil, nil, false
    restorestrip.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            rsdragging = true; rshasmoved = false
            rsdragstart = inp.Position; rsstartpos = restorestrip.Position
        end
    end)
    restorestrip.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then rsdragging = false end
    end)

    local minihitbox = Instance.new("TextButton")
    minihitbox.Size = UDim2.new(1, 0, 1, 0)
    minihitbox.BackgroundTransparency = 1
    minihitbox.Text = ""
    minihitbox.ZIndex = 22
    minihitbox.Parent = miniwidget

    local minidragging, minidragstart, ministartpos, minihasmoved = false, nil, nil, false

    minihitbox.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            minidragging = true; minihasmoved = false
            minidragstart = inp.Position; ministartpos = miniwidget.Position
        end
    end)
    minihitbox.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then minidragging = false end
    end)
    local function collapse()
        mainframe.Visible = false
        miniwidget.Visible = true
        restorestrip.Visible = true
        if blurenabled then
            tweenservice:Create(blureffect, TweenInfo.new(0.25), { Size = 0 }):Play()
            task.delay(0.25, function() blureffect.Enabled = false end)
        end
    end

    local function showgui()
        miniwidget.Visible = false
        restorestrip.Visible = false
        mainframe.Visible = true
        if blurenabled then
            blureffect.Size = 0
            blureffect.Enabled = true
            tweenservice:Create(blureffect, TweenInfo.new(0.25), { Size = blurintensity }):Play()
        end
    end

    minihitbox.MouseButton1Click:Connect(function()
        if not minihasmoved then showgui() end
    end)
    restorebtn.MouseButton1Click:Connect(function()
        if not rshasmoved then showgui() end
    end)

    closebtn.MouseButton1Click:Connect(collapse)
    minbtn.MouseButton1Click:Connect(collapse)

    local maindragging, maindragstart, mainstartpos = false, nil, nil
    titlebar.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            maindragging = true; maindragstart = inp.Position; mainstartpos = mainframe.Position
        end
    end)
    titlebar.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then maindragging = false end
    end)

    local currenttogglekey = togglekey
    local listeningforkey = false

    uis.InputChanged:Connect(function(inp)
        if inp.UserInputType ~= Enum.UserInputType.MouseMovement then return end
        if maindragging and maindragstart then
            local d = inp.Position - maindragstart
            mainframe.Position = UDim2.new(
                mainstartpos.X.Scale, mainstartpos.X.Offset + d.X,
                mainstartpos.Y.Scale, mainstartpos.Y.Offset + d.Y)
        end
        if minidragging and minidragstart then
            local d = inp.Position - minidragstart
            if math.abs(d.X) > 3 or math.abs(d.Y) > 3 then minihasmoved = true end
            miniwidget.Position = UDim2.new(
                ministartpos.X.Scale, ministartpos.X.Offset + d.X,
                ministartpos.Y.Scale, ministartpos.Y.Offset + d.Y)
        end
        if rsdragging and rsdragstart then
            local d = inp.Position - rsdragstart
            if math.abs(d.X) > 3 or math.abs(d.Y) > 3 then rshasmoved = true end
            restorestrip.Position = UDim2.new(
                rsstartpos.X.Scale, rsstartpos.X.Offset + d.X,
                rsstartpos.Y.Scale, rsstartpos.Y.Offset + d.Y)
        end
    end)

    uis.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            maindragging = false; minidragging = false
            if rsdragging then
                rsdragging = false
                -- reset moved flag after a tick so click handler fires correctly next time
                task.delay(0, function() rshasmoved = false end)
            end
            if minidragging then
                task.delay(0, function() minihasmoved = false end)
            end
        end
    end)

    uis.InputBegan:Connect(function(inp, gpe)
        if listeningforkey and inp.UserInputType == Enum.UserInputType.Keyboard then
            listeningforkey = false
            currenttogglekey = inp.KeyCode
            return
        end
        if not listeningforkey and inp.KeyCode == currenttogglekey and not gpe then
            if mainframe.Visible then collapse()
            else showgui()
            end
        end
    end)

    local tablist  = {}
    local pagelist = {}
    local activetab = nil
    local taborder  = 0

    local function selecttab(name)
        if activetab == name then return end
        activetab = name
        for tname, info in pairs(tablist) do
            local active = tname == name
            info.btn.TextColor3 = active and WHITE or GREY1
            info.btn.BackgroundColor3 = DARK2
            info.indicator.Visible = active
            if active then info.indicator.BackgroundColor3 = accentcolor end
        end
        for pname, page in pairs(pagelist) do
            page.Visible = pname == name
        end
    end

    local window = {}

    function window:addtab(name)
        taborder += 1
        local order = taborder

        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 34)
        btn.BackgroundColor3 = DARK2
        btn.Text = name
        btn.TextColor3 = GREY1
        btn.TextSize = 12
        btn.Font = Enum.Font.GothamSemibold
        btn.BorderSizePixel = 0
        btn.AutoButtonColor = false
        btn.LayoutOrder = order
        btn.Parent = tabpanel

        local indicator = Instance.new("Frame")
        indicator.Size = UDim2.new(0, 3, 0.6, 0)
        indicator.Position = UDim2.new(0, 0, 0.2, 0)
        indicator.BackgroundColor3 = accentcolor
        indicator.BorderSizePixel = 0
        indicator.Visible = false
        indicator.ZIndex = 2
        indicator.Parent = btn
        regaccent(indicator, "BackgroundColor3")

        tablist[name] = { btn = btn, indicator = indicator }

        local scroll = Instance.new("ScrollingFrame")
        scroll.Size = UDim2.new(1, 0, 1, 0)
        scroll.BackgroundTransparency = 1
        scroll.BorderSizePixel = 0
        scroll.ScrollBarThickness = 3
        scroll.ScrollBarImageColor3 = accentcolor
        scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
        scroll.Visible = false
        scroll.Parent = contentarea
        pagelist[name] = scroll
        regaccent(scroll, "ScrollBarImageColor3")

        local layout = Instance.new("UIListLayout")
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Padding = UDim.new(0, 4)
        layout.Parent = scroll

        makepad(8, 8, 8, 8, scroll)

        layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 16)
        end)

        btn.MouseButton1Click:Connect(function() selecttab(name) end)

        if activetab == nil then selecttab(name) end

        local tab = {}
        local page = scroll

        function tab:addsection(txt)
            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(1, 0, 0, 20)
            lbl.BackgroundTransparency = 1
            lbl.Text = txt
            lbl.TextColor3 = accentcolor
            lbl.TextSize = 11
            lbl.Font = Enum.Font.GothamBold
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.BorderSizePixel = 0
            lbl.Parent = page
            makepad(0, 4, 0, 0, lbl)
            regaccent(lbl, "TextColor3")
        end

        function tab:addtoggle(cfg)
            cfg = cfg or {}
            local txt     = cfg.title    or "toggle"
            local default = cfg.default  or false
            local cb      = cfg.callback

            local row = Instance.new("Frame")
            row.Size = UDim2.new(1, 0, 0, 32)
            row.BackgroundColor3 = DARK3
            row.BorderSizePixel = 0
            row.Parent = page

            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(1, -50, 1, 0)
            lbl.Position = UDim2.new(0, 10, 0, 0)
            lbl.BackgroundTransparency = 1
            lbl.Text = txt
            lbl.TextColor3 = GREY3
            lbl.TextSize = 12
            lbl.Font = Enum.Font.Gotham
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.Parent = row

            local togbg = Instance.new("Frame")
            togbg.Size = UDim2.new(0, 36, 0, 18)
            togbg.Position = UDim2.new(1, -44, 0.5, -9)
            togbg.BackgroundColor3 = GREY5
            togbg.BorderSizePixel = 0
            togbg.Parent = row
            makecorner(UDim.new(1, 0), togbg)

            local circle = Instance.new("Frame")
            circle.Size = UDim2.new(0, 12, 0, 12)
            circle.Position = UDim2.new(0, 3, 0.5, -6)
            circle.BackgroundColor3 = GREY1
            circle.BorderSizePixel = 0
            circle.Parent = togbg
            makecorner(UDim.new(1, 0), circle)

            local state = default
            local setstate
            setstate = function(v)
                state = v
                tweenservice:Create(circle, TweenInfo.new(0.12), {
                    Position = v and UDim2.new(1,-15,0.5,-6) or UDim2.new(0,3,0.5,-6)
                }):Play()
                tweenservice:Create(togbg, TweenInfo.new(0.12), {
                    BackgroundColor3 = v and accentcolor or GREY5
                }):Play()
                tweenservice:Create(circle, TweenInfo.new(0.12), {
                    BackgroundColor3 = v and WHITE or GREY1
                }):Play()
                if cb then cb(v) end
            end
            setstate(state)

            local clickbtn = Instance.new("TextButton")
            clickbtn.Size = UDim2.new(1, 0, 1, 0)
            clickbtn.BackgroundTransparency = 1
            clickbtn.Text = ""
            clickbtn.Parent = row
            clickbtn.MouseButton1Click:Connect(function() setstate(not state) end)

            return setstate
        end

        function tab:addslider(cfg)
            cfg = cfg or {}
            local txt     = cfg.title    or "slider"
            local default = cfg.default  or 50
            local min     = cfg.min      or 0
            local max     = cfg.max      or 100
            local cb      = cfg.callback

            local row = Instance.new("Frame")
            row.Size = UDim2.new(1, 0, 0, 46)
            row.BackgroundColor3 = DARK3
            row.BorderSizePixel = 0
            row.Parent = page

            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(1, -60, 0, 22)
            lbl.Position = UDim2.new(0, 10, 0, 2)
            lbl.BackgroundTransparency = 1
            lbl.Text = txt
            lbl.TextColor3 = GREY3
            lbl.TextSize = 12
            lbl.Font = Enum.Font.Gotham
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.Parent = row

            local vallbl = Instance.new("TextLabel")
            vallbl.Size = UDim2.new(0, 55, 0, 22)
            vallbl.Position = UDim2.new(1, -60, 0, 2)
            vallbl.BackgroundTransparency = 1
            vallbl.Text = tostring(default)
            vallbl.TextColor3 = accentcolor
            vallbl.TextSize = 12
            vallbl.Font = Enum.Font.GothamBold
            vallbl.TextXAlignment = Enum.TextXAlignment.Right
            vallbl.Parent = row
            regaccent(vallbl, "TextColor3")

            local track = Instance.new("Frame")
            track.Size = UDim2.new(1, -20, 0, 5)
            track.Position = UDim2.new(0, 10, 0, 32)
            track.BackgroundColor3 = GREY4
            track.BorderSizePixel = 0
            track.Parent = row

            local initrel = math.clamp((default - min) / (max - min), 0, 1)
            local fill = Instance.new("Frame")
            fill.Size = UDim2.new(initrel, 0, 1, 0)
            fill.BackgroundColor3 = accentcolor
            fill.BorderSizePixel = 0
            fill.Parent = track
            regaccent(fill, "BackgroundColor3")

            local knob = Instance.new("Frame")
            knob.Size = UDim2.new(0, 11, 0, 11)
            knob.Position = UDim2.new(1, -5, 0.5, -5)
            knob.BackgroundColor3 = Color3.fromRGB(230, 230, 230)
            knob.BorderSizePixel = 0
            knob.Parent = fill
            makecorner(UDim.new(1, 0), knob)

            local slideactive = false
            local function updateslider(ix)
                local rel = math.clamp((ix - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
                fill.Size = UDim2.new(rel, 0, 1, 0)
                local val = math.floor(min + (max - min) * rel + 0.5)
                vallbl.Text = tostring(val)
                if cb then cb(val) end
            end

            track.InputBegan:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 then slideactive = true; updateslider(inp.Position.X) end
            end)
            knob.InputBegan:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 then slideactive = true end
            end)
            uis.InputEnded:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 then slideactive = false end
            end)
            uis.InputChanged:Connect(function(inp)
                if slideactive and inp.UserInputType == Enum.UserInputType.MouseMovement then updateslider(inp.Position.X) end
            end)
        end

        function tab:addbutton(cfg)
            cfg = cfg or {}
            local txt = cfg.title    or "button"
            local cb  = cfg.callback

            local btn2 = Instance.new("TextButton")
            btn2.Size = UDim2.new(1, 0, 0, 30)
            btn2.BackgroundColor3 = DARK4
            btn2.Text = txt
            btn2.TextColor3 = GREY3
            btn2.TextSize = 12
            btn2.Font = Enum.Font.GothamSemibold
            btn2.BorderSizePixel = 0
            btn2.AutoButtonColor = false
            btn2.Parent = page
            local bs = makestroke(accentcolor, 1, btn2)
            regaccent(bs, "Color")

            btn2.MouseButton1Click:Connect(function()
                tweenservice:Create(btn2, TweenInfo.new(0.1), { BackgroundColor3 = Color3.fromRGB(30,10,10) }):Play()
                task.wait(0.15)
                tweenservice:Create(btn2, TweenInfo.new(0.1), { BackgroundColor3 = DARK4 }):Play()
                if cb then cb() end
            end)
        end

        function tab:addconfirmbutton(cfg)
            cfg = cfg or {}
            local txt  = cfg.title    or "button"
            local warn = cfg.warning  or "are you sure?"
            local cb   = cfg.callback

            local btn2 = Instance.new("TextButton")
            btn2.Size = UDim2.new(1, 0, 0, 30)
            btn2.BackgroundColor3 = DARK4
            btn2.Text = txt
            btn2.TextColor3 = GREY3
            btn2.TextSize = 12
            btn2.Font = Enum.Font.GothamSemibold
            btn2.BorderSizePixel = 0
            btn2.AutoButtonColor = false
            btn2.Parent = page
            local bs = makestroke(accentcolor, 1, btn2)
            regaccent(bs, "Color")

            btn2.MouseButton1Click:Connect(function()
                tweenservice:Create(btn2, TweenInfo.new(0.1), { BackgroundColor3 = Color3.fromRGB(30,10,10) }):Play()
                task.wait(0.15)
                tweenservice:Create(btn2, TweenInfo.new(0.1), { BackgroundColor3 = DARK4 }):Play()
                cpwarn.Text = warn
                pendingyes = cb; pendingrevert = nil
                confirmpopup.Visible = true
            end)
        end

        function tab:addconfirmtoggle(cfg)
            cfg = cfg or {}
            local txt     = cfg.title    or "toggle"
            local warn    = cfg.warning  or "are you sure?"
            local default = cfg.default  or false
            local cb      = cfg.callback

            local row = Instance.new("Frame")
            row.Size = UDim2.new(1, 0, 0, 32)
            row.BackgroundColor3 = DARK3
            row.BorderSizePixel = 0
            row.Parent = page

            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(1, -50, 1, 0)
            lbl.Position = UDim2.new(0, 10, 0, 0)
            lbl.BackgroundTransparency = 1
            lbl.Text = txt
            lbl.TextColor3 = GREY3
            lbl.TextSize = 12
            lbl.Font = Enum.Font.Gotham
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.Parent = row

            local togbg = Instance.new("Frame")
            togbg.Size = UDim2.new(0, 36, 0, 18)
            togbg.Position = UDim2.new(1, -44, 0.5, -9)
            togbg.BackgroundColor3 = GREY5
            togbg.BorderSizePixel = 0
            togbg.Parent = row
            makecorner(UDim.new(1, 0), togbg)

            local circle = Instance.new("Frame")
            circle.Size = UDim2.new(0, 12, 0, 12)
            circle.Position = UDim2.new(0, 3, 0.5, -6)
            circle.BackgroundColor3 = GREY1
            circle.BorderSizePixel = 0
            circle.Parent = togbg
            makecorner(UDim.new(1, 0), circle)

            local state = default
            local setstate
            setstate = function(v, skipconfirm)
                if v and not skipconfirm then
                    cpwarn.Text = warn
                    pendingyes = function()
                        state = true
                        tweenservice:Create(circle, TweenInfo.new(0.12), { Position = UDim2.new(1,-15,0.5,-6) }):Play()
                        tweenservice:Create(togbg,  TweenInfo.new(0.12), { BackgroundColor3 = accentcolor }):Play()
                        tweenservice:Create(circle, TweenInfo.new(0.12), { BackgroundColor3 = WHITE }):Play()
                        if cb then cb(true) end
                    end
                    pendingrevert = function() setstate(false, true) end
                    confirmpopup.Visible = true
                    return
                end
                state = v
                tweenservice:Create(circle, TweenInfo.new(0.12), {
                    Position = v and UDim2.new(1,-15,0.5,-6) or UDim2.new(0,3,0.5,-6)
                }):Play()
                tweenservice:Create(togbg, TweenInfo.new(0.12), {
                    BackgroundColor3 = v and accentcolor or GREY5
                }):Play()
                tweenservice:Create(circle, TweenInfo.new(0.12), {
                    BackgroundColor3 = v and WHITE or GREY1
                }):Play()
                if not v and cb then cb(false) end
            end
            setstate(state, true)

            local clickbtn = Instance.new("TextButton")
            clickbtn.Size = UDim2.new(1, 0, 1, 0)
            clickbtn.BackgroundTransparency = 1
            clickbtn.Text = ""
            clickbtn.Parent = row
            clickbtn.MouseButton1Click:Connect(function() setstate(not state) end)

            return setstate
        end

        function tab:adddropdown(cfg)
            cfg = cfg or {}
            local txt    = cfg.title    or "dropdown"
            local values = cfg.values   or {}
            local cb     = cfg.callback

            -- outer container grows when open
            local container = Instance.new("Frame")
            container.Size = UDim2.new(1, 0, 0, 38)
            container.BackgroundColor3 = DARK3
            container.BorderSizePixel = 0
            container.ClipsDescendants = false
            container.ZIndex = 5
            container.Parent = page

            -- label above the button
            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(1, -10, 0, 16)
            lbl.Position = UDim2.new(0, 10, 0, 2)
            lbl.BackgroundTransparency = 1
            lbl.Text = txt
            lbl.TextColor3 = GREY1
            lbl.TextSize = 10
            lbl.Font = Enum.Font.GothamSemibold
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.ZIndex = 5
            lbl.Parent = container

            -- full-width button
            local dbtn = Instance.new("TextButton")
            dbtn.Size = UDim2.new(1, -16, 0, 24)
            dbtn.Position = UDim2.new(0, 8, 0, 18)
            dbtn.BackgroundColor3 = DARK4
            dbtn.Text = (values[1] or "none") .. "  ▾"
            dbtn.TextColor3 = GREY3
            dbtn.TextSize = 12
            dbtn.Font = Enum.Font.GothamSemibold
            dbtn.BorderSizePixel = 0
            dbtn.AutoButtonColor = false
            dbtn.ZIndex = 6
            dbtn.Parent = container
            local dbtns = makestroke(accentcolor, 1, dbtn)
            regaccent(dbtns, "Color")

            local ddframe = Instance.new("Frame")
            ddframe.Size = UDim2.new(1, -16, 0, 0)
            ddframe.Position = UDim2.new(0, 8, 1, 2)
            ddframe.BackgroundColor3 = DARK4
            ddframe.BorderSizePixel = 0
            ddframe.ZIndex = 10
            ddframe.Visible = false
            ddframe.ClipsDescendants = true
            ddframe.Parent = container
            local ddlayout = Instance.new("UIListLayout")
            ddlayout.SortOrder = Enum.SortOrder.LayoutOrder
            ddlayout.Parent = ddframe
            local dds = makestroke(accentcolor, 1, ddframe)
            regaccent(dds, "Color")

            local isopen = false
            local currentval = values[1] or "none"

            local function setvalues(vals)
                for _, c in ipairs(ddframe:GetChildren()) do
                    if c:IsA("TextButton") then c:Destroy() end
                end
                for _, v in ipairs(vals) do
                    local opt = Instance.new("TextButton")
                    opt.Size = UDim2.new(1, 0, 0, 26)
                    opt.BackgroundColor3 = DARK4
                    opt.Text = v
                    opt.TextColor3 = v == currentval and accentcolor or GREY2
                    opt.TextSize = 12
                    opt.Font = Enum.Font.Gotham
                    opt.BorderSizePixel = 0
                    opt.AutoButtonColor = false
                    opt.ZIndex = 11
                    opt.Parent = ddframe
                    opt.MouseEnter:Connect(function()
                        if opt.Text ~= currentval then
                            opt.BackgroundColor3 = GREY6
                        end
                    end)
                    opt.MouseLeave:Connect(function()
                        opt.BackgroundColor3 = DARK4
                    end)
                    opt.MouseButton1Click:Connect(function()
                        currentval = v
                        dbtn.Text = v .. "  ▾"
                        isopen = false
                        tweenservice:Create(ddframe, TweenInfo.new(0.12), { Size = UDim2.new(1,-16,0,0) }):Play()
                        task.wait(0.12); ddframe.Visible = false
                        container.Size = UDim2.new(1, 0, 0, 38)
                        -- refresh active color on all opts
                        for _, c2 in ipairs(ddframe:GetChildren()) do
                            if c2:IsA("TextButton") then
                                c2.TextColor3 = c2.Text == currentval and accentcolor or GREY2
                            end
                        end
                        if cb then cb(v) end
                    end)
                end
            end

            setvalues(values)

            dbtn.MouseButton1Click:Connect(function()
                isopen = not isopen
                if isopen then
                    local cnt = #values
                    local totalH = cnt * 26
                    ddframe.Visible = true
                    ddframe.Size = UDim2.new(1,-16,0,0)
                    tweenservice:Create(ddframe, TweenInfo.new(0.12), { Size = UDim2.new(1,-16,0,totalH) }):Play()
                    container.Size = UDim2.new(1, 0, 0, 38 + totalH + 4)
                    dbtn.Text = currentval .. "  ▴"
                else
                    tweenservice:Create(ddframe, TweenInfo.new(0.12), { Size = UDim2.new(1,-16,0,0) }):Play()
                    task.wait(0.12); ddframe.Visible = false
                    container.Size = UDim2.new(1, 0, 0, 38)
                    dbtn.Text = currentval .. "  ▾"
                end
            end)

            return { setvalues = setvalues }
        end

        function tab:addcolorpicker(cfg)
            cfg = cfg or {}
            local txt     = cfg.title    or "color"
            local default = cfg.default  or Color3.new(1, 1, 1)
            local cb      = cfg.callback

            -- current HSV state
            local h, s, v = Color3.toHSV(default)

            local row = Instance.new("Frame")
            row.Size = UDim2.new(1, 0, 0, 30)
            row.BackgroundColor3 = DARK3
            row.BorderSizePixel = 0
            row.Parent = page

            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(1, -48, 1, 0)
            lbl.Position = UDim2.new(0, 10, 0, 0)
            lbl.BackgroundTransparency = 1; lbl.Text = txt
            lbl.TextColor3 = GREY2; lbl.TextSize = 12; lbl.Font = Enum.Font.Gotham
            lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.Parent = row

            -- swatch button (shows current colour, click to open picker)
            local swatch = Instance.new("TextButton")
            swatch.Size = UDim2.new(0, 22, 0, 22)
            swatch.Position = UDim2.new(1, -34, 0.5, -11)
            swatch.BackgroundColor3 = default
            swatch.Text = ""; swatch.BorderSizePixel = 0; swatch.Parent = row
            makecorner(UDim.new(0, 4), swatch)
            makestroke(GREY7, 1, swatch)

            -- ── popup ─────────────────────────────────────────────────────────
            local popup = Instance.new("Frame")
            popup.Size = UDim2.new(0, 220, 0, 230)
            popup.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
            popup.BorderSizePixel = 0; popup.ZIndex = 200; popup.Visible = false
            popup.Parent = screengui
            makecorner(UDim.new(0, 6), popup)
            local pstroke = makestroke(accentcolor, 1, popup)
            regaccent(pstroke, "Color")

            -- title bar of popup
            local ptitle = Instance.new("TextLabel")
            ptitle.Size = UDim2.new(1, -8, 0, 22)
            ptitle.Position = UDim2.new(0, 8, 0, 4)
            ptitle.BackgroundTransparency = 1; ptitle.Text = txt
            ptitle.TextColor3 = GREY2; ptitle.TextSize = 11; ptitle.Font = Enum.Font.GothamBold
            ptitle.TextXAlignment = Enum.TextXAlignment.Left; ptitle.ZIndex = 201; ptitle.Parent = popup

            local pclosebtn = Instance.new("TextButton")
            pclosebtn.Size = UDim2.new(0, 18, 0, 18)
            pclosebtn.Position = UDim2.new(1, -22, 0, 4)
            pclosebtn.BackgroundColor3 = Color3.fromRGB(60,10,10)
            pclosebtn.Text = "x"; pclosebtn.TextColor3 = WHITE
            pclosebtn.TextSize = 10; pclosebtn.Font = Enum.Font.GothamBold
            pclosebtn.BorderSizePixel = 0; pclosebtn.ZIndex = 202; pclosebtn.Parent = popup
            makecorner(UDim.new(0,3), pclosebtn)
            pclosebtn.MouseButton1Click:Connect(function() popup.Visible = false end)

            -- hue-saturation 2D canvas (180×130)
            local canvas = Instance.new("ImageLabel")
            canvas.Size = UDim2.new(0, 180, 0, 130)
            canvas.Position = UDim2.new(0, 10, 0, 30)
            canvas.BackgroundColor3 = Color3.new(1,0,0)
            -- white→transparent gradient left→right, then black gradient top→bottom overlay
            canvas.Image = "rbxassetid://4155801252"  -- hue-saturation square
            canvas.ZIndex = 201; canvas.Parent = popup
            makecorner(UDim.new(0,3), canvas)

            -- hue rainbow bar (180×12)
            local huebar = Instance.new("ImageLabel")
            huebar.Size = UDim2.new(0, 180, 0, 12)
            huebar.Position = UDim2.new(0, 10, 0, 166)
            huebar.Image = "rbxassetid://698052001"  -- rainbow gradient
            huebar.ZIndex = 201; huebar.Parent = popup
            makecorner(UDim.new(0,2), huebar)

            -- brightness bar (180×12)
            local brightbar = Instance.new("Frame")
            brightbar.Size = UDim2.new(0, 180, 0, 12)
            brightbar.Position = UDim2.new(0, 10, 0, 182)
            brightbar.BackgroundColor3 = Color3.new(1,1,1)
            brightbar.ZIndex = 201; brightbar.Parent = popup
            makecorner(UDim.new(0,2), brightbar)
            -- gradient overlay black→transparent
            local brightgrad = Instance.new("UIGradient")
            brightgrad.Color = ColorSequence.new{
                ColorSequenceKeypoint.new(0, Color3.new(1,1,1)),
                ColorSequenceKeypoint.new(1, Color3.new(0,0,0))
            }
            brightgrad.Rotation = 0; brightgrad.Parent = brightbar

            -- cursor on SV canvas
            local cursor = Instance.new("Frame")
            cursor.Size = UDim2.new(0, 10, 0, 10)
            cursor.AnchorPoint = Vector2.new(0.5, 0.5)
            cursor.BackgroundColor3 = WHITE
            cursor.BorderSizePixel = 0; cursor.ZIndex = 203; cursor.Parent = canvas
            makecorner(UDim.new(1,0), cursor)
            makestroke(DARK, 1, cursor)

            -- hue cursor
            local huecursor = Instance.new("Frame")
            huecursor.Size = UDim2.new(0, 4, 1, 2)
            huecursor.AnchorPoint = Vector2.new(0.5, 0.5)
            huecursor.Position = UDim2.new(0, 0, 0.5, 0)
            huecursor.BackgroundColor3 = WHITE
            huecursor.BorderSizePixel = 0; huecursor.ZIndex = 203; huecursor.Parent = huebar
            makecorner(UDim.new(0,2), huecursor)
            makestroke(DARK, 1, huecursor)

            -- brightness cursor
            local brightcursor = Instance.new("Frame")
            brightcursor.Size = UDim2.new(0, 4, 1, 2)
            brightcursor.AnchorPoint = Vector2.new(0.5, 0.5)
            brightcursor.Position = UDim2.new(1, 0, 0.5, 0)
            brightcursor.BackgroundColor3 = WHITE
            brightcursor.BorderSizePixel = 0; brightcursor.ZIndex = 203; brightcursor.Parent = brightbar
            makecorner(UDim.new(0,2), brightcursor)
            makestroke(DARK, 1, brightcursor)

            -- hex input row
            local hexrow = Instance.new("Frame")
            hexrow.Size = UDim2.new(0, 180, 0, 22)
            hexrow.Position = UDim2.new(0, 10, 0, 198)
            hexrow.BackgroundTransparency = 1
            hexrow.ZIndex = 201; hexrow.Parent = popup

            local hexprefix = Instance.new("TextLabel")
            hexprefix.Size = UDim2.new(0, 16, 1, 0)
            hexprefix.BackgroundTransparency = 1; hexprefix.Text = "#"
            hexprefix.TextColor3 = GREY1; hexprefix.TextSize = 11; hexprefix.Font = Enum.Font.GothamBold
            hexprefix.ZIndex = 202; hexprefix.Parent = hexrow

            local hexbox = Instance.new("TextBox")
            hexbox.Size = UDim2.new(0, 90, 1, 0)
            hexbox.Position = UDim2.new(0, 16, 0, 0)
            hexbox.BackgroundColor3 = DARK2
            hexbox.Text = "FFFFFF"; hexbox.TextColor3 = GREY2
            hexbox.TextSize = 11; hexbox.Font = Enum.Font.GothamSemibold
            hexbox.BorderSizePixel = 0; hexbox.ZIndex = 202; hexbox.Parent = hexrow
            makestroke(GREY7, 1, hexbox); makecorner(UDim.new(0,3), hexbox)

            -- result preview
            local resultprev = Instance.new("Frame")
            resultprev.Size = UDim2.new(0, 60, 0, 20)
            resultprev.Position = UDim2.new(0, 116, 0, 1)
            resultprev.BackgroundColor3 = default
            resultprev.BorderSizePixel = 0; resultprev.ZIndex = 202; resultprev.Parent = hexrow
            makecorner(UDim.new(0,4), resultprev); makestroke(GREY7, 1, resultprev)

            -- helper: color→hex string
            local function color3tohex(c)
                return string.format("%02X%02X%02X",
                    math.floor(c.R*255+0.5),
                    math.floor(c.G*255+0.5),
                    math.floor(c.B*255+0.5))
            end
            -- helper: hex→Color3
            local function hextoc3(hex)
                hex = hex:gsub("#",""):sub(1,6)
                if #hex < 6 then return nil end
                local r = tonumber(hex:sub(1,2),16)
                local g = tonumber(hex:sub(3,4),16)
                local b = tonumber(hex:sub(5,6),16)
                if not r or not g or not b then return nil end
                return Color3.fromRGB(r,g,b)
            end

            local function applycolor()
                local col = Color3.fromHSV(h, s, v)
                swatch.BackgroundColor3 = col
                resultprev.BackgroundColor3 = col
                canvas.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
                -- update brightness bar gradient from pure hue to black
                brightbar.BackgroundColor3 = Color3.fromHSV(h, s, 1)
                hexbox.Text = color3tohex(col)
                cursor.Position = UDim2.new(s, 0, 1-v, 0)
                huecursor.Position = UDim2.new(h, 0, 0.5, 0)
                brightcursor.Position = UDim2.new(v, 0, 0.5, 0)
                if cb then cb(col) end
            end

            -- position popup near swatch when opened
            local function openPopup()
                local ap = swatch.AbsolutePosition
                local ps = popup.AbsoluteSize
                local vpsize = workspace.CurrentCamera.ViewportSize
                local px = math.clamp(ap.X - 10, 0, vpsize.X - 225)
                local py = math.clamp(ap.Y + 28, 0, vpsize.Y - 235)
                popup.Position = UDim2.new(0, px, 0, py)
                popup.Visible = true
                applycolor()
            end

            swatch.MouseButton1Click:Connect(function()
                if popup.Visible then popup.Visible = false else openPopup() end
            end)

            -- single drag state: "sv", "hue", "bright", or nil
            local dragmode = nil

            canvas.InputBegan:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragmode = "sv"
                    local rel = uis:GetMouseLocation() - canvas.AbsolutePosition
                    s = math.clamp(rel.X / canvas.AbsoluteSize.X, 0, 1)
                    v = 1 - math.clamp(rel.Y / canvas.AbsoluteSize.Y, 0, 1)
                    applycolor()
                end
            end)
            huebar.InputBegan:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragmode = "hue"
                    local rel = uis:GetMouseLocation() - huebar.AbsolutePosition
                    h = math.clamp(rel.X / huebar.AbsoluteSize.X, 0, 1)
                    applycolor()
                end
            end)
            brightbar.InputBegan:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragmode = "bright"
                    local rel = uis:GetMouseLocation() - brightbar.AbsolutePosition
                    v = math.clamp(rel.X / brightbar.AbsoluteSize.X, 0, 1)
                    applycolor()
                end
            end)

            uis.InputChanged:Connect(function(inp)
                if inp.UserInputType ~= Enum.UserInputType.MouseMovement then return end
                if not dragmode or not popup.Visible then return end
                local mpos = uis:GetMouseLocation()
                if dragmode == "sv" then
                    local rel = mpos - canvas.AbsolutePosition
                    s = math.clamp(rel.X / canvas.AbsoluteSize.X, 0, 1)
                    v = 1 - math.clamp(rel.Y / canvas.AbsoluteSize.Y, 0, 1)
                    applycolor()
                elseif dragmode == "hue" then
                    local rel = mpos - huebar.AbsolutePosition
                    h = math.clamp(rel.X / huebar.AbsoluteSize.X, 0, 1)
                    applycolor()
                elseif dragmode == "bright" then
                    local rel = mpos - brightbar.AbsolutePosition
                    v = math.clamp(rel.X / brightbar.AbsoluteSize.X, 0, 1)
                    applycolor()
                end
            end)
            -- clear drag on mouse release, but only when this picker owns the drag
            local function clearDragIfOwned(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 and dragmode ~= nil then
                    dragmode = nil
                end
            end
            popup.InputEnded:Connect(clearDragIfOwned)
            canvas.InputEnded:Connect(clearDragIfOwned)
            huebar.InputEnded:Connect(clearDragIfOwned)
            brightbar.InputEnded:Connect(clearDragIfOwned)
            uis.InputEnded:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragmode = nil
                end
            end)

            -- hex input
            hexbox.FocusLost:Connect(function()
                local c = hextoc3(hexbox.Text)
                if c then
                    h, s, v = Color3.toHSV(c)
                    applycolor()
                end
            end)

            applycolor()
        end

        function tab:addkeybind(cfg)
            cfg = cfg or {}
            local txt        = cfg.title   or "keybind"
            local defaultkey = cfg.default or "none"
            local cb         = cfg.callback

            local currentkey = defaultkey
            local togstate   = false
            local listening  = false

            -- shared toggle bg (left side of row)
            local row = Instance.new("Frame")
            row.Size = UDim2.new(1, 0, 0, 32)
            row.BackgroundColor3 = DARK3
            row.BorderSizePixel = 0
            row.Parent = page

            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(1, -110, 1, 0)
            lbl.Position = UDim2.new(0, 10, 0, 0)
            lbl.BackgroundTransparency = 1
            lbl.Text = txt
            lbl.TextColor3 = GREY2
            lbl.TextSize = 12
            lbl.Font = Enum.Font.Gotham
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.Parent = row

            -- toggle pill (same as addtoggle)
            local togbg = Instance.new("Frame")
            togbg.Size = UDim2.new(0, 36, 0, 18)
            togbg.Position = UDim2.new(1, -108, 0.5, -9)
            togbg.BackgroundColor3 = GREY5
            togbg.BorderSizePixel = 0
            togbg.Parent = row
            makecorner(UDim.new(1,0), togbg)

            local circle = Instance.new("Frame")
            circle.Size = UDim2.new(0, 12, 0, 12)
            circle.Position = UDim2.new(0, 3, 0.5, -6)
            circle.BackgroundColor3 = GREY1
            circle.BorderSizePixel = 0
            circle.Parent = togbg
            makecorner(UDim.new(1,0), circle)

            -- keybind button (right side)
            local kbtn = Instance.new("TextButton")
            kbtn.Size = UDim2.new(0, 58, 0, 20)
            kbtn.Position = UDim2.new(1, -62, 0.5, -10)
            kbtn.BackgroundColor3 = GREY6
            kbtn.Text = currentkey == "none" and "[ -- ]" or ("[" .. string.lower(currentkey) .. "]")
            kbtn.TextColor3 = GREY1
            kbtn.TextSize = 10
            kbtn.Font = Enum.Font.GothamSemibold
            kbtn.BorderSizePixel = 0
            kbtn.Parent = row
            makestroke(GREY7, 1, kbtn)

            -- context menu (right click on keybind button)
            local ctxmenu = Instance.new("Frame")
            ctxmenu.Size = UDim2.new(0, 130, 0, 0)
            ctxmenu.BackgroundColor3 = DARK4
            ctxmenu.BorderSizePixel = 0
            ctxmenu.ZIndex = 50
            ctxmenu.Visible = false
            ctxmenu.ClipsDescendants = true
            ctxmenu.Parent = screengui
            makestroke(accentcolor, 1, ctxmenu)
            regaccent(makestroke(accentcolor, 1, ctxmenu), "Color")
            makecorner(UDim.new(0, 4), ctxmenu)
            local ctxlayout = Instance.new("UIListLayout")
            ctxlayout.SortOrder = Enum.SortOrder.LayoutOrder
            ctxlayout.Parent = ctxmenu

            local ctxjustopened = false

            local function closectx()
                tweenservice:Create(ctxmenu, TweenInfo.new(0.1), {Size = UDim2.new(0,130,0,0)}):Play()
                task.wait(0.1); ctxmenu.Visible = false
            end

            local function makectxitem(label, color, onclick)
                local item = Instance.new("TextButton")
                item.Size = UDim2.new(1, 0, 0, 26)
                item.BackgroundColor3 = DARK4
                item.Text = label
                item.TextColor3 = color or GREY2
                item.TextSize = 11
                item.Font = Enum.Font.GothamSemibold
                item.BorderSizePixel = 0
                item.AutoButtonColor = false
                item.ZIndex = 51
                item.Parent = ctxmenu
                item.MouseEnter:Connect(function() item.BackgroundColor3 = GREY6 end)
                item.MouseLeave:Connect(function() item.BackgroundColor3 = DARK4 end)
                item.MouseButton1Click:Connect(function() closectx(); onclick() end)
            end

            makectxitem("set keybind", GREY3, function()
                listening = true
                kbtn.Text = "[ ... ]"; kbtn.TextColor3 = accentcolor
            end)
            makectxitem("delete keybind", Color3.fromRGB(200, 50, 50), function()
                currentkey = "none"
                kbtn.Text = "[ -- ]"; kbtn.TextColor3 = GREY1
            end)

            -- right click opens context menu
            kbtn.MouseButton2Click:Connect(function()
                local ap = kbtn.AbsolutePosition
                ctxmenu.Position = UDim2.new(0, ap.X, 0, ap.Y + 24)
                ctxmenu.Visible = true
                ctxmenu.Size = UDim2.new(0, 130, 0, 0)
                ctxjustopened = true
                tweenservice:Create(ctxmenu, TweenInfo.new(0.1), {Size = UDim2.new(0,130,0,52)}):Play()
            end)

            -- close ctx when clicking elsewhere (not on the menu itself)
            uis.InputBegan:Connect(function(inp)
                if ctxmenu.Visible and inp.UserInputType == Enum.UserInputType.MouseButton1 then
                    if ctxjustopened then ctxjustopened = false; return end
                    closectx()
                end
            end)

            local function settogtoggle(v)
                togstate = v
                tweenservice:Create(circle, TweenInfo.new(0.12), {
                    Position = v and UDim2.new(1,-15,0.5,-6) or UDim2.new(0,3,0.5,-6)
                }):Play()
                tweenservice:Create(togbg, TweenInfo.new(0.12), {
                    BackgroundColor3 = v and accentcolor or GREY5
                }):Play()
                tweenservice:Create(circle, TweenInfo.new(0.12), {
                    BackgroundColor3 = v and WHITE or GREY1
                }):Play()
                if cb then cb(v) end
            end

            -- left click on row = toggle on/off
            local clickbtn = Instance.new("TextButton")
            clickbtn.Size = UDim2.new(1, -130, 1, 0)
            clickbtn.BackgroundTransparency = 1
            clickbtn.Text = ""
            clickbtn.Parent = row
            clickbtn.MouseButton1Click:Connect(function()
                settogtoggle(not togstate)
            end)

            -- key press toggles state if keybind is set
            uis.InputBegan:Connect(function(inp, gpe)
                if listening and inp.UserInputType == Enum.UserInputType.Keyboard then
                    listening = false
                    currentkey = inp.KeyCode.Name
                    kbtn.Text = "[" .. string.lower(currentkey) .. "]"
                    kbtn.TextColor3 = GREY1
                elseif not listening and inp.UserInputType == Enum.UserInputType.Keyboard
                    and currentkey ~= "none" and inp.KeyCode.Name == currentkey and not gpe then
                    settogtoggle(not togstate)
                end
            end)

            table.insert(keybindregistry, {
                title    = txt,
                getkey   = function() return currentkey end,
                getstate = function() return togstate end,
            })

            return settogtoggle
        end

        function tab:addthemepicker()
            self:addsection("theme color")
            -- reuse addcolorpicker but wire it to updatetheme
            self:addcolorpicker({
                title    = "accent color",
                default  = accentcolor,
                callback = function(col)
                    updatetheme(col)
                    yesbtn.BackgroundColor3 = col
                end,
            })
        end

        function tab:addkeybindlist()
            self:addsection("keybinds")

            local listcontainer = Instance.new("Frame")
            listcontainer.Size = UDim2.new(1, 0, 0, 28)
            listcontainer.BackgroundColor3 = DARK3
            listcontainer.BorderSizePixel = 0
            listcontainer.ClipsDescendants = true
            listcontainer.Parent = page

            local listlayout = Instance.new("UIListLayout")
            listlayout.SortOrder = Enum.SortOrder.LayoutOrder
            listlayout.Padding = UDim.new(0, 2)
            listlayout.Parent = listcontainer
            makepad(4, 8, 8, 4, listcontainer)

            local function rebuildlist()
                for _, c in ipairs(listcontainer:GetChildren()) do
                    if c:IsA("Frame") then c:Destroy() end
                end

                local shown = 0
                for _, entry in ipairs(keybindregistry) do
                    shown += 1
                    local isactive = entry.getstate()

                    local row2 = Instance.new("Frame")
                    row2.Size = UDim2.new(1, 0, 0, 24)
                    row2.BackgroundTransparency = 1
                    row2.BorderSizePixel = 0
                    row2.Parent = listcontainer

                    -- active dot
                    local dot = Instance.new("Frame")
                    dot.Size = UDim2.new(0, 6, 0, 6)
                    dot.Position = UDim2.new(0, 0, 0.5, -3)
                    dot.BackgroundColor3 = isactive and accentcolor or GREY5
                    dot.BorderSizePixel = 0
                    dot.Parent = row2
                    makecorner(UDim.new(1,0), dot)

                    local keylbl = Instance.new("TextLabel")
                    keylbl.Size = UDim2.new(0, 72, 1, 0)
                    keylbl.Position = UDim2.new(0, 12, 0, 0)
                    keylbl.BackgroundTransparency = 1
                    keylbl.Text = "[" .. string.lower(entry.getkey()) .. "]"
                    keylbl.TextColor3 = isactive and accentcolor or GREY2
                    keylbl.TextSize = 10
                    keylbl.Font = Enum.Font.GothamSemibold
                    keylbl.BorderSizePixel = 0
                    keylbl.Parent = row2

                    local titlelbl2 = Instance.new("TextLabel")
                    titlelbl2.Size = UDim2.new(1, -88, 1, 0)
                    titlelbl2.Position = UDim2.new(0, 88, 0, 0)
                    titlelbl2.BackgroundTransparency = 1
                    titlelbl2.Text = entry.title
                    titlelbl2.TextColor3 = isactive and GREY3 or GREY1
                    titlelbl2.TextSize = 10
                    titlelbl2.Font = Enum.Font.Gotham
                    titlelbl2.TextXAlignment = Enum.TextXAlignment.Left
                    titlelbl2.TextTruncate = Enum.TextTruncate.AtEnd
                    titlelbl2.Parent = row2
                end

                listlayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                    listcontainer.Size = UDim2.new(1, 0, 0, listlayout.AbsoluteContentSize.Y + 8)
                end)

                if shown == 0 then
                    listcontainer.Size = UDim2.new(1, 0, 0, 28)
                    local nonelbl = Instance.new("TextLabel")
                    nonelbl.Size = UDim2.new(1, -16, 1, 0)
                    nonelbl.Position = UDim2.new(0, 8, 0, 0)
                    nonelbl.BackgroundTransparency = 1
                    nonelbl.Text = "no keybinds registered"
                    nonelbl.TextColor3 = GREY7
                    nonelbl.TextSize = 10
                    nonelbl.Font = Enum.Font.Gotham
                    nonelbl.TextXAlignment = Enum.TextXAlignment.Left
                    nonelbl.Parent = listcontainer
                else
                    listcontainer.Size = UDim2.new(1, 0, 0, shown * 26 + 8)
                end
            end

            rebuildlist()

            -- auto refresh every 0.5s so active states stay current
            task.spawn(function()
                while screengui.Parent do task.wait(0.5); rebuildlist() end
            end)
        end

        function tab:addblurslider()
            -- toggle row
            local togglerow = Instance.new("Frame")
            togglerow.Size = UDim2.new(1, 0, 0, 30)
            togglerow.BackgroundColor3 = DARK3
            togglerow.BorderSizePixel = 0; togglerow.Parent = page

            local togtitle = Instance.new("TextLabel")
            togtitle.Size = UDim2.new(1, -50, 1, 0)
            togtitle.Position = UDim2.new(0, 10, 0, 0)
            togtitle.BackgroundTransparency = 1; togtitle.Text = "background blur"
            togtitle.TextColor3 = GREY3; togtitle.TextSize = 12; togtitle.Font = Enum.Font.Gotham
            togtitle.TextXAlignment = Enum.TextXAlignment.Left; togtitle.Parent = togglerow

            local togbg2 = Instance.new("Frame")
            togbg2.Size = UDim2.new(0, 36, 0, 18)
            togbg2.Position = UDim2.new(1, -44, 0.5, -9)
            togbg2.BackgroundColor3 = GREY5; togbg2.BorderSizePixel = 0; togbg2.Parent = togglerow
            makecorner(UDim.new(1,0), togbg2)
            local circle2 = Instance.new("Frame")
            circle2.Size = UDim2.new(0, 12, 0, 12)
            circle2.Position = UDim2.new(0, 3, 0.5, -6)
            circle2.BackgroundColor3 = GREY1; circle2.BorderSizePixel = 0; circle2.Parent = togbg2
            makecorner(UDim.new(1,0), circle2)

            local function setblurtog(val)
                blurenabled = val
                tweenservice:Create(circle2, TweenInfo.new(0.12), {
                    Position = val and UDim2.new(1,-15,0.5,-6) or UDim2.new(0,3,0.5,-6)
                }):Play()
                tweenservice:Create(togbg2, TweenInfo.new(0.12), {
                    BackgroundColor3 = val and accentcolor or GREY5
                }):Play()
                tweenservice:Create(circle2, TweenInfo.new(0.12), {
                    BackgroundColor3 = val and WHITE or GREY1
                }):Play()
                if val and mainframe.Visible then
                    blureffect.Size = 0; blureffect.Enabled = true
                    tweenservice:Create(blureffect, TweenInfo.new(0.25), { Size = blurintensity }):Play()
                else
                    tweenservice:Create(blureffect, TweenInfo.new(0.25), { Size = 0 }):Play()
                    task.delay(0.25, function() blureffect.Enabled = false end)
                end
            end

            local clickbtn2 = Instance.new("TextButton")
            clickbtn2.Size = UDim2.new(1,0,1,0); clickbtn2.BackgroundTransparency = 1
            clickbtn2.Text = ""; clickbtn2.Parent = togglerow
            clickbtn2.MouseButton1Click:Connect(function() setblurtog(not blurenabled) end)

            -- intensity slider
            local lbl2 = Instance.new("TextLabel")
            lbl2.Size = UDim2.new(1, 0, 0, 18)
            lbl2.BackgroundTransparency = 1; lbl2.Text = "blur intensity: 20"
            lbl2.TextColor3 = GREY1; lbl2.TextSize = 11; lbl2.Font = Enum.Font.Gotham
            lbl2.TextXAlignment = Enum.TextXAlignment.Left; lbl2.BorderSizePixel = 0; lbl2.Parent = page
            makepad(0, 4, 0, 0, lbl2)

            local track2 = Instance.new("Frame")
            track2.Size = UDim2.new(1, -8, 0, 5)
            track2.BackgroundColor3 = GREY4; track2.BorderSizePixel = 0; track2.Parent = page

            local fill2 = Instance.new("Frame")
            fill2.Size = UDim2.new(0.4, 0, 1, 0)  -- default 20/50
            fill2.BackgroundColor3 = accentcolor; fill2.BorderSizePixel = 0; fill2.Parent = track2
            regaccent(fill2, "BackgroundColor3")

            local knob2 = Instance.new("Frame")
            knob2.Size = UDim2.new(0, 11, 0, 11)
            knob2.Position = UDim2.new(1, -5, 0.5, -5)
            knob2.BackgroundColor3 = Color3.fromRGB(230,230,230); knob2.BorderSizePixel = 0; knob2.Parent = fill2
            makecorner(UDim.new(1,0), knob2)

            local bluractive = false
            local function updateblur(ix)
                local rel = math.clamp((ix - track2.AbsolutePosition.X) / track2.AbsoluteSize.X, 0, 1)
                fill2.Size = UDim2.new(rel, 0, 1, 0)
                blurintensity = math.floor(rel * 56 + 0.5)  -- 0–56 is Roblox BlurEffect range
                lbl2.Text = "blur intensity: " .. blurintensity
                if blurenabled and mainframe.Visible then
                    blureffect.Size = blurintensity
                end
            end

            track2.InputBegan:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 then bluractive = true; updateblur(inp.Position.X) end
            end)
            knob2.InputBegan:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 then bluractive = true end
            end)
            uis.InputEnded:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 then bluractive = false end
            end)
            uis.InputChanged:Connect(function(inp)
                if bluractive and inp.UserInputType == Enum.UserInputType.MouseMovement then updateblur(inp.Position.X) end
            end)
        end

        function tab:addtransparencyslider()
            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(1, 0, 0, 18)
            lbl.BackgroundTransparency = 1
            lbl.Text = "transparency: 0%"
            lbl.TextColor3 = GREY1
            lbl.TextSize = 11
            lbl.Font = Enum.Font.Gotham
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.BorderSizePixel = 0
            lbl.Parent = page
            makepad(0, 4, 0, 0, lbl)

            local track = Instance.new("Frame")
            track.Size = UDim2.new(1, -8, 0, 5)
            track.BackgroundColor3 = GREY4
            track.BorderSizePixel = 0
            track.Parent = page

            local fill = Instance.new("Frame")
            fill.Size = UDim2.new(0, 0, 1, 0)
            fill.BackgroundColor3 = accentcolor
            fill.BorderSizePixel = 0
            fill.Parent = track
            regaccent(fill, "BackgroundColor3")

            local knob = Instance.new("Frame")
            knob.Size = UDim2.new(0, 11, 0, 11)
            knob.Position = UDim2.new(1, -5, 0.5, -5)
            knob.BackgroundColor3 = Color3.fromRGB(230,230,230)
            knob.BorderSizePixel = 0
            knob.Parent = fill
            makecorner(UDim.new(1,0), knob)

            local transactive = false
            local function updatetrans(ix)
                local rel = math.clamp((ix - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
                fill.Size = UDim2.new(rel, 0, 1, 0)
                lbl.Text = "transparency: " .. math.floor(rel * 100) .. "%"
                mainframe.BackgroundTransparency = rel * 0.88
            end

            track.InputBegan:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 then transactive = true; updatetrans(inp.Position.X) end
            end)
            knob.InputBegan:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 then transactive = true end
            end)
            uis.InputEnded:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 then transactive = false end
            end)
            uis.InputChanged:Connect(function(inp)
                if transactive and inp.UserInputType == Enum.UserInputType.MouseMovement then updatetrans(inp.Position.X) end
            end)
        end

        function tab:addkeybindsetting(cfg)
            cfg = cfg or {}
            local txt = cfg.title or "toggle ui"

            local row = Instance.new("Frame")
            row.Size = UDim2.new(1, 0, 0, 30)
            row.BackgroundColor3 = DARK3
            row.BorderSizePixel = 0
            row.Parent = page

            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(1, -100, 1, 0)
            lbl.Position = UDim2.new(0, 10, 0, 0)
            lbl.BackgroundTransparency = 1
            lbl.Text = txt
            lbl.TextColor3 = GREY2
            lbl.TextSize = 12
            lbl.Font = Enum.Font.Gotham
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.Parent = row

            local kbtn = Instance.new("TextButton")
            kbtn.Size = UDim2.new(0, 88, 0, 22)
            kbtn.Position = UDim2.new(1, -94, 0.5, -11)
            kbtn.BackgroundColor3 = GREY6
            kbtn.Text = "[ " .. string.lower(currenttogglekey.Name) .. " ]"
            kbtn.TextColor3 = GREY2
            kbtn.TextSize = 11
            kbtn.Font = Enum.Font.GothamSemibold
            kbtn.BorderSizePixel = 0
            kbtn.Parent = row
            makestroke(GREY7, 1, kbtn)

            kbtn.MouseButton1Click:Connect(function()
                listeningforkey = true; kbtn.Text = "[ ... ]"; kbtn.TextColor3 = accentcolor
            end)
            uis.InputBegan:Connect(function(inp)
                if listeningforkey and inp.UserInputType == Enum.UserInputType.Keyboard then
                    listeningforkey = false
                    currenttogglekey = inp.KeyCode
                    kbtn.Text = "[ " .. string.lower(inp.KeyCode.Name) .. " ]"
                    kbtn.TextColor3 = GREY2
                end
            end)
        end

        return tab
    end

    function window:notify(msg)
        sendnotif(msg)
    end

    function window:selecttab(name)
        selecttab(name)
    end

    return window
end

return multihubx
