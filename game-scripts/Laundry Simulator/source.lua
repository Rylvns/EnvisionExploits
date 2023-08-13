local Virtual = game:GetService("VirtualUser");
local Players = game:GetService("Players");
local Player = Players.LocalPlayer;

local ReplicatedStorage = game:GetService("ReplicatedStorage");

local Plot = Player.NonSaveVars.OwnsPlot.Value;
local MainSignal = nil;
local Configuration = {
	["CanGrab"] = {
		["Normal"] = false,
		["Silver"] = true,
		["Gold"] = true,
		["Emerald"] = true,
		["Ruby"] = true,
		["Sapphire"] = true,
	},
	["Autofarm"] = {
		["TrueAutoFarm"] = false,
		["Grabbing"] = false,
	},
};

Player.Idled:Connect(function()
	Virtual:CaptureController();
	Virtual:ClickButton2(Vector2.new());
end);

local Library = loadstring(game:HttpGet("https://pastebin.com/raw/Bp4irPC6"))()("Laundry Simulator", Enum.KeyCode.Delete, {}, function()
	Configuration.Autofarm.TrueAutoFarm = false;
	Configuration.Autofarm.Grabbing = false;
	MainSignal:Disconnect();
end);

if Plot == nil then
	repeat
		task.wait(1);
		Library:ShowNotification("warning", "Please claim a plot.", 1, nil);
	until Player.NonSaveVars.OwnsPlot.Value ~= nil;
	Plot = Player.NonSaveVars.OwnsPlot.Value;
end

function Or(Variable, ...)
	for Int, Value in pairs({...}) do
		if Variable == Value then
			return true;
		end;
	end;
	return false;
end;
function FindFirstChild(Parent, Name)
	for Int, Value in pairs(Parent:GetChildren()) do
		if Value.Name == Name then
			return Value;
		end;
	end;
	return nil;
end;
function GetClothTag(Cloth)
	if FindFirstChild(Cloth, "SpecialTag") == nil then
		local Time = 0;
		while FindFirstChild(Cloth, "SpecialTag") ~= nil do
			Time += task.wait();
			if Time >= 5 then
				return "Normal";
			end;
		end;
	else
		return Cloth:WaitForChild("SpecialTag").Value;
	end;
end;
function GrabClothing(Cloth)
	if Or(GetClothTag(Cloth), table.unpack((function()
			local List = {};
			for Tag, Value in pairs(Configuration.CanGrab) do
				if Value == true then
					table.insert(List, Tag);
				end;
			end;
			return List;
		end)())) == true then
		local LastCFrame = Player.Character.HumanoidRootPart.CFrame;
		Player.Character.HumanoidRootPart.CFrame = CFrame.new(Cloth.CFrame.Position+Vector3.new(0, 2, 0));
		delay(0.1, function()
			ReplicatedStorage.Events.GrabClothing:FireServer(Cloth);
			delay(0.1, function()
				Player.Character.HumanoidRootPart.CFrame = LastCFrame;
			end);
		end);
	end;
end;
function LoadWashingMachines()
	for Int, Machine in pairs(Plot.WashingMachines:GetChildren()) do
		if Machine.Config.Started.Value == false and Machine.Config.InsertingClothes.Value == false and Machine.Config.DoorMoving.Value == false and Machine.Config.CycleFinished.Value == false then
			Player.Character.HumanoidRootPart.CFrame = Machine.MAIN.CFrame;
			delay(0.1, function()
				ReplicatedStorage.Events.LoadWashingMachine:FireServer(Machine);
			end);
			task.wait(0.2);
			if Player.NonSaveVars.BackpackAmount.Value == 0 then
				break;
			end;
		end;
	end;
end;
function UnloadWashingMachines()
	for Int, Machine in pairs(Plot.WashingMachines:GetChildren()) do
		if Machine.Config.CycleFinished.Value == true then
			Player.Character.HumanoidRootPart.CFrame = Machine.MAIN.CFrame;
			delay(0.1, function()
				ReplicatedStorage.Events.UnloadWashingMachine:FireServer(Machine);
			end);
			task.wait(0.2);
			if Player.NonSaveVars.BackpackAmount.Value == Player.NonSaveVars.BasketSize.Value then
				break;
			end;
		end;
	end;
end;

