local Players = game:GetService("Players")
local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")

-- Destroy old GUI
if PlayerGui:FindFirstChild("CerealStrictFarmGUI") then
	PlayerGui.CerealStrictFarmGUI:Destroy()
end

-- GUI Setup
local gui = Instance.new("ScreenGui", PlayerGui)
gui.Name = "CerealStrictFarmGUI"
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 220, 0, 170)
frame.Position = UDim2.new(0, 20, 0.5, -85)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true

Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

local toggleBtn = Instance.new("TextButton", frame)
toggleBtn.Size = UDim2.new(1, -20, 0, 40)
toggleBtn.Position = UDim2.new(0, 10, 0, 10)
toggleBtn.Text = "Start Strict Farm"
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
toggleBtn.Font = Enum.Font.Gotham
toggleBtn.TextSize = 16

local washBtn = Instance.new("TextButton", frame)
washBtn.Size = UDim2.new(1, -20, 0, 40)
washBtn.Position = UDim2.new(0, 10, 0, 60)
washBtn.Text = "Wash Dirty Cash"
washBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
washBtn.BackgroundColor3 = Color3.fromRGB(30, 60, 30)
washBtn.Font = Enum.Font.Gotham
washBtn.TextSize = 16

local unloadBtn = Instance.new("TextButton", frame)
unloadBtn.Size = UDim2.new(1, -20, 0, 40)
unloadBtn.Position = UDim2.new(0, 10, 0, 110)
unloadBtn.Text = "Unload GUI"
unloadBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
unloadBtn.BackgroundColor3 = Color3.fromRGB(60, 20, 20)
unloadBtn.Font = Enum.Font.Gotham
unloadBtn.TextSize = 16

-- Utilities
local function teleportTo(pos)
	local char = player.Character or player.CharacterAdded:Wait()
	local root = char:WaitForChild("HumanoidRootPart")
	root.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
end

local function firePrompt(prompt, times)
	for _ = 1, (times or 1) do
		if prompt and prompt.Enabled then
			fireproximityprompt(prompt)
			task.wait(0.1)
		end
	end
end

local function countMix()
	local backpack = player:FindFirstChild("Backpack")
	local char = player.Character
	local count = 0
	for _, t in ipairs(backpack:GetChildren()) do if t.Name == "ChocolateMix" then count += 1 end end
	for _, t in ipairs(char:GetChildren()) do if t.Name == "ChocolateMix" then count += 1 end end
	return count
end

local function equipMix()
	local char = player.Character
	local backpack = player:FindFirstChild("Backpack")
	local tool
	if char then tool = char:FindFirstChild("ChocolateMix") end
	if not tool and backpack then
		tool = backpack:FindFirstChild("ChocolateMix")
		if tool then tool.Parent = char end
	end
	return tool
end

local function sellCereal()
	local buyer = workspace:FindFirstChild("ChocolateBuyer")
	if buyer and buyer:FindFirstChild("UpperTorso") then
		local prompt = buyer.UpperTorso:FindFirstChild("Attachment") and buyer.UpperTorso.Attachment:FindFirstChild("ProximityPrompt")
		if prompt then
			teleportTo(buyer.HumanoidRootPart.Position)
			task.wait(0.3)
			for _ = 1, 8 do
				firePrompt(prompt, 1)
				task.wait(0.2)
			end
		end
	end
end

-- Autofarm Logic
local farming = false
local function startFarm()
	farming = true
	toggleBtn.Text = "Stop Strict Farm"

	task.spawn(function()
		while farming do
			-- Step 1: TP once to buy mixes
			local buyPos = Vector3.new(-199, 426, 1657)
			teleportTo(buyPos)
			task.wait(0.5)
			local prompt = workspace.ChocolateMixShowcase.Pillow.Attachment:FindFirstChild("ProximityPrompt")
			if prompt then
				local attempts = 0
				while countMix() < 8 and attempts < 20 and farming do
					firePrompt(prompt, 2)
					task.wait(0.3)
					attempts += 1
				end
			end
			if not farming then break end

			-- Step 2: TP once to cooking pot, cook all 8
			local cookPos = Vector3.new(-742, 304, 167)
			teleportTo(cookPos)
			task.wait(0.5)
			local ovenPrompt = workspace:FindFirstChild("OvenOnePrompt")
			if ovenPrompt and ovenPrompt:FindFirstChild("ProximityPrompt") then
				local prompt = ovenPrompt.ProximityPrompt
				for i = 1, 8 do
					if not farming then break end
					equipMix()
					firePrompt(prompt, 1)
					task.wait(10.5)
				end
			end

			if not farming then break end

			-- Step 3: Sell
			sellCereal()
			task.wait(1)
		end
		toggleBtn.Text = "Start Strict Farm"
	end)
end

local function stopFarm()
	farming = false
	toggleBtn.Text = "Start Strict Farm"
end

-- Button Events
toggleBtn.MouseButton1Click:Connect(function()
	if farming then stopFarm() else startFarm() end
end)

unloadBtn.MouseButton1Click:Connect(function()
	farming = false
	gui:Destroy()
end)

washBtn.MouseButton1Click:Connect(function()
	local pos = Vector3.new(592, 376, 1205)
	teleportTo(pos)
	task.wait(0.5)
	local laundering = workspace:FindFirstChild("TacoMoneyLaundering")
	if laundering and laundering:FindFirstChild("Attachment") then
		local prompt = laundering.Attachment:FindFirstChild("ProximityPrompt")
		if prompt then firePrompt(prompt, 1) end
	end
end)
