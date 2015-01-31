local APP = {}

APP.PrintName = "gPong"
APP.Icon = "vgui/gphone/pong.png"
APP.FPS = 30
APP.Tags = {"Game", "Retro", "2D"}

--// Game variables
local gameOptions = {
	"Player v Bot",
	"Player v Player",
	"Player v Self", 
}
local difficultyLevels = {
	["Easy"] = {ball=4, ply=4, bot=3},
	["Intermediate"] = {ball=6, ply=5, bot=5},
	["Hard"] = {ball=8, ply=7, bot=8},
}
local objectBounds = {}

local winScore = 10
local isInGame = false
local gameRunning = false
local gamePaused = false

local ballSpeed = difficultyLevels.Easy.ball
local botSpeed = difficultyLevels.Easy.bot
local playerSpeed = difficultyLevels.Easy.ply
local paddleStartY = nil

-- Enumerations
local PONG_PLAYER1 = 1
local PONG_PLAYER2 = 2
local PONG_GAME_BOT = 1
local PONG_GAME_MP = 2
local PONG_GAME_SELF = 3
local PONG_BALLSIDE_LEFT = 1
local PONG_BALLSIDE_CENTER = 2
local PONG_BALLSIDE_RIGHT = 3

--// App run
function APP.Run( objects, screen )
	gPhone.hideStatusBar()
	isInGame = false
	gameRunning = false
	gamePaused = false
	
	objects.Layout = vgui.Create( "DIconLayout", screen)
	objects.Layout:SetSize( screen:GetWide(), screen:GetTall())
	objects.Layout:SetPos( 0, 0 )
	objects.Layout:SetSpaceY( 0 )
	
	local titleButton = objects.Layout:Add("DButton")
	titleButton:SetSize(screen:GetWide(), 50)
	titleButton:SetText("")
	titleButton.Paint = function( self, w, h )
		if self:IsDown() then
			draw.RoundedBox(2, 5, 5, w-10, h-10, Color(180, 180, 180))
		end
			
		surface.SetDrawColor( color_white )
		surface.DrawOutlinedRect( 5, 5, w-10, h-10 )
	end
	titleButton.DoClick = function() -- Put us back at the main menu
		gPhone.hideChildren( objects.Layout )
		APP.Run( objects, screen )
	end
	
	local title = vgui.Create( "DLabel", titleButton)
	title:SetTextColor( color_white )
	title:SetFont("gPhone_22")
	title:SizeToContents()
	gPhone.setTextAndCenter(title, "gPong", titleButton, true)
	
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
		optionButton:SetFont( "gPhone_18" )
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
	local objects = gApp["_children_"]
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
			optionButton:SetFont( "gPhone_18" )
			optionButton:SetTextColor( color_white )
			optionButton.Paint = function( self, w, h )
				if self:IsDown() then
					draw.RoundedBox(2, 0, 0, w, h, Color(180, 180, 180))
				end
				
				surface.SetDrawColor( color_white )
				surface.DrawOutlinedRect( 0, 0, w, h )
			end
			optionButton.DoClick = function()
				ballSpeed = num.ball
				botSpeed = num.bot
				playerSpeed = num.ply
				
				APP.SetUpGame( PONG_GAME_BOT )
			end
			
			local fake = objects.Layout:Add("DPanel") -- Invisible panel for spacing
			fake:SetSize(screen:GetWide(), 20)
			fake.Paint = function() end
		end
	elseif option == gameOptions[2] then -- Playing against a live player
		local playerPanel = objects.Layout:Add("DPanel")
		playerPanel:SetSize(screen:GetWide(), 40)
		playerPanel.Paint = function() end
		
		local opponentPicker = vgui.Create( "DComboBox", playerPanel )
		opponentPicker:SetPos( 30, 0 )
		opponentPicker:SetSize( playerPanel:GetWide() - 60, playerPanel:GetTall() )
		opponentPicker:SetValue( "Opponent" )
		opponentPicker:SetTextColor( color_white )
		opponentPicker:SetFont( "gPhone_18" )
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
			if v != LocalPlayer() then
				opponentPicker:AddChoice( v:Nick() )
			end
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
		confirmButton:SetFont( "gPhone_18" )
		confirmButton:SetTextColor( color_white )
		confirmButton.Paint = function( self, w, h )
			if self:IsDown() then
				draw.RoundedBox(2, 0, 0, w, h, Color(180, 180, 180))
			end
			
			surface.SetDrawColor( color_white )
			surface.DrawOutlinedRect( 0, 0, w, h )
		end
		confirmButton.DoClick = function()
			local ply = util.getPlayerByNick( opponentPicker:GetText() )
			if IsValid(ply) then
				local gameResponse = gPhone.requestGame(ply, APP.PrintName)
				
				-- The server tells us when to set up the game
				APP.SetUpGame( PONG_GAME_MP )
			end
		end
	elseif option == gameOptions[3] then -- Playing against someone else on their computer
		local helpPanel = objects.Layout:Add("DPanel")
		helpPanel:SetSize(screen:GetWide(), 80)
		helpPanel.Paint = function() end

		local helpLabel = vgui.Create("DLabel", helpPanel)
		helpLabel:SetPos(30, 0)
		helpLabel:SetSize( helpPanel:GetWide() - 60, helpPanel:GetTall() )
		helpLabel:SetText( " Player 1:\r\n W and S to move\r\n Player 2:\r\n Up and Down arrow keys" )
		helpLabel:SetFont( "gPhone_18" )
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
		optionButton:SetFont( "gPhone_18" )
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

