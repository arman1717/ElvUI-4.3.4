local E, L, V, P, G = unpack(select(2, ...));
local DT = E:GetModule('DataTexts')

local displayNumberString = ''
local lastPanel;
local join = string.join

local function OnEvent(self, event, ...)
	self.text:SetFormattedText(displayNumberString, STAT_ENERGY_REGEN, GetPowerRegen())
	lastPanel = self
end

local function ValueColorUpdate(hex)
	displayNumberString = join("", "%s: ", hex, "%.f|r")

	if lastPanel ~= nil then
		OnEvent(lastPanel)
	end
end
E['valueColorUpdateFuncs'][ValueColorUpdate] = true

DT:RegisterDatatext('Energy Regen', {"UNIT_STATS", "UNIT_AURA", "FORGE_MASTER_ITEM_CHANGED", "ACTIVE_TALENT_GROUP_CHANGED", "PLAYER_TALENT_UPDATE"}, OnEvent)