--TODO: Names. I feel like each function could have more informative names.
--Initializing the table.
--Make this into a static class through tables or some shit...
util.AddNetworkString( "UpdateExp" )

function InitializeTable()
	if( sql.Query( "SELECT SteamID,EXP FROM experience" ) == false ) then
		CreateEXPTable();
	end
	print( "Database successfully initialized!" )
end

function CreateEXPTable()
	sql.Query( "CREATE TABLE experience( SteamID string UNIQUE, EXP int )" )
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
             ply:notification.AddLegacy( "You got "..exp.." XP", NOTIFY_GENERIC, 2 )
        end
end

function SetExp( ply, exp)
	local steamID = ply:SteamID()
	sql.Query( "UPDATE experience SET EXP = '"..exp.."' WHERE SteamID = '"..steamID.."'" )
	UpdateClientExp(ply,exp)
        for k,v in pairs(player.GetAll()) do
            ply:notification.AddLegacy( "You got "..exp.." XP", NOTIFY_GENERIC, 2 )
        end
end

function UpdateClientExp(ply, exp)
	net.Start( "UpdateExp" )
	net.WriteInt(exp,32)
	net.Send(ply)
end
