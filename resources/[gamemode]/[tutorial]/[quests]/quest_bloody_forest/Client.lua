loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "CQuest" )
Extend( "CActionTasksUtils" )
Extend( "CUI" )
Extend( "CAI" )

addEventHandler( "onClientResourceStart", resourceRoot, function( )
	CQuest( QUEST_DATA )
end )

function CreateFollowInterface()
	local self = {}

	self.follows = {}
	self.init = function( self )
		addEventHandler( "onClientPlayerVehicleEnter", localPlayer, self.on_player_veh_enter )
		addEventHandler( "onClientPlayerVehicleExit", localPlayer, self.on_player_veh_exit )
	end

	self.on_player_veh_enter = function( vehicle )
		local seat = 1
		for k, v in pairs( self.follows ) do
			if isElement( k ) then
				self:stop_follow( k )
				AddAIPedPatternInQueue( k, AI_PED_PATTERN_VEHICLE_ENTER, {
					vehicle = vehicle;
					seat = seat;
				} )
				seat = seat + 1
			end
		end
	end

	self.on_player_veh_exit = function()
		for k, v in pairs( self.follows ) do
			AddAIPedPatternInQueue( k, AI_PED_PATTERN_VEHICLE_EXIT, {
				end_callback = {
					func = function()
						self:follow( k )
					end,
					args = { },
				}
			} )
		end
	end

	self.follow = function( self, ped, distance )
		self:stop_follow( ped )
		
		self.follows[ ped ] = CreatePedFollow( ped )
		self.follows[ ped ].distance = distance or 5
		self.follows[ ped ]:start( localPlayer )
	end

	self.stop_follow = function( self, ped )
		if self.follows[ ped ] then
			self.follows[ ped ]:destroy()
			self.follows[ ped ] = nil
		end
	end

	self.destroy = function()
		removeEventHandler( "onClientPlayerVehicleEnter", localPlayer, self.on_player_veh_enter )
		removeEventHandler( "onClientPlayerVehicleExit", localPlayer, self.on_player_veh_exit )
		setmetatable( self, nil )
	end

	self:init()

	return self
end