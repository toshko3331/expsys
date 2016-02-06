--Umm I think this is encapsulated? Not sure. Need to be double checked. I did my best for now.		|
--TODO: Names. I feel like each function could have more informative names.							|
--TODO: Handle edge case of having max xp and being max level. Handled for XP, need to do for lvl	|
--TODO:	Make sure that when we run the SendLua in the functions, the number is cast to an int 		|
--			since floats can get sent and be displayed inaccurately.								|																	   |
-----------------------------------------------------------------------------------------------------
--[[
	==================================================
			Made by toshko3331 and DEADMONSTOR 	
		  GitHub:https://github.com/toshko3331/expsys   
	==================================================
]]
util.AddNetworkString( "UpdateXP" )

XPSYS = {}
XPSYS.XPTable = {1,100,200,300,400,500,600,700,800,900,1000,1100,1200,1300,1400,1500}
 
 --[[---------------------------------------------------------
   Name: XPSYS.InitializeXPTable()
   Desc: Starts to make the Table if not there.
-----------------------------------------------------------]]
 
function XPSYS.InitializeXPTable()
	if( sql.Query( "SELECT SteamID,XP,Level FROM experience" ) == false ) then
		XPSYS.CreateXPTable();
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
	XPSYS.UpdateThroughXP(ply,tonumber(sql.QueryValue("SELECT XP FROM experience WHERE SteamID = '"..steamID.."'")))
	ply:SendLua("notification.AddLegacy('You got "..xp.." XP!', NOTIFY_GENERIC, 5);")
end

--[[---------------------------------------------------------
   Name: XPSYS.SetXP(player, xp)
   Desc: Sets XP to the player selected
-----------------------------------------------------------]]

function XPSYS.SetXP( ply, xp )
	local steamID = ply:SteamID()
	sql.Query( "UPDATE experience SET XP = '"..xp.."' WHERE SteamID = '"..steamID.."'" )
	XPSYS.UpdateThroughXP(ply,xp)
	ply:SendLua("notification.AddLegacy('Your experience points have been set to "..xp.." XP!', NOTIFY_GENERIC, 5);")
end

--[[---------------------------------------------------------
   Name: XPSYS.AddLevels(player, level(s))
   Desc: Add(s) the level to the player selected
-----------------------------------------------------------]]

function XPSYS.AddLevels( ply, levels )
	local steamID = ply:SteamID()
	local newLevel = tonumber(sql.QueryValue("SELECT Level FROM experience WHERE SteamID = '"..steamID.."'")) + levels
	XPSYS.UpdateThroughLevel( ply, newLevel )
end

--[[---------------------------------------------------------
   Name: XPSYS.SetLevel(player, level(s))
   Desc: Sets the level to the player selected
-----------------------------------------------------------]]

function XPSYS.SetLevel( ply, level )
	XPSYS.UpdateThroughLevel( ply, level )
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
   Desc: Returns a boolean value on weather the player is the max level.
-----------------------------------------------------------]]

function XPSYS.isPlayerMaxLevel( ply )

	local maxLevel = #XPSYS.XPTable
	local steamID = ply:SteamID()
	if tonumber(sql.QueryValue("SELECT Level FROM experience WHERE SteamID = '"..steamID.."'")) >= maxLevel  then
		return true
	else
		return false
	end
end

--[[---------------------------------------------------------
   Name: XPSYS.UpdateThroughXP(player, xp)
   Desc: Utility function for updating the xp and taking into account any leveling up that happens in the process.
			Not meant to be used outside of this file without good reason.
-----------------------------------------------------------]]

