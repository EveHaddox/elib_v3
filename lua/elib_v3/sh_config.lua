--[[
	PIXEL UI - Copyright Notice
	© 2023 Thomas O'Sullivan - All rights reserved

	This program is free software: you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation, either version 3 of the License.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program.  If not, see <https://www.gnu.org/licenses/>.
--]]

--[[
    Should we override the default derma popups for the Elib V3 reskins?
    0 = No - forced off.
    1 = No - but users can opt in via convar (pixel_ui_override_popups).
    2 = Yes - but users can opt out via convar.
    3 = Yes - forced on.
]]
Elib.OverrideDermaMenus = 0

--[[
    The Image URL of the progress image you want to appear when image content is loading.
]]
Elib.ProgressImageURL = "https://construct-cdn.physgun.com/images/5fa7c9c8-d9d5-4c77-aed6-975b4fb039b5.png"

--[[
    The location at which downloaded assets should be stored (relative to the data folder).
]]
Elib.DownloadPath = "elib/images/"

--[[
    Colour definitions.
]]
Elib.Colors = {
    Background = Color(20, 20, 20),         -- Neutral matte base
    Header = Color(30, 30, 30),             -- Flat section separator
    Scroller = Color(48, 48, 48),           -- Visible but non-distracting

    PrimaryText = Color(240, 240, 240),     -- Clear, readable
    SecondaryText = Color(200, 200, 200),   -- Less prominent info
    DisabledText = Color(100, 100, 100),    -- Muted/inactive

    Primary = Color(180, 58, 58),           -- Strong modern red
    Disabled = Color(120, 120, 120),        -- Grayed-out UI
    Positive = Color(70, 175, 70),          -- Green for success
    Negative = Color(190, 65, 65),          -- Red for errors

    Gold = Color(214, 174, 34),
    Silver = Color(192, 192, 192),
    Bronze = Color(145, 94, 49),

    Transparent = Color(0, 0, 0, 0),
    Stencil = Color(0, 0, 0, 1)
}

