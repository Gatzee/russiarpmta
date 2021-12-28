loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "ib" )

LOADED_TEXTURES = { }
START_LOADING_TEXTURES = { }

function RequestUpdateImageTexture( date, index, image, loading )
	local texture_path = "content/updates/" .. date .. "/" .. index .. ".png"
	Request( texture_path, image, loading )
end
addEvent( "RequestUpdateImageTexture" )
addEventHandler( "RequestUpdateImageTexture", root, RequestUpdateImageTexture )

function RequestContentImageTexture( content_type, content_id, width, height, image, loading )
	local texture_path = "content/" .. content_type .. "/" .. width .. "x" .. height .. "/" .. content_id .. ".png"
	Request( "content/" .. content_type .. "/" .. width .. "x" .. height .. "/" .. content_id .. ".png", image, loading )
end
addEvent( "RequestContentImageTexture" )
addEventHandler( "RequestContentImageTexture", root, RequestContentImageTexture )

function Request( texture_path, image, loading )
	if LOADED_TEXTURES[ texture_path ] then
		triggerEvent( "onClientContentImageLoad", resourceRoot, ":nrp_content/" .. texture_path, true )
		SetTexture( image, loading, texture_path )
		return
	end

	if START_LOADING_TEXTURES[ texture_path ] then
		table.insert( START_LOADING_TEXTURES[ texture_path ], { image, loading } )
	else
		START_LOADING_TEXTURES[ texture_path ] = { { image, loading } }
		if not downloadFile( texture_path ) then
			triggerEvent( "onClientContentImageLoad", resourceRoot, ":nrp_content/" .. texture_path, false )
			Debug( texture_path, 1 )
		end
	end
end

function onClientFileDownloadComplete_handler( texture_path, is_success )
	triggerEvent( "onClientContentImageLoad", resourceRoot, ":nrp_content/" .. texture_path, is_success )

	if not is_success then return end

	LOADED_TEXTURES[ texture_path ] = true

	if not START_LOADING_TEXTURES[ texture_path ] then return end

	local image, loading = nil, nil
	for i, data in pairs( START_LOADING_TEXTURES[ texture_path ] ) do
		image = data[ 1 ]
		loading = data[ 2 ]

		SetTexture( image, loading, texture_path )
	end
	START_LOADING_TEXTURES[ texture_path ] = nil
end
addEventHandler( "onClientFileDownloadComplete", resourceRoot, onClientFileDownloadComplete_handler )

function SetTexture( image, loading, texture )
	if not isElement( image ) or not isElement( loading ) then return end

	image:ibBatchData( { texture = ":nrp_content/" .. texture, color = 0xFFFFFFFF } )
	destroyElement( loading )
end