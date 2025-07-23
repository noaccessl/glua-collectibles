
--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Purpose: Switch statement akin to C/C++. JIT-compatible.
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
do

	local g_value -- g denotes "general"

	local switch_action
	local switch_return

	function switch( any, mode )

		g_value = any

		if ( mode == 'return' ) then
			return switch_return
		end

		return switch_action

	end

	do

		local select = select

		function switch_action( ... )

			local numElements = select( '#', ... )

			local i, stop, step = -1, numElements - 1, 2

			::test::
			i = i + step

				local case, func = select( i, ... )

				if ( case == g_value ) then
					return func()
				end

				-- At this point, `case` is the last element
				-- Taking it as the default/fallback function
				if ( func == nil ) then

					func = case
					return func()

				end

			if ( i ~= stop ) then goto test end

		end

		function switch_return( ... )

			local numElements = select( '#', ... )

			local i, stop, step = -1, numElements - 1, 2

			::test::
			i = i + step

				local case, ret = select( i, ... )

				if ( case == g_value ) then
					return ret
				end

				-- At this point, `case` is the last element
				-- Taking it as the default/fallback return
				if ( ret == nil ) then

					ret = case
					return ret

				end

			if ( i ~= stop ) then goto test end

		end

	end

end
