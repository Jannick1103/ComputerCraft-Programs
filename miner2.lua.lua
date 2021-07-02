-- Konfiguration
print("==========================")
print("Willkommen bei Stripmining")
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

filter = {
    "minecraft:stone",
    "minecraft:andesite", 
    "minecraft:gravel",
    "minecraft:dirt"
}

port  = 5000
portP = 5001

-- SETUP
function SETUP() 
    distToHome, visitedBranches = 0, 0
    modem = peripheral.wrap("left")

    if not (modem == nil) then
        print("--------------------------------")
        print("Wireless Modem Support activated")
        print("Status Port: "..port)
        print("Prints Port: "..portP)
        print("--------------------------------")
        modem.open(port)
        modem.open(portP)
    end

    turtle.select(1)
    
    mprint()
    mprint("energySlot:   "..energySlot)
    mprint("mainLength:   "..mainLength)
    mprint("branchLength: "..branchLength)
    mprint("branchGap:    "..branchGap)
    mprint()
    
    mprint("Fuel Level: "..turtle.getFuelLevel())
    refuel()
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
    turnBack()
    oreType()
    turtle.down()
    oreType()
    turtle.turnRight()
end

function oreType()
    succes, data = turtle.inspect()
    if checkFilter(data.name) then
       mprint("found "..data.name)
       turtle.dig()
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
end

function inventoryCheck()    
end

function dumpInventory()
    mprint("dumping Inventory @ "..distToHome)
    for i=1, 16 do
        turtle.select(i)
        data = turtle.getItemDetail()
        if not (data == nil) and not (i == energySlot) then
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
            turtle.turnRight()
            carveBranch()
            carveBranch()
            turtle.turnLeft()
            dumpInventory()        
        end
        
        generalMove()
        if inventoryCheck() or checkFuel() then
            turnBack()
            for i=distToHome, 0, -1 do turtle.forward() end
            turnBack()
            for i=0, distToHome do turtle.forward() end
        end
    until distToHome >= mainLength
    
    dumpInventory()
    
    for back=mainLength, 0, -1 do 
        turtle.back()
    end
    
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
    if not (modem == nil) then
        modem.transmit(portP,portP,data)
    end
end

function transmitInfo()
    if not (modem == nil) then    
        modem.transmit(port,port,{
            {"Fuel:   ", turtle.getFuelLevel()},
            {"Dist:   ", distToHome},
            {"Branch: ", visitedBranches}
        })
    end
end

SETUP()
MAIN()