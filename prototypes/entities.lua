--------------------------------------------------------------------------------------
local note = dupli_proto( "container", "wooden-chest", "sticky-note" )
note.icon = "__StickyNotes__/graphics/sticky-note.png"
note.picture =
	{
		filename = "__StickyNotes__/graphics/sticky-note.png",
		priority = "extra-high",
		width = 32,
		height = 32,
		shift = {0,0},
	}
note.collision_box = {{-0.1, -0.1}, {0.1, 0.1}}
note.selection_box = {{-0.5, -0.5}, {0.5, 0.5}}
note.inventory_size = 1

-- note.collision_mask = "floor-layer"

local sign = dupli_proto( "container", "wooden-chest", "sticky-sign" )
sign.icon = "__StickyNotes__/graphics/sign-icon.png"
sign.picture =
	{
		filename = "__StickyNotes__/graphics/sign.png",
		priority = "extra-high",
		width = 64,
		height = 64,
		shift = {0.5,-0.5},
	}
sign.collision_box = {{-0.1, -0.1}, {0.1, 0.1}}
sign.selection_box = {{-0.5, -0.5}, {0.5, 0.5}}
-- sign.collision_mask = "floor-layer"
sign.inventory_size = 1


-- local invis_note = dupli_proto("constant-combinator", "constant-combinator", "invis-note")

local invis_note = table.deepcopy(data.raw["constant-combinator"]["constant-combinator"])
invis_note.name = "invis-note"
invis_note.icon = "__StickyNotes__/graphics/sticky-note.png"
sprites = {}
invis_note.picture =
	{
		filename = "__StickyNotes__/graphics/sticky-note.png",
		priority = "extra-high",
		width = 32,
		height = 32,
		shift = {0,0},
	}
invis_note.flags = {"placeable-off-grid"}
invis_note.item_slot_count = 51 -- first slot stores metadata, the rest store text at 4 chars per slot
circuit_wire_connection_points = {}

data:extend(
	{
		{
			type = "technology",
			name = "sticky-notes",
			icon = "__StickyNotes__/graphics/sticky-notes.png",
			icon_size = 128,
			effects =
			{
				{
					type = "unlock-recipe",
					recipe = "sticky-note",
				},
				{
					type = "unlock-recipe",
					recipe = "sticky-sign",
				},
			},
			unit = {
				count = 20,
				ingredients = {
					{"science-pack-1", 1},
				},
				time = 10
			},
			order = "k-c",
		},
		
		note,
		
		{
			type = "item",
			name = "sticky-note",
			icon = "__StickyNotes__/graphics/sticky-note.png",
			flags = {"goes-to-quickbar"},
			subgroup = "terrain",
			order = "y",
			place_result = "sticky-note",
			stack_size = 100
		},
		
		{
			type = "recipe",
			name = "sticky-note",
			enabled = false,
			energy_required = 0.5,
			ingredients = 
			{      
				{"wood", 3}
			},
			result = "sticky-note",
			result_count = 1,
		},
		
		sign,
		
		{
			type = "item",
			name = "sticky-sign",
			icon = "__StickyNotes__/graphics/sign-icon.png",
			flags = {"goes-to-quickbar"},
			subgroup = "terrain",
			order = "y",
			place_result = "sticky-sign",
			stack_size = 100
		},
		
		{
			type = "recipe",
			name = "sticky-sign",
			enabled = false,
			energy_required = 1,
			ingredients = 
			{      
				{"iron-plate", 3}
			},
			result = "sticky-sign",
			result_count = 1,
		},

		-- invis_note,
		invis_note,
	}
	)		

-- to put a label on the map.

local mapmark_anim =
{
	filename = "__StickyNotes__/graphics/empty.png",
	priority = "high",
	width = 0,
	height = 0,
	frame_count = 1,
	shift = {0,0},
}

local mapmark = dupli_proto("train-stop","train-stop","sticky-note-mapmark")
mapmark.minable.result = "train-stop"
mapmark.collision_box = {{0,0}, {0,0}}
mapmark.selection_box = {{0,0}, {0,0}}
mapmark.drawing_box = {{0,0}, {0,0}}
mapmark.order = "y"
mapmark.selectable_in_game = false
mapmark.tile_width = 1
mapmark.tile_height = 1
mapmark.rail_overlay_animations =
{
	north = mapmark_anim,
	east = mapmark_anim,
	south = mapmark_anim,
	west = mapmark_anim,
}
mapmark.animations =
{
	north = mapmark_anim,
	east = mapmark_anim,
	south = mapmark_anim,
	west = mapmark_anim,
}
mapmark.top_animations =
{
	north = mapmark_anim,
	east = mapmark_anim,
	south = mapmark_anim,
	west = mapmark_anim,
}

data:extend(
	{
		mapmark,
	}
)