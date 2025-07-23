--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––

	Instead of going through all the table and writing each key and value..;
	what if send it as a string?

–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]


--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Purpose: Custom table encoder & decoder

	Note:
		Built-in JSON isn't the best for networking a table
		 due to potential large strings and performance cost.
		So, replace with your one (pon; sfs (a good one); etc.).
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
local pfnTableToString = util.TableToJSON
local pfnStringToTable = util.JSONToTable

--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	WriteTable
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
local NetworkWriteString = net.WriteString

function net.WriteTable( tbl )

	NetworkWriteString( pfnTableToString( tbl ) )

end

--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	ReadTable
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
local NetworkReadString = net.ReadString

function net.ReadTable()

	return pfnStringToTable( NetworkReadString() )

end
