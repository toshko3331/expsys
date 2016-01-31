--TODO: Names. I feel like each function could have more informative names.
--Initializing the table.
--Make this into a static class through tables or some shit...
util.AddNetworkString( "UpdateExp" )

function InitializeTable()
	if( sql.Query( "SELECT SteamID,EXP,Level FROM experience" ) == false ) then
		CreateEXPTable();
	end
	print( "Database successfully initialized!" )
end

function CreateEXPTable()
	sql.Query( "CREATE TABLE experience( SteamID string UNIQUE, Level int, EXP int )" )
	print("Table created!")
end
hook.Add( "Initialize", "Experience Table Initilization", InitializeTable )
--Set up of player when they first join.
function InitializePlayerInfo( ply )
	local steamID = ply:SteamID()
	if( sql.Query( "SELECT * FROM experience WHERE SteamID = '"..steamID.."'" ) == nil ) then
		sql.Query("INSERT INTO experience ( SteamID, EXP ) \
			VALUES ( '"..steamID.."', 0)" )
	end
	UpdateClientExp(ply,sql.QueryValue("SELECT EXP FROM experience WHERE SteamID = '"..steamID.."'"))
end
hook.Add( "PlayerInitialSpawn", "Initializing The Player Info", InitializePlayerInfo )

function AddExp( ply, exp)
	local steamID = ply:SteamID()
	sql.Query( "UPDATE experience SET EXP = EXP + '"..exp.."' WHERE SteamID = '"..steamID.."'" )
	UpdateClientExp(ply,sql.QueryValue("SELECT EXP FROM experience WHERE SteamID = '"..steamID.."'"))
        for k,v in pairs(player.GetAll()) do
        	ply:SendLua("GAMEMODE:AddNotify('You got XP!', NOTIFY_GENERIC, 5);")
        end
end

function SetExp(ply , exp)
	local steamID = ply:SteamID()
	sql.Query( "UPDATE experience SET EXP = '"..exp.."' WHERE SteamID = '"..steamID.."'" )
	UpdateClientExp(ply,exp)
        for k,v in pairs(player.GetAll()) do
        	ply:SendLua("GAMEMODE:AddNotify('You got XP!', NOTIFY_GENERIC, 5);")
        end
end

function UpdateClientExp(ply, exp)
	net.Start( "UpdateExp" )
	net.WriteInt(exp,32)
	net.Send(ply)
end

Level = {1,10,50,70,80}

function Level(ply, exp)
	local steamID = ply:SteamID()
	for k,v in pairs(player.GetAll()) do
		for k,v in pairs(Level) do
			if Level[v] < Level[v-1]
				if level[v] > Level[+1]
					sql.Query( "UPDATE experience SET Level = '"..Level.."' WHERE SteamID = '"..steamID.."'" )   
				end
			end
		end
	end
