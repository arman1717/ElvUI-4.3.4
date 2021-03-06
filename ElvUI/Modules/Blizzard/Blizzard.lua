local E, L, V, P, G = unpack(select(2, ...))
local B = E:GetModule("Blizzard")
local Skins = E:GetModule("Skins")

local CreateFrame = CreateFrame
local IsAddOnLoaded = IsAddOnLoaded
local UnitIsUnit = UnitIsUnit

function B:Initialize()
	self:EnhanceColorPicker()
	self:KillBlizzard()
	self:AlertMovers()
	self:PositionCaptureBar()
	self:PositionDurabilityFrame()
	self:PositionGMFrames()
	self:SkinBlizzTimers()
	self:PositionVehicleFrame()
	self:MoveWatchFrame()

	if not IsAddOnLoaded("SimplePowerBar") then
		self:PositionAltPowerBar()
		self:SkinAltPowerBar()
	end

	self:RegisterEvent("ZONE_CHANGED_NEW_AREA", SetMapToCurrentZone)

	if GetLocale() == "deDE" then
		DAY_ONELETTER_ABBR = "%d d"
	end

	CreateFrame("Frame"):SetScript("OnUpdate", function()
		if LFRBrowseFrame.timeToClear then
			LFRBrowseFrame.timeToClear = nil
		end
	end)

	ReadyCheckFrame:HookScript("OnShow", function(self)
		if UnitIsUnit("player", self.initiator) then
			self:Hide()
		end
	end)

	-- MicroButton Talent Alert
	if E.global.general.showMissingTalentAlert then
		TalentMicroButtonAlert:StripTextures(true)
		TalentMicroButtonAlert:SetTemplate("Transparent")
		TalentMicroButtonAlert:ClearAllPoints()
		TalentMicroButtonAlert:Point("CENTER", E.UIParent, "TOP", 0, -75)
		TalentMicroButtonAlert:Width(230)

		TalentMicroButtonAlertArrow:Hide()
		TalentMicroButtonAlertText:Point("TOPLEFT", 42, -23)
		TalentMicroButtonAlertText:FontTemplate()
		Skins:HandleCloseButton(TalentMicroButtonAlertCloseButton)

		TalentMicroButtonAlert.tex = TalentMicroButtonAlert:CreateTexture(nil, "OVERLAY")
		TalentMicroButtonAlert.tex:Point("LEFT", 5, -4)
		TalentMicroButtonAlert.tex:SetTexture("Interface\\DialogFrame\\UI-Dialog-Icon-AlertNew")
		TalentMicroButtonAlert.tex:Size(32)

		TalentMicroButtonAlert.button = CreateFrame("Button", nil, TalentMicroButtonAlert, nil)
		TalentMicroButtonAlert.button:SetAllPoints(TalentMicroButtonAlert)
		TalentMicroButtonAlert.button:HookScript("OnClick", function()
			if not PlayerTalentFrame then TalentFrame_LoadUI() end
			if not GlyphFrame then GlyphFrame_LoadUI() end

			if not PlayerTalentFrame:IsShown() then
				ShowUIPanel(PlayerTalentFrame)
			else
				HideUIPanel(PlayerTalentFrame)
			end
		end)
	else
		TalentMicroButtonAlert:Kill() -- Kill it, because then the blizz default will show
	end

	self.Initialized = true
end

local function InitializeCallback()
	B:Initialize()
end

E:RegisterModule(B:GetName(), InitializeCallback)