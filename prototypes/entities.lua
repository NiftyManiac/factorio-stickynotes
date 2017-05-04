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
sticky_note.collision_box = {{-0.1, -0.1}, {0.1, 0.1}}
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
sticky_sign.collision_box = {{-0.1, -0.1}, {0.1, 0.1}}
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
    stack_size = 1,
}

local invis_note = {
    type = "constant-combinator",
    name = "invis-note",
    icon = "__StickyNotes__/graphics/sticky-note.png",
    flags = {"player-creation", "placeable-off-grid", "not-repairable"},
    max_health = 1,
    collision_mask = {"not-colliding-with-itself"},
    item_slot_count = settings.startup["sticky-note-slot-count"].value,
    sprites =
    {
        north = empty_picture,
        east = empty_picture,
        south = empty_picture,
        west = empty_picture,
    },
    activity_led_sprites =
    {
        north = empty_picture,
        east = empty_picture,
        south = empty_picture,
        west = empty_picture
    },
    activity_led_light_offsets = {{0, 0}, {0, 0}, {0, 0}, {0, 0}},
    circuit_wire_max_distance = 0,
    circuit_wire_connection_points =
    {
        {
            shadow = {red = {0, 0}, green = {0, 0}},
            wire = {red = {0, 0}, green = {0, 0}}
        },
        {
            shadow = {red = {0, 0}, green = {0, 0}},
            wire = {red = {0, 0}, green = {0, 0}}
        },
        {
            shadow = {red = {0, 0}, green = {0, 0}},
            wire = {red = {0, 0}, green = {0, 0}}
        },
        {
            shadow = {red = {0, 0}, green = {0, 0}},
            wire = {red = {0, 0}, green = {0, 0}}
        },
    }
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
    mapmark.icon = "__StickyNotes__/graphics/sign-icon.png"
    mapmark.minable = nil
    mapmark.flags = {}
    mapmark.collision_box = nil
    mapmark.selection_box = nil
    mapmark.drawing_box = nil
    mapmark.collision_mask = {"not-colliding-with-itself"}

    mapmark.tile_width = 1
    mapmark.tile_height = 1

    mapmark.working_sound = nil
    mapmark.vehicle_impact_sound = nil

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
    sticky_text.speed = 0
    sticky_text.time_to_live = 300

    data:extend{invis_note_item, invis_note, sticky_text, mapmark}
