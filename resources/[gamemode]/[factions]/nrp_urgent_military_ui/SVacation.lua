loadstring(exports.interfacer:extend("Interfacer"))()
Extend("SPlayer")
Extend("SVehicle")
Extend("ShVehicleConfig")

function PlayerWantGetUrgentMilitaryVacation()
	if not client then return end
	if not client:IsInGame() then return end
	if not client:IsOnUrgentMilitary() then return end
	if not client:IsInUrgentMilitaryBase() then return end

	local current_quest = client:getData( "current_quest" )
	if current_quest then
		client:ShowError( "Сначала закончи выполнять квест" )
		return
	end

	local last_enter_urgent_military_base = client:getData( "last_enter_urgent_military_base" )
	if last_enter_urgent_military_base and ( last_enter_urgent_military_base + URGENT_MILITARY_VACATION_TIMEOUT ) > getRealTimestamp( ) then
		return
	end

	client:ExitFromUrgentMilitaryBase()
	client:GiveUrgentMilitaryVacation()
end
addEvent( "PlayerWantGetUrgentMilitaryVacation", true )
addEventHandler( "PlayerWantGetUrgentMilitaryVacation", resourceRoot, PlayerWantGetUrgentMilitaryVacation )

function PlayerWantBackInUrgentMilitaryBase()
	if not client then return end
	if not client:IsInGame() then return end
	if not client:IsOnUrgentMilitary() then return end
	if client:IsInUrgentMilitaryBase() then return end

	local current_quest = client:getData( "current_quest" )
	if current_quest then
		client:ShowError( "Сначала закончи выполнять квест" )
		return
	end

	local urgent_military_vacation = client:getData( "urgent_military_vacation" )

	client:EnterOnUrgentMilitaryBase()
	client:TakeUrgentMilitaryVacation()

	if urgent_military_vacation and ( urgent_military_vacation + URGENT_MILITARY_VACATION_LEN ) < getRealTime().timestamp then
		client:TakeMilitaryExp( URGENT_MILITARY_VACATION_FINE_EXP )
	end

	client:ParkedVehicles()
end
addEvent( "PlayerWantBackInUrgentMilitaryBase", true )
addEventHandler( "PlayerWantBackInUrgentMilitaryBase", resourceRoot, PlayerWantBackInUrgentMilitaryBase )

function PlayerWantStartUrgentMilitary()
	if not client then return end
	if not client:IsInGame() then return end
	if client:IsOnUrgentMilitary() then return end
	if client:HasMilitaryTicket() then return end

	local current_quest = client:getData( "current_quest" )
	if current_quest then
		client:ShowError( "Сначала закончи выполнять квест" )
		return
	end

	if #client:GetWantedData() > 0 then
		client:ShowError( "Военкомат не принимает розыскиваемых" )
		return
	end

	if client:getData( "is_handcuffed" ) then
		client:ShowError( "На службе зеки не нужны" )
		return
	end

	-- Выход из интерьера
	client.interior = 0
	client.dimension = 0

	-- Начало входа на срочку
	triggerEvent( "PlayeStartQuest_urgent_military_1", client )
end
addEvent( "PlayerWantStartUrgentMilitary", true )
addEventHandler( "PlayerWantStartUrgentMilitary", resourceRoot, PlayerWantStartUrgentMilitary )

function PlayerWantMilitaryLeave_handler()
	if not client then return end
	if not client:IsInGame() then return end
	if not client:IsOnUrgentMilitary() then return end
	client:SetMilitaryLevel( 0 )
	client:SetMilitaryExp( 0 )
	if client:IsInUrgentMilitaryBase() then
		client:ExitFromUrgentMilitaryBase()
	else
		client:TakeUrgentMilitaryVacation()
	end
	client:ShowSuccess( "Ты покинул срочную службу. Эх, в жизни бы так..." )
	triggerEvent( "onPlayerUrgentMilitaryLeave", client, true )
end
addEvent( "PlayerWantMilitaryLeave", true )
addEventHandler( "PlayerWantMilitaryLeave", root, PlayerWantMilitaryLeave_handler )

addEventHandler( "onPlayerReadyToPlay", root, function ( )
	if source:IsOnUrgentMilitary( ) then
		source:EnterOnUrgentMilitaryBase( )
	end
end )