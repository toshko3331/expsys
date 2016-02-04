--TODO: Please for gods sake, find a graceful way to handle the maximum possible level. OR WAIT, should all that stuff be 
--handled by the server? Actually this makes sense. So maybe just do nothing here because that is too much data to query and 
--it also seems like boiler plate code. GG EZ.
XPSYS = {}
XPSYS.XP = 0
XPSYS.level = 1
XPSYS.XPOfNextLevel = 1

--[[---------------------------------------------------------
   Name: XPSYS.UpdateXP()
   Desc: Updates the level on the client
-----------------------------------------------------------]]

function XPSYS.UpdateXP(len)
--TODO:Add some checks to see if is player(?)
	XPSYS.XP = net.ReadInt(32)
	XPSYS.level = net.ReadInt(32)
	XPSYS.XPOfNextLevel = net.ReadInt(32)
	print("I have been updated! \n XP: "..XPSYS.XP.."\n Level: "..XPSYS.level)
	print("The next level's required XP is: "..XPSYS.XPOfNextLevel)
end
net.Receive("UpdateXP",XPSYS.UpdateXP)

--[[---------------------------------------------------------
   Name: XPSYS.PrintXP()
   Desc: Prints the your XP
-----------------------------------------------------------]]

function XPSYS.PrintExp()
	print(XPSYS.XP)
end
concommand.Add("print_xp",XPSYS.PrintExp)

hook.Add( "HUDPaint", "HelloThere", function()
	draw.DrawText( "Level: "..XPSYS.level, "DermaLarge", ScrW() * 0.07 , ScrH() * 0.85, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER )
end )

--[[---------------------------------------------------------
   Name: XPSYS.HUDOverHead()
   Desc: Hud thing thats being developed
-----------------------------------------------------------]]

function XPSYS.HUDOverHead()
	local ply = LocalPlayer()
	
	for id,target in pairs(ents.FindByClass("Player")) do
		local name = tostring(target:Nick())
		
		local steamid = tostring(target:SteamID())
		local targetPos = target:GetPos() + Vector(0,0,35)
		
		local targetDistance = math.floor((target:GetPos():Distance( targetPos ))/40)
		
		local targetScreenpos = targetPos:ToScreen()
		if targetDistance > 20 then end
		if targetDistance < 20 then
			surface.SetTextColor(200,25,25,255)
			surface.SetFont( "Default" )
			surface.SetTextPos( tonumber(targetScreenpos.x), tonumber(targetScreenpos.y))
			surface.DrawText("Player Level: Test  ".. target:GetVar("level", 1 ))-- Broken
	end
	end
end
hook.Add( "HUDPaint", "DrawStuff", XPSYS.HUDOverHead )

--[[---------------------------------------------------------
   Name: XPSYS.XPBarDraw()
   Desc: Experience bar drawing function.
-----------------------------------------------------------]]

function XPSYS.XPBarDraw()
		draw.RoundedBox( 7,  ScrW()/4, ScrH()/1.08, ScrW()/2, 20, Color(255,174,26,200) )
		local ratio = XPSYS.XP / XPSYS.XPOfNextLevel
		
		if ratio <= 0.01 then
			ratio = 0.01
		end
		draw.RoundedBoxEx( 5,ScrW()/4, ScrH()/1.08, (ScrW()/2) * ratio, 20, Color(26,107,255,255),true,false,true,false)
		

end

hook.Add( "HUDPaint", "Experience Bar", XPSYS.XPBarDraw )
