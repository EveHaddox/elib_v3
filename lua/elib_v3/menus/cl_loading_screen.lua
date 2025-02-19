hook.Add("Elib.FullyLoaded", "Elib_PlayerFullyInGame1", function()
    timer.Simple(.1, function()
        if Elib.loadingScreen then Elib.loadingScreen:Remove() end
        Elib.loadingScreen = vgui.Create("DFrame")
        Elib.loadingScreen:SetSize(ScrW(), ScrH())
        Elib.loadingScreen:SetTitle("")
        Elib.loadingScreen:SetDraggable(false)
        Elib.loadingScreen:ShowCloseButton(false)
        Elib.loadingScreen:MakePopup()
        Elib.loadingScreen:SetZPos(32767)
        Elib.loadingScreen.Paint = function(self, w, h)
            Elib.DrawRoundedBoxEx(0, 0, 0, w, h, Elib.Colors.Background, false, false, false, false)
            Elib.DrawProgressWheel((w - 60) / 2, (h - 60) / 2 - 20, 60, 60, Elib.Colors.PrimaryText)
            draw.SimpleText("Preparing Assets", "Trebuchet24", w / 2, h / 2 + 35, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end

        hook.Add("Elib:AssetsLoaded", "Elib_AssetsLoaded", function()
            if IsValid(Elib.loadingScreen) then
                Elib.loadingScreen:Close()
            end
        end)
    end)
end)
