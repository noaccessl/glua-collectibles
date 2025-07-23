
### [http.lua](./http.lua)

#### `http.DownloadImage`
Downloads an image from a web server into `DATA/webassets` folder

###### Example</br>Through callback
```lua
http.DownloadImage( 'https://files.facepunch.com/garry/822e60dc-c931-43e4-800f-cbe010b3d4cc.png', function( pMaterial )

	hook.Add( 'HUDPaint', '', function()

		local w, h = pMaterial:Width(), pMaterial:Height()

		surface.SetDrawColor( 255, 255, 255 )
		surface.SetMaterial( pMaterial )
		surface.DrawTexturedRect( ScrW() * 0.5 - w * 0.5, ScrH() * 0.5 - h * 0.5, w, h )

	end )

end )
```

###### Example</br>Through upvalue
```lua
local matIcon = Material( '__error' )

http.DownloadImage( 'https://files.facepunch.com/garry/822e60dc-c931-43e4-800f-cbe010b3d4cc.png', function( pMaterial )

	matIcon = pMaterial

end )

hook.Add( 'HUDPaint', '', function()

	if ( matIcon:IsError() ) then
		return
	end

	local w, h = matIcon:Width(), matIcon:Height()

	surface.SetDrawColor( 255, 255, 255 )
	surface.SetMaterial( matIcon )
	surface.DrawTexturedRect( ScrW() * 0.5 - w * 0.5, ScrH() * 0.5 - h * 0.5, w, h )

end )
```
