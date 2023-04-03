args = {...}
 
-- SETABLES
port  = 5000
portP = 5001
-- SETABLES
 
filter = {}

function SETUP()
    if #args > 0 then
        for i=1, #args do
            fillFilter(args[i])
        end
    else
        shell.run("chooseOres")
        shell.run("chooseOres.lua")
        print("TURTLE STARTED IN 5 SECS NEU")
        shell.run("reboot")
    end
    
    -- Konfiguration
    print("==========================")
    print("Fuel oder Energiequellen Slot: [1;16]")
    print()
    energySlot = tonumber(read())
    if energySlot == nil then energySlot = 16 end

    print("Wähle den Testmodus: ")
    print("1) Scaning Ores")
    print("2) Testing matches")
    print("====================")
    selected = tonumber(read())
    
    function refuel() 
        turtle.select(energySlot)
        turtle.refuel(1)
        turtle.select(1)
    end
    refuel()
end
 
function forward()
    while turtle.detect() do
        turtle.dig()
    end
    turtle.forward()
end
function back()
    if not turtle.back() then
        turnBack()
        forward()
        turnBack()
    end
end
function turnBack()
    turtle.turnRight()
    turtle.turnRight()
end

function __gatherBlockInfos(oreName, _blockInfoFileName)
    _blockInfoFileName = _blockInfoFileName or "__blockInfo"

    oreFoundInDataBase = false
    if fs.exists("/".._blockInfoFileName) then
        local fr = fs.open("/".._blockInfoFileName, "r")
        while true do
            line = fr.readLine()
            if line == nil then 
                break 
            end
            if line == oreName then 
                oreFoundInDataBase = true
                break
            end
        end
        fr.close()

        if not oreFoundInDataBase then
            local fw = fs.open("/".._blockInfoFileName, "a") -- opens the BlockInfoFile and appends the ore
            fw.writeLine(oreName)
            fw.close()
        end
    else
        local fw = fs.open("/".._blockInfoFileName, "w") -- create a new BlockInfoFile and appends the ore
        fw.writeLine(oreName)
        fw.close()
    end
end
 
function mprint(data)
    if data == nil then  
        print()
    else
        print(data)
    end
    if modem ~= nil then
        modem.transmit(portP,portP,data)
    end
end
 
function split(str, sep)
    local out = {}
    for s in string.gmatch(str, "([^"..sep.."]+)") do
        table.insert(out, s)
    end
    return out
end

function fillFilter(filename)
    f = nil
    
    if fs.exists("/"..filename..".lua") then
        f = fs.open("/"..filename..".lua", "r")
    elseif fs.exists("/"..filename) then
        f = fs.open("/"..filename, "r")
    else 
        print("ERROR: file with name: "..filename.." NOT found")
        return
    end

    while true do
        line = f.readLine()
        if line == nil then 
            break 
        end
        table.insert(filter, line)
    end
    f.close()
end

function checkFilter(ore)
    for i=1, #filter do 
        if string.match( ore , filter[i] ) then return true end
    end
    __gatherBlockInfos(ore)
    return false        
end

function scanInventory()
    for i=1, 16 do
        turtle.select(i)
        data = turtle.getItemDetail()

        if data ~= nil and i ~= energySlot then
            mprint(i.." "..data.name.." "..data.count)
            __gatherBlockInfos( data.name )
        end
    end
end

function scanOres()
    while true do
        if turtle.detect() then
            temp = {turtle.inspect()}
            __gatherBlockInfos( temp[2].name )

            turtle.dig()
            scanInventory()
        end
    end
end

function testFilter()
    while true do
        if turtle.detect() then
            temp = {turtle.inspect()}
            mprint( "in Filter: "..temp[2].name.. " > " ..checkFilter( temp[2].name ) )
        end
    end
end


SETUP()

if     selected == 1 then scanOres()
elseif selected == 2 then testFilter()
end