-- Remove all game elements and move to the main menu
local gameType = nil
function APP.QuitToMainMenu()	
	local objects = gApp["_children_"]
	
	for k, v in pairs( objects ) do
		if IsValid(v) then
			v:Remove()
		end
	end
	
	gameRunning = false
	gamePaused = false
		
	gPhone.setOrientation( "portrait" )
	APP.Run( objects, gPhone.phoneScreen )
	
	if gameType == PONG_GAME_MP then
		gPhone.updateToNetStream( {header=GPHONE_MP_PLAYER_QUIT} ) -- Tell the server that we quit
	end
end

-- Set up the game to be played
local ballSide = PONG_BALLSIDE_CENTER
function APP.SetUpGame( type )
	local objects = gApp["_children_"]
	local screen = gPhone.phoneScreen
	
	for k, v in pairs(objects) do
		if IsValid(v) then
			v:SetVisible(false)
		end
	end
	
	gPhone.setOrientation( "landscape" )
	isInGame = true
	objectBounds = {}
	traceData = {}
	
	gameType = type
	
	if gameType == PONG_GAME_BOT then

	elseif gameType == PONG_GAME_MP then

	elseif gameType == PONG_GAME_SELF then
	
	end
	
	objects.ScoreP1 = vgui.Create( "DLabel", screen)
	objects.ScoreP1:SetText( "0" )
	objects.ScoreP1:SetTextColor( color_white )
	objects.ScoreP1:SetFont("gPhone_22")
	objects.ScoreP1:SizeToContents()
	objects.ScoreP1:SetPos( screen:GetWide()/2 - objects.ScoreP1:GetWide() - 10, 10 )
	
	objects.ScoreP2 = vgui.Create( "DLabel", screen)
	objects.ScoreP2:SetText( "0" )
	objects.ScoreP2:SetTextColor( color_white )
	objects.ScoreP2:SetFont("gPhone_22")
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
	
	objects.StatusPanel = vgui.Create("DPanel", screen)
	objects.StatusPanel:SetSize(screen:GetTall()/3, 50)
	objects.StatusPanel:SetPos(screen:GetWide()/2-objects.StatusPanel:GetWide()/2, 45)
	objects.StatusPanel.Paint = function( self, w, h )
		draw.RoundedBox(0, 0, 0, w, h, color_black )
			
		surface.SetDrawColor( color_white )
		surface.DrawOutlinedRect( 0, 0, w, h )
	end
	
	local statusLabel = vgui.Create("DLabel", objects.StatusPanel)
	statusLabel:SetTextColor( color_white )
	statusLabel:SetFont( "gPhone_18" )
	statusLabel.Think = function()
		statusLabel:SizeToContents()
		gPhone.setTextAndCenter( statusLabel, nil, objects.StatusPanel, true )
		
		if timer.Exists( "gPong_StartDelay" ) then
			local time = math.Round( timer.TimeLeft("gPong_StartDelay") )
			gPhone.setTextAndCenter( statusLabel, time, objects.StatusPanel, true )
		end
	end
	
	gamePaused = false
	
	objects.StatusPanel:SetVisible(true)
	timer.Create("gPong_StartDelay", 3, 1, function()
		gameRunning = true
		timer.Destroy( "gPong_StartDelay" )
		
		if IsValid( objects.StatusPanel ) then
			objects.StatusPanel:SetVisible(false)
		end
	end)
	
	--// Pause menu panels are created early on and then hidden
	objects.LayoutPause = vgui.Create( "DIconLayout", screen)
	objects.LayoutPause:SetSize( screen:GetWide()/3, 130)
	objects.LayoutPause:SetSpaceY( 20 )
	
	local layout = objects.LayoutPause
	
	local resumeGame = layout:Add("DButton")
	resumeGame:SetSize( layout:GetWide(), 50 )
	resumeGame:SetText("Resume")
	resumeGame:SetTextColor( color_white )
	resumeGame:SetFont( "gPhone_18" )
	resumeGame.Paint = function( self, w, h )
		if self:IsDown() then
			draw.RoundedBox(2, 5, 5, w-10, h-10, Color(180, 180, 180))
		else
			draw.RoundedBox(2, 5, 5, w-10, h-10, color_black )
		end
			
		surface.SetDrawColor( color_white )
		surface.DrawOutlinedRect( 5, 5, w-10, h-10 )
	end
	resumeGame.DoClick = function() -- Resume the game
		objects.LayoutPause:SetVisible( false )
		
		if gameType != PONG_GAME_MP then -- Multiplayer games cannot be paused
			gamePaused = false
			gameRunning = true
			timer.UnPause( "gPong_StartDelay" )
		end
	end
	
	local quitGame = layout:Add("DButton")
	quitGame:SetSize( layout:GetWide(), 50 )
	quitGame:SetText("Quit")
	quitGame:SetTextColor( color_white )
	quitGame:SetFont( "gPhone_18" )
	quitGame.Paint = function( self, w, h )
		if self:IsDown() then
			draw.RoundedBox(2, 5, 5, w-10, h-10, Color(180, 180, 180))
		else
			draw.RoundedBox(2, 5, 5, w-10, h-10, color_black )
		end
			
		surface.SetDrawColor( color_white )
		surface.DrawOutlinedRect( 5, 5, w-10, h-10 )
	end
	quitGame.DoClick = function() -- Put us back at the main menu
		APP.QuitToMainMenu()
	end
	
	objects.LayoutPause:SetVisible(false)
	objects.LayoutPause:SetPos( screen:GetWide()/2 - layout:GetWide()/2, screen:GetTall()/2 - layout:GetTall()/2 )
