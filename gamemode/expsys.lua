--TODO: Names. I feel like each function could have more informative names.
--Initializing the table.
--Make this into a static class through tables or some shit...
--TODO:Handle edge case of having max xp and being max level.
util.AddNetworkString( "UpdateXP" )
local XPTable = {0,100,200,300,400,500,600,700,800,900,1000}

function InitializeXPTable()
	if( sql.Query( "SELECT SteamID,XP,Level FROM experience" ) == false ) then
		CreateXPTable();
	end
	print( "Database successfully initialized!" )
end

function CreateXPTable()
	sql.Query( "CREATE TABLE experience( SteamID string UNIQUE, XP int, Level int )" )
	print("Table created!")
end
hook.Add( "Initialize", "Experience Table Initilization", InitializeXPTable )

function InitializePlayerInfo( ply )
	local steamID = ply:SteamID()
	if( sql.Query( "SELECT * FROM experience WHERE SteamID = '"..steamID.."'" ) == nil ) then
		sql.Query("INSERT INTO experience ( SteamID, XP, Level ) \
			VALUES ( '"..steamID.."', 0, 1)" )
	end
	
	UpdateClient(ply,sql.QueryValue("SELECT XP FROM experience WHERE SteamID = '"..steamID.."'"),
		tonumber(sql.QueryValue("SELECT Level FROM experience WHERE SteamID = '"..steamID.."'")))
end
hook.Add( "PlayerInitialSpawn", "Initializing The Player Info", InitializePlayerInfo )

function AddXP( ply, xp)
	local steamID = ply:SteamID()
	sql.Query( "UPDATE experience SET XP = XP + '"..xp.."' WHERE SteamID = '"..steamID.."'" )
	UpdateLevel(ply,sql.QueryValue("SELECT XP FROM experience WHERE SteamID = '"..steamID.."'") + xp)
	UpdateClient(ply,sql.QueryValue("SELECT XP FROM experience WHERE SteamID = '"..steamID.."'"),
		tonumber(sql.QueryValue("SELECT Level FROM experience WHERE SteamID = '"..steamID.."'")))
	ply:SendLua("notification.AddLegacy('You got XP!', NOTIFY_GENERIC, 5);")
end

function SetXP(ply , xp)
	local steamID = ply:SteamID()
	sql.Query( "UPDATE experience SET XP = '"..xp.."' WHERE SteamID = '"..steamID.."'" )
	ply:SendLua("notification.AddLegacy('You got XP!', NOTIFY_GENERIC, 5);")
	UpdateLevel(ply,xp)
	UpdateClient(ply, xp,
		sql.QueryValue("SELECT Level FROM experience WHERE SteamID = '"..steamID.."'"))
end

function SetLevel(ply, level)
	local steamID = ply:SteamID()
	sql.Query("UPDATE experience SET Level = 1 WHERE SteamID = '"..steamID.."'")
	UpdateClient(ply,sql.QueryValue("SELECT XP FROM experience WHERE SteamID = '"..steamID.."'"),level) 
end

function UpdateLevel(ply,xp)
	local steamID = ply:SteamID()
	while xp > XPTable[tonumber(sql.QueryValue("SELECT Level FROM experience WHERE SteamID = '"..steamID.."'")) + 1] do
		sql.Query( "UPDATE experience SET Level = Level + 1 WHERE SteamID = '"..steamID.."'" )
		sql.Query( "UPDATE experience SET XP = 0 WHERE SteamID = '"..steamID.."'")
		xp = xp - XPTable[tonumber(sql.QueryValue("SELECT Level FROM experience WHERE SteamID = '"..steamID.."'"))]
	end
end

function UpdateClient(ply, xp, level)
	net.Start( "UpdateXP" )
	net.WriteInt(xp,32)
	net.WriteInt(level,32)
	net.Send(ply)
end
