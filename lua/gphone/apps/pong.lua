local APP = {}

APP.PrintName = "gPong"
APP.Icon = "vgui/gphone/pong.png"

--// Game variables
math.randomseed(os.time())
local gameOptions = {
	"Player v Bot",
	"Player v Player",
	"Player v Self", 
}
local difficultyLevels = {
	["Easy"] = 100,
	["Intermediate"] = 125,
	["Hard"] = 150,
	
}
local objectBounds = {}

local isInGame = false
local gameRunning = false
local difficultySpeed = difficultyLevels.Easy -- Default 
local paddleStartY = nil

-- Enumerations
local PONG_PLAYER1 = 1
local PONG_PLAYER2 = 2

local PONG_GAME_BOT = 1
local PONG_GAME_MP = 2
local PONG_GAME_SELF = 3

local PONG_BALLSIDE_LEFT = 1
local PONG_BALLSIDE_CENTER = 1
local PONG_BALLSIDE_RIGHT = 1

--// App run
function APP.Run( objects, screen )
	gPhone.HideStatusBar()
	isInGame = false
	gameRunning = false
	
	objects.Layout = vgui.Create( "DIconLayout", screen)
	objects.Layout:SetSize( screen:GetWide(), screen:GetTall())
	objects.Layout:SetPos( 0, 0 )
	objects.Layout:SetSpaceY( 0 )
	
	local titleButton = objects.Layout:Add("DButton")
	titleButton:SetSize(screen:GetWide(), 50)
	titleButton:SetText("")
	titleButton.Paint = function( self, w, h )
		surface.SetDrawColor( color_white )
		surface.DrawOutlinedRect( 5, 5, w-10, h-10 )
	end
	titleButton.DoClick = function() -- Put us back at the main menu
		gPhone.HideChildren( objects.Layout )
		APP.Run( objects, screen )
	end
	
	local title = vgui.Create( "DLabel", titleButton)
	title:SetText( "gPong" )
	title:SetTextColor( color_white )
	title:SetFont("gPhone_Error")
	title:SizeToContents()
	gPhone.SetTextAndCenter(title, titleButton, true)
	
	local fake = objects.Layout:Add("DPanel")
	fake:SetSize(screen:GetWide(), 50)
	fake.Paint = function() end
	
	for key, str in pairs(gameOptions) do
		local optionPanel = objects.Layout:Add("DPanel")
		optionPanel:SetSize(screen:GetWide(), 30)
		optionPanel.Paint = function() end

		local optionButton = vgui.Create("DButton", optionPanel)
		optionButton:SetPos(30, 0)
		optionButton:SetSize( optionPanel:GetWide() - 60, optionPanel:GetTall() )
		optionButton:SetText( str )
		optionButton:SetFont( "gPhone_Title" )
		optionButton:SetTextColor( color_white )
		optionButton.Paint = function( self, w, h )
			if self:IsDown() then
				draw.RoundedBox(2, 0, 0, w, h, Color(180, 180, 180))
			end
			
			surface.SetDrawColor( color_white )
			surface.DrawOutlinedRect( 0, 0, w, h )
		end
		optionButton.DoClick = function()
			APP.OptionClick( str )
		end
		
		local fake = objects.Layout:Add("DPanel") -- Invisible panel for spacing
		fake:SetSize(screen:GetWide(), 20)
		fake.Paint = function() end
	end
end

