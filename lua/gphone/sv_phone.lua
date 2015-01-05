----// Serverside Phone //----

--// Resourcing and app adding
resource.AddFile( "materials/vgui/gphone/gPhone.png" )
resource.AddFile( "resource/fonts/roboto_light.tff" )
resource.AddFile( "sound/gphone/vibrate.wav" )

local files = file.Find( "materials/vgui/gphone/*.png", "GAME" ) -- Phone images
for k, v in pairs(files) do
	resource.AddFile("materials/vgui/gphone/"..v)
end
files = file.Find( "materials/vgui/gphone/wallpapers/*.png", "GAME" ) -- Wallpapers
for k, v in pairs(files) do
	resource.AddFile("materials/vgui/gphone/wallpapers/"..v)
end
files = file.Find( "materials/vgui/gphone/apps/*.png", "GAME" ) -- App images
for k, v in pairs(files) do
	resource.AddFile("materials/vgui/gphone/apps/"..v)
end

files = file.Find( "gphone/apps/*.lua", "LUA" ) -- Apps
for k, v in pairs(files) do
	AddCSLuaFile("apps/"..v)
end

--// Player functions
local plymeta = FindMetaTable( "Player" )


--// Receives data from applications and runs it on the server
net.Receive( "gPhone_DataTransfer", function( len, ply )
	local data = net.ReadTable()
	local header = data.header
	
	if header == GPHONE_MONEY_TRANSFER then -- Money transaction
		local amount = tonumber(data.amount)
		local target = data.target
		local plyWallet = tonumber(ply:getDarkRPVar("money"))
		
		-- Cooldowns to prevent spam
		if ply:GetTransferCooldown() > 0 then
			gPhone.ChatMsg( ply, "You must wait "..math.Round(ply:GetTransferCooldown()).."s before sending more money" )
			return
		end
		
		-- If the player disconnected or they are sending money to themselves, stop the transaction
		if not IsValid(target) or target == ply then
			gPhone.ChatMsg( ply, "Unable to complete transaction - invalid recipient" )
			return
		end
		
		-- If a negative or string amount got through, stop it
		if amount < 0 or amount == nil then 
			gPhone.FlagPlayer( ply, GPHONE_F_FINANCES )
			gPhone.ChatMsg( ply, "Unable to complete transaction - nil amount" )
			return
		else
			-- Force the amount to be positive. If a negative value is passed then the 'exploiter' will still transfer the cash
			amount = math.abs(amount) 
		end
		
		-- Make sure the player has this money and didn't cheat it on the client
		if plyWallet > amount then 	
			-- Last measure before allowing the deal, call the hook
			local shouldTransfer, denyReason = hook.Run( "gPhone_ShouldAllowTransaction", ply, target, amount )
			if shouldTransfer == false then
				if denyReason != nil then
					gPhone.ChatMsg( ply, denyReason )
				else
					gPhone.ChatMsg( ply, "Unable to complete transaction, sorry" )
				end
				return
			end
			
			-- Complete the transaction
			target:addMoney(amount)
			ply:addMoney(-amount)
			gPhone.ChatMsg( target, "Received $"..amount.." from "..ply:Nick().."!" )
			gPhone.ChatMsg( ply, "Wired $"..amount.." to "..target:Nick().." successfully!" )
			gPhone.ConfirmTransaction( ply, {target=target:Nick(), amount=amount, time=os.date( "%x - %I:%M%p")} )
			
			ply:SetTransferCooldown( 5 )
		else	
			gPhone.FlagPlayer( ply, GPHONE_F_FINANCES )
			gPhone.MsgC( GPHONE_MSGC_WARNING, ply:Nick().." attempted to force a transaction with more money than they had!" )
			gPhone.ChatMsg( ply, "Unable to complete transaction - lack of funds" )
			return
		end
	elseif header == GPHONE_STATE_CHANGED then -- The phone has been opened or closed
		local phoneOpen = data.open
		
		if phoneOpen == true then
			ply:SetNWBool("gPhone_Open", true)
			hook.Run( "gPhone_Built", ply )
		else
			ply:SetNWBool("gPhone_Open", false)
		end
	elseif header == GPHONE_CUR_APP then
		ply:SetNWString("gPhone_CurApp", data.app)
	elseif header == GPHONE_F_EXISTS then
		local cache = data.data

		local length = string.len(cache[1].body) / 3
		gPhone.AdminMsg( ply:Nick().." ("..ply:SteamID()..") has "..#cache.." attempts at exploiting the gPhone recorded!" )
		-- Perhaps add an app to keep track of these
	end
end)

hook.Add("PlayerInitialSpawn", "gPhone_GenerateNumber", function( ply )
	ply:GeneratePhoneNumber()

	net.Start("gPhone_DataTransfer")
		net.WriteTable( {header=GPHONE_BUILD} )
	net.Send( ply )
end)



