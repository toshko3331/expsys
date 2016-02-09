XPSYS = {}
XPSYS.XP = 0
XPSYS.level = 1
XPSYS.XPOfNextLevel = 1

--[[---------------------------------------------------------
   Name: XPSYS.Update()
   Desc: Updates all the data on the client.
-----------------------------------------------------------]]

function XPSYS.Update(len)
	XPSYS.XP = net.ReadInt(32)
	XPSYS.level = net.ReadInt(32)
	XPSYS.XPOfNextLevel = net.ReadInt(32)
	print("I have been updated! \n XP: "..XPSYS.XP.."\n Level: "..XPSYS.level)
	print("The next level's required XP is: "..XPSYS.XPOfNextLevel)
end
net.Receive("UpdateClient",XPSYS.Update)

--[[---------------------------------------------------------
   Name: XPSYS.PrintXP()
   Desc: Prints the your XP.
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
   Desc: HUD thing that is being developed
-----------------------------------------------------------]]

function XPSYS.HUDOverHead()
	local ply = LocalPlayer()
	
	for id,target in pairs(ents.FindByClass("Player")) do
		local name = tostring(target:Nick())
		
		local steamid = tostring(target:SteamID())
		local targetPos = target:GetPos() + Vector(0,0,75)
		
		local targetDistance = math.floor((target:GetPos():Distance( targetPos ))/40)
		
		local targetScreenpos = targetPos:ToScreen()
		if targetDistance > 20 then end
		if targetDistance <= 20 then
			surface.SetTextColor(200,25,25,255)
			surface.SetFont( "Default" )
			surface.SetTextPos( tonumber(targetScreenpos.x), tonumber(targetScreenpos.y))
			surface.DrawText("Player Level: ".. target:GetVar("level", 1 ))-- Broken -- Should work Now
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
		
		if ratio <= 0.98 then
			draw.RoundedBoxEx( 5,ScrW()/4, ScrH()/1.08, (ScrW()/2) * ratio, 20, Color(26,107,255,255),true,false,true,false)
		else
			draw.RoundedBox( 5,ScrW()/4, ScrH()/1.08, (ScrW()/2) * ratio, 20, Color(26,107,255,255))
		end

end

hook.Add( "HUDPaint", "Experience Bar", XPSYS.XPBarDraw )
