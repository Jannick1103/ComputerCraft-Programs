args = {...}

if args[1] ~= nil then
    fillFilter(args[1])
else
    shell.run("chooseOres.lua")
    fillFilter("ores")
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
end

filter = { }

port  = 5000
portP = 5001

function fillFilter(filename)
    if not fs.exists(filename) then
        print("ERROR: file with name: "..filename.." NOT found")
        return
    end
    local f = fs.open(filename, "r")
    while true 
        line = f.readLine()
        if line == nil then break end
        table.insert(filter, line)
    end
    f.close()
end

-- SETUP
function SETUP() 
    distToHome, visitedBranches = 0, 0
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

function turnBack()
    turtle.turnRight()
    turtle.turnRight()
    mprint("Turn Around @ "..distToHome..", "..visitedBranches)
end

function carveBranch()
    visitedBranches = visitedBranches + 1
    mprint("Entering Branch "..visitedBranches)
    for i=0, branchLength, 1 do
        generalMove()
        checkOres()
    end
    turnBack()
    for i=0, branchLength, 1 do
        while turtle.detect() do
            turtle.dig()
        end
        turtle.forward()
    end
    mprint("Leaving Branch")
end

function checkOres()
    turtle.turnRight()
    oreType()
    turtle.up()
	oreType()
    turnBack()
    oreType()
    turtle.down()
    oreType()
    turtle.turnRight()
end

function oreType(dir)
    succes, dataF = turtle.inspect()
    succes, dataD = turtle.inspectDown()
    succes, dataU = turtle.inspectUp()

    if checkFilter(dataF.name) then
       mprint("found Forward"..dataF.name)
       turtle.dig()
    end if checkFilter(dataD.name) then
        mprint("found Down"..dataD.name)
        turtle.digDown()
    end if checkFilter(dataU.name) then
        mprint("found Up"..dataU.name)
        turtle.digUp()
    end
end

function checkFilter(ore)
    for i=1, #filter do 
        if filter[i] == ore then return true end
    end
    return false        
end

function generalMove()
    turtle.dig()
    turtle.forward()
    turtle.digUp()
    transmitInfo()
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
    threshold = 0.75*64

    leftIndex = leftIndex or 0
    for i=1, 16 do
        turtle.select(i)
        data = turtle.getItemDetail()

        if data ~= nil and i ~= energySlot and i ~= leftIndex then
            if name ~= nil then --recursion mode
                if data.count < threshold then -- is there a slot there is enougth spaceleft
                    return true
                end
            else
                if data.count >= threshold then
                    if not inventoryCheck(data.name, i) then
                        return true
                    end
                end
            end
        end
    end
    return false
end

function dumpInventory(inChest)
    inChest = inChest or false
    mprint("dumping Inventory @ "..distToHome)
    for i=1, 16 do
        turtle.select(i)
        data = turtle.getItemDetail()

        if inChest then
            if not turtle.dropDown() then
                mprint("Chest is full: Halting until its clear")
                local  isClear
                repeat isClear = turtle.dropDown() until isClear
            else
                mprint("Inventory put in Chest")
            end
        elseif data ~= nil and i ~= energySlot then
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
        end
        
        generalMove()
        if inventoryCheck() then
            for i=0, distToHome do turtle.back() end
            dumpInventory(true)
            for i=0, distToHome do turtle.forward() end
        end
    until distToHome >= mainLength
    
    dumpInventory()
    
    for back=mainLength, 0, -1 do 
        turtle.back()
    end

    dumpInventory(true)
    
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
            {"Fuel:    ", turtle.getFuelLevel()},
            {"Dist:    ", distToHome},
            {"Branch:  ", visitedBranches}
        }
        for i=1, 16 do
            table.insert(info, {"Slot_"..i, turtle.getItemDetail(i)})
        end

        modem.transmit(port,port, info)
    end
end

SETUP()
MAIN()