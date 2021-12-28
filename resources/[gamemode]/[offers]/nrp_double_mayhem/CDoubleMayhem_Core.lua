Extend( "ib" )
Extend( "ShClothesShops" )

ibUseRealFonts( true )

function onClientShowDoubleMayhemOffer_handler( data )
	if data.is_show_first then
        CHECK_ANY_WINDOW_TMR = setTimer( function( )
            if ibIsAnyWindowActive( ) then return end
            killTimer( CHECK_ANY_WINDOW_TMR )

            localPlayer:setData( "double_mayhem_offer_finish", data.offer_finish_date, false )
            ShowDoubleMayhemOfferUI( true, data )
            if not INIT_OFFER then
                INIT_OFFER = true
                triggerEvent( "ShowSplitOfferInfo", root, OFFER_NAME, data.offer_finish_date - getRealTimestamp() )
            end
        end, 1000, 0 )
    else
		local purchased_pack_id = nil
		for k, v in pairs( data.pack_data ) do
			if v == PACK_STATE_PURCHASED then
				purchased_pack_id = k
				break
			end
		end

		if purchased_pack_id then
			onClientShowRewardDoubleMayhem_handler( purchased_pack_id )
		else
        	ShowDoubleMayhemOfferUI( true, data )
		end
    end
end
addEvent( "onClientShowDoubleMayhemOffer", true )
addEventHandler( "onClientShowDoubleMayhemOffer", resourceRoot, onClientShowDoubleMayhemOffer_handler )

function onClientShowRewardDoubleMayhem_handler( pack_id, data )
	HidePaymentWindow( )

	if data then ShowDoubleMayhemOfferUI( true, data ) end
    
	REWARD_INTERFACE = {
		reward_id = 0,
		pack_id = pack_id,
		rewards = pack_id == "gift" and { OFFER_CONFIG.gift } or OFFER_CONFIG.packs[ pack_id ].items,
		
		init = function( self )
			showCursor( true )
			setCursorAlpha( 255 )

			self:show_next_reward()
		end,

		show_next_reward = function( self )
			self.reward_id = self.reward_id + 1
			if isElement( self.reward_element ) then self.reward_element:destroy( ) end
			
			self.reward_element = ibCreateDummy()
			triggerEvent( "ShowTakeReward", self.reward_element, self.reward_element, self.rewards[ self.reward_id ].type, self.rewards[ self.reward_id ] )
	
			addEventHandler( "ShowTakeReward_callback", self.reward_element, function( data )
				if self.rewards[ self.reward_id ].type == "vinyl" then self.data = data end
				
				if self.rewards[ self.reward_id + 1 ] then
					self:show_next_reward()
				else
					self:success_trigger()
				end
			end )
		end,

		success_trigger = function( self, data )
			triggerServerEvent( "onServerPlayerTakeReward", resourceRoot, self.pack_id, self.data )
			self:destroy()
		end,

		destroy = function( self )
			if not IsUIActive() then
				showCursor( false )
			end
			if isElement( self.reward_element ) then 
				self.reward_element:destroy( ) 
			end

			setmetatable( self, nil )
			REWARD_INTERFACE = nil
		end,
	}

	REWARD_INTERFACE:init()
end
addEvent( "onClientShowRewardDoubleMayhem", true )
addEventHandler( "onClientShowRewardDoubleMayhem", resourceRoot, onClientShowRewardDoubleMayhem_handler )

function GetOffersConfig( )
	return OFFER_NAME_RU, OFFER_CONFIG.gift.params.model
end