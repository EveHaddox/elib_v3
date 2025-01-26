hook.Add("Elib.FullyLoaded", "Elib_PlayerFullyInGame1", function()
    timer.Simple(.1, function()
        local loadingScreen = vgui.Create("DFrame")
        loadingScreen:SetSize(ScrW(), ScrH())
        loadingScreen:SetTitle("")
        loadingScreen:SetDraggable(false)
        loadingScreen:ShowCloseButton(false)
        loadingScreen:MakePopup()
        loadingScreen:SetZPos(32767)
        loadingScreen.Paint = function(self, w, h)
            Elib.DrawRoundedBoxEx(0, 0, 0, w, h, Elib.Colors.Background, false, false, false, false)
            Elib.DrawProgressWheel((w - 60) / 2, (h - 60) / 2 - 20, 60, 60, Elib.Colors.PrimaryText)
            draw.SimpleText("Preparing Assets", "Trebuchet24", w / 2, h / 2 + 35, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end

        hook.Add("Elib:AssetsLoaded", "Elib_AssetsLoaded", function()
            if IsValid(loadingScreen) then
                loadingScreen:Close()
            end
        end)
    end)
end)
