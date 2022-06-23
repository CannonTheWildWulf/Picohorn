menu = {}

menulist = { "File", "Edit", "Selection", "View", "Room" }

MenuPanel = {}
function MenuPanel.load()
    menusizes = {}
    for i = 1, #menulist do
        table.insert(menusizes, app.font:getWidth(menulist[i])+32)
    end
end

function MenuPanel:panel()
    if ui:windowBegin("Menu", 0, 0, app.W, app.top) then
        ui:layoutRow("static", app.top-8, menusizes)
        local x = 0
        for i = 0, #menulist - 1 do
            x = x + (menusizes[i] or 0)
            local menu_string = menulist[i+1]
            local context = menu[menu_string]
            if ui:selectable( menu_string, app.context == context and context ~= nil) then
                if context then
                    app.context = context
                    app.context_x = x
                    app.context_y = app.top
                else
                    app.context = nil
                end
            end
        end
    end
    ui:windowEnd()
end

menu.File = {}
function menu.File:panel(ui, x, y)
    local item_height = 25*global_scale
    local width, height = app.W*0.1, 3*item_height

    if ui:windowBegin("filemenu", x, y, width, height) then
        app.contextHasFocus = ui:windowHasFocus()
        ui:layoutRow("dynamic", 25*global_scale, 1)
        
        if ui:selectable("Open...", false) then
            openFile()
        end
        if ui:selectable("Save", false) then
            saveFile(false)
        end
        if ui:selectable("Save As...", false) then
            saveFile(true)
        end

    end
    ui:windowEnd()

end

menu.Room = {}
function menu.Room:panel(ui, x, y)
    local item_height = 25*global_scale
    local width, height = app.W*0.1, 2*item_height

    if ui:windowBegin("roommenu", x, y, width, height) then
        app.contextHasFocus = ui:windowHasFocus()
        ui:layoutRow("dynamic", 25*global_scale, 1)
        
        if ui:selectable("New Room", false) then
            local x, y = fromScreen(app.W/3, app.H/3)
            local room = newRoom(roundto8(x), roundto8(y), 16, 16)

            room.title = ""

            table.insert(project.rooms, room)
            app.room = #project.rooms
            app.roomAdded = true
        end
        if ui:selectable("Delete Room", false) then
            if activeRoom() then
                table.remove(project.rooms, app.room)
                if not activeRoom() then
                    app.room = #project.rooms
                end
            end
        end

    end
    ui:windowEnd()

end
