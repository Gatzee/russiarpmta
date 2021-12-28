ACCESSORIES_FOR_DOWN_DAMAGE = {
    helmet_avg = true,
    m2_asce06 = true,
    helmet_black = true,
    m2_asce17 = true,
    m3_acse19 = true,
    m3_acse20 = true
}

Player.HasHelmet = function( self )
    local acc = ( self:getData( "accessories" ) or { } )[self.model] or { }
    return ( acc.head and ACCESSORIES_FOR_DOWN_DAMAGE[acc.head.id] ) or false
end