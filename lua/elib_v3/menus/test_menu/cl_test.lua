//////////////////////
// Elib Test Menu
//////////////////////

////////////////
// Pages
////////////////
-- moved to separate files

////////////////
// Menu
////////////////
concommand.Add("elib_test", function()

    local frame = vgui.Create("Elib.Frame")
    frame:SetTitle("Elib Test Menu")
    frame:SetImageURL("https://i.imgur.com/WUtsRM9.png")
    frame:SetSize(Elib.Scale(900), Elib.Scale(600))
    //frame:SetSizable(true)
    frame:Center()
    frame:MakePopup()

    // Content
    local pages = {}
    local currentPage = 1

    local function changeTab()
        for k, page in pairs(pages) do
            page:SetVisible(k == currentPage)
        end
    end

    local page1 = vgui.Create("Elib.Test.Page1", frame)
    page1:Dock(FILL)
    page1:DockMargin(8, 8, 8, 8)
    pages[1] = page1

    local page2 = vgui.Create("Elib.Test.Page2", frame)
    page2:Dock(FILL)
    page2:DockMargin(8, 8, 8, 8)
    pages[2] = page2

    local page3 = vgui.Create("Elib.Test.Page3", frame)
    page3:Dock(FILL)
    page3:DockMargin(8, 8, 8, 8)
    pages[3] = page3

    changeTab()

    // Sidebar
    local sidebar = frame:CreateSidebar("Tab 1", "https://i.imgur.com/WUtsRM9.png", 1, -15, 5)

    sidebar:AddItem(1, "Welcome", "https://i.imgur.com/WUtsRM9.png", function(id) // (id, name, imageURL, doClick, order)
        currentPage = 1
        changeTab()
    end, 1)

    sidebar:AddItem(2, "Buttons", "https://i.imgur.com/WUtsRM9.png", function(id)
        currentPage = 2
        changeTab()
    end, 2)

    sidebar:AddItem(3, "Tab 3", "https://i.imgur.com/WUtsRM9.png", function(id)
        currentPage = 3
        changeTab()
    end, 3)

    // Open Animation
    frame:Open()
    
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