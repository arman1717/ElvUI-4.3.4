local E, L, V, P, G = unpack(select(2, ...))
local S = E:GetModule("Skins")

local _G = _G
local unpack, select = unpack, select

local hooksecurefunc = hooksecurefunc
local GetInboxHeaderInfo = GetInboxHeaderInfo
local GetInboxItemLink = GetInboxItemLink
local GetItemInfo = GetItemInfo
local GetSendMailItem = GetSendMailItem
local GetItemQualityColor = GetItemQualityColor

local function LoadSkin()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.mail then return end

	-- Inbox Frame
	MailFrame:StripTextures(true)
	MailFrame:CreateBackdrop("Transparent")
	MailFrame.backdrop:Point("TOPLEFT", 4, 0)
	MailFrame.backdrop:Point("BOTTOMRIGHT", -25, 74)
	MailFrame:EnableMouseWheel(true)
	MailFrame:SetScript("OnMouseWheel", function(_, value)
		if value > 0 then
			if InboxPrevPageButton:IsEnabled() == 1 then
				InboxPrevPage()
			end
		else
			if InboxNextPageButton:IsEnabled() == 1 then
				InboxNextPage()
			end
		end
	end)

	for i = 1, INBOXITEMS_TO_DISPLAY do
		local mail = _G["MailItem"..i]
		local button = _G["MailItem"..i.."Button"]
		local icon = _G["MailItem"..i.."ButtonIcon"]
		local expire = _G["MailItem"..i.."ExpireTime"]

		mail:StripTextures()
		mail:CreateBackdrop("Transparent")
		mail.backdrop:SetParent(button)
		mail.backdrop:ClearAllPoints()
		mail.backdrop:Point("TOPLEFT", mail, 42, -2)
		mail.backdrop:Point("BOTTOMRIGHT", mail, 4, 7)
		mail.backdrop:SetFrameLevel(mail:GetFrameLevel() - 1)

		button:StripTextures()
		button:CreateBackdrop()
		button:Point("TOPLEFT", 2, -3)
		button:Size(34)
		button:StyleButton()
		button.hover:SetAllPoints()

		icon:SetTexCoord(unpack(E.TexCoords))
		icon:SetInside(button.backdrop)

		if expire then
			expire:Point("TOPRIGHT", mail, "TOPRIGHT", 4, -3)
		end
	end

	hooksecurefunc("InboxFrame_Update", function()
		local numItems = GetInboxNumItems()
		local index = ((InboxFrame.pageNum - 1) * INBOXITEMS_TO_DISPLAY) + 1

		for i = 1, INBOXITEMS_TO_DISPLAY do
			local button = _G["MailItem"..i.."Button"]

			if index <= numItems then
				local packageIcon, _, _, _, _, _, _, _, _, _, _, _, isGM = GetInboxHeaderInfo(index)

				if packageIcon and not isGM then
					local ItemLink = GetInboxItemLink(index, 1)

					if ItemLink then
						local quality = select(3, GetItemInfo(ItemLink))

						if quality then
							button.backdrop:SetBackdropBorderColor(GetItemQualityColor(quality))
						else
							button.backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))
						end
					end
				elseif isGM then
					button.backdrop:SetBackdropBorderColor(0, 0.56, 0.94)
				else
					button.backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))
				end
			else
				button.backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))
			end

			index = index + 1
		end
	end)

	InboxTitleText:ClearAllPoints()
	InboxTitleText:Point("TOP", InboxFrame, "TOP", 0, -5)

	SendMailTitleText:ClearAllPoints()
	SendMailTitleText:Point("TOP", SendMailFrame, "TOP", 0, -5)

	InboxTooMuchMail:ClearAllPoints()
	InboxTooMuchMail:Point("TOP", SendMailFrame, "TOP", -10, -30)

	S:HandleNextPrevButton(InboxPrevPageButton, nil, nil, true)
	InboxPrevPageButton:Size(32)
	InboxPrevPageButton:Point("CENTER", InboxFrame, "BOTTOMLEFT", 36, 104)

	S:HandleNextPrevButton(InboxNextPageButton, nil, nil, true)
	InboxNextPageButton:Size(32)
	InboxNextPageButton:Point("CENTER", InboxFrame, "BOTTOMLEFT", 328, 104)

	S:HandleCloseButton(InboxCloseButton, MailFrame.backdrop)

	for i = 1, 2 do
		local tab = _G["MailFrameTab"..i]

		tab:StripTextures()
		S:HandleTab(tab)
	end

	-- Send Mail Frame
	SendMailFrame:StripTextures()

	SendMailScrollFrame:StripTextures(true)
	SendMailScrollFrame:SetTemplate("Default")

	hooksecurefunc("SendMailFrame_Update", function()
		for i = 1, ATTACHMENTS_MAX_SEND do
			local button = _G["SendMailAttachment"..i]
			local icon = button:GetNormalTexture()
			local name = GetSendMailItem(i)

			if not button.skinned then
				button:StripTextures()
				button:SetTemplate("Default", true)
				button:StyleButton(nil, true)

				button.skinned = true
			end

			if name then
				local quality = select(3, GetItemInfo(name))

				if quality then
					button:SetBackdropBorderColor(GetItemQualityColor(quality))
				else
					button:SetBackdropBorderColor(unpack(E.media.bordercolor))
				end

				icon:SetTexCoord(unpack(E.TexCoords))
				icon:SetInside()
			else
				button:SetBackdropBorderColor(unpack(E.media.bordercolor))
			end
		end
	end)

	SendMailBodyEditBox:SetTextColor(1, 1, 1)

	S:HandleScrollBar(SendMailScrollFrameScrollBar)
	SendMailScrollFrameScrollBar:ClearAllPoints()
	SendMailScrollFrameScrollBar:Point("TOPRIGHT", SendMailScrollFrame, "TOPRIGHT", 20, -18)
	SendMailScrollFrameScrollBar:Point("BOTTOMRIGHT", SendMailScrollFrame, "BOTTOMRIGHT", 0, 18)

	S:HandleEditBox(SendMailNameEditBox)
	SendMailNameEditBox:Height(18)

	S:HandleEditBox(SendMailSubjectEditBox)
	SendMailSubjectEditBox:Point("TOPLEFT", SendMailNameEditBox, "BOTTOMLEFT", 0, -10)
	SendMailSubjectEditBox:Size(211, 18)

	S:HandleEditBox(SendMailMoneyGold)
	S:HandleEditBox(SendMailMoneySilver)
	S:HandleEditBox(SendMailMoneyCopper)

	S:HandleButton(SendMailMailButton)
	SendMailMailButton:Point("RIGHT", SendMailCancelButton, "LEFT", -2, 0)

	S:HandleButton(SendMailCancelButton)
	SendMailCancelButton:Point("BOTTOMRIGHT", -45, 80)

	S:HandleRadioButton(SendMailSendMoneyButton)
	S:HandleRadioButton(SendMailCODButton)

	SendMailMoneyFrame:Point("BOTTOMLEFT", 170, 84)

	for i = 1, 5 do
		_G["AutoCompleteButton"..i]:StyleButton()
	end

	-- Open Mail Frame
	OpenMailFrame:StripTextures(true)
	OpenMailFrame:CreateBackdrop("Transparent")
	OpenMailFrame.backdrop:Point("TOPLEFT", 4, 0)
	OpenMailFrame.backdrop:Point("BOTTOMRIGHT", -27, 74)

	for i = 1, ATTACHMENTS_MAX_SEND do
		local button = _G["OpenMailAttachmentButton"..i]
		local icon = _G["OpenMailAttachmentButton"..i.."IconTexture"]
		local count = _G["OpenMailAttachmentButton"..i.."Count"]

		button:StripTextures()
		button:SetTemplate("Default", true)
		button:StyleButton()

		if icon then
			icon:SetTexCoord(unpack(E.TexCoords))
			icon:SetDrawLayer("ARTWORK")
			icon:SetInside()

			count:SetDrawLayer("OVERLAY")
		end
	end

	hooksecurefunc("OpenMailFrame_UpdateButtonPositions", function()
		for i = 1, ATTACHMENTS_MAX_RECEIVE do
			local ItemLink = GetInboxItemLink(InboxFrame.openMailID, i)
			local button = _G["OpenMailAttachmentButton"..i]

			if ItemLink then
				local quality = select(3, GetItemInfo(ItemLink))

				if quality then
					button:SetBackdropBorderColor(GetItemQualityColor(quality))
				else
					button:SetBackdropBorderColor(unpack(E.media.bordercolor))
				end
			else
				button:SetBackdropBorderColor(unpack(E.media.bordercolor))
			end
		end
	end)

	S:HandleCloseButton(OpenMailCloseButton)
	OpenMailCloseButton:Point("CENTER", OpenMailFrame, "TOPRIGHT", -40, -13)

	S:HandleButton(OpenMailReportSpamButton)

	S:HandleButton(OpenMailReplyButton)
	OpenMailReplyButton:Point("RIGHT", OpenMailDeleteButton, "LEFT", -2, 0)

	S:HandleButton(OpenMailDeleteButton)
	OpenMailDeleteButton:Point("RIGHT", OpenMailCancelButton, "LEFT", -2, 0)

	S:HandleButton(OpenMailCancelButton)

	OpenMailScrollFrame:StripTextures(true)
	OpenMailScrollFrame:SetTemplate("Default")

	S:HandleScrollBar(OpenMailScrollFrameScrollBar)

	OpenMailBodyText:SetTextColor(1, 1, 1)
	InvoiceTextFontNormal:SetFont(E.media.normFont, 13)
	InvoiceTextFontNormal:SetTextColor(1, 1, 1)
	OpenMailInvoiceBuyMode:SetTextColor(1, 0.80, 0.10)

	OpenMailArithmeticLine:Kill()

	OpenMailLetterButton:StripTextures()
	OpenMailLetterButton:SetTemplate("Default", true)
	OpenMailLetterButton:StyleButton()

	OpenMailLetterButtonIconTexture:SetTexCoord(unpack(E.TexCoords))
	OpenMailLetterButtonIconTexture:SetDrawLayer("ARTWORK")
	OpenMailLetterButtonIconTexture:SetInside()

	OpenMailLetterButtonCount:SetDrawLayer("OVERLAY")

	OpenMailMoneyButton:StripTextures()
	OpenMailMoneyButton:SetTemplate("Default", true)
	OpenMailMoneyButton:StyleButton()

	OpenMailMoneyButtonIconTexture:SetTexCoord(unpack(E.TexCoords))
	OpenMailMoneyButtonIconTexture:SetDrawLayer("ARTWORK")
	OpenMailMoneyButtonIconTexture:SetInside()

	OpenMailMoneyButtonCount:SetDrawLayer("OVERLAY")
end

S:AddCallback("Mail", LoadSkin)