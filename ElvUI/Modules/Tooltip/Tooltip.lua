local E, L, V, P, G = unpack(select(2, ...))
local TT = E:GetModule("Tooltip")

local _G = _G
local unpack, tonumber, select = unpack, tonumber, select
local twipe, tinsert, tconcat = table.wipe, table.insert, table.concat
local floor = math.floor
local find, format, sub, match = string.find, string.format, string.sub, string.match

local CanInspect = CanInspect
local CreateFrame = CreateFrame
local GameTooltip_ClearMoney = GameTooltip_ClearMoney
local GetAverageItemLevel = GetAverageItemLevel
local GetGuildInfo = GetGuildInfo
local GetInventoryItemLink = GetInventoryItemLink
local GetInventorySlotInfo = GetInventorySlotInfo
local GetItemCount = GetItemCount
local GetMouseFocus = GetMouseFocus
local GetNumPartyMembers = GetNumPartyMembers
local GetNumRaidMembers = GetNumRaidMembers
local GetQuestDifficultyColor = GetQuestDifficultyColor
local GetTime = GetTime
local InCombatLockdown = InCombatLockdown
local IsAltKeyDown = IsAltKeyDown
local IsControlKeyDown = IsControlKeyDown
local IsShiftKeyDown = IsShiftKeyDown
local NotifyInspect = NotifyInspect
local SetTooltipMoney = SetTooltipMoney
local UnitAura = UnitAura
local UnitClass = UnitClass
local UnitClassification = UnitClassification
local UnitCreatureType = UnitCreatureType
local UnitExists = UnitExists
local UnitGUID = UnitGUID
local UnitHasVehicleUI = UnitHasVehicleUI
local UnitIsAFK = UnitIsAFK
local UnitIsDND = UnitIsDND
local UnitIsDeadOrGhost = UnitIsDeadOrGhost
local UnitIsPVP = UnitIsPVP
local UnitIsPlayer = UnitIsPlayer
local UnitIsTapped = UnitIsTapped
local UnitIsTappedByPlayer = UnitIsTappedByPlayer
local UnitIsUnit = UnitIsUnit
local UnitLevel = UnitLevel
local UnitName = UnitName
local UnitPVPName = UnitPVPName
local UnitRace = UnitRace
local UnitReaction = UnitReaction

local AFK, BOSS, DEAD, DND, ID, PVP = AFK, BOSS, DEAD, DND, ID, PVP
local ROLE, TANK, HEALER = ROLE, TANK, HEALER
local FACTION_ALLIANCE, FACTION_HORDE, FACTION_BAR_COLORS = FACTION_ALLIANCE, FACTION_HORDE, FACTION_BAR_COLORS
local FOREIGN_SERVER_LABEL = FOREIGN_SERVER_LABEL
local ITEM_QUALITY3_DESC = ITEM_QUALITY3_DESC
local UNKNOWN = UNKNOWN
local PRIEST_COLOR = RAID_CLASS_COLORS.PRIEST

-- Custom to find LEVEL string on tooltip
local LEVEL1 = strlower(TOOLTIP_UNIT_LEVEL:gsub("%s?%%s%s?%-?", ""))
local LEVEL2 = strlower(TOOLTIP_UNIT_LEVEL_CLASS:gsub("^%%2$s%s?(.-)%s?%%1$s", "%1"):gsub("^%-?г?о?%s?", ""):gsub("%s?%%s%s?%-?", ""))

local GameTooltip, GameTooltipStatusBar = GameTooltip, GameTooltipStatusBar
local MATCH_ITEM_LEVEL = ITEM_LEVEL:gsub("%%d", "(%%d+)")
local targetList = {}
local TAPPED_COLOR = {r = 0.6, g = 0.6, b = 0.6}
local AFK_LABEL = " |cffFFFFFF[|r|cffFF0000"..AFK.."|r|cffFFFFFF]|r"
local DND_LABEL = " |cffFFFFFF[|r|cffFFFF00"..DND.."|r|cffFFFFFF]|r"
local keybindFrame

local classification = {
	worldboss = format("|cffAF5050 %s|r", BOSS),
	rareelite = format("|cffAF5050+ %s|r", ITEM_QUALITY3_DESC),
	elite = "|cffAF5050+|r",
	rare = format("|cffAF5050 %s|r", ITEM_QUALITY3_DESC)
}

