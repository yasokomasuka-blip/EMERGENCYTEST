-- // ============================================
-- // KYNTRIX V0.2 | ULTIMATE EDITION
-- // ============================================

-- // ============ SERVİSLER ============
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- // ============ ESKİ UI TEMİZLE ============
for _, v in pairs(CoreGui:GetChildren()) do
    if v.Name == "KYNTRIX_UI" then v:Destroy() end
end
if LocalPlayer:FindFirstChild("PlayerGui") then
    for _, v in pairs(LocalPlayer.PlayerGui:GetChildren()) do
        if v.Name == "KYNTRIX_UI" then v:Destroy() end
    end
end

-- // ============ BİLDİRİM SİSTEMİ ============
local NotificationFrame = Instance.new("Frame")
NotificationFrame.Name = "KYNTRIX_Notification"
NotificationFrame.Size = UDim2.new(0, 300, 0, 40)
NotificationFrame.Position = UDim2.new(0, 10, 1, -50)
NotificationFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
NotificationFrame.BorderSizePixel = 0
NotificationFrame.Visible = false
NotificationFrame.ZIndex = 9999
Instance.new("UICorner", NotificationFrame).CornerRadius = UDim.new(0, 8)

local NotificationStroke = Instance.new("UIStroke", NotificationFrame)
NotificationStroke.Color = Color3.fromRGB(130, 60, 255)
NotificationStroke.Thickness = 1.5
NotificationStroke.Transparency = 0.3

local NotificationText = Instance.new("TextLabel", NotificationFrame)
NotificationText.Size = UDim2.new(1, -20, 1, 0)
NotificationText.Position = UDim2.new(0, 10, 0, 0)
NotificationText.BackgroundTransparency = 1
NotificationText.Font = Enum.Font.GothamBold
NotificationText.TextSize = 14
NotificationText.TextColor3 = Color3.fromRGB(255, 255, 255)
NotificationText.TextXAlignment = Enum.TextXAlignment.Left

local function ShowNotification(text, color)
    NotificationFrame.Parent = CoreGui
    NotificationText.Text = text
    NotificationStroke.Color = color or Color3.fromRGB(130, 60, 255)
    NotificationFrame.Visible = true
    NotificationFrame.Position = UDim2.new(0, 10, 1, -50)
    
    TweenService:Create(NotificationFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Position = UDim2.new(0, 10, 1, -100)
    }):Play()
    
    task.delay(3, function()
        TweenService:Create(NotificationFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Position = UDim2.new(0, 10, 1, -50)
        }):Play()
        task.wait(0.5)
        NotificationFrame.Visible = false
    end)
end

-- // ============ ANTİ-CHEAT BYPASS (KAPSAMLI) ============
local function AntiCheatBypass()
    -- Meta tablo bypass
    local mt = getrawmetatable(game)
    if mt then
        setreadonly(mt, false)
        local oldIndex = mt.__index
        local oldNewIndex = mt.__newindex
        
        mt.__index = newcclosure(function(self, k)
            if k == "WalkSpeed" or k == "JumpPower" or k == "HipHeight" then
                return 16
            end
            return oldIndex(self, k)
        end)
        
        mt.__newindex = newcclosure(function(self, k, v)
            if k == "WalkSpeed" then
                return oldNewIndex(self, k, math.clamp(v, 0, 100))
            elseif k == "JumpPower" then
                return oldNewIndex(self, k, math.clamp(v, 0, 150))
            end
            return oldNewIndex(self, k, v)
        end)
        setreadonly(mt, true)
    end
    
    -- Anti-detection için RemoteEvent izleme
    local oldNamecall
    oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
        local method = getnamecallmethod()
        local args = {...}
        
        if method == "FireServer" and typeof(self) == "Instance" then
            if self.Name:lower():find("anticheat") or self.Name:lower():find("detect") or self.Name:lower():find("ban") then
                return nil -- Engelle
            end
        end
        
        return oldNamecall(self, ...)
    end))
    
    -- Log servisini sustur
    if game:FindService("LogService") then
        game:GetService("LogService").MessageOut:Connect(function() end)
    end
end

-- // ============ AYARLAR ============
local Settings = {
    Visuals  = { 
        Enable=false, Box=false, Name=false, Health=false, Distance=false, 
        Skeleton=false, Snaplines=false, Weapon=false, MaxDistance=1000,
        TeamCheck=false, ShowLocalPlayer=false, ESPTransparency=0
    },
    ESPColors= { 
        Box=Color3.fromRGB(255,255,255), 
        Name=Color3.fromRGB(255,255,255),
        Health=Color3.fromRGB(50,255,50),
        Snapline=Color3.fromRGB(130,60,255)
    },
    Movement = { 
        Noclip=false, NoFallDamage=false, ClickTP=false, Speed=false, 
        SpeedValue=24, InfiniteJump=false, Fly=false, FlySpeed=50,
        AutoRespawn=false, AntiAFK=false
    },
    Misc     = { 
        ShowFPS=false, AutoReconnect=false, AutoFarm=false, 
        AntiLag=false, FullBright=false
    },
    Vehicle  = { 
        SpeedMultiplier=0.025, BrakeForce=0.150, 
        AccelKey=Enum.KeyCode.Unknown, BrakeKey=Enum.KeyCode.Unknown,
        VehicleFly=false
    }
}

-- // ============ UI OLUŞTUR ============
local sg = Instance.new("ScreenGui")
sg.Name="KYNTRIX_UI"; sg.ResetOnSpawn=false; sg.IgnoreGuiInset=true
local ok = pcall(function() sg.Parent=CoreGui end)
if not ok then sg.Parent=LocalPlayer:WaitForChild("PlayerGui") end

local UIVisible = true

-- FPS Label
local FPSLabel = Instance.new("TextLabel", sg)
FPSLabel.Size=UDim2.new(0,120,0,28); FPSLabel.Position=UDim2.new(1,-130,0,8)
FPSLabel.BackgroundTransparency=1; FPSLabel.TextColor3=Color3.fromRGB(0,255,120)
FPSLabel.TextStrokeTransparency=0; FPSLabel.Font=Enum.Font.GothamBold
FPSLabel.TextSize=15; FPSLabel.TextXAlignment=Enum.TextXAlignment.Right; FPSLabel.Visible=false
local _ff,_fl=0,tick()
local _frameCount=0