end

local canPauseTime = 0
function APP.PauseGame()
	local objects = gApp["_children_"]
	local screen = gPhone.phoneScreen
	
	if gamePaused and CurTime() > canPauseTime then -- Enter was pressed again, close this
		objects.LayoutPause:SetVisible( false )
		
		if gameType != PONG_GAME_MP then
			gamePaused = false
			gameRunning = true
			timer.UnPause( "gPong_StartDelay" )
		end
	else -- Not paused
		canPauseTime = CurTime() + 1
		
		if gameType != PONG_GAME_MP then
			gamePaused = true
			timer.Pause( "gPong_StartDelay" )
		
			gameRunning = false
		end
		
		objects.LayoutPause:SetVisible( true )
	end
end

--// Game related functions
local function resetBall() -- Move the ball back to the center and start the game back up
	local objects = gApp["_children_"]
	local screen = gPhone.phoneScreen
	
	gameRunning = false
	ballSide = PONG_BALLSIDE_CENTER
	
	objects.Ball:SetPos( screen:GetWide()/2 - objects.Ball:GetWide()/2, screen:GetTall()/2 - objects.Ball:GetTall()/2)
	objects.Ball.VelocityX = 0
	objects.Ball.VelocityY = 0
	
	objects.StatusPanel:SetVisible(true)
	timer.Create("gPong_StartDelay", 3, 1, function()
		gameRunning = true
		timer.Destroy( "gPong_StartDelay" )
		
		if IsValid( objects.StatusPanel ) then
			objects.StatusPanel:SetVisible(false)
		end
	end)
