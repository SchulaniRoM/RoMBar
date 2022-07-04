--======================== sessional game events ======================

local RB = _G.RoMBar
local ME = {
	summerEvent 	= {},
	temp					= {},
}

function ME.Init()
	return true
end

local CO 	= ChoiceOption
local OC 	= function() return g_SpeakFrameData.count end
local ATT	= function() CastSpellByName(TEXT("Sys540000_name")) end
local OFF = SpeakFrame_Hide

function ME.summerEvent.Ailes(start)
	if UnitName("target")~="Ailes" then return RB.Error("target Ailes") end
	ME.temp.i, ME.temp.j = ME.temp.i or 0, ME.temp.j or 0
	if OC()<=1 then
		ATT()
 	elseif OC()==2 then
 		CO(1)
 	elseif OC()==6 then
 		if ME.temp.j==0 then
 			ME.temp.i = ME.temp.i + (ME.temp.i>5 and -5 or 1)
 		end
		CO(ME.temp.i)
	elseif OC()==10 then
		ME.temp.j = ME.temp.j + (ME.temp.j>9 and -9 or 1)
 		CO(ME.temp.j)
	end
	RB.Print(ME.temp.i, ME.temp.j)
end

function ME.summerEvent.Burton()
	if UnitName("target")~="Burton" then return RB.Error("target Burton") end
	ATT()
	if OC()==2 then CO(1) end
	if OC()==2 then CO(1) end
	if GetNumQuest(3)>0 then
		OnClick_QuestListButton(3, 1)
		CompleteQuest()
	end
	if GetNumQuest(1)>0 then
		OnClick_QuestListButton(1, 1)
		CompleteQuest()
	end
	OFF()
end

RB.RegisterModule("events", ME)
