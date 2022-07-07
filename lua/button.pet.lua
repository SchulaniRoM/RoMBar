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
	if GetPetCount()==0 then
		ME.actions.RBUTTON.disabled = true
		ME.actions.MBUTTON.disabled = true
	else
		ME.actions.RBUTTON.disabled = false
		if GetActivePetSlot() then
			ME.icon	= "Interface/Icons/shop_goods/pet_egg_09"
			ME.actions.MBUTTON.disabled = true
			ME.actions.LBUTTON.text			= RB.lang.PET_RECALL
		else
			ME.icon	= "Interface/Icons/pet_goods/pet_goods_003"
			ME.actions.MBUTTON.disabled = false
			ME.actions.LBUTTON.text			= RB.lang.PET_SUMMON
		end
	end
	RB.UpdateButtonIcon(ME.name)
-- 	RB.UpdateButtonText(nil, nil, GetActivePetSlot())
end

function ME.Tooltip(tooltip)
	if GetPetCount()>0 then
		for i=1,6 do
			if HasPetItem(i) then
				local name	= GetPetItemName(i)
				local level	= GetPetItemLevel(i)
				local prop	= RB.lang["PET_PROP"..GetPetItemProperty(i)]
				local h			= GetPetItemAbility(i, "HUNGER")
				local l			= GetPetItemAbility(i, "LOYAL")
				tooltip:AddDoubleLine(
					sprintf("%d: %s %d (%s)", i, name, level, prop),
					sprintf("%s: %s%s%s: %s", RB.lang.PET_HUNGER_SHORT, RB.ColorByPercent(h, 100), RB.Separator(), RB.lang.PET_LOYAL_SHORT, RB.ColorByPercent(l, 100))
				)
			end
		end
	else
		tooltip:AddLine(RB.lang.PET_NOPET)
	end
end

local function FeedPet(petSlot)
	local food = {
		[204510]	= { loyal = 1 },
		[204925]	= { hunger = 10 },
	}
	local petSlot	= RB.settings.lastPetSlot or 0
	if not petSlot or petSlot<1 or petSlot>6 then
		for i=6,1,-1 do
			if IsPetStarUse(i)~=nil then
				petSlot = i
			end
		end
	end

	RB.settings.lastPetSlot	= petSlot
	local h	= GetPetItemAbility(petSlot, "HUNGER")
	local l	= GetPetItemAbility(petSlot, "LOYAL")

-- 	/run slot,food,feed=1,"Nahrhafter Käse",10
-- /run name=GetPetItemName(slot) if IsPetSummoned(slot) then DEFAULT_CHAT_FRAME:AddMessage("Ab ins Körbchen "..name.."...") ReturnPet(slot)
-- else h=GetPetItemAbility(slot,"HUNGER") if h<80 then for i=1,180 do id,_,f=GetBagItemInfo(i) if f==food then break else id=0 end end if id~=0 then PickupBagItem(id) ClickPetFeedItem() for i=h,100,feed do FeedPet(slot) end end end DEFAULT_CHAT_FRAME:AddMessage("Dein Auftritt "..name.."...") SummonPet(slot) end

end

local function CallPet(petSlot)
	petSlot	= petSlot or RB.settings.lastPetSlot or 1
	RB.settings.lastPetSlot	= petSlot
	local name = GetPetItemName(petSlot)
	if name then
		if IsPetSummoned(petSlot) then
			RB.Print(RB.Format(RB.lang.PET_CHATMSG_RECALL, {name = name}, 0, 1, 0))
			ReturnPet(petSlot)
			ME.Update()
		else
			RB.Print(RB.Format(RB.lang.PET_CHATMSG_SUMMON, {name = name}, 0, 1, 0))
			SummonPet(petSlot)
			ME.Update()
		end
	end
end

function ME.Click(key, tooltip)
	if key=="LBUTTON" then
		CallPet(RB.settings.lastPetSlot)
	elseif key=="RBUTTON" then
		ToggleUIFrame(PetFrame)
	elseif key=="MBUTTON" then
		RB.RegisterEvent(ME.name, "COROUTINE", coroutine.create(FeedPet))
	end
end

RB.RegisterButton("pet", ME)
