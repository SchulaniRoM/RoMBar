--======================== Pet ======================

local RB = _G.RoMBar
local ME = {
	icon			= "Interface/Icons/pet_goods/pet_goods_003",
	events		= {"PET_SUMMON_SUCCEED", "PET_RETURN_SUCCEED", "PET_COUNT_CHANGE"}
}

local function GetActivePetSlot()
	for i=1,6 do
		if IsPetSummoned(i) then
			return i
		end
	end
	return nil
end

local function GetPetCount()
	local cnt = 0
	for i=1,6 do
		if HasPetItem(i) then
			cnt = cnt + 1
		end
	end
	return cnt
end

function ME.Update(event, ...)
	local oldIcon, petSlot = ME.icon, GetActivePetSlot()
	if GetPetCount()==0 then
		ME.icon											= "Interface/Icons/Icon-Default"
		ME.actions.LBUTTON.text			= RB.Lang(ME.name, "NOPET")
		ME.actions.RBUTTON.disabled = true
		ME.actions.MBUTTON.disabled = true
	elseif petSlot then
		ME.icon											= GetEggIcon(petSlot)
		ME.actions.LBUTTON.text			= RB.Lang(ME.name, "RECALL")
		ME.actions.RBUTTON.disabled = false
		ME.actions.MBUTTON.disabled = true
	else
		ME.icon											= "Interface/Icons/pet_goods/pet_goods_003"
		ME.actions.LBUTTON.text			= RB.Lang(ME.name, "SUMMON")
		ME.actions.RBUTTON.disabled = false
		ME.actions.MBUTTON.disabled = false
	end
	if oldIcon~=ME.icon then
		RB.UpdateButtonIcon(ME.name)
		RB.UpdateButtonText(nil, nil, petSlot)
	end
end

function ME.Tooltip(tooltip)
	if GetPetCount()>0 then
		for i=1,6 do
			if HasPetItem(i) then
				local name	= GetPetItemName(i)
				local level	= GetPetItemLevel(i)
				local prop	= RB.Lang(ME.name, "PROP"..GetPetItemProperty(i))
				local h			= GetPetItemAbility(i, "HUNGER")
				local l			= GetPetItemAbility(i, "LOYAL")
				RB.AddToTooltip(
					sprintf("%d: %s %d (%s)", i, name, level, prop),
					{
				   RB.Lang(ME.name, "HUNGER_SHORT", {RB.ColorByPercent(h, 100)}),
				   RB.Lang(ME.name, "LOYAL_SHORT", {RB.ColorByPercent(l, 100)})
				  }
				)
			end
		end
	else
		RB.AddToTooltip(RB.Lang(ME.name, "NOPET"))
	end
end

local function FeedPet_coroutine()
end

local function PetFeeding(petSlot)
	if GetActivePetSlot()==petSlot or not HasPetItem(petSlot) then return end

	local l,h	= GetPetItemAbility(petSlot, "LOYAL"), GetPetItemAbility(petSlot, "HUNGER")
	local name = GetPetItemName(petSlot)
	if h<=90 then
		for i=1,180 do
			local id, _, item, count, locked = GetBagItemInfo(i)
			if not locked and item==TEXT("Sys204925_name") then
				PickupBagItem(id)
				ClickPetFeedItem()
				while h<=90 and count>0 do
					coroutine.yield()
-- 					FeedPet(petSlot)
					h = h + 10
					count = count - 1
					RB.Print(sprintf("Feeding %s to %s...", item, name))
				end
				ClearPetFeedItem()
				if CursorHasItem() then CancelPendingItem() end
			end
			if h>90 then break end
		end
	else
		RB.Print("no need to feed")
	end
end

local function CallPet(petSlot)
	petSlot	= (petSlot or RB.settings.lastPetSlot) or 1
	RB.settings.lastPetSlot	= petSlot
	local name = GetPetItemName(petSlot)
	if name then
		if IsPetSummoned(petSlot) then
			RB.Print(RB.Lang(ME.name, "CHATMSG_RECALL", {name}))
			ReturnPet(petSlot)
			ME.Update()
		else
			RB.Print(RB.Lang(ME.name, "CHATMSG_SUMMON", {name}))
			SummonPet(petSlot)
			ME.Update()
		end
	end
end

function ME.Click(key, tooltip)
	if key=="LBUTTON" then
		if GetPetCount()>0 then
			tooltip:Hide()
			CallPet(RB.settings.lastPetSlot)
		end
	elseif key=="RBUTTON" then
		ToggleUIFrame(PetFrame)
	elseif key=="MBUTTON" then
		tooltip:Hide()
		RB.RegisterCoroutine(ME.name, coroutine.create(PetFeeding))
	end
end

RB.RegisterButton("pet", ME)