function APP.OptionClick( option )
	local objects = gPhone.AppBase["_children_"]
	local screen = gPhone.phoneScreen
	local layout = objects.Layout
	
	for k, v in pairs(layout:GetChildren()) do
		if IsValid(v) and k > 2 then -- Dont hide the title and spacer
			v:SetVisible(false)
		end
	end
	
	if option == gameOptions[1] then -- Playing against a Bot
		for str, num in pairs(difficultyLevels) do
			local optionPanel = objects.Layout:Add("DPanel")
			optionPanel:SetSize(screen:GetWide(), 30)
			optionPanel.Paint = function() end

			local optionButton = vgui.Create("DButton", optionPanel)
			optionButton:SetPos(30, 0)
			optionButton:SetSize( optionPanel:GetWide() - 60, optionPanel:GetTall() )
			optionButton:SetText( str )
			optionButton:SetFont( "gPhone_Title" )
			optionButton:SetTextColor( color_white )
			optionButton.Paint = function( self, w, h )
				if self:IsDown() then
					draw.RoundedBox(2, 0, 0, w, h, Color(180, 180, 180))
				end
				
				surface.SetDrawColor( color_white )
				surface.DrawOutlinedRect( 0, 0, w, h )
			end
			optionButton.DoClick = function()
				difficultySpeed = num 
				
				APP.SetUpGame( PONG_GAME_BOT )
			end
			
			local fake = objects.Layout:Add("DPanel") -- Invisible panel for spacing
			fake:SetSize(screen:GetWide(), 20)
			fake.Paint = function() end
		end
	elseif option == gameOptions[2] then -- Playing against a live player
		--APP.SetUpGame( PONG_GAME_MP )
		
		local playerPanel = objects.Layout:Add("DPanel")
		playerPanel:SetSize(screen:GetWide(), 40)
		playerPanel.Paint = function() end
		
		local opponentPicker = vgui.Create( "DComboBox", playerPanel )
		opponentPicker:SetPos( 30, 0 )
		opponentPicker:SetSize( playerPanel:GetWide() - 60, playerPanel:GetTall() )
		opponentPicker:SetValue( "Opponent" )
		opponentPicker:SetTextColor( color_white )
		opponentPicker:SetFont( "gPhone_Title" )
		opponentPicker.Paint = function( self, w, h )
			surface.SetDrawColor( color_white )
			surface.DrawOutlinedRect( 0, 0, w, h )
			
			--[[if IsValid(self.Menu) then
				self.Menu.Paint = function( self, w, h )
					surface.SetDrawColor( color_white )
					surface.DrawOutlinedRect( 0, 0, w, h )
				end
			end]]
		end
		for k, v in pairs( player.GetAll() ) do
			opponentPicker:AddChoice( v:Nick() )
		end
		
		local fake = objects.Layout:Add("DPanel") -- Invisible panel for spacing
		fake:SetSize(screen:GetWide(), 20)
		fake.Paint = function() end
		
		local confirmPanel = objects.Layout:Add("DPanel")
		confirmPanel:SetSize(screen:GetWide(), 30)
		confirmPanel.Paint = function() end

		local confirmButton = vgui.Create("DButton", confirmPanel)
		confirmButton:SetPos(30, 0)
		confirmButton:SetSize( confirmPanel:GetWide() - 60, confirmPanel:GetTall() )
		confirmButton:SetText( "Challenge Player!" )
		confirmButton:SetFont( "gPhone_Title" )
		confirmButton:SetTextColor( color_white )
		confirmButton.Paint = function( self, w, h )
			if self:IsDown() then
				draw.RoundedBox(2, 0, 0, w, h, Color(180, 180, 180))
			end
			
			surface.SetDrawColor( color_white )
			surface.DrawOutlinedRect( 0, 0, w, h )
		end
		confirmButton.DoClick = function()
			local ply = util.GetPlayerByNick( opponentPicker:GetText() )
			local gameResponse = gPhone.RequestGame(ply, APP.PrintName)
			
			gPhone.ChatMsg("Challenged "..ply:Nick().."!")
		end
		
	elseif option == gameOptions[3] then -- Playing against someone else on their computer
		local helpPanel = objects.Layout:Add("DPanel")
		helpPanel:SetSize(screen:GetWide(), 80)
		helpPanel.Paint = function() end

		local helpLabel = vgui.Create("DLabel", helpPanel)
		helpLabel:SetPos(30, 0)
		helpLabel:SetSize( helpPanel:GetWide() - 60, helpPanel:GetTall() )
		helpLabel:SetText( " Player 1:\r\n W and S to move\r\n Player 2:\r\n Up and Down arrow keys" )
		helpLabel:SetFont( "gPhone_Title" )
		helpLabel.Paint = function( self, w, h )
			surface.SetDrawColor( color_white )
			surface.DrawOutlinedRect( 0, 0, w, h )
		end
		
		local fake = objects.Layout:Add("DPanel") -- Invisible panel for spacing
		fake:SetSize(screen:GetWide(), 20)
		fake.Paint = function() end
		
		local optionPanel = objects.Layout:Add("DPanel")
		optionPanel:SetSize(screen:GetWide(), 30)
		optionPanel.Paint = function() end

		local optionButton = vgui.Create("DButton", optionPanel)
		optionButton:SetPos(30, 0)
		optionButton:SetSize( optionPanel:GetWide() - 60, optionPanel:GetTall() )
		optionButton:SetText( "Start!" )
		optionButton:SetFont( "gPhone_Title" )
		optionButton:SetTextColor( color_white )
		optionButton.Paint = function( self, w, h )
			if self:IsDown() then
				draw.RoundedBox(2, 0, 0, w, h, Color(180, 180, 180))
			end
			
			surface.SetDrawColor( color_white )
			surface.DrawOutlinedRect( 0, 0, w, h )
		end
		optionButton.DoClick = function()
			APP.SetUpGame( PONG_GAME_SELF )
		end
	end