end

local function scorePoint( plyNum ) -- Add 1 point to one of the players
	local objects = gApp["_children_"]
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

local function checkWin()
	local objects = gApp["_children_"]
	local p1Score = tonumber( objects.ScoreP1:GetText() )
	local p2Score = tonumber( objects.ScoreP2:GetText() )

	if p1Score >= winScore or p2Score >= winScore then
		print("Won")
		gameRunning = false
		
		local status = objects.StatusPanel:GetChildren()[1]
		objects.StatusPanel:SetVisible( true )
		
		if IsValid(status) then
			timer.Destroy( "gPong_StartDelay" ) 
			
			if p1Score >= winScore then
				status:SetText("P1 wins!")
			else
				status:SetText("P2 wins!")
			end
			
			timer.Simple(5, function()
				objects.ScoreP1:SetText( "0" )
				objects.ScoreP2:SetText( "0" )
				resetBall()
			end)
		end
	end
end

local predictedHitPos = {}
local function trackBallMovement( ball, hitX, hitY, hitCount ) -- Predict where the ball will be for bots
	local screen = gPhone.phoneScreen
	
	local ang = 45/360 -- This angle will never change with the current velocity
	local x, y = ball:GetPos()
	local startX = hitX or x
	local startY = hitY or y
	
	-- Determine the sign of the velocity values
	local signX = 1
	if ball.VelocityX < 0 then
		signX = -1
	end
	local signY = 1
	if ball.VelocityY < 0 then
		signY = -1
	end
	
	-- Predict the end points
	local endX = hitX + (ang * signX * 10000)
	local endY = hitY + (ang * signY * 10000)
	
	-- Clamp the end points
	--endX = math.Clamp( endX, 10, screen:GetWide() - 10)
	--endY = math.Clamp( endY, 10, screen:GetTall() - 10)
	
	-- Store value for the bot
	predictedHitPos = {x=endX, y=endY} 
end

local function movePaddle( paddle, yPos, bAddToY ) -- Move the paddle
	if not IsValid( paddle ) or gamePaused then return end
	
	local x, y = paddle:GetPos()
	local screenTop, screenBottom = 10, gPhone.phoneScreen:GetTall()-10-gApp["_children_"].PaddleP1:GetTall()
	local delta = 200 * RealFrameTime()
	local moveDistance = playerSpeed
	
	if bAddToY then 
		paddle:SetPos( x, math.Clamp(Lerp( delta, y, y + yPos ), screenTop, screenBottom) )
	else
		paddle:SetPos( x, math.Clamp(Lerp( delta, y, yPos ), screenTop, screenBottom) )
	end
end

