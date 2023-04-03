args = {...}
 
-- SETABLES
port  = 5000
portP = 5001

threshold_ItemCount = 0.5 * 64
threshold_SpaceLeft = 3
-- SETABLES
 
filter = {}
chest_name = "!!! NO CHEST FOUND !!!"
 
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
 
if #args > 0 then
    for i=1, #args do
        fillFilter(args[i])
    end
else
    print("No ores detected, pls add a filename")
    print("in which oredata is stored")
    print("USE: 'chooseOres.lua' if unclear")
end

estimatedTimeLeft = 0
startTime = os.clock()

-- Konfiguration
print("==========================")
print("Willkommen bei Stripmining")
print("eine Chest muss HINTER der Turtle sein")
print("Um dort die Erze abzulegen")
print()
print("Fuel oder Energiequellen Slot: [1;16]")
print()
energySlot = tonumber(read())
if energySlot == nil then energySlot = 16 end

print("Laenge des Tunnels: [0;inf[")
print()
mainLength = tonumber(read())
if mainLength == nil then mainLength = 5 end

print("Laenge der Zweige: [0;inf[")
print()
branchLength = tonumber(read())
if branchLength == nil then branchLength = 3 end

print("Abstand zwischen den Zweigen: [1;inf[")
print()
branchGap = tonumber(read())
if branchGap == nil then branchGap = 3 end


-- SETUP
function SETUP() 
    distToHome, visitedBranches, distInBranch = 0, 0, 0
    turtle.select(1)
    
    modem = peripheral.wrap("left")
 
    if modem ~= nil then
        modem.open(port)
        modem.open(portP)
        mprint("--------------------------------")
        mprint("Wireless Modem Support activated")
        mprint("Status Port: "..port)
        mprint("Prints Port: "..portP)
        mprint()
    end
    
    mprint("--------------------------------")
    mprint("Whitelisted Blocks: ")
    for i=1, #filter do mprint(filter[i]) end
    mprint("--------------------------------")
    
    -- get Chest data
    turnBack()
    local chestSuccess, chestData = turtle.inspect()
    if chestSuccess then 
        chest_name = chestData.name 
    end
    turnBack()
    mprint("Chest name: "..chest_name)
    mprint("--------------------------------")
    
    mprint()
    mprint("energySlot:   "..energySlot)
    mprint("mainLength:   "..mainLength)
    mprint("branchLength: "..branchLength)
    mprint("branchGap:    "..branchGap)
    mprint()
    
    refuel()
    mprint("Fuel Level: "..turtle.getFuelLevel())
    mprint("--------------------------------")
end

function reCalcEstimatedTime()
    local deltaTime = os.clock() - startTime
    local estimatedTotalTime = deltaTime * mainLength / distToHome 
    estimatedTimeLeft = estimatedTotalTime - deltaTime
end

function formatTime( time ) 
    local sec = math.floor( math.fmod( time      , 60 ) )
    local min = math.floor( math.fmod( time/60   , 60 ) )
    local hr  = math.floor( math.fmod( time/3600 , 24 ) )
    return hr..":"..min..":"..sec
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
function generalMove()
    forward()
    turtle.digUp()
    transmitInfo()
end
 
function carveBranch()
    visitedBranches = visitedBranches + 1
    mprint("Entering Branch "..visitedBranches)
    for i=0, branchLength, 1 do
        distInBranch = i
        generalMove()
 
        checkOres() -- check leftDown then rightDown
    end
 
    turtle.up()
    checkOres() -- check lastUp
 
    turnBack()
    for i=branchLength, 0, -1 do
        distInBranch = i
        forward()
        transmitInfo()
 
        checkOres() -- check RightUp then leftUp
    end
    turtle.digDown()
    turtle.down()
    mprint("Leaving Branch")
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

function checkFilter(ore)
    for i=1, #filter do 
        if string.match( ore , filter[i] ) then return true end
    end
    __gatherBlockInfos(ore) -- no longer needed currently
    return false        
end
function checkDown()
    succes, data = turtle.inspectDown()
    if succes and checkFilter(data.name) then
       mprint("found Down "..split(data.name, ":")[2])
       turtle.digDown()
       return true
    end
    return false
end
function checkUp()
    succes, data = turtle.inspectUp()
    if succes and checkFilter(data.name) then
       mprint("found Up "..split(data.name, ":")[2])
       turtle.digUp()
       return true
    end
    return false
end
function checkFwd()
    succes, data = turtle.inspect()
    if succes and checkFilter(data.name) then
       mprint("found Forward "..split(data.name, ":")[2])
       turtle.dig()
       return true
    end
    return false
end
 
function checkReservoir_FWD()
    if checkFwd() then
        forward()
        checkOres()
        back()
    end
end
function checkReservoir_UP()
    if checkUp() then
        turtle.up()
        checkOres()
        turtle.down()
    end
end
function checkReservoir_DOWN()
    if checkDown() then
        turtle.down()
        checkOres()
        turtle.up()
    end
end
 
function checkOres()
    checkReservoir_FWD()
    checkReservoir_UP()
    checkReservoir_DOWN()
 
    for i=1, 4 do
        turtle.turnLeft()
        checkReservoir_FWD()
    end
end

function refuel()
    local prevSlot = turtle.getSelectedSlot()
    turtle.select(energySlot)
    local success = turtle.refuel(1)
    turtle.select(prevSlot)
    return success