end

-- Boundaries are needed to detect hits and such
local function setBounds( obj )
	-- Code inspired from my HUD designer
	local x, y = obj:GetPos()
	local w, h = obj:GetSize()
	
	objectBounds[obj] = {x=x, y=y, width=w, height=h}
end

-- Set up the game to be played
local gameType = nil
local ballSide = PONG_BALLSIDE_CENTER
function APP.SetUpGame( type )
	local objects = gPhone.AppBase["_children_"]
	local screen = gPhone.phoneScreen
	
	for k, v in pairs(objects) do
		if IsValid(v) then
			v:SetVisible(false)
		end
	end
	
	gPhone.RotateToLandscape()
	isInGame = true
	objectBounds = {}
	
	gameType = type
	--PONG_GAME_BOT
	--PONG_GAME_MP
	--PONG_GAME_SELF
	
	objects.ScoreP1 = vgui.Create( "DLabel", screen)
	objects.ScoreP1:SetText( "0" )
	objects.ScoreP1:SetTextColor( color_white )
	objects.ScoreP1:SetFont("gPhone_Error")
	objects.ScoreP1:SizeToContents()
	objects.ScoreP1:SetPos( screen:GetWide()/2 - objects.ScoreP1:GetWide() - 10, 10 )
	
	objects.ScoreP2 = vgui.Create( "DLabel", screen)
	objects.ScoreP2:SetText( "0" )
	objects.ScoreP2:SetTextColor( color_white )
	objects.ScoreP2:SetFont("gPhone_Error")
	objects.ScoreP2:SizeToContents()
	objects.ScoreP2:SetPos( screen:GetWide()/2 + 10, 10 )
	
	objects.PaddleP1 = vgui.Create("DPanel", screen)
	objects.PaddleP1:SetSize( 10, 50 )
	objects.PaddleP1:SetPos( 15, screen:GetTall()/2 - objects.PaddleP1:GetTall()/2)
	objects.PaddleP1.Paint = function( self, w, h )
		draw.RoundedBox(0, 0, 0, w, h, color_white )
	end
	setBounds( objects.PaddleP1 )
	
	objects.PaddleP2 = vgui.Create("DPanel", screen)
	objects.PaddleP2:SetSize( 10, 50 )
	objects.PaddleP2:SetPos( screen:GetWide() - objects.PaddleP1:GetWide() - 15, screen:GetTall()/2 - objects.PaddleP1:GetTall()/2)
	objects.PaddleP2.Paint = function( self, w, h )
		draw.RoundedBox(0, 0, 0, w, h, color_white )
	end
	setBounds( objects.PaddleP2 )
	
	paddleStartY = select(2, objects.PaddleP1:GetPos())

	objects.Ball = vgui.Create("DPanel", screen)
	objects.Ball:SetSize( 15, 15 )
	objects.Ball:SetPos( screen:GetWide()/2 - objects.Ball:GetWide()/2, screen:GetTall()/2 - objects.Ball:GetTall()/2)
	objects.Ball.Paint = function( self, w, h )
		draw.RoundedBox(0, 0, 0, w, h, color_white )
	end
	objects.Ball.VelocityX = 0
	objects.Ball.VelocityY = 0
	setBounds( objects.Ball )
	
	timer.Simple(2, function()
		gameRunning = true
	end)
end

