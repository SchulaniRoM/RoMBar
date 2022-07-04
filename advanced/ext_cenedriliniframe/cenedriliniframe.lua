function ExtraWeekInstanceInfoFrame_OnShow(this)
	local c = {}
	local i = string.sub(this:GetParent():GetName(), 22)
	fsName = getglobal("WeekInstanceInfoFrame" .. i .. "Level")
	n = i - 1 + 250000
	c = {0.2, 0.2, 1} -- blue
	if math.mod(i,3) == 1 then
		c = {1, 0, 0} -- red
	end
	if math.mod(i,3) == 2 then
		c = {0, 1, 0} -- green
	end	
	fsName:SetText("90      "..string.format("|cff%02x%02x%02x%s|r", c[1] * 255, c[2] * 255, c[3] * 255, GetObjName(n)))
end