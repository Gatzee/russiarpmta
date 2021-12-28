-- local CHECK_INTERVAL = 24 * 60 * 60
-- CASE_SALE_DURATION = 14 * 24 * 60 * 60

-- UPDATING_CASES_POSITIONS = {
-- 	[ 2 ] = true, -- low
-- 	[ 4 ] = true, -- middle-1
-- 	[ 5 ] = true, -- high
-- 	[ 6 ] = true, -- middle-2
-- }

-- function RerollCases()
-- 	-- Подгружаем текущие данные напрямую из БД, т.к. MariaGet может вернуть старые данные
-- 	CommonDB:queryAsync( function( query )
-- 		local result = query:poll( -1 )
-- 		if result and #result > 0 then
-- 			-- Не юзаем getRealTimestamp, чтобы функция не срабатывала при тесте другого контента с setfaketime
-- 			local current_date = os.time( )
		
-- 			local cases_list = { }
-- 			for i, case_data in pairs( cases_info ) do
-- 				table.insert( cases_list, case_data )
-- 			end
-- 			table.sort( cases_list, function( a, b ) return ( a.temp_end or 0 ) < ( b.temp_end or 0 ) end )
		
-- 			local cases_to_update = { }
-- 			local current_temp_ends_by_position = { }
-- 			local cases_by_temp_start_by_position = { }
		
-- 			for i, case_data in pairs( cases_list ) do
-- 				local temp_end = case_data.temp_end
-- 				if temp_end then
-- 					if current_date > ( case_data.temp_start or 0 ) and temp_end > current_date then
-- 						current_temp_ends_by_position[ case_data.position ] = temp_end
-- 					end
		
-- 					if UPDATING_CASES_POSITIONS[ case_data.position ] then
-- 						if not cases_by_temp_start_by_position[ case_data.position ] then
-- 							cases_by_temp_start_by_position[ case_data.position ] = { }
-- 						end
-- 						-- На случай, если сейчас нет кейса в продаже в этой позиции
-- 						if not current_temp_ends_by_position[ case_data.position ] then
-- 							current_temp_ends_by_position[ case_data.position ] = temp_end
-- 						end
-- 						-- Учитываем кейсы, у которых дата старта смещена на воскресенье
-- 						local temp_start = temp_end - CASE_SALE_DURATION
-- 						cases_by_temp_start_by_position[ case_data.position ][ temp_start ] = case_data
-- 						if temp_end < current_date then
-- 							table.insert( cases_to_update, case_data )
-- 						end
-- 					end
-- 				end
-- 			end
		
-- 			for i, case_data in pairs( cases_to_update ) do
-- 				local next_temp_start = current_temp_ends_by_position[ case_data.position ]
-- 				if next_temp_start then
-- 					-- Двигаем дату старта вперёд на 2 недели, если она в прошлом или если на эту дату уже стоит другой кейс
-- 					while( next_temp_start < current_date or cases_by_temp_start_by_position[ case_data.position ][ next_temp_start ] ) do
-- 						next_temp_start = next_temp_start + CASE_SALE_DURATION
-- 					end
-- 					case_data.temp_start = next_temp_start
-- 					case_data.temp_end = next_temp_start + CASE_SALE_DURATION
-- 					cases_by_temp_start_by_position[ case_data.position ][ case_data.temp_start ] = case_data
		
-- 					case_data.is_new = nil
		
-- 					CommonDB:exec( 
-- 						"UPDATE f4_cases SET temp_start = ?, temp_end = ?, is_new = ? WHERE id = ?",
-- 						os.date( "%Y-%m-%d %H:%M:%S", case_data.temp_start ), os.date( "%Y-%m-%d %H:%M:%S", case_data.temp_end ), case_data.is_new, case_data.id 
-- 					)
-- 				end
-- 			end
-- 		end
-- 	end, { }, "SELECT * FROM f4_cases" )
-- end

-- setTimer( RerollCases, CHECK_INTERVAL * 1000, 0 )
-- RerollCases( )