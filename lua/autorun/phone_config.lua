----// gPhone //----
-- Author: Exho
-- Version: 1/27/14
-- Phone source: https://creativemarket.com/buatoom/6422-iPhone5-Flat-Template
-- Icon sources: http://www.flaticon.com/

--[[ To Do:
	- New icons that are not all white
	- Multiplayer
	- Fix animations so that they are consistant
	- Notifications for text messages
	- Convert all the back buttons to my format
		objects.Back = vgui.Create("gPhoneBackButton", screen)
		objects.Back:SetTextColor( gPhone.config.colorBlue )
		objects.Back:SetPos( )
	- Finish apps!!!
	- Perhaps move all text logs serverside
		- Regardless of position, they need to NOT be in plain text
		- If encrpyted, perhaps store the key on the server and only decrypt serverside then send the table to the client
	- Settings tabs
		- Developer stuff
	- Convert naming conventions to config
	- So many update checks will likely max out free webhost
	- Moving apps in folders
	- Some system to make sure we don't have too many apps on the screen
		- Throw em into folders
		- Or allow scrolling down
	- App saves in gphone/appdata folder
		- saveAppData/loadAppData functions
]]

gPhone = gPhone or {}
gPhone.version = 0.3

if SERVER then
	--// Serverside config
	gPhone.config = {
		-- Time to count text messages in order to check for spam
		antiSpamTimeframe = 5,
		-- Max amount of texts allowed in the above declared time
		textPerTimeframeLimit = 5,
		-- Time to prevent another text from being sent after a player is flagged as a spammer
		textSpamCooldown = 10, 
		
		-- Admin groups 
		adminGroups = {"owner", "superadmin", "admin"}
	}
else
	
	--// Clientside config
	gPhone.config = {
		-- Should we display debug console messages called with the msgC function? 
		showConsoleMessages = true,
		-- Should apps that we cannot use be shown on the home screen?
		ShowUnusableApps = true,
		-- Should the status bar be darkened on the homescreen for white wallpapers?
		darkStatusBar = false,
		
		-- Default homescreen wallpaper
		homeWallpaper = "vgui/gphone/wallpapers/greyfabric.png",
		-- Default lockscreen wallpaper
		lockWallpaper = "vgui/gphone/wallpapers/greyfabric.png",
		-- Fallback in case either wallpaper is nil
		fallbackWallpaper = "vgui/gphone/wallpapers/wood.png",
		
		-- Held key to open/close the gPhone
		openKey = KEY_G, 
		-- Time to hold the key in order to open/close the gPhone
		keyHoldTime = 0.75,
		-- Time after showing the homescreen to unlock it 
		openLockDelay = 1,
		
		-- Colors
		colorBlue = Color(20,80,200),
		colorRed = Color(220, 27, 23),
		colorGrey = Color(100, 100, 100),
		phoneColor = Color(255,255,255,255),
	}
end

if SERVER then
	util.AddNetworkString("gPhone_DataTransfer")
	util.AddNetworkString("gPhone_MultiplayerData")
	util.AddNetworkString("gPhone_MultiplayerStream")
	util.AddNetworkString("gPhone_ChatMsg")
	
	AddCSLuaFile()
	gPhone.addCSLuaFile( "gphone" )
	AddCSLuaFile("vgui/backbutton.lua")
	
	gPhone.include( "gphone" )
end

if CLIENT then
	gPhone.include( "gphone" )
	include("vgui/backbutton.lua")
end

print("---// gPhone //---")
print("- Created by Exho (STEAM_0:0:53332328) -")
print("- https://github.com/Exho1/gPhone -")
print("- Do not reupload anywhere -")
print("---// Version "..gPhone.version.." //---")

