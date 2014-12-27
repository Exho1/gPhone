----// gPhone //----
-- Author: Exho
-- Version: 12/27/14
-- Phone source: https://creativemarket.com/buatoom/6422-iPhone5-Flat-Template
-- Icon sources: http://www.flaticon.com/

--[[ To Do:
	- New icons that are not all white
	- Boot-up screen
]]

gPhone = gPhone or {}

gPhone.Config = {
	PhoneColor = Color(255,255,255,255),
	
	DarkenStatusBar = false,
	
	HomeWallpaper = "vgui/gphone/wallpapers/greyfabric.png",
	LockWallpaper = "vgui/gphone/wallpapers/greyfabric.png",
	FallbackWallpaper = "vgui/gphone/wallpapers/wood.png",
	
	OpenKey = KEY_G, 
	KeyHoldTime = 0.75,
	
	OpenLockDelay = 1,
	
	ColorBlue = Color(20,80,200),
}

if SERVER then
	print("Loading gPhone - Server")
	
	util.AddNetworkString("gPhone_DataTransfer")
	util.AddNetworkString("gPhone_MultiplayerData")
	util.AddNetworkString("gPhone_ChatMsg")
	
	AddCSLuaFile()
	AddCSLuaFile("gphone/cl_phone.lua")
	AddCSLuaFile("gphone/cl_appbase.lua")
	AddCSLuaFile("gphone/cl_util.lua")
	AddCSLuaFile("gphone/cl_animations.lua")
	AddCSLuaFile("gphone/sh_util.lua")
	AddCSLuaFile("gphone/sh_multiplayer.lua")
	local files = file.Find( "lua/gphone/apps/*.lua", "GAME" )
	for k, v in pairs(files) do
		AddCSLuaFile("lua/gphone/apps/"..v)
	end
	
	include("gphone/sv_util.lua")
	include("gphone/sv_phone.lua")
	include("gphone/sh_util.lua")
	include("gphone/sh_multiplayer.lua")
	
	print("Loaded!")
end

if CLIENT then
	print("Loading gPhone - Client")
	
	include("gphone/cl_phone.lua")
	include("gphone/cl_appbase.lua")
	include("gphone/cl_util.lua")
	include("gphone/cl_animations.lua")
	include("gphone/sh_util.lua")
	include("gphone/sh_multiplayer.lua")
	
	print("Loaded!")
end

