--TODO: Names. I feel like each function could have more informative names.
--Initializing the table.
--Make this into a static class through tables or some shit...
util.AddNetworkString( "UpdateExp" )
util.AddNetworkString( "UpdateLevel" )
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
       	ply:SendLua("notification.AddLegacy('You got XP!', NOTIFY_GENERIC, 5);")
	Level(ply, exp)
end

function SetExp(ply , exp)
	local steamID = ply:SteamID()
	sql.Query( "UPDATE experience SET EXP = '"..exp.."' WHERE SteamID = '"..steamID.."'" )
	UpdateClientExp(ply,exp)
       	ply:SendLua("notification.AddLegacy('You got XP!', NOTIFY_GENERIC, 5);")
	Level(ply, exp)
end

function UpdateClientExp(ply, exp)
	print(exp)
	net.Start( "UpdateExp" )
	net.WriteInt(exp,32)
	net.Send(ply)
end

function UpdateClientLevel(ply, Level)
	net.Start( "UpdateLevel" )
	net.WriteInt(Level,32)
	net.Send(ply)
	ply:ChatPrint("Sent")
end

Levels = {1,10,50,70,80,300,600,900,100000}
ActualLevels = {1,2,3,4,5,6,7,8,9,10}
function Level(ply, exp)
	local steamID = ply:SteamID()
	for k,v in pairs(player.GetAll()) do
		for x,z in pairs(Levels) do
			if Levels[x] == 1 then
				if exp < Levels[x] then
					ply:ChatPrint(ActualLevels[x])
					UpdateClientLevel(ply, ActualLevels[x])
					print("X:"..ActualLevels[x])
				end
			end
			if Levels[x] != 1 then
				if exp > Levels[x-1] then
					if exp <= Levels[x] then   
						ply:ChatPrint(ActualLevels[x])
						UpdateClientLevel(ply, ActualLevels[x])
						print("X:"..ActualLevels[x])
					end
				end
			end
		end
	end
end
