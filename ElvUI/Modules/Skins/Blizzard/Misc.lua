local E, L, V, P, G = unpack(select(2, ...))
local S = E:GetModule("Skins")

local _G = _G
local unpack = unpack

local function LoadSkin()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.misc then return end

	-- ESC/Menu Buttons
	GameMenuFrame:StripTextures()
	GameMenuFrame:CreateBackdrop("Transparent")

	local BlizzardMenuButtons = {
		GameMenuButtonOptions,
		GameMenuButtonUIOptions,
		GameMenuButtonKeybindings,
		GameMenuButtonMacros,
		GameMenuButtonRatings,
		GameMenuButtonLogout,
		GameMenuButtonQuit,
		GameMenuButtonContinue,
		GameMenuButtonMacOptions,
		GameMenuButtonHelp,
		GameMenuFrame.ElvUI
	}

	for i = 1, #BlizzardMenuButtons do
		local menuButton = BlizzardMenuButtons[i]
		if menuButton then
			S:HandleButton(menuButton)
		end
	end

	-- Static Popups
	for i = 1, 4 do
		local staticPopup = _G["StaticPopup"..i]
		local itemFrame = _G["StaticPopup"..i.."ItemFrame"]
		local itemFrameBox = _G["StaticPopup"..i.."EditBox"]
		local itemFrameTexture = _G["StaticPopup"..i.."ItemFrameIconTexture"]
		local itemFrameNormal = _G["StaticPopup"..i.."ItemFrameNormalTexture"]
		local itemFrameName = _G["StaticPopup"..i.."ItemFrameNameFrame"]
		local closeButton = _G["StaticPopup"..i.."CloseButton"]

		staticPopup:SetTemplate("Transparent")

		S:HandleEditBox(itemFrameBox)
		itemFrameBox.backdrop:Point("TOPLEFT", -2, -4)
		itemFrameBox.backdrop:Point("BOTTOMRIGHT", 2, 4)

		S:HandleEditBox(_G["StaticPopup"..i.."MoneyInputFrameGold"])
		S:HandleEditBox(_G["StaticPopup"..i.."MoneyInputFrameSilver"])
		S:HandleEditBox(_G["StaticPopup"..i.."MoneyInputFrameCopper"])

		closeButton:StripTextures(true)
		S:HandleCloseButton(closeButton)

		itemFrame:GetNormalTexture():Kill()
		itemFrame:SetTemplate()
		itemFrame:StyleButton()

		hooksecurefunc("StaticPopup_Show", function(which, _, _, data)
			local info = StaticPopupDialogs[which]
			if not info then return nil end

			if info.hasItemFrame then
				if data and type(data) == "table" then
					itemFrame:SetBackdropBorderColor(unpack(data.color or {1, 1, 1, 1}))
				end
			end
		end)

		itemFrameTexture:SetTexCoord(unpack(E.TexCoords))
		itemFrameTexture:SetInside()

		itemFrameNormal:SetAlpha(0)

		itemFrameName:Kill()

		for j = 1, 3 do
			S:HandleButton(_G["StaticPopup"..i.."Button"..j])
		end
	end

	-- Graveyard Button
	do
		GhostFrame:StripTextures(true)
		GhostFrame:SetTemplate("Transparent")
		GhostFrame:ClearAllPoints()
		GhostFrame:Point("TOP", E.UIParent, "TOP", 0, -150)

		GhostFrame:HookScript("OnEnter", S.SetModifiedBackdrop)
		GhostFrame:HookScript("OnLeave", S.SetOriginalBackdrop)

		GhostFrameContentsFrame:CreateBackdrop()
		GhostFrameContentsFrame.backdrop:SetOutside(GhostFrameContentsFrameIcon)
		GhostFrameContentsFrame.SetPoint = E.noop

		GhostFrameContentsFrameIcon:SetTexCoord(unpack(E.TexCoords))
		GhostFrameContentsFrameIcon:SetParent(GhostFrameContentsFrame.backdrop)
	end

	-- Other Frames
	TicketStatusFrameButton:SetTemplate("Transparent")

	AutoCompleteBox:SetTemplate("Transparent")

	StreamingIcon:ClearAllPoints()
	StreamingIcon:Point("TOP", UIParent, "TOP", 0, -100)

	if GetLocale() == "koKR" then
		RatingMenuFrame:SetTemplate("Transparent")
		RatingMenuFrameHeader:Kill()
		S:HandleButton(RatingMenuButtonOkay)
	end

	-- BNToast Frame
	BNToastFrame:SetTemplate("Transparent")

	BNToastFrameCloseButton:Size(32)
	BNToastFrameCloseButton:Point("TOPRIGHT", "BNToastFrame", 4, 4)

	S:HandleCloseButton(BNToastFrameCloseButton)

	-- ReadyCheck Frame
	ReadyCheckFrame:SetTemplate("Transparent")
	ReadyCheckFrame:Size(290, 85)

	S:HandleButton(ReadyCheckFrameYesButton)
	ReadyCheckFrameYesButton:ClearAllPoints()
	ReadyCheckFrameYesButton:Point("LEFT", ReadyCheckFrame, 15, -20)
	ReadyCheckFrameYesButton:SetParent(ReadyCheckFrame)

	S:HandleButton(ReadyCheckFrameNoButton)
	ReadyCheckFrameNoButton:ClearAllPoints()
	ReadyCheckFrameNoButton:Point("RIGHT", ReadyCheckFrame, -15, -20)
	ReadyCheckFrameNoButton:SetParent(ReadyCheckFrame)

	ReadyCheckFrameText:ClearAllPoints()
	ReadyCheckFrameText:Point("TOP", 0, -5)
	ReadyCheckFrameText:SetParent(ReadyCheckFrame)
	ReadyCheckFrameText:SetTextColor(1, 1, 1)

	ReadyCheckListenerFrame:SetAlpha(0)

	-- Coin PickUp Frame
	CoinPickupFrame:StripTextures()
	CoinPickupFrame:SetTemplate("Transparent")

	S:HandleButton(CoinPickupOkayButton)
	S:HandleButton(CoinPickupCancelButton)

	-- Stack Split Frame
	StackSplitFrame:SetTemplate("Transparent")
	StackSplitFrame:GetRegions():Hide()
	StackSplitFrame:SetFrameStrata("DIALOG")

	StackSplitFrame.bg1 = CreateFrame("Frame", nil, StackSplitFrame)
	StackSplitFrame.bg1:SetTemplate("Transparent")
	StackSplitFrame.bg1:Point("TOPLEFT", 10, -15)
	StackSplitFrame.bg1:Point("BOTTOMRIGHT", -10, 55)
	StackSplitFrame.bg1:SetFrameLevel(StackSplitFrame.bg1:GetFrameLevel() - 1)

	S:HandleButton(StackSplitOkayButton)
	S:HandleButton(StackSplitCancelButton)

	-- Opacity Frame
	OpacityFrame:StripTextures()
	OpacityFrame:SetTemplate("Transparent")

	S:HandleSliderFrame(OpacityFrameSlider)

	-- Declension frame
	if GetLocale() == "ruRU" then
		DeclensionFrame:SetTemplate("Transparent")

		S:HandleNextPrevButton(DeclensionFrameSetPrev)
		S:HandleNextPrevButton(DeclensionFrameSetNext)
		S:HandleButton(DeclensionFrameOkayButton)
		S:HandleButton(DeclensionFrameCancelButton)

		for i = 1, RUSSIAN_DECLENSION_PATTERNS do
			local editBox = _G["DeclensionFrameDeclension"..i.."Edit"]
			if editBox then
				editBox:StripTextures()
				S:HandleEditBox(editBox)
			end
		end
	end

	-- Role Check Popup
	RolePollPopup:SetTemplate("Transparent")

	S:HandleCloseButton(RolePollPopupCloseButton)

	S:HandleButton(RolePollPopupAcceptButton)

	local roleCheckIcons = {
		"RolePollPopupRoleButtonTank",
		"RolePollPopupRoleButtonHealer",
		"RolePollPopupRoleButtonDPS"
	}

	for i = 1, #roleCheckIcons do
		_G[roleCheckIcons[i]]:StripTextures()
		_G[roleCheckIcons[i]]:CreateBackdrop()
		_G[roleCheckIcons[i]].backdrop:Point("TOPLEFT", 7, -7)
		_G[roleCheckIcons[i]].backdrop:Point("BOTTOMRIGHT", -7, 7)

		_G[roleCheckIcons[i]]:GetNormalTexture():SetTexCoord(unpack(E.TexCoords))
		_G[roleCheckIcons[i]]:GetNormalTexture():SetInside(_G[roleCheckIcons[i]].backdrop)
	end

	RolePollPopupRoleButtonTank:Point("TOPLEFT", 32, -35)

	RolePollPopupRoleButtonTank:SetNormalTexture("Interface\\Icons\\Ability_Defend")
	RolePollPopupRoleButtonHealer:SetNormalTexture("Interface\\Icons\\SPELL_NATURE_HEALINGTOUCH")
	RolePollPopupRoleButtonDPS:SetNormalTexture("Interface\\Icons\\INV_Knife_1H_Common_B_01")

	-- Report Player
	ReportCheatingDialog:StripTextures()
	ReportCheatingDialog:SetTemplate("Transparent")

	ReportCheatingDialogCommentFrame:StripTextures()

	S:HandleEditBox(ReportCheatingDialogCommentFrameEditBox)
	S:HandleButton(ReportCheatingDialogReportButton)
	S:HandleButton(ReportCheatingDialogCancelButton)

	ReportPlayerNameDialog:StripTextures()
	ReportPlayerNameDialog:SetTemplate("Transparent")

	ReportPlayerNameDialogCommentFrame:StripTextures()

	S:HandleEditBox(ReportPlayerNameDialogCommentFrameEditBox)
	S:HandleButton(ReportPlayerNameDialogCancelButton)
	S:HandleButton(ReportPlayerNameDialogReportButton)

	-- Cinematic Popup
	CinematicFrameCloseDialog:StripTextures()
	CinematicFrameCloseDialog:SetTemplate("Transparent")

	CinematicFrameCloseDialog:SetScale(UIParent:GetScale())

	S:HandleButton(CinematicFrameCloseDialogConfirmButton)
	S:HandleButton(CinematicFrameCloseDialogResumeButton)

	-- Level Up Popup
	LevelUpDisplaySpellFrame:CreateBackdrop()
	LevelUpDisplaySpellFrame.backdrop:SetOutside(LevelUpDisplaySpellFrameIcon)

	LevelUpDisplaySpellFrameIcon:SetTexCoord(unpack(E.TexCoords))
	LevelUpDisplaySpellFrameSubIcon:SetTexCoord(unpack(E.TexCoords))

	LevelUpDisplaySide:HookScript("OnShow", function(self)
		for i = 1, #self.unlockList do
			local button = _G["LevelUpDisplaySideUnlockFrame"..i]

			if not button.isSkinned then
				button.icon:SetTexCoord(unpack(E.TexCoords))

				button.isSkinned = true
			end
		end
	end)

	-- Channel Pullout Frame
	ChannelPullout:SetTemplate("Transparent")

	ChannelPulloutBackground:Kill()

	S:HandleTab(ChannelPulloutTab)
	ChannelPulloutTab:Size(107, 26)
	ChannelPulloutTabText:Point("LEFT", ChannelPulloutTabLeft, "RIGHT", 0, 4)

	S:HandleCloseButton(ChannelPulloutCloseButton)
	ChannelPulloutCloseButton:Size(32)

	-- Dropdown Menu
	hooksecurefunc("UIDropDownMenu_CreateFrames", function(level, index)
		local listFrame = _G["DropDownList"..level]
		local listFrameName = listFrame:GetName()
		local expandArrow = _G[listFrameName.."Button"..index.."ExpandArrow"]

		if expandArrow then
			expandArrow:Size(16)
			expandArrow:SetNormalTexture(E.Media.Textures.ArrowUp)
			expandArrow:GetNormalTexture():SetRotation(S.ArrowRotation.right)
			expandArrow:GetNormalTexture():SetVertexColor(unpack(E.media.rgbvaluecolor))
		end

		local Backdrop = _G[listFrameName.."Backdrop"]
		if not Backdrop.template then Backdrop:StripTextures() end
		Backdrop:SetTemplate("Transparent")

		local menuBackdrop = _G[listFrameName.."MenuBackdrop"]
		if not menuBackdrop.template then menuBackdrop:StripTextures() end
		menuBackdrop:SetTemplate("Transparent")
	end)

	hooksecurefunc("UIDropDownMenu_InitializeHelper", function()
		for i = 1, UIDROPDOWNMENU_MAXLEVELS do
			for j = 1, UIDROPDOWNMENU_MAXBUTTONS do
				local button = _G["DropDownList"..i.."Button"..j]
				local check = _G["DropDownList"..i.."Button"..j.."Check"]
				local uncheck = _G["DropDownList"..i.."Button"..j.."UnCheck"]
				local highlight = _G["DropDownList"..i.."Button"..j.."Highlight"]
				local colorSwatch = _G["DropDownList"..i.."Button"..j.."ColorSwatch"]
				local r, g, b = unpack(E.media.rgbvaluecolor)

				if not button.isSkinned then
					button:CreateBackdrop()
					button.backdrop:SetOutside(check)

					highlight:SetTexture(E.Media.Textures.Highlight)
					highlight:SetVertexColor(r, g, b, 0.7)
					highlight:SetInside()
					highlight:SetBlendMode("BLEND")
					highlight:SetDrawLayer("BACKGROUND")

					check:SetTexture(E.media.normTex)
					check:SetVertexColor(r, g, b)
					check:Size(12)

					uncheck:SetTexture()

					S:HandleColorSwatch(colorSwatch, 12)

					button.isSkinned = true
				end
			end
		end
	end)

	hooksecurefunc("ToggleDropDownMenu", function(level)
		if not level then level = 1 end

		for i = 1, UIDROPDOWNMENU_MAXBUTTONS do
			local button = _G["DropDownList"..level.."Button"..i]
			local check = _G["DropDownList"..level.."Button"..i.."Check"]

			check:SetTexCoord(0, 1, 0, 1)

			if not button.notCheckable then
				if button.backdrop then
					button.backdrop:Show()
				end
			else
				if button.backdrop then
					button.backdrop:Hide()
				end
			end
		end
	end)

	-- Chat Menu
	for _, frame in pairs({"ChatMenu", "EmoteMenu", "LanguageMenu", "VoiceMacroMenu"}) do
		if _G[frame] == _G["ChatMenu"] then
			_G[frame]:HookScript("OnShow", function(self)
				self:SetTemplate("Transparent")
				self:SetBackdropColor(unpack(E.media.backdropfadecolor))
				self:ClearAllPoints()
				self:Point("BOTTOMLEFT", ChatFrame1, "TOPLEFT", 0, 30)
			end)
		else
			_G[frame]:HookScript("OnShow", function(self)
				self:SetTemplate("Transparent")
				self:SetBackdropColor(unpack(E.media.backdropfadecolor))
			end)
		end

		for i = 1, 32 do
			local button = _G[frame.."Button"..i]
			local r, g, b = unpack(E.media.rgbvaluecolor)

			button:SetHighlightTexture(E.Media.Textures.Highlight)
			button:GetHighlightTexture():SetVertexColor(r, g, b, 0.5)
			button:GetHighlightTexture():SetInside()
		end
	end
end

S:AddCallback("SkinMisc", LoadSkin)