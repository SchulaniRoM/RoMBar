--======================== Class ======================

local RB = _G.RoMBar
local ME = {
	icon		= "Interface/buttons/characterabilitypoint-normal",
}

function ME.Init()
	return true
end

function ME.Click(key, tooltip)
	if key=="LBUTTON" then
 		ToggleUIFrame(MacroFrame)
	elseif key=="MBUTTON" then
		local cmd = {}
		for k,v in pairs(_G.SlashCmdList) do
			cmd[k] = cmd[k] or {}
			local i=1 while _G["SLASH_"..k..tostring(i)]~=nil do
				cmd[k][_G["SLASH_"..k..tostring(i)]] = true
				i = i + 1
			end
		end
		RB.Print("available commands")
		for k,v in pairs(cmd) do
			local t = ""
			for j in pairs(v) do
				t = (t=="" and "" or t.." ")..j
			end
			RB.Print(sprintf("  [%s] |cffffffff%s|r", k, t))
		end
	elseif key=="RBUTTON" then
	end
end

RB.RegisterButton("macro", ME)