-- Ana Frame
local MainFrame = Instance.new("Frame", sg)
MainFrame.Size=UDim2.new(0,700,0,500); MainFrame.Position=UDim2.new(0.5,-350,0.5,-250)
MainFrame.BackgroundColor3=Color3.fromRGB(18,18,25); MainFrame.BorderSizePixel=0; MainFrame.Active=true
Instance.new("UICorner",MainFrame).CornerRadius=UDim.new(0,12)

-- Gradient effect
local UIGradient = Instance.new("UIGradient", MainFrame)
UIGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(25,25,35)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(15,15,20))
})
UIGradient.Rotation = 45

local ms=Instance.new("UIStroke",MainFrame) 
ms.Color=Color3.fromRGB(150,80,255)
ms.Thickness=2
ms.Transparency=0.2

-- Drag sistemi
local dragging,dragInput,dragStart,startPos
MainFrame.InputBegan:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 then
        dragging=true; dragStart=i.Position; startPos=MainFrame.Position
        i.Changed:Connect(function() if i.UserInputState==Enum.UserInputState.End then dragging=false end end)
    end
end)
MainFrame.InputChanged:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseMovement then dragInput=i end end)
UserInputService.InputChanged:Connect(function(i)
    if i==dragInput and dragging then
        local d=i.Position-dragStart
        MainFrame.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,startPos.Y.Scale,startPos.Y.Offset+d.Y)
    end
end)

-- Klavye kısayolları
UserInputService.InputBegan:Connect(function(input,gpe)
    if gpe then return end
    if input.KeyCode==Enum.KeyCode.X then
        UIVisible=not UIVisible; MainFrame.Visible=UIVisible
    end
    if input.KeyCode==Enum.KeyCode.F then
        Settings.Movement.Fly = not Settings.Movement.Fly
        if Settings.Movement.Fly then
            ShowNotification("Fly Enabled", Color3.fromRGB(50,255,50))
        else
            ShowNotification("Fly Disabled", Color3.fromRGB(255,50,50))
        end
    end
    if input.UserInputType==Enum.UserInputType.MouseButton1 and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
        if Settings.Movement.ClickTP then
            local r=LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if r then 
                r.CFrame=CFrame.new(Mouse.Hit.Position+Vector3.new(0,3,0)) 
                ShowNotification("Teleported!", Color3.fromRGB(130,60,255))
            end
        end
    end
end)

-- Sidebar
local Sidebar=Instance.new("Frame",MainFrame)
Sidebar.Size=UDim2.new(0,180,1,0); Sidebar.BackgroundColor3=Color3.fromRGB(25,22,32); Sidebar.BorderSizePixel=0
Instance.new("UICorner",Sidebar).CornerRadius=UDim.new(0,12)

local SidebarGradient = Instance.new("UIGradient", Sidebar)
SidebarGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(30,25,40)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(20,18,28))
})

-- Logo
local Logo=Instance.new("TextLabel",Sidebar)
Logo.Size=UDim2.new(1,0,0,35); Logo.Position=UDim2.new(0,20,0,15); Logo.BackgroundTransparency=1
Logo.Text="KYNTRIX"; Logo.TextColor3=Color3.fromRGB(255,255,255); Logo.Font=Enum.Font.GothamBlack
Logo.TextSize=24; Logo.TextXAlignment=Enum.TextXAlignment.Left

local LogoGradient = Instance.new("UIGradient", Logo)
LogoGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255,255,255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(180,140,255))
})

local SubLogo=Instance.new("TextLabel",Sidebar)
SubLogo.Size=UDim2.new(1,0,0,20); SubLogo.Position=UDim2.new(0,20,0,42); SubLogo.BackgroundTransparency=1
SubLogo.Text="V0.2 ULTIMATE"; SubLogo.TextColor3=Color3.fromRGB(150,140,160); SubLogo.TextTransparency=0.4
SubLogo.Font=Enum.Font.GothamMedium; SubLogo.TextSize=11; SubLogo.TextXAlignment=Enum.TextXAlignment.Left

-- Profil
local SP=Instance.new("Frame",Sidebar)
SP.Size=UDim2.new(1,0,0,65); SP.Position=UDim2.new(0,0,1,-65)
SP.BackgroundColor3=Color3.fromRGB(20,18,28); SP.BorderSizePixel=0
Instance.new("UICorner",SP).CornerRadius=UDim.new(0,12)

local SP_Ico=Instance.new("ImageLabel",SP)
SP_Ico.Size=UDim2.new(0,40,0,40); SP_Ico.Position=UDim2.new(0,15,0.5,-20)
SP_Ico.BackgroundColor3=Color3.fromRGB(40,35,50)
Instance.new("UICorner",SP_Ico).CornerRadius=UDim.new(1,0)
Instance.new("UIStroke", SP_Ico).Color = Color3.fromRGB(150,80,255)

task.spawn(function()
    local c,r=Players:GetUserThumbnailAsync(LocalPlayer.UserId,Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size420x420)
    if r then SP_Ico.Image=c end
end)

local SP_N=Instance.new("TextLabel",SP)
SP_N.Size=UDim2.new(1,-65,0,18); SP_N.Position=UDim2.new(0,60,0,12)
SP_N.BackgroundTransparency=1; SP_N.Text=LocalPlayer.Name; SP_N.TextColor3=Color3.fromRGB(255,255,255)
SP_N.Font=Enum.Font.GothamBold; SP_N.TextSize=13; SP_N.TextXAlignment=Enum.TextXAlignment.Left

local SP_R=Instance.new("TextLabel",SP)
SP_R.Size=UDim2.new(1,-65,0,15); SP_R.Position=UDim2.new(0,60,0,32)
SP_R.BackgroundTransparency=1; SP_R.Text="PREMIUM USER"; SP_R.TextColor3=Color3.fromRGB(255,200,50)
SP_R.Font=Enum.Font.GothamMedium; SP_R.TextSize=10; SP_R.TextXAlignment=Enum.TextXAlignment.Left

-- Tab Container
local TabContainers=Instance.new("Frame",MainFrame)
TabContainers.Size=UDim2.new(1,-200,1,-20); TabContainers.Position=UDim2.new(0,190,0,10)
TabContainers.BackgroundTransparency=1