local function movePaddleBot( yPos, onFinished ) -- Bots need a special move function
	if gamePaused then return end
	
	local objects = gApp["_children_"]
	local screen = gPhone.phoneScreen
	
	local screenTop, screenBottom = 10, gPhone.phoneScreen:GetTall()-10-objects.PaddleP2:GetTall()
	local delta = 200 * RealFrameTime()
	local moveDistance = botSpeed
	
	yPos = math.Clamp( yPos, screenTop, screenBottom )
	local x, y = objects.PaddleP2:GetPos()
	
	if y != yPos then 
		objects.PaddleP2:SetPos( x, Lerp( delta, y, yPos ) )
	elseif IsValid(onFinished) then
		onFinished() 
	end
end

local hitX, hitY, hitCount = nil, nil, 0
local function moveBall( bHit, hitPaddle, plyNum ) -- Move the ball 
	local screen = gPhone.phoneScreen
	local ball = gApp["_children_"].Ball
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

	-- Tell the ball to move
	if not bHit then -- It has not hit anything
		if ball.VelocityX == 0 then -- No velocity, create some
			hitCount = hitCount + 1
			hitX, hitY = ball:GetPos()
			
			local dir = math.random(2)
			if dir == 1 then
				ball.VelocityX = ballSpeed
			else
				ball.VelocityX = -ballSpeed
			end
		end
		if ball.VelocityY == 0 then	
			hitCount = hitCount + 1
			hitX, hitY = ball:GetPos()
			
			local dir = math.random(2)
			if dir == 1 then
				ball.VelocityY = -ballSpeed
			else
				ball.VelocityY = ballSpeed
			end
		end
	else -- It has hit a paddle
		local x, y = hitPaddle:GetPos()
		
		hitCount = hitCount + 1
		hitX, hitY = ball:GetPos()
		
		if plyNum == PONG_PLAYER1 then -- Player 1's paddle hit the ball
			if ballY <= y + hitPaddle:GetTall()/2 then -- Ball hit lower half of the paddle
				ball.VelocityX = ballSpeed
				ball.VelocityY = -ballSpeed
			else
				ball.VelocityX = ballSpeed
				ball.VelocityY = ballSpeed
			end
		else
			if ballY <= y + hitPaddle:GetTall()/2 then
				ball.VelocityX = -ballSpeed
				ball.VelocityY = -ballSpeed
			else
				ball.VelocityX = -ballSpeed
				ball.VelocityY = ballSpeed
			end
		end
	end
	
	-- Track which side the ball is on
	if ballX < screen:GetWide()/2 then
		ballSide = PONG_BALLSIDE_LEFT
	else
		ballSide = PONG_BALLSIDE_RIGHT
	end
	
	trackBallMovement( ball, hitX, hitY, hitCount )
	
	-- Now actually move the ball across the screen
	--local newX = Lerp(2, ballX, endX)
	--local newY = Lerp(2, ballY, endY)
	local newX = ballX + ball.VelocityX
	local newY = ballY + ball.VelocityY
	newX = math.Clamp( newX, 10, screen:GetWide() - ball:GetWide() - 10) -- Clamp within the playing area
	newY = math.Clamp( newY, 10, screen:GetTall() - ball:GetTall() - 10)
	
	ball:SetPos( newX, newY )
end

local function checkCollision( obj, plyNum ) -- Check collisions between objects
	local paddle = objectBounds[obj] -- Paddle
	local ball = objectBounds[gApp["_children_"].Ball] -- Ball
	
	if paddle and ball then
		if plyNum == PONG_PLAYER1 then -- Player 1
			if paddle.x + paddle.width >= ball.x then
				if paddle.y <= ball.y and paddle.y + paddle.height >= ball.y then 
					moveBall( true, gApp["_children_"].PaddleP1, 1 )
				elseif paddle.x >= ball.x then
					scorePoint( PONG_PLAYER2 )
				end
			end
		else -- Player 2
			if paddle.x - paddle.width <= ball.x then
				if paddle.y <= ball.y and paddle.y + paddle.height >= ball.y then
					moveBall( true, gApp["_children_"].PaddleP2, 2 )
				elseif paddle.x <= ball.x then
					scorePoint( PONG_PLAYER1 )
				end
			end
		end
	end
end