local SlotName = {
	"Head", "Neck", "Shoulder", "Back", "Chest", "Wrist",
	"Hands", "Waist", "Legs", "Feet", "Finger0", "Finger1",
	"Trinket0", "Trinket1", "MainHand", "SecondaryHand", "Ranged"
}

function TT:GameTooltip_SetDefaultAnchor(tt, parent)
	if E.private.tooltip.enable ~= true then return end
	if not self.db.visibility then return end
	if tt:GetAnchorType() ~= "ANCHOR_NONE" then return end

	if InCombatLockdown() and self.db.visibility.combat then
		local modifier = self.db.visibility.combatOverride
		if not ((modifier == "SHIFT" and IsShiftKeyDown()) or (modifier == "CTRL" and IsControlKeyDown()) or (modifier == "ALT" and IsAltKeyDown())) then
			tt:Hide()
			return
		end
	end

	local ownerName = tt:GetOwner() and tt:GetOwner().GetName and tt:GetOwner():GetName()
	if self.db.visibility.actionbars ~= "NONE" and ownerName and (strfind(ownerName, "ElvUI_Bar") or strfind(ownerName, "MultiBar") or strfind(ownerName, "ElvUI_StanceBar") or strfind(ownerName, "PetAction")) and not keybindFrame.active then
		local modifier = self.db.visibility.actionbars

		if modifier == "ALL" or not ((modifier == "SHIFT" and IsShiftKeyDown()) or (modifier == "CTRL" and IsControlKeyDown()) or (modifier == "ALT" and IsAltKeyDown())) then
			tt:Hide()
			return
		end
	end

	if tt.StatusBar then
		if self.db.healthBar.statusPosition == "BOTTOM" then
			if tt.StatusBar.anchoredToTop then
				tt.StatusBar:ClearAllPoints()
				tt.StatusBar:Point("TOPLEFT", tt, "BOTTOMLEFT", E.Border, -(E.Spacing * 3))
				tt.StatusBar:Point("TOPRIGHT", tt, "BOTTOMRIGHT", -E.Border, -(E.Spacing * 3))
				tt.StatusBar.text:Point("CENTER", tt.StatusBar, 0, 0)
				tt.StatusBar.anchoredToTop = nil
			end
		else
			if not tt.StatusBar.anchoredToTop then
				tt.StatusBar:ClearAllPoints()
				tt.StatusBar:Point("BOTTOMLEFT", tt, "TOPLEFT", E.Border, (E.Spacing * 3))
				tt.StatusBar:Point("BOTTOMRIGHT", tt, "TOPRIGHT", -E.Border, (E.Spacing * 3))
				tt.StatusBar.text:Point("CENTER", tt.StatusBar, 0, 0)
				tt.StatusBar.anchoredToTop = true
			end
		end
	end

	if parent then
		if self.db.cursorAnchor then
			tt:SetOwner(parent, self.db.cursorAnchorType, self.db.cursorAnchorX, self.db.cursorAnchorY)
			return
		else
			tt:SetOwner(parent, "ANCHOR_NONE")
		end
	end

	local _, anchor = tt:GetPoint()
	if anchor == nil or (ElvUI_ContainerFrame and anchor == ElvUI_ContainerFrame) or anchor == RightChatPanel or anchor == TooltipMover or anchor == UIParent or anchor == E.UIParent then
		tt:ClearAllPoints()
		if not E:HasMoverBeenMoved("TooltipMover") then
			if ElvUI_ContainerFrame and ElvUI_ContainerFrame:IsShown() then
				tt:Point("BOTTOMRIGHT", ElvUI_ContainerFrame, "TOPRIGHT", 0, 18)
			elseif RightChatPanel:GetAlpha() == 1 and RightChatPanel:IsShown() then
				tt:Point("BOTTOMRIGHT", RightChatPanel, "TOPRIGHT", 0, 18)
			else
				tt:Point("BOTTOMRIGHT", RightChatPanel, "BOTTOMRIGHT", 0, 18)
			end
		else
			local point = E:GetScreenQuadrant(TooltipMover)
			if point == "TOPLEFT" then
				tt:Point("TOPLEFT", TooltipMover, "BOTTOMLEFT", 1, -4)
			elseif point == "TOPRIGHT" then
				tt:Point("TOPRIGHT", TooltipMover, "BOTTOMRIGHT", -1, -4)
			elseif point == "BOTTOMLEFT" or point == "LEFT" then
				tt:Point("BOTTOMLEFT", TooltipMover, "TOPLEFT", 1, 18)
			else
				tt:Point("BOTTOMRIGHT", TooltipMover, "TOPRIGHT", -1, 18)
			end
		end
	end
