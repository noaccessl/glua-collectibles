--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––

	gluafuncbudget
	 A utility that serves to conveniently measure performance of functions.

–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]



--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Prepare
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
--
-- Functions & Libraries
--
local Color = Color
local MsgC = MsgC
local Format = Format
local table = table
local math = math
local string = string
local Msg = Msg
local pcall = pcall
local jit = jit
local timer = timer


--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Common Colors
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
local WHITE = Color( 255, 255, 255 )

local RED = Color( 255, 85, 85 )
local GRAY = Color( 180, 180, 180 )
local YELLOW = Color( 255, 255, 170 )
local GREEN = Color( 170, 255, 170 )
local DARKAQUA = Color( 0, 170, 170 )

local COLOR_JIT = Color( 255, 179, 128 )

local COLOR_SERVER = Color( 156, 241, 255, 200 )
local COLOR_CLIENT = Color( 255, 241, 122, 200 )
local COLOR_MENU = Color( 100, 220, 100, 200 )


--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Purpose: Formatted colored console message
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
local function MsgF( col, fmt, ... )

	MsgC( col, Format( fmt, ... ) )

end


--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Purpose: Calculates the sum of the given number set
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
local function calculate_sum( numset )

	local sum = 0

	for i = 1, #numset do
		sum = sum + numset[i]
	end

	return sum

end

--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Purpose: Calculates the median of the given number set
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
local function calculate_median( numset )

	local len = #numset
	local copy = {}

	for i = 1, len do
		copy[i] = numset[i]
	end

	table.sort( copy )

	if ( len % 2 == 0 ) then
		return ( copy[ len * 0.5 ] + copy[ len * 0.5 + 1 ] ) * 0.5
	end

	return copy[ math.ceil( len * 0.5 ) ]

end

--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Purpose: Finds the minimal in the given number set
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
local function find_minimal( numset )

	local min_true = math.huge

	for i = 1, #numset do

		local min_potential = numset[i]

		if ( min_potential < min_true ) then
			min_true = min_potential
		end

	end

	return min_true

end

--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Purpose: Finds the maximal in the given number set
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
local function find_maximal( numset )

	local max_true = -0

	for i = 1, #numset do

		local max_potential = numset[i]

		if ( max_potential > max_true ) then
			max_true = max_potential
		end

	end

	return max_true

end


--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Purpose: Gets a readable name for the `BRANCH`
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
local GetBranchNiceName; do

	local TRANSLATE = {

		['unknown'] = 'Main';
		['dev'] = 'Development';
		['prerelease'] = 'Pre-release';
		['x86-64'] = 'x64'

	}

	function GetBranchNiceName()

		return TRANSLATE[BRANCH]

	end

end


--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Purpose: Converts milliseconds into seconds
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
local function ms_to_sec( ms ) return ms / 1000 end

--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Purpose: Converts milliseconds into microseconds
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
local function ms_to_us( ms ) return ms * 1000 end


--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	gluafuncbudget
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
gluafuncbudget = {}

local Queue = {}
local Results = {}

local FuncBudget_Frames = 0
local FuncBudget_Iterations = 0
local FuncBudget_Digit = 5
local FuncBudget_MeasureUnit = 'us'
local FuncBudget_ComparisonBasis = 'average' -- total/median/average/min/max
local FuncBudget_ShownCategories = 'total median average min max avgfps stddevfps minfps maxfps'

local FuncBudget_Standard_Last = 0

