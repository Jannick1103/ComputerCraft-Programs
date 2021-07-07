args = {...}

-- SETABLES
port  = 5000
portP = 5001
-- SETABLES

filter = {}
 
function fillFilter(filename)
    if not fs.exists("/"..filename..".lua") then
        print("ERROR: file with name: "..filename.." NOT found")
        return
    end
    local f = fs.open("/"..filename..".lua", "r")
    while true do
        line = f.readLine()
        if line == nil then break end
        table.insert(filter, line)
    end
    f.close()
end
 
if args[1] ~= nil then
    fillFilter(args[1])
else
    shell.run("chooseOres.lua")
    print("TURTLE STARTED SICH IN 5 SECS AUS")
    print("BITTE NEU STARTEN")
    shell.run("shutdown")
end
 
-- Konfiguration
print("==========================")
print("Willkommen bei Stripmining")
print("eine Chest muss UNTERHALB des Turtles sein")
print("Um dort die Erze abzulegen")
print()
print("Fuel oder Energiequellen Slot: [1;16]")
energySlot = tonumber(read())
if energySlot == nil then energySlot = 16 end
 
print("Laenge des Tunnels: [0;inf[")
mainLength = tonumber(read())
if mainLength == nil then mainLength = 5 end
 
print("Laenge der Zweige: [0;inf[")
branchLength = tonumber(read())
if branchLength == nil then branchLength = 3 end
 
print("Abstand zwischen den Zweigen: [1;inf[")
branchGap = tonumber(read())
if branchGap == nil then branchGap = 3 end
 
function refuel() 
    turtle.select(energySlot)
    turtle.refuel(1)
    turtle.select(1)
end
 
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
    mprint("Whitelisted Bloks: ")
    for i=1, #filter do mprint(filter[i]) end
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

        turtle.turnLeft()
        checkOres() -- check leftDown
        turnBack()
        checkOres() -- check rightDown
        turtle.turnLeft()
    end

    checkOres() -- check lastDown
    turtle.up()
    checkOres() -- check lastUp

    turnBack()
    for i=branchLength, 0, -1 do
        distInBranch = i
        forward()

        turtle.turnLeft()
        checkOres() -- check RightUp
        turnBack()
        checkOres() -- check leftUp
        turtle.turnLeft()
    end
    turtle.digDown()
    turtle.down()
    mprint("Leaving Branch")
end

function checkFilter(ore)
    for i=1, #filter do 
        if filter[i] == ore then return true end
    end
    return false        
end
function checkDown()
    succes, data = turtle.inspectDown()
    if succes and checkFilter(data.name) then
       mprint("found Down "..data.name)
       turtle.digDown()
       return true
    end
    return false
end
function checkUp()
    succes, data = turtle.inspectUp()
    if succes and checkFilter(data.name) then
       mprint("found Up "..data.name)
       turtle.digUp()
       return true
    end
    return false
end
function checkFwd()
    succes, data = turtle.inspect()
    if succes and checkFilter(data.name) then
       mprint("found Forward "..data.name)
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

    for i=0, 4 do
        turtle.turnLeft()
        checkReservoir_FWD()
    end
end

function checkFuel()
    turtle.select(energySlot)
    if turtle.getFuelLevel() <= 2 * 3*branchLength then
        if turtle.refuel() then
            mprint("refueled: "..turtle.getFuelLevel().." @ "..distToHome)
        else
            mprint("refuel: FAILED! @ "..distToHome)
            mprint("Self Halt until higher fuelLevel")
            local  isClear
            repeat 
                if turtle.getItemCount(energySlot) > 0 then
                    isClear = turtle.refuel()
                end            
            until isClear
        end
    end
    turtle.select(1)
end 
function inventoryCheck(name, leftIndex)
    mprint("Starting Inventory Check")
    threshold = 0.75*64
    
    leftIndex = leftIndex or 0
    for i=1, 16 do
        turtle.select(i)
        data = turtle.getItemDetail()
 
        if data ~= nil and i ~= energySlot and i ~= leftIndex then
            mprint(i.." "..data.name.." "..data.count)
            if name ~= nil then --recursion mode
                if data.name == name and data.count < threshold then -- is there a slot there is enougth spaceleft
                    mprint("R "..data.name.." "..data.count)
                    return true
                end
            else
                if data.count >= threshold then
                    mprint("over threshold")
                    if not inventoryCheck(data.name, i) then
                        return true
                    end
                end
            end
        end
    end
    turtle.select(1)
    return false
end
 
function dumpToChest()
    mprint("dumping Chest")
    for i=1, 16 do 
        turtle.select(i)
        if i ~= energySlot and turtle.getItemCount(i) ~= 0 then
            if not turtle.dropDown() then 
                mprint("Chest is full!")
                shell.run("shutdown")
            else
                mprint("Inventory put in Chest")
            end
        end
    end
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
        end
    end
    turtle.select(1)
end
 
function MAIN()
    repeat
        distToHome = distToHome + 1
                
        if math.mod(distToHome, branchGap+1) == 0 then
            checkFuel()
            turtle.turnRight()
            carveBranch()
 
            checkFuel()
            carveBranch()
            turtle.turnLeft()
            dumpInventory()        
 
            if inventoryCheck() then
                turnBack()
                for i=1, distToHome do forward() end
                dumpToChest()
                turnBack()
                for i=0, distToHome do forward() end
            end 
        end
        
        checkReservoir_DOWN() -- check floor of main tunnel

        generalMove()
    until distToHome >= mainLength
    
    dumpInventory()
    
    turnBack()
    turtle.up()
    for i=1, mainLength do
        checkReservoir_UP() -- check ceiling of main tunnel
        forward()
    end
    turnBack()
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
            {"Fuel:       ", turtle.getFuelLevel()},
            {"Dist:       ", distToHome},
            {"Branch Num: ", visitedBranches},
            {"Prog Main:  ", math.ceil(100*distToHome/mainLength).." %  "},
            {"Prog Branch:", math.ceil(100*distInBranch/branchLength).." %  "}
        }
        for i=1, 16 do
            data = turtle.getItemDetail(i) or {name = " : ", count = " "}
            table.insert(info, {"Slot_"..i.." |", data.count.." "..split(data.name, ":")[2]})
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