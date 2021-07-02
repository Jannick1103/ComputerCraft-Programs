-- Konfiguration
print("Willkommen bei Stripmining")
print("Der Fuel muss in Slot 16 platziert werden!")
print("Gebe die Laenge des Tunnels ein!")
mainLength = tonumber(read())

print("Gebe die Laenge der Zweige ein!")
branchLength = tonumber(read())

print("Gebe den Abstand zwischen den Zweigen ein!")
branchGap = tonumber(read())

function refuel() 
    turtle.select(16)
    turtle.refuel(1)
end

---------------

energySlot = 16

filter = {
    "minecraft:stone",
    "minecraft:andesite", 
    "minecraft:gravel",
    "minecraft:dirt"
}

port = 5000

---------------

modem = peripheral.wrap("left")

turtle.select(1)

print(turtle.getFuelLevel())
refuel()

function turnBack()
    turtle.turnRight()
    turtle.turnRight()
end

function carveBranch()
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
        print("found "..data.name)
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
end

function inventoryCheck()
    
end

function dumpInventory()
    for i=1, 16 do
        turtle.select(i)
        data = turtle.getItemDetail()
        if not (data == nil) and not (i == energySlot) then
            print(data)
            if not checkFilter(data.name) then
                turtle.drop()
            end
        end
    end
end

function MAIN()
    for dist=1, mainLength, 1 do    
        if math.mod(dist, branchGap+1) == 0 then
            turtle.turnRight()
            carveBranch()
            carveBranch()
            turtle.turnLeft()
            dumpInventory()        
        end
        
        generalMove()
        if inventoryCheck() then
            turnBack()
            for i=dist, 0, -1 do turtle.forward() end
            turnBack()
            for i=0, dist do turtle.forward() end
        end
        --transmittInfo()
    end
    turnBack()
    for back=mainLength, 0, -1 do 
        turtle.forward()
    end
    print()
    print("minen erfolgreich abgeschlossen :)")
end

function transmittInfo()
    modem.open(port)
    modem.transmit(port,port,"test")
end


MAIN()