AddCSLuaFile( "cl_expsys.lua" )
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "expsys.lua" )

include("shared.lua")
include("expsys.lua")

function GM:Initialize()
	--Nothing
end

--Test Code
function ShityTimer()

	timer.Create( "SomeShityTimer", 1, 10,function() 

		for k,v in pairs(player.GetAll()) do
			AddExp(v,20)
			print("Added 20 exp points to "..v:Nick())
		end
	end)

end
concommand.Add("StartTimer",ShityTimer)

