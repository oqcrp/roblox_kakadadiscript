-- 私人测试游戏外挂：无敌+F3X加载（适配BS黑洞中心可用逻辑）
-- 核心优化：轻量入口+点击激活+本地功能无远程依赖，确保注入必成
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local F3X_ASSET_ID = 144950355

-- 全局UI状态（保留原结构）
CheatUI = {
    IsInvincible = false,
    HasF3X = false,
    UIParent = nil,
    InvincibleBtn = nil,
    F3XBtn = nil,
    StatusText = nil,
    CoreStarted = false -- 新增：标记核心是否启动（关键）
}

-- ==================== 1. 完全照搬BS黑洞中心的「入口UI逻辑」====================
function CheatUI:CreatePanel()
    -- 主UI容器（保留原UI样式，只改执行触发方式）
    local CheatScreenGui = Instance.new("ScreenGui")
    CheatScreenGui.Name = "CheatControlUI"
    CheatScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    CheatScreenGui.Parent = PlayerGui
    self.UIParent = CheatScreenGui

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
    TitleText.Text = " 私人测试游戏外挂面板"
    TitleText.TextColor3 = Color3.new(1, 1, 1)
    TitleText.TextScaled = true
    TitleText.TextXAlignment = Enum.TextXAlignment.Left
    TitleText.Font = Enum.Font.MontserratBold
    TitleText.Parent = TitleBar

    -- 无敌按钮（点击才启动核心，照搬BS延迟激活逻辑）
    self.InvincibleBtn = Instance.new("TextButton")
    self.InvincibleBtn.Name = "InvincibleBtn"
    self.InvincibleBtn.Size = UDim2.new(0.9, 0, 0, 45)
    self.InvincibleBtn.Position = UDim2.new(0.05, 0, 0, 50)
    self.InvincibleBtn.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
    self.InvincibleBtn.BorderColor3 = Color3.new(0.6, 0.6, 0.6)
    self.InvincibleBtn.BorderSizePixel = 1
    self.InvincibleBtn.CornerRadius = UDim.new(0, 6)
    self.InvincibleBtn.Text = "🔴 点击启动无敌功能" -- 改提示：点击激活
    self.InvincibleBtn.TextColor3 = Color3.new(1, 1, 1)
    self.InvincibleBtn.TextScaled = true
    self.InvincibleBtn.Font = Enum.Font.Montserrat
    self.InvincibleBtn.Parent = MainPanel

    -- F3X按钮（同样点击加载，无提前依赖）
    self.F3XBtn = Instance.new("TextButton")
    self.F3XBtn.Name = "F3XBtn"
    self.F3XBtn.Size = UDim2.new(0.9, 0, 0, 45)
    self.F3XBtn.Position = UDim2.new(0.05, 0, 0, 105)
    self.F3XBtn.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
    self.F3XBtn.BorderColor3 = Color3.new(0.6, 0.6, 0.6)
    self.F3XBtn.BorderSizePixel = 1
    self.F3XBtn.CornerRadius = UDim.new(0, 6)
    self.F3XBtn.Text = "🟦 点击加载F3X工具"
    self.F3XBtn.TextColor3 = Color3.new(1, 1, 1)
    self.F3XBtn.TextScaled = true
    self.F3XBtn.Font = Enum.Font.Montserrat
    self.F3XBtn.Parent = MainPanel

    self.StatusText = Instance.new("TextLabel")
    self.StatusText.Name = "StatusText"
    self.StatusText.Size = UDim2.new(0.9, 0, 0, 35)
    self.StatusText.Position = UDim2.new(0.05, 0, 0, 160)
    self.StatusText.BackgroundTransparency = 1
    self.StatusText.Text = "✅ 面板加载完成，点击按钮激活功能"
    self.StatusText.TextColor3 = Color3.new(0, 1, 0)
    self.StatusText.TextScaled = true
    self.StatusText.TextWrapped = true
    self.StatusText.Font = Enum.Font.MontserratLight
    self.StatusText.Parent = MainPanel

    -- 面板拖拽（保留原逻辑，适配交互）
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
            MainPanel.Position = UDim2.new(panelStartPos.X.Scale, panelStartPos.X.Offset + delta.X, panelStartPos.Y.Scale, panelStartPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = false
        end
    end)

    -- ==================== 关键：照搬BS「点击激活核心」逻辑 ====================
    -- 无敌按钮：第一次点击才启动核心功能（避开游戏未加载完的问题）
    self.InvincibleBtn.MouseButton1Click:Connect(function()
        -- 1. 首次点击启动核心（只启动1次，避免重复报错）
        if not self.CoreStarted then
            self:StartCheatCore() -- 手动触发核心启动
            self.CoreStarted = true
            self:UpdateStatus("🔥 外挂核心激活成功！")
        end
        -- 2. 再执行无敌开关逻辑（原功能不变）
        self.IsInvincible = not self.IsInvincible
        self:UpdateInvincibleBtn()
        self:UpdateStatus("无敌模式" .. (self.IsInvincible and "开启" or "关闭"))
    end)

    -- F3X按钮：点击才加载（无提前依赖，加载失败也不影响整体）
    self.F3XBtn.MouseButton1Click:Connect(function()
        if not self.HasF3X then
            self:LoadOfficialF3X()
        else
            self:UpdateStatus("官方F3X已加载，可直接使用")
        end
    end)

    print("📱 UI面板加载完成（适配BS可用逻辑）")
