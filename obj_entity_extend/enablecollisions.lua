
--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Name: Entity:EnableCollisions
	Purpose: Sets whether the entity should collide with **anything** or not
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
do

	--
	-- Metatables
	--
	local Entity = FindMetaTable( 'Entity' )

	--
	-- Enums
	--
	local FVPHYSICS_NO_SELF_COLLISIONS = FVPHYSICS_NO_SELF_COLLISIONS

	local COLLISION_GROUP_NONE = COLLISION_GROUP_NONE
	local COLLISION_GROUP_WORLD = COLLISION_GROUP_WORLD

	function Entity:EnableCollisions( enable )

		local numObjects = Entity.GetPhysicsObjectCount( self )

		if ( numObjects == 0 ) then
			return
		end

		local i = 0

		::apply_to_each_physobj::
		i = i + 1

			local physobj = Entity.GetPhysicsObjectNum( self, i - 1 )

			if ( physobj:IsValid() ) then

				if ( enable ) then
					physobj:ClearGameFlag( FVPHYSICS_NO_SELF_COLLISIONS )
				else
					physobj:AddGameFlag( FVPHYSICS_NO_SELF_COLLISIONS )
				end

				physobj:EnableCollisions( enable )

			end

		if ( i ~= numObjects ) then goto apply_to_each_physobj end

		Entity.SetCollisionGroup( self, enable and COLLISION_GROUP_NONE or COLLISION_GROUP_WORLD )

	end

end