local TabAutofarm = Library:AddTab("Autofarm");
TabAutofarm:AddToggle("True autofarm", "Runs through all the checks and functions for a full afk session.", "", Configuration.Autofarm.TrueAutoFarm, function(Value)
	Configuration.Autofarm.TrueAutoFarm = Value;
	while Configuration.Autofarm.TrueAutoFarm == true do
		if #workspace.Debris.Clothing:GetChildren() > 0 then
			if Player.NonSaveVars.BackpackAmount.Value == 0 or Player.NonSaveVars.BasketStatus.Value == "Dirty" then
				if Or(Player.NonSaveVars.BackpackAmount.Value, Player.NonSaveVars.BasketSize.Value, Player.NonSaveVars.TotalWashingMachineCapacity.Value) == true then
					if Player.NonSaveVars.BasketStatus.Value == "Dirty" then
						LoadWashingMachines();
					end;
					UnloadWashingMachines();
					Player.Character.HumanoidRootPart.CFrame = workspace["_FinishChute"].Entrance.CFrame;
					task.wait(0.2);
					ReplicatedStorage.Events.DropClothesInChute:FireServer();
					task.wait(0.1);
				else
					for Int, Cloth in pairs(workspace.Debris.Clothing:GetChildren()) do
						if Cloth.Name ~= "Magnet" then
							local LastBackpackCount = Player.NonSaveVars.BackpackAmount.Value;
							local Time = 0;
							repeat
								Player.Character.HumanoidRootPart.CFrame = CFrame.new(Cloth.CFrame.Position+Vector3.new(0, 2, 0));
								Time += task.wait(0.1);
								ReplicatedStorage.Events.GrabClothing:FireServer(Cloth);
								if Time > 1 then
									LoadWashingMachines();
									break;
								end;
							until Cloth == nil or LastBackpackCount+1 == Player.NonSaveVars.BackpackAmount.Value;
							break;
						end;
					end;
				end;
			elseif Player.NonSaveVars.BackpackAmount.Value > 0 and Player.NonSaveVars.BasketStatus.Value == "Clean" then
				UnloadWashingMachines();
				Player.Character.HumanoidRootPart.CFrame = workspace["_FinishChute"].Entrance.CFrame;
				task.wait(0.2);
				ReplicatedStorage.Events.DropClothesInChute:FireServer();
				task.wait(0.1);
			end;
		end;
		task.wait();
	end;
end);
TabAutofarm:AddToggle("Auto grab open clothes", "Automatically grabs clothes depending on the selected configs.", "", Configuration.Autofarm.Grabbing, function(Value)
	Configuration.Autofarm.Grabbing = Value;
end);
TabAutofarm:AddButton("Grab open clothes", "Grabs all clothes currently on the conveyer with selected configs.", "", function()
	for Int, Cloth in pairs(workspace.Debris.Clothing:GetChildren()) do
		if Player.NonSaveVars.BasketStatus.Value == "Clean" or Or(Player.NonSaveVars.BackpackAmount.Value, Player.NonSaveVars.BasketSize.Value, Player.NonSaveVars.TotalWashingMachineCapacity.Value) == true then
			break;
		end;
		GrabClothing(Cloth);
	end;
end);
TabAutofarm:AddSeperator();
TabAutofarm:AddLabel("Settings for: 'Auto grab open clothes' & 'Grab open clothes'");
TabAutofarm:AddToggle("Grab silver clothes", "Automatically grab silver clothes when they appear.", "", Configuration.CanGrab.Silver, function(Value)Configuration.CanGrab.Silver = Value end);
TabAutofarm:AddToggle("Grab gold clothes", "Automatically grab gold clothes when they appear.", "", Configuration.CanGrab.Gold, function(Value)Configuration.CanGrab.Gold = Value end);
TabAutofarm:AddToggle("Grab emerald clothes", "Automatically grab emerald clothes when they appear.", "", Configuration.CanGrab.Emerald, function(Value)Configuration.CanGrab.Emerald = Value end);
TabAutofarm:AddToggle("Grab ruby clothes", "Automatically grab ruby clothes when they appear.", "", Configuration.CanGrab.Ruby, function(Value)Configuration.CanGrab.Ruby = Value end);
TabAutofarm:AddToggle("Grab sapphire clothes", "Automatically grab sapphire clothes when they appear.", "", Configuration.CanGrab.Sapphire, function(Value)Configuration.CanGrab.Sapphire = Value end);

local TabUtilities = Library:AddTab("Utilities");
TabUtilities:AddButton("Trade clean clothes", "Trades the clean clothes for money, without walking.", "", function()
	if Player.NonSaveVars.BasketStatus.Value == "Clean" and Player.NonSaveVars.BackpackAmount.Value > 0 then
		local LastCFrame = Player.Character.HumanoidRootPart.CFrame;
		Player.Character.HumanoidRootPart.CFrame = workspace["_FinishChute"].Entrance.CFrame;
		delay(0.2, function()
			ReplicatedStorage.Events.DropClothesInChute:FireServer();
			delay(0.2, function()
				Player.Character.HumanoidRootPart.CFrame = LastCFrame;
			end);
		end);
	end;
end);
TabUtilities:AddSeperator();
TabUtilities:AddButton("Load washing machines", "Automatically loads all your dirty clothes into your washing machines.", "", function()
	if Player.NonSaveVars.BasketStatus.Value == "Dirty" and Player.NonSaveVars.BackpackAmount.Value > 0 then
		LoadWashingMachines();
	end;
end);
TabUtilities:AddButton("Unload washing machines", "Automatically fetches clothes from machines that are clean.", "", function()
	if Player.NonSaveVars.BackpackAmount.Value == 0 or (Player.NonSaveVars.BasketStatus.Value == "Clean" and Player.NonSaveVars.BackpackAmount.Value < Player.NonSaveVars.BasketSize.Value) then
		UnloadWashingMachines();
	end;
end);

Library:AddTab("Discord"):AddDiscord("EnvisionExploits", "7EJ9MunQTt");
Library:OpenTab("Discord");

MainSignal = workspace.Debris.Clothing.ChildAdded:Connect(function(Cloth)
	if Configuration.Autofarm.Grabbing == true then
		if Player.NonSaveVars.BackpackAmount.Value == 0 or (Player.NonSaveVars.BasketStatus.Value == "Dirty" and Player.NonSaveVars.BackpackAmount.Value < Player.NonSaveVars.BasketSize.Value) then
			GrabClothing(Cloth);
		end;
	end;
end);
