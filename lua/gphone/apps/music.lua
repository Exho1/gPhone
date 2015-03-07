local APP = {}
local trans = gPhone.getTranslation

APP.PrintName = "Music"
APP.Icon = "vgui/gphone/music.png"
APP.Author = "Exho"
APP.Tags = {"Sound", "Jamz", "Tunes"}

function APP.Run( objects, screen )
	gPhone.darkenStatusBar()
	
	-- App specific variables
	APP.OnMusicPlayer = false
	APP.PlayingData = APP.PlayingData or {} -- Persists
	APP.Volume = 1
	
	objects.Title = vgui.Create( "DLabel", screen )
	objects.Title:SetText( trans("music") )
	objects.Title:SetTextColor( color_black )
	objects.Title:SetFont("gPhone_18Lite")
	objects.Title:SizeToContents()
	objects.Title:SetPos( screen:GetWide()/2 - objects.Title:GetWide()/2, 25 )
	
	objects.Back = vgui.Create("gPhoneBackButton", screen)
	objects.Back:SetTextColor( gPhone.colors.blue )
	objects.Back:SetPos( 10, 25 )
	objects.Back:SetVisible( false )
	
	local offset = 20 -- A little trick to push the scrollbar off the screen
	objects.LayoutScroll = vgui.Create( "DScrollPanel", screen )
	objects.LayoutScroll:SetSize( screen:GetWide() + offset, screen:GetTall() - 50 )
	objects.LayoutScroll:SetPos( 0, 50 )
	objects.LayoutScroll.Paint = function( self, w, h )
		draw.RoundedBox(0, 0, self:GetWide(), self:GetTall(), 0, Color(0, 235, 0))
	end
	
	objects.Layout = vgui.Create( "DIconLayout", objects.LayoutScroll )
	objects.Layout:SetSize( screen:GetWide(), screen:GetTall() - 1 )
	objects.Layout:SetPos( 0, 1 )
	objects.Layout:SetSpaceY( 0 )
	
	objects.AddSong = vgui.Create("DImageButton", screen)
	objects.AddSong:SetSize( 18, 18 )
	local x, y = objects.Title:GetPos()
	objects.AddSong:SetPos( screen:GetWide() - objects.AddSong:GetWide() - 10, y)
	objects.AddSong:SetColor( gPhone.colors.blue )
	objects.AddSong:SetImage("vgui/gphone/add.png")
	objects.AddSong.DoClick = function( self )
		self:SetVisible(false)
		APP.OpenEditor()
	end
	
	-- Load the music list and merge it into the existing one or a new table
	APP.MusicList = table.Merge(APP.MusicList or {}, gPhone.loadMusic())
	
	--[[local temp = {
		artistName="Submersed",
		songName="Hollow",
		albumUrl = "https://i.scdn.co/image/2d3c7477f70eead0daa791ca6b7e9542e0d80790",
		songUrl = "http://a.tumblr.com/tumblr_lng7dwiPUp1qd3ziuo1.mp3",
	}
	table.insert(APP.MusicList, temp)
	
	local temp = {
		artistName="Chevelle",
		songName="I Get It",
		albumUrl = "https://i.scdn.co/image/282d3c11fbfa67653fb64557ce779c859f545e38",
		songUrl = "http://supercloun.ru/ultra/chevelle_-_i_get_it.mp3",
	}
	table.insert(APP.MusicList, temp)]]
	
	for k, data in pairs( APP.MusicList ) do
		local bgPanel = objects.Layout:Add("DPanel")
		bgPanel:SetSize(screen:GetWide(), 30)
		bgPanel.Paint = function() end
		
		local layoutButton = vgui.Create("DButton", bgPanel)
		layoutButton:SetSize(screen:GetWide(), 30)
		layoutButton:SetText("")
		layoutButton:SetZPos(5)
		layoutButton.Paint = function()
			if not layoutButton:IsDown() then
				draw.RoundedBox(0, 0, 0, layoutButton:GetWide(), layoutButton:GetTall(), gPhone.colors.whiteBG)
			else
				draw.RoundedBox(0, 0, 0, layoutButton:GetWide(), layoutButton:GetTall(), gPhone.colors.darkWhiteBG)
			end
			
			draw.RoundedBox(0, 30, layoutButton:GetTall()-1, layoutButton:GetWide()-30, 1, gPhone.colors.greyAccent)
		end
		
		-- Delete button shamelessly copied from the messages app
		local deleteOffset = 50
		local deleteConvo = vgui.Create( "DButton", bgPanel )
		deleteConvo:SetSize(deleteOffset, layoutButton:GetTall())
		deleteConvo:SetPos(layoutButton:GetWide()-deleteOffset,0)
		deleteConvo:SetText( trans("delete") )
		deleteConvo:SetFont("gPhone_18lite")
		deleteConvo:SetColor( color_white )
		deleteConvo:SetZPos(-5)
		deleteConvo:SetVisible(false)
		deleteConvo.Paint = function( self, w, h )
			draw.RoundedBox(0, 0, 0, w, h, gPhone.colors.red)
		end
		deleteConvo.DoClick = function( self )
			-- Removes the song from the users list
			bgPanel:Remove()
			
			table.remove(APP.MusicList, k)
			gPhone.saveMusic( APP.MusicList )
			
			objects.Layout:LayoutIcons_TOP()
		end
		
		layoutButton.OnMousePressed = function( self, mCode )
			local x, y = self:ScreenToLocal( gui.MouseX(), gui.MouseY() )
			
			if mCode != MOUSE_RIGHT then
				if x >= self:GetWide() - (deleteOffset - 10) and not self.deleteMode  then
					local bX, bY = self:GetPos()
					self:MoveTo( bX - deleteOffset, bY, 0.5, 0, -1 )
					self.deleteMode = true
					deleteConvo:SetVisible(true)
					return
				elseif self.deleteMode then
					local bX, bY = self:GetPos()
					self:MoveTo( bX + deleteOffset, bY, 0.5, 0, -1, function() deleteConvo:SetVisible(false) end)
					self.deleteMode = false
					return
				end

				APP.OpenPlayer(data)
			else
				APP.OpenEditor(data)
			end
		end
		
		local title = vgui.Create( "DLabel", layoutButton )
		title:SetText( string.format("%s - %s", data.artistName or "N/A", data.songName or "N/A") )
		title:SetTextColor(Color(0,0,0))
		title:SetFont("gPhone_18")
		title:SizeToContents()
		title:SetPos( 35, 5 )
	end
	
	--gPhone.saveMusic( APP.MusicList )