end

function TT:RemoveTrashLines(tt)
	for i = 3, tt:NumLines() do
		local tiptext = _G["GameTooltipTextLeft"..i]
		local linetext = tiptext:GetText()

		if linetext == PVP or linetext == FACTION_ALLIANCE or linetext == FACTION_HORDE then
			tiptext:SetText("")
			tiptext:Hide()
		end
	end
end

function TT:GetLevelLine(tt, offset)
	for i = offset, tt:NumLines() do
		local tipLine = _G["GameTooltipTextLeft"..i]
		local tipText = tipLine and tipLine.GetText and tipLine:GetText() and strlower(tipLine:GetText())
		if tipText and find(tipText, LEVEL1) or find(tipText, LEVEL2) then
			return tipLine
		end
	end
end

function TT:SetUnitText(tt, unit, level, isShiftKeyDown)
	local color
	if UnitIsPlayer(unit) then
		local localeClass, class = UnitClass(unit)
		if not localeClass or not class then return end

		local name, realm = UnitName(unit)
		local nameRealm = (realm and realm ~= "" and format("%s-%s", name, realm)) or name
		local guildName, guildRankName, _, guildRealm = GetGuildInfo(unit)
		local pvpName = UnitPVPName(unit)

		color = E:ClassColor(class) or PRIEST_COLOR

		if self.db.playerTitles and pvpName then
			name = pvpName
		end

		if realm and realm ~= "" then
			if isShiftKeyDown or self.db.alwaysShowRealm then
				name = name.."-"..realm
			else
				name = name..FOREIGN_SERVER_LABEL
			end
		end

		if UnitIsAFK(unit) then
			name = name..AFK_LABEL
		elseif UnitIsDND(unit) then
			name = name..DND_LABEL
		end

		GameTooltipTextLeft1:SetFormattedText("|c%s%s|r", color.colorStr, name or UNKNOWN)

		local lineOffset = 2
		if guildName then
			if guildRealm and isShiftKeyDown then
				guildName = guildName.."-"..guildRealm
			end

			if self.db.guildRanks then
				GameTooltipTextLeft2:SetFormattedText("<|cff00ff10%s|r> [|cff00ff10%s|r]", guildName, guildRankName)
			else
				GameTooltipTextLeft2:SetFormattedText("<|cff00ff10%s|r>", guildName)
			end

			lineOffset = 3
		end

		local levelLine = self:GetLevelLine(tt, lineOffset)
		if levelLine then
			local diffColor = GetQuestDifficultyColor(level)
			local race = UnitRace(unit)
			levelLine:SetFormattedText("|cff%02x%02x%02x%s|r %s |c%s%s|r", diffColor.r * 255, diffColor.g * 255, diffColor.b * 255, level > 0 and level or "??", race or "", color.colorStr, localeClass)
		end

		if E.db.tooltip.role then
			local r, g, b, role = 1, 1, 1, UnitGroupRolesAssigned(unit)
			local numParty, numRaid = GetNumPartyMembers(), GetNumRaidMembers()
			if (numParty > 0 or numRaid > 0) and (UnitInParty(unit) or UnitInRaid(unit)) and (role ~= "NONE") then
				if role == "HEALER" then
					role, r, g, b = HEALER, 0, 1, 0.59
				elseif role == "TANK" then
					role, r, g, b = TANK, 0.16, 0.31, 0.61
				elseif role == "DAMAGER" then
					role, r, g, b = L["DPS"], 0.77, 0.12, 0.24
				end

				GameTooltip:AddDoubleLine(format("%s:", ROLE), role, nil, nil, nil, r, g, b)
			end
		end

		if E.db.tooltip.showElvUIUsers then
			local addonUser = E.UserList[nameRealm]
			if addonUser then
				local v, r, g, b = addonUser == E.version, unpack(E.media.rgbvaluecolor)

				GameTooltip:AddDoubleLine(E.title, format("%s%s", "v", addonUser), r, g, b, v and 0 or 1, v and 1 or 0, 0)
			end
		end
	else
		if UnitIsTapped(unit) and not UnitIsTappedByPlayer(unit) then
			color = TAPPED_COLOR
		else
			local unitReaction = UnitReaction(unit, "player")
			if E.db.tooltip.useCustomFactionColors then
				if unitReaction then
					color = E.db.tooltip.factionColors[unitReaction]
				end
			else
				color = FACTION_BAR_COLORS[unitReaction]
			end
		end

		if not color then color = PRIEST_COLOR end

		local levelLine = self:GetLevelLine(tt, 2)
		if levelLine then
			local creatureClassification = UnitClassification(unit)
			local creatureType = UnitCreatureType(unit)
			local pvpFlag = ""
			local diffColor = GetQuestDifficultyColor(level)

			if UnitIsPVP(unit) then
				pvpFlag = format(" (%s)", PVP)
			end

			levelLine:SetFormattedText("|cff%02x%02x%02x%s|r%s %s%s", diffColor.r * 255, diffColor.g * 255, diffColor.b * 255, level > 0 and level or "??", classification[creatureClassification] or "", creatureType or "", pvpFlag)
		end
	end

	return color
