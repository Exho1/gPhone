
local function openTracker()
	local frame = vgui.Create( "DFrame" )
	frame:SetPos( 100, 100 )
	frame:SetSize( 300, 200 )
	frame:SetTitle( "Net Tracker" )
	frame:SetDraggable( true )
	frame:MakePopup()
	
	local netList = vgui.Create( "DListView" )
	netList:SetMultiSelect( tue )
	netList:AddColumn( "Message" )
	netList:AddColumn( "In" )
	netList:AddColumn( "Out" )

	--netList:AddLine( "PesterChum", "2mb" )	
end

concommand.Add("net_tracker", function()
	openTracker()
end)

--[[
local oldIncoming = net.Incoming

function net.Incoming( len, client )
	local i = net.ReadHeader()
	local strName = util.NetworkIDToString( i )
	
	MsgC( color_white, "Started ", Color(52, 152, 219), "incoming", color_white, "net message",
	Color(46, 204, 113), '"'..strName...'"')
	oldIncoming( len, client )
	strName
end
]]


