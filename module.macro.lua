--======================== Class ======================

local RB = _G.RoMBar
local ME = {
	exports		= {
		"FindString",	-- for developement
		"HasBuff",
		"HasDebuff",
		"HasQuest",
		"IsCasting",
		"RB_Kitty",
		"TargetNearestEnemy",
		"TargetUnitByName",
		"FocusUnitByName",
		"UnitIsCasting",
		"GetNpcID",
		"GetPosition",
		"SH_loot",
		"SH_unbox",
	},
}

function ME.Init()
	for _,func in pairs(ME.exports) do
		if ME[func] then
			if _G[func] then
				RB.Hook(_G, func, ME[func])
			else
				_G[func] = ME[func]
			end
		end
	end
end

function ME.FindString(str, root)
	local k,v,i,t1,t2
	for k,v in pairs(root or _G) do
		if tostring(v):match(str) then
			RB.Print("found in", tostring(k), ":", tostring(v))
		end
	end
	for i=100000,999999 do
		t1 = "Sys"..i.."_name"	t2 = TEXT(t1)
		if t1~=t2 and t2:match(str) then
			RB.Print("found in", i, ":", t1, t2)
		end
		t1 = "SC_"..i.."_S"	t2 = TEXT(t1)
		if t1~=t2 and t2:match(str) then
			RB.Print("found in", i, ":", t1, t2)
		end
		for j=0,9 do
			t1 = "SO_"..i.."_"..j	t2 = TEXT(t1)
			if t1~=t2 and t2:match(str) then
				RB.Print("found in", i, ":", t1, t2)
			end
		end
	end
	RB.Print("--- ende ---")
end

local function CheckBuff(ID_Name, debuff, target)
	local t, n, d		= target or "player", 0, debuff==true or false
	local id, name	= type(ID_Name)=="number" and ID_Name or nil, type(ID_Name)=="string" and ID_Name or nil
	repeat n = n + 1
		_name, _icon, _count, _id, _params = debuff and UnitDebuff(t, n) or UnitBuff(t, n)
		if name and (_id==id or _name==name) then
			return _name, _id, _count, _params
		end
	until not _id
	return nil, nil, nil, nil
end

function ME.HasDebuff(ID_Name, target)
	return CheckBuff(ID_Name, true, target)
end

function ME.HasBuff(ID_Name, target)
	return CheckBuff(ID_Name, false, target)
end

function ME.HasQuest(id)
	for i=1,30 do
		if select(9, GetQuestInfo(i)) == id then
			return true
		end
	end
	return false
end

function ME.RB_Kitty(kittyToken)
	if kittyToken=="auto" then
		kittyToken = UnitClassToken("player")
	end
	if UnitIsDeadOrGhost("target") then
		CastSpellByName(TEXT("Sys540000_name"))
		TargetUnit()
	elseif not UnitName(t) then
		TargetNearestEnemy()
	end
	if UnitName(t) then
		Kitty.attack(kittyToken or nil)
	end
end

function ME.TargetNearestEnemy(reverse)
	local orig,first = RB.GetOriginalFunction(_G, "TargetNearestEnemy"), 0
	for i=1,20 do
		orig(reverse)
		if UnitName("target") and not UnitIsDeadOrGhost("target") then
			if i==1 then
				first = UnitGUID("target")
			elseif UnitGUID("target")==first then
				break
			end
			if UnitName("targettarget")==UnitName("player") then
				break
			end
		end
	end
end

function ME.UnitIsCasting(pattern, target)
	local trgt = target or "player"
	local cast, tTime, cTime = UnitCastingTime(target)
	if cast and cast~="" and cTime<tTime then
		if castPattern then
			if cast==castPattern or string.find(cast, castPattern) then
				return true
			end
		end
	end
	return false
end

local function CheckName(pattern, target)
	target = target or "target"
	if type(pattern)~="table" then pattern = {pattern} end
	if UnitName(target) then
		for _,pat in pairs(pattern) do
			if UnitName(target)==tostring(pat) or UnitName(target):find(tostring(pat)) then
-- RB.Print("found:", UnitName(target))
				return true
			end
		end
	end
	return false
end

function ME.TargetUnitByName(pattern, friendly)
	local i, first = 0, nil
	repeat i = i + 1
		if UnitName("target") then
			first = first or UnitGUID("target")
-- 			RB.Print("'"..tostring(UnitName("target")).."'", UnitGUID("target"))
			if CheckName(pattern, "target") then return true end
		end
		if friendly==true then TargetNearestFriend() else TargetNearestEnemy() end
	until not UnitName("target") or first==UnitGUID("target") or i>=30
-- RB.Print("not found")
	TargetUnit()
	return false
end

function ME.FocusUnitByName(pattern, friendly)
	local i
	for i=1,12 do
		if UnitName("focus"..i)==nil then
			break
		elseif CheckName(pattern, "focus"..i) then
			TargetUnit("focus"..i)
			return i
		end
	end
	if TargetUnitByName(pattern, friendly) then
		FocusUnit(i, "target")
		return i
	else
		return false
	end
end

function ME.GetPosition()
	local m		= GetCurrentWorldMapID()
	local z,n = GetZoneID(), GetZoneName()
	local x,y = GetPlayerWorldMapPos(m)
	DEFAULT_CHAT_FRAME:AddMessage(sprintf("zone: %s (%d) xPos: %.10f yPos: %.10f", n, z, x, y))
end

function ME.GetNpcID(target)
	target = target or "target"
	DEFAULT_CHAT_FRAME:AddMessage(sprintf("npcID of %s: %d", target, UnitGUID(target)))
end

function ME.SH_loot()
	local i, n = 0, "Geheimnisvolle"
	if UnitName("target")==nil then
		TargetUnit("player")
	end
	if string.match(UnitName("target"), n)==n then
		FocusUnit(1, "target")
	end
	repeat
		if string.match(UnitName("target"), n)~=n or UnitIsUnit("player", "focus1")==false then
			TargetNearestFriend()
			i=i+1
		end
	until i==40 or string.match(UnitName("target"), n)==n
	if string.match(UnitName("target"), n)~=n then
		TargetUnit("player")
	end
	if string.match(UnitName("target"), n)==n then
		FocusUnit(1, "target")
		CastSpellByName("Angreifen")
	end
end

function ME.SH_unbox()
	ITEM_QUEUE_FRAME_UPSATETIME = 0
	ITEM_QUEUE_FRAME_INSERTITEM = 0
	_G.NEXT_CHEST = _G.NEXT_CHEST or 203256
	function run()
		local _,s,_ = GetBagCount()
		local b			= GetBagItemCount(_G.NEXT_CHEST)
		if s>3 and b>0 then
			UseItemByName(TEXT("Sys".._G.NEXT_CHEST.."_name"))
			return true
		else
			return false
		end
	end
	while not run() do
		_G.NEXT_CHEST = _G.NEXT_CHEST + 1
		if _G.NEXT_CHEST==203266 then
			_G.NEXT_CHEST = 208361
		end
		if _G.NEXT_CHEST==208371 then
			_G.NEXT_CHEST = 203256
			break
		end
	end
end

RB.RegisterModule("macro", ME)
