// Script made by Eve Haddox
// discord evehaddox


//////////////////////
// Elib Test Menu
//////////////////////

////////////////
// Menu
////////////////
local function CreateTestMenu()
    Elib.TestFrame = vgui.Create("Elib.Frame")
    Elib.TestFrame:SetTitle("Elib Test Menu")
    Elib.TestFrame:SetImageURL("https://construct-cdn.physgun.com/images/51bf125e-b357-42df-949c-2bffff7e8b6c.png")
    Elib.TestFrame:SetSize(Elib.Scale(900), Elib.Scale(600))
    //Elib.TestFrame:SetSizable(true)
    Elib.TestFrame:Center()
    Elib.TestFrame:SetRemoveOnClose(false)
    --Elib.TestFrame:SetCanFullscreen(false)

    // Content
    local pages = {}
    local currentPage = 1

    local function changeTab()
        for k, page in pairs(pages) do
            page:SetVisible(k == currentPage)
        end
    end

    local page1 = vgui.Create("Elib.Test.Page1", Elib.TestFrame)
    page1:Dock(FILL)
    page1:DockMargin(8, 8, 8, 8)
    pages[1] = page1

    local page2 = vgui.Create("Elib.Test.Page2", Elib.TestFrame)
    page2:Dock(FILL)
    page2:DockMargin(8, 8, 8, 8)
    pages[2] = page2

    local page3 = vgui.Create("Elib.Test.Page3", Elib.TestFrame)
    page3:Dock(FILL)
    page3:DockMargin(8, 8, 8, 8)
    pages[3] = page3

    local page4 = vgui.Create("Elib.Test.Page4", Elib.TestFrame)
    page4:Dock(FILL)
    page4:DockMargin(8, 8, 8, 8)
    pages[4] = page4

    local page5 = vgui.Create("Elib.Test.Page5", Elib.TestFrame)
    page5:Dock(FILL)
    page5:DockMargin(8, 8, 8, 8)
    pages[5] = page5

    local page6 = vgui.Create("Elib.Test.Page6", Elib.TestFrame)
    page6:Dock(FILL)
    page6:DockMargin(8, 8, 8, 8)
    pages[6] = page6

    local page7 = vgui.Create("Elib.Test.Page7", Elib.TestFrame)
    page7:Dock(FILL)
    page7:DockMargin(8, 8, 8, 8)
    pages[7] = page7

    local page8 = vgui.Create("Elib.Test.Page8", Elib.TestFrame)
    page8:Dock(FILL)
    page8:DockMargin(8, 8, 8, 8)
    pages[8] = page8

    local page9 = vgui.Create("Elib.Test.Page9", Elib.TestFrame)
    page9:Dock(FILL)
    page9:DockMargin(8, 8, 8, 8)
    pages[9] = page9

    local page10 = vgui.Create("Elib.Test.Page10", Elib.TestFrame)
    page10:Dock(FILL)
    page10:DockMargin(8, 8, 8, 8)
    pages[10] = page10

    local page11 = vgui.Create("Elib.Test.Page11", Elib.TestFrame)
    page11:Dock(FILL)
    page11:DockMargin(8, 8, 8, 8)
    pages[11] = page11

    local page12 = vgui.Create("Elib.Test.Page12", Elib.TestFrame)
    page12:Dock(FILL)
    page12:DockMargin(8, 8, 8, 8)
    pages[12] = page12

    local page13 = vgui.Create("Elib.Test.Page13", Elib.TestFrame)
    page13:Dock(FILL)
    page13:DockMargin(8, 8, 8, 8)
    pages[13] = page13

    local pageData = {
        {name = "Welcome", icon = "https://construct-cdn.physgun.com/images/1e154095-79b2-436e-80a3-cb6b924d14a2.png"},
        {name = "Buttons", icon = "https://construct-cdn.physgun.com/images/2dea4a43-79f1-4025-a6a6-9aaf059214e9.png"},
        {name = "Toggles", icon = "https://construct-cdn.physgun.com/images/2dea4a43-79f1-4025-a6a6-9aaf059214e9.png"},
        {name = "Text Entries", icon = "https://construct-cdn.physgun.com/images/2dea4a43-79f1-4025-a6a6-9aaf059214e9.png"},
        {name = "Binds", icon = "https://construct-cdn.physgun.com/images/2dea4a43-79f1-4025-a6a6-9aaf059214e9.png"},
        {name = "Color Picker", icon = "https://construct-cdn.physgun.com/images/2dea4a43-79f1-4025-a6a6-9aaf059214e9.png"},
        {name = "Avatar", icon = "https://construct-cdn.physgun.com/images/2dea4a43-79f1-4025-a6a6-9aaf059214e9.png"},
        {name = "Menu", icon = "https://construct-cdn.physgun.com/images/2dea4a43-79f1-4025-a6a6-9aaf059214e9.png"},
        {name = "Navbar", icon = "https://construct-cdn.physgun.com/images/2dea4a43-79f1-4025-a6a6-9aaf059214e9.png"},
        {name = "Property Sheet", icon = "https://construct-cdn.physgun.com/images/2dea4a43-79f1-4025-a6a6-9aaf059214e9.png"},
        {name = "Scroll Panel", icon = "https://construct-cdn.physgun.com/images/2dea4a43-79f1-4025-a6a6-9aaf059214e9.png"},
        {name = "Categories", icon = "https://construct-cdn.physgun.com/images/2dea4a43-79f1-4025-a6a6-9aaf059214e9.png"},
        {name = "Graphs", icon = "https://construct-cdn.physgun.com/images/2dea4a43-79f1-4025-a6a6-9aaf059214e9.png"},
    }

    // Sidebar
    local sidebar = Elib.TestFrame:CreateSidebar("Tab 1", "https://construct-cdn.physgun.com/images/5cfb8931-ed9d-4efe-a16b-7e9cc7c0952a.png", .8, -5, 15)

    for i = 1, #pageData do
        sidebar:AddItem(i, pageData[i].name, pageData[i].icon, function(id)
            currentPage = i
            changeTab()
        end, i)
    end

    sidebar:SelectItem(1)

    Elib.TestFrame:MakePopup()
