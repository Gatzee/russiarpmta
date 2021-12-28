function SwitchPosition_handler( )
    triggerEvent( "onTaxiPrivateFailWaiting", client, "Пассажир отменил заказ", "Ты зашёл в помещение, заказ в Такси отменен" )
end
addEvent( "SwitchPosition", true )
addEventHandler( "SwitchPosition", resourceRoot, SwitchPosition_handler )