end

--// Helper function
function APP.StopChannel()
	if IsValid(APP.MusicChannel) then
		APP.MusicChannel:Stop()
		hook.Run("IGModAudioStop", channel)
	end
end	

function APP.OpenPlayer( data )
	--[[ Format:
		data.artist_name, data.song_name, data.album_url, data.song_url
	]]
	
	local screen = gPhone.phoneScreen
	local objects = gApp["_children_"]
	
	gPhone.setTextAndCenter(objects.Title, "", screen)
	gPhone.hideChildren( objects.Layout )
	
	APP.OnMusicPlayer = true
	
	objects.Back:SetVisible(true)
	objects.Back.DoClick = function()
		for k, v in pairs(objects) do
			if IsValid(v) then
				v:Remove()
			end
		end
		
		hook.Remove("Think", "gPhone_musicProgress")
		
		APP.Run( objects, screen )
	end
	
	-- If the song we clicked on differs than the one playing, stop the playing song
	if APP.MusicChannel != nil then
		if APP.PlayingData != data then
			APP.StopChannel()
		end
	end
	
	local albumCover = vgui.Create( "HTML", objects.LayoutScroll) 
	local w, h = screen:GetWide(), screen:GetTall()/4 * 2.5
	albumCover:SetSize( w, h )
	albumCover:SetPos( 0, 5 )
	if data.albumUrl and data.albumUrl != "" then
		albumCover:SetHTML( "<img width='".. w-20 .."px' height='".. h-20 .."px' src='"..data.albumUrl.."'>" )
	else
		gPhone.msgC( GPHONE_MSGC_NOTIFY, "Manually loading album art")
		
		local artist = data.artistName or ""
		local song = data.songName or ""
		
		-- Using the spotify API, find an album cover for the song
		gPhone.loadAlbumArt(artist.." "..song, 1, function( url )
			data.albumUrl = url -- Set this to the album's URL for quick loading later
			gPhone.saveMusic( APP.MusicList )
			
			albumCover:SetHTML( "<img width='".. w-20 .."px' height='".. h-20 .."px' src='"..url.."'>" )
		end)	
	end
	
	local controlPanel = vgui.Create("DPanel", objects.LayoutScroll)
	controlPanel:SetSize( screen:GetWide(), screen:GetTall()/4 )
	controlPanel:SetPos( 0, screen:GetTall() - controlPanel:GetTall() - 50 )
	controlPanel.Paint = function() end

	local timeElapsed = vgui.Create( "DLabel", controlPanel )
	timeElapsed:SetText( "00:00" )
	timeElapsed:SetFont("gPhone_12")
	timeElapsed:SetColor(color_black)
	timeElapsed:SizeToContents()
	timeElapsed:SetPos( 7, 3 )
	
	local timeLeft = vgui.Create( "DLabel", controlPanel )
	timeLeft:SetText( "00:00" )
	timeLeft:SetFont("gPhone_12")
	timeLeft:SetColor(color_black)
	timeLeft:SizeToContents()
	timeLeft:SetPos( screen:GetWide() - timeLeft:GetWide() - 7, 3 )
	
	local songProgress = vgui.Create( "DPanel", controlPanel )
	songProgress:SetSize( screen:GetWide() - 90, 7 )
	songProgress:SetPos( screen:GetWide()/2 - songProgress:GetWide()/2, 5 )
	songProgress.progress = 0
	songProgress.Paint = function( self, w, h )
		draw.RoundedBox(0, 0, 0, w, h, gPhone.colors.greyAccent)
		draw.RoundedBox(0, 0, 0, w * self.progress, h, gPhone.colors.blue)
	end
	
	local songName = vgui.Create( "DLabel", controlPanel )
	songName:SetText(string.format("%s - %s", data.artistName or "N/A", data.songName or "N/A"))
	songName:SetFont("gPhone_18")
	songName:SetColor(color_black)
	songName:SizeToContents()
	local _, y = songProgress:GetPos()
	songName:SetPos( screen:GetWide()/2 - songName:GetWide()/2, y + 15 )
	
	local play = vgui.Create("DImageButton", controlPanel)
	play:SetSize( 24, 24 )
	play:SetPos( screen:GetWide()/2 - play:GetWide()/2, y + 50 )
	play:SetImage("vgui/gphone/play.png")
	if IsValid(APP.MusicChannel) then
		play.isPlaying = true
	else
		play.isPlaying = false
	end
	play.Think = function( self )
		if play.isPlaying == false then
			play:SetImage("vgui/gphone/play.png")
		else
			play:SetImage("vgui/gphone/pause.png")
		end	
	end
	
	local x, y = play:GetPos()
	
	local back = vgui.Create("DImageButton", controlPanel)
	back:SetSize( 24, 24 )
	back:SetPos( x - back:GetWide() - 50, y )
	back:SetImage("vgui/gphone/rewind.png")
	back.DoClick = function( self )
		if songProgress.progress > 0 then
			-- Restart the song
			timeElapsed:SetText( "00:00" )
			timeLeft:SetText( "00:00" )
			
			if IsValid(APP.MusicChannel) then
				-- Dont run the hook in this one as it gets restarted
				APP.MusicChannel:Stop()
				APP.MusicChannel:Play()
			end
			songProgress.progress = 0
		else
			-- Go back one song
			for key, tbl in pairs( APP.MusicList ) do
				if data == tbl then
					-- Remove old panels
					controlPanel:Remove()
					albumCover:Remove()
					
					-- Stop music
					if IsValid(APP.MusicChannel) then	
						APP.StopChannel()
					end
					
					-- Build a new player for the previous song
					if APP.MusicList[key-1] != nil then
						APP.OpenPlayer( APP.MusicList[key-1] )
					else
						APP.OpenPlayer( APP.MusicList[#APP.MusicList] )
					end
				end
			end
		end
	end
	
	local forward = vgui.Create("DImageButton", controlPanel)
	forward:SetSize( 24, 24 )
	forward:SetPos( x + forward:GetWide() + 50, y )
	forward:SetImage("vgui/gphone/f_forward.png")
	forward.DoClick = function( self )
		-- Jump forward a song
		for key, tbl in pairs( APP.MusicList ) do
			if data == tbl then
				controlPanel:Remove()
				albumCover:Remove()
				if IsValid(APP.MusicChannel) then
					APP.StopChannel()
				end
				if APP.MusicList[key+1] != nil then
					APP.OpenPlayer( APP.MusicList[key+1] )
				else
					APP.OpenPlayer( APP.MusicList[1] )
				end
			end
		end
	end
	
	local volume = vgui.Create("gPhoneSlider", controlPanel)
	volume:SetWide( screen:GetWide() - 40 )
	volume:SetPos( screen:GetWide()/2 - volume:GetWide()/2, controlPanel:GetTall() - 20 ) 
	volume:SetMin( 0 )
	volume:SetMax( 1 )
	volume:SetBackgroundColor( gPhone.colors.greyAccent )
	volume:SetForegroundColor( gPhone.colors.grey )
	volume:SetKnobColor( Color(190, 190, 190) )
	volume:SetValue( APP.Volume )
	volume.OnValueChanged = function( self, val )
		-- Update the apps volume
		APP.Volume = val
	end
	
	play.DoClick = function( self )
		-- If music is playing, pause/play
		if IsValid(APP.MusicChannel) then
			if play.isPlaying == false then
				APP.MusicChannel:Play()
			else
				APP.MusicChannel:Pause()
			end
			self.isPlaying = !self.isPlaying
			return
		end
		
		self.isPlaying = !self.isPlaying
		
		-- Create a new music channel
		sound.PlayURL( data.songUrl, "", function( channel, errorID, errorName )
			APP.PlayingData = data
			
			concommand.Add("gphone_stopmusic", function()
				if IsValid(channel) then
					APP.StopChannel()
				end
			end)
			
			-- Hook onto my event that gets called whenever the audio channel stops
			hook.Add("IGModAudioStop", "gPhone_audioStop", function()
				gPhone.msgC( GPHONE_MSGC_NONE, "Audio channel stopped")
				APP.PlayingData = {}
				APP.MusicChannel = nil
			end)
			
			if not IsValid(channel) then
				-- Alert the player that they used an invalid url
				gPhone.notifyAlert( {msg=trans("music_format_warn"),
				title=trans("music"), options={trans("okay")}}, nil, nil, true, true)
				return
			end
			
			APP.MusicChannel = channel
			if IsValid(volume) then
				channel:SetVolume( volume:GetValue() )
			end
			APP.ProgressBar( play, songProgress, timeElapsed, timeLeft, volume )
		end)
	end
	
	APP.ProgressBar( play, songProgress, timeElapsed, timeLeft, volume )
end

--// Handles the progress bar for songs
function APP.ProgressBar( dPlay, dProgress, dElapsed, dLeft, dVolume )
	hook.Add("Think", "gPhone_musicProgress", function()
		if IsValid(APP.MusicChannel) then
			local channel = APP.MusicChannel
			if not APP.OnMusicPlayer then
				return
			end
			
			local curTime = channel:GetTime() or 0 
			local length = channel:GetLength() or 0
	
			-- Update the progress bar
			dProgress.progress = curTime / length
			
			dElapsed:SetText( gPhone.simpleTime(curTime, "%02i:%02i") )
			dLeft:SetText( gPhone.simpleTime(length - curTime, "%02i:%02i"))
			
			-- Volume stuff (luckily volume is from 0-1 already)
			dVolume:SetValue( channel:GetVolume() )
			dVolume.OnValueChanged = function( self, value )
				if IsValid(channel) then
					channel:SetVolume( value )
				end
			end
			
			-- Pause music if we tab out
			if not system.HasFocus() then
				channel:Pause()
				dPlay.isPlaying = false
			end
		end
	end)
end

function APP.OpenEditor( data ) 
	local objects = gApp["_children_"]
	local screen = gPhone.phoneScreen
	
	local function setUpTab( name )
		local objects = gApp["_children_"]
		local screen = gPhone.phoneScreen
		gPhone.setTextAndCenter(objects.Title, name, screen)
		
		-- Hide the app's home screen
		for k, v in pairs(objects.Layout:GetChildren()) do
			v:SetVisible(false)
		end
	end
	
	setUpTab( trans("editor") )
	
	-- Set up the back button
	objects.Back:SetVisible(true)
	objects.Back.DoClick = function()
		for k, v in pairs(objects) do
			if IsValid(v) then
				v:Remove()
			end
		end
		
		APP.Run( objects, screen )
	end
	
	local bgPanel = objects.Layout:Add("DPanel")
	bgPanel:SetSize(screen:GetWide(), screen:GetTall()/2)
	bgPanel.Paint = function( self, w, h )
		draw.RoundedBox(0, 0, 0, w, h, gPhone.colors.whiteBG)
	end
	
	local fields = {
		trans("artist_name"),
		trans("song_name"),
		trans("song_url"),
		trans("album_url"),
	}
	
	local fieldLabel = vgui.Create( "DLabel", bgPanel )
	fieldLabel:SetTextColor(Color(0,0,0))
	fieldLabel:SetFont("gPhone_16")
	fieldLabel:SetPos( 15, 20 )
	gPhone.setTextAndCenter( fieldLabel, trans("editor_help"), bgPanel )
	gPhone.wordWrap( fieldLabel, bgPanel:GetWide(), 20 ) -- Just in case
	
	local textEntries = {}
	
	local yBuffer = 0
	for k, text in pairs( fields ) do
		local fieldLabel = vgui.Create( "DLabel", bgPanel )
		fieldLabel:SetText( text )
		fieldLabel:SetTextColor(Color(0,0,0))
		fieldLabel:SetFont("gPhone_18")
		fieldLabel:SetSize( 100, 18 )
		fieldLabel:SetPos( 15, 60 + yBuffer )
		
		textEntries[k] = vgui.Create( "DTextEntry", bgPanel )
		local text = ""
		if data then
			-- If we gave a data table, fill in the blanks
			if k == 1 then
				text = data.artistName or ""
			elseif k == 2 then
				text = data.songName or ""
			elseif k == 3 then
				text = data.songUrl or ""
			elseif k == 4 then
				text = data.albumUrl or ""
			end
		end
		textEntries[k]:SetText( text )
		textEntries[k]:SetFont("gPhone_18")
		textEntries[k]:SetSize( 100, 20 )
		textEntries[k]:SetTextColor( color_black )
		textEntries[k]:SetDrawBorder( false )
		textEntries[k]:SetDrawBackground( false )
		textEntries[k]:SetCursorColor( color_black )
		textEntries[k]:SetHighlightColor( Color(27,161,226) )
		local x, y = fieldLabel:GetPos()
		textEntries[k]:SetPos( bgPanel:GetWide() - textEntries[k]:GetWide() - 15, y )
		textEntries[k].PaintOver = function( self, w, h )
			-- I like this look better than the default derma
			surface.SetDrawColor( color_black )
			surface.DrawOutlinedRect( 0, 0, w, h )
		end
		
		yBuffer = yBuffer + fieldLabel:GetTall() + 10
	end
	
	local fake = objects.Layout:Add("DPanel")
	fake:SetSize(screen:GetWide(), 30)
	fake.Paint = function() end
	
	local updateButton = objects.Layout:Add("DButton")
	updateButton:SetSize(screen:GetWide(), 30)
	updateButton:SetFont("gPhone_18")
	updateButton:SetTextColor( color_black )
	updateButton:SetText(trans("update"))
	updateButton.Paint = function( self, w, h )
		if not self:IsDown() then
			draw.RoundedBox(0, 0, 0, w, h, gPhone.colors.whiteBG)
		else
			draw.RoundedBox(0, 0, 0, w, h, gPhone.colors.darkWhiteBG)
		end
		
	end
	updateButton.DoClick = function( self )
		if data == nil then
			-- New song file
			local entry = {
				artistName=textEntries[1]:GetText(),
				songName=textEntries[2]:GetText(),
				songUrl = textEntries[3]:GetText(),
				albumUrl = textEntries[4]:GetText(),
			}
			table.insert(APP.MusicList, entry)
		else
			-- Editing a song file
			local entry = {
				artistName=textEntries[1]:GetText(),
				songName=textEntries[2]:GetText(),
				songUrl = textEntries[3]:GetText(),
				albumUrl = textEntries[4]:GetText(),
			}
			
			for key, tbl in pairs( APP.MusicList ) do
				if data == tbl then
					APP.MusicList[key] = entry
				end
			end
		end
		
		-- Gotta stop the music otherwise things break
		APP.StopChannel()
		
		-- Save changes and hop back to main menu
		gPhone.saveMusic( APP.MusicList )
		objects.Back:DoClick()
	end
end

function APP.Close()
	APP.OnMusicPlayer = false
	hook.Remove("Think", "gPhone_musicProgress")
end

function APP.Paint( screen )
	if APP.OnMusicPlayer then
		draw.RoundedBox(2, 0, 0, screen:GetWide(), screen:GetTall(), gPhone.colors.whiteBG)
	else
		draw.RoundedBox(2, 0, 0, screen:GetWide(), screen:GetTall(), gPhone.colors.darkerWhite)
		
		draw.RoundedBox(2, 0, 0, screen:GetWide(), 50, gPhone.colors.whiteBG)
		draw.RoundedBox(0, 0, 50, screen:GetWide(), 1, Color(20, 40, 40))
	end
end

gPhone.addApp(APP)