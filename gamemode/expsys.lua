--Initializing the table.																		   |
--Umm I think this is encapsulated? Not sure. Need to be double checked. I did my best for now.  				   |
--TODO:Handle edge case of having max xp and being max level.									   |																	   |
----------------------------------------------------------------------------------------------------
print(==================================================)
print(		Made by toshko3331 and DEADMONSTOR 	)
print(	  GitHub:https://github.com/toshko3331/expsys   )
print(==================================================)
util.AddNetworkString( "UpdateXP" )

XPSYS = {}
XPSYS.XPTable = {0,100,200,300,400,500,600,700,800,900,1000,1100,1200,1300,1400,1500}

--[[---------------------------------------------------------
   Name: XPSYS.InitializeXPTable()
   Desc: Starts to make the Table if not there.
-----------------------------------------------------------]]

function XPSYS.InitializeXPTable()
	if( sql.Query( "SELECT SteamID,XP,Level FROM experience" ) == false ) then
		XPSYS.CreateXPTable();
		EPSYS.MaxXP()
	end
	print( "Database successfully initialized!" )
end

--[[---------------------------------------------------------
   Name: XPSYS.CreateXPTable()
   Desc: This Creates the table if its not there.
-----------------------------------------------------------]]

function XPSYS.CreateXPTable()

	sql.Query( "CREATE TABLE experience( SteamID string UNIQUE, XP int, Level int )" )
	print("Table created!")
end
hook.Add( "Initialize", "Experience Table Initialization", XPSYS.InitializeXPTable )

--[[---------------------------------------------------------
   Name: XPSYS.InitializePlayerInfo(player)
   Desc: Makes the Players Row if not joined before.
-----------------------------------------------------------]]

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

--[[---------------------------------------------------------
   Name: XPSYS.AddXP(player, xp)
   Desc: Adds XP to the player selected
-----------------------------------------------------------]]

function XPSYS.AddXP( ply, xp )
	local steamID = ply:SteamID()
	sql.Query( "UPDATE experience SET XP = XP + '"..xp.."' WHERE SteamID = '"..steamID.."'" )
	XPSYS.UpdateLevelWithXP(ply,tonumber(sql.QueryValue("SELECT XP FROM experience WHERE SteamID = '"..steamID.."'")) + xp)
	XPSYS.UpdateClient(ply,tonumber(sql.QueryValue("SELECT XP FROM experience WHERE SteamID = '"..steamID.."'")),
		tonumber(sql.QueryValue("SELECT Level FROM experience WHERE SteamID = '"..steamID.."'")))
	ply:SendLua("notification.AddLegacy('You got "..xp.." XP!', NOTIFY_GENERIC, 5);")
end

--[[---------------------------------------------------------
   Name: XPSYS.SetXP(player, xp)
   Desc: Sets XP to the player selected
-----------------------------------------------------------]]

function XPSYS.SetXP( ply, xp )
	local steamID = ply:SteamID()
	sql.Query( "UPDATE experience SET XP = '"..xp.."' WHERE SteamID = '"..steamID.."'" )
	ply:SendLua("notification.AddLegacy('Your experience points have been set to "..xp.." XP!', NOTIFY_GENERIC, 5);")
	XPSYS.UpdateLevelWithXP(ply,xp)
	XPSYS.UpdateClient(ply, xp,
		tonumber(sql.QueryValue("SELECT Level FROM experience WHERE SteamID = '"..steamID.."'")))
end

--[[---------------------------------------------------------
   Name: XPSYS.AddLevel(player, level(s))
   Desc: Add(s) the level to the player selected
-----------------------------------------------------------]]

function XPSYS.AddLevels( ply, levels )
	local steamID = ply:SteamID()
	sql.Query( "UPDATE experience SET Level = Level + '"..levels.."' WHERE SteamID = '"..steamID.."'" )
	XPSYS.UpdateClient(ply,tonumber(sql.QueryValue("SELECT XP FROM experience WHERE SteamID = '"..steamID.."'")),
		tonumber(sql.QueryValue("SELECT Level FROM experience WHERE SteamID = '"..steamID.."'")))
	ply:SendLua("notification.AddLegacy('You got "..levels.." levels!', NOTIFY_GENERIC, 5);")
end

--[[---------------------------------------------------------
   Name: XPSYS.SetLevel(player, level(s))
   Desc: Sets the level to the player selected
-----------------------------------------------------------]]

function XPSYS.SetLevel( ply, level )
	local steamID = ply:SteamID()
	sql.Query("UPDATE experience SET Level = 1 WHERE SteamID = '"..steamID.."'")
	XPSYS.UpdateClient(ply,tonumber(sql.QueryValue("SELECT XP FROM experience WHERE SteamID = '"..steamID.."'")),level) 
	ply:SendLua("notification.AddLegacy('Your level is set to "..level.."!', NOTIFY_GENERIC, 5);")
end

--[[---------------------------------------------------------
   Name: XPSYS.GetLevel(player)
   Desc: Returns the level that player has
-----------------------------------------------------------]]

function XPSYS.GetLevel(ply)
	return tonumber(sql.QueryValue("SELECT Level FROM experience WHERE SteamID = '"..ply:SteamID().."'"))
end

--[[---------------------------------------------------------
   Name: XPSYS.GetXP(player)
   Desc: Returns the XP that player has
-----------------------------------------------------------]]

function XPSYS.GetXP(ply)
	return tonumber(sql.QueryValue("SELECT XP FROM experience WHERE SteamID = '"..ply:SteamID().."'"))
end

--[[---------------------------------------------------------
   Name: XPSYS.UpdateLevelWithXP(player, xp)
   Desc: If goes over the ammount level up!
-----------------------------------------------------------]]

function XPSYS.UpdateLevelWithXP( ply, xp )
	local steamID = ply:SteamID()
	while xp > XPSYS.XPTable[tonumber(sql.QueryValue("SELECT Level FROM experience WHERE SteamID = '"..steamID.."'")) + 1] do
		sql.Query( "UPDATE experience SET Level = Level + 1 WHERE SteamID = '"..steamID.."'" )
		sql.Query( "UPDATE experience SET XP = 0 WHERE SteamID = '"..steamID.."'")
		xp = xp - XPSYS.XPTable[tonumber(sql.QueryValue("SELECT Level FROM experience WHERE SteamID = '"..steamID.."'"))]
		hook.Call("PlayerLevelUp",GAMEMODE,ply)
	end
end

--[[---------------------------------------------------------
   Name: XPSYS.UpdateClient(player, xp, level)
   Desc: Sends the ammount over to the client
-----------------------------------------------------------]]

function XPSYS.UpdateClient( ply, xp, level )
	net.Start( "UpdateXP" )
	net.WriteInt(xp,32)
	net.WriteInt(level,32)
	net.Send(ply)
end

--[[---------------------------------------------------------
   Name: XPSYS.MaxXP()
   Desc: Checks for the max Level
-----------------------------------------------------------]]

function EPSYS.MaxXP()
	local Level = 0
	for k,v in pairs(EPSYS.XPTable) do
		Level + 1
	end
end
