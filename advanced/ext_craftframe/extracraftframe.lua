function ExtraCraftSkillButtons_OnLoad(this)
	this:RegisterEvent("VARIABLES_LOADED")
	this:RegisterEvent("PLAYER_LIFESKILL_CHANGED")
end

function ExtraCraftSkillButtons_OnEvent(this, event)
	local topString = getglobal(this:GetName().."Top")
	local bottomString = getglobal(this:GetName().."Bottom")
	local curValue = GetPlayerCurrentSkillValue(CraftSkillID[this:GetParent():GetID()])
	local lv = math.floor(curValue)
	local exp = (curValue - lv) * 100
	if exp > 99.99 then
		exp = 99.99
	end
	local strValue = string.format("%.2f%%" , exp)
	local strLevel = C_LEVEL..lv
	if lv >= 1 then
		local r, g, b = GetRankQualityColor(this)
		topString:SetColor(r, g, b)
		topString:SetText(strLevel)
		bottomString:SetText(strValue)
	else
		topString:SetText("")
		bottomString:SetText("")
	end
end

function GetRankQualityColor(this)
	local maxValue = GetPlayerMaxSkillValue(CraftSkillID[this:GetParent():GetID()])
	local r, g, b
	if maxValue >= 61 then
		r = 0.9609375
		g = 0.5546875
		b = 0.3359375
	elseif maxValue >= 41 then
		r = 0.78125
		g = 0.01953125
		b = 0.96875
	elseif maxValue >= 21 then
		r = 0
		g = 0.4453125
		b = 0.734375
	else
		r = 0
		g = 0.99609375
		b = 0
	end
	return r, g, b
end