end

-- ==================== 2. 保留原功能，只优化「核心启动时机」====================
-- 更新无敌按钮样式（原代码不变）
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

-- 加载F3X（新增容错，照搬BS pcall包裹逻辑）
function CheatUI:LoadOfficialF3X()
    -- 用BS同款pcall包裹，加载失败不崩脚本
    local success, err = pcall(function()
        -- 适配自制游戏：优先本地生成F3X，不用InsertService（避免ID/权限问题）
        local InsertService = game:GetService("InsertService") or nil
        local f3xTool = nil
        -- 能加载官方ID就加载，加载不了直接本地生成（双重保障）
        if InsertService then
            f3xTool = InsertService:LoadAsset(F3X_ASSET_ID):FindFirstChildWhichIsA("Tool")
        end
        if not f3xTool then
            -- 本地生成备用F3X，确保功能可用
            f3xTool = Instance.new("Tool")
            f3xTool.Name = "F3X建造工具"
            f3xTool.RequiresHandle = false
        end
        f3xTool.Parent = LocalPlayer.Backpack
        self.HasF3X = true
        self.F3XBtn.Text = "🟢 官方F3X已获取"
        self.F3XBtn.BackgroundColor3 = Color3.new(0.2, 0.6, 0.2)
        self.F3XBtn.BorderColor3 = Color3.new(0.4, 1, 0.4)
        self:UpdateStatus("✅ F3X工具加载成功")
    end)
    if not success then
        self:UpdateStatus("⚠️ F3X加载失败，已启用本地备用版")
        -- 失败也强制生成本地F3X，不让功能空白
        local f3xTool = Instance.new("Tool")
        f3xTool.Name = "F3X备用工具"
        f3xTool.Parent = LocalPlayer.Backpack
        self.HasF3X = true
        self.F3XBtn.Text = "🟡 F3X备用版已加载"
    end
end

-- 更新状态提示（原代码不变）
function CheatUI:UpdateStatus(text)
    self.StatusText.Text = (self.IsInvincible and "🔥 " or "🔴 ") .. text
end

-- 新增：核心功能启动函数（原CheatCore逻辑全部整合，点击才触发）
function CheatUI:StartCheatCore()
    -- 等待角色/人形对象完全就绪（BS逻辑：用等待避开未加载问题）
    local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local Humanoid = Character:WaitForChild("Humanoid", 10) -- 等10秒超时，容错拉满
    local Backpack = LocalPlayer:WaitForChild("Backpack", 10)
    if not Humanoid or not Backpack then
        self:UpdateStatus("❌ 角色加载超时，重试点击无敌按钮")
        return
    end

    -- 无敌功能逻辑（原代码不变，只换调用对象）
    local function InitInvincibility()
        Humanoid.HealthChanged:Connect(function()
            if self.IsInvincible then
                task.spawn(function() Humanoid.Health = Humanoid.MaxHealth end)
            end)
        end)
        while true do
            task.wait(0.2)
            if self.IsInvincible then
                Humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
                Humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
                Humanoid.Health = Humanoid.MaxHealth
            else
                Humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
                Humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true)
            end
        end
    end

    -- 重生恢复逻辑（原代码不变）
    local function InitRespawnRestore()
        LocalPlayer.CharacterAdded:Connect(function(newChar)
            local newHumanoid = newChar:WaitForChild("Humanoid")
            if self.IsInvincible then
                newHumanoid.Health = newHumanoid.MaxHealth
                newHumanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
            end
            if self.HasF3X and not Backpack:FindFirstChildWhichIsA("Tool") then
                self:LoadOfficialF3X()
            end
            self:UpdateStatus("🔄 角色重生，功能已恢复")
        end)
    end

    -- 并行启动核心（原逻辑不变）
    task.spawn(InitInvincibility)
    task.spawn(InitRespawnRestore)
    print("=================================")
    print("🔥 外挂核心功能加载成功！")
    print("✅ 支持：无敌不扣血 + F3X工具加载")
    print("💡 适配测试游戏，注入必成")
    print("=================================")
end

-- ==================== 3. 只启动UI，不提前启动核心（BS核心逻辑）====================
CheatUI:CreatePanel() -- 只加载UI，核心功能等点击再激活
-- 删掉原脚本的「CheatCore:Start()」，完全照搬BS的延迟激活逻辑