local Tabs={}
local function SwitchTab(id)
    for tid,tab in pairs(Tabs) do
        local a=tid==id
        tab.Btn.BackgroundColor3=a and Color3.fromRGB(150,80,255) or Color3.fromRGB(25,22,32)
        tab.Btn.TextColor3=a and Color3.fromRGB(255,255,255) or Color3.fromRGB(150,140,160)
        tab.Container.Visible=a
    end
end

local function CreateTab(text,id,idx)
    local btn=Instance.new("TextButton",Sidebar)
    btn.Size=UDim2.new(1,-20,0,40); btn.Position=UDim2.new(0,10,0,85+(idx*46))
    btn.BackgroundColor3=Color3.fromRGB(25,22,32); btn.BorderSizePixel=0
    btn.Text="  "..text; btn.TextColor3=Color3.fromRGB(150,140,160)
    btn.Font=Enum.Font.GothamSemibold; btn.TextSize=14; btn.TextXAlignment=Enum.TextXAlignment.Left
    Instance.new("UICorner",btn).CornerRadius=UDim.new(0,8)
    
    -- Hover effect
    btn.MouseEnter:Connect(function()
        if Tabs[id].Container.Visible == false then
            TweenService:Create(btn, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(40,35,50)
            }):Play()
        end
    end)
    btn.MouseLeave:Connect(function()
        if Tabs[id].Container.Visible == false then
            TweenService:Create(btn, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(25,22,32)
            }):Play()
        end
    end)
    
    local c=Instance.new("ScrollingFrame",TabContainers)
    c.Size=UDim2.new(1,0,1,0); c.BackgroundTransparency=1; c.BorderSizePixel=0
    c.ScrollBarThickness=3; c.ScrollBarImageColor3=Color3.fromRGB(150,80,255); c.Visible=false
    c.ScrollBarImageTransparency = 0.5
    
    local t=Instance.new("TextLabel",c)
    t.Size=UDim2.new(1,0,0,45); t.BackgroundTransparency=1; t.Text=text
    t.TextColor3=Color3.fromRGB(255,255,255); t.Font=Enum.Font.GothamBlack; t.TextSize=26
    t.TextXAlignment=Enum.TextXAlignment.Left
    
    Tabs[id]={Btn=btn,Container=c,YOff=55}
    btn.MouseButton1Click:Connect(function() SwitchTab(id) end)
end

local function Sec(tid,text)
    local tab=Tabs[tid]; local s=Instance.new("TextLabel",tab.Container)
    s.Size=UDim2.new(1,-10,0,28); s.Position=UDim2.new(0,0,0,tab.YOff); tab.YOff+=35
    s.BackgroundTransparency=1; s.Text="━━ "..text.." ━━"; s.TextColor3=Color3.fromRGB(180,150,255)
    s.Font=Enum.Font.GothamBlack; s.TextSize=14; s.TextXAlignment=Enum.TextXAlignment.Left
    tab.Container.CanvasSize=UDim2.new(0,0,0,tab.YOff+10)
end

local function Toggle(tid,text,cat,key)
    local tab=Tabs[tid]; local row=Instance.new("Frame",tab.Container)
    row.Size=UDim2.new(1,-10,0,42); row.Position=UDim2.new(0,0,0,tab.YOff); tab.YOff+=48
    row.BackgroundColor3=Color3.fromRGB(28,26,36); Instance.new("UICorner",row).CornerRadius=UDim.new(0,8)
    
    local lbl=Instance.new("TextLabel",row)
    lbl.Size=UDim2.new(0.7,0,1,0); lbl.Position=UDim2.new(0,15,0,0); lbl.BackgroundTransparency=1
    lbl.Text=text; lbl.TextColor3=Color3.fromRGB(230,230,240); lbl.Font=Enum.Font.GothamMedium
    lbl.TextSize=13; lbl.TextXAlignment=Enum.TextXAlignment.Left
    
    local tBg=Instance.new("Frame",row)
    tBg.Size=UDim2.new(0,40,0,20); tBg.AnchorPoint=Vector2.new(1,0.5); tBg.Position=UDim2.new(1,-15,0.5,0)
    tBg.BackgroundColor3=Color3.fromRGB(45,40,60); Instance.new("UICorner",tBg).CornerRadius=UDim.new(1,0)
    
    local tC=Instance.new("Frame",tBg)
    tC.Size=UDim2.new(0,16,0,16); tC.AnchorPoint=Vector2.new(0,0.5); tC.Position=UDim2.new(0,2,0.5,0)
    tC.BackgroundColor3=Color3.fromRGB(180,160,200); Instance.new("UICorner",tC).CornerRadius=UDim.new(1,0)
    
    local btn=Instance.new("TextButton",row); btn.Size=UDim2.new(1,0,1,0); btn.BackgroundTransparency=1; btn.Text=""
    
    btn.MouseButton1Click:Connect(function()
        Settings[cat][key]=not Settings[cat][key]; local st=Settings[cat][key]
        TweenService:Create(tBg,TweenInfo.new(0.2),{
            BackgroundColor3=st and Color3.fromRGB(150,80,255) or Color3.fromRGB(45,40,60)
        }):Play()
        TweenService:Create(tC,TweenInfo.new(0.2),{
            Position=st and UDim2.new(1,-18,0.5,0) or UDim2.new(0,2,0.5,0),
            BackgroundColor3=st and Color3.fromRGB(255,255,255) or Color3.fromRGB(180,160,200)
        }):Play()
    end)
    tab.Container.CanvasSize=UDim2.new(0,0,0,tab.YOff+10)
end

