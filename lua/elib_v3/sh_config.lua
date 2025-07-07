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
    Should we override the default derma popups for the PIXEL UI reskins?
    0 = No - forced off.
    1 = No - but users can opt in via convar (pixel_ui_override_popups).
    2 = Yes - but users can opt out via convar.
    3 = Yes - forced on.
]]
Elib.OverrideDermaMenus = 0

--[[
    The Image URL of the progress image you want to appear when image content is loading.
]]
Elib.ProgressImageURL = "https://pixel-cdn.lythium.dev/i/47qh6kjjh"

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