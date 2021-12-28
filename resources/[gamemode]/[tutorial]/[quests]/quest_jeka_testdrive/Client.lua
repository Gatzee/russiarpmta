loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "CQuest" )
Extend( "CActionTasksUtils" )
Extend( "CUI" )

addEventHandler( "onClientResourceStart", resourceRoot, function( )
	CQuest( QUEST_DATA )
end )

function CreateDragInterface()
	local self = 
	{
		prepare_race_time = function( self, value )
			local minute = math.floor( value / 60000 )
			local seconds = math.floor( (value - minute * 60000) / 1000 )
			local milliseconds = value - minute * 60000 - seconds * 1000
			return string.format( "%02d:%02d:%02d", minute, seconds, milliseconds )
		end,

		init = function( self )
			self.ox_bold_25 = dxCreateFont( ":nrp_races/files/fonts/Oxanium-Bold.ttf", 25, false, "antialiased" )
			self.race_time = ibCreateLabel( 0, 92, _SCREEN_X, 0, self:prepare_race_time( 0 ), _, 0xFFFFFFFF, 1, 1, "center", "center", self.ox_bold_25 )
				:ibOnRender( function()
					if not self.start_time then return end
					self.race_time:ibData( "text", self:prepare_race_time( getTickCount() - self.start_time ) )
				end )
		end,

		start = function( self )
			self.start_time = getTickCount()
		end,

		show = function( self, state )
			self.race_time:ibData( "alpha", state and 255 or 0 )
		end,

		stop = function( self )
			self:show( false )

			local race_time = getTickCount() - self.start_time
			self.start_time = nil
			return self:prepare_race_time( race_time )
		end,
	}

	self:init()
	return self
end