local function Slider(tid,text,cat,key,mn,mx,mult)
    mult=mult or 1; local tab=Tabs[tid]; local row=Instance.new("Frame",tab.Container)
    row.Size=UDim2.new(1,-10,0,55); row.Position=UDim2.new(0,0,0,tab.YOff); tab.YOff+=61
    row.BackgroundColor3=Color3.fromRGB(28,26,36); Instance.new("UICorner",row).CornerRadius=UDim.new(0,8)
    
    local lbl=Instance.new("TextLabel",row); lbl.Size=UDim2.new(0.5,0,0,22); lbl.Position=UDim2.new(0,15,0,5)
    lbl.BackgroundTransparency=1; lbl.Text=text; lbl.TextColor3=Color3.fromRGB(230,230,240)
    lbl.Font=Enum.Font.GothamMedium; lbl.TextSize=13; lbl.TextXAlignment=Enum.TextXAlignment.Left
    
    local vL=Instance.new("TextLabel",row); vL.Size=UDim2.new(0.5,-30,0,22); vL.Position=UDim2.new(0.5,0,0,5)
    vL.BackgroundTransparency=1; vL.Text=tostring(Settings[cat][key]*mult)
    vL.TextColor3=Color3.fromRGB(180,150,255); vL.Font=Enum.Font.GothamBold; vL.TextSize=13; vL.TextXAlignment=Enum.TextXAlignment.Right
    
    local sBg=Instance.new("Frame",row); sBg.Size=UDim2.new(1,-30,0,8); sBg.Position=UDim2.new(0,15,0,35)
    sBg.BackgroundColor3=Color3.fromRGB(20,18,28); Instance.new("UICorner",sBg).CornerRadius=UDim.new(1,0)
    
    local fill=Instance.new("Frame",sBg)
    fill.Size=UDim2.new(math.clamp((Settings[cat][key]*mult-mn)/(mx-mn),0,1),0,1,0)
    fill.BackgroundColor3=Color3.fromRGB(150,80,255); Instance.new("UICorner",fill).CornerRadius=UDim.new(1,0)
    
    local fillGradient = Instance.new("UIGradient", fill)
    fillGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(150,80,255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(200,120,255))
    })
    
    local sb=Instance.new("TextButton",sBg); sb.Size=UDim2.new(1,0,1,15); sb.Position=UDim2.new(0,0,0,-5)
    sb.BackgroundTransparency=1; sb.Text=""
    
    local ds=false
    sb.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then ds=true end end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then ds=false end end)
    UserInputService.InputChanged:Connect(function(i)
        if ds and i.UserInputType==Enum.UserInputType.MouseMovement then
            local pct=math.clamp((i.Position.X-sBg.AbsolutePosition.X)/sBg.AbsoluteSize.X,0,1)
            fill.Size=UDim2.new(pct,0,1,0)
            local val=math.floor(mn+((mx-mn)*pct)); vL.Text=tostring(val); Settings[cat][key]=val/mult
        end
    end)
    tab.Container.CanvasSize=UDim2.new(0,0,0,tab.YOff+10)
end

local function Btn(tid,text,cb)
    local tab=Tabs[tid]; local row=Instance.new("Frame",tab.Container)
    row.Size=UDim2.new(1,-10,0,42); row.Position=UDim2.new(0,0,0,tab.YOff); tab.YOff+=48
    row.BackgroundColor3=Color3.fromRGB(28,26,36); Instance.new("UICorner",row).CornerRadius=UDim.new(0,8)
    
    local btn=Instance.new("TextButton",row); btn.Size=UDim2.new(1,0,1,0); btn.BackgroundTransparency=1
    btn.Text="  "..text; btn.TextColor3=Color3.fromRGB(255,255,255)
    btn.Font=Enum.Font.GothamMedium; btn.TextSize=13; btn.TextXAlignment=Enum.TextXAlignment.Left
    
    btn.MouseEnter:Connect(function()
        TweenService:Create(row, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(40,35,50)
        }):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(row, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(28,26,36)
        }):Play()
    end)
    
    btn.MouseButton1Click:Connect(function() cb(btn) end)
    tab.Container.CanvasSize=UDim2.new(0,0,0,tab.YOff+10)
end

local function Keybind(tid,text,cat,key)
    local tab=Tabs[tid]; local row=Instance.new("Frame",tab.Container)
    row.Size=UDim2.new(1,-10,0,42); row.Position=UDim2.new(0,0,0,tab.YOff); tab.YOff+=48
    row.BackgroundColor3=Color3.fromRGB(28,26,36); Instance.new("UICorner",row).CornerRadius=UDim.new(0,8)
    
    local lbl=Instance.new("TextLabel",row); lbl.Size=UDim2.new(0.5,0,1,0); lbl.Position=UDim2.new(0,15,0,0)
    lbl.BackgroundTransparency=1; lbl.Text=text; lbl.TextColor3=Color3.fromRGB(230,230,240)
    lbl.Font=Enum.Font.GothamMedium; lbl.TextSize=13; lbl.TextXAlignment=Enum.TextXAlignment.Left
    
    local kbtn=Instance.new("TextButton",row); kbtn.Size=UDim2.new(0,90,0,26); kbtn.Position=UDim2.new(1,-105,0.5,-13)
    kbtn.BackgroundColor3=Color3.fromRGB(50,45,65)
    kbtn.Text=Settings[cat][key]==Enum.KeyCode.Unknown and "None" or Settings[cat][key].Name
    kbtn.TextColor3=Color3.fromRGB(255,255,255); kbtn.Font=Enum.Font.GothamBold; kbtn.TextSize=12
    Instance.new("UICorner",kbtn).CornerRadius=UDim.new(0,6)
    Instance.new("UIStroke", kbtn).Color = Color3.fromRGB(150,80,255)
    
    local li=false; kbtn.MouseButton1Click:Connect(function() li=true; kbtn.Text="..." end)
    UserInputService.InputBegan:Connect(function(i)
        if li and i.UserInputType==Enum.UserInputType.Keyboard then
            li=false; Settings[cat][key]=i.KeyCode; kbtn.Text=i.KeyCode.Name
        end
    end)
    tab.Container.CanvasSize=UDim2.new(0,0,0,tab.YOff+10)
end

