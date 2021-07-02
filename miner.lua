-- Konfiguration
print("Willkommen bei Stripmining")
print("Der Fuel muss in Slot 16 platziert werden!")
print("Gebe die Laenge des Tunnels ein!")
mainLength = tonumber(read())

print("Gebe die Laenge der Zweige ein!")
branchLength = tonumber(read())

print("Gebe den Abstand zwischen den Zweigen ein!")
branchGap = tonumber(read())


---------------
function refuel() 
    turtle.select(16)
    turtle.refuel(1)
end

refuel()
print(turtle.getFuelLevel())


function carveBranch()
    for i=0, branchLength, 1 do
        generalMove()
        checkOres()
    end
    turtle.turnLeft()
    turtle.turnLeft()
    for i=0, branchLength, 1 do
        while turtle.detect() do
            turtle.dig()
        end
        turtle.forward()
    end    
end

function checkOres()
end

function generalMove()
    turtle.dig()
    turtle.forward()
    turtle.digUp()
end

function inventoryCheck()
end

function MAIN()
    for dist=1, mainLength, 1 do    
        if math.mod(dist, branchGap+1) == 0 then
            turtle.turnRight()
            carveBranch()
            carveBranch()
            turtle.turnLeft()        
        end
        
        generalMove()
    end
    turtle.turnLeft()
    turtle.turnLeft()
    for back=mainLength, 0, -1 do 
        turtle.forward()
    end
    print()
    print("minen erfolgreich abgeschlossen :)")
end

MAIN()