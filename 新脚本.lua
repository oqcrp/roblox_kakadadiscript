-- 私人游戏外挂：无敌不扣血+一键获取官方F3X（适配已购买插件，支持loadstring加载）
-- 原UI布局不变，F3X按钮改为调用官方插件，忍者注入器Delta专用

-- ================================= 第一部分：UI界面代码（优先加载）=================================
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local InsertService = game:GetService("InsertService") -- 新增：用于加载官方插件
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- 官方F3X插件Asset ID（从你提供的链接提取：144950355）
local F3X_ASSET_ID = 144950355

-- 全局UI状态（给核心脚本传值）
CheatUI = {
    IsInvincible = false,
    IsF3XEnabled = false,
    UIParent = nil,
    InvincibleBtn = nil,
    F3XBtn = nil,
    StatusText = nil,
    HasF3X = false -- 新增：标记是否已加载官方F3X
}

-- 生成悬浮控制面板
function CheatUI:CreatePanel()
    -- 主UI容器
    local CheatScreenGui = Instance.new("ScreenGui")
    CheatScreenGui.Name = "CheatControlUI"
    CheatScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    CheatScreenGui.Parent = PlayerGui
    self.UIParent = CheatScreenGui

    -- 悬浮面板主体
    local MainPanel = Instance.new("Frame")
    MainPanel.Name = "MainPanel"
    MainPanel.Size = UDim2.new(0, 300, 0, 200)
    MainPanel.Position = UDim2.new(0.05, 0, 0.1, 0)
    MainPanel.BackgroundColor3 = Color3.new(0.08, 0.08, 0.08)
    MainPanel.BackgroundTransparency = 0.2
    MainPanel.BorderColor3 = Color3.new(0.4, 0.8, 1)
    MainPanel.BorderSizePixel = 2
    MainPanel.CornerRadius = UDim.new(0, 10)
    MainPanel.Parent = CheatScreenGui

    -- 标题栏（拖拽区域）
    local TitleBar = Instance.new("Frame")
    TitleBar.Name = "TitleBar"
    TitleBar.Size = UDim2.new(1, 0, 0, 40)
    TitleBar.BackgroundColor3 = Color3.new(0.2, 0.5, 0.8)
    TitleBar.CornerRadius = UDim.new(0, 8)
    TitleBar.Parent = MainPanel

    local TitleText = Instance.new("TextLabel")
    TitleText.Name = "TitleText"
    TitleText.Size = UDim2.new(1, 0, 1, 0)
    TitleText.BackgroundTransparency = 1
    TitleText.Text = " 私人游戏外挂控制面板"
    TitleText.TextColor3 = Color3.new(1, 1, 1)
    TitleText.TextScaled = true
    TitleText.TextXAlignment = Enum.TextXAlignment.Left
    TitleText.Font = Enum.Font.MontserratBold
    TitleText.Parent = TitleBar

    -- 无敌开关按钮
    self.InvincibleBtn = Instance.new("TextButton")
    self.InvincibleBtn.Name = "InvincibleBtn"
    self.InvincibleBtn.Size = UDim2.new(0.9, 0, 0, 45)
    self.InvincibleBtn.Position = UDim2.new(0.05, 0, 0, 50)
    self.InvincibleBtn.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
    self.InvincibleBtn.BorderColor3 = Color3.new(0.6, 0.6, 0.6)
    self.InvincibleBtn.BorderSizePixel = 1
    self.InvincibleBtn.CornerRadius = UDim.new(0, 6)
    self.InvincibleBtn.Text = "🔴 无敌模式 [未开启]"
    self.InvincibleBtn.TextColor3 = Color3.new(1, 1, 1)
    self.InvincibleBtn.TextScaled = true
    self.InvincibleBtn.Font = Enum.Font.Montserrat
    self.InvincibleBtn.Parent = MainPanel

    -- F3X开关按钮（改为调用官方插件）
    self.F3XBtn = Instance.new("TextButton")
    self.F3XBtn.Name = "F3XBtn"
    self.F3XBtn.Size = UDim2.new(0.9, 0, 0, 45)
    self.F3XBtn.Position = UDim2.new(0.05, 0, 0, 105)
    self.F3XBtn.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
    self.F3XBtn.BorderColor3 = Color3.new(0.6, 0.6, 0.6)
    self.F3XBtn.BorderSizePixel = 1
    self.F3XBtn.CornerRadius = UDim.new(0, 6)
    self.F3XBtn.Text = "🟦 获取官方F3X插件"
    self.F3XBtn.TextColor3 = Color3.new(1, 1, 1)
    self.F3XBtn.TextScaled = true
    self.F3XBtn.Font = Enum.Font.Montserrat
    self.F3XBtn.Parent = MainPanel

    -- 状态提示框
    self.StatusText = Instance.new("TextLabel")
    self.StatusText.Name = "StatusText"
    self.StatusText.Size = UDim2.new(0.9, 0, 0, 35)
    self.StatusText.Position = UDim2.new(0.05, 0, 0, 160)
    self.StatusText.BackgroundTransparency = 1
    self.StatusText.Text = "✅ 外挂加载完成，点击按钮获取官方F3X"
    self.StatusText.TextColor3 = Color3.new(0, 1, 0)
    self.StatusText.TextScaled = true
    self.StatusText.TextWrapped = true
    self.StatusText.Font = Enum.Font.MontserratLight
    self.StatusText.Parent = MainPanel

    -- 面板拖拽逻辑
    local isDragging = false
    local dragStartPos = Vector2.new()
    local panelStartPos = MainPanel.Position

    TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = true
            dragStartPos = input.Position
            panelStartPos = MainPanel.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStartPos
            MainPanel.Position = UDim2.new(
                panelStartPos.X.Scale, panelStartPos.X.Offset + delta.X,
                panelStartPos.Y.Scale, panelStartPos.Y.Offset + delta.Y
            )
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = false
        end
    end)

    -- 开关点击事件
    self.InvincibleBtn.MouseButton1Click:Connect(function()
        self.IsInvincible = not self.IsInvincible
        self:UpdateInvincibleBtn()
        self:UpdateStatus("无敌模式" .. (self.IsInvincible and "开启" or "关闭"))
    end)

    -- 新增：F3X按钮改为调用官方插件的事件
    self.F3XBtn.MouseButton1Click:Connect(function()
        if not self.HasF3X then
            self:LoadOfficialF3X()
        else
            self:UpdateStatus("官方F3X已加载，可直接使用")
        end
    end)

    print("📱 UI面板加载完成，可拖拽移动")