end

function TT:ScanForItemLevel(itemLink)
	E.ScanTooltip:SetOwner(UIParent, "ANCHOR_NONE")
	E.ScanTooltip:SetHyperlink(itemLink)
	E.ScanTooltip:Show()

	local iLvl = 0
	for i = 2, E.ScanTooltip:NumLines() do
		local line = _G["ElvUI_ScanTooltipTextLeft"..i]
		local lineText = line:GetText()

		if lineText and lineText ~= "" then
			local value = strmatch(lineText, MATCH_ITEM_LEVEL)

			if value then
				iLvl = tonumber(value)
			end
		end
	end

	E.ScanTooltip:Hide()

	return iLvl
end

function TT:GetItemLvL(unit)
	local total, item = 0, 0
	for i = 1, #SlotName do
		local itemLink = GetInventoryItemLink(unit, GetInventorySlotInfo(format("%sSlot", SlotName[i])))

		if itemLink ~= nil then
			local iLvl = TT:ScanForItemLevel(itemLink)
			if iLvl and iLvl > 0 then
				item = item + 1
				total = total + iLvl
			end
		end
	end

	if total < 1 then return end

	return floor(total / item)
end

local tree = {}
function TT:GetTalentSpec(unit, isInspect)
	local group = GetActiveTalentGroup(isInspect)
	local primaryTree = 1
	for i = 1, 3 do
		local _, _, _, _, pointsSpent = GetTalentTabInfo(i, isInspect, nil, group)

		tree[i] = pointsSpent

		if tree[i] > tree[primaryTree] then
			primaryTree = i
		end
	end

	local _, name, _, icon = GetTalentTabInfo(primaryTree, isInspect, nil, group)
	icon = icon and "|T"..icon..":12:12:0:0:64:64:5:59:5:59|t " or ""

	return name and icon..name
end

local inspectGUIDCache = {}
local inspectColorFallback = {1, 1, 1}
function TT:PopulateInspectGUIDCache(unitGUID, itemLevel, specName)
	if specName and itemLevel then
		local inspectCache = inspectGUIDCache[unitGUID]
		if inspectCache then
			inspectCache.time = GetTime()
			inspectCache.itemLevel = itemLevel
			inspectCache.specName = specName
		end

		GameTooltip:AddDoubleLine(L["Talent Specialization"]..":", specName, nil, nil, nil, unpack((inspectCache and inspectCache.unitColor) or inspectColorFallback))
		GameTooltip:AddDoubleLine(L["Item Level:"], itemLevel, nil, nil, nil, 1, 1, 1)
		GameTooltip:Show()
	end
end

function TT:INSPECT_READY(event, unitGUID)
	if UnitExists("mouseover") and UnitGUID("mouseover") == unitGUID then
		local itemLevel = TT:GetItemLvL("mouseover")
		local specName = TT:GetTalentSpec("mouseover", 1)

		TT:PopulateInspectGUIDCache(unitGUID, itemLevel, specName)
	end

	if event then
		self:UnregisterEvent(event)
	end
end

