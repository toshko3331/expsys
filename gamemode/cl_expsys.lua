--TODO: Encapsulate all of this stuff.
--NOTE: If we want to make these variables into Vars, we have to make sure that UpdateXP is called after the player is loaded
--		which is currently NOT happening so the entity will return and it won't work.
XPSYS = {}
XPSYS.experience = 0
XPSYS.level = 1
function XPSYS.UpdateXP(len)
--TODO:Add some checks to see if is player(?)
	XPSYS.experience = net.ReadInt(32)
	XPSYS.level = net.ReadInt(32)
	
	print("I have been updated! \n XP: "..XPSYS.experience.."\n Level: "..XPSYS.level)
end
net.Receive("UpdateXP",XPSYS.UpdateXP)

function XPSYS.PrintExp()
	print(XPSYS.experience)
end
concommand.Add("print_exp",XPSYS.PrintExp)

hook.Add( "HUDPaint", "HelloThere", function()
	draw.DrawText( "Level: "..XPSYS.level, "DermaLarge", ScrW() * 0.07 , ScrH() * 0.85, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER )
end )

function XPSYS.test()
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
			surface.DrawText("Player Level: ".. target:GetVar("level", 1 ))-- Broken
	end
	end
end
hook.Add( "HUDPaint", "DrawStuff", XPSYS.test)