// Script made by Eve Haddox
// discord evehaddox


///////////////////
// Popups Utilities
///////////////////
function Elib.CreateInfoPopup(message, title)
    local popup = vgui.Create("Elib.PopupInfo")
    if message then popup.Text:SetText(message) end
    if title then popup:SetTitle(title) end

    return popup
end

function Elib.CreateBoolPopup(message, OnComplete, title)
    local popup = vgui.Create("Elib.PopupBool")
    if message then popup.Text:SetText(message) end
    if title then popup:SetTitle(title) end
    popup:SetFunction(OnComplete)

    return popup
end

function Elib.CreateStringPopup(message, OnComplete, title, placeholder)
    local popup = vgui.Create("Elib.PopupString")
    if message then popup.Text:SetText(message) end
    if title then popup:SetTitle(title) end
    if placeholder then popup:SetPlaceholder(placeholder) end
    popup:SetFunction(OnComplete)

    return popup
end

if IsValid(Elib.PopupTest) then
    Elib.PopupTest:Remove()
end
Elib.PopupTest = Elib.CreateStringPopup(nil, function(bool) print(bool) end)