local lastGUID
function TT:AddInspectInfo(tooltip, unit, numTries, r, g, b)
	if (not unit) or (numTries > 3) or not CanInspect(unit) then return end

	local unitGUID = UnitGUID(unit)
	if not unitGUID then return end

	if unitGUID == E.myguid then
		tooltip:AddDoubleLine(L["Talent Specialization"]..":", TT:GetTalentSpec(unit), nil, nil, nil, r, g, b)
		tooltip:AddDoubleLine(L["Item Level:"], floor(select(2, GetAverageItemLevel())), nil, nil, nil, 1, 1, 1)
	elseif inspectGUIDCache[unitGUID] and inspectGUIDCache[unitGUID].time then
		local specName = inspectGUIDCache[unitGUID].specName
		local itemLevel = inspectGUIDCache[unitGUID].itemLevel
		if not (specName and itemLevel) or (GetTime() - inspectGUIDCache[unitGUID].time > 120) then
			inspectGUIDCache[unitGUID].time = nil
			inspectGUIDCache[unitGUID].specName = nil
			inspectGUIDCache[unitGUID].itemLevel = nil

			return TT:AddInspectInfo(tooltip, unit, numTries + 1, r, g, b)
		end

		tooltip:AddDoubleLine(L["Talent Specialization"]..":", specName, nil, nil, nil, r, g, b)
		tooltip:AddDoubleLine(L["Item Level:"], itemLevel, nil, nil, nil, 1, 1, 1)
	elseif unitGUID then
		if not inspectGUIDCache[unitGUID] then
			inspectGUIDCache[unitGUID] = {unitColor = {r, g, b}}
		end

		if lastGUID ~= unitGUID then
			lastGUID = unitGUID
			NotifyInspect(unit)
			self:RegisterEvent("INSPECT_READY")
		else
			self:INSPECT_READY(nil, unitGUID)
		end
	end
end

function TT:GameTooltip_OnTooltipSetUnit(tt)
	local unit = select(2, tt:GetUnit())
	local isShiftKeyDown = IsShiftKeyDown()
	local isControlKeyDown = IsControlKeyDown()
	local isPlayerUnit = UnitIsPlayer(unit)

	if tt:GetOwner() ~= UIParent and (self.db.visibility and self.db.visibility.unitFrames ~= "NONE") then
		local modifier = self.db.visibility.unitFrames

		if modifier == "ALL" or not ((modifier == "SHIFT" and isShiftKeyDown) or (modifier == "CTRL" and isControlKeyDown) or (modifier == "ALT" and IsAltKeyDown())) then
			tt:Hide()
			return
		end
	end

	if not unit then
		local GMF = GetMouseFocus()
		if GMF and GMF.GetAttribute and GMF:GetAttribute("unit") then
			unit = GMF:GetAttribute("unit")
		end

		if not unit or not UnitExists(unit) then return end
	end

	self:RemoveTrashLines(tt)

	local color = self:SetUnitText(tt, unit, UnitLevel(unit), isShiftKeyDown)

	if not isShiftKeyDown and not isControlKeyDown then
		local unitTarget = unit.."target"
		if self.db.targetInfo and unit ~= "player" and UnitExists(unitTarget) then
			local targetColor
			if UnitIsPlayer(unitTarget) and not UnitHasVehicleUI(unitTarget) then
				local _, class = UnitClass(unitTarget)
				targetColor = E:ClassColor(class) or PRIEST_COLOR
			else
				targetColor = E.db.tooltip.useCustomFactionColors and E.db.tooltip.factionColors[UnitReaction(unitTarget, "player")] or FACTION_BAR_COLORS[UnitReaction(unitTarget, "player")]
			end

			tt:AddDoubleLine(format("%s:", TARGET), format("|cff%02x%02x%02x%s|r", targetColor.r * 255, targetColor.g * 255, targetColor.b * 255, UnitName(unitTarget)))
		end

		local numParty, numRaid = GetNumPartyMembers(), GetNumRaidMembers()
		if self.db.targetInfo and (numParty > 0 or numRaid > 0) then
			for i = 1, (numRaid > 0 and numRaid or numParty) do
				local groupUnit = (numRaid > 0 and "raid"..i or "party"..i)
				if UnitIsUnit(groupUnit.."target", unit) and not UnitIsUnit(groupUnit,"player") then
					local _, class = UnitClass(groupUnit)
					local classColor = E:ClassColor(class) or PRIEST_COLOR
					tinsert(targetList, format("|c%s%s|r", classColor.colorStr, UnitName(groupUnit)))
				end
			end
			local numList = #targetList
			if numList > 0 then
				tt:AddLine(format("%s (|cffffffff%d|r): %s", L["Targeted By:"], numList, tconcat(targetList, ", ")), nil, nil, nil, true)
				twipe(targetList)
			end
		end
	end

	if isShiftKeyDown and isPlayerUnit then
		twipe(tree)
		self:AddInspectInfo(tt, unit, 0, color.r, color.g, color.b)
	end

	-- NPC ID's
	if unit and self.db.npcID and not isPlayerUnit then
		local guid = UnitGUID(unit) or ""
		local id = tonumber(sub(guid, 8, 12), 16)
		if id then
			tt:AddLine(format("|cFFCA3C3C%s|r %d", ID, id))
		end
	end

	if color then
		tt.StatusBar:SetStatusBarColor(color.r, color.g, color.b)
	else
		tt.StatusBar:SetStatusBarColor(0.6, 0.6, 0.6)
	end

	local textWidth = tt.StatusBar.text:GetStringWidth()
	if textWidth then
		tt:SetMinimumWidth(textWidth)
	end
