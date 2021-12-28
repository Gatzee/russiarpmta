BOOSTS_LIST = 
{
	{
		id = "ram",
		name = "Таран",
		desk = "Значительно увеличивает вес транспорта, что позволяет отталкивать машины в стороны не замечая их.",
		cost = 30000,
		cl_effect = function( pPlayer )
			local pVehicle = pPlayer.vehicle
			if pVehicle then
				local function HandleCollision( pElement, fForce )
					if pElement and isElement(pElement) and getElementType(pElement) == "vehicle" then
						local vecDirection = source.position - pElement.position
						vecDirection:normalize()

						pElement.velocity = pElement.velocity - vecDirection*( fForce/500 )
					end
				end
				addEventHandler("onClientVehicleCollision", pVehicle, HandleCollision)

				setTimer(function(veh)
					removeEventHandler("onClientVehicleCollision", veh, HandleCollision)
				end, 5000, 1, pVehicle)

				RemoveEffects( pVehicle, 5000 )
				triggerEvent( "RC:ApplyEffect", localPlayer, 2, pVehicle )

				if pPlayer == localPlayer then
					local sound = playSound(":nrp_races/files/sounds/juggernaut.ogg")
					setSoundPosition(sound, 0.3)
					SetBoosterCooldown( 1, 15 )
				end
			end
		end
	},

	{
		id = "nitro",
		name = "Нитро",
		desk = "Увеличивает ускорение транспорта в 2 раза",
		cost = 30000,
		cl_effect = function( pPlayer )
			local pVehicle = pPlayer.vehicle
			setTimer(function(veh)
				if not isElement( veh ) then return end

				local vecVelocity = veh.velocity
				vecVelocity:normalize()
				veh.velocity = veh.velocity + vecVelocity*0.03
			end, 200, 15, pVehicle)

			if pPlayer == localPlayer then
				SetBoosterCooldown( 2, 10, 3 )
			end

			RemoveEffects( pVehicle, 3000 )
			triggerEvent( "RC:ApplyEffect", localPlayer, 3, pVehicle )

			local sound = playSound3D(":nrp_races/files/sounds/nitro.wav", pVehicle.position)
			sound.dimension = localPlayer.dimension
			attachElements( sound, pVehicle )
		end
	},

	{
		id = "wave",
		name = "Волна",
		desk = "Инициирует ударную волну, отталкивающую соперников находящихся в радиусе 3 метров от твоего автомобиля",
		cost = 30000,
		cl_effect = function( pPlayer )
			local pSourceVehicle = pPlayer.vehicle
			for i, vehicle in pairs(getElementsWithinRange( pSourceVehicle.position, 30, "vehicle" )) do
				if vehicle ~= pSourceVehicle and vehicle.dimension == pSourceVehicle.dimension then
					local vecVelocity = vehicle.velocity
					local vecDirection = pSourceVehicle.position - vehicle.position
					vecDirection:normalize()
					vehicle.velocity = vecVelocity - vecDirection*0.5
				end
			end

			if pPlayer == localPlayer then
				SetBoosterCooldown( 3, 10 )
			end

			local sound = playSound3D(":nrp_races/files/sounds/blast_wave.wav", pSourceVehicle.position)
			sound.dimension = localPlayer.dimension
			attachElements( sound, pSourceVehicle )

			RemoveEffects( pSourceVehicle, 1500 )
			triggerEvent( "RC:ApplyEffect", localPlayer, 1, pSourceVehicle )
		end
	},

	{
		id = "slowmo",
		name = "Замедление",
		desk = "Резко замедляет ближайших оппонентов.",
		cost = 30000,
		cl_effect = function( pPlayer )
			SetBoosterCooldown( 4, 10, 3 )

			local pSourceVehicle = pPlayer.vehicle
			RemoveEffects( pSourceVehicle, 3000 )
			triggerEvent( "RC:ApplyEffect", localPlayer, 4, pSourceVehicle, true )

			for i, vehicle in pairs(getElementsWithinRange( pSourceVehicle.position, 30, "vehicle" )) do
				if vehicle ~= pSourceVehicle and vehicle.dimension == pSourceVehicle.dimension then
					local vecVelocity = vehicle.velocity
					vehicle.velocity = vecVelocity*0.75

					RemoveEffects( vehicle, 3000 )
					triggerEvent( "RC:ApplyEffect", localPlayer, 4, vehicle )
				end
			end

			local sound = playSound(":nrp_races/files/sounds/boost.wav")
			setSoundVolume(sound, 0.7)
		end
	},
}