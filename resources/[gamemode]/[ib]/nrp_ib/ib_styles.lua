_IB_STYLES = { }

function ibGetStyle( element, id )
    local tbl = _IB_STYLES[ _IB_ELEMENT_DATA[ element ].type ]
    return tbl[ id ]
end