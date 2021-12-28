local file = fileOpen( "input.lua" )
loadstring( fileRead( file, fileGetSize( file ) ) )()
fileClose( file )

id = 1

local vIdentifierFound = false

handlingLimits = { 
    ["identifier"] = {
        id = 1,
        input = "string",
        limits = { "", "" },
    },
    ["mass"] = {
        id = 2,
        input = "float",
        limits = { "1.0", "100000.0" }
    },
    ["turnMass"] = {
        id = 3,
        input = "float",
        limits = { "0.0", "1000000.0" }
    },
    ["dragCoeff"] = {
        id = 4,
        input = "float",
        limits = { "0.0", "200.0" }
    },
    ["centerOfMassX"] = {
        id = 5,
        input = "float",
        limits = { "-10", "10" }
    },
    ["centerOfMassY"] = {
        id = 6,
        input = "float",
        limits = { "-10", "10" }
    },
    ["centerOfMassZ"] = {
        id = 7,
        input = "float",
        limits = { "-10", "10" }
    },
    ["percentSubmerged"] = {
        id = 8,
        input = "integer",
        limits = { "1", "120" }
    },
    ["tractionMultiplier"] = {
        id = 9,
        input = "float",
        limits = { "0.0", "100000.0" }
    },
    ["tractionLoss"] = {
        id = 10,
        input = "float",
        limits = { "0.0", "100.0" }
    },
    ["tractionBias"] = {
        id = 11,
        input = "float",
        limits = { "0.0", "1.0" }
    },
    ["numberOfGears"] = {
        id = 12,
        input = "integer",
        limits = { "1", "5" }
    },
    ["maxVelocity"] = {
        id = 13,
        input = "float",
        limits = { "0.1", "200000.0" }
    },
    ["engineAcceleration"] = {
        id = 14,
        input = "float",
        limits = { "0.0", "100000.0" }
    },
    ["engineInertia"] = {
        id = 15,
        input = "float",
        limits = { "-1000.0", "1000.0" }
    },
    ["driveType"] = {
        id = 16,
        input = "string",
        limits = { "", "" },
        options = { "f","r","4" }
    },
    ["engineType"] = {
        id = 17,
        input = "string",
        limits = { "", "" },
        options = { "p","d","e" }
    },
    ["brakeDeceleration"] = {
        id = 18,
        input = "float",
        limits = { "0.1", "100000.0" }
    },
    ["brakeBias"] = {
        id = 19,
        input = "float",
        limits = { "0.0", "1.0" }
    },
    ["ABS"] = {
        id = 20,
        input = "boolean",
        limits = { "", "" },
        options = { "true","false" }
    },
    ["steeringLock"] = {
        id = 21,
        input = "float",
        limits = { "0.0", "360.0" }
    },
    ["suspensionForceLevel"] = {
        id = 22,
        input = "float",
        limits = { "0.0", "100.0" }
    },
    ["suspensionDamping"] = {
        id = 23,
        input = "float",
        limits = { "0.0", "100.0" }
    },
    ["suspensionHighSpeedDamping"] = {
        id = 24,
        input = "float",
        limits = { "0.0", "600.0" }
    },
    ["suspensionUpperLimit"] = {
        id = 25,
        input = "float",
        limits = { "-50.0", "50.0" }
    },
    ["suspensionLowerLimit"] = {
        id = 26,
        input = "float",
        limits = { "-50.0", "50.0" }
    },
    ["suspensionFrontRearBias"] = {
        id = 27,
        input = "float",
        limits = { "0.0", "1.0" }
    },
    ["suspensionAntiDiveMultiplier"] = {
        id = 28,
        input = "float",
        limits = { "0.0", "30.0" }
    },
    ["seatOffsetDistance"] = {
        id = 29,
        input = "float",
        limits = { "0.0", "20.0" }
    },
    ["collisionDamageMultiplier"] = {
        id = 30,
        input = "float",
        limits = { "0.0", "100.0" }
    },
    ["monetary"] = {
        id = 31,
        input = "integer",
        limits = { "0", "230195200" }
    },
    ["headLight"] = {
        id = 34,
        input = "integer",
        limits = { "0", "3" },
        options = { 0,1,2,3 }
    },
    ["tailLight"] = {
        id = 35,
        input = "integer",
        limits = { "0", "3" },
        options = { 0,1,2,3 }
    },
    ["animGroup"] = {
        id = 36,
        input = "integer",
        limits = { "0", "30" }
    }
}

propertyID = {}
for k,v in pairs ( handlingLimits ) do
    propertyID[v.id] = k
end

function getHandlingPropertyNameFromID ( id )
    id = tonumber ( id )
    
    if not id then
        return false
    end
    
    return propertyID[id]
end

function stringToValue ( property, value )
    if property == "ABS" then
        return value
    end

    if property == "driveType" then
      if tonumber(value) then value = "a" end
      return "\"".. value .."wd\""
    end

    if property == "engineType" then
      return value == "p" and "\"petrol\"" or "\"diesel\""
    end
    
    if property == "driveType" or property == "engineType" then
        return value
    end
    
    return tonumber ( value ) or value
end

file_str = ""

for value in string.gmatch( handlingLine, "[^%s]+" ) do
  if not vIdentifierFound and tonumber( value ) then
    vIdentifierFound = true
  end
    
  if vIdentifierFound then
    id = id + 1
    local property = getHandlingPropertyNameFromID ( id )
    if property then
        file_str = file_str .. "\n" .. property .. " = ".. stringToValue ( property, value ) .. ";"
    end
  end
end

local file = fileCreate( "output.lua" )
fileWrite( file, file_str )
fileClose( file )

--iprint( getTickCount(), "File saved to: output.lua" )