end

-- 更新无敌按钮样式
function CheatUI:UpdateInvincibleBtn()
    if self.IsInvincible then
        self.InvincibleBtn.Text = "🟢 无敌模式 [已开启]"
        self.InvincibleBtn.BackgroundColor3 = Color3.new(0.2, 0.6, 0.2)
        self.InvincibleBtn.BorderColor3 = Color3.new(0.4, 1, 0.4)
    else
        self.InvincibleBtn.Text = "🔴 无敌模式 [未开启]"
        self.InvincibleBtn.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
        self.InvincibleBtn.BorderColor3 = Color3.new(0.6, 0.6, 0.6)
    end
end

-- 新增：加载官方F3X插件的函数
function CheatUI:LoadOfficialF3X()
    local success, err = pcall(function()
        -- 加载官方F3X插件到玩家背包
        local f3xTool = InsertService:LoadAsset(F3X_ASSET_ID):FindFirstChildWhichIsA("Tool")
        if f3xTool then
            f3xTool.Parent = LocalPlayer.Backpack
            self.HasF3X = true
            self.F3XBtn.Text = "🟢 官方F3X已获取"
            self.F3XBtn.BackgroundColor3 = Color3.new(0.2, 0.6, 0.2)
            self.F3XBtn.BorderColor3 = Color3.new(0.4, 1, 0.4)
            self:UpdateStatus("✅ 官方F3X插件加载成功，背包可查看")
        else
            self:UpdateStatus("❌ 加载失败：未找到F3X工具")
        end
    end)
    if not success then
        self:UpdateStatus("❌ 加载出错：" .. err)
    end
end

-- 更新状态提示
function CheatUI:UpdateStatus(text)
    self.StatusText.Text = (self.IsInvincible and "🔥 " or "🔴 ") .. text
end

-- 初始化UI
CheatUI:CreatePanel()

-- ================================= 第二部分：核心功能代码（还原启动核心+无敌+重生）=================================
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local Backpack = LocalPlayer:WaitForChild("Backpack")

-- 等待UI加载完成
repeat task.wait(0.1) until CheatUI ~= nil
local UI = CheatUI

-- 核心状态（保留原结构，适配官方F3X）
local CheatCore = {
    HasLoadedF3X = false,
    Character = Character,
    Humanoid = Humanoid
}

-- 无敌功能逻辑（优化稳定性，还原原逻辑框架）
function CheatCore:InitInvincibility()
    -- 拦截血量变化（实时补满）
    self.Humanoid.HealthChanged:Connect(function()
        if UI.IsInvincible then
            task.spawn(function()
                self.Humanoid.Health = self.Humanoid.MaxHealth
            end)
        end)
    end)

    -- 循环维持无敌状态
    while true do
        task.wait(0.2)
        if UI.IsInvincible then
            self.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
            self.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
            self.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Stunned, false)
            self.Humanoid.Health = self.Humanoid.MaxHealth -- 双重保障，防止漏补
        else
            self.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
            self.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true)
            self.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Stunned, true)
        end
    end
end

-- 重生恢复功能（还原原逻辑，适配官方F3X）
function CheatCore:InitRespawnRestore()
    LocalPlayer.CharacterAdded:Connect(function(newChar)
        self.Character = newChar
        self.Humanoid = newChar:WaitForChild("Humanoid")
        
        -- 重生后恢复无敌状态
        if UI.IsInvincible then
            self.Humanoid.Health = self.Humanoid.MaxHealth
            self.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
        end
        
        -- 重生后自动恢复官方F3X（如果已加载过）
        if UI.HasF3X and not Backpack:FindFirstChildWhichIsA("Tool", true) then
            UI:LoadOfficialF3X()
        end

        UI:UpdateStatus("角色重生，功能已自动恢复")
        warn("🔄 角色重生，外挂功能正常运行")
    end)
end

-- 启动核心功能（完全还原原启动逻辑，结构不变）
function CheatCore:Start()
    -- 并行启动所有核心功能
    task.spawn(self.InitInvincibility, self)
    task.spawn(self.InitRespawnRestore, self)

    -- 启动成功提示（保留原格式）
    print("=================================")
    print("🔥 外挂核心功能加载成功！")
    print("✅ 支持：无敌不扣血 + 一键获取官方F3X")
    print("👥 官方F3X天然支持多人同步，操作全服可见")
    print("💡 点击F3X按钮即可加载官方建造工具")
    print("=================================")
end

-- 启动核心（关键步骤，完全还原，确保功能激活）
CheatCore:Start()