--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Purpose: Configures the utility

	#doc

		#Structure GLuaFuncBudgetParams

			Description
			—————————————————————————————————————
				The configuration-structure for the utility.

			Members
			—————————————————————————————————————
				number frames
					The number of frames for the budgeting of functions.

					A point of reference:
						The more frames, the more averaged, less deviated, comprehensive the result is.
						The less frames, the more occasional the result is.
						"Precision" is likely to be an inapplicable term here
						for if to take calculations, they're already precise,
						so what actually is supposed to get more precise?.

				number iterations_per_frame
					The number of iterations of a budgeted-function within a frame.

				number digit
					The amount of shown digits after the decimal point of time-spent-numbers.

					Default: 5

				string measure_unit
					One of these: s (seconds); ms (milliseconds); us (microseconds).

					Default: 'us'

				string comparison_basis
					The time-spent-category by which budgeted-functions are compared.
					One of these: total, median, average, min, max.

					Default: 'average'

				string shown_categories
					The shown time-spent-categories.
					A combination of keywords: total, median, average, min, max, avgfps, stddevfps, minfps, maxfps.

					Default: 'total median average min max avgfps stddevfps minfps maxfps'

		#

	#enddoc
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
function gluafuncbudget.Configure( tGLuaFuncBudgetParams )

	local params = tGLuaFuncBudgetParams

	FuncBudget_Frames            = math.floor( params.frames )
	FuncBudget_Iterations        = math.floor( params.iterations_per_frame )
	FuncBudget_Digit             = math.floor( params.digit or 5 )
	FuncBudget_MeasureUnit       = params.measure_unit or 'us'
	FuncBudget_ComparisonBasis   = params.comparison_basis or 'average'
	FuncBudget_ShownCategories   = params.shown_categories or 'total median average min max avgfps stddevfps minfps maxfps'

	local colRealm = CLIENT_DLL and COLOR_CLIENT or ( GAME_DLL and COLOR_SERVER or COLOR_MENU )
	local realmname = CLIENT_DLL and 'Client' or ( GAME_DLL and 'Server' or 'Menu' )

	MsgF( WHITE, '\n%s\nGLuaFuncBudget Configuration:',    string.rep( '-', 48 ) )
	MsgC( WHITE, '\n\tBranch: ',                      YELLOW,   GetBranchNiceName() )
	MsgC( WHITE, '\n\tRealm: ',                       colRealm,       realmname )
	MsgC( WHITE, '\n\tFrames: ',                      GRAY,     string.Comma( FuncBudget_Frames ) )
	MsgC( WHITE, '\n\tIterations/frame: ',            GRAY,     string.Comma( FuncBudget_Iterations ) )
	MsgC( WHITE, '\n\tDigit: ',                       GRAY,     FuncBudget_Digit )
	MsgC( WHITE, '\n\tMeasure Unit: ',                RED,      FuncBudget_MeasureUnit )
	MsgC( WHITE, '\n\tComparison Basis: ',            DARKAQUA, FuncBudget_ComparisonBasis )
	MsgC( WHITE, '\n\tShown Categories: ',            WHITE,    FuncBudget_ShownCategories )
	Msg( '\n' )

end


--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Purpose: (Internal) Adjusts the passed time
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
local function adjust_time_spent( flTimeSpent )

	if ( FuncBudget_MeasureUnit == 's' ) then return ms_to_sec( flTimeSpent ) end
	if ( FuncBudget_MeasureUnit == 'us' ) then return ms_to_us( flTimeSpent ) end

	return flTimeSpent

end

--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Purpose: (Internal) Budgets the passed budgeted-function
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
local ResetTimerCycle, GetLastTimerCycle = util.TimerCycle, util.TimerCycle

