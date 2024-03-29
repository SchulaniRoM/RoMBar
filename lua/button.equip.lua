--======================== Dura ======================

local RB = _G.RoMBar
local ME = {
	events		= {"PLAYER_EQUIPMENT_UPDATE", "PLAYER_BAG_CHANGED", "BAG_ITEM_UPDATE", "STORE_OPEN", "TP_EXP_UPDATE"},
	blacklist = {
		[221396] = 1, [221397] = 1, [221398] = 1, [221399] = 1,
		[221400] = 1, [221401] = 1, [221402] = 1, [221403] = 1,
	},
	slots			= {},
	slotOrder	= {0,1,2,3,4,5,6,7,8,10,11,12,13,14,15,16,17,21,18,19,20,9},
}

local function SwapAmulet(slot, name)
	if slot and type(slot)=="number" then
		UseEquipmentItem(slot)
		ME.slots[slot] = name
		RB.RegisterEvent(ME.name, "ONUPDATE", SwapAmulet)
	elseif slot=="ONUPDATE" then
		RB.UnregisterEvent(ME.name, "ONUPDATE")
		for i=18,20 do
			local name = ME.slots[i] or nil
			RB.Debug(ME.name, "-->", name)
			if name and GetCountInBagByName(name)>0 then
				UseItemByName(name)
			end
			ME.slots[i] = nil
		end
	end
end

function ME.Update(event, ...)
	RB.Debug(ME.name, event)
	local aInv,aBag,dura	= 0, 0, 0
	local _,_,aName				= GetInventoryItemDurable("player", 9)
	if aName then
		aInv,aBag			= GetInventoryItemCount("player", 9), GetCountInBagByName(aName)
		if event=="PLAYER_BAG_CHANGED" and RB.settings.autoEquipAmmo==true and aInv<999 and aBag>0 and not CharacterFrame:IsVisible() then
			UseItemByName(aName)
			aInv,aBag		= GetInventoryItemCount("player", 9), GetCountInBagByName(aName)
		end
	end
	for i = 0, 20 do
		if i>=18 then
			if RB.settings.autoSwapAmulets==true then
				local _,_,iName, dVal, dMax = GetInventoryItemDurable("player", i)
				if iName and ME.blacklist[name]==nil and ME.slots[i]~=iName then
					if dMax>0 and dVal==dMax then
						RB.Debug(ME.name, iName, dVal, dMax)
						SwapAmulet(i, iName)
					end
				end
			end
		elseif i~=9 and i~=17 then
			local dVal, dMax, iName = GetInventoryItemDurable("player", i)
			if iName then
				dura			= ((dura==0 and 1 or dura) + (1 / dMax * math.min(dVal, dMax))) / 2
			end
		end
	end
	RB.UpdateButtonText(ME.name,
		RB.Lang(ME.name, "DURA_SHORT", {RB.ColorByPercent(dura, 1, false, tostring(math.floor(100*dura)).."%%")}),
		aName and RB.Lang(ME.name, "AMMO_SHORT", {RB.ColorByPercent(aInv, 999, false)}) or RB.Lang(ME.name, "NOAMMO"),
		GetEuipmentNumber()
	)
	local oldIcon		= ME.icon
	_,_,ME.icon = GetSkillDetail(RB.GetSkillBookIndexes(TEXT("Sys540000_name")))

	if oldIcon~=ME.icon then
		RB.UpdateButtonIcon(ME.name)
	end
end

function ME.STORE_OPEN()
	if RB.settings.autoRepair and GetEquipmentRepairAllMoney()>0 then
		ClickRepairAllButton()
		ME.Update("PLAYER_EQUIPMENT_UPDATE")
	end
end

function ME.Tooltip(tooltip)
	local aName,aCount,sep = nil, 0, false
	for _,i in ipairs(ME.slotOrder) do
		local dVal, dMax, iName = GetInventoryItemDurable("player", i)
		local quali							= GetInventoryItemQuality("player", i)
		if iName then
			if i==9 then
				tooltip:AddSeparator()
				tooltip:AddDoubleLine(sprintf("%s%s%s", RB.Lang(ME.name, "SLOT9"), RB.Separator(), iName), sprintf("x%d", GetInventoryItemCount("player", 9)))
			else
				if i==18 then tooltip:AddSeparator() end
				iName		= RB.ColorByRarity(quali, iName)
				dVal		= RB.ColorByPercent(dVal, math.min(100, dMax))
				dMax		= dMax>100 and "|cff00ff00"..dMax.."|r" or tostring(dMax)
				if i>=18 and i<=20 then
					tooltip:AddDoubleLine(iName, sprintf("%s%s%s", dVal, RB.Separator(), dMax))
				else
					tooltip:AddDoubleLine(sprintf("%s%s%s", RB.Lang(ME.name, "SLOT"..i), RB.Separator(), iName), sprintf("%s%s%s", dVal, RB.Separator(), dMax))
				end
			end
		end
	end
	if GetEquipmentRepairAllMoney()>0 then
		RB.AddToTooltip("---")
		RB.AddToTooltip(RB.Lang(ME.name, "REPAIRCOSTS"), RB.ColorByName("GOLD", GetEquipmentRepairAllMoney()))
	end
end

function ME.Click(key, tooltip)
	if key=="LBUTTON" then
		ToggleCharacter("EquipmentFrame")
	elseif key=="MBUTTON" then
		SwapEquipmentItem((GetEuipmentNumber()) % CharactFrame_GetEquipSlotCount())
	elseif key=="RBUTTON" then
		RB.modules.dropdown.ShowDropDown(tooltip, ME.DropDownHandler)
	end
end

function ME.DropDownHandler()
	local DD,c,i 		= RB.modules.dropdown, 0
	local cH1, cH2	= GetBagItemCount(201967), GetBagItemCount(201014)
	if cH1>0 or cH2>0 then
		for _,i in ipairs(ME.slotOrder) do
			local dVal, dMax, iName = GetInventoryItemDurable("player", i)
			local quali							= GetInventoryItemQuality("player", i)
			if iName and dVal<dMax then
				if i~=9 and (i<18 or i>20) then
					c = c + 1
					local func = function(this)
						UseItemByName(TEXT("Sys201967_name"))
						PickupEquipmentItem(i)
						RB.Print(RB.Lang(ME.name, "REPAIRING", {RB.ColorByRarity(quali, iName)}))
						RB.modules.dropdown.RefreshDropDown(ME.DropDownHandler)
					end
					local tooltip = RB.Lang(ME.name, "NOHAMMER")
					DD.AddButton(RB.ColorByRarity(quali, iName), cH1>0 and func or nil, i, cH1<=0 and tooltip or nil)
				end
			end
		end
		if c==0 then
			DD.AddText(RB.Lang(ME.name, "NOREPAIR"))
		elseif cH2>0 then
			DD.AddSeparator()
			DD.AddButton(RB.ColorByRarity(201014, TEXT("Sys201014_name")).." x"..cH2, function(this) UseItemByName(TEXT("Sys201014_name")) end)
		end
	else
		DD.AddText(RB.Lang(ME.name, "NOHAMMER"))
	end
end

RB.RegisterButton("equip", ME)