function XPSYS.UpdateThroughXP( ply, xp )

	local steamID = ply:SteamID()
	if !XPSYS.isPlayerMaxLevel(ply) then
		if xp <= XPSYS.XPTable[tonumber(sql.QueryValue("SELECT Level FROM experience WHERE SteamID = '"..steamID.."'")) + 1] then
			-- We do this to make sure it does not send data that will register the 
			-- player as having more XP than the current level's max on the client side.
			XPSYS.UpdateClient(ply,xp,tonumber(sql.QueryValue( "SELECT Level FROM experience WHERE SteamID = '"..steamID.."'" )))
		end
		
		while xp > XPSYS.XPTable[tonumber(sql.QueryValue("SELECT Level FROM experience WHERE SteamID = '"..steamID.."'")) + 1] do
			sql.Query( "UPDATE experience SET Level = Level + 1 WHERE SteamID = '"..steamID.."'" )
			xp = xp - XPSYS.XPTable[tonumber(sql.QueryValue("SELECT Level FROM experience WHERE SteamID = '"..steamID.."'"))]
			sql.Query( "UPDATE experience SET XP = '"..xp.."' WHERE SteamID = '"..steamID.."'")
			hook.Call("PlayerLevelUp",GAMEMODE,ply)
			XPSYS.UpdateClient(ply,xp,tonumber(sql.QueryValue( "SELECT Level FROM experience WHERE SteamID = '"..steamID.."'" )))
			if XPSYS.isPlayerMaxLevel(ply) and xp > XPSYS.XPTable[#XPSYS.XPTable] then
				-- We check here in case the initial XP that was passed overflows the table but when we player received it
				-- they were not max level (e.x: Level 14 and receive enough xp to push them 3 levels over, which overflows table.)
				sql.Query( "UPDATE experience SET XP = '"..XPSYS.XPTable[#XPSYS.XPTable].."' WHERE SteamID = '"..steamID.."'")
				XPSYS.UpdateClient(ply,XPSYS.XPTable[#XPSYS.XPTable],#XPSYS.XPTable)
				break
			end
		end
	else
		local maxXP = XPSYS.XPTable[#XPSYS.XPTable]
		if tonumber(sql.QueryValue("SELECT XP FROM experience WHERE SteamID = '"..steamID.."'")) > maxXP then
			--If max level and xp that was passed was over the max amaount
			sql.Query("UPDATE experience SET XP = '"..maxXP.."' WHERE SteamID = '"..steamID.."'")
			XPSYS.UpdateClient(ply,maxXP,#XPSYS.XPTable)
		else
			--If max level and xp passed was below or equal to the last levels xp max.
			XPSYS.UpdateClient(ply,xp,#XPSYS.XPTable)
		end
	end
end

--[[---------------------------------------------------------
   Name: XPSYS.UpdateThroughLevel(player, xp)
   Desc: Utility function for updating level.
			Not meant to be used outside of this file without good reason.
-----------------------------------------------------------]]

function XPSYS.UpdateThroughLevel( ply, level )
	local steamID = ply:SteamID()
	local maxLevel = #XPSYS.XPTable
	if level >= maxLevel then
		sql.Query("UPDATE experience SET Level = '"..maxLevel.."' WHERE SteamID = '"..steamID.."'")	
		XPSYS.UpdateClient(ply,tonumber(sql.QueryValue("SELECT XP FROM experience WHERE SteamID = '"..steamID.."'")),maxLevel)
		ply:SendLua("notification.AddLegacy('Your level is set to "..maxLevel.."!', NOTIFY_GENERIC, 5);")
	else
		sql.Query("UPDATE experience SET Level = '"..level.."' WHERE SteamID = '"..steamID.."'")
		XPSYS.UpdateClient(ply,tonumber(sql.QueryValue("SELECT XP FROM experience WHERE SteamID = '"..steamID.."'")),level)
		ply:SendLua("notification.AddLegacy('Your level is set to "..level.."!', NOTIFY_GENERIC, 5);")
	end
end

--[[---------------------------------------------------------
   Name: XPSYS.UpdateClient(player, xp, level)
   Desc: Sends the ammount over to the client
-----------------------------------------------------------]]

function XPSYS.UpdateClient( ply, xp, level )

	net.Start( "UpdateXP" )
	net.WriteInt(xp,32) -- client xp
	net.WriteInt(level,32) -- client level
	if XPSYS.isPlayerMaxLevel(ply) then --XP requirement for next level 
		net.WriteInt(XPSYS.XPTable[#XPSYS.XPTable] ,32) 
	else
		net.WriteInt(XPSYS.XPTable[tonumber(
		sql.QueryValue("SELECT Level FROM experience WHERE SteamID = '"..ply:SteamID().."'")) + 1] ,32)
	end
	net.Send(ply)
end