--// Game related functions
local function resetBall() -- Move the ball back to the center and start the game back up
	local objects = gPhone.AppBase["_children_"]
	local screen = gPhone.phoneScreen
	
	gameRunning = false
	ballSide = PONG_BALLSIDE_CENTER
	
	objects.Ball:SetPos( screen:GetWide()/2 - objects.Ball:GetWide()/2, screen:GetTall()/2 - objects.Ball:GetTall()/2)
	objects.Ball.VelocityX = 0
	objects.Ball.VelocityY = 0
	
	timer.Simple(2, function()
		gameRunning = true
	end)
end

local function scorePoint( plyNum ) -- Add 1 point to one of the players
	local objects = gPhone.AppBase["_children_"]
	local screen = gPhone.phoneScreen
	
	resetBall()
	
	if plyNum == PONG_PLAYER1 then
		local curScore = tonumber( objects.ScoreP1:GetText() )
		objects.ScoreP1:SetText( curScore + 1 )
	else
		local curScore = tonumber( objects.ScoreP2:GetText() )
		objects.ScoreP2:SetText( curScore + 1 )
	end
end

local function movePaddle( obj, up ) -- Move the paddle
	if !IsValid( obj ) then return end
	
	local screenTop, screenBottom = 10, gPhone.phoneScreen:GetTall()-10-gPhone.AppBase["_children_"].PaddleP1:GetTall()
	local delta = 200 * RealFrameTime()
	local moveDistance = 2
	
	local x, y = obj:GetPos()
	if up then 
		obj:SetPos( x, math.Clamp(Lerp( delta, y, y - moveDistance ), screenTop, screenBottom) )
	else
		obj:SetPos( x, math.Clamp(Lerp( delta, y, y + moveDistance ), screenTop, screenBottom) )
	end
end

local function movePaddleBot( yPos, onFinished ) -- Bots need a special move function
	local screenTop, screenBottom = 10, gPhone.phoneScreen:GetTall()-10-gPhone.AppBase["_children_"].PaddleP1:GetTall()
	local delta = 200 * RealFrameTime()
	local moveDistance = 2
	
	local x, y = obj:GetPos()
	
	obj:SetPos( x, math.Clamp(Lerp( delta, y, y + (y-yPos) ), screenTop, screenBottom) )
	
	if y == yPos and IsValid(onFinished) then 
		onFinished() -- Callback functions 
	end
end

local function moveBall( bHit, hitPaddle, plyNum ) -- Move the ball 
	local screen = gPhone.phoneScreen
	local ball = gPhone.AppBase["_children_"].Ball
	if !IsValid( ball ) then return end
	
	local ballX, ballY = ball:GetPos()
	
	-- Check if the ball has hit one of the screen boundaries
	if ballX == 10 then
		ball.VelocityX = 0
	elseif ballX == screen:GetWide() - ball:GetWide() - 10 then
		ball.VelocityX = 0
	elseif ballY == 10 then
		ball.VelocityY = 0
	elseif ballY == screen:GetTall() - ball:GetTall() - 10 then
		ball.VelocityY = 0
	end

	-- Give the ball some velocity
	if not bHit then -- It has not hit anything
		if ball.VelocityX == 0 then
			local dir = math.random(2)
			if dir == 1 then
				ball.VelocityX = 2
			else
				ball.VelocityX = -2
			end
		end
		if ball.VelocityY == 0 then
			local dir = math.random(2)
			if dir == 1 then
				ball.VelocityY = -2
			else
				ball.VelocityY = 2
			end
		end
	else -- It has hit a paddle
		local x, y = hitPaddle:GetPos()
		
		if plyNum == PONG_PLAYER1 then -- Player 1's paddle hit the ball
			if ballY <= y + hitPaddle:GetTall()/2 then -- Ball hit lower half of the paddle
				ball.VelocityX = 2
				ball.VelocityY = -2
			else
				ball.VelocityX = 2
				ball.VelocityY = 2
			end
		else
			if ballY <= y + hitPaddle:GetTall()/2 then
				ball.VelocityX = -2
				ball.VelocityY = -2
			else
				ball.VelocityX = -2
				ball.VelocityY = 2
			end
		end
	end
	
	-- Track which side the ball is on
	if ballX <= screen:GetWide()/2 then
		ballSide = PONG_BALLSIDE_LEFT
	else
		ballSide = PONG_BALLSIDE_RIGHT
	end
	
	-- Now actually move the ball across the screen
	local newX = Lerp(difficultySpeed * RealFrameTime(), ballX, ballX + ball.VelocityX)
	local newY = Lerp(difficultySpeed * RealFrameTime(), ballY, ballY + ball.VelocityY)
	newX = math.Clamp( newX, 10, screen:GetWide() - ball:GetWide() - 10) -- Clamp within the playing area
	newY = math.Clamp( newY, 10, screen:GetTall() - ball:GetTall() - 10)
	
	ball:SetPos( newX, newY )