local function handleBot() -- Create an opponent for a Player v Bot game
	-- Add: Difficulty
	local objects = gApp["_children_"]
	local ball = gApp["_children_"].Ball
	local paddle = objects.PaddleP2
	local x, y = paddle:GetPos()
	
	if ballSide == PONG_BALLSIDE_CENTER or not gameRunning then -- Do nothing
		movePaddleBot( paddleStartY )
	elseif ballSide == PONG_BALLSIDE_RIGHT then -- Get ready to whack it!
		--local x = predictedHitPos.x
		--local y = predictedHitPos.y		
		local x, y = ball:GetPos()
		if ball.VelocityX > 0 then -- It coming to our side
			movePaddleBot( y )
		else
			movePaddleBot( paddleStartY )
		end
		
	else -- Its not on our side yet
		movePaddleBot( paddleStartY )
	end
end

function grabGamePositions()
	local objects = gApp["_children_"]
	local posTable = {}
	
	local p1X, p1Y = objects.PaddleP1:GetPos()
	--local p2X, p2Y = objects.PaddleP2:GetPos()
	local bX, bY = objects.Ball:GetPos()
	
	posTable.paddle1 = {y=p1Y}
	--posTable.paddle2 = {y=p2Y}
	posTable.ball = {x=bX, y=bY, veloX=objects.Ball.VelocityX, veloY=objects.Ball.VelocityY}

	return posTable
end

function updateGamePositions( tab )
	if tab.ball then -- Our values exist
		local objects = gApp["_children_"]
		local screen = gPhone.phoneScreen
		local ball = gApp["_children_"].Ball
		
		-- These are our opponent's positions, so everything is from their point of view
		local opponentPaddle = objects.PaddleP1
		local opponentY = tab.paddle1.y
		
		movePaddle( opponentPaddle, opponentY, false )
		
		-- The ball's X variable might need to be altered because of multiplayer POV
		local ballX, ballY = tab.ball.x, tab.ball.y
		local newX = ballX + ball.VelocityX
		local newY = ballY + ball.VelocityY
		newX = math.Clamp( newX, 10, screen:GetWide() - ball:GetWide() - 10)
		newY = math.Clamp( newY, 10, screen:GetTall() - ball:GetTall() - 10)
	
		ball:SetPos( newX, newY )
	end
end


--// We basically run the game in the application's Think function
function APP.Think()
	local objects = gApp["_children_"]
	local screen = gPhone.phoneScreen
	
	if isInGame then
		-- Manage the client's Paddle
		if input.IsKeyDown( KEY_S ) then
			movePaddle( objects.PaddleP1, playerSpeed, true )
		elseif input.IsKeyDown( KEY_W )  then
			movePaddle( objects.PaddleP1, -playerSpeed, true )
		end
		
		if input.IsKeyDown( KEY_ENTER ) then
			APP.PauseGame()
		end
		
		-- If its a self game, allow another user to play
		if gameType == PONG_GAME_SELF then 
			if input.IsKeyDown( KEY_DOWN ) then
				movePaddle( objects.PaddleP2, playerSpeed, true )
			elseif input.IsKeyDown( KEY_UP )  then
				movePaddle( objects.PaddleP2, -playerSpeed, true )
			end
		elseif gameType == PONG_GAME_MP then
			gPhone.updateToNetStream( grabGamePositions() ) -- Sends our positions to the server
			
			updateGamePositions( gPhone.updateFromNetStream() ) -- Updates our positions from the server
		end
		
		-- This block of code runs the entire game
		if gameRunning then
			-- Move the ball
			moveBall() 
			
			-- Update boundaries/hitboxes
			setBounds( objects.PaddleP1 )
			setBounds( objects.PaddleP2 )
			setBounds( objects.Ball )
			
			-- Check paddle/ball collisions
			checkCollision( objects.PaddleP1, 1 )
			checkCollision( objects.PaddleP2, 2 )
			
			checkWin()
			
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

gPhone.addApp(APP)