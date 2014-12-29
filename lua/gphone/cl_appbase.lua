----// Clientside Application Base //----

local client = LocalPlayer()
gPhone.Apps = gPhone.Apps or {}

-- AppBase is the table on which all applications will run
gPhone.AppBase = {}
gPhone.AppBase["_children_"] = {}

-- Storing our objects
local oldScreenPaint = nil
local oldScreenThink = nil
local appLayout = nil

-- Prepares the phone to run an application
gPhone.AppBase["_init_"] = function()
	oldScreenPaint = gPhone.phoneScreen.Paint
	oldScreenThink = gPhone.phoneScreen.Think
	
	gPhone.HomeIconLayout:SetVisible( false )
end

-- Removes application panels and restores the home screen
gPhone.AppBase["_close_"] = function()
	gPhone.phoneScreen.Paint = oldScreenPaint
	gPhone.phoneScreen.Think = oldScreenThink
	
	for k, v in pairs(gPhone.AppBase["_children_"]) do
		if IsValid(v) then
			v:Remove()
		end
	end
	
	gPhone.HomeIconLayout:SetVisible( true )
	
	if gPhone.Config.DarkenStatusBar == true then
		gPhone.DarkenStatusBar()
	else
		gPhone.LightenStatusBar()
	end
	gPhone.ShowStatusBar()
	
	gPhone.IsOnHomeScreen = false
end

--// Grabs all app files and runs them
function gPhone.ImportApps()
	local files = file.Find( "lua/gphone/apps/*.lua", "GAME" )
	
	if #files == 0 then
		error("gPhone was unable to load any apps!")
		return
	end
	
	for k, v in pairs(files) do
		include("gphone/apps/"..v)
	end
end

--// Adds an app to the phone screen and sets it up to be run
function gPhone.AddApp( data )
	local name = string.lower(data.PrintName) or "error"
	
	gPhone.AppBase[name] = {
		["Data"] = data,
		["Run"] = function()
			data.Run( gPhone.AppBase["_children_"], gPhone.phoneScreen )
			
			gPhone.phoneScreen.Paint = data.Paint
			gPhone.phoneScreen.Think = data.Think
		end
	}
	
	gPhone.Apps[data.PrintName] = data.Icon
end

--// Runs the app on the phone
function gPhone.RunApp(name)
	local name = string.lower(name)
	
	if gPhone.AppBase[name] then
		gPhone.AppBase["_init_"]() -- Prepare the phone
		
		local app = gPhone.AppBase[name]
		
		-- Check if the app has a set run gamemode
		local appGM = app.Data.Gamemode
		if appGM != nil and appGM != "" and string.lower(appGM) != string.lower(engine.ActiveGamemode()) then
			gPhone.DenyApp( appGM, "App's usable gamemode does not \r\nmatch current gamemode!" )
			return
		end
		
		-- Check usergroup privelages (unsafe, I should do this on the server)
		local whitelist = app.AllowedUsergroups
		if whitelist != nil and #whitelist > 0 then
			local isWhitelisted = false
			
			for k, v in pairs(whitelist) do
				if client:GetUserGroup():lower() == v:lower() then
					isWhitelisted = true
				end
			end
			
			if not isWhitelisted then 
				gPhone.DenyApp( appGM, "Your usergroup cannot use this app!" )
				return 
			end
		end
		
		-- Run a hook to see if there are any other conditions that need to be met
		local shouldRun = hook.Run( "gPhone_ShouldAppRun", name, gPhone.AppBase[name].Data )
		if shouldRun == false then 
			gPhone.ToHomeScreen()
			return 
		end
		
		-- All seems to be be good, run the application
		gPhone.IsOnHomeScreen = false
		app.Run()
	else
		-- This should never happen, catch it anyways
		error(string.format("App '%s' does not exist in the Application table, aborting", name))
		gPhone.ToHomeScreen()
	end
end

--// Denies the user access to an app without breaking everything
function gPhone.DenyApp( gmName, reason )
	-- Don't need to initialize the app base, its already been done
	gPhone.IsOnHomeScreen = false
		
	local screen = gPhone.phoneScreen
	local objs = gPhone.AppBase["_children_"]
	local containerWidth = screen:GetWide()-20
	
	objs.Container = vgui.Create("DPanel", screen)
	objs.Container:SetSize( containerWidth, screen:GetTall()/2.5 )
	objs.Container:SetPos( 10, screen:GetTall()/2 - objs.Container:GetTall()/2 )
	objs.Container.Paint = function()
		draw.RoundedBox(0, 0, 0, objs.Container:GetWide(), objs.Container:GetTall(), Color(250, 250, 250))
	end
	
	local topError = vgui.Create( "DLabel", objs.Container ) -- Header
	topError:SetText( "[App Error]" )
	topError:SetTextColor(Color(0,0,0))
	topError:SetFont("gPhone_Error")
	topError:SizeToContents()
	local width, height = gPhone.GetTextSize("App Error", "gPhone_Error")
	topError:SetPos( containerWidth/2 - width/2, 5 )
	
	local errorMsg = vgui.Create( "DLabel", objs.Container ) -- Actual message
	errorMsg:SetText( reason )
	errorMsg:SetTextColor(Color(0,0,0))
	errorMsg:SetFont("gPhone_StatusBar")
	errorMsg:SizeToContents()
	local width, height = gPhone.GetTextSize(reason, "gPhone_StatusBar")
	errorMsg:SetPos( containerWidth/2 - width/2, 30 )
	
end
