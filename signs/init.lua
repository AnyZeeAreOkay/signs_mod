
--[[

  ITB (insidethebox) minetest game - Copyright (C) 2017-2018 sofar & nore

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

signs = {}

local function clean_sign_entities(pos)
	for _, obj in pairs(minetest.get_objects_inside_radius(pos, 0.5)) do
		if not obj:is_player() and obj:get_luaentity().name == "signs:sign" then
			obj:remove()
		end
	end
end

local function format_time(seconds)
	local r = ""
	local s = seconds
	if s > 3600 then
		local h = s / 3600
		s = s % 3600
		r = r .. tostring(math.floor(h)) .. "h"
	end
	if s > 60 then
		local m = s / 60
		s = s % 60
		r = r .. tostring(math.floor(m)) .. "m"
	end
	if s > 0 then
		r = r .. tostring(s) .. "s"
	end
	return r
end

local function sign_refresh(pos)


	clean_sign_entities(pos)
	local meta = minetest.get_meta(pos)

	local text = meta:get_string("text")
	local ntext, count = string.gsub(text, "%$%((.-)%)", function(s)
		-- highscore player 1 through 10
		if s == "player1" then
			return ranks.player[1]
		elseif s == "player2" then
			return ranks.player[2]
		elseif s == "player3" then
			return ranks.player[3]
		elseif s == "player4" then
			return ranks.player[4]
		elseif s == "player5" then
			return ranks.player[5]
		elseif s == "player6" then
			return ranks.player[6]
		elseif s == "player7" then
			return ranks.player[7]
		elseif s == "player8" then
			return ranks.player[8]
		elseif s == "player9" then
			return ranks.player[9]
		elseif s == "player10" then
			return ranks.player[10]
		elseif s == "box1" then
			return ranks.box[1]
		elseif s == "box2" then
			return ranks.box[2]
		elseif s == "box3" then
			return ranks.box[3]
		elseif s == "box4" then
			return ranks.box[4]
		elseif s == "box5" then
			return ranks.box[5]
		elseif s == "box6" then
			return ranks.box[6]
		elseif s == "box7" then
			return ranks.box[7]
		elseif s == "box8" then
			return ranks.box[8]
		elseif s == "box9" then
			return ranks.box[9]
		elseif s == "box10" then
			return ranks.box[10]
		elseif s == "builder1" then
			return ranks.builder[1]
		elseif s == "builder2" then
			return ranks.builder[2]
		elseif s == "builder3" then
			return ranks.builder[3]
		elseif s == "builder4" then
			return ranks.builder[4]
		elseif s == "builder5" then
			return ranks.builder[5]
		elseif s == "builder6" then
			return ranks.builder[6]
		elseif s == "builder7" then
			return ranks.builder[7]
		elseif s == "builder8" then
			return ranks.builder[8]
		elseif s == "builder9" then
			return ranks.builder[9]
		elseif s == "builder10" then
			return ranks.builder[10]
		end
		return "[" .. s .. " ???]"
	end)
	meta:set_string("dtext", ntext)
	meta:mark_as_private("dtext")
	if meta:get_string("text") ~= "" then
		minetest.add_entity(pos, "signs:sign")
	end
	return (count > 0)
end

local function text_callback(player, fields, context)
	local name = player:get_player_name()

	--validate user was allowed to edit signs


	if not fields.text then
		if fields.quit then
			return true
		end
		fields.text = ""
	end

	-- validate length of sign text does not exceed max
	if string.len(fields.text) > 1000 then
		fields.text = fields.text:sub(1, 1000)
	end

	-- check: validate composed texture string does not exceed max
	-- max 1000 characters, each character can take up to 17 chars to encode
	-- in tex. So the total size is 17000 + "[combine", which easily fits
	-- 64k max texture string.

	--validate sign pos is actually within the box that player is in
	local pos = context


	-- verify node is still a sign
	local node = minetest.get_node(pos)
	if node.name ~= "signs:sign" and node.name ~= "signs:sign_wall" then
		-- sign no longer exists. Could be lag.
		return true
	end

	-- erase sign
	clean_sign_entities(pos)

	local meta = minetest.get_meta(pos)
	meta:set_string("text", fields.text)
	meta:mark_as_private("text")

	-- for lobby signs that need a refresh
	if minetest.get_node_timer(pos):is_started() then
		sign_refresh(pos)
	end

	if fields.text ~= "" then
		minetest.add_entity(pos, "signs:sign")
	end

	return true
end

minetest.register_node("signs:sign", {
	description = "sign",
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = true,
	inventory_image = "sign.png",
	walkable = false,
	tiles = {"invisible.png"},
	groups = { node = 1, sign = 1 },
	node_box = {
		type = "fixed",
		fixed = {
			{-1/2, -1/2, 7/16, 1/2, 1/2, 1/2}
		}
	},
	selection_box = {
		type = "fixed",
		fixed = {
			{-1/2, -1/2, 7/16, 1/2, 1/2, 1/2},
		}
	},
	colision_box = {
		type = "fixed",
		fixed = {
			{-1/2, -1/2, 7/16, 1/2, 1/2, 1/2},
		}
	},
	on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
		-- is player playing in this box?
		local name = clicker:get_player_name()

		-- show text input form
		local text = minetest.get_meta(pos):get_string("text")
		fsc.show(name,
			"size[8,8]" ..
			"textarea[0.5,0.5;7.5,6.5;text;text;" ..
			minetest.formspec_escape(text) .. "]" ..
			"button_exit[3.5,7;1,0.5;exit;exit]",
			pos,
			text_callback)
	end,
	on_destruct = function(pos)
		clean_sign_entities(pos)
	end,
	on_construct = function(pos)
		minetest.get_node_timer(pos):start(300)
	end,
	on_timer = function(pos)
		return sign_refresh(pos)
	end,
	after_box_construct = function(pos, box_id, player, moredata)
		clean_sign_entities(pos)
		local meta = minetest.get_meta(pos)
		if player then
			-- this is reached in exit lobbies, elswhere player = nil (mech creation of sign)
			local name = player:get_player_name()
			if boxes.players_in_boxes[name] then
				local box = boxes.players_in_boxes[name].box_id
				local bmeta = db.box_get_meta(box).meta
				local text = meta:get_string("text")
				local ntext = string.gsub(text, "%$%((.-)%)", function(s)
					if s == "box_name" then
						return bmeta.box_name
					elseif s == "builder" then
						return bmeta.builder
					elseif s == "build_time" then
						return format_time(bmeta.build_time)
					elseif moredata and moredata[s] then
						if moredata[s].format == "time" then
							return format_time(moredata[s].data)
						else
							return moredata[s].data
						end
					end
					return "[" .. s .. " ???]"
				end)
				meta:set_string("dtext", ntext)
				meta:mark_as_private("dtext")
			end
		end
		if meta:get_string("text") ~= "" then
			minetest.add_entity(pos, "signs:sign")
		end
	end,
	on_exit_update = function(pos, player, moredata)
		minetest.registered_nodes["signs:sign"].after_box_construct(pos, nil, player, moredata)
	end,
})

minetest.register_node("signs:sign_wall", {
	description = "Wall sign",
	drawtype = "mesh",
	mesh = "signs_wall.obj",
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = true,
	inventory_image = "sign.png",
	walkable = false,
	tiles = {"sign.png"},
	groups = { node = 1, sign = 1 },
	selection_box = {
		type = "fixed",
		fixed = {
			{-1/2, -7/16, 6/16, 1/2, 7/16, 1/2},
		}
	},
	on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)

		local name = clicker:get_player_name()

		-- show text input form
		local text = minetest.get_meta(pos):get_string("text")
		fsc.show(name,
			"size[8,8]" ..
			"textarea[0.5,0.5;7.5,6.5;text;text;" ..
			minetest.formspec_escape(text) .. "]" ..
			"button_exit[3.5,7;1,0.5;exit;exit]",
			pos,
			text_callback)
	end,
	on_destruct = function(pos)
		clean_sign_entities(pos)
	end,
	after_box_construct = function(pos, box_id, player, moredata)
		clean_sign_entities(pos)
		local meta = minetest.get_meta(pos)
		if meta:get_string("text") ~= "" then
			minetest.add_entity(pos, "signs:sign")
		end
	end,
	on_exit_update = function(pos, player, moredata)
		minetest.registered_nodes["signs:sign_wall"].after_box_construct(pos, nil, player, moredata)
	end,
})

local function make_tex(pos)
	local meta = minetest.get_meta(pos)
	local text = meta:get_string("dtext")
	if text == "" then
		text = meta:get_string("text")
	end
	-- Escape sequence for e with diaeresis mark
	text = string.gsub(text, "\\\"e", string.char(0xeb))

	local ww, rest = string.match(text, "^@wordwrap ([^\n]+)\n(.+)$")
	local center = false
	local wwwidth
	if ww then
		text = rest
		local wr = string.match(ww, "^center (.+)$")
		if wr then
			center = true
			ww = wr
		end
		wwwidth = tonumber(ww)
		if wwwidth and wwwidth < 1 then
			wwwidth = 1
		end
	end

	-- count lines
	local _, count = string.gsub(text, string.char(10), "")
	count = count + 1

	while true do
		local xlen = 0
		local max_width = 1000
		local ok = true
		if wwwidth then
			max_width = wwwidth * count
		end

		local index = 1
		local lines = {}
		local idx = 1
		text:gsub("()\n", function(ix)
			lines[index] = text:sub(idx, ix - 1)
			index = index + 1
			idx = ix + 1
		end)
		lines[index] = text:sub(idx, string.len(text))

		local split_lines = {}
		if wwwidth then
			local sindex = 1
			for _, s in ipairs(lines) do
				split_lines[sindex] = ""
				local ix = 1
				local column = 0
				s:gsub("()([^ ]+)()", function(i1, word, i2)
					local sp = i1 - ix
					column = column + sp
					ix = i2
					if column > 0 and column + string.len(word) > max_width then
						column = string.len(word)
						sindex = sindex + 1
						split_lines[sindex] = word
					else
						column = column + string.len(word)
						split_lines[sindex] = split_lines[sindex] .. string.rep(" ", sp) .. word
					end
					if column > max_width then
						ok = false
					end
				end)
				sindex = sindex + 1
			end
		else
			split_lines = lines
		end

		if count > 20 or (ok and #split_lines <= count) then
			local tex = ""
			local height = 8
			local stride = height
			for _, s in ipairs(split_lines) do
				xlen = math.max(xlen, string.len(s))
			end
			-- compose text
			for line, s in ipairs(split_lines) do
				local xoff = 0
				if center then
					xoff = math.floor((stride * (xlen - string.len(s))) / 2)
				end
				for column = 1, string.len(s) do
					local xpos = xoff + stride * (column - 1)
					local ypos = height * (line - 1)
					tex = tex .. string.format(":%d,%d=%x.png", xpos, ypos, string.byte(s, column))
				end
			end

			if tex == "" then
				tex = string.format(":%d,%d=%x.png", 0, 0, string.byte(" "))
			end

			local node = minetest.get_node(pos)
			local visual_size
			if node.name == "signs:sign_wall" then
				if xlen / count < 1.0 then
					visual_size = {x = 10/16 * (xlen / count), y = 10/16}
				else
					visual_size = {x = 10/16, y = 10/16 / (xlen / count)}
				end
			else
				visual_size = {x = xlen / count, y = 1}
			end
			return  "[combine:" .. (xlen * stride) .. "x" .. (height * count) .. tex, visual_size
		end
		count = count + 1
	end
end

minetest.register_lbm({
	nodenames = {"signs:sign", "signs:sign_wall"},
	run_at_every_load = true,
	name = "signs:load",
	action = function(pos, node)
		clean_sign_entities(pos)
		local meta = minetest.get_meta(pos)
		if meta:get_string("text") ~= "" then
			minetest.add_entity(pos, "signs:sign")
		end
	end,
})

function signs.set_text(pos, text)
	clean_sign_entities(pos)
	local meta = minetest.get_meta(pos)
	meta:set_string("text", text)
	meta:mark_as_private("text")
	if text ~= "" then
		minetest.add_entity(pos, "signs:sign")
	end
end

minetest.register_entity("signs:sign", {
	visual = "upright_sprite",
	textures = {},
	collisionbox = {0, 0, 0, 0, 0, 0},
	on_activate = function(self)
		local pos = self.object:getpos()
		if vector.distance(pos, vector.round(pos)) > 0.25 then
			self.object:remove()
			return
		end
		local textures, visual_size = make_tex(pos)
		local node = minetest.get_node(pos)
		local dir = minetest.facedir_to_dir(node.param2)
		local yaw = minetest.dir_to_yaw(dir)
		local offset
		if node.name == "signs:sign_wall" then
			offset = vector.multiply(dir, 1/2 - 1/16 - 1/64)
		else
			offset = vector.multiply(dir, 1/2 - 1/64)
		end
		self.object:setpos(vector.add(pos, offset))
		self.object:set_properties({
			textures = {textures},
			visual_size = visual_size
		})
		self.object:set_yaw(yaw)
	end,
	get_staticdata = function(self)
		return ""
	end,
})

minetest.register_node("signs:bg", {
	description = "Sign Background",
	tiles = {"sign_bg.png"},
	groups = { node = 1 },
})

local icons = {
	[1] = "nil",
	[2] = "asleep",
	[3] = "discontent",
	[4] = "down",
	[5] = "exclamation",
	[6] = "heart",
	[7] = "home",
	[8] = "oh",
	[9] = "question",
	[10] = "racecar",
	[11] = "raincloud",
	[12] = "shades",
	[13] = "smile",
	[14] = "snail",
	[15] = "sunny",
	[16] = "up",
	[17] = "weird",
	[18] = "winksmile",
	[19] = "xmouth",
}

local function icon_callback(player, fields, context)
	if not fields.quit then
		local k, _ = next(fields)
		local i = tonumber(k) or 0
		if not icons[i] then
			return true
		end

		local pos = context.pos
		local node = minetest.get_node(pos)
		node.name = "signs:icon_" .. icons[i]
		minetest.swap_node(pos, node)
	end

	return true
end

for k, v in ipairs(icons) do
	minetest.register_node("signs:icon_".. v, {
		description = "sign (" .. v .. ")",
		drawtype = "nodebox",
		paramtype = "light",
		paramtype2 = "facedir",
		walkable = false,
		tiles = {"signs_" .. v .. ".png"},
		node_box = {
			type = "fixed",
			fixed = {
				{-1/2, -1/2, 7/16, 1/2, 1/2, 1/2}
			}
		},
		selection_box = {
			type = "fixed",
			fixed = {
				{-1/2, -1/2, 7/16, 1/2, 1/2, 1/2},
			}
		},
		colision_box = {
			type = "fixed",
			fixed = {
				{-1/2, -1/2, 7/16, 1/2, 1/2, 1/2},
			}
		},
		on_trigger = function(pos)
			local box = boxes.find_box(pos)

			local name = box.name -- player name
			local form = "size[9,8]\n"
			for kk, vv in ipairs(icons) do
				form = form ..
					"image_button[" .. 1.5 * ((kk-1) % 5) + 0.7 .. "," ..
					2.0 * math.floor((kk-1)/5) + 0.3 .. ";" ..
					"1.35,1.35;signs_" .. vv ..
					".png;" .. kk .. ";]"
				if vv == "nil" then
					vv = "cancel"
				end
				form = form ..
					"label[" ..  1.5 * ((kk-1) % 5) + 0.8 .. "," ..
					2.0 * math.floor((kk-1)/5) + 1.5 ..
					";" .. vv .. "]\n"
			end
			fsc.show(name, form, {pos = pos}, icon_callback)
		end,
		groups = {icon = 1}, -- find icons using group:icon
		icon_name = v,
		icon_id = k, -- ID, must never get renumbered!
	})
end


local stardir = {
	[0] = {x = 1, y = 0, z = 0},
	[1] = {x = 0, y = 0, z = -1},
	[2] = {x = -1, y = 0, z = 0},
	[3] = {x = 0, y = 0, z = 1},
}

minetest.register_node("signs:star", {
	description = "A Star",
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = true,
	walkable = false,
	tiles = {"signs_star.png"},
	node_box = {
		type = "fixed",
		fixed = {
			{-1/2, -1/2, 7/16, 1/2, 1/2, 1/2}
		}
	},
	selection_box = {
		type = "fixed",
		fixed = {
			{-1/2, -1/2, 7/16, 1/2, 1/2, 1/2},
		}
	},
	colision_box = {
		type = "fixed",
		fixed = {
			{-1/2, -1/2, 7/16, 1/2, 1/2, 1/2},
		}
	},
	on_trigger = function(pos)
		local node = minetest.get_node(pos)
		local dir = stardir[node.param2]
		pos = vector.add(pos, dir)
		node = minetest.get_node(pos)
		while node.name == "signs:star" do
			-- make this a no_star
			node.name = "signs:no_star"
			minetest.swap_node(pos, node)
			-- iterate right
			pos = vector.add(pos, dir)
			node = minetest.get_node(pos)
		end
	end,
	groups = {star = 1}, -- count stars by finding them using group:star
})

minetest.register_node("signs:no_star", {
	description = "No Star",
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = true,
	walkable = false,
	tiles = {"signs_nil.png"},
	groups = { node = 1 },
	node_box = {
		type = "fixed",
		fixed = {
			{-1/2, -1/2, 7/16, 1/2, 1/2, 1/2}
		}
	},
	selection_box = {
		type = "fixed",
		fixed = {
			{-1/2, -1/2, 7/16, 1/2, 1/2, 1/2},
		}
	},
	colision_box = {
		type = "fixed",
		fixed = {
			{-1/2, -1/2, 7/16, 1/2, 1/2, 1/2},
		}
	},
	on_trigger = function(pos)
		local node = minetest.get_node(pos)
		local dir = stardir[node.param2]
		while node.name == "signs:no_star" do
			-- make this a no_star
			node.name = "signs:star"
			minetest.swap_node(pos, node)
			-- iterate left
			pos = vector.subtract(pos, dir)
			node = minetest.get_node(pos)
		end
	end,
})
