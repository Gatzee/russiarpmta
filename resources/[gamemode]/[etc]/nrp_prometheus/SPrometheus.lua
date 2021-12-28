---------------
-- Main part --
---------------

-- Main grabber for all metrics. DO NOT REMOVE
loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "Globals" )

metric_grabber = MetricGrabber( )

-- List of objects to ask for metrics
objects = {
    PerformanceWatcher( ),
    PlayerWatcher( ),
    SQLWatcher( ),
}

-- Important magic
for i, v in pairs( objects ) do
    metric_grabber.add_object( v )
end

-- Exported function for web calls
function GetMetrics( )
    return metric_grabber.get_all_metrics_string( )
end