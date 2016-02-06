A GMod experience system for servers.

Server-Side Hooks
-----------------

--[[---------------------------------------------------------
   Name: XPSYS.InitializeXPTable()
   Desc: Starts to make the Table if not there.
-----------------------------------------------------------]]

--[[---------------------------------------------------------
   Name: XPSYS.CreateXPTable()
   Desc: This Creates the table if its not there.
-----------------------------------------------------------]]

--[[---------------------------------------------------------
   Name: XPSYS.InitializePlayerInfo(player)
   Desc: Makes the Players Row if not joined before.
-----------------------------------------------------------]]

--[[---------------------------------------------------------
   Name: XPSYS.AddXP(player, xp)
   Desc: Adds XP to the player selected
-----------------------------------------------------------]]

--[[---------------------------------------------------------
   Name: XPSYS.SetXP(player, xp)
   Desc: Sets XP to the player selected
-----------------------------------------------------------]]

--[[---------------------------------------------------------
   Name: XPSYS.AddLevel(player, level(s))
   Desc: Add(s) the level to the player selected
-----------------------------------------------------------]]

--[[---------------------------------------------------------
   Name: XPSYS.SetLevel(player, level(s))
   Desc: Sets the level to the player selected
-----------------------------------------------------------]]

--[[---------------------------------------------------------
   Name: XPSYS.GetLevel(player)
   Desc: Returns the level that player has
-----------------------------------------------------------]]

--[[---------------------------------------------------------
   Name: XPSYS.GetXP(player)
   Desc: Returns the XP that player has
-----------------------------------------------------------]]

--[[---------------------------------------------------------
   Name: XPSYS.UpdateThroughXP(player, xp)
   Desc: Utility function for updating xp and level .
			Meant for internal use only. Don't hook onto this without good reason.
-----------------------------------------------------------]]

--[[---------------------------------------------------------
   Name: XPSYS.UpdateThroughLevel(player, xp)
   Desc: Utility function for updating level.
			Meant for internal use only. Don't hook onto this without good reason.
-----------------------------------------------------------]]

--[[---------------------------------------------------------
   Name: XPSYS.UpdateClient(player, xp, level)
   Desc: Sends the ammount over to the client
-----------------------------------------------------------]]

--[[---------------------------------------------------------
   Name: PlayerLevelUp
   Desc: Called whenever the player levels up.
-----------------------------------------------------------]]