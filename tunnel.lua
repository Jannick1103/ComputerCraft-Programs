args_mode, args_length = ...

shell.run("clear")

glass, stone, smooth = {}, {}, {}
rail, powered, torch, lamp = {}, {}, {}, {}

port  = 7070
portP = 7071

modem = peripheral.wrap("left")
print("modem Left Check")
if modem == nil then
    print("modem Right Check")
    modem = peripheral.wrap("right")
end

function getSlot(stack)
    item = stack[#stack]
    data = turtle.getItemDetail(item) or {name = " : ", count = "-1"}
    mprint("Sel["..item.."] "..data.count..", "..split(data.name, ":")[2])

    if turtle.getItemCount(item) <= 1 or item == nil then
        if #stack > 1 then
            table.remove(stack, #stack)
            mprint("removed one Item Stack")
        else 
            mprint("Not Enought Items")
            local _ = read()
            getItems()
        end
    end
    return item
end
function place(stack)
    turtle.select(getSlot(stack))
    turtle.place()
end

function getItems()
    glass, stone, smooth = {}, {}, {}
    rail, powered, torch, lamp = {}, {}, {}, {}

	for i=1, 16 do
        data = turtle.getItemDetail(i)
        if data ~= nil then
            if     data.name == "minecraft:glass"           then table.insert(glass, i)
            elseif data.name == "minecraft:stone"           then table.insert(stone, i)
            elseif data.name == "minecraft:smooth_stone"    then table.insert(smooth, i)
            elseif data.name == "minecraft:rail"            then table.insert(rail, i)
            elseif data.name == "minecraft:powered_rail"    then table.insert(powered, i)
            elseif data.name == "minecraft:redstone_torch"  then table.insert(torch, i)
            elseif data.name == "blockus:redstone_lamp_lit" then table.insert(lamp, i)
            end
        end
    end
end

function forward()
    while turtle.detect() do turtle.dig() end
    turtle.forward()
    transmitInfo()
end
function back()
    if not turtle.back() then
        turnBack()
        forward()
        turnBack()
    end
end
function down()
    while turtle.detectDown() do turtle.digDown() end
    turtle.down()
end
function up()
    while turtle.detectUp() do turtle.digUp() end
    turtle.up()
end
function turnBack()
    turtle.turnRight()
    turtle.turnRight()
end

function fwdClear()
    _, data = turtle.inspect()
    if data ~= nil then
        if data.name ~= "minecraft:stone" then
            turtle.dig()
            turtle.select(getSlot(stone))
            turtle.place()
        end
    end
end
function upClear()
    _, data = turtle.inspectUp()
    if data ~= nil then
        if data.name ~= "minecraft:stone" then
            turtle.digUp()
            turtle.select(getSlot(stone))
            turtle.placeUp()
        end
    end
end

function buildWater()
    forward()
    turtle.turnLeft()

    -- floor left part
    floor()
    floorplace("smooth_stone", smooth)

    -- Wall Up
    forward()
    wallUp()
    down()
    back()

    -- ceiling
    ceiling()
    forward()
    turnBack()
    down()
    turtle.select(getSlot(glass))
    turtle.placeUp()

    -- Wall Down
    wallDown()
    turnBack()
    forward()
    up()

    -- floor right part
    floor()
    turtle.turnRight()
end
function buildLand()
    forward()
    turtle.turnLeft()

    -- floor left part
    if turtle.detectUp() then turtle.digUp() end
    floorplace("smooth_stone", smooth)
    forward()
    
    if turtle.detectUp() then turtle.digUp() end
    floorplace("stone", stone)
    forward()

    if turtle.detectUp() then turtle.digUp() end
    floorplace("smooth_stone", smooth)

    -- Wall Up
    for i=1, 2 do
        fwdClear()
        up()
    end
    fwdClear()
    turnBack()
    
    -- ceiling
    for i=1, 4 do
        upClear()
        forward()
    end
    upClear()    
    
    -- Wall Down
    for i=1, 2 do
        fwdClear()
        down()
    end
    fwdClear()
    turnBack()

    -- floor right part
    floorplace("smooth_stone", smooth)
    forward()
    
    if turtle.detectUp() then turtle.digUp() end
    floorplace("stone", stone)
    forward()

    turtle.turnRight()
end
function clean()
    -- !!! NOT WORKING !!!
    for i=1, 3 do 
        for i=1, 2 do
            --frontWaterCleaner()()
            back()
        end

        --frontWaterCleaner()()
        turnBack()
        --frontWaterCleaner()()
        
        if i < 3 then up() end
    end
    turnBack()
    for i=1, 3 do 
        for i=1, 2 do
            --frontWaterCleaner()()
            back()
        end

        --frontWaterCleaner()()
        turnBack()
        --frontWaterCleaner()()
        
        if i < 3 then down() end
    end
    turtle.turnRight()
    forward()
    turtle.turnRight()
end

function floorplace(name, stack)
    _, data = turtle.inspectDown()
    if data ~= nil then
        if data.name ~= "minecraft:"..name then
            turtle.digDown()
            turtle.select(getSlot(stack))
            turtle.placeDown()
        end
    end
end
function floor()
    floorplace("smooth_stone", smooth)
    forward()

    floorplace("stone", stone)
    forward()
end
function wallUp()
    for i=1, 4 do
        if turtle.detect() then
            turtle.select( getSlot(stone) )
        else
            turtle.select( getSlot(glass) )
        end
        turtle.placeDown()
        while turtle.detectUp() do turtle.digUp() end
        turtle.up()
    end
end
function wallDown()
    for i=1, 3 do
        if turtle.detect() then
            turtle.select( getSlot(stone) )
        else
            turtle.select( getSlot(glass) )
        end
        down()
        turtle.placeUp()
    end
end
function ceiling()
    for i=1, 6 do
        place(glass)
        back()
    end
end

function placeLR(stack)
    forward()
    turtle.turnLeft()
    place(stack)
    turtle.turnRight()
    turtle.turnRight()
    place(stack)
    turtle.turnLeft()
end

function carveUnderWater()
    getItems()

    for i=1, length do
        buildWater()
        progress = 100*i/length
        transmitInfo()
    end
end
function carveTunnel()
    getItems()

    for i=1, length do
        buildLand()
        progress = 100*i/length
        transmitInfo()
    end
end
function railWork()
    sections = math.floor( length / 11 )

    getItems()

    for i=1, sections do
        placeLR(powered)
        placeLR(powered)

        turtle.digDown()
        turtle.select(getSlot(lamp))
        turtle.placeDown()
        
        placeLR(powered)

        turnBack()
        place(torch)
        turnBack()

        for j=1, 8 do
            placeLR(rail)
        end

        progress = 100*i/sections
        transmitInfo()
    end
end

function mprint(data)
    if data == nil then print() else print(data) end
    if modem ~= nil then
        modem.transmit(portP,portP, data)
    end
end
function transmitInfo()
    if modem ~= nil then    
        info = {
            {"Fuel:     ", turtle.getFuelLevel()},
            {"Progress: ", math.floor(progress)},
        }
        for i=1, 16 do
            data = turtle.getItemDetail(i) or {name = " : ", count = " "}
            table.insert(info, {i.." |", data.count.." "..split(data.name, ":")[2]})
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

print("Wähle den Baumodus: ")
print("1) Unterwasser-Bau")
print("2) Trocken-Bau")
print("3) Schienen-Bau")
print("====================")

if args_mode == nil then
    number = tonumber( read() )
else 
    number = tonumber( args_mode )
    print(number)
end

print("Länge der Bebauung")
if args_length == nil then
    length = tonumber( read() )
else 
    length = tonumber( args_length )
    print(length)
end
progress = 0

if     number == 1 then carveUnderWater()
elseif number == 2 then carveTunnel()
elseif number == 3 then railWork()
end