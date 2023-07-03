--! AUTO REBIRTH AND AUTO BUY SPEED WILL BE HAULTED UNTIL THE WINDOW IS FOCUSED.

AutoRebirth = AutoRebirth or true;
AutoBuySpeed = AutoBuySpeed or true;

local Players = game:GetService("Players");
local Player = Players.LocalPlayer;

local CoinsVip = workspace.Vip_COINS.Coins;
local CoinsSpawn = workspace.Map_COINS;
local CoinsMap = workspace.CoinFolder.Coins;
local Mines = workspace.Mines;
local RebirthCostTextLabel = (function()
	for Int, Value in pairs(Player.PlayerGui.Purchases_Frames.Rebirth_FRRAME:GetChildren()) do
		if Value.ClassName == "TextLabel" and Value:FindFirstChild("TextLabel") ~= nil then
			return Value.TextLabel;
		end;
	end;
end)();

local function Animate(Parent, Time, Style, Direction, Animation)
	game:GetService("TweenService"):Create(Parent, TweenInfo.new(Time, Style, Direction, 0, false, 0), Animation):Play();
end;
local function CaptureCoins(Parent, AddChildAddedConnection)
	for Int, Coin in pairs(Parent:GetChildren())do
		Coin.CFrame = Player.Character.HumanoidRootPart.CFrame;
	end;
	if AddChildAddedConnection == true then
		Parent.ChildAdded:Connect(function(Coin)
			wait();
			Coin.CFrame = Player.Character.HumanoidRootPart.CFrame;
		end);
	end;
end;
local function WaitForPlayersCharacter()
	local Time, TimeWithHumanoid = 0, 0;
	while wait() do
		Time += 0.0303051000000778;
		TimeWithHumanoid += 0.0303051000000778;
		if Player.Character == nil or Player.Character:FindFirstChild("Humanoid") == nil or Player.Character.Humanoid.Health <= 0 then
			TimeWithHumanoid = 0;
		end;
		if TimeWithHumanoid >= 5 then
			break;
		end;
		if Time >= 12 then
			if Player.Character ~= nil and Player.Character:FindFirstChild("Humanoid") ~= nil then
				break;
			end;
		end;
	end;
end;

CaptureCoins(CoinsVip, true);
CaptureCoins(CoinsSpawn, true);
CaptureCoins(CoinsMap, true);

for Int, Mine in pairs(workspace.Mines:GetChildren())do Mine:Remove()end;
workspace.Mines.ChildAdded:Connect(function(Mine)wait()Mine:Remove()end);

Player.Idled:Connect(function()
	game:GetService("VirtualUser"):CaptureController();
	game:GetService("VirtualUser"):ClickButton2(Vector2.new());
end);

Player.PlayerGui.MainGui.Enabled = false;
Player.PlayerGui.TrollGui.Enabled = false;
Player.PlayerGui.AllStats.Frame.Visible = false;

coroutine.resume(coroutine.create(function()
	while wait() do
		if iswindowactive() == true then
			if AutoBuySpeed == true or AutoRebirth == true then
				if Player.CoinsFolder.Coins.Value >= tonumber(string.match(Player.PlayerGui.Purchases_Frames.Speed_FRAME.CostGUI.TextLabel.ContentText, "Cost:%s+(%d+)%s+Coins")) then
					Player.PlayerGui.Purchases_Frames.Speed_FRAME.Visible = true;
					Player.PlayerGui.Purchases_Frames.Speed_FRAME.Position = UDim2.new(0.498, 0, 0.5, 0);
					Player.PlayerGui.Purchases_Frames.Speed_FRAME.Frame.TextButton.Size = UDim2.new(5, 0, 20, 0);
					wait(0.05);
					repeat
						mouse1click();
						game:GetService("RunService").Heartbeat:Wait();
						if Player.leaderstats.SM.Value >= tonumber(string.match(RebirthCostTextLabel.ContentText, "Cost:%s+(%d+)%s+SM")) then
							break;
						end;
					until Player.CoinsFolder.Coins.Value < tonumber(string.match(Player.PlayerGui.Purchases_Frames.Speed_FRAME.CostGUI.TextLabel.ContentText, "Cost:%s+(%d+)%s+Coins"));
					wait(0.05);
					Player.PlayerGui.Purchases_Frames.Speed_FRAME.Position = UDim2.new(0.498, 0, 2, 0);
					Player.PlayerGui.Purchases_Frames.Speed_FRAME.Frame.TextButton.Size = UDim2.new(1.001, 0, 0.38, 0);
				end;
			end;
			if AutoRebirth == true then
				if Player.leaderstats.SM.Value >= tonumber(string.match(RebirthCostTextLabel.ContentText, "Cost:%s+(%d+)%s+SM")) then
					Player.PlayerGui.Purchases_Frames.Rebirth_FRRAME.Visible = true;
					Player.PlayerGui.Purchases_Frames.Rebirth_FRRAME.Position = UDim2.new(0.498, 0, 0.5, 0);
					Player.PlayerGui.Purchases_Frames.Rebirth_FRRAME.Frame.TextButton.Size = UDim2.new(5, 0, 20, 0);
					wait(0.05);
					mouse1click();
					wait(0.05);
					Player.PlayerGui.Purchases_Frames.Rebirth_FRRAME.Position = UDim2.new(0.498, 0, 2, 0);
					Player.PlayerGui.Purchases_Frames.Rebirth_FRRAME.Frame.TextButton.Size = UDim2.new(1.001, 0, 0.38, 0);
				end;
			end;
		end;
	end;
end));
coroutine.resume(coroutine.create(function()
	while true do
		WaitForPlayersCharacter();
		Animate(Player.Character.HumanoidRootPart, 0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, {
			CFrame = CFrame.new(workspace:FindFirstChild("Start").Position+Vector3.new(-1, 3, 0)),
		});
		wait(1.5);
		Animate(Player.Character.HumanoidRootPart, 1, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, {
			CFrame = CFrame.new(Vector3.new(-99999999999, Player.Character.HumanoidRootPart.Position.Y, Player.Character.HumanoidRootPart.Position.Z)),
		});
		wait(1);
		Player.Character.Humanoid.Health = 0;
		WaitForPlayersCharacter();
		CaptureCoins(CoinsVip, false);
		CaptureCoins(CoinsSpawn, false);
		CaptureCoins(CoinsMap, false);
	end;
end));
