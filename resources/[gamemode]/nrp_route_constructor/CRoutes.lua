local pPoints = CROSSROAD_POINTS or {}
local pPossibleRoutes = POSSIBLE_ROUTES

function PointToVector( pointID )
	local pPoint = CROSSROAD_POINTS[pointID]
	return Vector3( pPoint.x, pPoint.y, pPoint.z )
end

function GetClosestPoint(x,y,z)
	local iPoint = 0
	local fLowerDistance = math.huge 
	for k,v in pairs(pPoints) do 
		local distance = (Vector3(x,y,z) - Vector3(v.x, v.y, v.z)).length 
		if distance < fLowerDistance then  
			fLowerDistance = distance 
			iPoint = k 
		end 
	end 
 
	return iPoint, fLowerDistance 
end

function GetPointPossibleWays( point, pUsedWays )
	local pUsedWays = pUsedWays or {}
	local result = {}

	for k,v in pairs(pRoutes or pPossibleRoutes) do
		if not pUsedWays[k] then
			if v[1] == point then
				table.insert(result, {point, v[2], k})
			elseif v[2] == point then
				table.insert(result, {point, v[1], k})
			end
		end
	end

	return result
end

function CalculateRouteFromPointToPoint( point1, point2 )
	local pCurrentRoute = {}
	local pUsedPoints = { [point1] = true }
	local iCurrentPoint = point1
	local iPointsPassed = 0
	table.insert(pCurrentRoute, point1)

	repeat
		local pWays = GetPointPossibleWays( iCurrentPoint )
		local fMinDistance = math.huge
		for k,v in pairs(pWays) do
			if not pUsedPoints[ v[2] ] then
				local vecCurrentPoint = PointToVector( iCurrentPoint )
				local vecTargetPoint = PointToVector( point2 )
				if point1 < 89 and point2 > 89 and iCurrentPoint < 89 then
					vecTargetPoint = PointToVector( 89 )
				elseif point1 > 89 and point2 < 89 and iCurrentPoint > 89 then
					vecTargetPoint = PointToVector( 89 )
				end

				local vecBetween = Vector3( (vecCurrentPoint.x + vecTargetPoint.x)/2, (vecCurrentPoint.y + vecTargetPoint.y)/2, (vecCurrentPoint.z + vecTargetPoint.z)/2 )

				local distance_to_target = ( vecBetween - Vector3( pPoints[ v[2] ].x, pPoints[ v[2] ].y, pPoints[ v[2] ].z ) ).length
				if distance_to_target < fMinDistance then
					fMinDistance = distance_to_target
					iCurrentPoint = v[2]
				end
			end
		end
		pUsedPoints[ iCurrentPoint ] = true
		table.insert(pCurrentRoute, iCurrentPoint)
		iPointsPassed = iPointsPassed + 1
	until
		iPointsPassed == 150 or iCurrentPoint == point2

	local pConvertedRoute = {}
	for k,v in pairs(pCurrentRoute) do
		table.insert( pConvertedRoute,  PointToVector( v ))
	end
	return pConvertedRoute
end

function CalculateRandomRoute( iStartPoint, fDistance, random_seed )
	local iCurrentPoint = iStartPoint
	local fTotalDistance = 0
	local pRoute = { PointToVector( iCurrentPoint ) }
	local pUsedPoints = { [iStartPoint] = true }
	local pUsedWays = {}

	local iBigIterations = 0
	local bDeadEnd = false

	repeat
		local pWays = GetPointPossibleWays( iCurrentPoint, pUsedWays )
		if #pWays == 0 then
			if random_seed then
				pWays = GetPointPossibleWays( iCurrentPoint )
			else
				bDeadEnd = true
				--iprint("DEAD END", iCurrentPoint)
				break
			end
		end
		local pUsedWay = pWays[ math_random( #pWays, random_seed ) ]
		local iNextPoint = pUsedWay[2]

		pUsedWays[ pUsedWay[3] ] = true

		fTotalDistance = fTotalDistance + (PointToVector(iCurrentPoint) - PointToVector(iNextPoint)).length
		iCurrentPoint = iNextPoint
		pUsedPoints[iCurrentPoint] = true

		if #pUsedWays >= 5 then
			for k,v in pairs(pUsedWays) do
				pUsedWays[k] = nil
				if #pUsedWays <= 5 then
					break
				end
			end
		end

		table.insert(pRoute, PointToVector( iCurrentPoint ))

		iBigIterations = iBigIterations + 1
	until
		fTotalDistance >= fDistance or iBigIterations >= 150


	if bDeadEnd then
		return CalculateRandomRoute( iStartPoint, fDistance, random_seed )
	end

	return pRoute, fTotalDistance
end

function math_random(size, seed)
	if seed then
		return math.floor( seed * 5 / 14 + size / 3 ) % size + 1
	else
		return math.random( 1, size )
	end
end

-- EXPORTED FUNCTIONS
function GetRandomRoute( x, y, z, fDistance, seed)
	local iStartPoint = GetClosestPoint(x,y,z)
	return CalculateRandomRoute( iStartPoint, fDistance, seed )
end

function GetRoute( x, y, z, x2, y2, z2 )
	local iStartPoint = GetClosestPoint(x,y,z)
	local iEndPoint = GetClosestPoint(x2,y2,z2)

	return  CalculateRouteFromPointToPoint( iStartPoint, iEndPoint )
end