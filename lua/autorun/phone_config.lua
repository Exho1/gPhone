----// gPhone //----
-- Author: Exho
-- Version: 3/11/14

--[[ To Do:
	- Multiplayer
		- Make it work
		- App variable which defines a function to run to start a multiplayer game
		- Replace the horrid multiplayer request system with my new one
	- Convert all the back buttons to my format
		objects.Back = vgui.Create("gPhoneBackButton", screen)
		objects.Back:SetTextColor( gPhone.colors.blue )
		objects.Back:SetPos()
	- Moving apps in folders
	- Function to bypass using net.*Table entirely
	- Phone/calling
		- Enable speaking for both players
		- Test it again
		- Finish implementing group calling
	- Language
		- Translate the finances app
		- Make sure to add new keys to non-English files with the English translations until proper ones are made
		- Run through the phone to make sure all translations exist
		- Talk to DJ or Narroby about Spanish
	- Figure out why missing config values dont save
	- Wallpaper
		- The gPhone is bloated by the backgrounds, 2mb.
		- Online wallpapers?
	- Ringtones?
	- Sounds?
	- Add some way to find local player id
	- More games
		- Find Flappy Garry guy or make own Flappy Garry
		- Snake
	- Settings app
		- Music tab with the 2 music related config bools
		
	- Before release
		- Make sure you can't self message in the messages app
		- Remove all TEMP stuff
		- Remove the Derma close button and other temp stuff
		- Set up the default config
		- Remove all prints and replace neccessary ones with gPhone.msgC(
	- On release
		- Update the webserver with the correct version number on release 1.0.0 
		- Update the settings update button to point to the Workshop page for the phone
]]

gPhone = gPhone or {}
gPhone.version = "0.9.86"

gPhone.languages = {}
gPhone.invalidNumber = "ERRO-RNUM"
if SERVER then
	--// Serverside config
	gPhone.config = {
		-- Time to count text messages in order to check for spam
		antiSpamTimeframe = 5,
		-- Max amount of texts allowed in the above declared time
		textPerTimeframeLimit = 5,
		-- Time to prevent another text from being sent after a player is flagged as a spammer
		textSpamCooldown = 10, 
		
		-- Should we display debug console messages called with the msgC function? 
		showConsoleMessages = true,
		
		-- Admin groups 
		adminGroups = {"owner", "superadmin", "admin"}
	}
else
	gPhone.debugLog = {}
	
	--// Clientside config - Most of these values have Derma bindings so they can be changed during run time
	gPhone.config = {
		
		-- Default phone color
		phoneColor = Color(255,255,255,255),
		
		-- Should we display debug console messages called with the msgC function? 
		showConsoleMessages = true,
		-- Should apps that we cannot use be shown on the home screen?
		showUnusableApps = false,
		-- Should the status bar be darkened on the homescreen for white wallpapers?
		darkStatusBar = false,
		
		-- Default homescreen wallpaper
		homeWallpaper = "vgui/gphone/wallpapers/greyfabric.png",
		-- Default lockscreen wallpaper
		lockWallpaper = "vgui/gphone/wallpapers/greyfabric.png",
		-- Fallback in case either wallpaper is nil
		fallbackWallpaper = "vgui/gphone/wallpapers/wood.png",
		
		-- Key held to open/close the gPhone
		openKey = KEY_G, 
		-- Time to hold the above in order to open/close the gPhone
		keyHoldTime = 0.75,
		-- Time after showing the homescreen to unlock it 
		openLockDelay = 1,
		
		-- Removes files in the data/gphone/archive folder after a time period has elapsed
		deleteArchivedFiles = true,
		-- Time period to delete up files in the archive if the above value is true
		daysToCleanupArchive = 14,
		
		-- Pauses the music from the Music app when you tab out of Garry's Mod
		stopMusicOnTabOut = true,
		-- Whether or not the phone should search online for album covers
		autoFindAlbumCovers = true,
		
		-- Replaces missing language keys with their english alternative
		replaceMissingTranslations = true,
		
		-- Disables incoming notification banners and alerts
		airplaneMode = false,
	}
	
	--// Color palatte for apps
	gPhone.colors = {
		blue = Color(20, 80, 200),
		red = Color(220, 27, 23),
		softRed = Color(220, 84, 78),
		grey = Color(100, 100, 100),
		
		whiteBG = Color(250, 250, 250),
		darkWhiteBG = Color(230, 230, 230), 
		darkerWhite = Color(210, 210, 210),
		greyAccent = Color(150, 150, 150),
		green = Color(75, 236, 101),
	}
end

if SERVER then
	--util.AddNetworkString("gPhone_DataTransfer")
	util.AddNetworkString("gPhone_GenerateNumber")
	util.AddNetworkString("gPhone_StateChange")
	util.AddNetworkString("gPhone_RunFunction")
	util.AddNetworkString("gPhone_Notify")
	util.AddNetworkString("gPhone_App")
	util.AddNetworkString("gPhone_Text")
	util.AddNetworkString("gPhone_Call")
	util.AddNetworkString("gPhone_Request")
	util.AddNetworkString("gPhone_Response")
	util.AddNetworkString("gPhone_Transfer")
	
	util.AddNetworkString("gPhone_MultiplayerData")
	util.AddNetworkString("gPhone_MultiplayerStream")
	util.AddNetworkString("gPhone_ChatMsg")
	
	AddCSLuaFile()
	AddCSLuaFile("gphone/cl_phone.lua")
 	AddCSLuaFile("gphone/cl_appbase.lua")
 	AddCSLuaFile("gphone/cl_util.lua")
 	AddCSLuaFile("gphone/cl_util_extension.lua")
 	AddCSLuaFile("gphone/cl_animations.lua")
	AddCSLuaFile("gphone/sh_datatransfer.lua")
	AddCSLuaFile("gphone/sh_util.lua")
	AddCSLuaFile("gphone/sh_lang.lua")
 	AddCSLuaFile("gphone/sh_multiplayer.lua")
	AddCSLuaFile("vgui/backbutton.lua")
	
	-- Apps
	local files = file.Find( "gphone/apps/*.lua", "LUA" )
	for k, v in pairs(files) do
		AddCSLuaFile("gphone/apps/"..v)
	end
	
	-- Language files
	files = file.Find( "gphone/lang/*.lua", "LUA" )
	for k, v in pairs(files) do
		AddCSLuaFile("gphone/lang/"..v)
	end
	
	-- Have to include the language file before the languages or errors result
	include("gphone/sh_lang.lua")
	
	-- Include languages
	local files = file.Find( "gphone/lang/*.lua", "LUA" )
	for k, v in pairs(files) do
		include("gphone/lang/"..v)
	end
	
	include("gphone/sv_phone.lua")
 	include("gphone/sh_util.lua")
 	include("gphone/sh_multiplayer.lua")
	include("gphone/sh_datatransfer.lua")
	
	if game.SinglePlayer() then
		for _, ply in pairs(player.GetAll()) do
			gPhone.chatMsg( ply, "The phone will not work properly in Single Player!!! Expect bugs and other paranormal activities" )
		end
	end
end

if CLIENT then
	include("gphone/sh_lang.lua")
	
	-- Include languages
	local files = file.Find( "gphone/lang/*.lua", "LUA" )
	for k, v in pairs(files) do
		include("gphone/lang/"..v)
	end

	include("gphone/cl_phone.lua")
 	include("gphone/cl_appbase.lua")
 	include("gphone/cl_util.lua")
 	include("gphone/cl_util_extension.lua")
 	include("gphone/cl_animations.lua")
	include("gphone/sh_util.lua")
 	include("gphone/sh_multiplayer.lua")
	include("gphone/sh_datatransfer.lua")
	include("vgui/backbutton.lua")
	
	-- Check for updates from my website ONCE 
	gPhone.checkUpdate()
end

print([[
        _____  _                      
       |  __ \| |                     
   __ _| |__) | |__   ___  _ __   ___ 
  / _` |  ___/| '_ \ / _ \| '_ \ / _ \
 | (_| | |    | | | | (_) | | | |  __/
  \__, |_|    |_| |_|\___/|_| |_|\___|
   __/ |                              
  |___/ 
	Created by Exho - STEAM_0:0:53332328
	Version: ]]..gPhone.version..[[
]])