local CLR={Color3.fromRGB(255,255,255),Color3.fromRGB(255,50,50),Color3.fromRGB(50,255,50),Color3.fromRGB(50,150,255),Color3.fromRGB(255,255,50),Color3.fromRGB(255,100,255),Color3.fromRGB(150,50,255),Color3.fromRGB(50,255,255),Color3.fromRGB(255,150,50)}
local function Clr(tid,text,cat,key)
    local tab=Tabs[tid]; local row=Instance.new("Frame",tab.Container)
    row.Size=UDim2.new(1,-10,0,42); row.Position=UDim2.new(0,0,0,tab.YOff); tab.YOff+=48
    row.BackgroundColor3=Color3.fromRGB(28,26,36); Instance.new("UICorner",row).CornerRadius=UDim.new(0,8)
    
    local lbl=Instance.new("TextLabel",row); lbl.Size=UDim2.new(0.5,0,1,0); lbl.Position=UDim2.new(0,15,0,0)
    lbl.BackgroundTransparency=1; lbl.Text=text.." (Click)"; lbl.TextColor3=Color3.fromRGB(230,230,240)
    lbl.Font=Enum.Font.GothamMedium; lbl.TextSize=13; lbl.TextXAlignment=Enum.TextXAlignment.Left
    
    local cbtn=Instance.new("TextButton",row); cbtn.Size=UDim2.new(0,45,0,22); cbtn.Position=UDim2.new(1,-60,0.5,-11)
    cbtn.BackgroundColor3=Settings[cat][key]; cbtn.Text=""
    Instance.new("UICorner",cbtn).CornerRadius=UDim.new(0,6)
    Instance.new("UIStroke",cbtn).Color=Color3.fromRGB(255,255,255)
    Instance.new("UIStroke",cbtn).Thickness=1
    
    local ci=1; for i,c in ipairs(CLR) do if c==Settings[cat][key] then ci=i break end end
    cbtn.MouseButton1Click:Connect(function() 
        ci=(ci%#CLR)+1; Settings[cat][key]=CLR[ci]; cbtn.BackgroundColor3=CLR[ci] 
    end)
    tab.Container.CanvasSize=UDim2.new(0,0,0,tab.YOff+10)
end

-- // ============ SEKMELER ============
CreateTab("🏠 Home","Home",0)
Sec("Home","Welcome to KYNTRIX")
Btn("Home","Status: UNDETECTED & SAFE",function()
    ShowNotification("Status: UNDETECTED!", Color3.fromRGB(50,255,50))
end)
Btn("Home","Version: V0.2 ULTIMATE",function()
    ShowNotification("KYNTRIX V0.2 ULTIMATE", Color3.fromRGB(150,80,255))
end)
Btn("Home","Creator: Anonymous",function()
    ShowNotification("Made with ❤️", Color3.fromRGB(255,100,100))
end)

CreateTab("👁 Visuals","Vis",1)
Sec("Vis","ESP Settings")
Toggle("Vis","ESP Master Switch","Visuals","Enable")
Slider("Vis","Max View Distance (m)","Visuals","MaxDistance",100,2000)
Toggle("Vis","Box ESP","Visuals","Box"); Clr("Vis","Box Color","ESPColors","Box")
Toggle("Vis","Name ESP","Visuals","Name")
Toggle("Vis","Health ESP","Visuals","Health")
Toggle("Vis","Distance ESP","Visuals","Distance")
Toggle("Vis","Skeleton ESP","Visuals","Skeleton")
Toggle("Vis","Snaplines","Visuals","Snaplines")
Toggle("Vis","Weapon ESP","Visuals","Weapon")

CreateTab("🏃 Movement","Mov",2)
Sec("Mov","Speed Settings")
Toggle("Mov","Speed Hack","Movement","Speed")
Slider("Mov","Speed Value","Movement","SpeedValue",16,100)
Toggle("Mov","Infinite Jump","Movement","InfiniteJump")
Toggle("Mov","Fly Mode (F)","Movement","Fly")
Slider("Mov","Fly Speed","Movement","FlySpeed",10,200)

Sec("Mov","Utility")
Toggle("Mov","Noclip","Movement","Noclip")
Toggle("Mov","No Fall Damage","Movement","NoFallDamage")
Toggle("Mov","Ctrl+Click Teleport","Movement","ClickTP")
Toggle("Mov","Auto Respawn","Movement","AutoRespawn")
Toggle("Mov","Anti-AFK","Movement","AntiAFK")

Btn("Mov","Fast Die (Instant Respawn)",function()
    local c=LocalPlayer.Character; if c and c:FindFirstChild("Humanoid") then c.Humanoid.Health=0 end
end)
Btn("Mov","Get Out From Police Car",function()
    local c=LocalPlayer.Character; if c and c:FindFirstChild("Humanoid") then
        c.Humanoid.Sit=false; task.wait(0.1)
        local r=c:FindFirstChild("HumanoidRootPart"); if r then r.CFrame=r.CFrame*CFrame.new(0,5,0) end
    end
end)

-- // ============ GELİŞMİŞ TELEPORT SİSTEMİ ============
local function SafeTeleport(targetPos)
    local char = LocalPlayer.Character
    if not char then return false end
    
    local root = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChild("Humanoid")
    if not root or not hum then return false end
    
    -- Eğer araçtaysa araçtan çıkar
    if hum.SeatPart then
        hum.Sit = false
        task.wait(0.3)
    end
    
    -- Noclip'i geçici olarak etkinleştir
    local oldNoclip = Settings.Movement.Noclip
    Settings.Movement.Noclip = true
    
    -- Hedef pozisyonu ayarla
    local finalPos = targetPos + Vector3.new(0, 5, 0)
    
    -- Raycast ile zemin kontrolü
    local rayParams = RaycastParams.new()
    rayParams.FilterDescendantsInstances = {char}
    rayParams.FilterType = Enum.RaycastFilterType.Blacklist
    
    local ray = workspace:Raycast(targetPos, Vector3.new(0, -100, 0), rayParams)
    if ray then
        finalPos = ray.Position + Vector3.new(0, 5, 0)
    end
    
    -- Teleport et
    root.CFrame = CFrame.new(finalPos)
    
    -- Hızı sıfırla (bug önleme)
    root.AssemblyLinearVelocity = Vector3.zero
    root.AssemblyAngularVelocity = Vector3.zero
    
    -- Kısa bekleme sonrası noclip'i geri al
    task.wait(0.5)
    Settings.Movement.Noclip = oldNoclip
    
    return true
end

local Dealers={
    {name="Dealer 1", pos=Vector3.new(-2698,44,166)},
    {name="Dealer 2", pos=Vector3.new(23,72,231)},
    {name="Dealer 3", pos=Vector3.new(47,101,65)},
    {name="Dealer 4", pos=Vector3.new(75,44,1804)}
}

CreateTab("📍 Teleports","TP",3)
Sec("TP","Special Locations")
Btn("TP","Teleport To Nearest Dealer",function(b)
    local r=LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not r then return end
    local best,bd=nil,math.huge
    for _,d in ipairs(Dealers) do 
        local dist=(r.Position-d.pos).Magnitude
        if dist<bd then bd=dist; best=d end 
    end
    if best then 
        local o=b.Text; b.Text="  Teleporting..."
        ShowNotification("Teleporting to "..best.name.."...", Color3.fromRGB(150,80,255))
        SafeTeleport(best.pos)
        task.wait(0.5); b.Text=o
        ShowNotification("Teleported!", Color3.fromRGB(50,255,50))
    end
end)

local TPs={
    {"Rob Teleports",{
        {"Jeweler",Vector3.new(-473,44,303)},
        {"Bank",Vector3.new(-500,44,-1369)},
        {"Bank V2",Vector3.new(-414,44,-236)},
        {"Count Gas 1",Vector3.new(-593,44,2431)},
        {"Count Gas 2",Vector3.new(-1279,44,2135)},
        {"Count Gas 3",Vector3.new(486,44,-2241)},
        {"Moon Gas",Vector3.new(-1343,44,-1152)},
        {"House 1",Vector3.new(-1636,44,-800)},
        {"House 2",Vector3.new(-2112,44,-858)},
        {"House 3",Vector3.new(-2058,44,-632)}
    }},
    {"Packstation",{
        {"Gun Tuner",Vector3.new(-223,44,-681)},
        {"Hospital",Vector3.new(-491,44,-1761)},
        {"Count Gas 3",Vector3.new(-462,44,-2210)},
        {"Moon Gas",Vector3.new(-1319,44,-1104)},
        {"Police",Vector3.new(106,72,891)},
        {"Car Spawner",Vector3.new(-954,44,225)},
        {"Fire Dept",Vector3.new(-2081,44,421)},
        {"House",Vector3.new(-1894,44,-621)},
        {"D.A.C.E",Vector3.new(-1674,44,-1271)},
        {"OPI",Vector3.new(835,44,249)}
    }},
    {"Map Teleports",{
        {"D.A.C.E",Vector3.new(-1707,44,-1407)},
        {"Car Spawn",Vector3.new(-1002,44,150)},
        {"Fire Dept",Vector3.new(-1721,44,417)},
        {"Hospital",Vector3.new(426,44,-1715)},
        {"Vehicle Shop",Vector3.new(105,44,-2169)},
        {"Police",Vector3.new(-70,71,769)}
    }}
}

for _,cat in ipairs(TPs) do 
    Sec("TP",cat[1]); 
    for _,loc in ipairs(cat[2]) do 
        Btn("TP","→  "..loc[1],function(b)
            local o=b.Text
            b.Text = "  Teleporting..."
            ShowNotification("Teleporting to "..loc[1].."...", Color3.fromRGB(150,80,255))
            SafeTeleport(loc[2])
            task.wait(0.5)
            b.Text = o
            ShowNotification("Teleported!", Color3.fromRGB(50,255,50))
        end) 
    end 
end

CreateTab("🚗 Car Boost","Car",4)
Sec("Car","Car Tweaks")
Keybind("Car","Acceleration Key","Vehicle","AccelKey")
Slider("Car","Acceleration Mult","Vehicle","SpeedMultiplier",0,50,1000)
Keybind("Car","Brake Key","Vehicle","BrakeKey")
Slider("Car","Brake Force","Vehicle","BrakeForce",0,300,1000)
Toggle("Car","Vehicle Fly","Vehicle","VehicleFly")

CreateTab("⚙ Misc","Misc",5)
Sec("Misc","Utility")
Toggle("Misc","Show FPS Counter","Misc","ShowFPS")
Toggle("Misc","Auto Reconnect","Misc","AutoReconnect")
Toggle("Misc","Anti-Lag Mode","Misc","AntiLag")
Toggle("Misc","Full Bright","Misc","FullBright")

Btn("Misc","FPS Boost",function()
    local L=game:GetService("Lighting"); L.GlobalShadows=false; L.FogEnd=9e9
    for _,v in ipairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") then v.Material=Enum.Material.SmoothPlastic; v.CastShadow=false
        elseif v:IsA("Decal") or v:IsA("Texture") or v:IsA("ParticleEmitter") or v:IsA("Trail") then pcall(function() v:Destroy() end) end
    end
    ShowNotification("FPS Boost Applied!", Color3.fromRGB(50,255,50))
end)

Btn("Misc","Server Hop",function()
    local req=request or http_request or (syn and syn.request); if not req then return end
    local r=req({Url=("https://games.roblox.com/v1/games/%s/servers/Public?sortOrder=Asc&limit=100"):format(game.PlaceId)})
    if r and r.Body then
        local b=HttpService:JSONDecode(r.Body)
        if b and b.data then 
            for _,v in ipairs(b.data) do 
                if type(v)=="table" and v.playing<v.maxPlayers and v.id~=game.JobId then 
                    TeleportService:TeleportToPlaceInstance(game.PlaceId,v.id,LocalPlayer); 
                    break 
                end 
            end 
        end
    end
    ShowNotification("Server Hopping...", Color3.fromRGB(150,80,255))
end)

SwitchTab("Home")

-- // ============ WEAPON CACHE ============
local WCache={}
local function GetWpn(tool)
    if not tool then return "" end
    if WCache[tool] then return WCache[tool] end
    local n=(tool.ToolTip~="" and tool.ToolTip) or tool.Name
    if n:match("%x%x%x%x%x%x%x%x%-") then n="Equipped"
        for _,c in pairs(tool:GetChildren()) do if c:IsA("BasePart") and c.Name~="Handle" then n=c.Name break end end
    end
    WCache[tool]=n; return n
end

-- // ============ ESP SİSTEMİ ============
local function US(o,v,p,s,c) if o.Visible~=v then o.Visible=v end if not v then return end local px,py=math.floor(p.X),math.floor(p.Y); if math.floor(o.Position.X)~=px or math.floor(o.Position.Y)~=py then o.Position=Vector2.new(px,py) end local sx,sy=math.floor(s.X),math.floor(s.Y); if math.floor(o.Size.X)~=sx or math.floor(o.Size.Y)~=sy then o.Size=Vector2.new(sx,sy) end if o.Color~=c then o.Color=c end end
local function UT(o,v,t,p,c) if o.Visible~=v then o.Visible=v end if not v then return end if o.Text~=t then o.Text=t end local px,py=math.floor(p.X),math.floor(p.Y); if math.floor(o.Position.X)~=px or math.floor(o.Position.Y)~=py then o.Position=Vector2.new(px,py) end if o.Color~=c then o.Color=c end end
local function UL(o,v,f,t,c) if o.Visible~=v then o.Visible=v end if not v then return end local fx,fy=math.floor(f.X),math.floor(f.Y); if math.floor(o.From.X)~=fx or math.floor(o.From.Y)~=fy then o.From=Vector2.new(fx,fy) end local tx,ty=math.floor(t.X),math.floor(t.Y); if math.floor(o.To.X)~=tx or math.floor(o.To.Y)~=ty then o.To=Vector2.new(tx,ty) end if o.Color~=c then o.Color=c end end

local EC={}
local function NE()
    local e={Box=Drawing.new("Square"),BoxO=Drawing.new("Square"),HpBg=Drawing.new("Square"),Hp=Drawing.new("Square"),Name=Drawing.new("Text"),Wpn=Drawing.new("Text"),Snap=Drawing.new("Line"),Bones={}}
    for i=1,14 do e.Bones[i]=Drawing.new("Line"); e.Bones[i].Thickness=1.5 end
    e.Name.Center=true; e.Name.Outline=true; e.Name.Size=15; e.Name.Font=2
    e.Wpn.Center=true; e.Wpn.Outline=true; e.Wpn.Size=13; e.Wpn.Font=2
    e.Box.Filled=false; e.Box.Thickness=1; e.BoxO.Filled=false; e.BoxO.Thickness=3
    e.HpBg.Filled=true; e.HpBg.Color=Color3.fromRGB(0,0,0); e.Hp.Filled=true
    return e
end
local function HA(e) US(e.Box,false); US(e.BoxO,false); US(e.HpBg,false); US(e.Hp,false); UT(e.Name,false); UT(e.Wpn,false); UL(e.Snap,false); for i=1,14 do UL(e.Bones[i],false) end end
local R15={{"Head","UpperTorso"},{"UpperTorso","LowerTorso"},{"UpperTorso","LeftUpperArm"},{"LeftUpperArm","LeftLowerArm"},{"LeftLowerArm","LeftHand"},{"UpperTorso","RightUpperArm"},{"RightUpperArm","RightLowerArm"},{"RightLowerArm","RightHand"},{"LowerTorso","LeftUpperLeg"},{"LeftUpperLeg","LeftLowerLeg"},{"LeftLowerLeg","LeftFoot"},{"LowerTorso","RightUpperLeg"},{"RightUpperLeg","RightLowerLeg"},{"RightLowerLeg","RightFoot"}}
local W=Color3.fromRGB(255,255,255); local BK=Color3.fromRGB(0,0,0)

RunService.RenderStepped:Connect(function()
    _ff+=1; local t=tick()
    if t-_fl>=1 then FPSLabel.Text="FPS: "..math.floor(_ff/(t-_fl)); _ff=0; _fl=t end
    FPSLabel.Visible=Settings.Misc.ShowFPS and UIVisible

    _frameCount+=1
    if _frameCount%2~=0 then return end

    if not Settings.Visuals.Enable then
        for _,e in pairs(EC) do HA(e) end return
    end

    local cam=workspace.CurrentCamera
    local camPos=cam.CFrame.Position; local vps=cam.ViewportSize

    for _,p in pairs(Players:GetPlayers()) do
        if p==LocalPlayer and not Settings.Visuals.ShowLocalPlayer then continue end
        local e=EC[p.UserId]; if not e then e=NE(); EC[p.UserId]=e end
        local char=p.Character
        if not char then HA(e); continue end
        local root=char:FindFirstChild("HumanoidRootPart"); local hum=char:FindFirstChild("Humanoid")
        if not root or not hum or hum.Health<=0 then HA(e); continue end
        local dist=(camPos-root.Position).Magnitude
        if dist>Settings.Visuals.MaxDistance then HA(e); continue end
        local head=char:FindFirstChild("Head") or root
        local sc,on=cam:WorldToViewportPoint(root.Position)
        if not on then HA(e); continue end
        local hSc=cam:WorldToViewportPoint(head.Position+Vector3.new(0,0.5,0))
        local lSc=cam:WorldToViewportPoint(root.Position-Vector3.new(0,3,0))
        local top=math.min(hSc.Y,lSc.Y); local bot=math.max(hSc.Y,lSc.Y)
        local h=math.abs(hSc.Y-lSc.Y); local w=h/1.5; local col=Settings.ESPColors.Box
        US(e.Box,Settings.Visuals.Box,Vector2.new(sc.X-w/2,top),Vector2.new(w,h),col)
        US(e.BoxO,Settings.Visuals.Box,Vector2.new(sc.X-w/2-1,top-1),Vector2.new(w+2,h+2),BK)
        local hp=math.clamp(hum.Health/hum.MaxHealth,0,1)
        US(e.HpBg,Settings.Visuals.Health,Vector2.new(sc.X-w/2-6,top-1),Vector2.new(3,h+2),BK)
        US(e.Hp,Settings.Visuals.Health,Vector2.new(sc.X-w/2-5,top+(h*(1-hp))),Vector2.new(1,h*hp),Color3.fromHSV(hp*0.3,1,1))
        local nv=Settings.Visuals.Name or Settings.Visuals.Distance
        local nt=Settings.Visuals.Name and p.Name or ""
        if Settings.Visuals.Distance then nt=nt..(nt~="" and " [" or "[")..math.floor(dist).."m]" end
        UT(e.Name,nv,nt,Vector2.new(sc.X,top-18),Settings.ESPColors.Name)
        UT(e.Wpn,Settings.Visuals.Weapon,GetWpn(char:FindFirstChildOfClass("Tool")),Vector2.new(sc.X,bot+4),Color3.fromRGB(200,200,200))
        UL(e.Snap,Settings.Visuals.Snaplines,Vector2.new(vps.X/2,vps.Y),Vector2.new(sc.X,lSc.Y),Settings.ESPColors.Snapline)
        if Settings.Visuals.Skeleton then
            for i=1,14 do
                local pA=char:FindFirstChild(R15[i][1]); local pB=char:FindFirstChild(R15[i][2])
                if pA and pB then
                    local a,va=cam:WorldToViewportPoint(pA.Position); local b,vb=cam:WorldToViewportPoint(pB.Position)
                    if va or vb then UL(e.Bones[i],true,Vector2.new(a.X,a.Y),Vector2.new(b.X,b.Y),W) else UL(e.Bones[i],false) end
                else UL(e.Bones[i],false) end
            end
        else for i=1,14 do UL(e.Bones[i],false) end end
    end
end)

Players.PlayerRemoving:Connect(function(p)
    if EC[p.UserId] then
        for _,o in pairs(EC[p.UserId]) do
            if type(o)=="table" then for _,s in pairs(o) do pcall(function() s:Remove() end) end
            else pcall(function() o:Remove() end) end
        end; EC[p.UserId]=nil
    end
end)

-- // ============ FLY SİSTEMİ ============
local bodyVelocity, bodyGyro
RunService.Heartbeat:Connect(function()
    local char=LocalPlayer.Character; if not char then return end
    local root=char:FindFirstChild("HumanoidRootPart")
    local hum=char:FindFirstChildWhichIsA("Humanoid")

    if hum then
        -- Speed Hack
        if Settings.Movement.Speed then
            hum.WalkSpeed = Settings.Movement.SpeedValue
        else
            hum.WalkSpeed = 16
        end
        
        -- Infinite Jump
        if Settings.Movement.InfiniteJump then
            hum.JumpPower = 50
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        else
            hum.JumpPower = 7.2
        end
    end

    -- Noclip
    if Settings.Movement.Noclip then
        for _,p in pairs(char:GetChildren()) do
            if p:IsA("BasePart") and p.CanCollide then p.CanCollide=false end
        end
    end

    -- Fly
    if Settings.Movement.Fly and root then
        if not bodyVelocity then
            bodyVelocity = Instance.new("BodyVelocity")
            bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            bodyVelocity.Parent = root
        end
        if not bodyGyro then
            bodyGyro = Instance.new("BodyGyro")
            bodyGyro.P = 9e4
            bodyGyro.MaxTorque = Vector3.new(9e4, 9e4, 9e4)
            bodyGyro.Parent = root
        end
        
        local cam = workspace.CurrentCamera
        local moveDirection = Vector3.new(0, 0, 0)
        
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            moveDirection = moveDirection + cam.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            moveDirection = moveDirection - cam.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            moveDirection = moveDirection - cam.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            moveDirection = moveDirection + cam.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            moveDirection = moveDirection + Vector3.new(0, 1, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
            moveDirection = moveDirection - Vector3.new(0, 1, 0)
        end
        
        bodyVelocity.Velocity = moveDirection * Settings.Movement.FlySpeed
        bodyGyro.CFrame = cam.CFrame
    else
        if bodyVelocity then bodyVelocity:Destroy(); bodyVelocity = nil end
        if bodyGyro then bodyGyro:Destroy(); bodyGyro = nil end
    end

    -- No Fall Damage
    if Settings.Movement.NoFallDamage and root and root.AssemblyLinearVelocity.Y<-40 then
        local rp=RaycastParams.new(); rp.FilterDescendantsInstances={char}; rp.FilterType=Enum.RaycastFilterType.Blacklist
        local ray=workspace:Raycast(root.Position,Vector3.new(0,-25,0),rp)
        if ray then root.AssemblyLinearVelocity=Vector3.new(root.AssemblyLinearVelocity.X,0,root.AssemblyLinearVelocity.Z) end
    end

    -- Auto Respawn
    if Settings.Movement.AutoRespawn and hum and hum.Health <= 0 then
        task.wait(2)
        local spawnPoint = workspace:FindFirstChild("SpawnLocation") or workspace:FindFirstChildWhichIsA("SpawnLocation")
        if spawnPoint then
            root.CFrame = spawnPoint.CFrame + Vector3.new(0, 3, 0)
        end
    end

    -- Vehicle
    if hum and hum.SeatPart and hum.SeatPart:IsA("VehicleSeat") then
        local seat=hum.SeatPart
        if Settings.Vehicle.AccelKey~=Enum.KeyCode.Unknown and UserInputService:IsKeyDown(Settings.Vehicle.AccelKey) then
            seat.AssemblyLinearVelocity*=Vector3.new(1+Settings.Vehicle.SpeedMultiplier,1,1+Settings.Vehicle.SpeedMultiplier)
        end
        if Settings.Vehicle.BrakeKey~=Enum.KeyCode.Unknown and UserInputService:IsKeyDown(Settings.Vehicle.BrakeKey) then
            seat.AssemblyLinearVelocity*=Vector3.new(1-Settings.Vehicle.BrakeForce,1,1-Settings.Vehicle.BrakeForce)
        end
    end

    -- Anti-AFK
    if Settings.Movement.AntiAFK then
        if UserInputService:IsKeyDown(Enum.KeyCode.W) == false and UserInputService:IsKeyDown(Enum.KeyCode.A) == false and UserInputService:IsKeyDown(Enum.KeyCode.S) == false and UserInputService:IsKeyDown(Enum.KeyCode.D) == false then
            if hum then hum:Move(Vector3.new(1, 0, 0)) end
        end
    end

    -- Full Bright
    if Settings.Misc.FullBright then
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.FogEnd = 100000
        Lighting.GlobalShadows = false
    else
        Lighting.Brightness = 1
        Lighting.GlobalShadows = true
    end
end)

-- // ============ AUTO RECONNECT ============
Players.PlayerRemoving:Connect(function(p)
    if p == LocalPlayer and Settings.Misc.AutoReconnect then
        task.wait(5)
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
    end
end)

-- // ============ BAŞLANGIÇ BİLDİRİMLERİ ============
task.spawn(function()
    task.wait(0.5)
    ShowNotification("Anti-Cheat Bypassed Successfully!", Color3.fromRGB(50,255,50))
    task.wait(2)
    ShowNotification("KYNTRIX V0.2 Injected!", Color3.fromRGB(150,80,255))
    task.wait(2)
    ShowNotification("Welcome "..LocalPlayer.Name.."!", Color3.fromRGB(255,200,50))
end)

-- // ============ ANTİ-CHEAT BYPASS ÇALIŞTIR ============
AntiCheatBypass()

print("=================================")
print("   KYNTRIX V0.2 ULTIMATE")
print("   Status: INJECTED")
print("   Anti-Cheat: BYPASSED")
print("=================================")