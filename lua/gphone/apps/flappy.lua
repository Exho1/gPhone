local APP = {}
local trans = gPhone.getTranslation

APP.PrintName = "Flappy"
APP.Icon = "vgui/gphone/flappy.png"
APP.Author = "Exho"
APP.Tags = {"Garry", "Game", "Dumb"}

-- Flappy Garry is mostly copied code from a Flappy Bird clone I made in Love2D of my programming teacher  

function APP.Run( objects, screen )
	gPhone.hideStatusBar()

	objects.logo = vgui.Create( "DImage", screen )
	objects.logo:SetImage( "vgui/gphone/apps/fg_logo.png" )
	objects.logo:SetSize( 175, 100 )
	objects.logo:SetPos( screen:GetWide()/2-objects.logo:GetWide()/2, screen:GetTall()/2-objects.logo:GetWide() )
	
	objects.player = vgui.Create( "DImage", screen )
	objects.player:SetImage( "vgui/gphone/apps/garry.png" )
	objects.player:SetSize( 64, 74 )
	objects.player:SetPos( screen:GetWide()/2-objects.player:GetWide()/2, screen:GetTall()/2-objects.player:GetWide()/2 )
	objects.player.velocity = 0
	
	objects.pressEnter = vgui.Create("DLabel", screen)
	objects.pressEnter:SetTextColor( color_white )
	objects.pressEnter:SetFont( "gPhone_flappy30" ) 
	objects.pressEnter:SetText( trans( "enter_play" ) )
	objects.pressEnter:SizeToContents()
	objects.pressEnter:SetPos( screen:GetWide()/2 - objects.pressEnter:GetWide()/2, screen:GetTall() - 75 )
	objects.pressEnter.Paint = function( self )
		draw.DrawText( self:GetText(), self:GetFont(), 2, 2, color_black )
	end
	objects.pressEnter.Think = function( self )
		if input.IsKeyDown( KEY_ENTER ) then
			APP.SetUpGame()
		end
	end
end

local gameRunning = false
local gameLost = false
local pipesPassed = 0
local gravity = 9.8
local bgMoveX = 250
local pipes = {}
function APP.SetUpGame()
	local objects = gApp["_children_"]
	local screen = gPhone.phoneScreen
	
	for k, v in pairs( objects ) do
		if IsValid(v) then
			v:SetVisible(false)
		end
	end
	
	pipes = {}
	
	objects.player:SetVisible( true )
	
	objects.score = vgui.Create("DLabel", screen)
	objects.score:SetTextColor( color_white )
	objects.score:SetFont( "gPhone_flappy50" ) 
	objects.score:SetText("0")
	objects.score:SizeToContents()
	objects.score:SetPos( screen:GetWide()/2 - objects.score:GetWide()/2, screen:GetWide()/4 )
	objects.score.updateScore = function( self, val )
		local num = tonumber( self:GetText() )
		if not val then
			num = num + 1
		else
			num = val
		end
		
		objects.score:SetText(num)
		objects.score:SizeToContents()
		objects.score:SetPos( screen:GetWide()/2 - objects.score:GetWide()/2, screen:GetWide()/4 )
	end
	
	gameRunning = true
	gameLost = false
	
	pipesPassed = 0
	pipes = {}
	
	-- Create pipes
	local x = 234 * 1.5
	for i = 1, 10 do
		APP.createPipe( x )
		x = x + 150 + math.random( objects.player:GetWide() * 1.5, objects.player:GetWide() * 3 ) 
	end
end

