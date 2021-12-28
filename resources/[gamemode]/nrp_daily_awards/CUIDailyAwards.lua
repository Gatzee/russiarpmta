loadstring( exports.interfacer:extend( "Interfacer" ) )()
Extend( "CPlayer" )
Extend( "ib" )

ibUseRealFonts( true )

local CONST_BLOCK_SIZE = 
{
	regular = { x = 200, y = 160, bx = 3, by = 3 },
	premium = { x = 400, y = 160, bx = 6, by = 2 },
}

function GenerateItemArea( block_size, r_type )
	local sx, sy = math.floor( CONST_BLOCK_SIZE[r_type].x / CONST_BLOCK_SIZE[r_type].bx * (block_size[1] or 1) ), math.floor( CONST_BLOCK_SIZE[r_type].y / CONST_BLOCK_SIZE[r_type].by * (block_size[2] or 1) )
	local area = ibCreateImage(0, 0, sx, sy, nil, false, 0x00FFFFFF):ibData("disabled", true)

	return area, sx, sy
end

function ConstructItemsBlock( items, r_type, step )
	local field = {}
	local bg = ibCreateImage( 0, 0, CONST_BLOCK_SIZE[r_type].x, CONST_BLOCK_SIZE[r_type].y, nil, false, 0x00FFFFFF)

	if #items == 1 then
		items[1].params.size = { 3, 3 }
		AddItemBlock( items[1], field, r_type )

		field[1].area:setParent( bg )
		field[1].area:center()

		field[1].area:ibData("py", -200)
		field[1].area:ibData("alpha", 0)

		field[1].area:ibTimer(function()
			local sx, sy = field[1].area:ibData("sx"), field[1].area:ibData("sy")

			field[1].area:ibMoveTo(CONST_BLOCK_SIZE[r_type].x/2 - sx/2, CONST_BLOCK_SIZE[r_type].y/2 - sy/2, 800, "OutBack")
			field[1].area:ibAlphaTo(255, 800)
		end, 200 * (step or 1), 1)
	else
		table.sort(items, function( a, b ) return ( POSSIBLE_ITEMS[a.class].block_priority or 0 ) > ( POSSIBLE_ITEMS[b.class].block_priority or 0 ) end )

		for _, v in pairs( items ) do
			AddItemBlock( v, field, r_type )
		end

		local sx, sy = math.floor( CONST_BLOCK_SIZE[r_type].x / CONST_BLOCK_SIZE[r_type].bx ), math.floor( CONST_BLOCK_SIZE[r_type].y / CONST_BLOCK_SIZE[r_type].by )

		local iTotalBlocksHorizontalSize = 0
		for _, v in pairs(field) do
			local end_pos = v.position[1]+v.size[1]-1
			if end_pos >= iTotalBlocksHorizontalSize then
				iTotalBlocksHorizontalSize = end_pos
			end
		end

		local iBias = CONST_BLOCK_SIZE[r_type].x / 2 - sx*iTotalBlocksHorizontalSize / 2

		SortBlocks(field, r_type)

		for _, v in pairs(field) do
			v.area:setParent( bg )

			v.area:ibData("px", CONST_BLOCK_SIZE[r_type].x/2-( sx*v.size[1] )/2)
			v.area:ibData("py", 0)
			v.area:ibData("alpha", 0)

			v.area:ibTimer(function()
				v.area:ibMoveTo(iBias + v.position[1] * sx - sx, v.position[2] * sy - sy, 800, "OutBack")
				v.area:ibAlphaTo(255, 800)
			end, 200 + 100 * (step or 1), 1)
		end
	end

	return bg
end

function SortBlocks( field, r_type )
	local field_blocks_state = {}
	for x = 1, CONST_BLOCK_SIZE[r_type].bx do
		field_blocks_state[x] = {  }
		for y = 1, CONST_BLOCK_SIZE[r_type].by do
			field_blocks_state[x][y] = 0
		end
	end

	for i, block in pairs(field) do
		local px, py = unpack(block.position)
		local sx, sy = unpack(block.size)

		for x = px, px+sx-1 do
			for y = py, py+sy-1 do
				if field_blocks_state[x] and field_blocks_state[x][y] then
					field_blocks_state[x][y] = 1
				end
			end
		end
	end

	local new_blocks = {}

	for k,v in pairs(field) do
		local bFree = true

		local start_y = v.position[2]+v.size[2]
		if start_y <= CONST_BLOCK_SIZE[r_type].by then
			if v.size[2] < CONST_BLOCK_SIZE[r_type].by then
				for y = start_y, CONST_BLOCK_SIZE[r_type].by do
					if field_blocks_state[v.position[1]][y] and field_blocks_state[v.position[1]][y] ~= 0 then
						bFree = false
					end
				end
			end

			if bFree then
				v.size[2] = CONST_BLOCK_SIZE[r_type].by
				new_blocks[k] = RefreshArea(v, r_type)
			end
		end
	end

	for k,v in pairs(new_blocks) do
		field[k].area:destroy()
		field[k] = nil

		field[k] = v
	end
end

function RefreshArea( block, r_type )
	block.item.params.size = block.size

	new_block = POSSIBLE_ITEMS[block.item.class]:func_draw( block.item.params, r_type )
	new_block.position = block.position
	return new_block
end

function AddItemBlock( item, field, r_type )
	local item_data = POSSIBLE_ITEMS[ item.class ]
	local new_block = item_data:func_draw( item.params, r_type )
	new_block.item = item

	local field_blocks_state = {}
	for x = 1, CONST_BLOCK_SIZE[r_type].bx do
		field_blocks_state[x] = {  }
		for y = 1, CONST_BLOCK_SIZE[r_type].by do
			field_blocks_state[x][y] = 0
		end
	end

	for i, block in pairs(field) do
		local px, py = unpack(block.position)
		local sx, sy = unpack(block.size)

		for x = px, px+sx-1 do
			for y = py, py+sy-1 do
				if field_blocks_state[x] and field_blocks_state[x][y] then
					field_blocks_state[x][y] = 1
				end
			end
		end
	end

	new_block.position = { math.ceil(CONST_BLOCK_SIZE[r_type].by / 2 ), 1 }

	local found = false

	if IsBlockFits( new_block, field_blocks_state, math.ceil(CONST_BLOCK_SIZE[r_type].by/2), 1 ) then
		found = true
	else
		for x = 1, CONST_BLOCK_SIZE[r_type].bx do
			if found then
				break
			end
			for y = 1, CONST_BLOCK_SIZE[r_type].by do
				if field_blocks_state[x][y] == 0 and IsBlockFits( new_block, field_blocks_state, x, y ) then
					new_block.position = { x, y }
					found = true
					break
				end
			end
		end
	end

	if found then
		table.insert(field, new_block)
	else
		new_block.area:destroy()
	end
end

function IsBlockFits( block, field, px, py )
	local sx, sy = unpack(block.size)

	for x = px, px+sx-1 do
		for y = py, py+sy-1 do
			if not field[x] or not field[x][y] or field[x][y] ~= 0 then
				return false
			end
		end
	end

	return true
end