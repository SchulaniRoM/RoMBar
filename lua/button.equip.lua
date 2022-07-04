--======================== Dura ======================

local RB = _G.RoMBar
local ME = {
	icon			= {"Interface/gameicon/gameicon", 0.25, 0.375, 0.5, 0.625},
	events		= {"PLAYER_EQUIPMENT_UPDATE", "PLAYER_BAG_CHANGED", "BAG_ITEM_UPDATE", "STORE_OPEN"},
}

function ME.Update(event, ...)
	local aInv,aBag,dura	= 0, 0, 0
	local _,_,aName				= GetInventoryItemDurable("player", 9)
	if aName then
		aInv,aBag			= GetInventoryItemCount("player", 9), GetCountInBagByName(aName)
		if event=="PLAYER_BAG_CHANGED" and RB.settings["autoEquipAmmo"]==true and aInv<999 and aBag>0 and not CharacterFrame:IsVisible() then
			UseItemByName(aName)
			aInv,aBag		= GetInventoryItemCount("player", 9), GetCountInBagByName(aName)
		end
	end
	for i = 0, 16 do
		if i~=9 then
			local dVal, dMax, iName = GetInventoryItemDurable("player", i)
			if iName then
				dura			= ((dura==0 and 1 or dura) + (1 / dMax * math.min(dVal, dMax))) / 2
			end
		end
	end
	RB.UpdateButtonText(ME.name,
		sprintf("%s: %s", RB.lang.DURA, RB.ColorByPercent(dura, 1, false, sprintf("%s%%", RB.Dec(math.floor(100*dura))))),
		aName and sprintf("%s: %s%s%s", RB.lang.AMMO, RB.ColorByPercent(aInv, 999, false, aInv), RB.Separator(), RB.Dec(aBag)) or RB.lang.NOAMMO,
		RB.ColorByName("yellow", GetEuipmentNumber())
	)
end

function ME.STORE_OPEN()
	if RB.settings.autoRepair and GetEquipmentRepairAllMoney()>0 then
		ClickRepairAllButton()
	end
end

function ME.Tooltip(tooltip)
	local aName,aCount,sep = nil, 0, false
	for _,i in ipairs({0,1,2,3,4,5,6,7,8,10,11,12,13,14,15,16,17,21,18,19,20,9}) do
		local dVal, dMax, iName = GetInventoryItemDurable("player", i)
		local quali							= GetInventoryItemQuality("player", i)
		if iName then
			if i==9 then
				tooltip:AddSeparator()
				tooltip:AddDoubleLine(sprintf("%s%s%s", RB.lang.EQUIP_SLOT9, RB.Separator(), iName), sprintf("x%d", GetInventoryItemCount("player", 9)))
			else
				if i==18 then tooltip:AddSeparator() end
				iName		= RB.ColorByRarity(quali, iName)
				dVal		= RB.ColorByPercent(dVal, math.min(100, dMax))
				dMax		= dMax>100 and "|cff00ff00"..dMax.."|r" or tostring(dMax)
				if i>=18 and i<=20 then
					tooltip:AddDoubleLine(iName, sprintf("%s%s%s", dVal, RB.Separator(), dMax))
				else
					tooltip:AddDoubleLine(sprintf("%s%s%s", RB.lang["EQUIP_SLOT"..i], RB.Separator(), iName), sprintf("%s%s%s", dVal, RB.Separator(), dMax))
				end
			end
		end
	end
	if GetEquipmentRepairAllMoney()>0 then
		tooltip:AddSeparator()
		tooltip:AddDoubleLine(RB.lang.REPAIR_COSTS..":", "|cffFFFF00"..RB.Dec(GetEquipmentRepairAllMoney()).."|r")
	end
end

local RepairItem_running = fale
local function RepairItem()
	if RepairItem_running==true then return else RepairItem_running = true end
	local hID, rDone = 201967, 0

	for i=0,21 do
		if i==9 then i=10 end
		local dVal, dMax, iName = GetInventoryItemDurable("player", i)
		local quali							= GetInventoryItemQuality("player", i)
		if iName and dVal<dMax and dVal<101 then
			if GetBagItemCount(hID)>0 then
				UseItemByName(TEXT("Sys"..hID.."_name"))
				PickupEquipmentItem(i)
				RB.Print(sprintf(RB.lang.EQUIP_REPAIRING, RB.ColorByRarity(quali, iName)))
				rDone	= rDone + 1
				coroutine.yield()
			else
				RB.Print(RB.lang.EQUIP_NOHAMMER)
				break
			end
		end
	end
	if rDone>0 then
		RB.Print(sprintf(RB.lang.EQUIP_REPDONE, rDone))
	else
		RB.Print(sprintf(RB.lang.EQUIP_NOREPAIR))
	end
	RepairItem_running = nil
end

function ME.Click(key, tooltip)
	if key=="LBUTTON" then
		ToggleCharacter("EquipmentFrame")
	elseif key=="RBUTTON" then
		SwapEquipmentItem(GetEuipmentNumber() % 2)
	elseif key=="MBUTTON" then
		StaticPopupDialogs["ROMBAR_REPAIR_ITEMS"] = {
			text 					= RB.lang.EQUIP_REPAIRDIALOG,
			button1 			= RB.ColorByRarity(201967, TEXT("Sys201967_name")),
			button2 			= RB.ColorByRarity(201014, TEXT("Sys201014_name")),
			whileDead 		= 0,
			exclusive 		= 1,
			showAlert 		= 0,
			hideOnEscape	= 1,
			OnShow = function(this)
				StaticPopup_Resize(this, "ROMBAR_REPAIR_ITEMS")
			end,
			OnAccept = function()
				RB.RegisterEvent(ME.name, "COROUTINE", coroutine.create(RepairItem))
			end,
			OnCancel = function(this)
				UseItemByName(TEXT(Sys201014_name))
			end
		}
		StaticPopup_Show("ROMBAR_REPAIR_ITEMS")
	end
end

RB.RegisterButton("equip", ME)
