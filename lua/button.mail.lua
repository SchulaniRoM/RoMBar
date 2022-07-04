--======================== Mail ======================

local RB = _G.RoMBar
local ME = {
	icon			= RB.addonPath.."/textures/icon_mail",
	events		= {"MAIL_SHOW", "CHAT_MSG_SYSTEM"},
}

function ME.Update(event, txt)
	if event=="MAIL_SHOW" then
		RB.settings["mail"] = math.max(0, RB.settings["mail"] - 30)
	elseif event=="CHAT_MSG_SYSTEM" and txt==TEXT("SYS_NEW_MAIL") then
		RB.settings["mail"] = RB.settings["mail"] + 1
	end
	RB.UpdateButtonText("mail",
		nil,
		nil,
		sprintf("|cff00ff00%s|r", RB.settings["mail"]>0 and tostring(RB.settings["mail"]) or "")
	)
end

function ME.Click(key, tooltip)
	if key=="LBUTTON" then
		if TimeLet_GetLetTime("MailLet")>0 then
			OpenMail()
		elseif GetBagItemCount(201136)>0 then
			UseItemByName(TEXT("Sys201136_name"))
		else
			StaticPopup_Show("TIMEFLAG_FAIL1")
		end
	elseif key=="MBUTTON" then
		if TimeLet_GetLetTime("AuctionLet")>0 then
			OpenAuction()
		else
			StaticPopup_Show("TIMEFLAG_FAIL1")
		end
	elseif key=="RBUTTON" then
		ToggleUIFrame(TimeFlagFrame);
	end
end

function ME.Tooltip(tooltip)
	for k,v in pairs({201136}) do
		local cBag, cBank	= GetBagItemCount(v), RB.GetBankItemCount(v)
-- 		if cBag+cBank>0 then
			tooltip:AddDoubleLine(
				RB.ColorByRarity(v, TEXT("Sys"..v.."_name")),
				sprintf("%s%s%s", cBag>0 and RB.Dec(cBag) or "", cBag>0 and cBank>0 and RB.Separator() or "", cBank>0 and RB.Dec(cBank) or "")
			)
-- 		end
	end
end

RB.RegisterButton("mail", ME)