--[[
    Theme presets.
    Each theme is a named table of color overrides for Elib.Colors.
    You only need to include the keys you want to change — any missing keys
    will fall back to the "Default" theme values.

    To add a new theme, just add a new entry to this table:
        Elib.Themes["MyTheme"] = { Primary = Color(255, 0, 0), ... }
]]
Elib.Themes = {
    ["Default"] = {
        Background = Color(20, 20, 20),
        Header = Color(30, 30, 30),
        Scroller = Color(48, 48, 48),
        PrimaryText = Color(240, 240, 240),
        SecondaryText = Color(200, 200, 200),
        DisabledText = Color(100, 100, 100),
        Primary = Color(180, 58, 58),
        Disabled = Color(120, 120, 120),
        Positive = Color(70, 175, 70),
        Negative = Color(190, 65, 65),
        Gold = Color(214, 174, 34),
        Silver = Color(192, 192, 192),
        Bronze = Color(145, 94, 49),
        Transparent = Color(0, 0, 0, 0),
        Stencil = Color(0, 0, 0, 1),
    },

    // 'Reskins'
    ["Blue"] = {
        Background = Color(20, 20, 24),
        Header = Color(30, 30, 34),
        Scroller = Color(48, 48, 52),
        PrimaryText = Color(240, 240, 240),
        SecondaryText = Color(200, 200, 200),
        DisabledText = Color(100, 100, 100),
        Primary = Color(60, 130, 220),
        Disabled = Color(120, 120, 120),
        Positive = Color(70, 175, 70),
        Negative = Color(190, 65, 65),
        Gold = Color(214, 174, 34),
        Silver = Color(192, 192, 192),
        Bronze = Color(145, 94, 49),
        Transparent = Color(0, 0, 0, 0),
        Stencil = Color(0, 0, 0, 1),
    },
    ["Green"] = {
        Background = Color(20, 24, 20),
        Header = Color(30, 34, 30),
        Scroller = Color(48, 52, 48),
        PrimaryText = Color(240, 240, 240),
        SecondaryText = Color(200, 200, 200),
        DisabledText = Color(100, 100, 100),
        Primary = Color(48, 155, 62),
        Disabled = Color(120, 120, 120),
        Positive = Color(70, 175, 70),
        Negative = Color(190, 65, 65),
        Gold = Color(214, 174, 34),
        Silver = Color(192, 192, 192),
        Bronze = Color(145, 94, 49),
        Transparent = Color(0, 0, 0, 0),
        Stencil = Color(0, 0, 0, 1),
    },
    ["Purple"] = {
        Background = Color(22, 20, 24),
        Header = Color(32, 30, 34),
        Scroller = Color(50, 48, 52),
        PrimaryText = Color(240, 240, 240),
        SecondaryText = Color(200, 200, 200),
        DisabledText = Color(100, 100, 100),
        Primary = Color(135, 58, 180),
        Disabled = Color(120, 120, 120),
        Positive = Color(70, 175, 70),
        Negative = Color(190, 65, 65),
        Gold = Color(214, 174, 34),
        Silver = Color(192, 192, 192),
        Bronze = Color(145, 94, 49),
        Transparent = Color(0, 0, 0, 0),
        Stencil = Color(0, 0, 0, 1),
    },
    ["Gray"] = {
        Background = Color(22, 22, 24),
        Header = Color(30, 30, 34),
        Scroller = Color(48, 48, 52),
        PrimaryText = Color(235, 235, 235),
        SecondaryText = Color(200, 200, 200),
        DisabledText = Color(100, 100, 100),
        Primary = Color(150, 150, 165),
        Disabled = Color(120, 120, 120),
        Positive = Color(70, 175, 90),
        Negative = Color(200, 70, 70),
        Gold = Color(210, 170, 40),
        Silver = Color(185, 185, 185),
        Bronze = Color(150, 95, 50),
        Transparent = Color(0, 0, 0, 0),
        Stencil = Color(0, 0, 0, 1),
    },
    ["Orange"] = {
        Background = Color(20, 18, 16),
        Header = Color(30, 26, 22),
        Scroller = Color(45, 40, 35),
        PrimaryText = Color(245, 240, 235),
        SecondaryText = Color(210, 200, 190),
        DisabledText = Color(105, 95, 85),
        Primary = Color(230, 125, 40),
        Disabled = Color(120, 120, 120),
        Positive = Color(70, 175, 90),
        Negative = Color(200, 70, 70),
        Gold = Color(215, 170, 40),
        Silver = Color(190, 190, 190),
        Bronze = Color(150, 95, 50),
        Transparent = Color(0, 0, 0, 0),
        Stencil = Color(0, 0, 0, 1),
    },

    // Full
    ["Arctic Neon"] = {
        Background = Color(12, 18, 28),
        Header = Color(18, 28, 40),
        Scroller = Color(28, 40, 55),

        PrimaryText = Color(235, 245, 255),
        SecondaryText = Color(170, 200, 225),
        DisabledText = Color(90, 110, 130),

        Primary = Color(0, 180, 255), -- bright button
        Disabled = Color(90, 100, 110),

        Positive = Color(60, 200, 140),
        Negative = Color(220, 70, 70),

        Gold = Color(220, 180, 45),
        Silver = Color(200, 205, 210),
        Bronze = Color(160, 110, 65),

        Transparent = Color(0, 0, 0, 0),
        Stencil = Color(0, 0, 0, 1),
    },
    ["Obsidian Magenta"] = {
        Background = Color(20, 14, 26),
        Header = Color(30, 20, 38),
        Scroller = Color(44, 30, 55),

        PrimaryText = Color(250, 240, 255),
        SecondaryText = Color(210, 185, 225),
        DisabledText = Color(110, 95, 120),

        Primary = Color(200, 60, 170),
        Disabled = Color(110, 110, 110),

        Positive = Color(80, 190, 110),
        Negative = Color(220, 70, 90),

        Gold = Color(230, 185, 55),
        Silver = Color(200, 195, 205),
        Bronze = Color(160, 100, 60),

        Transparent = Color(0, 0, 0, 0),
        Stencil = Color(0, 0, 0, 1),
    },
    ["Toxic Reactor"] = {
        Background = Color(14, 22, 16),
        Header = Color(22, 32, 22),
        Scroller = Color(32, 48, 32),

        PrimaryText = Color(235, 255, 235),
        SecondaryText = Color(180, 215, 180),
        DisabledText = Color(100, 120, 100),

        Primary = Color(120, 230, 60),
        Disabled = Color(110, 120, 110),

        Positive = Color(80, 200, 100),
        Negative = Color(220, 70, 70),

        Gold = Color(215, 175, 35),
        Silver = Color(190, 190, 190),
        Bronze = Color(150, 95, 50),

        Transparent = Color(0, 0, 0, 0),
        Stencil = Color(0, 0, 0, 1),
    },
    ["Bloodsteel"] = {
        Background = Color(24, 14, 14),
        Header = Color(36, 20, 20),
        Scroller = Color(52, 28, 28),

        PrimaryText = Color(255, 235, 235),
        SecondaryText = Color(215, 180, 180),
        DisabledText = Color(120, 95, 95),

        Primary = Color(190, 45, 45),
        Disabled = Color(120, 110, 110),

        Positive = Color(70, 180, 100),
        Negative = Color(220, 80, 80),

        Gold = Color(220, 170, 40),
        Silver = Color(195, 195, 195),
        Bronze = Color(160, 95, 50),

        Transparent = Color(0, 0, 0, 0),
        Stencil = Color(0, 0, 0, 1),
    },
    ["Royal Gold"] = {
        Background = Color(16, 16, 14),
        Header = Color(24, 24, 20),
        Scroller = Color(36, 36, 30),

        PrimaryText = Color(255, 250, 220),
        SecondaryText = Color(220, 205, 150),
        DisabledText = Color(120, 115, 95),

        Primary = Color(212, 168, 28),
        Disabled = Color(120, 120, 110),

        Positive = Color(70, 180, 110),
        Negative = Color(210, 70, 70),

        Gold = Color(230, 190, 60),
        Silver = Color(200, 200, 200),
        Bronze = Color(160, 100, 55),

        Transparent = Color(0, 0, 0, 0),
        Stencil = Color(0, 0, 0, 1),
    },
    

    // Elib's ui wasn't made for a light theme, so it looks horrible
    --["Light"] = {
    --    Background = Color(220, 220, 220),
    --    Header = Color(200, 200, 200),
    --    Scroller = Color(180, 180, 180),
    --    PrimaryText = Color(30, 30, 30),
    --    SecondaryText = Color(80, 80, 80),
    --    DisabledText = Color(160, 160, 160),
    --    Primary = Color(55, 174, 210),
    --    Disabled = Color(180, 180, 180),
    --    Positive = Color(50, 160, 70),
    --    Negative = Color(210, 60, 60),
    --    Gold = Color(190, 155, 25),
    --    Silver = Color(140, 140, 145),
    --    Bronze = Color(145, 94, 49),
    --    Transparent = Color(0, 0, 0, 0),
    --    Stencil = Color(0, 0, 0, 1),
    --},
}

Elib.ActiveTheme = Elib.ActiveTheme or "Default"