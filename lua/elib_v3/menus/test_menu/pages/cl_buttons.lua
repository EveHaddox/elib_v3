// Script made by Eve Haddox
// discord evehaddox


/// Button Page | Page 2
local PANEL = {}

Elib.RegisterFont("Elib.Test.Title", "Space Grotesk SemiBold", 32)

function PANEL:Init()

    self.panel = self:Add("DPanel")
    self.panel:Dock(TOP)
    self.panel:DockMargin(0, 0, 0, 4)
    self.panel:SetTall(Elib.Scale(40))

    self.panel.Paint = function(self, w, h)
        Elib.DrawSimpleText("Buttons", "Elib.Test.Title", w / 2, 0, Elib.Colors.PrimaryText, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
    end
    
    // Normal Buttons
    self.button = self:Add("Elib.Button")
    self.button:Dock(TOP)
    self.button:DockMargin(0, 0, 0, 4)
    self.button.DoClick = function()
        print("Button clicked!")
    end

    self.textButton = self:Add("Elib.TextButton")
    self.textButton:Dock(TOP)
    self.textButton:DockMargin(0, 0, 0, 4)
    self.textButton:SetText("Text Button")
    self.textButton.DoClick = function()
        print("Text Button clicked!")
    end

    self.textButton = self:Add("Elib.ImageTextButton")
    self.textButton:Dock(TOP)
    self.textButton:DockMargin(0, 0, 0, 4)
    self.textButton:SetText("Image Text Button")
    --self.textButton:SetImageSpacing(Elib.Scale(6))
    self.textButton:SetUrl("https://construct-cdn.physgun.com/images/51bf125e-b357-42df-949c-2bffff7e8b6c.png")
    self.textButton.DoClick = function()
        print("Image text Button clicked!")
    end

    // Outline Buttons
    self.button = self:Add("Elib.OutlineButton")
    self.button:Dock(TOP)
    self.button:DockMargin(0, 0, 0, 4)
    self.button.DoClick = function()
        print("Outline button clicked!")
    end

    self.textButton = self:Add("Elib.OutlineTextButton")
    self.textButton:Dock(TOP)
    self.textButton:DockMargin(0, 0, 0, 4)
    self.textButton:SetText("Outline Text Button")
    self.textButton.DoClick = function()
        print("Outline text button clicked!")
    end

    self.textButton = self:Add("Elib.OutlineImageButton")
    self.textButton:Dock(TOP)
    self.textButton:DockMargin(0, 0, 0, 4)
    self.textButton:SetText("Outline Image Button")
    --self.textButton:SetImageSpacing(Elib.Scale(6))
    self.textButton:SetUrl("https://construct-cdn.physgun.com/images/51bf125e-b357-42df-949c-2bffff7e8b6c.png")
    self.textButton.DoClick = function()
        print("Outline image button clicked!")
    end

    // Gradient Buttons
    self.gradientButton = self:Add("Elib.GradientButton")
    self.gradientButton:Dock(TOP)
    self.gradientButton:DockMargin(0, 0, 0, 4)
    self.gradientButton.DoClick = function()
        print("Gradient button clicked!")
    end

    self.gradientButton = self:Add("Elib.GradientTextButton")
    self.gradientButton:Dock(TOP)
    self.gradientButton:DockMargin(0, 0, 0, 4)
    self.gradientButton:SetText("Gradient Text Button")
    self.gradientButton.DoClick = function()
        print("Gradient text button clicked!")
    end

    self.textButton = self:Add("Elib.GradientImageButton")
    self.textButton:Dock(TOP)
    self.textButton:DockMargin(0, 0, 0, 4)
    self.textButton:SetText("Gradient Text Button")
    --self.textButton:SetImageSpacing(Elib.Scale(6))
    self.textButton:SetUrl("https://construct-cdn.physgun.com/images/51bf125e-b357-42df-949c-2bffff7e8b6c.png")
    self.textButton.DoClick = function()
        print("Gradient image button clicked!")
    end

    // Image buttons
    self.imageButton = self:Add("Elib.ImageButton")
    self.imageButton:Dock(TOP)
    self.imageButton:DockMargin(0, 0, 0, 4)
    self.imageButton:SetTall(40)
    self.imageButton:SetImageURL("https://construct-cdn.physgun.com/images/2dea4a43-79f1-4025-a6a6-9aaf059214e9.png")
    self.imageButton.DoClick = function()
        print("Image Button clicked!")
    end

    self.imgurButton = self:Add("Elib.ImgurButton")
    self.imgurButton:Dock(TOP)
    self.imgurButton:DockMargin(0, 0, 0, 4)
    self.imgurButton:SetTall(40)
    self.imgurButton:SetImageURL("https://i.imgur.com/WUtsRM9.png")
    self.imgurButton.DoClick = function()
        print("Imgur Button clicked!")
    end

end

function PANEL:PerformLayout(w, h)
    
end

function PANEL:Paint(w, h)

end

vgui.Register("Elib.Test.Page2", PANEL, "Panel")