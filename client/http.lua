
--[[

	Note:
		The script is a bit old and can be improved.
		At the moment, this is for your insight of the concept;
		and not meaning you can't use it.

]]


--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Prepare
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
--
-- Globals
--
local GetExtension = string.GetExtensionFromFilename
local GetFile = string.GetFileFromFilename

local gsub = string.gsub
local FileWrite = file.Write

--
-- Utilities
--
local function HTTPRequest( url )

	local thread = coroutine.running()

	http.Fetch( url, function( body )

		coroutine.resume( thread, true, body )

	end, function( err )

		coroutine.resume( thread, false, err )

	end )

	return coroutine.yield()

end


--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Purpose: Very simple image downloader
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
file.CreateDir( 'webimages' )

local IMAGE_EXTENSIONS = {

	png = true;
	jpg = true;
	jpeg = true

}

local Downloaded = {}

function http.DownloadImage( url, callback, pngParameters )

	if ( not IMAGE_EXTENSIONS[ GetExtension( url ) ] ) then
		return
	end

	coroutine.wrap( function()

		local success, result = HTTPRequest( url )

		if ( success ) then

			local data = result

			local path = 'webimages/' .. GetFile( gsub( url, '.+%/', '' ) )

			FileWrite( path, data )
			Downloaded[ path ] = true

			if ( callback ) then
				callback( Material( '../data/' .. path, pngParameters ) )
			end

		else

			local err = result
			error( Format( '[http.DownloadImage] Failed to fetch %s (Reason: %s)', url, err ) )

		end

	end )()

end

gameevent.Listen( 'client_disconnect' )
hook.Add( 'client_disconnect', 'WebImagesGC', function()

	for path in pairs( Downloaded ) do
		file.Delete( path )
	end

end )
