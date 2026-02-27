local astrixhub = {}
astrixhub.__index = astrixhub

local tweenservice = game:GetService("TweenService")
local uis          = game:GetService("UserInputService")
local players      = game:GetService("Players")
local lp           = players.LocalPlayer

local function makecorner(radius, parent)
    local c = Instance.new("UICorner")
    c.CornerRadius = radius or UDim.new(0, 8)
    c.Parent = parent
    return c
end

local function makestroke(color, thickness, parent)
    local s = Instance.new("UIStroke")
    s.Color     = color     or Color3.fromRGB(130, 40, 200)
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

function astrixhub:createwindow(config)
    config = config or {}
    local title     = config.title     or "astrix hub"
    local subtitle  = config.subtitle  or ""
    local size      = config.size      or UDim2.new(0, 600, 0, 410)
    local togglekey = config.togglekey or Enum.KeyCode.RightShift

    local playergui = lp:WaitForChild("PlayerGui")
    local screengui = Instance.new("ScreenGui")
    screengui.Name           = "astrixhub_" .. title:lower():gsub("%s","")
    screengui.ResetOnSpawn   = false
    screengui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screengui.Parent         = playergui

    local lighting = game:GetService("Lighting")
    local blureffect = Instance.new("BlurEffect")
    blureffect.Size    = 0
    blureffect.Enabled = false
    blureffect.Parent  = lighting
    local blurenabled  = false
    local blurintensity = 20

    local accentcolor    = Color3.fromRGB(130, 40, 200)
    local accentobjs     = {}
    local keybindregistry = {}
    local notifstack     = {}

    -- ── keybind float panel (outside main gui, toggled from settings) ─────────────
    local kbfloat = Instance.new("Frame")
    kbfloat.Name = "keybindpanel"
    kbfloat.Size = UDim2.new(0, 200, 0, 28)
    kbfloat.Position = UDim2.fromOffset(
        game:GetService("Workspace").CurrentCamera.ViewportSize.X - 215,
        math.floor(game:GetService("Workspace").CurrentCamera.ViewportSize.Y / 2) - 80
    )
    kbfloat.BackgroundColor3 = DARK
    kbfloat.BorderSizePixel = 0
    kbfloat.ZIndex = 30
    kbfloat.Visible = false
    kbfloat.Parent = screengui
    makecorner(UDim.new(0, 8), kbfloat)

    local kbfloatstroke = Instance.new("UIStroke")
    kbfloatstroke.Color = accentcolor; kbfloatstroke.Thickness = 1; kbfloatstroke.Parent = kbfloat

    local kbfloatherbar = Instance.new("Frame")
    kbfloatherbar.Size = UDim2.new(1, 0, 0, 22)
    kbfloatherbar.BackgroundColor3 = DARK5
    kbfloatherbar.BorderSizePixel = 0; kbfloatherbar.ZIndex = 31; kbfloatherbar.Parent = kbfloat
    makecorner(UDim.new(0, 8), kbfloatherbar)

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

    -- draggable header
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

            local isactive = entry.getstate and entry.getstate() or false

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

    -- ── notifications ────────────────────────────────────────────────────────────
    local notifstackframe = Instance.new("Frame")
    notifstackframe.Size = UDim2.new(0, 240, 1, 0)
    notifstackframe.Position = UDim2.new(1, -250, 0, 0)
    notifstackframe.BackgroundTransparency = 1
    notifstackframe.BorderSizePixel = 0
    notifstackframe.ZIndex = 50
    notifstackframe.Parent = screengui

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
        makecorner(UDim.new(0, 8), nf)
        local ns = makestroke(accentcolor, 1, nf)

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

    -- ── confirm popup ────────────────────────────────────────────────────────────
    local confirmpopup = Instance.new("Frame")
    confirmpopup.Size = UDim2.new(0, 310, 0, 165)
    confirmpopup.Position = UDim2.new(0.5, -155, 0.5, -82)
    confirmpopup.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
    confirmpopup.BorderSizePixel = 0
    confirmpopup.ZIndex = 100
    confirmpopup.Visible = false
    confirmpopup.Parent = screengui
    makecorner(UDim.new(0, 10), confirmpopup)
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
    yesbtn.BackgroundColor3 = Color3.fromRGB(90, 20, 160)
    yesbtn.Text = "yes"
    yesbtn.TextColor3 = WHITE
    yesbtn.TextSize = 12
    yesbtn.Font = Enum.Font.GothamBold
    yesbtn.BorderSizePixel = 0
    yesbtn.ZIndex = 102
    yesbtn.Parent = confirmpopup
    makecorner(UDim.new(0, 6), yesbtn)

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
    makecorner(UDim.new(0, 6), nobtn)
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

    -- ── main frame ───────────────────────────────────────────────────────────────
    -- Outer: rounded + stroke, NO ClipsDescendants so corners aren't cut
    local mainframe = Instance.new("Frame")
    mainframe.Name = "mainframe"
    mainframe.Size = size
    mainframe.Position = UDim2.new(0.5, -size.X.Offset/2, 0.5, -size.Y.Offset/2)
    mainframe.BackgroundColor3 = DARK
    mainframe.BackgroundTransparency = 0
    mainframe.BorderSizePixel = 0
    mainframe.ClipsDescendants = false
    mainframe.Parent = screengui
    makecorner(UDim.new(0, 12), mainframe)
    local mainstroke = makestroke(accentcolor, 2, mainframe)
    regaccent(mainstroke, "Color")
    -- Inner clip frame so content is still clipped without ruining corners
    local mainclip = Instance.new("Frame")
    mainclip.Size = UDim2.new(1, 0, 1, 0)
    mainclip.BackgroundTransparency = 1
    mainclip.BorderSizePixel = 0
    mainclip.ClipsDescendants = true
    mainclip.Parent = mainframe
    makecorner(UDim.new(0, 12), mainclip)

    local titlebarH = subtitle ~= "" and 46 or 34

    local titlebar = Instance.new("Frame")
    titlebar.Size = UDim2.new(1, 0, 0, titlebarH)
    titlebar.BackgroundColor3 = DARK5
    titlebar.BorderSizePixel = 0
    titlebar.ZIndex = 2
    titlebar.Parent = mainclip

    local titlelbl = Instance.new("TextLabel")
    titlelbl.Size = UDim2.new(1, -70, 0, subtitle ~= "" and 22 or 34)
    titlelbl.Position = UDim2.new(0, 12, 0, subtitle ~= "" and 4 or 0)
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
        sublbl.Position = UDim2.new(0, 12, 0, 27)
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
        b.Size = UDim2.new(0, 26, 0, 22)
        b.Position = UDim2.new(1, xoff, 0, (titlebarH - 22) / 2)
        b.BackgroundColor3 = bg
        b.Text = txt
        b.TextColor3 = WHITE
        b.TextSize = 11
        b.Font = Enum.Font.GothamBold
        b.BorderSizePixel = 0
        b.ZIndex = 3
        b.Parent = titlebar
        makecorner(UDim.new(0, 5), b)
        return b
    end

    local closebtn = maketitlebtn("×", -30, Color3.fromRGB(100, 20, 170))
    local minbtn   = maketitlebtn("−", -60, GREY7)

    local sep = Instance.new("Frame")
    sep.Size = UDim2.new(1, 0, 0, 1)
    sep.Position = UDim2.new(0, 0, 0, titlebarH)
    sep.BackgroundColor3 = accentcolor
    sep.BorderSizePixel = 0
    sep.ZIndex = 2
    sep.Parent = mainclip
    regaccent(sep, "BackgroundColor3")

    -- ── tab panel (left sidebar) ─────────────────────────────────────────────────
    local tabpanel = Instance.new("Frame")
    tabpanel.Size = UDim2.new(0, 120, 1, -(titlebarH+1))
    tabpanel.Position = UDim2.new(0, 0, 0, titlebarH+1)
    tabpanel.BackgroundColor3 = DARK2
    tabpanel.BorderSizePixel = 0
    tabpanel.ClipsDescendants = true
    tabpanel.Parent = mainclip

    local tabdiv = Instance.new("Frame")
    tabdiv.Size = UDim2.new(0, 1, 1, -(titlebarH+1))
    tabdiv.Position = UDim2.new(0, 120, 0, titlebarH+1)
    tabdiv.BackgroundColor3 = accentcolor
    tabdiv.BorderSizePixel = 0
    tabdiv.Parent = mainclip
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
    contentarea.Parent = mainclip

    -- ── mini widget / restore ────────────────────────────────────────────────────
    -- miniwidget kept as invisible dummy so existing logic still references it
    local miniwidget = Instance.new("Frame")
    miniwidget.Name = "miniwidget"
    miniwidget.Size = UDim2.new(0, 0, 0, 0)
    miniwidget.BackgroundTransparency = 1
    miniwidget.BorderSizePixel = 0
    miniwidget.Visible = false
    miniwidget.ZIndex = 20
    miniwidget.Parent = screengui

    local restorestrip = Instance.new("Frame")
    restorestrip.Size = UDim2.new(0, 120, 0, 28)
    restorestrip.Position = UDim2.new(0.5, -60, 1, -36)
    restorestrip.BackgroundColor3 = DARK2
    restorestrip.BorderSizePixel = 0
    restorestrip.Visible = false
    restorestrip.ZIndex = 20
    restorestrip.Parent = screengui
    makecorner(UDim.new(0, 8), restorestrip)
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
        restorestrip.Visible = true
        if blurenabled then
            tweenservice:Create(blureffect, TweenInfo.new(0.25), { Size = 0 }):Play()
            task.delay(0.25, function() blureffect.Enabled = false end)
        end
    end

    local function showgui()
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

    closebtn.MouseButton1Click:Connect(function() screengui:Destroy() end)
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
                task.delay(0, function() rshasmoved = false end)
            end
            if minidragging then
                task.delay(0, function() minihasmoved = false end)
            end
        end
    end)

    uis.InputBegan:Connect(function(inp, gpe)
        if listeningforkey and not gpe and inp.UserInputType == Enum.UserInputType.Keyboard then
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

    -- ── tab / page registry ───────────────────────────────────────────────────────
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
            info.btn.BackgroundColor3 = active and Color3.fromRGB(25,25,25) or DARK2
            info.indicator.Visible = active
            if active then info.indicator.BackgroundColor3 = accentcolor end
        end
        for pname, page in pairs(pagelist) do
            page.Visible = pname == name
        end
    end

    local window = {}

    -- ── addtab ────────────────────────────────────────────────────────────────────
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
        makecorner(UDim.new(0, 2), indicator)
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
        layout.Padding = UDim.new(0, 6)
        layout.Parent = scroll

        makepad(10, 10, 10, 10, scroll)

        layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
        end)

        btn.MouseButton1Click:Connect(function() selecttab(name) end)

        if activetab == nil then selecttab(name) end

        local tab = {}
        local page = scroll

        -- ── GROUPBOX ──────────────────────────────────────────────────────────────
        -- Creates a collapsible groupbox. All elements added inside it are hidden
        -- or shown when the user clicks the header.
        --
        -- Usage:
        --   local mybox = tab:addgroupbox("esp settings")
        --   mybox:addtoggle({ title = "show names", callback = ... })
        --   mybox:addslider(...)
        --
        function tab:addgroupbox(title, collapsed)
            local isopen = (collapsed == false)  -- default CLOSED unless explicitly collapsed=false

            -- outer wrapper (auto-sizes based on content)
            local wrapper = Instance.new("Frame")
            wrapper.Size = UDim2.new(1, 0, 0, 30)   -- will be updated
            wrapper.BackgroundColor3 = DARK3
            wrapper.BorderSizePixel = 0
            wrapper.ClipsDescendants = false
            wrapper.Parent = page
            makecorner(UDim.new(0, 8), wrapper)
            makestroke(GREY4, 1, wrapper)

            -- header row
            local header = Instance.new("TextButton")
            header.Size = UDim2.new(1, 0, 0, 28)
            header.BackgroundColor3 = DARK4
            header.Text = ""
            header.BorderSizePixel = 0
            header.AutoButtonColor = false
            header.ZIndex = 2
            header.Parent = wrapper
            makecorner(UDim.new(0, 8), header)

            -- accent left bar on header
            local headerbar = Instance.new("Frame")
            headerbar.Size = UDim2.new(0, 3, 0.6, 0)
            headerbar.Position = UDim2.new(0, 0, 0.2, 0)
            headerbar.BackgroundColor3 = accentcolor
            headerbar.BorderSizePixel = 0
            headerbar.ZIndex = 3
            headerbar.Parent = header
            makecorner(UDim.new(0, 2), headerbar)
            regaccent(headerbar, "BackgroundColor3")

            local titlelabel = Instance.new("TextLabel")
            titlelabel.Size = UDim2.new(1, -50, 1, 0)
            titlelabel.Position = UDim2.new(0, 10, 0, 0)
            titlelabel.BackgroundTransparency = 1
            titlelabel.Text = title
            titlelabel.TextColor3 = GREY3
            titlelabel.TextSize = 12
            titlelabel.Font = Enum.Font.GothamSemibold
            titlelabel.TextXAlignment = Enum.TextXAlignment.Left
            titlelabel.ZIndex = 3
            titlelabel.Parent = header

            -- arrow indicator
            local arrowlbl = Instance.new("TextLabel")
            arrowlbl.Size = UDim2.new(0, 20, 1, 0)
            arrowlbl.Position = UDim2.new(1, -26, 0, 0)
            arrowlbl.BackgroundTransparency = 1
            arrowlbl.Text = isopen and "-" or "+"
            arrowlbl.TextColor3 = accentcolor
            arrowlbl.TextSize = 14
            arrowlbl.Font = Enum.Font.GothamBold
            arrowlbl.ZIndex = 3
            arrowlbl.Parent = header
            regaccent(arrowlbl, "TextColor3")

            -- content frame (inner scroll area)
            local contentframe = Instance.new("Frame")
            contentframe.Size = UDim2.new(1, 0, 0, 0)   -- updated by layout
            contentframe.Position = UDim2.new(0, 0, 0, 30)
            contentframe.BackgroundTransparency = 1
            contentframe.BorderSizePixel = 0
            contentframe.ClipsDescendants = true
            contentframe.Parent = wrapper

            local innerlayout = Instance.new("UIListLayout")
            innerlayout.SortOrder = Enum.SortOrder.LayoutOrder
            innerlayout.Padding = UDim.new(0, 4)
            innerlayout.Parent = contentframe

            makepad(6, 6, 6, 6, contentframe)

            -- helper: recompute sizes after content changes
            local function refreshsize()
                local innerH = isopen and (innerlayout.AbsoluteContentSize.Y + 12) or 0
                contentframe.Size = UDim2.new(1, 0, 0, innerH)
                contentframe.Visible = isopen
                wrapper.Size = UDim2.new(1, 0, 0, 28 + innerH)
            end

            innerlayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(refreshsize)

            header.MouseButton1Click:Connect(function()
                isopen = not isopen
                arrowlbl.Text = isopen and "-" or "+"
                refreshsize()
            end)

            refreshsize()

            -- The groupbox object exposes all the same element methods,
            -- but parents them into contentframe instead of the tab's scroll page.
            local groupbox = {}
            local gbpage = contentframe

            -- helper: wrap element methods using gbpage
            local function gbwrap(fn)
                return function(self, cfg) return fn(self, cfg, gbpage) end
            end

            -- addsection inside groupbox (just a label divider)
            function groupbox:addsection(txt)
                local lbl = Instance.new("TextLabel")
                lbl.Size = UDim2.new(1, 0, 0, 18)
                lbl.BackgroundTransparency = 1
                lbl.Text = txt
                lbl.TextColor3 = accentcolor
                lbl.TextSize = 10
                lbl.Font = Enum.Font.GothamBold
                lbl.TextXAlignment = Enum.TextXAlignment.Left
                lbl.BorderSizePixel = 0
                lbl.Parent = gbpage
                makepad(0, 4, 0, 0, lbl)
                regaccent(lbl, "TextColor3")
            end

            -- all element-adding methods delegated to internal helpers (see below)
            -- we define them via the shared factory further down
            groupbox._page = gbpage
            groupbox._isGroupbox = true

            return groupbox
        end

        -- ── shared element factory ─────────────────────────────────────────────────
        -- Elements can be added to either the tab's page or a groupbox's page.
        local function addElementsTo(target)

            function target:addsection(txt)
                local lbl = Instance.new("TextLabel")
                lbl.Size = UDim2.new(1, 0, 0, 20)
                lbl.BackgroundTransparency = 1
                lbl.Text = txt
                lbl.TextColor3 = accentcolor
                lbl.TextSize = 11
                lbl.Font = Enum.Font.GothamBold
                lbl.TextXAlignment = Enum.TextXAlignment.Left
                lbl.BorderSizePixel = 0
                lbl.Parent = (target._isGroupbox and target._page) or page
                makepad(0, 4, 0, 0, lbl)
                regaccent(lbl, "TextColor3")
            end

            function target:addtoggle(cfg)
                cfg = cfg or {}
                local txt     = cfg.title    or "toggle"
                local default = cfg.default  or false
                local cb      = cfg.callback
                local p = (target._isGroupbox and target._page) or page

                local row = Instance.new("Frame")
                row.Size = UDim2.new(1, 0, 0, 32)
                row.BackgroundColor3 = DARK3
                row.BorderSizePixel = 0
                row.Parent = p
                makecorner(UDim.new(0, 6), row)

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

            function target:addslider(cfg)
                cfg = cfg or {}
                local txt     = cfg.title    or "slider"
                local default = cfg.default  or 50
                local min     = cfg.min      or 0
                local max     = cfg.max      or 100
                local cb      = cfg.callback
                local p = (target._isGroupbox and target._page) or page

                local row = Instance.new("Frame")
                row.Size = UDim2.new(1, 0, 0, 46)
                row.BackgroundColor3 = DARK3
                row.BorderSizePixel = 0
                row.Parent = p
                makecorner(UDim.new(0, 6), row)

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
                makecorner(UDim.new(1, 0), track)

                local initrel = math.clamp((default - min) / (max - min), 0, 1)
                local fill = Instance.new("Frame")
                fill.Size = UDim2.new(initrel, 0, 1, 0)
                fill.BackgroundColor3 = accentcolor
                fill.BorderSizePixel = 0
                fill.Parent = track
                makecorner(UDim.new(1, 0), fill)
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

            function target:addbutton(cfg)
                cfg = cfg or {}
                local txt = cfg.title    or "button"
                local cb  = cfg.callback
                local p = (target._isGroupbox and target._page) or page

                local btn2 = Instance.new("TextButton")
                btn2.Size = UDim2.new(1, 0, 0, 30)
                btn2.BackgroundColor3 = DARK4
                btn2.Text = txt
                btn2.TextColor3 = GREY3
                btn2.TextSize = 12
                btn2.Font = Enum.Font.GothamSemibold
                btn2.BorderSizePixel = 0
                btn2.AutoButtonColor = false
                btn2.Parent = p
                makecorner(UDim.new(0, 6), btn2)
                local bs = makestroke(accentcolor, 1, btn2)
                regaccent(bs, "Color")

                btn2.MouseButton1Click:Connect(function()
                    tweenservice:Create(btn2, TweenInfo.new(0.1), { BackgroundColor3 = Color3.fromRGB(30,10,60) }):Play()
                    task.wait(0.15)
                    tweenservice:Create(btn2, TweenInfo.new(0.1), { BackgroundColor3 = DARK4 }):Play()
                    if cb then cb() end
                end)
            end

            function target:addconfirmbutton(cfg)
                cfg = cfg or {}
                local txt  = cfg.title    or "button"
                local warn = cfg.warning  or "are you sure?"
                local cb   = cfg.callback
                local p = (target._isGroupbox and target._page) or page

                local btn2 = Instance.new("TextButton")
                btn2.Size = UDim2.new(1, 0, 0, 30)
                btn2.BackgroundColor3 = DARK4
                btn2.Text = txt
                btn2.TextColor3 = GREY3
                btn2.TextSize = 12
                btn2.Font = Enum.Font.GothamSemibold
                btn2.BorderSizePixel = 0
                btn2.AutoButtonColor = false
                btn2.Parent = p
                makecorner(UDim.new(0, 6), btn2)
                local bs = makestroke(accentcolor, 1, btn2)
                regaccent(bs, "Color")

                btn2.MouseButton1Click:Connect(function()
                    tweenservice:Create(btn2, TweenInfo.new(0.1), { BackgroundColor3 = Color3.fromRGB(30,10,60) }):Play()
                    task.wait(0.15)
                    tweenservice:Create(btn2, TweenInfo.new(0.1), { BackgroundColor3 = DARK4 }):Play()
                    cpwarn.Text = warn
                    pendingyes = cb; pendingrevert = nil
                    confirmpopup.Visible = true
                end)
            end

            function target:addconfirmtoggle(cfg)
                cfg = cfg or {}
                local txt     = cfg.title    or "toggle"
                local warn    = cfg.warning  or "are you sure?"
                local default = cfg.default  or false
                local cb      = cfg.callback
                local p = (target._isGroupbox and target._page) or page

                local row = Instance.new("Frame")
                row.Size = UDim2.new(1, 0, 0, 32)
                row.BackgroundColor3 = DARK3
                row.BorderSizePixel = 0
                row.Parent = p
                makecorner(UDim.new(0, 6), row)

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

            function target:adddropdown(cfg)
                cfg = cfg or {}
                local txt    = cfg.title    or "dropdown"
                local values = cfg.values   or {}
                local cb     = cfg.callback
                local p = (target._isGroupbox and target._page) or page

                local container = Instance.new("Frame")
                container.Size = UDim2.new(1, 0, 0, 42)
                container.BackgroundColor3 = DARK3
                container.BorderSizePixel = 0
                container.ClipsDescendants = false
                container.ZIndex = 5
                container.Parent = p
                makecorner(UDim.new(0, 6), container)

                local lbl = Instance.new("TextLabel")
                lbl.Size = UDim2.new(1, -10, 0, 16)
                lbl.Position = UDim2.new(0, 10, 0, 3)
                lbl.BackgroundTransparency = 1
                lbl.Text = txt
                lbl.TextColor3 = GREY1
                lbl.TextSize = 10
                lbl.Font = Enum.Font.GothamSemibold
                lbl.TextXAlignment = Enum.TextXAlignment.Left
                lbl.ZIndex = 5
                lbl.Parent = container

                local dbtn = Instance.new("TextButton")
                dbtn.Size = UDim2.new(1, -16, 0, 24)
                dbtn.Position = UDim2.new(0, 8, 0, 19)
                dbtn.BackgroundColor3 = DARK4
                dbtn.Text = (values[1] or "none") .. "  ▾"
                dbtn.TextColor3 = GREY3
                dbtn.TextSize = 12
                dbtn.Font = Enum.Font.GothamSemibold
                dbtn.BorderSizePixel = 0
                dbtn.AutoButtonColor = false
                dbtn.ZIndex = 6
                dbtn.Parent = container
                makecorner(UDim.new(0, 5), dbtn)
                local dbtns = makestroke(accentcolor, 1, dbtn)
                regaccent(dbtns, "Color")

                local ddframe = Instance.new("Frame")
                ddframe.BackgroundColor3 = DARK4
                ddframe.BorderSizePixel = 0
                ddframe.ZIndex = 200
                ddframe.Visible = false
                ddframe.ClipsDescendants = true
                ddframe.Size = UDim2.new(0, 0, 0, 0)
                ddframe.Position = UDim2.new(0, 0, 0, 0)
                ddframe.Parent = screengui
                makecorner(UDim.new(0, 6), ddframe)
                local ddlayout = Instance.new("UIListLayout")
                ddlayout.SortOrder = Enum.SortOrder.LayoutOrder
                ddlayout.Parent = ddframe
                local dds = makestroke(accentcolor, 1, ddframe)
                regaccent(dds, "Color")

                local isopen = false
                local currentval = values[1] or "none"
                local currentvals = values

                local function closeDropdown()
                    isopen = false
                    tweenservice:Create(ddframe, TweenInfo.new(0.12), { Size = UDim2.new(0, ddframe.AbsoluteSize.X, 0, 0) }):Play()
                    task.delay(0.12, function() ddframe.Visible = false end)
                    dbtn.Text = currentval .. "  ▾"
                end

                local function setvalues(vals)
                    currentvals = vals
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
                        opt.ZIndex = 201
                        opt.Parent = ddframe
                        opt.MouseEnter:Connect(function()
                            if opt.Text ~= currentval then opt.BackgroundColor3 = GREY6 end
                        end)
                        opt.MouseLeave:Connect(function()
                            opt.BackgroundColor3 = DARK4
                        end)
                        opt.MouseButton1Click:Connect(function()
                            currentval = v
                            dbtn.Text = v .. "  ▾"
                            for _, c2 in ipairs(ddframe:GetChildren()) do
                                if c2:IsA("TextButton") then
                                    c2.TextColor3 = c2.Text == currentval and accentcolor or GREY2
                                end
                            end
                            closeDropdown()
                            if cb then cb(v) end
                        end)
                    end
                end

                setvalues(values)

                dbtn.MouseButton1Click:Connect(function()
                    isopen = not isopen
                    if isopen then
                        local ap = dbtn.AbsolutePosition
                        local as = dbtn.AbsoluteSize
                        local totalH = math.min(#currentvals, 8) * 26
                        ddframe.Position = UDim2.new(0, ap.X, 0, ap.Y + as.Y + 2)
                        ddframe.Size = UDim2.new(0, as.X, 0, 0)
                        ddframe.Visible = true
                        tweenservice:Create(ddframe, TweenInfo.new(0.12), { Size = UDim2.new(0, as.X, 0, totalH) }):Play()
                        dbtn.Text = currentval .. "  ▴"
                    else
                        closeDropdown()
                    end
                end)

                game:GetService("UserInputService").InputBegan:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseButton1 and isopen then
                        local mx, my = inp.Position.X, inp.Position.Y
                        local ap = ddframe.AbsolutePosition
                        local as = ddframe.AbsoluteSize
                        local inDD = mx >= ap.X and mx <= ap.X + as.X and my >= ap.Y and my <= ap.Y + as.Y
                        local bap = dbtn.AbsolutePosition
                        local bas = dbtn.AbsoluteSize
                        local inBtn = mx >= bap.X and mx <= bap.X + bas.X and my >= bap.Y and my <= bap.Y + bas.Y
                        if not inDD and not inBtn then
                            closeDropdown()
                        end
                    end
                end)

                return { setvalues = setvalues }
            end

            function target:addcolorpicker(cfg)
                cfg = cfg or {}
                local txt     = cfg.title    or "color"
                local default = cfg.default  or Color3.new(1, 1, 1)
                local cb      = cfg.callback
                local p = (target._isGroupbox and target._page) or page

                local h, s, v = Color3.toHSV(default)

                local row = Instance.new("Frame")
                row.Size = UDim2.new(1, 0, 0, 30)
                row.BackgroundColor3 = DARK3
                row.BorderSizePixel = 0
                row.Parent = p
                makecorner(UDim.new(0, 6), row)

                local lbl = Instance.new("TextLabel")
                lbl.Size = UDim2.new(1, -48, 1, 0)
                lbl.Position = UDim2.new(0, 10, 0, 0)
                lbl.BackgroundTransparency = 1; lbl.Text = txt
                lbl.TextColor3 = GREY2; lbl.TextSize = 12; lbl.Font = Enum.Font.Gotham
                lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.Parent = row

                local swatch = Instance.new("TextButton")
                swatch.Size = UDim2.new(0, 22, 0, 22)
                swatch.Position = UDim2.new(1, -34, 0.5, -11)
                swatch.BackgroundColor3 = default
                swatch.Text = ""; swatch.BorderSizePixel = 0; swatch.Parent = row
                makecorner(UDim.new(0, 5), swatch)
                makestroke(GREY7, 1, swatch)

                local popup = Instance.new("Frame")
                popup.Size = UDim2.new(0, 220, 0, 230)
                popup.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
                popup.BorderSizePixel = 0; popup.ZIndex = 200; popup.Visible = false
                popup.Parent = screengui
                makecorner(UDim.new(0, 10), popup)
                local pstroke = makestroke(accentcolor, 1, popup)
                regaccent(pstroke, "Color")

                local ptitle = Instance.new("TextLabel")
                ptitle.Size = UDim2.new(1, -8, 0, 22)
                ptitle.Position = UDim2.new(0, 8, 0, 4)
                ptitle.BackgroundTransparency = 1; ptitle.Text = txt
                ptitle.TextColor3 = GREY2; ptitle.TextSize = 11; ptitle.Font = Enum.Font.GothamBold
                ptitle.TextXAlignment = Enum.TextXAlignment.Left; ptitle.ZIndex = 201; ptitle.Parent = popup

                local pclosebtn = Instance.new("TextButton")
                pclosebtn.Size = UDim2.new(0, 18, 0, 18)
                pclosebtn.Position = UDim2.new(1, -22, 0, 4)
                pclosebtn.BackgroundColor3 = Color3.fromRGB(60,10,100)
                pclosebtn.Text = "×"; pclosebtn.TextColor3 = WHITE
                pclosebtn.TextSize = 10; pclosebtn.Font = Enum.Font.GothamBold
                pclosebtn.BorderSizePixel = 0; pclosebtn.ZIndex = 202; pclosebtn.Parent = popup
                makecorner(UDim.new(0,4), pclosebtn)
                pclosebtn.MouseButton1Click:Connect(function() popup.Visible = false end)

                local canvas = Instance.new("ImageLabel")
                canvas.Size = UDim2.new(0, 180, 0, 130)
                canvas.Position = UDim2.new(0, 10, 0, 30)
                canvas.BackgroundColor3 = Color3.new(1,0,0)
                canvas.Image = "rbxassetid://4155801252"
                canvas.ZIndex = 201; canvas.Parent = popup
                makecorner(UDim.new(0,4), canvas)

                local huebar = Instance.new("ImageLabel")
                huebar.Size = UDim2.new(0, 180, 0, 12)
                huebar.Position = UDim2.new(0, 10, 0, 166)
                huebar.Image = "rbxassetid://698052001"
                huebar.ZIndex = 201; huebar.Parent = popup
                makecorner(UDim.new(0,3), huebar)

                local brightbar = Instance.new("Frame")
                brightbar.Size = UDim2.new(0, 180, 0, 12)
                brightbar.Position = UDim2.new(0, 10, 0, 182)
                brightbar.BackgroundColor3 = Color3.new(1,1,1)
                brightbar.ZIndex = 201; brightbar.Parent = popup
                makecorner(UDim.new(0,3), brightbar)

                local brightgrad = Instance.new("UIGradient")
                brightgrad.Color = ColorSequence.new{
                    ColorSequenceKeypoint.new(0, Color3.new(1,1,1)),
                    ColorSequenceKeypoint.new(1, Color3.new(0,0,0))
                }
                brightgrad.Rotation = 0; brightgrad.Parent = brightbar

                local cursor = Instance.new("Frame")
                cursor.Size = UDim2.new(0, 10, 0, 10)
                cursor.AnchorPoint = Vector2.new(0.5, 0.5)
                cursor.BackgroundColor3 = WHITE
                cursor.BorderSizePixel = 0; cursor.ZIndex = 203; cursor.Parent = canvas
                makecorner(UDim.new(1,0), cursor)
                makestroke(DARK, 1, cursor)

                local huecursor = Instance.new("Frame")
                huecursor.Size = UDim2.new(0, 4, 1, 2)
                huecursor.AnchorPoint = Vector2.new(0.5, 0.5)
                huecursor.Position = UDim2.new(0, 0, 0.5, 0)
                huecursor.BackgroundColor3 = WHITE
                huecursor.BorderSizePixel = 0; huecursor.ZIndex = 203; huecursor.Parent = huebar
                makecorner(UDim.new(0,2), huecursor)
                makestroke(DARK, 1, huecursor)

                local brightcursor = Instance.new("Frame")
                brightcursor.Size = UDim2.new(0, 4, 1, 2)
                brightcursor.AnchorPoint = Vector2.new(0.5, 0.5)
                brightcursor.Position = UDim2.new(1, 0, 0.5, 0)
                brightcursor.BackgroundColor3 = WHITE
                brightcursor.BorderSizePixel = 0; brightcursor.ZIndex = 203; brightcursor.Parent = brightbar
                makecorner(UDim.new(0,2), brightcursor)
                makestroke(DARK, 1, brightcursor)

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
                makestroke(GREY7, 1, hexbox); makecorner(UDim.new(0,4), hexbox)

                local resultprev = Instance.new("Frame")
                resultprev.Size = UDim2.new(0, 60, 0, 20)
                resultprev.Position = UDim2.new(0, 116, 0, 1)
                resultprev.BackgroundColor3 = default
                resultprev.BorderSizePixel = 0; resultprev.ZIndex = 202; resultprev.Parent = hexrow
                makecorner(UDim.new(0,5), resultprev); makestroke(GREY7, 1, resultprev)

                local function color3tohex(c)
                    return string.format("%02X%02X%02X",
                        math.floor(c.R*255+0.5),
                        math.floor(c.G*255+0.5),
                        math.floor(c.B*255+0.5))
                end

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
                    brightbar.BackgroundColor3 = Color3.fromHSV(h, s, 1)
                    hexbox.Text = color3tohex(col)
                    cursor.Position = UDim2.new(s, 0, 1-v, 0)
                    huecursor.Position = UDim2.new(h, 0, 0.5, 0)
                    brightcursor.Position = UDim2.new(v, 0, 0.5, 0)
                    if cb then cb(col) end
                end

                local function openPopup()
                    local ap = swatch.AbsolutePosition
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
                        dragmode = "h"
                        local rel = uis:GetMouseLocation() - huebar.AbsolutePosition
                        h = math.clamp(rel.X / huebar.AbsoluteSize.X, 0, 1)
                        applycolor()
                    end
                end)
                brightbar.InputBegan:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragmode = "v"
                        local rel = uis:GetMouseLocation() - brightbar.AbsolutePosition
                        v = math.clamp(rel.X / brightbar.AbsoluteSize.X, 0, 1)
                        applycolor()
                    end
                end)
                uis.InputEnded:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseButton1 then dragmode = nil end
                end)
                uis.InputChanged:Connect(function(inp)
                    if dragmode and inp.UserInputType == Enum.UserInputType.MouseMovement then
                        if dragmode == "sv" then
                            local rel = uis:GetMouseLocation() - canvas.AbsolutePosition
                            s = math.clamp(rel.X / canvas.AbsoluteSize.X, 0, 1)
                            v = 1 - math.clamp(rel.Y / canvas.AbsoluteSize.Y, 0, 1)
                        elseif dragmode == "h" then
                            local rel = uis:GetMouseLocation() - huebar.AbsolutePosition
                            h = math.clamp(rel.X / huebar.AbsoluteSize.X, 0, 1)
                        elseif dragmode == "v" then
                            local rel = uis:GetMouseLocation() - brightbar.AbsolutePosition
                            v = math.clamp(rel.X / brightbar.AbsoluteSize.X, 0, 1)
                        end
                        applycolor()
                    end
                end)

                hexbox.FocusLost:Connect(function()
                    local c = hextoc3(hexbox.Text)
                    if c then h, s, v = Color3.toHSV(c); applycolor() end
                end)
            end

            function target:addkeybind(cfg)
                cfg = cfg or {}
                local txt    = cfg.title    or "keybind"
                local defkey = cfg.default  or Enum.KeyCode.Unknown
                local cb     = cfg.callback
                local p = (target._isGroupbox and target._page) or page

                local row = Instance.new("Frame")
                row.Size = UDim2.new(1, 0, 0, 32)
                row.BackgroundColor3 = DARK3
                row.BorderSizePixel = 0
                row.Parent = p
                makecorner(UDim.new(0, 6), row)

                local lbl = Instance.new("TextLabel")
                lbl.Size = UDim2.new(1, -90, 1, 0)
                lbl.Position = UDim2.new(0, 10, 0, 0)
                lbl.BackgroundTransparency = 1
                lbl.Text = txt
                lbl.TextColor3 = GREY3
                lbl.TextSize = 12
                lbl.Font = Enum.Font.Gotham
                lbl.TextXAlignment = Enum.TextXAlignment.Left
                lbl.Parent = row

                local kbtn = Instance.new("TextButton")
                kbtn.Size = UDim2.new(0, 76, 0, 20)
                kbtn.Position = UDim2.new(1, -82, 0.5, -10)
                kbtn.BackgroundColor3 = GREY6
                kbtn.Text = defkey ~= Enum.KeyCode.Unknown and ("[ " .. defkey.Name:lower() .. " ]") or "[ none ]"
                kbtn.TextColor3 = GREY2
                kbtn.TextSize = 10
                kbtn.Font = Enum.Font.GothamSemibold
                kbtn.BorderSizePixel = 0
                kbtn.Parent = row
                makecorner(UDim.new(0, 5), kbtn)
                makestroke(GREY7, 1, kbtn)

                local currentkey = defkey
                local listeningkb = false
                local kbstate = false

                local function setkbstate(v)
                    kbstate = v
                    kbtn.BackgroundColor3 = v and Color3.fromRGB(40, 15, 70) or GREY6
                    kbtn.TextColor3 = v and accentcolor or GREY2
                    if cb then cb(v) end
                end

                kbtn.MouseButton1Click:Connect(function()
                    listeningkb = true
                    kbtn.Text = "[ ... ]"
                    kbtn.TextColor3 = accentcolor
                end)

                uis.InputBegan:Connect(function(inp, gpe)
                    if gpe then return end
                    if listeningkb and inp.UserInputType == Enum.UserInputType.Keyboard then
                        listeningkb = false
                        currentkey = inp.KeyCode
                        kbtn.Text = "[ " .. inp.KeyCode.Name:lower() .. " ]"
                        kbtn.TextColor3 = kbstate and accentcolor or GREY2
                    elseif not listeningkb
                        and currentkey ~= Enum.KeyCode.Unknown
                        and inp.KeyCode == currentkey then
                        setkbstate(not kbstate)
                    end
                end)

                table.insert(keybindregistry, {
                    title    = txt,
                    getkey   = function() return currentkey.Name end,
                    getstate = function() return kbstate end,
                })
            end

            function target:addkeybindlist()
                local p = (target._isGroupbox and target._page) or page

                local row = Instance.new("Frame")
                row.Size = UDim2.new(1, 0, 0, 32)
                row.BackgroundColor3 = DARK3
                row.BorderSizePixel = 0
                row.Parent = p
                makecorner(UDim.new(0, 6), row)

                local lbl = Instance.new("TextLabel")
                lbl.Size = UDim2.new(1, -50, 1, 0)
                lbl.Position = UDim2.new(0, 10, 0, 0)
                lbl.BackgroundTransparency = 1
                lbl.Text = "show keybind panel"
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

                local kbopen = false
                local function settog(v)
                    kbopen = v
                    kbfloat.Visible = v
                    tweenservice:Create(circle, TweenInfo.new(0.12), {
                        Position = v and UDim2.new(1,-15,0.5,-6) or UDim2.new(0,3,0.5,-6)
                    }):Play()
                    tweenservice:Create(togbg, TweenInfo.new(0.12), {
                        BackgroundColor3 = v and accentcolor or GREY5
                    }):Play()
                    tweenservice:Create(circle, TweenInfo.new(0.12), {
                        BackgroundColor3 = v and WHITE or GREY1
                    }):Play()
                end

                local clickbtn = Instance.new("TextButton")
                clickbtn.Size = UDim2.new(1, 0, 1, 0)
                clickbtn.BackgroundTransparency = 1
                clickbtn.Text = ""
                clickbtn.Parent = row
                clickbtn.MouseButton1Click:Connect(function() settog(not kbopen) end)
            end
            function target:addthemepicker()
                local p = (target._isGroupbox and target._page) or page
                local colors = {
                    { "red",     Color3.fromRGB(210, 25, 25)  },
                    { "blue",    Color3.fromRGB(30, 100, 210) },
                    { "green",   Color3.fromRGB(30, 180, 80)  },
                    { "purple",  Color3.fromRGB(130, 40, 200) },
                    { "orange",  Color3.fromRGB(220, 110, 20) },
                    { "white",   Color3.fromRGB(220, 220, 220)},
                }
                local row = Instance.new("Frame")
                row.Size = UDim2.new(1, 0, 0, 34)
                row.BackgroundTransparency = 1
                row.BorderSizePixel = 0
                row.Parent = p

                local rl = Instance.new("UIListLayout")
                rl.FillDirection = Enum.FillDirection.Horizontal
                rl.SortOrder = Enum.SortOrder.LayoutOrder
                rl.Padding = UDim.new(0, 6)
                rl.VerticalAlignment = Enum.VerticalAlignment.Center
                rl.Parent = row

                for _, pair in ipairs(colors) do
                    local cname, cval = pair[1], pair[2]
                    local swatch = Instance.new("TextButton")
                    swatch.Size = UDim2.new(0, 28, 0, 28)
                    swatch.BackgroundColor3 = cval
                    swatch.Text = ""
                    swatch.BorderSizePixel = 0
                    swatch.Parent = row
                    makecorner(UDim.new(1, 0), swatch)
                    makestroke(GREY7, 1, swatch)
                    swatch.MouseButton1Click:Connect(function()
                        updatetheme(cval)
                    end)
                end
            end

            function target:addblurslider()
                local p = (target._isGroupbox and target._page) or page
                local togglerow = Instance.new("Frame")
                togglerow.Size = UDim2.new(1, 0, 0, 32)
                togglerow.BackgroundColor3 = DARK3
                togglerow.BorderSizePixel = 0
                togglerow.Parent = p
                makecorner(UDim.new(0, 6), togglerow)

                local toglbl = Instance.new("TextLabel")
                toglbl.Size = UDim2.new(1, -50, 1, 0)
                toglbl.Position = UDim2.new(0, 10, 0, 0)
                toglbl.BackgroundTransparency = 1
                toglbl.Text = "blur background"
                toglbl.TextColor3 = GREY3; toglbl.TextSize = 12; toglbl.Font = Enum.Font.Gotham
                toglbl.TextXAlignment = Enum.TextXAlignment.Left
                toglbl.Parent = togglerow

                local togbg2 = Instance.new("Frame")
                togbg2.Size = UDim2.new(0, 36, 0, 18)
                togbg2.Position = UDim2.new(1, -44, 0.5, -9)
                togbg2.BackgroundColor3 = GREY5
                togbg2.BorderSizePixel = 0
                togbg2.Parent = togglerow
                makecorner(UDim.new(1, 0), togbg2)

                local circle2 = Instance.new("Frame")
                circle2.Size = UDim2.new(0, 12, 0, 12)
                circle2.Position = UDim2.new(0, 3, 0.5, -6)
                circle2.BackgroundColor3 = GREY1
                circle2.BorderSizePixel = 0
                circle2.Parent = togbg2
                makecorner(UDim.new(1, 0), circle2)

                local setblurtog
                setblurtog = function(val)
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

                local lbl2 = Instance.new("TextLabel")
                lbl2.Size = UDim2.new(1, 0, 0, 18)
                lbl2.BackgroundTransparency = 1; lbl2.Text = "blur intensity: 20"
                lbl2.TextColor3 = GREY1; lbl2.TextSize = 11; lbl2.Font = Enum.Font.Gotham
                lbl2.TextXAlignment = Enum.TextXAlignment.Left; lbl2.BorderSizePixel = 0; lbl2.Parent = p
                makepad(0, 4, 0, 0, lbl2)

                local track2 = Instance.new("Frame")
                track2.Size = UDim2.new(1, -8, 0, 5)
                track2.BackgroundColor3 = GREY4; track2.BorderSizePixel = 0; track2.Parent = p
                makecorner(UDim.new(1, 0), track2)

                local fill2 = Instance.new("Frame")
                fill2.Size = UDim2.new(0.4, 0, 1, 0)
                fill2.BackgroundColor3 = accentcolor; fill2.BorderSizePixel = 0; fill2.Parent = track2
                makecorner(UDim.new(1, 0), fill2)
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
                    blurintensity = math.floor(rel * 56 + 0.5)
                    lbl2.Text = "blur intensity: " .. blurintensity
                    if blurenabled and mainframe.Visible then blureffect.Size = blurintensity end
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

            function target:addtransparencyslider()
                local p = (target._isGroupbox and target._page) or page
                local lbl = Instance.new("TextLabel")
                lbl.Size = UDim2.new(1, 0, 0, 18)
                lbl.BackgroundTransparency = 1
                lbl.Text = "transparency: 0%"
                lbl.TextColor3 = GREY1; lbl.TextSize = 11; lbl.Font = Enum.Font.Gotham
                lbl.TextXAlignment = Enum.TextXAlignment.Left
                lbl.BorderSizePixel = 0; lbl.Parent = p
                makepad(0, 4, 0, 0, lbl)

                local track = Instance.new("Frame")
                track.Size = UDim2.new(1, -8, 0, 5)
                track.BackgroundColor3 = GREY4; track.BorderSizePixel = 0; track.Parent = p
                makecorner(UDim.new(1, 0), track)

                local fill = Instance.new("Frame")
                fill.Size = UDim2.new(0, 0, 1, 0)
                fill.BackgroundColor3 = accentcolor; fill.BorderSizePixel = 0; fill.Parent = track
                makecorner(UDim.new(1, 0), fill)
                regaccent(fill, "BackgroundColor3")

                local knob = Instance.new("Frame")
                knob.Size = UDim2.new(0, 11, 0, 11)
                knob.Position = UDim2.new(1, -5, 0.5, -5)
                knob.BackgroundColor3 = Color3.fromRGB(230,230,230); knob.BorderSizePixel = 0; knob.Parent = fill
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

            function target:addkeybindsetting(cfg)
                cfg = cfg or {}
                local txt = cfg.title or "toggle ui"
                local p = (target._isGroupbox and target._page) or page

                local row = Instance.new("Frame")
                row.Size = UDim2.new(1, 0, 0, 30)
                row.BackgroundColor3 = DARK3
                row.BorderSizePixel = 0
                row.Parent = p
                makecorner(UDim.new(0, 6), row)

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
                makecorner(UDim.new(0, 5), kbtn)
                makestroke(GREY7, 1, kbtn)

                kbtn.MouseButton1Click:Connect(function()
                    listeningforkey = true; kbtn.Text = "[ ... ]"; kbtn.TextColor3 = accentcolor
                end)
                uis.InputBegan:Connect(function(inp, gpe)
                    if gpe then return end
                    if listeningforkey and inp.UserInputType == Enum.UserInputType.Keyboard then
                        listeningforkey = false
                        currenttogglekey = inp.KeyCode
                        kbtn.Text = "[ " .. string.lower(inp.KeyCode.Name) .. " ]"
                        kbtn.TextColor3 = GREY2
                    end
                end)
            end
        end

        -- apply element methods to the tab itself
        addElementsTo(tab)

        -- patch addgroupbox so groupboxes also get all element methods
        local origAddGroupbox = tab.addgroupbox
        tab.addgroupbox = function(self, title, collapsed)
            local gb = origAddGroupbox(self, title, collapsed)
            addElementsTo(gb)
            return gb
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

return astrixhub
