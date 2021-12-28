local sx, sy = guiGetScreenSize( )
local remoteUrl = "https://nextrp.ru/hints/" -- metadata.json
local localPath = "img/"
local imgSX, imgSY = 2100, 1300
local posX, posY = 0, 0
local availableImgs = { } -- "1.png", "2.png", ..., etc
local textures = { } -- example: ["1.png"] = mta texture element
local drawImgs = { } -- { name = "10.png", alpha = 0 }, ..., etc

if imgSX - sx > 0 then posX = - ( imgSX / 2 - sx / 2 ) else imgSX = sx end
if imgSY - sy > 0 then posY = - ( imgSY / 2 - sy / 2 ) else imgSY = sy end

function imageLoadedHandler( imgName )
    table.insert( drawImgs, { name = imgName, alpha = 0, counter = 0, stopCounter = false } )
end

function saveImage( imgName, data )
    local file = fileCreate( localPath .. imgName )
    fileWrite( file, data )
    fileClose( file )
end

function loadImage( imgName )
    if not fileExists( localPath .. imgName ) then
        fetchRemote( remoteUrl .. imgName, function ( data, error )
            if error ~= 0 then iprint( error ) return end

            if not textures then return end
            textures[imgName] = dxCreateTexture( data, "dxt5" )

            imageLoadedHandler( imgName )
            saveImage( imgName, data )
        end )

        return
    end

    if not isElement( textures[imgName] ) then
        textures[imgName] = dxCreateTexture( localPath .. imgName, "dxt5" )
    end

    imageLoadedHandler( imgName )
end

function getRandomImg( )
    if #availableImgs < 1 then return end

    return availableImgs[math.random( 1, #availableImgs )]
end

function nextImg( )
    local img = getRandomImg( )
    loadImage( img )
end

function renderBG( )
    local index = #drawImgs
    if index < 1 then return end

    local function drawDx( num, direction )
        local imgData = drawImgs[num]

        imgData.alpha = imgData.alpha + ( direction and 5 or - 5 )
        imgData.alpha = imgData.alpha > 255 and 255 or imgData.alpha
        imgData.alpha = imgData.alpha < 0 and 0 or imgData.alpha

        local imgData = drawImgs[num]
        local texture = textures[imgData.name]

        dxDrawImage( posX, posY, imgSX, imgSY, texture, 0, 0, 0, tocolor( 255, 255, 255, imgData.alpha ) )

        if imgData.stopCounter then return end

        imgData.counter = imgData.counter + 1
        if imgData.counter > 500 then
            nextImg( )
            imgData.stopCounter = true
        end
    end

    drawDx( index, true ) -- draw last img
    if index > 1 then drawDx( index - 1, false ) end -- draw pre last img
end

function destroyBG( )
    removeEventHandler( "onClientRender", root, renderBG )
    removeEventHandler( "onRegisterStart", root, destroyBG )
    removeEventHandler( "onClientPlayerNRPSpawn", localPlayer, destroyBG )

    for _, texture in pairs( textures ) do
        destroyElement( texture )
    end
    textures = nil
end

addEvent( "onRegisterStart", true )
addEventHandler( "onRegisterStart", root, destroyBG )

addEvent( "onClientPlayerNRPSpawn", true )
addEventHandler( "onClientPlayerNRPSpawn", localPlayer, destroyBG )

addEvent( "ShowInviteLoginUI", true )
addEventHandler( "ShowInviteLoginUI", root, destroyBG )

fetchRemote( remoteUrl .. "metadata.json", "start_images", function ( data, error )
    if error ~= 0 then iprint( error ) return end

    local array = fromJSON( data )
    if not array or not array.list then return end

    availableImgs = array.list

    addEventHandler( "onClientRender", root, renderBG )

    nextImg( )
end )