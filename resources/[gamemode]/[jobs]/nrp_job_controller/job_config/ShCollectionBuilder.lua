

for job_class, job_data in pairs( JOB_DATA ) do
    job_data.conf_reverse = { }
    for i, v in pairs( job_data.conf ) do
        v.position = i
        v.tasks = { }
        job_data.conf_reverse[ v.id ] = v
    end
    
    job_data.tasks_reverse = { }
    for i, v in pairs( job_data.tasks ) do
        v.position = i
        job_data.tasks_reverse[ v.id ] = v
        job_data.conf_reverse[ v.company ].tasks[ v.id ] = v
    end
end