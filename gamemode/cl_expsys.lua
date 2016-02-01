--TODO: Make this into a class so no global variables and shit like that.
--NOTE: If we want to make these variables into Vars, we have to make sure that UpdateXP is called after the player is loaded
--		which is currently NOT happening so the entity will return and it won't work.
experience = 0
level = 1
function UpdateXP(len)
--TODO:Add some checks to see if is player(?)
	experience = net.ReadInt(32)
	level = net.ReadInt(32)
	
	print("I have been updated! \n XP: "..experience.."\n Level: "..level)
end
net.Receive("UpdateXP",UpdateXP)

function PrintExp()
	print(experience)
end
concommand.Add("print_exp",PrintExp)

hook.Add( "HUDPaint", "HelloThere", function()
	draw.DrawText( "Level: "..level, "DermaLarge", ScrW() * 0.07 , ScrH() * 0.85, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER )
end )

function test()
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
			surface.DrawText("Player Level: ".. target:GetVar("level", 0 )) -- Broken except for self
	end
	end
end
hook.Add( "HUDPaint", "DrawStuff", test)