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
function ShityTimer(ply)
    if ply:IsSuperAdmin() or ply:IsAdmin() then
	timer.Create( "SomeShityTimer", 1, 10,function() 

		for k,v in pairs(player.GetAll()) do
			XPSYS.AddXP(v,20)
			print("Added 20 XP points to "..v:Nick())
		end
	end)
    end
end
concommand.Add("StartTimer",ShityTimer)

function RemoveXP(ply)
    if ply:IsSuperAdmin() or ply:IsAdmin() then
	for k,v in pairs(player.GetAll()) do
		XPSYS.SetXP(v,0)
		print("RESET!")
	end
   end
end
concommand.Add("RemoveXP", RemoveXP)

function ResetLevels(ply)
     if ply:IsSuperAdmin() or ply:IsAdmin() then
	for k,v in pairs(player.GetAll()) do
		XPSYS.SetLevel(v,1)
		print("Level set to 1!")
	end
     end
end
concommand.Add("ResetLevels", ResetLevels)

function SetXP( ply, cmd, args )
    if ply:IsSuperAdmin() or ply:IsAdmin() then	
	for k,v in pairs(player.GetAll()) do
		XPSYS.SetXP(v,tonumber(args[1]))
		print("XP set to "..args[1].."!")
	end
    end
end
concommand.Add("SetXP", SetXP)

function SetLevel( ply, cmd, args )
    if ply:IsSuperAdmin() or ply:IsAdmin() then		
	for k,v in pairs(player.GetAll()) do
		XPSYS.SetLevel(v,tonumber(args[1]))
		print("Level is set to "..args[1].."!")
	end
    end
end
concommand.Add("SetLevel", SetLevel)

function AddLevels( ply, cmd, args )
    if ply:IsSuperAdmin() or ply:IsAdmin() then		
	for k,v in pairs(player.GetAll()) do
		XPSYS.AddLevels(v,tonumber(args[1]))
		print("Levels added are "..args[1].."!")
	end
    end
end
concommand.Add("AddLevels", AddLevels)


timer.Create("PrintHighestLevel", 30, 0, function() 
	local highestXP = 0 
	local highestLevel = 1
	for k,v in pairs(player.GetAll()) do
		local playerXP = XPSYS.GetXP(v)
		local playerLevel = XPSYS.GetLevel(v)
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
		print(ply:Nick().." has just leveled up to level "..XPSYS.GetLevel(ply).."!") 
		PrecacheParticleSystem("bday_confetti")
		local plypos = ply:GetPos()
		local plyangle = ply:GetAngle()
		ParticleEffect("bday_confetti", plypos, plyangle, nil )
		ply:EmitSound("music/HL1_song25_REMIX3.mp3")
	end
)

hook.Add("PlayerDeath","Gain Some Levels For Killing A Player", 
	function(victim,inflictor,attacker ) 

		if ( attacker:IsPlayer() ) then
			XPSYS.AddLevels(attacker,2)
		end
	end
)
