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

		{
		    type = "item",
		    name = "invis-note",
		    icon = "__StickyNotes__/graphics/sticky-note.png",
		    flags = { "goes-to-quickbar" },
		    subgroup = "circuit-network",
		    place_result="invis-note",
		    order = "b[combinators]-c[invis-note]",
		    stack_size= 50,
	  },
		{
		    type = "constant-combinator",
			name = "invis-note",
		    icon = "__StickyNotes__/graphics/sticky-note.png",
		    flags = {"player-creation", "placeable-off-grid"},
		    -- minable = {hardness = 0.2, mining_time = 0.5, result = "constant-combinator"},
		    max_health = 50,
		    corpse = "small-remnants",
		    collision_mask = {},

		    collision_box = {{0, 0}, {0, 0}},
		    selection_box = {{0, 0}, {0, 0}},

		    item_slot_count = note_slot_count,

		    sprites =
		    {
		      north =
		      {
		        filename = "__StickyNotes__/graphics/empty.png",
		        x = 0,
		        y = 0,
		        width = 1,
		        height = 1,
		        frame_count = 1,
		        shift = {0, 0},
		      },
		      east =
		      {
		        filename = "__StickyNotes__/graphics/empty.png",
		        x = 0,
		        y = 0,
		        width = 1,
		        height = 1,
		        frame_count = 1,
		        shift = {0, 0},
		      },
		      south =
		      {
		        filename = "__StickyNotes__/graphics/empty.png",
		        x = 0,
		        y = 0,
		        width = 1,
		        height = 1,
		        frame_count = 1,
		        shift = {0, 0},
		      },
		      west =
		      {
		        filename = "__StickyNotes__/graphics/empty.png",
		        x = 0,
		        y = 0,
		        width = 1,
		        height = 1,
		        frame_count = 1,
		        shift = {0, 0},
		      }
		    },

		    activity_led_sprites =
		    {
		      north =
		      {
		        filename = "__base__/graphics/entity/combinator/activity-leds/combinator-led-constant-north.png",
		        width = 11,
		        height = 10,
		        frame_count = 1,
		        shift = {0.296875, -0.40625},
		      },
		      east =
		      {
		        filename = "__base__/graphics/entity/combinator/activity-leds/combinator-led-constant-east.png",
		        width = 14,
		        height = 12,
		        frame_count = 1,
		        shift = {0.25, -0.03125},
		      },
		      south =
		      {
		        filename = "__base__/graphics/entity/combinator/activity-leds/combinator-led-constant-south.png",
		        width = 11,
		        height = 11,
		        frame_count = 1,
		        shift = {-0.296875, -0.078125},
		      },
		      west =
		      {
		        filename = "__base__/graphics/entity/combinator/activity-leds/combinator-led-constant-west.png",
		        width = 12,
		        height = 12,
		        frame_count = 1,
		        shift = {-0.21875, -0.46875},
		      }
		    },

		    activity_led_light =
		    {
		      intensity = 0.8,
		      size = 1,
		    },

		    activity_led_light_offsets =
		    {
		      {0.296875, -0.40625},
		      {0.25, -0.03125},
		      {-0.296875, -0.078125},
		      {-0.21875, -0.46875}
		    },

		    circuit_wire_connection_points =
		    {
		      {
		        shadow =
		        {
		          red = {0.15625, -0.28125},
		          green = {0.65625, -0.25}
		        },
		        wire =
		        {
		          red = {-0.28125, -0.5625},
		          green = {0.21875, -0.5625},
		        }
		      },
		      {
		        shadow =
		        {
		          red = {0.75, -0.15625},
		          green = {0.75, 0.25},
		        },
		        wire =
		        {
		          red = {0.46875, -0.5},
		          green = {0.46875, -0.09375},
		        }
		      },
		      {
		        shadow =
		        {
		          red = {0.75, 0.5625},
		          green = {0.21875, 0.5625}
		        },
		        wire =
		        {
		          red = {0.28125, 0.15625},
		          green = {-0.21875, 0.15625}
		        }
		      },
		      {
		        shadow =
		        {
		          red = {-0.03125, 0.28125},
		          green = {-0.03125, -0.125},
		        },
		        wire =
		        {
		          red = {-0.46875, 0},
		          green = {-0.46875, -0.40625},
		        }
		      }
		    },

		    circuit_wire_max_distance = 7.5
		    }
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