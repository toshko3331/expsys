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
end
net.Receive("UpdateClient",XPSYS.Update)

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

hook.Add( "HUDPaint", "LevelDraw", function()
	draw.DrawText( "Level: "..XPSYS.level, "DermaLarge", ScrW() * 0.07 , ScrH() * 0.85, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER )
end )