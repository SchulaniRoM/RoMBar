--======================== Config ======================

local RB = _G.RoMBar
local ME = {
	icon			= {"Interface/mainmenuframe/mainmenu-systembutton-normal", 0.234375, 0.75, 0.203125, 0.71875},
}

local function ToggleValue(this)
	local var = this.value
	if var=="lockAB" then
		RB.SetupTooltipPosition(not GetActionBarLocked())
		GCF_ActionButtonLocked:SetChecked(not GetActionBarLocked())
		GCF_Page4_Apply()
		GC_Save()
		RB.UpdateUI()
	elseif var=="click2move" then
		GC_SetMouseMoveEnable(not GC_GetMouseMoveEnable())
	elseif type(RB.settings[var])=="table" then
		RB.settings[var].enabled = not RB.settings[var].enabled
		RB.UpdateUI()
	elseif RB.settings[var]~=nil then
		RB.settings[var] = not RB.settings[var]
		RB.UpdateUI()
	end
	if var=="useWoWColors" then RB.OnEvent("UPDATE_COLORS_ROMWOW") end
	if var=="originalAB" and RB.settings.orininalAB then CloseAllWindows() ReloadUI() end
-- 	UIDropDownMenu_Refresh(RB.modules.dropdown.GetDropDownFrame())
end

local function SetValue(this)
	RB.Debug("ToggleValue", UIDROPDOWNMENU_MENU_VALUE, this.value)
	if RB.settings[UIDROPDOWNMENU_MENU_VALUE] then
		RB.settings[UIDROPDOWNMENU_MENU_VALUE]	= this.value
		RB.UpdateUI()
	end
	UIDropDownMenu_Refresh(RB.modules.dropdown.GetDropDownFrame())
end

function ME.DropDownHandler()
	local DD = RB.modules.dropdown
	if (UIDROPDOWNMENU_MENU_LEVEL or 1)==1 then
		DD.AddTitle(RB.lang[ME.name:upper().."_TITLE"])
		DD.AddMenu(RB.lang.CONFIG_INTERFACE, 1)
		DD.AddMenu(RB.lang.CONFIG_AUTOMATIC, 2)
	elseif UIDROPDOWNMENU_MENU_LEVEL==2 then
		if UIDROPDOWNMENU_MENU_VALUE==1 then
			DD.AddCheckBox(RB.lang.CONFIG_ONTOP, RB.settings.top, "top", ToggleValue)
			DD.AddCheckBox(RB.lang.CONFIG_ORIGINALUI, RB.settings.originalUI, "originalUI", ToggleValue)
			DD.AddSeparator()
			DD.AddCheckBox(RB.lang.CONFIG_CLICK2MOVE, GC_GetMouseMoveEnable(), "click2move", ToggleValue)
			DD.AddCheckBox(RB.lang.CONFIG_LOCKAB, GetActionBarLocked(), "lockAB", ToggleValue)
			DD.AddCheckBox(RB.lang.CONFIG_TOOLTIPPOS, RB.settings.actionbarTooltip.enabled, "actionbarTooltip", ToggleValue)
			DD.AddCheckMenu(sprintf(RB.lang.CONFIG_TOOLTIPSCALE, RB.settings.tooltipScale), false, "tooltipScale")
			DD.AddCheckBox(RB.lang.CONFIG_WOWCOLORS, RB.settings.useWoWColors, "useWoWColors", ToggleValue)
			DD.AddSeparator()
			DD.AddCheckBox(RB.lang.CONFIG_GUILDBEEP, RB.settings.beepGuild, "beepGuild", ToggleValue)
			DD.AddCheckBox(RB.lang.CONFIG_PARTYBEEP, RB.settings.beepParty, "beepParty", ToggleValue)
			DD.AddCheckBox(RB.lang.CONFIG_WISPERBEEP, RB.settings.beepWisper, "beepWisper", ToggleValue)
			DD.AddSeparator()
			DD.AddCheckBox("Debug", RB.settings.debug, "debug", ToggleValue)
		elseif UIDROPDOWNMENU_MENU_VALUE==2 then
			DD.AddCheckBox(RB.lang.CONFIG_AUTOREPAIR, RB.settings.autoRepair, "autoRepair", ToggleValue)
			DD.AddCheckBox(RB.lang.CONFIG_SKIPDIALOGS, RB.settings.skipDialogs, "skipDialogs", ToggleValue)
			DD.AddSeparator()
			DD.AddCheckBox(RB.lang.CONFIG_FRIENDPARTY, RB.settings.acceptPartyFriend, "acceptPartyFriend", ToggleValue)
			DD.AddCheckBox(RB.lang.CONFIG_GUILDPARTY, RB.settings.acceptPartyGuild, "acceptPartyGuild", ToggleValue)
			DD.AddCheckBox(RB.lang.CONFIG_FRIENDRIDE, RB.settings.acceptRideFriend, "acceptRideFriend", ToggleValue)
			DD.AddCheckBox(RB.lang.CONFIG_GUILDRIDE, RB.settings.acceptRideGuild, "acceptRideGuild", ToggleValue)
			DD.AddCheckBox(RB.lang.CONFIG_DECLINEDUELL, RB.settings.declineDuel, "declineDuel", ToggleValue)
			DD.AddSeparator()
			DD.AddCheckBox(RB.lang.CONFIG_AUTOAMULET, RB.settings.autoSwapAmulets, "autoSwapAmulets", ToggleValue)
			DD.AddCheckBox(RB.lang.CONFIG_AUTOAMMO, RB.settings.autoEquipAmmo, "autoEquipAmmo", ToggleValue)
			DD.AddCheckBox(RB.lang.CONFIG_FRIENDSYNC, RB.settings.friendSync, "friendSync", ToggleValue)
		end
	elseif UIDROPDOWNMENU_MENU_LEVEL==3 then
		if UIDROPDOWNMENU_MENU_VALUE=="tooltipScale" then
			for i=60, 100, 5 do
				DD.AddCheckBox(i.."%", i==RB.settings.tooltipScale, i, SetValue)
			end
		end
	end
end

function ME.Click(key, tooltip)
	local point, relativePoint, relativeTo, offsetX, offsetY = tooltip:GetAnchor(0)
	if key=="LBUTTON" then
		RB.modules.dropdown.ShowDropDown(tooltip, ME.DropDownHandler)
	elseif key=="RBUTTON" then
		ToggleMainPopupMenu()
		MainPopupMenu:ClearAllAnchors()
		MainPopupMenu:SetBackdrop(RB.Backdrop())
		MainPopupMenu:SetScale(RB.settings.tooltipScale/100)
		MainPopupMenu:SetAnchor(point, relativePoint, relativeTo, offsetX, offsetY)
		tooltip:Hide()
	elseif key=="MBUTTON" then
		CloseAllWindows()
		ReloadUI()
	end
end

RB.RegisterButton("config", ME)
