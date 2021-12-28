
for job_class, job_data in pairs( JOB_DATA ) do
    job_data.conf_reverse = { }
    for k, v in pairs( job_data.conf ) do
        v.position = k
        v.id = job_data.company_name .. "_company_" .. k
        v.condition = function( player )
            if player:GetLevel( ) < v.level then
                return false, "Требуется " .. v.level .. "-й уровень!"
            end
            return true
        end
        v.condition_text = "Необходим " .. v.level .. "-й уровень"
        v.name = "В компании " .. ROMAN_NUMERALS[ k ]

    	job_data.conf_reverse[ v.id ] = v
    end
end

 function GetVehiclePositionsByJobId( job_id, city )
    return JOB_DATA[ job_id ].vehicle_data[ city ].positions
 end