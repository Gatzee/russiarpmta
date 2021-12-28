loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "ib" )
Extend( "CInterior" )
Extend( "CPlayer" )
Extend( "CActionTasksUtils" )
Extend( "CUI" )
Extend( "ShUtils" )

IB_elements = {}
CEs = {}
ANIMATION = nil
PREIST = nil
MARKERS = {
	WEDDING_POS = {
		x = 183.7721,
		y = -799.2515,
		z = 1140.5,
		accepted_elements = { player = true },
		keypress = "lalt",
		radius = 1.5,
		marker_text = "Свадьба",
		text = "ALT Взаимодействие",
		dimension = 1,
        interior = 1,
		PostJoin = function( self, player )
			triggerServerEvent( "OnWeddingPlayerWantStartWedding", resourceRoot )
		end
	};
	CHURCH_ENTER = {
		x = 179.96,
		y = -1693.46 + 860,
		z = 22.83,
		accepted_elements = { player = true },
		keypress = "lalt",
		radius = 1.5,
		marker_text = "Церковь",
		text = "ALT Взаимодействие",
		PostJoin = function( )
			localPlayer:Teleport( { x = 183.96, y = - 837.46, z = 1140 }, 1, 1, 1000 )
			localPlayer:CompleteDailyQuest( "np_visit_church" )
		end
	};

	CHURCH_EXIT = {
		x = 183.96,
		y = - 837.46,
		z = 1140.5,
		accepted_elements = { player = true },
		keypress = "lalt",
		radius = 1.5,
		marker_text = "Выход",
		text = "ALT Взаимодействие",
		dimension = 1,
        interior = 1,
		PostJoin = function( )
			localPlayer:Teleport( { x = 179.96, y = -1693.46 + 860, z = 22.83 }, 0, 0, 50 )
		end
	};
}
function CWeddingOnStart()

	--Маркеры
	for i, v in pairs( MARKERS ) do
		if v.marker_text == "Церковь" then
			v.elements = { }
			v.elements.blip = createBlip( v.x, v.y, v.z, 0, 2, 255, 255, 255, 255, 0, 150 )
			setElementData( v.elements.blip, "extra_blip", 67, false )
		end
		local teleport = TeleportPoint( v )
		teleport.element:setData( "ignore_dist", true )
		teleport.marker:setColor( 0, 255 ,0, 20 )
		teleport.PostJoin = v.PostJoin
		teleport.element:setData( "material", true, false )
		teleport:SetDropImage( { ":nrp_shared/img/dropimage.png", 0, 255, 0, 255, 1.2 } )
		
		if v.marker_text == "Церковь" then
			teleport.PreJoin = function(self, player)
				if player:GetBlockInteriorInteraction() then
					player:ShowInfo( "Вы не можете войти во время задания" )
					return false
				end
				return true
			end
		end
	end
	
	--Священник
	PREIST = createPed( WEDDING_SKINS.preist, 183.79, -794.52, 1140.90 )
	PREIST.interior = 1
	PREIST.dimension = 1
	PREIST:setRotation( 0, 0, 180 )
	PREIST:setFrozen( true )
	addEventHandler( "onClientPedDamage", PREIST, function()
		cancelEvent()
	end )


	engineLoadIFP( "files/anim.ifp", "nrp_wedding.svadba1" )
	engineLoadIFP( "files/kiss.ifp", "nrp_wedding.svadba2" )

end
addEventHandler( 'onClientResourceStart', resourceRoot, CWeddingOnStart )

function CWeddingOnStop()
	--setCameraTarget(localPlayer)
end
addEventHandler( 'onClientResourceStop', resourceRoot, CWeddingOnStop )

local stand_pos = {
	pos = {
		{ 183.388, -796.724, 1140.9 },
		{ 184.2, -796.7, 1140.90 },
	},
	rot = { 359, 0.86 },
};

--Запуск диалогов свадьбы
function OnPlayerStartWedding_handler( pos )
	--CEs.stripes = CreateBlackStripes()
	--CEs.stripes:show( )
	StartQuestCutscene()
	setCameraMatrix( 183.7, -798.86651, 1142, 183.7, -793.062, 1141, 0, 70 )
	localPlayer:setPosition( unpack( stand_pos.pos[pos] ) )
	localPlayer:setRotation( 0, 0, stand_pos.rot[pos] )

	CEs.dialog = CreateDialog( {
		{ name = "Батюшка", text = "Дорогие возлюбленные, мы собрались здесь и сейчас \nдабы стать свидетелями вступления в брак двоих детей божьих.", voice_line = "Priest_1" },
		{ name = "Батюшка", text = "Властью данной мне господом нашим нарекаю вас мужем и женой! ", voice_line = "Priest_2" },
	} )
	--CEs.dialog:reposition_to_stripes( CEs.stripes )
	CEs.dialog:next( )
	
	--Запуск первой части диалога
	CEs.timer = setTimer( function( )
		iprint("запрос на открытие окна, OnWeddingPlayerDialogStartPartEnds")
		triggerServerEvent( "OnWeddingPlayerDialogStartPartEnds", resourceRoot )
	end, 10*1000, 1 )
