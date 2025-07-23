
--[[

	Note:
		The script is a bit old and can be fine-tuned.
		At the moment, this is for your insight of the concept;
		and not meaning you can't use it.

]]


--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Prepare
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
--
-- Metamethods: Entity, ConVar
--
local GetClass = FindMetaTable( 'Entity' ).GetClass
local GetTable = FindMetaTable( 'Entity' ).GetTable

local CVarGetFloat = FindMetaTable( 'ConVar' ).GetFloat

--
-- Globals
--
local GetCurTime = CurTime


--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Purpose: Adds delay to using doors
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
local DOOR_CLASS = {

	func_door = true;
	func_door_rotating = true;
	prop_door_rotating = true;
	func_movelinear = true

}

local sv_doorusedelay = CreateConVar( 'sv_doorusedelay', '0.5', FCVAR_ARCHIVE + FCVAR_UNLOGGED, '', 0, 2 )

hook.Add( 'PlayerUse', 'AntiDoorSpam', function( pl, pEntity )

	if DOOR_CLASS[ GetClass( pEntity ) ] then

		local pDoor = pEntity
		local pDoor_t = GetTable( pDoor )

		if ( ( pDoor_t.m_flNextUse or 0 ) > GetCurTime() ) then
			return false
		end

		pDoor_t.m_flNextUse = GetCurTime() + CVarGetFloat( sv_doorusedelay )

		return true

	end

end )
