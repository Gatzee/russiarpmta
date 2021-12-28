loadstring( exports.interfacer:extend( "Interfacer" ) )()
if localPlayer then
	Extend( "CPlayer" )
	Extend( "Globals" )
else
	Extend( "SPlayer" )
end
Extend( "ShClans" )

SHOP_ASSORTMENT =
{
	{ name = "Баллончик" , key = "spraycan", type = "weapon", id = 41, cost = 1500   , shop = "clanpanel" , shop_only = "clanpanel", unlock = UNLOCK_WEAPON_SPRAY_CAN , },
	{ name = "Макар"     , key = "pistol"  , type = "weapon", id = 22, cost = 18000  , shop = "clanpanel" , shop_only = "clanpanel", unlock = UNLOCK_WEAPON_GLOCK     , },
	{ name = "MP5"       , key = "mp5"     , type = "weapon", id = 29, cost = 84000  , shop = "dealer"    ,                          unlock = UNLOCK_WEAPON_MP5       , },
	{ name = "AK-47"     , key = "ak47"    , type = "weapon", id = 30, cost = 90000  , shop = "dealer"    ,                          unlock = UNLOCK_WEAPON_AK47      , },
	{ name = "Снайперка" , key = "sniper"  , type = "weapon", id = 34, cost = 108000 , shop = "dealer"    ,                          unlock = UNLOCK_WEAPON_SNIPER    , },
	{ name = "Дигл"      , key = "deagle"  , type = "weapon", id = 24, cost = 132000 , shop = "dealer"    ,                          unlock = UNLOCK_WEAPON_DEAGLE    , },
}

for i, v in pairs( DRUGS ) do
	if v.price then
		table.insert( SHOP_ASSORTMENT, 
			{ name = v.name, key = v.key, type = "drugs", id = i, cost = v.price, shop = v.shop or "clanpanel", shop_only = v.shop_only, unlock = v.unlock } 
		)
	end
end

Player.GetItemCost = function( player, item )
	local cost = item.cost
    if item.type == "drugs" then
        cost = cost * ( 1 - ( player:GetClanBuffValue( CLAN_UPGRADE_DRUGS_DISCOUNT ) + ( player:IsPremiumActive( ) and 15 or 0 ) ) / 100 )
    elseif item.type == "weapon" then
        cost = cost * ( 1 - ( player:GetClanBuffValue( CLAN_UPGRADE_WEAPON_DISCOUNT ) + ( player:IsPremiumActive( ) and 15 or 0 ) ) / 100 )
    end
    return math.ceil( cost - 0.5 )
end

function GetShopAssortment( player, shop_type )
	local items = { }

	for k, v in pairs( SHOP_ASSORTMENT ) do
		if not v.shop_only or v.shop_only == shop_type then
			local item = { }
			item.iid = k
			item.id = v.id
			item.name = v.name
			item.type = v.type
			item.cost = player:GetItemCost( v )
			item.img = v.type .. "_" .. v.id
			item.available = ( not shop_type or shop_type == v.shop ) --[[ and v.unlock and player:IsUnlocked( v.unlock ) ]] or false
			if not item.available then
				item.lock_hint = shop_type ~= v.shop and "Доступно только у барыги"
					-- or UNLOCK_NEED_RANKS[ v.unlock ] and "Доступно только c " .. ( UNLOCK_NEED_RANKS[ v.unlock ] + 1 ) .. " ранга"
			end

			table.insert( items, item )
		end
	end

	return items
end