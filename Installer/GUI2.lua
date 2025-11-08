local XSize, YSize = term.getSize()
local ColorGray = colors.lightBlue
local ColorLightGray = colors.lightGray
local ColorDownloadBack = colors.lightGray
local ColorDownloadFront = colors.blue

function centerText(how,coord,text,textColor,backColor)
    term.setTextColor(textColor)
    if backColor then
        term.setBackgroundColor(backColor)
    end
    if how == "xy" then
        term.setCursorPos(math.floor(XSize/2-#text/2),math.floor(YSize/2))
    elseif how == "x" then
        term.setCursorPos(math.floor(XSize/2-#text/2),coord)
    elseif how == "y" then
        term.setCursorPos(coord,math.floor(YSize/2))
    end
    term.write(text)
end

function horisontalBar(x,y,width,color)
    for i=x,(x+width-1) do
        paintutils.drawPixel(i,y,color)
    end
end

function progressBar(size,action,percent,action2)
    local doneSize = math.ceil(percent/100*size)
    local startingY = math.floor(YSize/2-1)
    local startingX = math.floor(XSize/2-size/2)
    horisontalBar(1,startingY,XSize,colors.white)
    centerText("x",startingY,"Installing update",colors.blue,colors.white)
    horisontalBar(startingX,startingY+2,size,ColorDownloadBack)
    horisontalBar(startingX,startingY+2,doneSize,ColorDownloadFront)
    centerText("x",startingY+4,"Done"..action,colors.black,colors.white)
end

function progressBar2(size,action,percent,action2)
    local doneSize = math.ceil(percent/100*size)
    local startingY = math.floor(YSize/2-1)
    local startingX = math.floor(XSize/2-size/2)
    horisontalBar(1,startingY,XSize,colors.white)
    centerText("x",startingY,action,ColorGray,colors.white)
    horisontalBar(startingX,startingY+2,size,colors.gray)
    horisontalBar(startingX,startingY+2,doneSize,colors.lightGray)
end