local function BudgetFunction( tBudgetedFunc )

	local budgetedfunc = tBudgetedFunc

	local name = budgetedfunc.name
	local pfnMain = budgetedfunc.main

	local arg1, arg2, arg3, arg4, arg5, arg6, arg7
	local pfnSetup = budgetedfunc.setup

	if ( pfnSetup ) then
		arg1, arg2, arg3, arg4, arg5, arg6, arg7 = pfnSetup( budgetedfunc )
	end

	local success, err = pcall( pfnMain, arg1, arg2, arg3, arg4, arg5, arg6, arg7 )

	if ( not success ) then
		return MsgF( WHITE, '\nBudgeted-function[%s] has failed:\n\t%s\n', name, err )
	end

	--
	-- Start
	--
	local funcbudget = {

		m_TimeSpentHistory = {};
		m_FrameRateHistory = {};

		__budgetedfunc = budgetedfunc

	}

	table.insert( Results, funcbudget )

	jit.on()
	jit.opt.start( 3 )

	if ( budgetedfunc.jit_off ) then
		jit.off( pfnMain )
	else
		jit.on( pfnMain )
	end

	-- More info on arguments for jit.off|on|flush here: https://luajit.org/ext_jit.html

	local flTimeSpent = 0.0
	local flFrameRate = 0.0

	for frame = 1, FuncBudget_Frames do

		jit.flush( true, false )
		pfnMain( arg1, arg2, arg3, arg4, arg5, arg6, arg7 )
		-- Calling the function before measuring it's execution time
		-- prepares it, so to speak.
		-- And the execution time renders a bit more accurate.

		if ( FuncBudget_Iterations > 1 ) then

			ResetTimerCycle()

				for i = 1, FuncBudget_Iterations do
					pfnMain( arg1, arg2, arg3, arg4, arg5, arg6, arg7 )
				end

			flTimeSpent = GetLastTimerCycle()

		else

			ResetTimerCycle()
				pfnMain( arg1, arg2, arg3, arg4, arg5, arg6, arg7 )
			flTimeSpent = GetLastTimerCycle()

		end

		flFrameRate = 1 / ms_to_sec( flTimeSpent )
		funcbudget.m_FrameRateHistory[frame] = flFrameRate

		flTimeSpent = adjust_time_spent( flTimeSpent )
		funcbudget.m_TimeSpentHistory[frame] = flTimeSpent

	end

	local pfnAfter = budgetedfunc.after

	if ( pfnAfter ) then
		pfnAfter()
	end

end


--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Purpose: (Internal) Calculates, outputs, and flushes the results
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
local subsequent = ipairs( {} )

