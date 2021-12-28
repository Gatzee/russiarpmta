REGISTERED_ITEMS = { }

function CheckRewardParams( reward_type, reward, ignore_errors )
    local pReward = REGISTERED_ITEMS[ reward_type ]
    if not pReward then
        if not ignore_errors then
            iprint("Несуществующий тип награды")
        end

        return false, "Несуществующий тип награды"
    end

    local params = reward.params or reward

    local sLostParam

    for k,v in pairs( pReward.available_params or {} ) do
        if v.required then
            if ( v.from_id and not params.id and not params[k] ) or ( not v.from_id and not params[k] ) then
                if not ignore_errors then
                    iprint( "Параметр "..k.." не найден. ( "..( v.desc or "" )..")" )
                end

                sLostParam = k.." ( "..( v.desc or "" ).." )"
            end
        end
    end

    if sLostParam then
        return false, "Не найден параметр: "..sLostParam
    end

    if pReward.IsValid then
        local bValid, sError = pReward:IsValid( reward )

        if not bValid then
            return false, sError
        end
    end

    return true
end

function CheckRewardsTable( rewards )
    if not rewards or type( rewards ) ~= "table" then 
        return false 
    end

    local pInvalidRewards = {}

    for k,v in pairs( rewards ) do
        local bValid, sError = CheckReward( v )
        if not bValid then
            table.insert( pInvalidRewards, "INDEX: "..k.."  TYPE: "..inspect(v.type).."  ERROR: "..sError )
        end
    end

    if #pInvalidRewards >= 1 then
        for k,v in pairs( pInvalidRewards ) do
            iprint( v )
        end

        return false
    end

    return true
end

function PrintRewardParams( reward_type )
    local pReward = REGISTERED_ITEMS[ reward_type ]
    if not pReward then return end

    outputConsole( "---------[ "..reward_type.." ]----------" )
    for k,v in pairs( pReward.available_params or {} ) do
        outputConsole( k.."     "..tostring( v.required or false ).."       "..( v.desc or "" ) )
    end
    outputConsole( "----------------------------" )
end

function CheckReward( item )
    local bParamsCheck, sParamsCheck = CheckRewardParams( item.type, item.params or item, true )

    if not bParamsCheck then
        return false, sParamsCheck
    end

    return true
end

-- Для расширения классов внутри ресурса
local _registered_items = { }
setmetatable( REGISTERED_ITEMS, {
    __index = _registered_items,
    __newindex = function( self, key, value )
        if not _registered_items[ key ] then
            _registered_items[ key ] = value
        else
            for k, v in pairs( value ) do
                _registered_items[ key ][ k ] = v
            end
        end
    end,
} )

Import( "rewards/Sh_AssemblDetail" )
Import( "rewards/ShAccessory" )
Import( "rewards/ShBox" )
Import( "rewards/ShCarEvac" )
Import( "rewards/ShCarSlot" )
Import( "rewards/ShCase" )
Import( "rewards/ShDance" )
Import( "rewards/ShExp" )
Import( "rewards/ShFirstaid" )
Import( "rewards/ShFuelcan" )
Import( "rewards/ShGunLicense" )
Import( "rewards/ShHard" )
Import( "rewards/ShJailkeys" )
Import( "rewards/ShLunchbox" )
Import( "rewards/ShNeon" )
Import( "rewards/ShNumberPlate" )
Import( "rewards/ShPhoneImg" )
Import( "rewards/ShPremium" )
Import( "rewards/ShRepairbox" )
Import( "rewards/ShSkin" )
Import( "rewards/ShSoft" )
Import( "rewards/ShTaxi" )
Import( "rewards/ShTuningCase" )
Import( "rewards/ShVehicle" )
Import( "rewards/ShVehicleLicense" )
Import( "rewards/ShVinyl" )
Import( "rewards/ShVinylCase" )
Import( "rewards/ShWeapon" )
Import( "rewards/ShWeddingBox" )
Import( "rewards/ShWofCoin" )
Import( "rewards/ShPack" )
Import( "rewards/ShInventoryExpand" )