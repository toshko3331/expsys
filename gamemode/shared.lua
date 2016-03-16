function GM:PlayerSpawn(ply)
	---TODO:Rewards
end

function LevelUpEffects(ply)
	PrecacheParticleSystem("bday_confetti") -- ply:PrecacheParticleSystem("bday_confetti") maybe
	local plypos = ply:GetPos()
	local plyangle = ply:GetAngle()
	ParticleEffect("bday_confetti", plypos, plyangle, nil )
	ply:EmitSound("music/HL1_song25_REMIX3.mp3")
end