end

function TT:GameTooltipStatusBar_OnValueChanged(tt, value)
	if not value or not self.db.healthBar.text or not tt.text then return end

	local unit = select(2, tt:GetParent():GetUnit())
	if not unit then
		local GMF = GetMouseFocus()
		if GMF and GMF.GetAttribute and GMF:GetAttribute("unit") then
			unit = GMF:GetAttribute("unit")
		end
	end

	local _, max = tt:GetMinMaxValues()
	if value > 0 and max == 1 then
		tt.text:SetFormattedText("%d%%", floor(value * 100))
		tt:SetStatusBarColor(TAPPED_COLOR.r, TAPPED_COLOR.g, TAPPED_COLOR.b) --most effeciant?
	elseif value == 0 or (unit and UnitIsDeadOrGhost(unit)) then
		tt.text:SetText(DEAD)
	else
		tt.text:SetText(E:ShortValue(value).." / "..E:ShortValue(max))
	end
end

function TT:GameTooltip_OnTooltipCleared(tt)
	tt.itemCleared = nil
end

function TT:GameTooltip_OnTooltipSetItem(tt)
	local ownerName = tt:GetOwner() and tt:GetOwner().GetName and tt:GetOwner():GetName()
	if self.db.visibility and self.db.visibility.bags ~= "NONE" and ownerName and (strfind(ownerName, "ElvUI_Container") or strfind(ownerName, "ElvUI_BankContainer")) then
		local modifier = self.db.visibility.bags

		if modifier == "ALL" or not ((modifier == "SHIFT" and IsShiftKeyDown()) or (modifier == "CTRL" and IsControlKeyDown()) or (modifier == "ALT" and IsAltKeyDown())) then
			tt.itemCleared = true
			tt:Hide()
			return
		end
	end

	if not tt.itemCleared then
		local _, link = tt:GetItem()
		local num = GetItemCount(link)
		local numall = GetItemCount(link, true)
		local left, right, bankCount = " ", " ", " "

		if link ~= nil and self.db.spellID then
			local id = tonumber(match(link, ":(%w+)"))
			left = format("|cFFCA3C3C%s|r %s", ID, id)
		end

		if self.db.itemCount == "BAGS_ONLY" then
			right = format("|cFFCA3C3C%s|r %d", L["Count"], num)
		elseif self.db.itemCount == "BANK_ONLY" then
			bankCount = format("|cFFCA3C3C%s|r %d", L["Bank"], (numall - num))
		elseif self.db.itemCount == "BOTH" then
			right = format("|cFFCA3C3C%s|r %d", L["Count"], num)
			bankCount = format("|cFFCA3C3C%s|r %d", L["Bank"], (numall - num))
		end

		if left ~= " " or right ~= " " then
			tt:AddLine(" ")
			tt:AddDoubleLine(left, right)
		end

		if bankCount ~= " " then
			tt:AddDoubleLine(" ", bankCount)
		end

		tt.itemCleared = true
	end
end

function TT:GameTooltip_ShowStatusBar(tt)
	if not tt then return end

	local sb = _G[tt:GetName().."StatusBar"..tt.shownStatusBars]
	if not sb or sb.backdrop then return end

	sb:StripTextures()
	sb:CreateBackdrop(nil, nil, true)
	sb:SetStatusBarTexture(E.media.normTex)
end

function TT:CheckBackdropColor(tt)
	if not tt:IsShown() then return end

	local r, g, b = tt:GetBackdropColor()
	if r and g and b then
		r, g, b = E:Round(r, 1), E:Round(g, 1), E:Round(b, 1)

		local red, green, blue = unpack(E.media.backdropfadecolor)
		if r ~= red or g ~= green or b ~= blue then
			tt:SetBackdropColor(red, green, blue, self.db.colorAlpha)
		end
	end
