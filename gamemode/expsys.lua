--Initializing the table.																		   |
--Umm I think this is encapsulated? Not sure. Need to be double checked. I did my best for now.    |
--TODO: Names. I feel like each function could have more informative names.						   |
--TODO:Handle edge case of having max xp and being max level.									   |
--TODO:Document everything.																		   |
----------------------------------------------------------------------------------------------------

util.AddNetworkString( "UpdateXP" )

XPSYS = {}
XPSYS.XPTable = {1,100,200,300,400,500,600,700,800,900,1000,1100,1200,1300,1400,1500}
 
function XPSYS.InitializeXPTable()
	if( sql.Query( "SELECT SteamID,XP,Level FROM experience" ) == false ) then
		XPSYS.CreateXPTable();
	end
	print( "Database successfully initialized!" )
end

function XPSYS.CreateXPTable()

	sql.Query( "CREATE TABLE experience( SteamID string UNIQUE, XP int, Level int )" )
	print("Table created!")
end
hook.Add( "Initialize", "Experience Table Initialization", XPSYS.InitializeXPTable )

function XPSYS.InitializePlayerInfo( ply )
	local steamID = ply:SteamID()
	
	if( sql.Query( "SELECT * FROM experience WHERE SteamID = '"..steamID.."'" ) == nil ) then
		sql.Query("INSERT INTO experience ( SteamID, XP, Level ) \
			VALUES ( '"..steamID.."', 0, 1)" )
	end
	
	XPSYS.UpdateClient(ply,tonumber(sql.QueryValue("SELECT XP FROM experience WHERE SteamID = '"..steamID.."'")),
		tonumber(sql.QueryValue("SELECT Level FROM experience WHERE SteamID = '"..steamID.."'")))
end
hook.Add( "PlayerInitialSpawn", "Initializing The Player Info", XPSYS.InitializePlayerInfo )

function XPSYS.AddXP( ply, xp )
	local steamID = ply:SteamID()
	sql.Query( "UPDATE experience SET XP = XP + '"..xp.."' WHERE SteamID = '"..steamID.."'" )
	XPSYS.UpdateLevelWithXP(ply,tonumber(sql.QueryValue("SELECT XP FROM experience WHERE SteamID = '"..steamID.."'")))
	--XPSYS.UpdateClient(ply,tonumber(sql.QueryValue("SELECT XP FROM experience WHERE SteamID = '"..steamID.."'")),
	--	tonumber(sql.QueryValue("SELECT Level FROM experience WHERE SteamID = '"..steamID.."'")))
	ply:SendLua("notification.AddLegacy('You got "..xp.." XP!', NOTIFY_GENERIC, 5);")
end

function XPSYS.SetXP( ply, xp )
	
	local steamID = ply:SteamID()
	sql.Query( "UPDATE experience SET XP = '"..xp.."' WHERE SteamID = '"..steamID.."'" )
	XPSYS.UpdateLevelWithXP(ply,xp)
	--XPSYS.UpdateClient(ply, tonumber(sql.QueryValue("SELECT XP FROM experience WHERE SteamID = '"..steamID.."'")),
	--	tonumber(sql.QueryValue("SELECT Level FROM experience WHERE SteamID = '"..steamID.."'")))
	ply:SendLua("notification.AddLegacy('Your experience points have been set to "..xp.." XP!', NOTIFY_GENERIC, 5);")
end

function XPSYS.AddLevels( ply, levels )
	-- TODO: Handle MAX level value.
	local steamID = ply:SteamID()
	sql.Query( "UPDATE experience SET Level = Level + '"..levels.."' WHERE SteamID = '"..steamID.."'" )
	XPSYS.UpdateClient(ply,tonumber(sql.QueryValue("SELECT XP FROM experience WHERE SteamID = '"..steamID.."'")),
		tonumber(sql.QueryValue("SELECT Level FROM experience WHERE SteamID = '"..steamID.."'")))
	ply:SendLua("notification.AddLegacy('You got "..levels.." levels!', NOTIFY_GENERIC, 5);")
end

function XPSYS.SetLevel( ply, level )
	-- TODO: Handle MAX level value.
	local steamID = ply:SteamID()
	sql.Query("UPDATE experience SET Level = 1 WHERE SteamID = '"..steamID.."'")
	XPSYS.UpdateClient(ply,tonumber(sql.QueryValue("SELECT XP FROM experience WHERE SteamID = '"..steamID.."'")),level) 
	ply:SendLua("notification.AddLegacy('Your level is set to "..level.."!', NOTIFY_GENERIC, 5);")
end

function XPSYS.GetLevel(ply)
	return tonumber(sql.QueryValue("SELECT Level FROM experience WHERE SteamID = '"..ply:SteamID().."'"))
end

function XPSYS.GetXP(ply)
	return tonumber(sql.QueryValue("SELECT XP FROM experience WHERE SteamID = '"..ply:SteamID().."'"))
end

function XPSYS.UpdateLevelWithXP( ply, xp )
	--TODO: Handle MAX level value.
	local steamID = ply:SteamID()
		XPSYS.UpdateClient(ply,xp,tonumber(sql.QueryValue( "SELECT Level FROM experience WHERE SteamID = '"..steamID.."'" )))
	while xp > XPSYS.XPTable[tonumber(sql.QueryValue("SELECT Level FROM experience WHERE SteamID = '"..steamID.."'")) + 1] do
		
		sql.Query( "UPDATE experience SET Level = Level + 1 WHERE SteamID = '"..steamID.."'" )
		xp = xp - XPSYS.XPTable[tonumber(sql.QueryValue("SELECT Level FROM experience WHERE SteamID = '"..steamID.."'"))]
		sql.Query( "UPDATE experience SET XP = '"..xp.."' WHERE SteamID = '"..steamID.."'")
		hook.Call("PlayerLevelUp",GAMEMODE,ply)
		XPSYS.UpdateClient(ply,xp,tonumber(sql.QueryValue( "SELECT Level FROM experience WHERE SteamID = '"..steamID.."'" )))
	end
end

function XPSYS.UpdateClient( ply, xp, level )
	-- TODO: Handle MAX level value.
	net.Start( "UpdateXP" )
	net.WriteInt(xp,32)
	net.WriteInt(level,32)
	net.WriteInt(XPSYS.XPTable[tonumber(
		sql.QueryValue("SELECT Level FROM experience WHERE SteamID = '"..ply:SteamID().."'")) + 1] ,32) 
	net.Send(ply)
end