end

local function checkCollision( obj, plyNum ) -- Check collisions between objects
	local paddle = objectBounds[obj] -- Paddle
	local ball= objectBounds[gPhone.AppBase["_children_"].Ball] -- Ball
	
	if plyNum == PONG_PLAYER1 then -- Player 1
		if paddle.x + paddle.width >= ball.x then
			if paddle.y <= ball.y and paddle.y + paddle.height >= ball.y then 
				moveBall( true, gPhone.AppBase["_children_"].PaddleP1, 1 )
			elseif paddle.x >= ball.x then
				scorePoint( PONG_PLAYER1 )
			end
		end
	else -- Player 2
		if paddle.x - paddle.width <= ball.x then
			if paddle.y <= ball.y and paddle.y + paddle.height >= ball.y then
				moveBall( true, gPhone.AppBase["_children_"].PaddleP2, 2 )
			elseif paddle.x <= ball.x then
				scorePoint( PONG_PLAYER2 )
			end
		end
	end
end

local function handleBot() -- Create an opponent for a Player v Bot game
	-- Add: Difficulty
	local objects = gPhone.AppBase["_children_"]
	local paddle = objects.PaddleP2
	local x, y = paddle:GetPos()
	
	--print(ballSide)
	if ballSide == PONG_BALLSIDE_CENTER or not gameRunning then -- Do nothing
		if y != paddleStartY then -- Move to the center
			movePaddleBot( centerY )
		end
	elseif ballSide == PONG_BALLSIDE_RIGHT then -- Get ready to whack it!
		-- movePaddle( objects.PaddleP2, true ) -- move up
		
	else -- Its not on our side yet
		if ball.VelocityX > 0 then -- It coming to our side
			
		else
			movePaddleBot( centerY, function() -- Wander a bit
				movePaddleBot( math.random( centerY - 50, centerY + 50 ) )
			end)
		end
	end

end

--// We basically run the game in the application's Think function
function APP.Think()
	local objects = gPhone.AppBase["_children_"]
	local screen = gPhone.phoneScreen
	
	if isInGame then
		-- Manage the client's Paddle
		if input.IsKeyDown( KEY_S ) then
			movePaddle( objects.PaddleP1, false )
		elseif input.IsKeyDown( KEY_W )  then
			movePaddle( objects.PaddleP1, true )
		end
		
		-- If its a self game, allow another user to play
		if gameType == PONG_GAME_SELF then 
			if input.IsKeyDown( KEY_DOWN ) then
				movePaddle( objects.PaddleP2, false )
			elseif input.IsKeyDown( KEY_UP )  then
				movePaddle( objects.PaddleP2, true )
			end
		elseif gameType == PONG_GAME_MP then
		
		end
		
		-- This block of code runs the entire game
		if gameRunning then
			-- Move the ball
			moveBall() 
			
			-- Check paddle/ball collisions
			checkCollision( objects.PaddleP1, 1 )
			checkCollision( objects.PaddleP2, 2 )
			
			-- Update boundaries/hitboxes
			setBounds( objects.PaddleP1 )
			setBounds( objects.PaddleP2 )
			setBounds( objects.Ball )
			
			if gameType == PONG_GAME_BOT then
				handleBot()
			end
		end
	end
end

function APP.Paint( screen )
	draw.RoundedBox(2, 0, 0, screen:GetWide(), screen:GetTall(), Color(0, 0, 0))
	
	if isInGame then -- Draw the game board
		surface.SetDrawColor( color_white )
		surface.DrawOutlinedRect( 5, 5, screen:GetWide() - 10, screen:GetTall() - 10 )
		
		draw.RoundedBox(0, screen:GetWide()/2, 5, 1, screen:GetTall() - 10, color_white )
	end
end

gPhone.AddApp(APP)