local E, L, V, P, G = unpack(select(2, ...));
local S = E:GetModule("Skins");

local _G = _G;
local unpack, select = unpack, select;
local find = string.find;

local function LoadSkin()
	if(E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.talent ~= true) then return; end

	PlayerTalentFrame:StripTextures()
	PlayerTalentFrame:CreateBackdrop("Transparent")
	PlayerTalentFrame.backdrop:Point("BOTTOMRIGHT", PlayerTalentFrame, 0, -1)

	PlayerTalentFrameInset:StripTextures()
	PlayerTalentFrameTalents:StripTextures()
	PlayerTalentFramePetTalents:StripTextures()

	PlayerTalentFrameActivateButton:StripTextures()
	S:HandleButton(PlayerTalentFrameActivateButton)

	PlayerTalentFrameToggleSummariesButton:StripTextures()
	S:HandleButton(PlayerTalentFrameToggleSummariesButton)
	PlayerTalentFrameToggleSummariesButton:Point("BOTTOM", PlayerTalentFrame, "BOTTOM", 0, 5)

	for i = 1, 3 do
		_G["PlayerTalentFramePanel"..i.."HeaderIcon"]:StripTextures()
		_G["PlayerTalentFramePanel"..i.."InactiveShadow"]:Kill()
		_G["PlayerTalentFramePanel"..i.."SummaryRoleIcon"]:Kill()

		_G["PlayerTalentFramePanel"..i.."SelectTreeButton"]:SetFrameLevel(_G["PlayerTalentFramePanel"..i.."SelectTreeButton"]:GetFrameLevel() + 5)
		_G["PlayerTalentFramePanel"..i.."SelectTreeButton"]:StripTextures(true)
		S:HandleButton(_G["PlayerTalentFramePanel"..i.."SelectTreeButton"])

		_G["PlayerTalentFramePanel"..i.."Arrow"]:SetFrameLevel(_G["PlayerTalentFramePanel"..i.."Arrow"]:GetFrameLevel() + 2)
	end

	PlayerTalentFramePanel2SummaryRoleIcon2:Kill()
	PlayerTalentFramePetShadowOverlay:Kill()
	PlayerTalentFrameHeaderHelpBox:Kill()

	local function StripTalentFramePanelTextures(object)
		for i = 1, object:GetNumRegions() do
			local region = select(i, object:GetRegions())
			if(region:GetObjectType() == "Texture") then
				if(region:GetName():find("Branch")) then
					region:SetDrawLayer("OVERLAY")
				else
					region:SetTexture(nil)
				end
			end
		end
	end

	StripTalentFramePanelTextures(PlayerTalentFramePanel1)
	StripTalentFramePanelTextures(PlayerTalentFramePanel2)
	StripTalentFramePanelTextures(PlayerTalentFramePanel3)
	StripTalentFramePanelTextures(PlayerTalentFramePetPanel)

	PlayerTalentFramePetPanelArrow:SetFrameStrata("HIGH")

	PlayerTalentFramePanel1:CreateBackdrop("Transparent")
	PlayerTalentFramePanel1.backdrop:Point("TOPLEFT", 3, -3)
	PlayerTalentFramePanel1.backdrop:Point("BOTTOMRIGHT", -3, 3)

	PlayerTalentFramePanel2:CreateBackdrop("Transparent")
	PlayerTalentFramePanel2.backdrop:Point("TOPLEFT", 3, -3)
	PlayerTalentFramePanel2.backdrop:Point("BOTTOMRIGHT", -3, 3)

	PlayerTalentFramePanel3:CreateBackdrop("Transparent")
	PlayerTalentFramePanel3.backdrop:Point("TOPLEFT", 3, -3)
	PlayerTalentFramePanel3.backdrop:Point("BOTTOMRIGHT", -3, 3)

	S:HandleCloseButton(PlayerTalentFrameCloseButton)

	function talentpairs(inspect, pet)
	   local tab, tal = 1, 0
	   return function()
		  tal = tal + 1
		  if(tal > GetNumTalents(tab,inspect,pet)) then
			 tal = 1
			 tab = tab + 1
		  end
		  if(tab <= GetNumTalentTabs(inspect,pet)) then
			 return tab, tal
		  end
	   end
	end

	--Skin TalentButtons
	local function TalentButtons(self, first, i, j)
		local button = _G["PlayerTalentFramePanel"..i.."Talent"..j]
		local icon = _G["PlayerTalentFramePanel"..i.."Talent"..j.."IconTexture"]

		if(first) then
			button:StripTextures()
		end

		if(button.Rank) then
			button.Rank:FontTemplate(nil, 12, "OUTLINE")
			button.Rank:Point("BOTTOMRIGHT", 9, -12)
		end

		if(icon) then
			icon:SetTexCoord(unpack(E.TexCoords))
			icon:SetAllPoints()

			button:StyleButton()
			button.SetHighlightTexture = E.noop
			button.SetPushedTexture = E.noop
			button:GetNormalTexture():SetTexCoord(unpack(E.TexCoords))
			button:GetPushedTexture():SetTexCoord(unpack(E.TexCoords))
			button:GetHighlightTexture():SetAllPoints(icon)
			button:GetPushedTexture():SetAllPoints(icon)
			button:SetFrameLevel(button:GetFrameLevel() + 1)
			button:CreateBackdrop()
		end
	end

	local function TalentSummaryButtons(self, first, active, i, j)
		if(active) then
			button = _G["PlayerTalentFramePanel"..i.."SummaryActiveBonus1"]
			icon = _G["PlayerTalentFramePanel"..i.."SummaryActiveBonus1Icon"]
		else
			button = _G["PlayerTalentFramePanel"..i.."SummaryBonus"..j]
			icon = _G["PlayerTalentFramePanel"..i.."SummaryBonus"..j.."Icon"]
		end

		if(first) then
			button:StripTextures()
		end

		if(icon) then
			icon:SetTexCoord(unpack(E.TexCoords))

			button:SetFrameLevel(button:GetFrameLevel() + 1)

			local frame = CreateFrame("Frame", nil, button)
			frame:CreateBackdrop()
			frame:SetFrameLevel(button:GetFrameLevel() - 1)
			frame.backdrop:SetOutside(icon)
		end
	end

	for i = 1, 2 do
		local tab = _G["PlayerSpecTab"..i]
		tab:GetRegions():Hide();
		tab:SetTemplate();
		tab:StyleButton(nil, true);
		tab:GetNormalTexture():SetInside();
		tab:GetNormalTexture():SetTexCoord(unpack(E.TexCoords));
	end

	--Reposition tabs
	PlayerSpecTab1:ClearAllPoints()
	PlayerSpecTab1:SetPoint("TOPLEFT", PlayerTalentFrame, "TOPRIGHT", E.PixelMode and -1 or 1, -32)
	PlayerSpecTab1.SetPoint = E.noop

	local function TalentSummaryClean(i)
		local frame = _G["PlayerTalentFramePanel"..i.."Summary"]
		frame:SetFrameLevel(frame:GetFrameLevel() + 2)
		frame:CreateBackdrop()
		frame:SetFrameLevel(frame:GetFrameLevel() + 1)

		local a,b,_,d,_,_,_,_,_,_,_,_,m,_ = frame:GetRegions()
		a:Hide()
		b:Hide()
		d:Hide()
		m:Hide()

		_G["PlayerTalentFramePanel"..i.."SummaryIcon"]:SetTexCoord(unpack(E.TexCoords))
	end

	local function TalentHeaderIcon(self, first, i)
		local button = _G["PlayerTalentFramePanel"..i.."HeaderIcon"]
		local icon = _G["PlayerTalentFramePanel"..i.."HeaderIconIcon"]
		local panel = _G["PlayerTalentFramePanel"..i]
		local text = _G["PlayerTalentFramePanel"..i.."HeaderIconPointsSpent"]

		if(first) then
			button:StripTextures()
		end

		if(icon) then
			icon:SetTexCoord(unpack(E.TexCoords))
			button:SetFrameLevel(button:GetFrameLevel() + 1)
			button:Point("TOPLEFT", panel, "TOPLEFT", 4, -4)

			text:FontTemplate(nil, 13, "OUTLINE")
			text:Point("BOTTOMRIGHT", button, "BOTTOMRIGHT", 125, 11)

			local frame = CreateFrame("Frame",nil, button)
			frame:CreateBackdrop()
			frame:SetFrameLevel(button:GetFrameLevel() + 1)
			frame:SetOutside(icon)
		end
	end

	for i = 1, 3 do
		TalentSummaryClean(i)
		TalentHeaderIcon(nil, true, i)
		for j = 1, 4 do
			TalentSummaryButtons(nil, true, true, i, j)
			TalentSummaryButtons(nil, true, false, i, j)
		end
	end

	for tab,talent in talentpairs() do
		TalentButtons(nil, true, tab, talent)
	end

	for i = 1, 3 do
		S:HandleTab(_G["PlayerTalentFrameTab"..i])
	end

	--PET TALENTS
	S:HandleRotateButton(PlayerTalentFramePetModelRotateLeftButton)
	PlayerTalentFramePetModelRotateLeftButton:Point("BOTTOM", PlayerTalentFramePetModel, "BOTTOM", -4, 4)

	S:HandleRotateButton(PlayerTalentFramePetModelRotateRightButton)
	PlayerTalentFramePetModelRotateRightButton:Point("TOPLEFT", PlayerTalentFramePetModelRotateLeftButton, "TOPRIGHT", 4, 0)

	PlayerTalentFramePetPanel:CreateBackdrop("Transparent")
	PlayerTalentFramePetPanel.backdrop:Point("TOPLEFT", 3, -3)
	PlayerTalentFramePetPanel.backdrop:Point("BOTTOMRIGHT", -3, 3)

	PlayerTalentFramePetModel:CreateBackdrop("Transparent")

	S:HandleButton(PlayerTalentFrameLearnButton, true)
	S:HandleButton(PlayerTalentFrameResetButton, true)

	local function PetHeaderIcon(self, first)
		local button = _G["PlayerTalentFramePetPanelHeaderIcon"]
		local icon = _G["PlayerTalentFramePetPanelHeaderIconIcon"]
		local panel = _G["PlayerTalentFramePetPanel"]
		local d = select(4, button:GetRegions())

		if(first) then
			button:StripTextures()
		end

		if(icon) then
			d:ClearAllPoints()
			pointsSpent = select(5, GetTalentTabInfo(1, Partycheck, true, 1))
			icon:SetTexCoord(unpack(E.TexCoords))

			button:SetFrameLevel(button:GetFrameLevel() + 1)
			button:Point("TOPLEFT", panel, "TOPLEFT", 5, -5)

			local text = button:CreateFontString(nil, "OVERLAY")
			text:FontTemplate(nil, 13, "OUTLINE")
			text:Point("BOTTOMRIGHT", button, "BOTTOMRIGHT", 150, 16)
			text:SetText(pointsSpent)

			local frame = CreateFrame("Frame", nil, button)
			frame:CreateBackdrop()
			frame:SetFrameLevel(button:GetFrameLevel() + 1)
			frame:SetOutside(icon)
		end
	end

	local function PetInfoIcon(self, first)
		local button = _G["PlayerTalentFramePetInfo"]
		local icon = _G["PlayerTalentFramePetIcon"]
		local panel = _G["PlayerTalentFramePetModel"]

		PlayerTalentFramePetDiet:Hide();

		local petFoodList = {GetPetFoodTypes()};
		if(#petFoodList > 0) then
			diet = petFoodList[1]
		else
			diet = "None"
		end

		if(first) then
			button:StripTextures()
		end

		if(icon) then
			icon:SetTexCoord(unpack(E.TexCoords))

			button:SetFrameLevel(button:GetFrameLevel() + 1)
			button:ClearAllPoints()
			button:Point("BOTTOMLEFT", panel, "TOPLEFT", 0, 10)

			local text = button:CreateFontString(nil, "OVERLAY")
			text:FontTemplate(nil, 12)
			text:Point("TOPRIGHT", button, "TOPRIGHT", 0, -10)
			text:SetText(diet)

			local frame = CreateFrame("Frame", nil, button)
			frame:CreateBackdrop()
			frame:SetFrameLevel(button:GetFrameLevel() + 1)
			frame:SetOutside(icon)
		end
	end	

	local function PetTalentButtons(self, first, i)
		local button = _G["PlayerTalentFramePetPanelTalent"..i]
		local icon = _G["PlayerTalentFramePetPanelTalent"..i.."IconTexture"]

		if(first) then
			button:StripTextures()
		end

		if(button.Rank) then
			button.Rank:FontTemplate(nil, 12, "OUTLINE")
			button.Rank:ClearAllPoints()
			button.Rank:SetPoint("BOTTOMRIGHT", 9, -12)
		end

		if(icon) then
			icon:SetTexCoord(unpack(E.TexCoords))
			icon:SetAllPoints()

			button:StyleButton()
			button.SetHighlightTexture = E.noop
			button.SetPushedTexture = E.noop
			button:GetNormalTexture():SetTexCoord(unpack(E.TexCoords))
			button:GetPushedTexture():SetTexCoord(unpack(E.TexCoords))
			button:GetHighlightTexture():SetAllPoints(icon)
			button:GetPushedTexture():SetAllPoints(icon)
			button:SetFrameLevel(button:GetFrameLevel() + 1)
			button:CreateBackdrop()
		end
	end	

	PetInfoIcon(nil, true)
	PetHeaderIcon(nil, true)

	PlayerTalentFrame:HookScript("OnShow", function()
		for i = 1, GetNumTalents(1, false, true) do
			PetTalentButtons(nil, true, i)
		end
	end)

	PlayerTalentFrameLearnButtonTutorial:Kill()

	S:HandleCloseButton(PlayerTalentFrameLearnButtonTutorialCloseButton)
end

S:AddCallbackForAddon("Blizzard_TalentUI", "Talent", LoadSkin);