end 
function checkFuel()
    if turtle.getFuelLevel() <= 2.5 * branchLength then
        if refuel() then
            mprint("refueled: "..turtle.getFuelLevel().." @ "..distToHome)
        else
            mprint("refuel: FAILED! @ "..distToHome)
            mprint("Self Halt until higher fuelLevel")
            local isClear
            repeat 
                if turtle.getItemCount(energySlot) > 0 then
                    isClear = refuel()
                end            
            until isClear
        end
    end
end

function inventoryCheck()
    mprint("Starting Inventory Check")
    
    local freespaceCount = 0
    for i=1, 16 do
        if i ~= energySlot then
            if turtle.getItemCount(i) == 0 then
                freespaceCount = freespaceCount + 1
            end
        end
    end
    
    return freespaceCount < threshold_SpaceLeft
end
function lookForSpaceLeft(itemName) -- not in use atm
    for i=1, 16 do
        if i ~= energySlot then
            local count = turtle.getItemCount(i)
            if count == 0 then 
                return true
            else
                data = turtle.getItemDetail(i)
                if data.name == itemName and count < threshold then
                    return true
                end
            end
        end
    end
    return false
end
 
function dumpToChest()
    mprint("dumping Chest")
    for i=1, 16 do 
        turtle.select(i)
        if i ~= energySlot and turtle.getItemCount(i) ~= 0 then
            if not turtle.drop() then 
                mprint("Chest is full!")
                mprint("HALTING until chest is cleared")
                while not turtle.drop() do end -- wait until turtle can drop
            end
        end
    end
    mprint("Inventory put in Chest")
    turtle.select(1)
end 
function dumpInventory()
    mprint("dumping Inventory @ "..distToHome)
    for i=1, 16 do
        turtle.select(i)
        data = turtle.getItemDetail()
 
        if data ~= nil and i ~= energySlot then
            if not checkFilter(data.name) then
                turtle.drop()
            end

            -- gathering Infos about block names
        end
    end
    turtle.select(1)
end

function compactInventory()
    for i=1, 16 do 
        data = turtle.getItemDetail(i)
        if data ~= nil then
            _inventoryComprimiser(i, data.name) -- accumulate items of this type up at this slot
        elseif i ~= energySlot then
            _inventoryCompactor(i) -- empty slot, shift most "right" item to this empty slot
        end
    end
    turtle.select(1)
end
function _inventoryComprimiser(toIndex, itemName)
    for i=toIndex+1, 16 do
        data = turtle.getItemDetail(i)
        if data ~= nil then
            if data.name == itemName then
                turtle.select(i)
                local isTransferSuccessfull = turtle.transferTo(toIndex)
                if not isTransferSuccessfull then
                    break -- slot(@toIndex) is full and cant hold anymore items
                end
            end
        end
    end
end
function _inventoryCompactor(toIndex)
    for i=toIndex+1, 16 do
        data = turtle.getItemDetail(i)
        if data ~= nil then
            turtle.select(i)
            turtle.transferTo(toIndex)
        end
    end
end

function goToChestAndBack()
    local inspect_name = nil
    local stepCounter  = 0

    turnBack()
    while true do 
        if turtle.detect() then
            temp = {turtle.inspect()}
            inspect_name = temp[2].name
            
            if inspect_name == chest_name then 
                break
            end
        end        
        forward()
        stepCounter = stepCounter + 1
    end
    dumpToChest()
    turnBack()
    for i=1, stepCounter do forward() end
end
 
function MAIN()
    repeat
        distToHome = distToHome + 1
                
        if math.mod(distToHome, branchGap+1) == 0 then
            checkFuel()
            turtle.turnRight()
            carveBranch()
            
            dumpInventory()
            compactInventory()
            if inventoryCheck() then
                turtle.turnRight() 
                goToChestAndBack()
                turtle.turnLeft()
            end 
            
            checkFuel()
            carveBranch()
            turtle.turnLeft()

            checkReservoir_DOWN()
            
            dumpInventory()
            compactInventory()
            if inventoryCheck() then goToChestAndBack() end 
        end
        
        checkReservoir_DOWN() -- check floor of main tunnel
 
        generalMove()
        reCalcEstimatedTime()
    until distToHome >= mainLength
    
    dumpInventory()
    
    turnBack()
    turtle.up()

    while true do
        if turtle.detectDown() then
            temp = {turtle.inspectDown()}
            if temp[2].name == chest_name then 
                break
            end
        end
        
        checkReservoir_UP() -- check ceiling of main tunnel
        forward()
    end
    turnBack()
    forward()
    turtle.down()
 
    dumpToChest()
    
    mprint()
    mprint("==================================")
    mprint("minen erfolgreich abgeschlossen :)")
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
function transmitInfo()
    if modem ~= nil then    
        info = {
            { "Fuel:       ", turtle.getFuelLevel().." " },
            { "Dist:       ", distToHome },
            { "Branch Num: ", visitedBranches },
            { "Prog (M/B): ", math.ceil(100*distToHome/mainLength).." %, "..math.ceil(100*distInBranch/branchLength).." % " },
            { "Remain Time:", formatTime( estimatedTimeLeft ) }
        }
        for i=1, 9 do
            data = turtle.getItemDetail(i) or { name = " : ", count = " " }
            table.insert( info, { "[ "..i.."] |", data.count.." "..split( data.name, ":" )[2] } )
        end
        for i=10, 16 do
            data = turtle.getItemDetail(i) or { name = " : ", count = " " }
            table.insert( info, { "["..i.."] |", data.count.." "..split( data.name, ":" )[2] } )
        end
 
        modem.transmit(port,port, info)
    end
end
 
function split(str, sep)
    local out = {}
    for s in string.gmatch(str, "([^"..sep.."]+)") do
        table.insert(out, s)
    end
    return out
end
 
SETUP()
MAIN()