function APP.Think( screen )	
	local objects = gApp["_children_"]
	local x, y = objects.player:GetPos()
	
	local player = objects.player
	
	if gameLost then
		gameRunning = false
		bgMoveX = 0
		return
	end
	
	if not gameRunning then
		-- Freeze player 
		y = screen:GetTall()/3
	else
		-- Clamp player position - top
		if player.y <= 0 then
			y = 0
		end
	
		-- GRAVITY! Velocity = Velocity + Gravity * Delta Time
		player.velocity = player.velocity + gravity * FrameTime()
		y = y + player.velocity
	
		-- Clamp player's jump velocity
		if player.velocity < -5 then
			player.velocity = -5
		elseif player.velocity > 5 then
			player.velocity = 5
		end
		
		-- Clamp player position - bottom. These need to be called at seperate areas or bad stuff happens
		if y + player:GetTall() >= screen:GetTall() - 100 then
			y = screen:GetTall() - 100 - player:GetTall()
		end
		
		player:SetPos( x, y )
		
		if APP.WasSpacePressed() then
			player.velocity = -1.5
		end
		
		for k, tbl in pairs( pipes ) do
			tbl.top.x = tbl.top.x - bgMoveX
			tbl.bottom.x = tbl.bottom.x - bgMoveX
			
			-- Detect collisions between player and pipe
			if x + player:GetWide() >= tbl.top.x and x <= tbl.top.x + 60 then
				if tbl.top.x >= 416/3 then
					if y <= tbl.top.y + 311 then
						gameLost = true
					end
					
					if y + player:GetTall() >= tbl.bottom.y then
						gameLost = true
					end
				end
			end
			
			-- Increment the passed counter and remove old pipes
			if tbl.top.x + 60 < x and not pipes[k].passed then 
				pipesPassed = pipesPassed + 1
				pipes[k].passed = true
				
				objects.score:updateScore()
			elseif tbl.top.x + 60 < 0 then
				table.remove(pipes, k)
				APP.createPipe( pipes[#pipes].top.x + 60 + math.random( 100, 300 ) )
			end
		end
		
		if tonumber(objects.score:GetText()) == 10 then -- Oh my god...
			gameRunning = false
			objects.player:SizeTo( screen:GetWide()*2, screen:GetTall()*2, 2 )
			objects.player:MoveTo( -screen:GetWide()/2, -screen:GetTall()/2, 2 )
		end
	end
end

local nextPress = 0
function APP.WasSpacePressed()
	if input.IsKeyDown( KEY_SPACE ) then
		if CurTime() > nextPress then	
			nextPress = CurTime() + 0.2
			return true
		end
	end
end

local lastY = 416/4
function APP.createPipe( x )
	local objects = gApp["_children_"]
	
	top = {}
	bottom = {}
	
	local h = objects.player:GetTall()
	local buffer = math.random( h * 1.5, h * 2.5 ) -- Space between pipes
	local nextY = math.random( lastY - 200, lastY + 200) -- Next Y value for the pipes
	
	-- Clamp values in playing area
	if nextY < 100 then
		nextY = 100
	elseif nextY > 416 - 150 - buffer then
		nextY = 416 - 150 - buffer
	end 
	
	lastY = nextY
	
	-- Insert positions into the pipe table
	top.x = x
	top.y = nextY - 311
	bottom.x = x
	bottom.y = nextY + buffer
	
	table.insert( pipes, {top=top, bottom=bottom} )
end

local matGameLost = Material( "vgui/gphone/apps/fg_gameover.png" )
local matBackground = Material( "vgui/gphone/apps/fg_background.png" )
local matForeground = Material( "vgui/gphone/apps/fg_ground.png" )
local matTopPipe = Material( "vgui/gphone/apps/fg_top_pipe.png" )
local matBottomPipe = Material( "vgui/gphone/apps/fg_bottom_pipe.png" )

local firstBGX = 0
local nextBGX = 234
function APP.Paint( screen )
	local objects = gApp["_children_"]
	
	draw.RoundedBox( 0, 0, 0, screen:GetWide(), screen:GetTall(), color_white )
	
	surface.SetDrawColor( color_white )
	surface.SetMaterial( matBackground )
	surface.DrawTexturedRect( firstBGX, 0, screen:GetWide(), screen:GetTall() )
	
	surface.SetMaterial( matBackground )
	surface.DrawTexturedRect( nextBGX, 0, screen:GetWide(), screen:GetTall() )
	
	for k, tbl in pairs( pipes ) do
		surface.SetMaterial( matTopPipe )
		surface.DrawTexturedRect( tbl.top.x, tbl.top.y, 60, 311 )
		
		surface.SetMaterial( matBottomPipe )
		surface.DrawTexturedRect( tbl.bottom.x, tbl.bottom.y, 60, 210 )
	end
	
	surface.SetMaterial( matForeground )
	surface.DrawTexturedRect( firstBGX, screen:GetTall() - 100, screen:GetWide(), 100 )
	
	surface.SetMaterial( matForeground )
	surface.DrawTexturedRect( nextBGX, screen:GetTall() - 100, screen:GetWide(), 100 )
	
	
	if gameLost or not gameRunning then 
		if gameLost then
			surface.SetMaterial( matGameLost )
			local w, h = 200, 40
			surface.DrawTexturedRect( screen:GetWide()/2 - w/2, screen:GetTall()/3, w, h )
			
			objects.pressEnter:SetVisible( true )
		end
		
		return 
	end
	
	bgMoveX = 250 * RealFrameTime()
	
	firstBGX = firstBGX - bgMoveX
	nextBGX = nextBGX - bgMoveX
	if firstBGX + 234 <= 0 then
		firstBGX = 233 - 1 - RealFrameTime()
	elseif nextBGX + 234 <= 0 then
		nextBGX = 233 - 1 - RealFrameTime()
	end
end

function APP.Close()
	pipes = {}
end

surface.CreateFont( "gPhone_flappy50", {
	font = "04b_19",
	size = 50,
	weight = 500,
	antialias = true,
} )

surface.CreateFont( "gPhone_flappy30", {
	font = "04b_19",
	size = 20,
	weight = 500,
	antialias = true,
} )


gPhone.addApp(APP)