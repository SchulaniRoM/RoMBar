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
	RB.Debug("SetValue", UIDROPDOWNMENU_MENU_VALUE, this.value)
	if RB.settings[UIDROPDOWNMENU_MENU_VALUE] then
		RB.settings[UIDROPDOWNMENU_MENU_VALUE]	= this.value
		RB.UpdateUI()
	end
	UIDropDownMenu_Refresh(RB.modules.dropdown.GetDropDownFrame())
end

local function SetAutoRepairSlot(this)
	RB.Debug("SetAutoRepairSlot", UIDROPDOWNMENU_MENU_VALUE, this.value)
	RB.settings.autoRepairSlots[this.value] = not RB.settings.autoRepairSlots[this.value]
end

function ME.Title()
	return RB.Lang(ME.name, "TITLE", {RB.addonVersion}, "RoMBar Configuration")
end

function ME.DropDownHandler()
	local DD = RB.modules.dropdown
	if (UIDROPDOWNMENU_MENU_LEVEL or 1)==1 then
		DD.AddTitle(ME.Title())
		DD.AddMenu(RB.Lang(ME.name, "INTERFACE"), 1)
		DD.AddMenu(RB.Lang(ME.name, "AUTOMATIC"), 2)
	elseif UIDROPDOWNMENU_MENU_LEVEL==2 then
		if UIDROPDOWNMENU_MENU_VALUE==1 then
			DD.AddCheckBox(RB.Lang(ME.name, "ONTOP"), 						RB.settings.top,											"top",									ToggleValue)
			DD.AddCheckBox(RB.Lang(ME.name, "ORIGINALUI"), 				RB.settings.originalUI,								"originalUI",						ToggleValue)
			DD.AddSeparator()
			DD.AddCheckBox(RB.Lang(ME.name, "CLICK2MOVE"), 				GC_GetMouseMoveEnable(),							"click2move",						ToggleValue)
			DD.AddCheckBox(RB.Lang(ME.name, "LOCKAB"), 						GetActionBarLocked(),									"lockAB",								ToggleValue)
			DD.AddCheckBox(RB.Lang(ME.name, "TOOLTIPPOS"),				RB.settings.actionbarTooltip.enabled,	"actionbarTooltip",			ToggleValue)
			DD.AddCheckMenu(RB.Lang(ME.name, "TOOLTIPSCALE"),			true,																	"tooltipScale")
			DD.AddCheckBox(RB.Lang(ME.name, "WOWCOLORS"),					RB.settings.useWoWColors,							"useWoWColors",					ToggleValue)
			DD.AddSeparator()
			DD.AddCheckBox(RB.Lang(ME.name, "GUILDBEEP"),					RB.settings.beepGuild,								"beepGuild",						ToggleValue)
			DD.AddCheckBox(RB.Lang(ME.name, "PARTYBEEP"),					RB.settings.beepParty,								"beepParty",						ToggleValue)
			DD.AddCheckBox(RB.Lang(ME.name, "WISPERBEEP"),				RB.settings.beepWisper,								"beepWisper",						ToggleValue)
			DD.AddSeparator()
			DD.AddCheckBox("Debug",																RB.settings.debug,										"debug",								ToggleValue)
		elseif UIDROPDOWNMENU_MENU_VALUE==2 then
			DD.AddCheckBox(RB.Lang(ME.name, "AUTOREPAIR"),				RB.settings.autoRepair,								"autoRepair",						ToggleValue)
			DD.AddCheckMenu(RB.Lang(ME.name, "AUTOREPAIRSLOTS"),	RB.settings.autoRepairSlots.enabled,	"autoRepairSlots",			ToggleValue)
			DD.AddCheckBox(RB.Lang(ME.name, "SKIPDIALOGS"),				RB.settings.skipDialogs,							"skipDialogs",					ToggleValue)
			DD.AddCheckBox(RB.Lang(ME.name, "BOSSBELL"),					RB.settings.bossBell,									"bossBell",							ToggleValue)
			DD.AddSeparator()
			DD.AddCheckBox(RB.Lang(ME.name, "FRIENDSYNC"),				RB.settings.friendSync,								"friendSync",						ToggleValue)
			DD.AddCheckBox(RB.Lang(ME.name, "HOUSEFRIEND"),				RB.settings.autoHouseFriend,					"autoHouseFriend",			ToggleValue)
			DD.AddSeparator()
			DD.AddCheckBox(RB.Lang(ME.name, "FRIENDPARTY"),				RB.settings.acceptPartyFriend,				"acceptPartyFriend",		ToggleValue)
			DD.AddCheckBox(RB.Lang(ME.name, "GUILDPARTY"),				RB.settings.acceptPartyGuild,					"acceptPartyGuild",			ToggleValue)
			DD.AddCheckBox(RB.Lang(ME.name, "FRIENDRIDE"),				RB.settings.acceptRideFriend,					"acceptRideFriend",			ToggleValue)
			DD.AddCheckBox(RB.Lang(ME.name, "GUILDRIDE"),					RB.settings.acceptRideGuild,					"acceptRideGuild",			ToggleValue)
			DD.AddCheckBox(RB.Lang(ME.name, "FRIENDTRADE"),				RB.settings.acceptTradeGuild,					"acceptTradeGuild",			ToggleValue)
			DD.AddCheckBox(RB.Lang(ME.name, "GUILDTRADE"),				RB.settings.acceptTradeGuild,					"acceptTradeGuild",			ToggleValue)
			DD.AddCheckBox(RB.Lang(ME.name, "PARTYTRADE"),				RB.settings.acceptTradeParty,					"acceptTradeParty",			ToggleValue)
			DD.AddCheckBox(RB.Lang(ME.name, "AUTOTRADE"),					RB.settings.autoTrade,								"autoTrade",						ToggleValue)
			DD.AddCheckBox(RB.Lang(ME.name, "DECLINEDUELL"),			RB.settings.declineDuel,							"declineDuel",					ToggleValue)
			DD.AddSeparator()
			DD.AddCheckBox(RB.Lang(ME.name, "AUTOAMULET"),				RB.settings.autoSwapAmulets,					"autoSwapAmulets",			ToggleValue)
			DD.AddCheckBox(RB.Lang(ME.name, "AUTOAMMO"),					RB.settings.autoEquipAmmo,						"autoEquipAmmo",				ToggleValue)
		end
	elseif UIDROPDOWNMENU_MENU_LEVEL==3 then
		if UIDROPDOWNMENU_MENU_VALUE=="tooltipScale" then
			for i=60, 100, 5 do
				DD.AddCheckBox(i.."%", i==RB.settings.tooltipScale, i, SetValue)
			end
		end
		if UIDROPDOWNMENU_MENU_VALUE=="autoRepairSlots" then
			for i=1, 17 do
				if i~=9 and i~=8 then
					DD.AddCheckBox(RB.Lang("equip", "SLOT"..i), RB.settings.autoRepairSlots[i], i, SetAutoRepairSlot)
				end
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