end

if IsValid(Elib.TestFrame) then Elib.TestFrame:Remove() CreateTestMenu() end

concommand.Add("elib_test", function()

    if not IsValid(Elib.TestFrame) then
        CreateTestMenu()
        return
    end
    if not IsValid(Elib.TestFrame) then return end
    if Elib.TestFrame:IsVisible() then
        Elib.TestFrame:Close()
    else
        // Open With Animation
        --Elib.TestFrame:Open()
        Elib.TestFrame:MakePopup() -- it has open
    end
    
end)

//////////////////////
// Overlay Test
//////////////////////

local function createDockingOverlayExample()
    -- Create the parent panel
    local parent = vgui.Create("DFrame")
    parent:SetSize(400, 300)
    parent:Center()
    parent:MakePopup()
    parent.Paint = function(self, w, h)
        surface.SetDrawColor(100, 100, 100, 255)
        surface.DrawRect(0, 0, w, h)
    end

    -- Add some children to the parent
    local child1 = vgui.Create("DPanel", parent)
    child1:Dock(TOP) -- Docked at the top
    child1:SetTall(50)
    child1.Paint = function(self, w, h)
        surface.SetDrawColor(150, 150, 255, 255)
        surface.DrawRect(0, 0, w, h)
    end

    local child2 = vgui.Create("DPanel", parent)
    child2:Dock(FILL) -- Fills remaining space
    child2.Paint = function(self, w, h)
        surface.SetDrawColor(150, 255, 150, 255)
        surface.DrawRect(0, 0, w, h)
    end

    -- Add the overlay panel
    local overlay = vgui.Create("DPanel", parent)
    overlay:Dock(FILL) -- Fully overlays the parent
    overlay:SetZPos(9999) -- Ensure it renders above all other children
    overlay.Paint = function(self, w, h)
        surface.SetDrawColor(255, 150, 150, 200) -- Semi-transparent red overlay
        surface.DrawRect(0, 0, w, h)

        draw.SimpleText("Overlay Panel", "Default", w / 2, h / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    -- Make the overlay "click-through" (optional)
    overlay:SetMouseInputEnabled(false)
end

concommand.Add("docking_overlay_example", createDockingOverlayExample)