end

function TT:SetStyle(tt)
	if not tt or tt == E.ScanTooltip then return end

	tt:SetTemplate("Transparent", nil, true) --ignore updates

	local r, g, b = tt:GetBackdropColor()
	tt:SetBackdropColor(r, g, b, self.db.colorAlpha)
end

function TT:MODIFIER_STATE_CHANGED(_, key)
	if key == "LSHIFT" or key == "RSHIFT" or key == "LCTRL" or key == "RCTRL" or key == "LALT" or key == "RALT" then
		local owner = GameTooltip:GetOwner()
		local notOnAuras = not (owner and owner.UpdateTooltip)

		if notOnAuras and UnitExists("mouseover") then
			GameTooltip:SetUnit("mouseover")
		end
	end
end

function TT:SetUnitAura(tt, ...)
	local _, _, _, _, _, _, _, caster, _, _, id = UnitAura(...)
	if id and self.db.spellID then
		if caster then
			local name = UnitName(caster)
			local _, class = UnitClass(caster)
			local color = E:ClassColor(class) or PRIEST_COLOR

			tt:AddDoubleLine(format("|cFFCA3C3C%s|r %d", ID, id), format("|c%s%s|r", color.colorStr, name))
		else
			tt:AddLine(format("|cFFCA3C3C%s|r %d", ID, id))
		end

		tt:Show()
	end
end

function TT:GameTooltip_OnTooltipSetSpell(tt)
	local id = select(3, tt:GetSpell())
	if not id or not self.db.spellID then return end

	local displayString = format("|cFFCA3C3C%s|r %d", ID, id)
	for i = 1, tt:NumLines() do
		local line = _G[format("GameTooltipTextLeft%d", i)]
		local text = line and line.GetText and line:GetText()

		if text and strfind(text, displayString) then return end
	end

	tt:AddLine(displayString)
	tt:Show()
end

function TT:SetItemRef(link)
	if self.db.spellID and link and (strfind(link, "^spell:") or strfind(link, "^item:") or strfind(link, "^currency:") or strfind(link, "^talent:")) then
		local id = tonumber(match(link, "(%d+)"))

		ItemRefTooltip:AddLine(format("|cFFCA3C3C%s|r %d", ID, id))
		ItemRefTooltip:Show()
	end
end

function TT:RepositionBNET(frame, _, anchor)
	if anchor ~= BNETMover then
		frame:ClearAllPoints()
		frame:Point(BNETMover.anchorPoint or "TOPLEFT", BNETMover, BNETMover.anchorPoint or "TOPLEFT")
	end
end

function TT:SetTooltipFonts()
	local font = E.Libs.LSM:Fetch("font", E.db.tooltip.font)
	local fontOutline = E.db.tooltip.fontOutline
	local headerSize = E.db.tooltip.headerFontSize
	local smallTextSize = E.db.tooltip.smallTextFontSize
	local textSize = E.db.tooltip.textFontSize

	GameTooltipHeaderText:SetFont(font, headerSize, fontOutline)
	GameTooltipTextSmall:SetFont(font, smallTextSize, fontOutline)
	GameTooltipText:SetFont(font, textSize, fontOutline)

	if GameTooltip.hasMoney then
		for i = 1, GameTooltip.numMoneyFrames do
			_G["GameTooltipMoneyFrame"..i.."PrefixText"]:FontTemplate(font, textSize, fontOutline)
			_G["GameTooltipMoneyFrame"..i.."SuffixText"]:FontTemplate(font, textSize, fontOutline)
			_G["GameTooltipMoneyFrame"..i.."GoldButtonText"]:FontTemplate(font, textSize, fontOutline)
			_G["GameTooltipMoneyFrame"..i.."SilverButtonText"]:FontTemplate(font, textSize, fontOutline)
			_G["GameTooltipMoneyFrame"..i.."CopperButtonText"]:FontTemplate(font, textSize, fontOutline)
		end
	end

	-- Ignore header font size on DatatextTooltip
	if DatatextTooltip then
		DatatextTooltipTextLeft1:FontTemplate(font, textSize, fontOutline)
		DatatextTooltipTextRight1:FontTemplate(font, textSize, fontOutline)
	end

	-- Comparison Tooltips should use smallTextSize
	for _, tt in ipairs(GameTooltip.shoppingTooltips) do
		for i = 1, tt:GetNumRegions() do
			local region = select(i, tt:GetRegions())

			if region:IsObjectType("FontString") then
				region:FontTemplate(font, smallTextSize, fontOutline)
			end
		end
	end
