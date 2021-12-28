values = {
    "mass",
    "turnMass",
    "dragCoeff",
    "centerOfMass",
    "percentSubmerged",
    "tractionMultiplier",
    "tractionLoss",
    "tractionBias",
    "numberOfGears",
    "maxVelocity",
    "engineAcceleration",
    "engineInertia",
    "driveType",
    "engineType",
    "brakeDeceleration",
    "brakeBias",
    "ABS",
    "steeringLock",
    "suspensionForceLevel",
    "suspensionDamping",
    "suspensionHighSpeedDamping",
    "suspensionUpperLimit",
    "suspensionLowerLimit",
    "suspensionFrontRearBias",
    "suspensionAntiDiveMultiplier",
    "seatOffsetDistance",
    "collisionDamageMultiplier",
    "monetary",
    "headLight",
    "tailLight",
    "animGroup",
}

function table.copy( obj, seen )
    if type( obj ) ~= 'table' then
        return obj;
    end;

    if seen and seen[ obj ] then
        return seen[ obj ];
    end;

    local s         = seen or {};
    local res       = setmetatable( { }, getmetatable( obj ) );
    s[ obj ]        = res;

    for k, v in pairs( obj ) do
        res[ table.copy(k, s) ] = table.copy( v, s );
    end

    return res;
end