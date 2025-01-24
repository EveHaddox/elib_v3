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
if IsValid(Elib.TestFrame) then Elib.TestFrame:Remove() end

Elib.TestFrame = vgui.Create("Elib.Frame")
Elib.TestFrame:SetTitle("Elib Test Menu")
Elib.TestFrame:SetImageURL("https://construct-cdn.physgun.com/images/51bf125e-b357-42df-949c-2bffff7e8b6c.png")
Elib.TestFrame:SetSize(Elib.Scale(900), Elib.Scale(600))
//Elib.TestFrame:SetSizable(true)
Elib.TestFrame:Center()
Elib.TestFrame:MakePopup()
Elib.TestFrame:SetRemoveOnClose(false)

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

changeTab()

// Sidebar
local sidebar = Elib.TestFrame:CreateSidebar("Tab 1", "https://i.imgur.com/WUtsRM9.png", 1, -15, 5)

sidebar:AddItem(1, "Welcome", "https://construct-cdn.physgun.com/images/1e154095-79b2-436e-80a3-cb6b924d14a2.png", function(id) // (id, name, imageURL, doClick, order)
    currentPage = 1
    changeTab()
end, 1)

sidebar:AddItem(2, "Buttons", "https://construct-cdn.physgun.com/images/2dea4a43-79f1-4025-a6a6-9aaf059214e9.png", function(id)
    currentPage = 2
    changeTab()
end, 2)

sidebar:AddItem(3, "Tab 3", "https://i.imgur.com/WUtsRM9.png", function(id)
    currentPage = 3
    changeTab()
end, 3)

Elib.TestFrame:SetVisible(false)

concommand.Add("elib_test", function()

    if Elib.TestFrame:IsVisible() then
        Elib.TestFrame:Close()
    else
        // Open With Animation
        Elib.TestFrame:Open()
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