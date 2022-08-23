--======================== HDE-Time ======================

local RB = _G.RoMBar
local ME = {
	zoneID			= 2,
	zoneName		= TEXT("ZONE_VARANAS ADMINISTRATION"),
	npcName			= TEXT("Sys123635_name"),
	npcText			= TEXT("SC_AC2_CHECK_MONEY"),
	goal				= 200000000,
	running			= false,
}

local function SaveScore(score)
	RB.global.hdeTime = RB.global.hdeTime or {}
	if OS_BASETIME>0 and os.date("%Y")~="1970" then
		local entry				= {time = math.floor(os.time()), score = score}
		if #RB.global.hdeTime<1 or RB.global.hdeTime[1].score>score then RB.global.hdeTime[1] = entry end
		RB.global.hdeTime[2] = entry
		SendSystemChat(sprintf("current hdescore: %s/%s", MoneyNormalization(score), MoneyNormalization(ME.goal)))
	else
		SendSystemChat("wrong time. hde-score not saved")
	end
end

local function ZoneChanged(event, arg1)
	if event=="LOADING_END" or event=="ZONE_CHANGED" then
		if GetZoneID()==ME.zoneID and GetZoneName()==ME.zoneName then
			if ME.running~=true and os.time then
				SendSystemChat("entering zone "..ME.zoneName)
				RB.RegisterEvent(ME.name, "SHOW_QUESTLIST", ZoneChanged)
				ME.running = true
			end
		elseif ME.running==true then
			SendSystemChat("leaving zone "..ME.zoneName)
			RB.UnregisterEvent(ME.name, "SHOW_QUESTLIST")
			ME.running = false
		end
	elseif event=="SHOW_QUESTLIST" and ME.running then
		if GetSpeakObjName()==ME.npcName then
			ME.npcText	= ME.npcText:gsub("(%[$VAR1%])", "")
			local text	= GetSpeakDetail()
			if ME.npcText==text:gsub("(%d)", "") then
				local score = text:match("(%d+)")
				SaveScore(score)
				SendSystemChat(ME.GetScoring())
			end
		end
	end
end

function ME.GetScoring()
	RB.global.hdeTime = RB.global.hdeTime or {}
	local diffTime		= RB.global.hdeTime[2].time - RB.global.hdeTime[1].time
	local diffScore		= RB.global.hdeTime[2].score - RB.global.hdeTime[1].score
	if diffTime>0 and diffScore>0 then
		local perSec		= diffScore / diffTime
		local leftScore	= ME.goal - RB.global.hdeTime[2].score
		local leftTime	= leftScore / perSec
		return sprintf("scores left: %s - average scores per second: %s\ntime left: %ss - %s",
			MoneyNormalization(leftScore), MoneyNormalization(math.floor(perSec)), MoneyNormalization(leftTime), os.date("%d.%m.%Y %H:%I", RB.global.hdeTime[2].time+leftTime)
		)
	end
	return ""
end

function ME.Init()
	RB.RegisterEvent(ME.name, {"LOADING_END", "ZONE_CHANGED"}, ZoneChanged)
end

RB.RegisterModule("hdetime", ME)
