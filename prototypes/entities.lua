--luacheck: ignore dupli_proto note_slot_count

local empty_picture = {
	filename = "__StickyNotes__/graphics/empty.png",
	x = 0,
	y = 0,
	width = 1,
	height = 1,
	frame_count = 1,
	shift = {0, 0},
}

--------------------------------------------------------------------------------------
--[[StickyNotes Tech]]--
local tech = {
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
}
data:extend({tech})

--------------------------------------------------------------------------------------
--[[Sticky Note]]--
local sticky_note_recipe = {
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
}

local sticky_note_item = {
    type = "item",
    name = "sticky-note",
    icon = "__StickyNotes__/graphics/sticky-note.png",
    flags = {"goes-to-quickbar"},
    subgroup = "terrain",
    order = "y",
    place_result = "sticky-note",
    stack_size = 100
}

local sticky_note = dupli_proto( "container", "wooden-chest", "sticky-note" )
sticky_note.icon = "__StickyNotes__/graphics/sticky-note.png"
sticky_note.picture =
{
    filename = "__StickyNotes__/graphics/sticky-note.png",
    priority = "extra-high",
    width = 32,
    height = 32,
    shift = {0,0},
}
--sticky_note.collision_mask = "floor-layer"
--sticky_note.collision_box = {{-0.1, -0.1}, {0.1, 0.1}}
sticky_note.collision_box = nil
sticky_note.selection_box = {{-0.5, -0.5}, {0.5, 0.5}}
sticky_note.inventory_size = 1

data:extend({sticky_note_recipe, sticky_note_item, sticky_note})

--------------------------------------------------------------------------------------
--[[Sticky Sign]]--
local sticky_sign_recipe = {
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
}

local sticky_sign_item = {
    type = "item",
    name = "sticky-sign",
    icon = "__StickyNotes__/graphics/sign-icon.png",
    flags = {"goes-to-quickbar"},
    subgroup = "terrain",
    order = "y",
    place_result = "sticky-sign",
    stack_size = 100
}

local sticky_sign = dupli_proto( "container", "wooden-chest", "sticky-sign" )
sticky_sign.icon = "__StickyNotes__/graphics/sign-icon.png"
sticky_sign.picture =
{
    filename = "__StickyNotes__/graphics/sign.png",
    priority = "extra-high",
    width = 64,
    height = 64,
    shift = {0.5,-0.5},
}
--sticky_sign.collision_box = {{-0.1, -0.1}, {0.1, 0.1}}
sticky_sign.collision_box = nil
sticky_sign.selection_box = {{-0.5, -0.5}, {0.5, 0.5}}
-- sticky_sign.collision_mask = "floor-layer"
sticky_sign.inventory_size = 1

data:extend({sticky_sign_recipe, sticky_sign_item, sticky_sign})

--------------------------------------------------------------------------------------
--[[Sticky Note Proxies]]--
local invis_note_item ={
    type = "item",
    name = "invis-note",
    icon = "__StickyNotes__/graphics/sticky-note.png",
    flags = { "hidden" },
    subgroup = "circuit-network",
    place_result="invis-note",
    order = "b[combinators]-c[invis-note]",
    stack_size= 50,
}

local invis_note = {
    type = "constant-combinator",
    name = "invis-note",
    icon = "__StickyNotes__/graphics/sticky-note.png",
    flags = {"player-creation", "placeable-off-grid"},
    max_health = 0,
    collision_mask = {"not-colliding-with-itself"},

    item_slot_count = note_slot_count,
    sprites =
    {
        north = empty_picture,
        east = empty_picture,
        south = empty_picture,
        west = empty_picture,
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
    circuit_wire_max_distance = 7.5,
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
}

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

local sticky_text = dupli_proto("flying-text", "flying-text", "sticky-text")
sticky_text.icon = "__StickyNotes__/graphics/sign-icon.png"

data:extend({invis_note_item, invis_note, sticky_text, mapmark})
