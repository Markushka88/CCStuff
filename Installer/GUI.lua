local XSize, YSize = term.getSize()
local ColorGray = colors.gray
local ColorLightGray = colors.lightGray
local ColorDownloadBack = colors.gray
local ColorDownloadFront = colors.lightBlue

function centerText(how,coord,text,textColor,backColor)
    term.setTextColor(textColor)
    term.setBackgroundColor(backColor)
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
    centerText("x",startingY,"Downloading"..action,ColorGray,colors.white)
    horisontalBar(startingX,startingY+2,size,ColorDownloadBack)
    horisontalBar(startingX,startingY+2,doneSize,ColorDownloadFront)
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
