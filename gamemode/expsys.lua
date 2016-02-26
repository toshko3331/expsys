--[[
	==================================================
		Made by toshko3331 and DEADMONSTOR 	
	    GitHub:https://github.com/toshko3331/expsys   
	==================================================
]]

util.AddNetworkString( "UpdateClient" )
XPSYS = {}
XPSYS.XPTable = {1}

 --[[---------------------------------------------------------
   Name: XPSYS.CreateXPGuildLines()
   Desc: Makes the XPTable GuildLines
-----------------------------------------------------------]]
function XPSYS.CreateXPGuildLines()
	for i=1,99 do do
		table.insert(XPSYS.XPTable, i * 10)
	end
end
end
hook.Add( "Initialize", "CreateXPGuildLines", XPSYS.CreateXPGuildLines )
		
 --[[---------------------------------------------------------
   Name: XPSYS.InitializeXPTable()
   Desc: Starts to make the Table if not there.
-----------------------------------------------------------]]
function XPSYS.InitializeXPTable()
	if( sql.Query( "SELECT SteamID,XP,Level FROM experience" ) == false ) then
		sql.Query( "CREATE TABLE experience( SteamID string UNIQUE, XP int, Level int )" )
		print( "XP table successfully initialized!" )
	end

	print( "XP table successfully initialized!" )
end
hook.Add( "Initialize", "Experience Table Initialization", XPSYS.InitializeXPTable )

--[[---------------------------------------------------------
   Name: XPSYS.InitializePlayerInfo(player)
   Desc: Checks if the XP table contains the proper columns and handles creating them.
   Also updates the client initially when the player loads.
-----------------------------------------------------------]]

function XPSYS.InitializePlayerInfo( ply )
	if !(ply:IsValid() and ply:IsPlayer()) then
		return 
	end
	local steamID = ply:SteamID()
	if( sql.Query( "SELECT * FROM experience WHERE SteamID = '"..steamID.."'" ) == nil ) then
		PrintMessage( HUD_PRINTTALK, ply:Name().. "Has joined the server for the first time.")
		sql.Query("INSERT INTO experience ( SteamID, XP, Level ) \
			VALUES ( '"..steamID.."', 0, 1)" )
	end
	
	XPSYS.UpdateClient(ply,tonumber(sql.QueryValue("SELECT XP FROM experience WHERE SteamID = '"..steamID.."'")),
		tonumber(sql.QueryValue("SELECT Level FROM experience WHERE SteamID = '"..steamID.."'")))
end
hook.Add( "PlayerInitialSpawn", "Initializing The Player Info", XPSYS.InitializePlayerInfo )

--[[---------------------------------------------------------
   Name: XPSYS.AddXP(player, xp)
   Desc: Adds XP to the player.
-----------------------------------------------------------]]

function XPSYS.AddXP( ply, xp )
	if !(ply:IsValid() and ply:IsPlayer()) then
		return 
	end
	local steamID = ply:SteamID()
	sql.Query( "UPDATE experience SET XP = XP + '"..xp.."' WHERE SteamID = '"..steamID.."'" )
	XPSYS.UpdateThroughXP(ply,tonumber(sql.QueryValue("SELECT XP FROM experience WHERE SteamID = '"..steamID.."'")))
end

--[[---------------------------------------------------------
   Name: XPSYS.SetXP(player, xp)
   Desc: Sets the XP of the player.
-----------------------------------------------------------]]

function XPSYS.SetXP( ply, xp )
	if !(ply:IsValid() and ply:IsPlayer()) then
		return 
	end
	local steamID = ply:SteamID()
	sql.Query( "UPDATE experience SET XP = '"..xp.."' WHERE SteamID = '"..steamID.."'" )
	XPSYS.UpdateThroughXP( ply, xp )
end

--[[---------------------------------------------------------
   Name: XPSYS.AddLevels(player, level(s))
   Desc: Add the level(s) to the player.
-----------------------------------------------------------]]

function XPSYS.AddLevels( ply, levels )
	if !(ply:IsValid() and ply:IsPlayer()) then
		return 
	end
	local steamID = ply:SteamID()
	local newLevel = tonumber(sql.QueryValue("SELECT Level FROM experience WHERE SteamID = '"..steamID.."'")) + levels
	XPSYS.UpdateThroughLevel( ply, newLevel )
end

--[[---------------------------------------------------------
   Name: XPSYS.SetLevel(player, level(s))
   Desc: Sets the level(s) to the player selected.
-----------------------------------------------------------]]

function XPSYS.SetLevel( ply, level )
	if !(ply:IsValid() and ply:IsPlayer()) then
		return 
	end
	XPSYS.UpdateThroughLevel( ply, level )
end

--[[---------------------------------------------------------
   Name: XPSYS.GetLevel(player)
   Desc: Returns the level of the player.
-----------------------------------------------------------]]

function XPSYS.GetLevel(ply)
	if !(ply:IsValid() and ply:IsPlayer()) then
		return 
	end
	return tonumber(sql.QueryValue("SELECT Level FROM experience WHERE SteamID = '"..ply:SteamID().."'"))
end

--[[---------------------------------------------------------
   Name: XPSYS.GetXP(player)
   Desc: Returns the XP of the player.
-----------------------------------------------------------]]

function XPSYS.GetXP(ply)
	if !(ply:IsValid() and ply:IsPlayer()) then
		return 
	end
	return tonumber(sql.QueryValue("SELECT XP FROM experience WHERE SteamID = '"..ply:SteamID().."'"))
end

--[[---------------------------------------------------------
   Name: XPSYS.isPlayerMaxLevel(player, xp)
   Desc: Returns a boolean value on weather the player is the max level.
-----------------------------------------------------------]]

function XPSYS.isPlayerMaxLevel( ply )
	if !(ply:IsValid() and ply:IsPlayer()) then
		return 
	end
	local maxLevel = #XPSYS.XPTable
	if tonumber(sql.QueryValue("SELECT Level FROM experience WHERE SteamID = '"..ply:SteamID().."'")) >= maxLevel  then
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
   Desc: Sends all player data to the client.
-----------------------------------------------------------]]

function XPSYS.UpdateClient( ply, xp, level )
	ply:SetVar("level"..level)
	net.Start( "UpdateClient" )
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
