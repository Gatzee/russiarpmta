local show = false
local x,y = guiGetScreenSize()
local px,py = math.max(x*0.1,250),50
local mem,rows,info,sh,tex = {},{},{},{},{}
local timers = {}

function renderStats()

  local todraw = { 
    ["Textures -> RES"] = tex,
    ["Shaders -> RES"] = sh, 
    ["GPU Information"] = info, 
    ["CPU 5s. Average"] = rows, 
    ["RES -> MEM"] = mem,
  }
    
  local rc = 0
  for row,data in pairs(todraw) do
    rc = rc + 1
    dxDrawText(row,px+230*(rc-1),py,px,py,tocolor(255,255,255,255),1.2,"default-bold","left","top",false,false,true,true)
    local ctr = 0
    for i,v in pairs(data) do
      ctr = ctr + 1
      local yy = py+ctr*20
      if yy < y then
        dxDrawText(tostring(i).." -> #ff55ff"..(type(v) == "table" and "#ffffff"..v[1].." -> #ffff00"..v[2] or tostring(v)),px+230*(rc-1),yy,px,py,tocolor(255,255,255,220),1,"default-bold","left","top",false,false,false,true)
      end
    end
  end
end

function updateAverage()
  local c,r = getPerformanceStats("Lua timing")
  local overall = 0
  for i,v in pairs(r) do
    if not v[2] or v[2] == "-" then
      r[i] = nil
    else
      overall = overall + tonumber(tostring(v[2]):sub(0,-2))
    end
  end
  table.sort(r,
    function(a,b) 
      local x = a and a[2] and tonumber(tostring(a[2]):sub(0,-2))
      local y = b and b[2] and tonumber(tostring(b[2]):sub(0,-2))
      return x and y and x > y
    end)
  table.insert(r,1,{"#00ff00Total usage: ",overall.."%"})

  rows = r
  local c,r = getPerformanceStats("Lua memory")
  for i,v in ipairs(r) do
    table.remove(v,2)
  end

  table.sort(r,
    function(a,b)
      local x = a and a[2] and tonumber(string.match(a[2],"%d+"))
      local y = b and b[2] and tonumber(string.match(b[2],"%d+"))
      return x and y and x > y
    end)

  mem = r
end

function updateInstant()
  local shaders = getElementsByType("shader")
  local shd = { }
  for i,v in ipairs(shaders) do
    local parent = getElementParent(v)
    local type = getElementType(parent)
    if type == "player" then
      parent = getPlayerName(parent)
    else
      parent = tostring(getElementID(getElementParent(parent)))
    end
    shd[parent] = (shd[parent] or 0) + 1
  end
  
  sh = shd

  local textures = getElementsByType("texture")
  local txd = { }
  for i,v in ipairs(textures) do
    local parent = getElementParent(v)
    local type = getElementType(parent)
    if type == "player" then
      parent = getPlayerName(parent)
    else
      parent = tostring(getElementID(getElementParent(parent)))
    end
    txd[parent] = (txd[parent] or 0) + 1
  end
  
  tex = txd
  
  
  local inf = dxGetStatus()
  for i,v in pairs(inf) do
    local lw = string.lower(i)
    if lw:gsub("mem","") == lw then
      inf[i] = nil
    else
      inf[i] = nil
      inf[i:gsub("VideoMemory","")] = v
    end
  end
  local streamedPlayers = #getElementsByType("player",root,true)
  local streamedVehicles = #getElementsByType("vehicle",root,true)
  table.insert(inf,1,{"Streamed players",streamedPlayers})
  table.insert(inf,1,{"Streamed vehicles",streamedVehicles})
  table.insert(inf,1,{"Shaders",#shaders})
  table.insert(inf,1,{"Textures",#textures})
  info = inf
  
end

function toggle()
  for k,v in ipairs(timers) do
    if isTimer(v) then
      killTimer(v)
    end
  end
  show = not show
  removeEventHandler("onClientRender",root,renderStats)
  if show then
    updateAverage()
    updateInstant()
    table.insert(timers,setTimer(updateAverage,500,0))
    table.insert(timers,setTimer(updateInstant,250,0))
    addEventHandler("onClientRender",root,renderStats,true,"low-10000")
  end
end
addCommandHandler("perfdebug",toggle)