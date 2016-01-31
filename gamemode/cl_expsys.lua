--TODO: Make this into a class so no global variables and shit like that.
experience = 0
function UpdateExp(len)
	experience = net.ReadInt(32)
	print("I have been updated! Exp: "..experience)
end
net.Receive("UpdateExp",UpdateExp)

function UpdateLevel(len)
	Level = net.ReadInt(32)
	print("I have been updated! Level: "..Level)
	test(Level)
end
net.Receive("UpdateLevel",UpdateLevel)

function PrintExp()
	print(experience)
end
concommand.Add("print_exp",PrintExp)

hook.Add( "HUDPaint", "HelloThere", function()
	draw.DrawText( "Level: "..Level, "DermaLarge", ScrW() * 0.07 , ScrH() * 0.85, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER )
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
			surface.DrawText("Player Level: ".. target:GetVar("Level", 0 ))
	end
	end
end
hook.Add( "HUDPaint", "DrawStuff", test)
