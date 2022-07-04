--======================== Pet ======================

local RB = _G.RoMBar
local ME = {
	icon			= "Interface/Icons/shop_goods/pet_egg_09",
}

function ME.Update(event, ...)
	RB.UpdateButtonText("pet")
	if RB.settings.lastPet and GetPetItemName(RB.settings.lastPet) then
		RB.Debug(LuaFunc_GetPetBookInfo(RB.settings.lastPet))
-- 		ME.icon =
	end
end

function ME.Tooltip(tooltip)
	local petFound = false
	for i=1,6 do
		if GetPetItemName(i) then
			local name	= GetPetItemName(i)
			local level	= GetPetItemLevel(i)
			local prop	= RB.lang["PET_PROP"..GetPetItemProperty(i)]
			local h			= GetPetItemAbility(i, "HUNGER")
			local l			= GetPetItemAbility(i, "LOYAL")
			tooltip:AddDoubleLine(
				sprintf("%d: %s %d (%s)", i, name, level, prop),
				sprintf("%s: %s%s%s: %s", RB.lang.PET_HUNGER_SHORT, RB.ColorByPercent(h, 100), RB.Separator(), RB.lang.PET_LOYAL_SHORT, RB.ColorByPercent(l, 100))
			)
			petFound = true
		end
	end
	if petFound then
		ME.actions.RBUTTON.disabled = false
		ME.actions.MBUTTON.disabled = false
	else
		ME.actions.RBUTTON.disabled = true
		ME.actions.MBUTTON.disabled = true
		tooltip:AddLine(RB.lang.PET_NOPET)
	end
end

local function FeedPet(petSlot)
	local food = {
		[204510]	= { loyal = 1 },
		[204925]	= { hunger = 10 },
	}
	local petSlot	= RB.settings.lastPet or 0
	if not petSlot or petSlot<1 or petSlot>6 then
		for i=6,1,-1 do
			if IsPetStarUse(i)~=nil then
				petSlot = i
			end
		end
	end

	RB.settings.lastPet	= petSlot
	local h	= GetPetItemAbility(petSlot, "HUNGER")
	local l	= GetPetItemAbility(petSlot, "LOYAL")

-- 	/run slot,food,feed=1,"Nahrhafter Käse",10
-- /run name=GetPetItemName(slot) if IsPetSummoned(slot) then DEFAULT_CHAT_FRAME:AddMessage("Ab ins Körbchen "..name.."...") ReturnPet(slot)
-- else h=GetPetItemAbility(slot,"HUNGER") if h<80 then for i=1,180 do id,_,f=GetBagItemInfo(i) if f==food then break else id=0 end end if id~=0 then PickupBagItem(id) ClickPetFeedItem() for i=h,100,feed do FeedPet(slot) end end end DEFAULT_CHAT_FRAME:AddMessage("Dein Auftritt "..name.."...") SummonPet(slot) end

end

local function CallPet(petSlot)
	petSlot	= petSlot or RB.settings.lastPet or 1
	RB.settings.lastPet	= petSlot
	name=GetPetItemName(petSlot)
	if IsPetSummoned(petSlot) then
		DEFAULT_CHAT_FRAME:AddMessage("Ab ins Körbchen "..name.."...", 0, 1, 0)
		ReturnPet(petSlot)
	else
		DEFAULT_CHAT_FRAME:AddMessage("Dein Auftritt "..name.."...")
		SummonPet(petSlot)
	end
end

function ME.Click(key, tooltip)
	if key=="LBUTTON" then
		ToggleUIFrame(PetFrame)
	elseif key=="RBUTTON" then
		CallPet(RB.settings.lastPet)
	elseif key=="MBUTTON" then
		RB.RegisterEvent(ME.name, "COROUTINE", coroutine.create(FeedPet))
	end
end

RB.RegisterButton("pet", ME)