end

--This changes the growth direction of the toast frame depending on position of the mover
local function PostBNToastMove(mover)
	local x, y = mover:GetCenter()
	local screenHeight = E.UIParent:GetTop()
	local screenWidth = E.UIParent:GetRight()

	local anchorPoint
	if y > (screenHeight / 2) then
		anchorPoint = (x > (screenWidth / 2)) and "TOPRIGHT" or "TOPLEFT"
	else
		anchorPoint = (x > (screenWidth / 2)) and "BOTTOMRIGHT" or "BOTTOMLEFT"
	end
	mover.anchorPoint = anchorPoint

	BNToastFrame:ClearAllPoints()
	BNToastFrame:Point(anchorPoint, mover)
end

function TT:Initialize()
	self.db = E.db.tooltip

	BNToastFrame:Point("TOPRIGHT", MMHolder, "BOTTOMRIGHT", 0, -10)
	E:CreateMover(BNToastFrame, "BNETMover", L["BNet Frame"], nil, nil, PostBNToastMove)
	self:SecureHook(BNToastFrame, "SetPoint", "RepositionBNET")

	if not E.private.tooltip.enable then return end

	self.Initialized = true

	GameTooltip.StatusBar = GameTooltipStatusBar
	GameTooltip.StatusBar:Height(self.db.healthBar.height)
	GameTooltip.StatusBar:SetScript("OnValueChanged", nil) -- Do we need to unset this?
	GameTooltip.StatusBar.text = GameTooltip.StatusBar:CreateFontString(nil, "OVERLAY")
	GameTooltip.StatusBar.text:Point("CENTER", GameTooltip.StatusBar, 0, 0)
	GameTooltip.StatusBar.text:FontTemplate(E.Libs.LSM:Fetch("font", self.db.healthBar.font), self.db.healthBar.fontSize, self.db.healthBar.fontOutline)

	--Tooltip Fonts
	if not GameTooltip.hasMoney then
		--Force creation of the money lines, so we can set font for it
		SetTooltipMoney(GameTooltip, 1, nil, "", "")
		SetTooltipMoney(GameTooltip, 1, nil, "", "")
		GameTooltip_ClearMoney(GameTooltip)
	end
	self:SetTooltipFonts()

	local GameTooltipAnchor = CreateFrame("Frame", "GameTooltipAnchor", E.UIParent)
	GameTooltipAnchor:Point("BOTTOMRIGHT", RightChatToggleButton, "BOTTOMRIGHT")
	GameTooltipAnchor:Size(130, 20)
	GameTooltipAnchor:SetFrameLevel(GameTooltipAnchor:GetFrameLevel() + 50)
	E:CreateMover(GameTooltipAnchor, "TooltipMover", L["Tooltip"], nil, nil, nil, nil, nil, "tooltip,general")

	self:SecureHook("SetItemRef")
	self:SecureHook("GameTooltip_SetDefaultAnchor")
	self:SecureHook(GameTooltip, "SetUnitAura")
	self:SecureHook(GameTooltip, "SetUnitBuff", "SetUnitAura")
	self:SecureHook(GameTooltip, "SetUnitDebuff", "SetUnitAura")
	self:HookScript(GameTooltip, "OnTooltipSetSpell", "GameTooltip_OnTooltipSetSpell")
	self:HookScript(GameTooltip, "OnTooltipCleared", "GameTooltip_OnTooltipCleared")
	self:HookScript(GameTooltip, "OnTooltipSetItem", "GameTooltip_OnTooltipSetItem")
	self:HookScript(GameTooltip, "OnTooltipSetUnit", "GameTooltip_OnTooltipSetUnit")
	self:HookScript(GameTooltip.StatusBar, "OnValueChanged", "GameTooltipStatusBar_OnValueChanged")
	self:RegisterEvent("MODIFIER_STATE_CHANGED")

	--Variable is localized at top of file, then set here when we're sure the frame has been created
	--Used to check if keybinding is active, if so then don't hide tooltips on actionbars
	keybindFrame = ElvUI_KeyBinder
end

local function InitializeCallback()
	TT:Initialize()
end

E:RegisterModule(TT:GetName(), InitializeCallback)