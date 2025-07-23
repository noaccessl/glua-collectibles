--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	
	Extends the utf8 library with lower & upper functions

–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]


local REPLACE_DEFAULT_LUA_UPPER_LOWER = true

if ( REPLACE_DEFAULT_LUA_UPPER_LOWER and ( string.upper == utf8.upper and string.lower == utf8.lower ) ) then
	return
end

--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Prepare
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
--
-- Globals
--
local strlower = string.lower
local strupper = string.upper
local strgsub = string.gsub


--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Form maps
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
local UPPER2LOWER
local LOWER2UPPER

do

	UPPER2LOWER = {

		--
		-- Cyrillic
		--
		['А'] = 'а'; ['Б'] = 'б'; ['В'] = 'в'; ['Г'] = 'г'; ['Д'] = 'д'; ['Е'] = 'е'; ['Ё'] = 'ё'; ['Ж'] = 'ж'; ['З'] = 'з'; ['И'] = 'и'; ['Й'] = 'й';
		['К'] = 'к'; ['Л'] = 'л'; ['М'] = 'м'; ['Н'] = 'н'; ['О'] = 'о'; ['П'] = 'п'; ['Р'] = 'р'; ['С'] = 'с'; ['Т'] = 'т'; ['У'] = 'у'; ['Ф'] = 'ф';
		['Х'] = 'х'; ['Ц'] = 'ц'; ['Ч'] = 'ч'; ['Ш'] = 'ш'; ['Щ'] = 'щ'; ['Ъ'] = 'ъ'; ['Ы'] = 'ы'; ['Ь'] = 'ь'; ['Э'] = 'э'; ['Ю'] = 'ю'; ['Я'] = 'я';

		--
		-- Latin
		--
		A = 'a'; B = 'b'; C = 'c'; D = 'd'; E = 'e'; F = 'f'; G = 'g'; H = 'h'; I = 'i'; J = 'j'; K = 'k'; L = 'l'; M = 'm';
		N = 'n'; O = 'o'; P = 'p'; Q = 'q'; R = 'r'; S = 's'; T = 't'; U = 'u'; V = 'v'; W = 'w'; X = 'x'; Y = 'y'; Z = 'z';

		--
		-- Specific
		--
		[ '\t' ] = '\t'; [ '\n' ] = '\n'

	}

	LOWER2UPPER = {}

	--
	-- Translate to LOWER2UPPER
	--
	for upper, lower in pairs( UPPER2LOWER ) do
		LOWER2UPPER[lower] = upper
	end

	--
	-- Constant characters
	--
	local CHARS_CONST = [[ `1234567890-=~!@#$%^&*()_+/*[]\;',./{}|:"<>?]]

	for i = 1, #CHARS_CONST do

		local char = CHARS_CONST[i]

		UPPER2LOWER[char] = char
		LOWER2UPPER[char] = char

	end

end

--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Lookup tables
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
local Upper2Lower = setmetatable( UPPER2LOWER, {

	-- Fall back to using the original function
	__index = function( self, char )

		return strlower( char )

	end

} )

local Lower2Upper = setmetatable( LOWER2UPPER, {

	-- Fall back to using the original function
	__index = function( self, char )

		return strupper( char )

	end

} )

--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	lower
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
function utf8.lower( str )

	local result = strgsub( str, '[%z\1-\127\194-\244][\128-\191]*', Upper2Lower )
	return result

end

--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	upper
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
function utf8.upper( str )

	local result = strgsub( str, '[%z\1-\127\194-\244][\128-\191]*', Lower2Upper )
	return result

end

--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Replacement
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
if ( REPLACE_DEFAULT_LUA_UPPER_LOWER ) then

	string.lower = utf8.lower
	string.upper = utf8.upper

end
