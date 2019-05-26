
--[[

  ITB (insidethebox) minetest game - Copyright (C) 2017-2018 sofar & nore

  helper script to create a font for use in signs.

  This library is free software; you can redistribute it and/or
  modify it under the terms of the GNU Lesser General Public License
  as published by the Free Software Foundation; either version 2.1
  of the License, or (at your option) any later version.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
  Lesser General Public License for more details.

  You should have received a copy of the GNU Lesser General Public
  License along with this library; if not, write to the Free
  Software Foundation, Inc., 59 Temple Place, Suite 330, Boston,
  MA 02111-1307 USA

]]--

for c = 32, 255 do
	s = string.char(c)
	n = string.format("%x", c)
	cmd = "convert -background transparent -fill black -font pcsenior.ttf -size 8x8" ..
			" -pointsize 8 label:\"" .. s .. "\" " .. n .. ".png"
	print(c, s, n)
	print(cmd)
	os.execute(cmd)
end
