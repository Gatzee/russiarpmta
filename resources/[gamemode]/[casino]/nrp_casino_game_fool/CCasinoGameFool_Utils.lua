CARD_TEXTURES = { } 
 
function CardImageFile( card ) 
    local card_name = card[ 1 ] 
    local card_color = card[ 2 ] 
 
    local card_file = card_name .. "_" .. card_color 
    return "img/cards/" .. card_file ..".png"
end 

function GenerateFonts()
    fonts = {
        light_12 = exports.nrp_fonts:DXFont("OpenSans/OpenSans-Light.ttf", 12, false, "default"),
        regular_10 = exports.nrp_fonts:DXFont("OpenSans/OpenSans-Regular.ttf", 10, false, "default"),
        regular_12 = exports.nrp_fonts:DXFont("OpenSans/OpenSans-Regular.ttf", 12, false, "default"),
        bold_9 = exports.nrp_fonts:DXFont("OpenSans/OpenSans-SemiBold.ttf", 9, false, "default"),
        bold_10 = exports.nrp_fonts:DXFont("OpenSans/OpenSans-SemiBold.ttf", 10, false, "default"),
        bold_11 = exports.nrp_fonts:DXFont("OpenSans/OpenSans-SemiBold.ttf", 11, false, "default"),
        bold_12 = exports.nrp_fonts:DXFont("OpenSans/OpenSans-SemiBold.ttf", 12, false, "default"),
        bold_14 = exports.nrp_fonts:DXFont("OpenSans/OpenSans-SemiBold.ttf", 14, false, "default"),
        bold_16 = exports.nrp_fonts:DXFont("OpenSans/OpenSans-SemiBold.ttf", 16, false, "default"),
        bold_20 = exports.nrp_fonts:DXFont("OpenSans/OpenSans-SemiBold.ttf", 20, false, "default"),
    }
end

function isMouseWithinRangeOf( px, py, sx, sy)
    if not isCursorShowing() then return end
    local cx, cy = getCursorPosition()
    local x, y = guiGetScreenSize()
    cx, cy = cx * x, cy * y
    if cx >= px and cx <= px + sx and cy >= py and cy <= py + sy then
        return true, cx, cy
    else
        return false
    end
  end