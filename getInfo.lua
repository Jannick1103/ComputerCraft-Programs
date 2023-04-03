shell.run("clear")

side = {modem="back", display="top"}

arrowKeys = { 203, 205 }

print("Port number: default 3000")
port  = tonumber( read() ) -- 3000
print("PortPrint number: default 3001")
portP = tonumber( read() ) -- 3001

modem = peripheral.wrap(side.modem)
modem.open(port)
modem.open(portP)

display = peripheral.wrap(side.display)
if display == nil then
    display = term
end
 
display.clear()
display.setCursorPos(1,1)

Size = {display.getSize()}
Size = {x=Size[1], y=Size[2]}

temp_info = {}

function show(data)
    --print(data)
    display.setCursorPos(1, Size.y)
    display.write(data)
    display.scroll(1)
end
function insertToTemp(data)
    table.insert(temp_info, data)
end
function showInfo(data)
    index = 1
    for index=1, #data do 
        display.setCursorPos(1, index)
        display.write(data[index][1].." "..data[index][2])
    end
end

function getInfo()
    event = {os.pullEventRaw()}
    if event[1] == "modem_message" then 
        if event[3] == portP then
            insertToTemp(event[5])
            if not inInfoMode then
                show(event[5])
            end
        elseif event[3] == port and inInfoMode then
            showInfo(event[5])
        end
    elseif event[1] == "key_up" then
        if event[2] == arrowKeys[1] or event[2] == arrowKeys[2] then
            inInfoMode = not inInfoMode
            shell.run("clear")
            if inInfoMode then
                show(" InfoMode")
            else
                show(" PrintMode")
                os.sleep(0.5)
                dumpInfo()
            end
        end
    elseif event[1] == "terminate" then
        print("shutdown")
        shell.run("shutdown")
    end
end

function dumpInfo()
    for index=1, Size.y do 
        display.setCursorPos(1, index)
        display.write(temp_info[#temp_info-index] or " ")
        os.sleep(0.1)
    end
end

show()
show("Listening "..port..", "..portP)

inInfoMode = false

repeat getInfo() until false

show("Stopped")