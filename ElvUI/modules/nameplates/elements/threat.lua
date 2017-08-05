local E, L, V, P, G = unpack(ElvUI)
local mod = E:GetModule("NamePlates")
local LSM = LibStub("LibSharedMedia-3.0")
local ThreatLib = LibStub("Threat-2.0", true)

local playerguid = UnitGUID("player")

function mod:ThreatUpdated(event, srcGUID, dstGUID, threat)
	local plate = mod:SearchNameplateByGUID(dstGUID)
	if plate then
		mod:UpdateElement_Threat(plate, threat)
	end
end

function mod:InitializeThreat()
	ThreatLib = LibStub("Threat-2.0", true)
	if ThreatLib then
		ThreatLib.RegisterCallback(mod, "ThreatUpdated")
	else
		E:Print("Error: No ThreatLib found. Threat Glow on Nameplates disabled.")
	end
end

function mod:ConstructElement_Threat(frame)
	--print("constructing threat element")
	
	local f = CreateFrame("Frame", nil, frame)
	f:SetFrameLevel(frame.HealthBar:GetFrameLevel() - 1)
	f:SetOutside(frame.HealthBar, 3, 3)
	f:SetBackdrop({
		edgeFile = LSM:Fetch("border", "ElvUI GlowBorder"), edgeSize = E:Scale(3),
		insets = {left = E:Scale(5), right = E:Scale(5), top = E:Scale(5), bottom = E:Scale(5)}
	})

	f:SetScale(E.PixelMode and 1.5 or 2)
	f:Hide()
	return f
end

function mod:UpdateElement_Threat(frame, newthreat)
	--print("Updating plate for threat")
	
	local MaxThreat, MaxThreatGuid = ThreatLib:GetMaxThreatOnTarget(frame.guid)
	local status = nil
	if MaxThreatGuid ~= playerguid then
		local MyThreat = ThreatLib:GetThreat(playerguid, frame.guid)
		if MyThreat / MaxThreat > 0.9 then
			status = 1
		else
			status = 0
		end
	else
		local SecondGuid, SecondThreat = ThreatLib:GetPlayerAtPosition(frame.guid, 2)
		if SecondThreat / MaxThreat > 0.9 then
			status = 2
		else
			status = 3
		end
	end
	
	if status then
		frame.Threat:Show()
		local r, g, b = GetThreatStatusColor(status)
		if r ~= frame.Threat.r or g ~= frame.Threat.g or b ~= frame.Threat.b then
			frame.Threat:SetBackdropBorderColor(r, g, b)
			frame.Threat.r, frame.Threat.g, frame.Threat.b = r, g, b
		end
	else
		if frame.Threat:IsShown() then
			frame.Threat:Hide()
		end
	end
end