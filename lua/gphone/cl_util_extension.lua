----// Clientside Utility Functions //----

local client = LocalPlayer()

--// Fonts
surface.CreateFont( "gPhone_18Lite", {
	font = "Roboto Lt",
	size = 18,
	weight = 500,
	antialias = true,
} )

surface.CreateFont( "gPhone_14", {
	font = "Roboto Lt",
	size = 14,
	weight = 500,
	antialias = true,
} )

surface.CreateFont( "gPhone_16", {
	font = "Roboto Lt",
	size = 14, -- wat
	weight = 500,
	antialias = true,
} )

surface.CreateFont( "gPhone_12", {
	font = "Roboto Lt",
	size = 12,
	weight = 600,
	antialias = true,
} )

surface.CreateFont( "gPhone_60", {
	font = "Roboto Lt",
	size = 60,
	weight = 300,
	antialias = true,
} )

surface.CreateFont( "gPhone_40", {
	font = "Roboto Lt",
	size = 40,
	weight = 400,
	antialias = true,
} )

surface.CreateFont( "gPhone_18", {
	font = "Roboto Lt",
	size = 18,
	weight = 650,
	antialias = true,
} )

surface.CreateFont( "gPhone_18lite", {
	font = "Roboto Lt",
	size = 18,
	weight = 500,
	antialias = true,
} )

surface.CreateFont( "gPhone_20", {
	font = "Roboto Lt",
	size = 20,
	weight = 650,
	antialias = true,
} )

surface.CreateFont( "gPhone_22", {
	font = "Roboto Lt",
	size = 22,
	weight = 500,
	antialias = true,
} )

surface.CreateFont( "gPhone_24", {
	font = "Roboto Lt",
	size = 24,
	weight = 500,
	antialias = true,
} )

surface.CreateFont( "gPhone_36", {
	font = "Roboto Lt",
	size = 36,
	weight = 650,
	antialias = true,
} )

--// Sets where the phone UI is
function gPhone.setPhoneState( state )
gPhone.log("Changing phone state from "..tostring(gPhone.phoneState).." to "..state)
	gPhone.phoneState = state
end

--// Return the phone's state as a string
function gPhone.getPhoneState()
	return gPhone.phoneState
end

--// Assorted functions which returns booleans based on the phone state
function gPhone.onHomescreen()
	return gPhone.phoneState == "home"
end

function gPhone.inFolder()
	return gPhone.phoneState == "folder"
end

function gPhone.onLockscreen()
	return gPhone.phoneState == "lock"
end

function gPhone.isOpen()
	return gPhone.phoneState != "hidden" and gPhone.phoneState != "destroyed"
end

function gPhone.exists()
	return gPhone.phoneState != "destroyed"
end

function gPhone.isHidden()
	return gPhone.phoneState == "hidden"
end
--\\


--// Sets the active homescreen folder
function gPhone.setActiveFolder( tbl )
	gPhone.currentFolder = tbl
end

function gPhone.getActiveFolder()
	return gPhone.currentFolder or {}
end
--\\

--// Sets the homescreen panel for the active folder
function gPhone.setActiveFolderPanel( pnl )
	gPhone.currentFolderPnl = pnl
end

function gPhone.getActiveFolderPanel()
	return gPhone.currentFolderPnl
end
--\\

--// Tells the active folder to close itself 
function gPhone.closeFolder()
	local pnl = gPhone.getActiveFolderPanel()
	
	if IsValid(pnl) then
		pnl:closeFolder()
	end
end

--// If the phone is currently running an animation such as rotating or appearing on the screen
function gPhone.setIsAnimating( b )
	gPhone.inAnimation = b
end

function gPhone.isAnimating()
	return gPhone.inAnimation
end
--\\

--// If the phone is currently inside an application
function gPhone.isInApp()
	return gApp["_active_"] ~= nil and gApp["_active_"] ~= {}
end

--// Currently running application table
function gPhone.setActiveApp( app ) 
	gApp["_active_"] = app
end

function gPhone.getActiveApp()
	return gApp["_active_"]
end
--\\


--// Sets the orientation (landscape or portrait) of the phone
function gPhone.setOrientation( dir )
	dir = string.lower(dir)
	gPhone.log("Changing phone orientation to "..dir)
	
	if dir == "portrait" and gPhone.orientation != "portrait" then
		gPhone.rotateToPortrait()
	elseif gPhone.orientation != "landscape" then
		gPhone.rotateToLandscape()
	else
		gPhone.msgC( GPHONE_MSGC_WARNING, "Attempted to set orientation ("..dir..") while orientation is ("..gPhone.orientation..")" )
		return
	end
	
	gPhone.orientation = dir
end

--// Instead of a getOrientation, just return bool based on portrait
function gPhone.isPortrait()
	return gPhone.orientation == "portrait"
end


--// Wallpaper
function gPhone.setWallpaper( bHome, texStr )
	if bHome then
		gPhone.config.homeWallpaperMat = Material(texStr)
		gPhone.config.homeWallpaper = texStr
	else
		gPhone.config.lockWallpaperMat = Material(texStr)
		gPhone.config.lockWallpaper = texStr
	end
end

function gPhone.getWallpaper( bHome, isMat )
	if bHome then
		if isMat then
			return gPhone.config.homeWallpaperMat or Material( gPhone.config.fallbackWallpaper )
		else
			return gPhone.config.homeWallpaper or gPhone.config.fallbackWallpaper
		end
	else
		if isMat then
			return gPhone.config.lockWallpaperMat or Material( gPhone.config.fallbackWallpaper )
		else
			return gPhone.config.lockWallpaper or gPhone.config.fallbackWallpaper
		end
	end
end
--\\