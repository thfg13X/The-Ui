local multihubx = {}
multihubx.__index = multihubx

local tweenservice = game:GetService("TweenService")
local uis = game:GetService("UserInputService")
local players = game:GetService("Players")
local lp = players.LocalPlayer

local function makecorner(radius, parent)
    local c = Instance.new("UICorner")
    c.CornerRadius = radius or UDim.new(0, 0)
    c.Parent = parent
    return c
end

local function makestroke(color, thickness, parent)
    local s = Instance.new("UIStroke")
    s.Color = color or Color3.fromRGB(210, 25, 25)
    s.Thickness = thickness or 1
    s.Parent = parent
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

local RED    = Color3.fromRGB(210, 25, 25)
local DARK   = Color3.fromRGB(15, 15, 15)
local DARK2  = Color3.fromRGB(18, 18, 18)
local DARK3  = Color3.fromRGB(22, 22, 22)
local DARK4  = Color3.fromRGB(25, 25, 25)
local DARK5  = Color3.fromRGB(20, 20, 20)
local GREY1  = Color3.fromRGB(150, 150, 150)
local GREY2  = Color3.fromRGB(200, 200, 200)
local GREY3  = Color3.fromRGB(210, 210, 210)
local GREY4  = Color3.fromRGB(38, 38, 38)
local GREY5  = Color3.fromRGB(45, 45, 45)
local GREY6  = Color3.fromRGB(28, 28, 28)
local GREY7  = Color3.fromRGB(55, 55, 55)
local WHITE  = Color3.fromRGB(255, 255, 255)

