
local get_cursor = love.mouse.getSystemCursor

cursors = {
    arrow = get_cursor("arrow"),
    ibeam = get_cursor("ibeam"),
    wait = get_cursor("wait"),
    waitarrow = get_cursor("waitarrow"),
    crosshair = get_cursor("crosshair"),
    hand = get_cursor("hand"),
    pan = love.mouse.newCursor("assets/mouse_pan.png",8,8),
    sizeew = get_cursor("sizewe"),
    sizens = get_cursor("sizens"),
    sizenesw = get_cursor("sizenesw"),
    sizenwse = get_cursor("sizenwse"),
    sizeall = get_cursor("sizeall"),
    no = get_cursor("no"),
}

function setCursor(curs)
    love.mouse.setCursor( cursors[curs] )
end

function love.mousepressed(x, y, button, istouch, presses)
    setCursor("arrow")
    if ui:mousepressed(x, y, button, istouch, presses) then
        return
    end

    app.context = nil
    local clickedRoom = false

    local mx, my = fromScreen(x, y)
    if button == 1 then
        if not app.toolMenuX then
            local oldActiveRoom = app.room
            for i, room in ipairs(project.rooms) do
                if mx >= room.x and mx <= room.x + room.w*8
                and my >= room.y and my <= room.y + room.h*8 then
                    clickedRoom = true

                    app.room = i
                    if app.room == oldActiveRoom then
                        break
                    end
                end
            end
            if app.room ~= oldActiveRoom then
                app.suppressMouse = true
                return
            end

            if love.keyboard.isDown("lalt") then
                if activeRoom() then
                    app.roomMoveX, app.roomMoveY = mx - activeRoom().x, my - activeRoom().y
                end
                return
            end
        end
    elseif button == 2 then
        if love.keyboard.isDown("lalt") and app.room then
            app.roomResizeSideX = sign(mx - activeRoom().x - activeRoom().w*8/2)
            app.roomResizeSideY = sign(my - activeRoom().y - activeRoom().h*8/2)
            return
        end
    end

    if button == 3
    or button == 1 and (love.keyboard.isDown("lshift") or not clickedRoom) then
        app.camMoveX, app.camMoveY = fromScreen(x, y)
        setCursor("pan")
    end

    --tool mousepressed
    app.tool:mousepressed(x, y, button)
end

function love.mousereleased(x, y, button, istouch, presses)
    ui:mousereleased(x, y, button, istouch, presses)
    -- note: mousereleased is not swallowed by nuklear windows, unlike mousepressed

    --tool mousereleased
    app.tool:mousereleased(x, y, button)

    app.camMoveX, app.camMoveY = nil, nil
    app.roomMoveX, app.roomMoveY = nil, nil
    app.roomResizeSideX, app.roomResizeSideY = nil, nil

    app.suppressMouse = false
    setCursor("arrow")

    -- just save history every time a mouse button is released lol
    pushHistory()
end

function love.mousemoved(x, y, dx, dy, istouch)
    if ui:mousemoved(x, y, dx, dy, istouch) then
        return
    end

    local mx, my = fromScreen(x, y)
    local ti, tj = div8(mx), div8(my)
    if app.camMoveX then
        app.camX = app.camX + mx - app.camMoveX
        app.camY = app.camY + my - app.camMoveY
    end
    if app.roomMoveX and app.room then
        local room=activeRoom()
        room.x = roundto8(mx - app.roomMoveX)
        room.y = roundto8(my - app.roomMoveY)
        if not room.hex then
            --can't move room stored in map outside of the map
            room.x = math.max(0, math.min(1024 - 8*room.w, room.x))
            room.y = math.max(0, math.min(512 - 8*room.h, room.y))
        end
    end

    --tool mousemoved
    app.tool:mousemoved(x, y, dx, dy)
end

function love.wheelmoved(x, y)
    -- this is an inelegant solution to the fact that some slut decided that scrollbars scroll even if the window isn't even hovered
    if app.anyWindowHovered then
        if ui:wheelmoved(x, y) then
            return
        end
    end

    if y ~= 0 then
        local mx, my = love.mouse.getPosition()
        rmx, rmy = fromScreen(mx, my)

        if y > 0 then
            app.camScaleSetting = app.camScaleSetting + 1
        elseif y < 0 then
            app.camScaleSetting = app.camScaleSetting - 1
        end
        app.camScaleSetting = math.min(math.max(app.camScaleSetting, -3), 20)
        app.camScale = app.camScaleSetting > 0 and (app.camScaleSetting + 1) or 2 ^ app.camScaleSetting

        nrmx, nrmy = fromScreen(mx, my)
        app.camX = app.camX + nrmx - rmx
        app.camY = app.camY + nrmy - rmy
    end

    if x ~= 0 then
        app.camX = app.camX - x*16
    end
end
