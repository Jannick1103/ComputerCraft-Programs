function refuel() 
    turtle.select(16)
    turtle.refuel(1)
end

---------------

mainLength = 10
branchLength = 3
branchGap = 3

---------------

print(turtle.getFuelLevel())
--refuel()

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