function multihubx:createwindow(config)
    config = config or {}
    local title    = config.title    or "multi hub x"
    local subtitle = config.subtitle or ""
    local size     = config.size     or UDim2.new(0, 580, 0, 390)
    local togglekey = config.togglekey or Enum.KeyCode.RightShift

    local playergui = lp:WaitForChild("PlayerGui")

    local screengui = Instance.new("ScreenGui")
    screengui.Name = "multihubx_" .. title:lower():gsub("%s", "")
    screengui.ResetOnSpawn = false
    screengui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screengui.Parent = playergui

    local notifstack = {}

    local function sendnotif(msg)
        local nf = Instance.new("Frame")
        nf.Size = UDim2.new(0, 240, 0, 40)
        nf.Position = UDim2.new(1, -250, 1, -(44 * (#notifstack + 1) + 10))
        nf.BackgroundColor3 = DARK2
        nf.BackgroundTransparency = 1
        nf.BorderSizePixel = 0
        nf.ZIndex = 50
        nf.Parent = screengui

        makestroke(RED, 1, nf)

        local nfl = Instance.new("TextLabel")
        nfl.Size = UDim2.new(1, -12, 1, -6)
        nfl.Position = UDim2.new(0, 8, 0, 2)
        nfl.BackgroundTransparency = 1
        nfl.Text = msg
        nfl.TextColor3 = GREY3
        nfl.TextSize = 11
        nfl.Font = Enum.Font.Gotham
        nfl.TextXAlignment = Enum.TextXAlignment.Left
        nfl.TextWrapped = true
        nfl.ZIndex = 51
        nfl.Parent = nf

        local bar = Instance.new("Frame")
        bar.Size = UDim2.new(1, 0, 0, 2)
        bar.Position = UDim2.new(0, 0, 1, -2)
        bar.BackgroundColor3 = RED
        bar.BorderSizePixel = 0
        bar.ZIndex = 51
        bar.Parent = nf

        table.insert(notifstack, nf)
        tweenservice:Create(nf, TweenInfo.new(0.2), { BackgroundTransparency = 0 }):Play()
        tweenservice:Create(bar, TweenInfo.new(3.5, Enum.EasingStyle.Linear), { Size = UDim2.new(0, 0, 0, 2) }):Play()

        task.delay(3.5, function()
            tweenservice:Create(nf, TweenInfo.new(0.3), { BackgroundTransparency = 1 }):Play()
            tweenservice:Create(nfl, TweenInfo.new(0.3), { TextTransparency = 1 }):Play()
            task.wait(0.3)
            for i, v in ipairs(notifstack) do
                if v == nf then table.remove(notifstack, i); break end
            end
            nf:Destroy()
        end)
    end

    local confirmpopup = Instance.new("Frame")
    confirmpopup.Size = UDim2.new(0, 310, 0, 165)
    confirmpopup.Position = UDim2.new(0.5, -155, 0.5, -82)
    confirmpopup.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
    confirmpopup.BorderSizePixel = 0
    confirmpopup.ZIndex = 100
    confirmpopup.Visible = false
    confirmpopup.Parent = screengui
    makestroke(RED, 2, confirmpopup)

    local cptitle = Instance.new("TextLabel")
    cptitle.Size = UDim2.new(1, -16, 0, 28)
    cptitle.Position = UDim2.new(0, 8, 0, 8)
    cptitle.BackgroundTransparency = 1
    cptitle.Text = "are you sure?"
    cptitle.TextColor3 = RED
    cptitle.TextSize = 14
    cptitle.Font = Enum.Font.GothamBold
    cptitle.TextXAlignment = Enum.TextXAlignment.Left
    cptitle.ZIndex = 101
    cptitle.Parent = confirmpopup

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

    local pendingyes = nil
    local pendingrevert = nil

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
    makestroke(RED, 2, mainframe)

    local titlebar = Instance.new("Frame")
    titlebar.Size = UDim2.new(1, 0, 0, 34)
    titlebar.BackgroundColor3 = DARK5
    titlebar.BorderSizePixel = 0
    titlebar.ZIndex = 2
    titlebar.Parent = mainframe

    local fulltitle = subtitle ~= "" and (title .. "  |  " .. subtitle) or title
    local titlelbl = Instance.new("TextLabel")
    titlelbl.Size = UDim2.new(1, -70, 1, 0)
    titlelbl.Position = UDim2.new(0, 10, 0, 0)
    titlelbl.BackgroundTransparency = 1
    titlelbl.Text = fulltitle
    titlelbl.TextColor3 = RED
    titlelbl.TextSize = 14
    titlelbl.Font = Enum.Font.GothamBold
    titlelbl.TextXAlignment = Enum.TextXAlignment.Left
    titlelbl.ZIndex = 2
    titlelbl.Parent = titlebar

    local function maketitlebtn(txt, xoff, bg)
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(0, 28, 0, 24)
        b.Position = UDim2.new(1, xoff, 0, 5)
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
    local minbtn   = maketitlebtn("-", -64, Color3.fromRGB(35, 35, 35))

    local sep = Instance.new("Frame")
    sep.Size = UDim2.new(1, 0, 0, 1)
    sep.Position = UDim2.new(0, 0, 0, 34)
    sep.BackgroundColor3 = RED
    sep.BorderSizePixel = 0
    sep.ZIndex = 2
    sep.Parent = mainframe

    local tabpanel = Instance.new("Frame")
    tabpanel.Size = UDim2.new(0, 120, 1, -35)
    tabpanel.Position = UDim2.new(0, 0, 0, 35)
    tabpanel.BackgroundColor3 = DARK2
    tabpanel.BorderSizePixel = 0
    tabpanel.ClipsDescendants = true
    tabpanel.Parent = mainframe

    local tabdiv = Instance.new("Frame")
    tabdiv.Size = UDim2.new(0, 1, 1, -35)
    tabdiv.Position = UDim2.new(0, 120, 0, 35)
    tabdiv.BackgroundColor3 = RED
    tabdiv.BorderSizePixel = 0
    tabdiv.Parent = mainframe

    local tablayout = Instance.new("UIListLayout")
    tablayout.SortOrder = Enum.SortOrder.LayoutOrder
    tablayout.Padding = UDim.new(0, 0)
    tablayout.Parent = tabpanel

    local contentarea = Instance.new("Frame")
    contentarea.Size = UDim2.new(1, -121, 1, -35)
    contentarea.Position = UDim2.new(0, 121, 0, 35)
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
    makestroke(RED, 2, miniwidget)

    local minilbl = Instance.new("TextLabel")
    minilbl.Size = UDim2.new(1, 0, 1, 0)
    minilbl.BackgroundTransparency = 1
    minilbl.Text = "m-x"
    minilbl.TextColor3 = RED
    minilbl.TextSize = 13
    minilbl.Font = Enum.Font.GothamBold
    minilbl.ZIndex = 21
    minilbl.Parent = miniwidget

    local minihitbox = Instance.new("TextButton")
    minihitbox.Size = UDim2.new(1, 0, 1, 0)
    minihitbox.BackgroundTransparency = 1
    minihitbox.Text = ""
    minihitbox.ZIndex = 22
    minihitbox.Parent = miniwidget

    local minidragging = false
    local minidragstart = nil
    local ministartpos = nil
    local minihasmoved = false

    minihitbox.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            minidragging = true; minihasmoved = false
            minidragstart = inp.Position; ministartpos = miniwidget.Position
        end
    end)
    minihitbox.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then minidragging = false end
    end)
    minihitbox.MouseButton1Click:Connect(function()
        if not minihasmoved then
            miniwidget.Visible = false; mainframe.Visible = true
        end
    end)

    local function collapse()
        mainframe.Visible = false; miniwidget.Visible = true
    end

    closebtn.MouseButton1Click:Connect(collapse)
    minbtn.MouseButton1Click:Connect(collapse)

    local maindragging = false
    local maindragstart = nil
    local mainstartpos = nil

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
                mainstartpos.Y.Scale, mainstartpos.Y.Offset + d.Y
            )
        end
        if minidragging and minidragstart then
            local d = inp.Position - minidragstart
            if math.abs(d.X) > 3 or math.abs(d.Y) > 3 then minihasmoved = true end
            miniwidget.Position = UDim2.new(
                ministartpos.X.Scale, ministartpos.X.Offset + d.X,
                ministartpos.Y.Scale, ministartpos.Y.Offset + d.Y
            )
        end
    end)

    uis.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            maindragging = false; minidragging = false
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
            else miniwidget.Visible = false; mainframe.Visible = true end
        end
    end)

    local tablist = {}
    local pagelist = {}
    local activetab = nil
    local taborder = 0

    local function selecttab(name)
        if activetab == name then return end
        activetab = name
        for tname, info in pairs(tablist) do
            local isactive = tname == name
            info.btn.TextColor3 = isactive and WHITE or GREY1
            info.btn.BackgroundColor3 = DARK2
            info.indicator.Visible = isactive
        end
        for pname, page in pairs(pagelist) do
            page.Visible = pname == name
        end
    end

    local window = {}

    function window:addtab(name)
        taborder = taborder + 1
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
        indicator.BackgroundColor3 = RED
        indicator.BorderSizePixel = 0
        indicator.Visible = false
        indicator.ZIndex = 2
        indicator.Parent = btn

        tablist[name] = { btn = btn, indicator = indicator }

        local scroll = Instance.new("ScrollingFrame")
        scroll.Size = UDim2.new(1, 0, 1, 0)
        scroll.BackgroundTransparency = 1
        scroll.BorderSizePixel = 0
        scroll.ScrollBarThickness = 3
        scroll.ScrollBarImageColor3 = RED
        scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
        scroll.Visible = false
        scroll.Parent = contentarea
        pagelist[name] = scroll

        local layout = Instance.new("UIListLayout")
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Padding = UDim.new(0, 4)
        layout.Parent = scroll

        makepad(8, 8, 8, 8, scroll)

        layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 16)
        end)

        btn.MouseButton1Click:Connect(function() selecttab(name) end)

        local tab = {}
        local page = scroll

        function tab:addsection(txt)
            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(1, 0, 0, 20)
            lbl.BackgroundTransparency = 1
            lbl.Text = txt
            lbl.TextColor3 = RED
            lbl.TextSize = 11
            lbl.Font = Enum.Font.GothamBold
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.BorderSizePixel = 0
            lbl.Parent = page
            makepad(0, 4, 0, 0, lbl)
        end

        function tab:addtoggle(config)
            config = config or {}
            local txt     = config.title or "toggle"
            local default = config.default or false
            local cb      = config.callback

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
                    Position = v and UDim2.new(1, -15, 0.5, -6) or UDim2.new(0, 3, 0.5, -6)
                }):Play()
                tweenservice:Create(togbg, TweenInfo.new(0.12), {
                    BackgroundColor3 = v and RED or GREY5
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

        function tab:addslider(config)
            config = config or {}
            local txt     = config.title or "slider"
            local default = config.default or 50
            local min     = config.min or 0
            local max     = config.max or 100
            local cb      = config.callback

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
            vallbl.TextColor3 = RED
            vallbl.TextSize = 12
            vallbl.Font = Enum.Font.GothamBold
            vallbl.TextXAlignment = Enum.TextXAlignment.Right
            vallbl.Parent = row

            local track = Instance.new("Frame")
            track.Size = UDim2.new(1, -20, 0, 5)
            track.Position = UDim2.new(0, 10, 0, 32)
            track.BackgroundColor3 = GREY4
            track.BorderSizePixel = 0
            track.Parent = row

            local initrel = math.clamp((default - min) / (max - min), 0, 1)
            local fill = Instance.new("Frame")
            fill.Size = UDim2.new(initrel, 0, 1, 0)
            fill.BackgroundColor3 = RED
            fill.BorderSizePixel = 0
            fill.Parent = track

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
                if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                    slideactive = true; updateslider(inp.Position.X)
                end
            end)
            knob.InputBegan:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 then slideactive = true end
            end)
            uis.InputEnded:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 then slideactive = false end
            end)
            uis.InputChanged:Connect(function(inp)
                if slideactive and inp.UserInputType == Enum.UserInputType.MouseMovement then
                    updateslider(inp.Position.X)
                end
            end)
        end

        function tab:addbutton(config)
            config = config or {}
            local txt = config.title or "button"
            local cb  = config.callback

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
            makestroke(RED, 1, btn2)

            btn2.MouseButton1Click:Connect(function()
                tweenservice:Create(btn2, TweenInfo.new(0.1), { BackgroundColor3 = Color3.fromRGB(40, 10, 10) }):Play()
                task.wait(0.15)
                tweenservice:Create(btn2, TweenInfo.new(0.1), { BackgroundColor3 = DARK4 }):Play()
                if cb then cb() end
            end)
        end

        function tab:addconfirmbutton(config)
            config = config or {}
            local txt    = config.title or "button"
            local warn   = config.warning or "are you sure you want to do this?"
            local cb     = config.callback
            local revert = config.onno

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
            makestroke(RED, 1, btn2)

            btn2.MouseButton1Click:Connect(function()
                tweenservice:Create(btn2, TweenInfo.new(0.1), { BackgroundColor3 = Color3.fromRGB(40, 10, 10) }):Play()
                task.wait(0.15)
                tweenservice:Create(btn2, TweenInfo.new(0.1), { BackgroundColor3 = DARK4 }):Play()
                cpwarn.Text = warn
                pendingyes = cb
                pendingrevert = revert
                confirmpopup.Visible = true
            end)
        end

        function tab:addconfirmtoggle(config)
            config = config or {}
            local txt    = config.title or "toggle"
            local warn   = config.warning or "are you sure you want to do this?"
            local default = config.default or false
            local cb     = config.callback

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
                        tweenservice:Create(circle, TweenInfo.new(0.12), { Position = UDim2.new(1, -15, 0.5, -6) }):Play()
                        tweenservice:Create(togbg, TweenInfo.new(0.12), { BackgroundColor3 = RED }):Play()
                        tweenservice:Create(circle, TweenInfo.new(0.12), { BackgroundColor3 = WHITE }):Play()
                        if cb then cb(true) end
                    end
                    pendingrevert = function()
                        setstate(false, true)
                    end
                    confirmpopup.Visible = true
                    return
                end
                state = v
                tweenservice:Create(circle, TweenInfo.new(0.12), {
                    Position = v and UDim2.new(1, -15, 0.5, -6) or UDim2.new(0, 3, 0.5, -6)
                }):Play()
                tweenservice:Create(togbg, TweenInfo.new(0.12), {
                    BackgroundColor3 = v and RED or GREY5
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

        function tab:adddropdown(config)
            config = config or {}
            local txt    = config.title or "dropdown"
            local values = config.values or {}
            local cb     = config.callback

            local container = Instance.new("Frame")
            container.Size = UDim2.new(1, 0, 0, 30)
            container.BackgroundColor3 = DARK3
            container.BorderSizePixel = 0
            container.ClipsDescendants = false
            container.ZIndex = 5
            container.Parent = page

            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(0.45, 0, 1, 0)
            lbl.Position = UDim2.new(0, 10, 0, 0)
            lbl.BackgroundTransparency = 1
            lbl.Text = txt
            lbl.TextColor3 = GREY2
            lbl.TextSize = 12
            lbl.Font = Enum.Font.Gotham
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.ZIndex = 5
            lbl.Parent = container

            local dbtn = Instance.new("TextButton")
            dbtn.Size = UDim2.new(0.5, -10, 0, 22)
            dbtn.Position = UDim2.new(0.5, 0, 0, 4)
            dbtn.BackgroundColor3 = GREY6
            dbtn.Text = values[1] or "none"
            dbtn.TextColor3 = GREY2
            dbtn.TextSize = 11
            dbtn.Font = Enum.Font.Gotham
            dbtn.BorderSizePixel = 0
            dbtn.ZIndex = 6
            dbtn.Parent = container
            makestroke(GREY7, 1, dbtn)

            local ddframe = Instance.new("Frame")
            ddframe.Size = UDim2.new(0.5, -10, 0, 0)
            ddframe.Position = UDim2.new(0.5, 0, 1, 2)
            ddframe.BackgroundColor3 = DARK3
            ddframe.BorderSizePixel = 0
            ddframe.ZIndex = 10
            ddframe.Visible = false
            ddframe.ClipsDescendants = true
            ddframe.Parent = container

            Instance.new("UIListLayout", ddframe).SortOrder = Enum.SortOrder.LayoutOrder
            makestroke(RED, 1, ddframe)

            local isopen = false

            local function setvalues(vals)
                for _, c in ipairs(ddframe:GetChildren()) do
                    if c:IsA("TextButton") then c:Destroy() end
                end
                for _, v in ipairs(vals) do
                    local opt = Instance.new("TextButton")
                    opt.Size = UDim2.new(1, 0, 0, 22)
                    opt.BackgroundColor3 = GREY6
                    opt.Text = v
                    opt.TextColor3 = GREY2
                    opt.TextSize = 11
                    opt.Font = Enum.Font.Gotham
                    opt.BorderSizePixel = 0
                    opt.ZIndex = 11
                    opt.Parent = ddframe
                    opt.MouseButton1Click:Connect(function()
                        dbtn.Text = v; isopen = false
                        tweenservice:Create(ddframe, TweenInfo.new(0.15), { Size = UDim2.new(0.5,-10,0,0) }):Play()
                        task.wait(0.15); ddframe.Visible = false
                        container.Size = UDim2.new(1, 0, 0, 30)
                        if cb then cb(v) end
                    end)
                end
            end

            setvalues(values)

            dbtn.MouseButton1Click:Connect(function()
                isopen = not isopen
                if isopen then
                    local cnt = #ddframe:GetChildren() - 1
                    ddframe.Visible = true
                    ddframe.Size = UDim2.new(0.5, -10, 0, 0)
                    tweenservice:Create(ddframe, TweenInfo.new(0.15), { Size = UDim2.new(0.5,-10,0,cnt*22) }):Play()
                    container.Size = UDim2.new(1, 0, 0, 30 + cnt*22 + 2)
                else
                    tweenservice:Create(ddframe, TweenInfo.new(0.15), { Size = UDim2.new(0.5,-10,0,0) }):Play()
                    task.wait(0.15); ddframe.Visible = false
                    container.Size = UDim2.new(1, 0, 0, 30)
                end
            end)

            return { setvalues = setvalues }
        end

        function tab:addcolorpicker(config)
            config = config or {}
            local txt     = config.title or "color"
            local default = config.default or Color3.new(1,1,1)
            local cb      = config.callback

            local palette = {
                Color3.new(1,0,0), Color3.new(0,0.5,1), Color3.new(0,1,0),
                Color3.new(1,1,0), Color3.new(1,0,1),   Color3.new(1,1,1),
            }

            local row = Instance.new("Frame")
            row.Size = UDim2.new(1, 0, 0, 30)
            row.BackgroundColor3 = DARK3
            row.BorderSizePixel = 0
            row.Parent = page

            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(0.4, 0, 1, 0)
            lbl.Position = UDim2.new(0, 10, 0, 0)
            lbl.BackgroundTransparency = 1
            lbl.Text = txt
            lbl.TextColor3 = GREY2
            lbl.TextSize = 12
            lbl.Font = Enum.Font.Gotham
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.Parent = row

            local crow = Instance.new("Frame")
            crow.Size = UDim2.new(0.55, 0, 0, 20)
            crow.Position = UDim2.new(0.42, 0, 0.5, -10)
            crow.BackgroundTransparency = 1
            crow.BorderSizePixel = 0
            crow.Parent = row

            local cl = Instance.new("UIListLayout")
            cl.FillDirection = Enum.FillDirection.Horizontal
            cl.Padding = UDim.new(0, 3)
            cl.Parent = crow

            if cb then cb(default) end

            for _, c in ipairs(palette) do
                local sw = Instance.new("TextButton")
                sw.Size = UDim2.new(0, 18, 0, 18)
                sw.BackgroundColor3 = c
                sw.Text = ""
                sw.BorderSizePixel = 0
                sw.Parent = crow
                sw.MouseButton1Click:Connect(function() if cb then cb(c) end end)
            end
        end

        function tab:addkeybind(config)
            config = config or {}
            local txt        = config.title or "keybind"
            local defaultkey = config.default or "none"
            local cb         = config.callback

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

            local currentkey = defaultkey
            local togstate   = false
            local listening  = false

            local kbtn = Instance.new("TextButton")
            kbtn.Size = UDim2.new(0, 88, 0, 22)
            kbtn.Position = UDim2.new(1, -94, 0.5, -11)
            kbtn.BackgroundColor3 = GREY6
            kbtn.Text = "[" .. string.lower(defaultkey) .. "]"
            kbtn.TextColor3 = GREY2
            kbtn.TextSize = 11
            kbtn.Font = Enum.Font.GothamSemibold
            kbtn.BorderSizePixel = 0
            kbtn.Parent = row
            makestroke(GREY7, 1, kbtn)

            kbtn.MouseButton1Click:Connect(function()
                listening = true; kbtn.Text = "..."
                kbtn.TextColor3 = RED
            end)

            uis.InputBegan:Connect(function(inp, gpe)
                if listening and inp.UserInputType == Enum.UserInputType.Keyboard then
                    listening = false
                    currentkey = inp.KeyCode.Name
                    kbtn.Text = "[" .. string.lower(currentkey) .. "]"
                    kbtn.TextColor3 = GREY2
                elseif not listening and inp.UserInputType == Enum.UserInputType.Keyboard
                    and inp.KeyCode.Name == currentkey and not gpe then
                    togstate = not togstate
                    kbtn.BackgroundColor3 = togstate and Color3.fromRGB(40,10,10) or GREY6
                    if cb then cb(togstate) end
                end
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
            fill.BackgroundColor3 = RED
            fill.BorderSizePixel = 0
            fill.Parent = track

            local knob = Instance.new("Frame")
            knob.Size = UDim2.new(0, 11, 0, 11)
            knob.Position = UDim2.new(1, -5, 0.5, -5)
            knob.BackgroundColor3 = Color3.fromRGB(230, 230, 230)
            knob.BorderSizePixel = 0
            knob.Parent = fill
            makecorner(UDim.new(1, 0), knob)

            local transactive = false

            local function updatetrans(ix)
                local rel = math.clamp((ix - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
                fill.Size = UDim2.new(rel, 0, 1, 0)
                lbl.Text = "transparency: " .. math.floor(rel * 100) .. "%"
                mainframe.BackgroundTransparency = rel * 0.88
            end

            track.InputBegan:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                    transactive = true; updatetrans(inp.Position.X)
                end
            end)
            knob.InputBegan:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 then transactive = true end
            end)
            uis.InputEnded:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 then transactive = false end
            end)
            uis.InputChanged:Connect(function(inp)
                if transactive and inp.UserInputType == Enum.UserInputType.MouseMovement then
                    updatetrans(inp.Position.X)
                end
            end)
        end

        function tab:addkeybindsetting(config)
            config = config or {}
            local txt = config.title or "toggle ui"

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
                listeningforkey = true
                kbtn.Text = "[ ... ]"
                kbtn.TextColor3 = RED
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

        if activetab == nil then
            selecttab(name)
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