end
addEvent( "OnWeddingPlayerStartWedding", true )
addEventHandler( "OnWeddingPlayerStartWedding", localPlayer, OnPlayerStartWedding_handler )

function onPlayerWeddingSuccess_handler()
	--Запуск второй части диалога
	CEs.dialog:next( )
	CEs.timer = setTimer( function( )
		CEs.dialog:destroy_with_animation()
		--CEs.stripes:destroy_with_animation()

		CEs.timer2 = setTimer( function( )
			StopDialogScene()
			CWeddingBonuslistSetState( true )
			setTimer( function()
				triggerServerEvent( "onWeddingEndSuccessDialog", resourceRoot )
			end, 500, 1 )
		end, 1000, 1 )

	end, 14*1000, 1 )
end
addEvent( "OnWeddingPlayerWeddingSuccess", true )
addEventHandler( "OnWeddingPlayerWeddingSuccess", localPlayer, onPlayerWeddingSuccess_handler )

function onPlayerWeddingOfferCanceled_handler()
	StopDialogScene()
	showPlayerAcceptWindow_handler( false )
end
addEvent( "OnWeddingPlayerWeddingOfferCanceled", true )
addEventHandler( "OnWeddingPlayerWeddingOfferCanceled", localPlayer, onPlayerWeddingOfferCanceled_handler )

function StopDialogScene()
	if next( CEs ) then
		showCursor( false )
		FinishQuestCutscene( )
		DestroyTableElements( CEs )
		CEs = {}
	end
end

function OnWeddingPlayerCallSeatAnimation_handler( list, state, stage )
	local function set( player, state, stage )
		if state then
			player:setAnimation( "nrp_wedding.svadba1", not stage and "Sit" or "Sit_" .. stage, not stage and -1 or 1500, false, true )
			if stage then
				setTimer( function( player )
					player:setAnimation()
				end, 1500, 1, player )
			end
		else
			player:setAnimation()
		end
	end
	if type( list ) == "table" then
		for i, v in pairs( list ) do
			set( v, state, stage )
		end
	else
		set( list, state, stage )
	end
end
addEvent( "OnWeddingPlayerCallSeatAnimation", true )
addEventHandler( "OnWeddingPlayerCallSeatAnimation", resourceRoot, OnWeddingPlayerCallSeatAnimation_handler )
--[[for i,v in pairs( getElementsByType( 'player')) do
	v:setAnimation()
end]]

function OnWeddingPlayerCallKissAnimation_handler( list )
	local is_local_player = list.female == localPlayer or list.male == localPlayer

	list.female:setCollidableWith( list.male, false )
	list.male:setCollidableWith( list.female, false )
	setTimer( function( player )
		player:setAnimation( "nrp_wedding.svadba2", "Playa_Kiss_02", 5000, false, true, false, false )
	end, 1000, 1, list.female )
	list.male:setAnimation( "nrp_wedding.svadba2", "Playa_Kiss_03", 5000, false, true, false, false )

	if is_local_player then
		addEventHandler( "onClientKey", root, KissKeyHandler )
	end

	setTimer( function( list, is_local_player )
		if isElement( list.female ) and isElement( list.male ) then
			list.female:setCollidableWith( list.male, true )
			list.male:setCollidableWith( list.female, true )
		end

		if is_local_player then
			removeEventHandler( "onClientKey", root, KissKeyHandler )
		end
	end, 6000, 1, list, is_local_player )
end
addEvent( "OnWeddingPlayerCallKissAnimation", true )
addEventHandler( "OnWeddingPlayerCallKissAnimation", resourceRoot, OnWeddingPlayerCallKissAnimation_handler )

function KissKeyHandler( )
	cancelEvent( )
end

function OnWeddingDivorceApply_handler()
	showCursor( true )
	IB_elements.confirm_divorce = ibConfirm(
		{
			title = "РАЗВОД", 
			text = "Ты действительно хочешь развестись?" ,
			fn = function( self )
				triggerServerEvent( "onWeddingPlayerWannaDivorce", resourceRoot )
				self:destroy()
				showCursor( false )
			end,
			fn_cancel = function( self )
				triggerServerEvent( "onWeddingPlayerDivorceCanceled", resourceRoot )
				self:destroy()
				showCursor( false )
			end,
			escape_close = true,
		}
	)
end
addEvent( "OnWeddingDivorceApply", true )
addEventHandler( "OnWeddingDivorceApply", localPlayer, OnWeddingDivorceApply_handler )

function OnWeddingForceClear_handler()
	StopDialogScene()
	showPlayerAcceptWindow_handler( false )
	CWeddingOfferSetState_handler( false )
	CWeddingRenameSetState( false )
end
addEvent( "OnWeddingForceClear", true )
addEventHandler( "OnWeddingForceClear", localPlayer, OnWeddingForceClear_handler )