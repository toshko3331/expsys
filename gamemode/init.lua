AddCSLuaFile( "cl_expsys.lua" )
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "expsys.lua" )

include("shared.lua")
include("expsys.lua")

DeriveGamemode( "sandbox" )

function GM:Initialize()
	--Nothing
end

--Test Code
function ShityTimer()

	timer.Create( "SomeShityTimer", 1, 10,function() 

		for k,v in pairs(player.GetAll()) do
			AddXP(v,20)
			print("Added 20 XP points to "..v:Nick())
		end
	end)

end
concommand.Add("StartTimer",ShityTimer)

function RemoveXP()
	for k,v in pairs(player.GetAll()) do
		SetXP(v,0)
		print("RESET!")
	end
end
concommand.Add("RemoveXP", RemoveXP)

function ResetLevels()
	for k,v in pairs(player.GetAll()) do
		SetLevel(v,1)
		print("Level set to 1!")
	end
end
concommand.Add("ResetLevels", ResetLevels)


