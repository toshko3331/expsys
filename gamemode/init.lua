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

timer.Create("PrintHighestLevel", 30, 0, function() 
	local highestXP = 0 
	local highestLevel = 1
	for k,v in pairs(player.GetAll()) do
		local playerXP = GetXP(v)
		local playerLevel = GetLevel(v)
		if highestXP < playerXP then
			highestXP = playerXP
		end
		if highestLevel < playerLevel then
			highestLevel = playerLevel
		end
	end
	print("The highest XP on the server is:"..highestXP)
	print("The highest Level the server is:"..highestLevel)
end )

hook.Add("PlayerLevelUp","Any Player Leveling Up",
	function(ply) 
		print(ply:Nick().." has just leveled up to level "..GetLevel(ply).."!") 
	end
)

hook.Add("PlayerDeath","Gain Some Levels For Killing A Player", 
	function(victim,inflictor,attacker ) 

		if ( attacker:IsPlayer() ) then
			AddLevels(attacker,2)
		end
	end
)