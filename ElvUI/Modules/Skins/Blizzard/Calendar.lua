local E, L, V, P, G = unpack(select(2, ...))
local S = E:GetModule("Skins")

local _G = _G
local ipairs, unpack = ipairs, unpack

local CLASS_SORT_ORDER = CLASS_SORT_ORDER
local CLASS_ICON_TCOORDS = CLASS_ICON_TCOORDS

local function LoadSkin()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.calendar then return end

	CalendarFrame:StripTextures()
	CalendarFrame:CreateBackdrop("Transparent")
	CalendarFrame.backdrop:Point("TOPLEFT", 9, -2)
	CalendarFrame.backdrop:Point("BOTTOMRIGHT", -8, 2)
	CalendarFrame:EnableMouseWheel(true)
	CalendarFrame:SetScript("OnMouseWheel", function(_, value)
		if value > 0 then
			if CalendarPrevMonthButton:IsEnabled() == 1 then CalendarPrevMonthButton_OnClick() end
		else
			if CalendarNextMonthButton:IsEnabled() == 1 then CalendarNextMonthButton_OnClick() end
		end
	end)

	S:HandleCloseButton(CalendarCloseButton, CalendarFrame.backdrop)

	S:HandleArrowButton(CalendarPrevMonthButton, true, true)
	S:HandleArrowButton(CalendarNextMonthButton, nil, true)

	-- Filter Frame
	CalendarFilterFrame:StripTextures()
	CalendarFilterFrame:Width(155)

	CalendarFilterFrameText:ClearAllPoints()
	CalendarFilterFrameText:Point("RIGHT", CalendarFilterButton, "LEFT", -2, 0)

	CalendarFilterButton:ClearAllPoints()
	CalendarFilterButton:Point("RIGHT", CalendarFilterFrame, "RIGHT", -10, 3)
	CalendarFilterButton.SetPoint = E.noop

	S:HandleNextPrevButton(CalendarFilterButton)

	CalendarFilterFrame:CreateBackdrop("Default")
	CalendarFilterFrame.backdrop:Point("TOPLEFT", 20, 4)
	CalendarFilterFrame.backdrop:Point("BOTTOMRIGHT", CalendarFilterButton, "BOTTOMRIGHT", 2, -2)

	CalendarWeekdaySelectedTexture:SetTexture(1, 1, 1, 0.3)
	CalendarWeekdaySelectedTexture:SetInside()

	CalendarContextMenu:SetTemplate("Transparent")
	CalendarContextMenu.SetBackdropColor = E.noop
	CalendarContextMenu.SetBackdropBorderColor = E.noop

	for i = 1, 7 do
		local button = _G["CalendarContextMenuButton"..i]

		S:HandleButtonHighlight(button, true)
	end

	for i = 1, 42 do
		local button = _G["CalendarDayButton"..i]
		local eventTexture = _G["CalendarDayButton"..i.."EventTexture"]
		local overlayFrame = _G["CalendarDayButton"..i.."OverlayFrame"]
		local darkFrame = _G["CalendarDayButton"..i.."DarkFrame"]
		local darkFrameTop = _G["CalendarDayButton"..i.."DarkFrameTop"]
		local moreEventButton = _G["CalendarDayButton"..i.."MoreEventsButton"]
		local highlight = button:GetHighlightTexture()

		button:StripTextures()
		button:SetTemplate("Transparent")
		button:Size(91 - E.Border)
		button:SetFrameLevel(button:GetFrameLevel() + 1)
		button:ClearAllPoints()

		S:HandleNextPrevButton(moreEventButton, nil, nil, true)
		moreEventButton:Point("TOPRIGHT", -2, -2)

		if i == 1 then
			button:Point("TOPLEFT", CalendarWeekday1Background, "BOTTOMLEFT", E.Spacing, 0)
		elseif mod(i, 7) == 1 then
			button:Point("TOPLEFT", _G["CalendarDayButton"..(i - 7)], "BOTTOMLEFT", 0, -E.Border)
		else
			button:Point("TOPLEFT", _G["CalendarDayButton"..(i - 1)], "TOPRIGHT", E.Border, 0)
		end

		button:SetHighlightTexture(E.media.glossTex)
		highlight:SetVertexColor(1, 1, 1, 0.3)
		highlight.SetAlpha = E.noop
		highlight:SetInside()

		darkFrame:StripTextures()
		darkFrameTop:SetTexture(E.media.glossTex)
		darkFrameTop:SetVertexColor(0, 0, 0, 0.6)
		darkFrameTop:SetInside()

		eventTexture:SetInside()
		overlayFrame:SetInside()

		for j = 1, 4 do
			local eventButton = _G["CalendarDayButton"..i.."EventButton"..j]
			local eventButtonHighlight = eventButton:GetHighlightTexture()

			eventButton:StripTextures()

			eventButton:SetHighlightTexture(E.media.glossTex)
			eventButtonHighlight:SetVertexColor(1, 1, 1, 0.3)
			eventButtonHighlight.SetAlpha = E.noop
			eventButtonHighlight:Point("TOPLEFT", -3, 1)
			eventButtonHighlight:Point("BOTTOMRIGHT", 2, -2)
		end
	end

	hooksecurefunc("CalendarFrame_SetToday", function()
		CalendarTodayFrame:SetInside()
	end)

	-- Today Frame
	CalendarTodayFrame:SetScript("OnUpdate", nil)
	CalendarTodayTextureGlow:Hide()
	CalendarTodayTexture:Hide()

	CalendarTodayFrame:SetBackdrop({
		edgeFile = E.media.blankTex,
		edgeSize = 2
	})
	CalendarTodayFrame:SetBackdropBorderColor(unpack(E.media.rgbvaluecolor))

	-- Create Event Frame
	CalendarCreateEventFrame:StripTextures()
	CalendarCreateEventFrame:SetTemplate("Transparent")
	CalendarCreateEventFrame:Point("TOPLEFT", CalendarFrame, "TOPRIGHT", -(E.PixelMode and 6 or 4), -2)
	CalendarCreateEventFrame:CreateBackdrop()
	CalendarCreateEventFrame.backdrop:SetOutside(CalendarCreateEventIcon)

	CalendarCreateEventIcon:SetTexCoord(unpack(E.TexCoords))
	CalendarCreateEventIcon.SetTexCoord = E.noop

	CalendarCreateEventTitleFrame:StripTextures()

	S:HandleButton(CalendarCreateEventCreateButton, true)
	CalendarCreateEventCreateButton:Point("BOTTOMRIGHT", CalendarCreateEventFrame, "BOTTOMRIGHT", -12, 12)

	S:HandleButton(CalendarCreateEventMassInviteButton, true)

	S:HandleButton(CalendarCreateEventInviteButton, true)
	CalendarCreateEventInviteButton:Point("TOPLEFT", CalendarCreateEventInviteEdit, "TOPRIGHT", 4, 1)

	CalendarCreateEventInviteList:StripTextures()
	CalendarCreateEventInviteList:SetTemplate("Transparent")

	S:HandleEditBox(CalendarCreateEventInviteEdit)
	CalendarCreateEventInviteEdit:Point("TOPLEFT", CalendarCreateEventInviteList, "BOTTOMLEFT", 1, -3)

	S:HandleEditBox(CalendarCreateEventTitleEdit)
	CalendarCreateEventTitleEdit:ClearAllPoints()
	CalendarCreateEventTitleEdit:Point("TOPLEFT", 17, -94)
	CalendarCreateEventTitleEdit:Size(170, 18)

	S:HandleDropDownBox(CalendarCreateEventTypeDropDown, 120)
	CalendarCreateEventTypeDropDown:ClearAllPoints()
	CalendarCreateEventTypeDropDown:Point("TOPRIGHT", -5, -87)

	CalendarCreateEventDescriptionContainer:StripTextures()
	CalendarCreateEventDescriptionContainer:SetTemplate("Default")

	S:HandleCloseButton(CalendarCreateEventCloseButton)

	S:HandleCheckBox(CalendarCreateEventLockEventCheck)

	S:HandleDropDownBox(CalendarCreateEventHourDropDown, 68)
	CalendarCreateEventHourDropDown:Point("TOPLEFT", 4, -114)
	S:HandleDropDownBox(CalendarCreateEventMinuteDropDown, 68)
	S:HandleDropDownBox(CalendarCreateEventAMPMDropDown, 68)
	S:HandleDropDownBox(CalendarCreateEventRepeatOptionDropDown, 120)

	CalendarCreateEventInviteListSection:StripTextures()

	S:HandleScrollBar(CalendarCreateEventDescriptionScrollFrameScrollBar)
	S:HandleScrollBar(CalendarCreateEventInviteListScrollFrameScrollBar)

	if CalendarCreateEventInviteListScrollFrame.buttons then
		for _, button in ipairs(CalendarCreateEventInviteListScrollFrame.buttons) do
			S:HandleButtonHighlight(button)
		end
	else
		CalendarCreateEventInviteList:HookScript("OnEvent", function(self, event)
			if event == "ADDON_LOADED" then
				for _, button in ipairs(self.scrollFrame.buttons) do
					S:HandleButtonHighlight(button)
				end
			end
		end)
	end

	CalendarClassButtonContainer:HookScript("OnShow", function()
		for i, class in ipairs(CLASS_SORT_ORDER) do
			local button = _G["CalendarClassButton"..i]
			local icon = button:GetNormalTexture()
			local tcoords = CLASS_ICON_TCOORDS[class]

			button:StripTextures()
			button:CreateBackdrop("Default")
			button:Size(23)

			icon:SetTexture("Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes")
			icon:SetTexCoord(tcoords[1] + 0.015, tcoords[2] - 0.02, tcoords[3] + 0.018, tcoords[4] - 0.02)
		end

		CalendarClassButton1:Point("TOPLEFT", E.PixelMode and 2 or 5, 0)

		CalendarClassTotalsButton:StripTextures()
		CalendarClassTotalsButton:CreateBackdrop("Default")
		CalendarClassTotalsButton:Size(23)
	end)

	CalendarInviteStatusContextMenu:StripTextures()
	CalendarInviteStatusContextMenu:SetTemplate("Transparent")

	for i = 1, 32 do
		local button = _G["CalendarInviteStatusContextMenuButton"..i]

		S:HandleButtonHighlight(button, true)
	end

	-- Texture Picker Frame
	CalendarTexturePickerFrame:StripTextures()
	CalendarTexturePickerFrame:SetTemplate("Transparent")
	CalendarTexturePickerFrame:Point("TOPRIGHT", CalendarFrame, "TOPRIGHT", 640, 0)

	CalendarTexturePickerScrollFrame:CreateBackdrop("Transparent")

	CalendarTexturePickerTitleFrame:StripTextures()

	for i = 1, 16 do
		local button = _G["CalendarTexturePickerScrollFrameButton"..i]

		S:HandleButtonHighlight(button)
	end

	S:HandleScrollBar(CalendarTexturePickerScrollBar)
	CalendarTexturePickerScrollBar:Point("RIGHT", 28, 0)

	S:HandleButton(CalendarCreateEventInviteButton, true)
	S:HandleButton(CalendarCreateEventRaidInviteButton, true)

	S:HandleButton(CalendarTexturePickerAcceptButton, true)
	CalendarTexturePickerAcceptButton:Width(110)
	CalendarTexturePickerAcceptButton:ClearAllPoints()
	CalendarTexturePickerAcceptButton:Point("RIGHT", CalendarTexturePickerCancelButton, "LEFT", -20, 0)

	S:HandleButton(CalendarTexturePickerCancelButton, true)
	CalendarTexturePickerCancelButton:Width(110)
	CalendarTexturePickerCancelButton:ClearAllPoints()
	CalendarTexturePickerCancelButton:Point("BOTTOMRIGHT", CalendarTexturePickerFrame, "BOTTOMRIGHT", -30, 7)

	-- Mass Invite Frame
	CalendarMassInviteFrame:StripTextures()
	CalendarMassInviteFrame:SetTemplate("Transparent")
	CalendarMassInviteFrame:ClearAllPoints()
	CalendarMassInviteFrame:Point("TOPLEFT", CalendarCreateEventFrame, "TOPRIGHT", 25, 0)

	CalendarMassInviteTitleFrame:StripTextures()

	S:HandleCloseButton(CalendarMassInviteCloseButton)

	S:HandleButton(CalendarMassInviteGuildAcceptButton)
	S:HandleButton(CalendarMassInviteArenaButton2)
	S:HandleButton(CalendarMassInviteArenaButton3)
	S:HandleButton(CalendarMassInviteArenaButton5)

	S:HandleDropDownBox(CalendarMassInviteGuildRankMenu, 130)

	S:HandleEditBox(CalendarMassInviteGuildMinLevelEdit)
	S:HandleEditBox(CalendarMassInviteGuildMaxLevelEdit)

	-- Raid View
	CalendarViewRaidFrame:StripTextures()
	CalendarViewRaidFrame:SetTemplate("Transparent")
	CalendarViewRaidFrame:Point("TOPLEFT", CalendarFrame, "TOPRIGHT", -(E.PixelMode and 6 or 4), -2)

	CalendarViewRaidTitleFrame:StripTextures()

	S:HandleCloseButton(CalendarViewRaidCloseButton)

	-- Holiday View
	CalendarViewHolidayFrame:StripTextures(true)
	CalendarViewHolidayFrame:SetTemplate("Transparent")
	CalendarViewHolidayFrame:Point("TOPLEFT", CalendarFrame, "TOPRIGHT", -(E.PixelMode and 6 or 4), -2)

	CalendarViewHolidayTitleFrame:StripTextures()

	S:HandleCloseButton(CalendarViewHolidayCloseButton)

	-- Event View
	CalendarViewEventFrame:StripTextures()
	CalendarViewEventFrame:SetTemplate("Transparent")
	CalendarViewEventFrame:Point("TOPLEFT", CalendarFrame, "TOPRIGHT", -(E.PixelMode and 6 or 4), -2)

	CalendarViewEventTitleFrame:StripTextures()

	CalendarViewEventDescriptionContainer:StripTextures()
	CalendarViewEventDescriptionContainer:SetTemplate("Transparent")

	CalendarViewEventInviteList:StripTextures()
	CalendarViewEventInviteList:SetTemplate("Transparent")

	CalendarViewEventInviteListSection:StripTextures()

	S:HandleCloseButton(CalendarViewEventCloseButton)

	S:HandleScrollBar(CalendarViewEventInviteListScrollFrameScrollBar)
	S:HandleScrollBar(CalendarViewEventDescriptionScrollFrameScrollBar)

	S:HandleButton(CalendarViewEventAcceptButton)
	S:HandleButton(CalendarViewEventTentativeButton)
	S:HandleButton(CalendarViewEventRemoveButton)
	S:HandleButton(CalendarViewEventDeclineButton)

	-- Event Picker Frame
	CalendarEventPickerTitleFrame:StripTextures()

	CalendarEventPickerFrame:StripTextures()
	CalendarEventPickerFrame:SetTemplate("Transparent")

	CalendarEventPickerScrollFrame:CreateBackdrop("Transparent")
	CalendarEventPickerScrollFrame.backdrop:Point("BOTTOMRIGHT", 0, -3)

	S:HandleScrollBar(CalendarEventPickerScrollBar)
	CalendarEventPickerScrollBar:ClearAllPoints()
	CalendarEventPickerScrollBar:Point("TOPRIGHT", CalendarEventPickerScrollFrame, "TOPRIGHT", 26, -15)
	CalendarEventPickerScrollBar:Point("BOTTOMRIGHT", CalendarEventPickerScrollFrame, "BOTTOMRIGHT", 0, 13)

	S:HandleButton(CalendarEventPickerCloseButton)
	CalendarEventPickerCloseButton:Point("BOTTOMRIGHT", -6, 6)
end

S:AddCallbackForAddon("Blizzard_Calendar", "Calendar", LoadSkin)