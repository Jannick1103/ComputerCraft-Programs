
-- SETABLES
port  = 5000
portP = 5001
-- SETABLES

estimatedTimeLeft = 0
startTime = os.clock()
 
-- Konfiguration
print("==========================")
print("Willkommen beim Area clearer")
print("Die Turtle baut mit blöcken ein gegebenes Gebiet aus")
print()

print("Fuel oder Energiequellen Slot: [1;16]")
energySlot = tonumber(read())
if energySlot == nil then energySlot = 16 end
 
print("Laenge des Bereichs: [0;inf[")
print("Laengenkoordinate = Turtle forward")
length = tonumber(read())
if length == nil then length = 5 end

print("Breite des Bereichs: ]-inf;inf[")
print("Breitenkoordinate = Turtle Left")
width = tonumber(read())
if width == nil then width = 3 end

print("Höhe des Bereichs: ]-inf;inf[")
print("Höhenkoordinate = Turtle Up")
height = tonumber(read())
if height == nil then height = 3 end
 
-- SETUP
function SETUP()
    getSlot()
    
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
    
    mprint()
    mprint("energySlot: "..energySlot)
    mprint("length:     "..length)
    mprint("width:      "..width)
    mprint("height:     "..height)
    mprint()
    
    refuel()
    mprint("Fuel Level: "..turtle.getFuelLevel())
    mprint("--------------------------------")
end

function reCalcEstimatedTime( currentDistance, totalDistance )
    local deltaTime = os.clock() - startTime
    local totalTime = deltaTime * totalDistance / currentDistance
    estimatedTimeLeft = totalTime - deltaTime
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
function up()
    while turtle.detectUp() do
        turtle.digUp()
    end
    turtle.up()
end
function down()
    while turtle.detectDown() do
        turtle.digDown()
    end
    turtle.down()
end

function turnBack()
    turtle.turnRight()
    turtle.turnRight()
end

function refuel()
    local prevSlot = turtle.getSelectedSlot()
    turtle.select(energySlot)
    local success = turtle.refuel(1)
    turtle.select(prevSlot)
    return success
end 
function checkFuel()
    if turtle.getFuelLevel() <= 1.1 * length then
        if refuel() then
            mprint("refueled: "..turtle.getFuelLevel())
        else
            mprint("refuel: FAILED!")
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

function goVertical(isUp)
    if isUp then
        up()
    else
        down()
    end
end
function turnLeftOrRight(turnLeft)
    if turnLeft then
        turtle.turnLeft()
    else
        turtle.turnRight()
    end
end
function returnLeftOrRight(returnLeft)
    if returnLeft then
        turtle.turnLeft()
        back()
        place()
        turtle.turnLeft()
    else
        turtle.turnRight()
        back()
        place()
        turtle.turnRight()
    end
end

function getSlot()
    for i=1, 16 do
        if i ~= energySlot then
            if turtle.getItemCount(i) ~= 0 then
                turtle.select(i)
                break
            end
        end
    end
end
function place()
    if turtle.getItemCount() == 0 then getSlot() end
    turtle.place()
end
function placeDown()
    if turtle.getItemCount() == 0 then getSlot() end
    turtle.placeDown()
end


function buildLength()
    checkFuel()
    for l=2, length do
        back()
        place()
    end
end
function buildLengthAndBack(leftHanded)
    buildLength()
    returnLeftOrRight( leftHanded )
    buildLength()
    returnLeftOrRight( not leftHanded )
end

function buildWidth()
    leftHanded = width > 0
    absWidth = math.abs(width)

    turnBack()
    for w=1, round( absWidth / 2 ) - 1 do
        buildLengthAndBack( leftHanded )
        mprint("width finished: "..round( 100 * w/absWidth ).."%")
        reCalcEstimatedTime( w, absWidth )
        mprint("Estimated Time: "..textutils.formatTime( estimatedTimeLeft, true ))
    end

    if absWidth > 2 then
        buildLength()
        if math.mod( width, 2 ) == 1 then
            up()
            placeDown()

            for l=2, length do forward() end -- go back
            turnLeftOrRight( leftHanded )
        else
            returnLeftOrRight( leftHanded )
            buildLength()

            up()
            placeDown()
            
            turnLeftOrRight( not leftHanded )
            forward()
        end
    elseif absWidth == 2 then
        buildLength()
        returnLeftOrRight( leftHanded )
        buildLength()

        up()
        placeDown()

        turnLeftOrRight( not leftHanded )
    elseif absWidth == 1 then
        buildLength()

        up()
        placeDown()

        for l=2, length do forward() end -- go back
        turnLeftOrRight( leftHanded )
    end

    for w=2, absWidth do forward() end
    turnLeftOrRight( leftHanded )
    -- down()
end

function buildHeight()
    isUp = height > 0

    step = -1
    if isUp then 
        step = 1
    end
    
    for h=step, height, step do
        buildWidth()
        mprint("finished height "..h.." / "..height)
        goVertical( isUp )
    end
    for h=step, height, step do
        goVertical( not isUp )
    end
end


function MAIN()
    buildHeight()
    
    mprint()
    mprint("==================================")
    mprint("Bereich befreien erfolgreich abgeschlossen :)")
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

function round(num, numDecimalPlaces)
    resolution = numDecimalPlaces or 0
    local mult = 10^( math.abs(resolution) )
    return math.floor(num * mult + 0.5) / mult
end
 
SETUP()
MAIN()