local function FinishBudgeting()

	for index, funcbudget in subsequent, Results, 0 do

		local historyTimeSpent = funcbudget.m_TimeSpentHistory
		local historyFrameRate = funcbudget.m_FrameRateHistory

		local budgetedfunc = funcbudget.__budgetedfunc

		--
		-- Calculate
		--
		local flTotal = calculate_sum( historyTimeSpent )
		local flMedian = calculate_median( historyTimeSpent )
		local flMin = find_minimal( historyTimeSpent )
		local flMax = find_maximal( historyTimeSpent )
		local flAvg = flTotal / #historyTimeSpent

		local flAvgFrameRate = calculate_sum( historyFrameRate ) / FuncBudget_Frames
		local flMinFrameRate = find_minimal( historyFrameRate )
		local flMaxFrameRate = find_maximal( historyFrameRate )

		local flDeviationSquared = 0

		-- Compute standard deviation
		for frame = 1, FuncBudget_Frames do

			local val = historyFrameRate[frame] - flAvgFrameRate
			flDeviationSquared = flDeviationSquared + ( val * val )

		end

		local variance = flDeviationSquared / ( FuncBudget_Frames - 1 )
		local flStdDevFrameRate = math.sqrt( variance )

		local numComparisonBasis; do

			local options = {

				total = flTotal;
				median = flMedian;
				min = flMin;
				max = flMax;
				average = flAvg

			}

			numComparisonBasis = options[FuncBudget_ComparisonBasis]

		end

		local flPercent = 100.0

		if ( budgetedfunc.standard ) then
			FuncBudget_Standard_Last = numComparisonBasis
		else
			flPercent = ( numComparisonBasis * 100 ) / FuncBudget_Standard_Last
		end

		--
		-- Output
		--
		local jit_off = budgetedfunc.jit_off
		local colJIT = jit_off and GRAY or GREEN
		local statusJIT = jit_off and 'OFF' or 'ON'

		MsgC(

			WHITE, '\nBudgeted-function (', COLOR_JIT, 'JIT ', colJIT, statusJIT, WHITE, '): ',
			YELLOW, budgetedfunc.name, ' ', WHITE, '(', DARKAQUA, Format( '%g%%', flPercent ), WHITE, ')'

		)

		local fmt_fl = '%.' .. FuncBudget_Digit .. 'f'
		local MU = FuncBudget_MeasureUnit

		local to_show = FuncBudget_ShownCategories

		if ( to_show:find( 'total' ) ) then
			MsgC( WHITE, '\n\tTotal     ', GRAY, Format( fmt_fl, flTotal ), ' ', RED, MU )
		end

		if ( to_show:find( 'median' ) ) then
			MsgC( WHITE, '\n\tMedian    ', GRAY, Format( fmt_fl, flMedian ), ' ', RED, MU )
		end

		if ( to_show:find( 'average' ) ) then
			MsgC( WHITE, '\n\tAverage   ', GRAY, Format( fmt_fl, flAvg ), ' ', RED, MU )
		end

		if ( to_show:find( 'min' ) ) then
			MsgC( WHITE, '\n\tMin       ', GRAY, Format( fmt_fl, flMin ), ' ', RED, MU )
		end

		if ( to_show:find( 'max' ) ) then
			MsgC( WHITE, '\n\tMax       ', GRAY, Format( fmt_fl, flMax ), ' ', RED, MU )
		end

		if ( to_show:find( 'avgfps' ) ) then
			MsgC( WHITE, '\n\tAvgFPS    ', GRAY, Format( '%.2f', flAvgFrameRate ) )
		end

		if ( to_show:find( 'stddevfps' ) ) then
			MsgC( WHITE, '\n\tStdDevFPS ', GRAY, Format( '%.2f', flStdDevFrameRate ) )
		end

		if ( to_show:find( 'minfps' ) ) then
			MsgC( WHITE, '\n\tMinFPS    ', GRAY, Format( '%.2f', flMinFrameRate ) )
		end

		if ( to_show:find( 'maxfps' ) ) then
			MsgC( WHITE, '\n\tMaxFPS    ', GRAY, Format( '%.2f', flMaxFrameRate ) )
		end

		MsgC( WHITE, '\n' )

		-- Flush
		Results[index] = nil

	end

end


--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Purpose: (Internal) Schedules function-budgeting
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
local function ScheduleFunctionBudgeting()

	timer.Create( 'gluafuncbudget', 0, 1, function()

		local tBudgetedFunc = table.remove( Queue, 1 )
		BudgetFunction( tBudgetedFunc )

		if ( Queue[1] ~= nil ) then
			ScheduleFunctionBudgeting()
		else
			FinishBudgeting()
		end

	end )

end

--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Purpose: Queues the passed budgeted-function

	#doc

		#Structure BudgetedFunc

			Description
			—————————————————————————————————————
				The datum-structure for a function to be budgeted.

			Members
			—————————————————————————————————————
				string name
					The name of this case.

				boolean standard
					Should the result of this budgeted-function be used as the current comparison-standard across-the-board?
					Optional though recommended.

				function setup
					The function to be called before the main one. Optional.

					Function's Arguments:
						1. table budgetedfunc — self

					Function's Returns:
						1. vararg args — arguments to be passed to the main function (up to 7)

				function main
					The function to be budgeted.

					Function's Arguments:
						1–7. any — arguments passed from the setup function

				boolean jit_off
					Should LuaJIT Lua compilation be disabled for this exact function?
					Optional.

				function after
					The function to be called after the main one. Optional.

		#

	#enddoc
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
function gluafuncbudget.Queue( tBudgetedFunc )

	table.insert( Queue, tBudgetedFunc )

	ScheduleFunctionBudgeting()

end
