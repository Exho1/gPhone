local APP = {}

-- Name that appears on the home screen
APP.PrintName = "App Name"
-- Path to the icon, relative to materials directory
APP.Icon = "vgui/gphone/app_image.png"
-- Your name which can be used to attribute this app to you
APP.Author = "Coder Name"
-- Short describing words for your app which may be used to help name a folder containing your app
APP.Tags = {}

-- Gamemode which this app's use is restricted to. Useful if it contains gamemode-specific functions or variables
APP.Gamemode = ""
-- Usergroups which can use this app, all others will be directed to a denial screen. 
APP.AllowedUsergroups = {}
-- Used ONLY for games to detour the app's Think function into a ticker that attempts to call it X times per second
APP.FPS = nil
-- Prevents the app from appearing on the homescreen initially 
APP.Hidden = false

-- Called when your App opens
function APP.Run( objects, screen )

end

-- Called when the phone screen's Think function is called
function APP.Think( screen )
	
end

-- Called when the phone screen's Paint function is called
function APP.Paint( screen )
	
end

-- Called when the app is told to close and the app's objects are about to be cleaned up
function APP.Close()

end

-- This adds the application to the phone
--gPhone.addApp(APP)