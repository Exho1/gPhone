----// gPhone //----
-- Author: Exho
-- Version: 12/31/14
-- Phone source: https://creativemarket.com/buatoom/6422-iPhone5-Flat-Template
-- Icon sources: http://www.flaticon.com/

--[[ To Do:
	- New icons that are not all white
	- Multiplayer
	- Fix animations so that they are consistant
	- Notifications for text messages
	- App notifications, red and white circles
	- Convert all the back buttons to my format
		objects.Back = vgui.Create("gPhoneBackButton", screen)
		objects.Back:SetTextColor( gPhone.config.ColorBlue )
		objects.Back:SetPos( )
		
	- Finish apps!!!
	- Perhaps move all text logs serverside
		- Regardless of position, they need to NOT be in plain text
		- If encrpyted, perhaps store the key on the server and only decrypt serverside then send the table to the client
	- App saves in gphone/appdata folder
	- Settings tabs
		- Color picker
		- Developer stuff
	
	- Convert naming conventions to config
	- So many update checks will likely max out free webhost
]]

gPhone = gPhone or {}
gPhone.version = 0.3

if SERVER then
	--// Serverside config
	gPhone.config = {
		AntiSpamTimeframe = 5,
		TextPerTimeframeLimit = 5,
		TextSpamCooldown = 15, 

	}
else
	
	--// Clientside config
	gPhone.config = {
		ShowRunTimeConsoleMessages = true,
		ShowUnusableApps = true,
		
		DarkenStatusBar = false,
		
		HomeWallpaper = "vgui/gphone/wallpapers/greyfabric.png",
		LockWallpaper = "vgui/gphone/wallpapers/greyfabric.png",
		FallbackWallpaper = "vgui/gphone/wallpapers/wood.png",
		
		OpenKey = KEY_G, 
		KeyHoldTime = 0.75,
		
		OpenLockDelay = 1,
		
		ColorBlue = Color(20,80,200),
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
	AddCSLuaFile("gphone/cl_phone.lua")
	AddCSLuaFile("gphone/cl_appbase.lua")
	AddCSLuaFile("gphone/cl_util.lua")
	AddCSLuaFile("gphone/cl_animations.lua")
	AddCSLuaFile("gphone/sh_util.lua")
	AddCSLuaFile("gphone/sh_multiplayer.lua")
	AddCSLuaFile("vgui/backbutton.lua")
	
	include("gphone/sv_util.lua")
	include("gphone/sv_phone.lua")
	include("gphone/sh_util.lua")
	include("gphone/sh_multiplayer.lua")
end

if CLIENT then
	include("gphone/cl_phone.lua")
	include("gphone/cl_appbase.lua")
	include("gphone/cl_util.lua")
	include("gphone/cl_animations.lua")
	include("gphone/sh_util.lua")
	include("gphone/sh_multiplayer.lua")
	include("vgui/backbutton.lua")
	
	gPhone.loadClientConfig()
end

print("---// gPhone //---")
print("- Created by Exho (STEAM_0:0:53332328) -")
print("- https://github.com/Exho1/gPhone -")
print("- Do not reupload anywhere -")
print("---// Version "..gPhone.version.." //---")

