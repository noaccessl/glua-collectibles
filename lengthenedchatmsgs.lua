--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––

	Lengthened Chat Messages
	 Increases the maximum message length in the default chat.

	 Steam Workshop: https://steamcommunity.com/sharedfiles/filedetails/?id=3395774840
	 GitHub: https://github.com/noaccessl/glua-collectibles/lengthenedchatmsgs.lua

–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]



--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	The server-side part
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
if ( SERVER ) then

	util.AddNetworkString( 'lengthened_chat_messages' )

	local sv_maxchatmsglength = CreateConVar(

		'sv_maxchatmsglength', '1536',
		FCVAR_ARCHIVE + FCVAR_NEVER_AS_STRING + FCVAR_REPLICATED,
		'The maximum chat\'s message length.',
		96, 4095

	)

	local g_recipfilterMessage = RecipientFilter()

	net.Receive( 'lengthened_chat_messages', function( _, pPlayer )

		local text = net.ReadString()
		local bTeamChat = net.ReadBool()

		if ( text == '' ) then
			return
		end

		local iMaxLength = sv_maxchatmsglength:GetInt()

		if ( utf8.len( text ) > iMaxLength ) then
			text = utf8.sub( text, 1, iMaxLength )
		end

		--
		-- Compatibility with other addons/scripts
		--
		local ret = hook.Run( 'PlayerSay', pPlayer, text, bTeamChat )

		if ( ret == '' ) then
			return
		end

		if ( isstring( ret ) ) then
			text = ret
		end

		--
		-- Filter
		--
		g_recipfilterMessage:RemoveAllPlayers()
		g_recipfilterMessage:AddPlayer( pPlayer )

		for _, pRecipient in ipairs( player.GetHumans() ) do

			if ( pRecipient == pPlayer ) then
				continue
			end

			if ( hook.Run( 'PlayerCanSeePlayersChat', text, bTeamChat, pRecipient, pPlayer ) ) then
				g_recipfilterMessage:AddPlayer( pRecipient )
			end

		end

		--
		-- Deliver
		--
		net.Start( 'lengthened_chat_messages' )
			net.WritePlayer( pPlayer )
			net.WriteString( text )
			net.WriteBool( bTeamChat )
		net.Send( g_recipfilterMessage )

	end )

end



--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	The client-side part
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
if ( CLIENT ) then

	local g_bTeamChat = false
	local g_strChatText = ''
	local g_bValidatedInput = false
	local g_pnlChatInput = NULL

	--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
		Purpose: Detour the closure of the chat & override behavior.

		Note:
			HUDShouldDraw is the only hook that can catch it antecedently.
	–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
	local VGUIGetKeyboardFocus = vgui.GetKeyboardFocus
	local InputIsKeyDown = input.IsKeyDown
	local KEY_ENTER = KEY_ENTER

	hook.Add( 'HUDShouldDraw', 'LengthenedChatMessages', function()

		if ( not g_bValidatedInput ) then
			return
		end

		if ( g_strChatText ~= '' and VGUIGetKeyboardFocus() == g_pnlChatInput and InputIsKeyDown( KEY_ENTER ) ) then

			--
			-- Transfer the message to the server
			--
			net.Start( 'lengthened_chat_messages' )
				net.WriteString( g_strChatText )
				net.WriteBool( g_bTeamChat )
			net.SendToServer()

			--
			-- Close the chat
			--
			chat.Close()
			g_pnlChatInput:KillFocus()
			g_strChatText = ''

		end

	end )

	--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
		Purpose:
			— Detour the chat's input field
			— Extend the limits
			— Store the current text
	–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
	hook.Add( 'ChatTextChanged', 'LengthenedChatMessages', function( text )

		local pnlFocus = VGUIGetKeyboardFocus()

		if ( not IsValid( pnlFocus ) ) then
			return
		end

		if ( pnlFocus:GetName() ~= 'ChatInput' or pnlFocus:GetClassName() ~= 'TextEntry' ) then
			return
		end

		if ( not g_bValidatedInput ) then

			g_pnlChatInput = pnlFocus
			g_bValidatedInput = true

		end

		local iMaxMessageLength = GetConVar( 'sv_maxchatmsglength' ):GetInt()

		if ( g_pnlChatInput:GetMaximumCharCount() ~= iMaxMessageLength ) then

			g_pnlChatInput:SetMaximumCharCount( iMaxMessageLength )
			g_pnlChatInput:SetAllowNonAsciiCharacters( true )

		end

		g_strChatText = g_pnlChatInput:GetText()

	end )

	--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
		Purpose: Store the boolean whether the local player is chatting with the team
	–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
	hook.Add( 'StartChat', 'LengthenedChatMessages', function( bTeamChat ) g_bTeamChat = bTeamChat end )

	--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
		Purpose: Receive messages
	–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
	net.Receive( 'lengthened_chat_messages', function()

		local pPlayer = net.ReadPlayer()
		local text = net.ReadString()
		local bTeamChat = net.ReadBool()

		hook.Run( 'OnPlayerChat', pPlayer, text, bTeamChat, not pPlayer:Alive() )

	end )

end
