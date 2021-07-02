port  = 5000
portP = 5001

modem = peripheral.wrap("back")
modem.open(port)
modem.open(portP)

display = peripheral.wrap("right")
display.clear()
display.setCursorPos(2, 1)

prints = peripheral.wrap("left")
prints.clear()
prints.setCursorPos(1,1)

index = 1

function getInfo()
    data = {os.pullEvent("modem_message")}
   
    if data[3] == port then
        for key, val in next, data[5] do
            display.setCursorPos(2, index)
            display.write(val[1]..val[2])
            index = index + 1
        end
        index = 1
    elseif data[3] == portP then
        x, y = prints.getSize()
        prints.setCursorPos(1, y-1 )
        prints.write(data[5])
        prints.scroll(1)
    end
end

repeat getInfo() until false