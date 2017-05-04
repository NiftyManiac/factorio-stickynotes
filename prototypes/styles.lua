data:extend{
    {
        type = "font",
        name = "font_stknt",
        from = "default",
        border = false,
        size = 15
    },
    {
        type = "font",
        name = "font_bold_stknt",
        from = "default-bold",
        border = false,
        size = 15
    },
}

--------------------------------------------------------------------------------------
local default_gui = data.raw["gui-style"].default

default_gui.frame_stknt_style =
{
    type="frame_style",
    parent="frame_style",
    top_padding = 0,
    right_padding = 0,
    bottom_padding = 0,
    left_padding = 0,
    resize_row_to_width = true,
    resize_to_row_height = false,
    -- max_on_row = 1,
}

default_gui.flow_stknt_style =
{
    type = "flow_style",

    top_padding = 0,
    bottom_padding = 0,
    left_padding = 0,
    right_padding = 0,

    horizontal_spacing = 2,
    vertical_spacing = 2,
    resize_row_to_width = true,
    resize_to_row_height = false,
    max_on_row = 1,

    graphical_set = { type = "none" },
}

--------------------------------------------------------------------------------------
default_gui.label_stknt_style =
{
    type="label_style",
    parent="label_style",
    font="font_stknt",
    align = "left",
    default_font_color={r=1, g=1, b=1},
    hovered_font_color={r=1, g=1, b=1},
    top_padding = 1,
    right_padding = 1,
    bottom_padding = 0,
    left_padding = 1,
}

default_gui.label_bold_stknt_style =
{
    type="label_style",
    parent="label_stknt_style",
    font="font_bold_stknt",
    default_font_color={r=1, g=1, b=0.5},
    hovered_font_color={r=1, g=1, b=0.5},
}

default_gui.textfield_stknt_style =
{
    type = "textfield_style",
    font="font_bold_stknt",
    align = "left",
    font_color = {},
    default_font_color={r=1, g=1, b=1},
    hovered_font_color={r=1, g=1, b=1},
    selection_background_color= {r=0.66, g=0.7, b=0.83},
    top_padding = 0,
    bottom_padding = 0,
    left_padding = 1,
    right_padding = 1,
    minimal_width = 300,
    maximal_width = 600,
    graphical_set =
    {
        type = "composition",
        filename = "__core__/graphics/gui.png",
        priority = "extra-high-no-scale",
        corner_size = {3, 3},
        position = {16, 0}
    },
}

default_gui.button_stknt_style =
{
    type="button_style",
    parent="button_style",
    font="font_bold_stknt",
    align = "center",
    default_font_color={r=1, g=1, b=1},
    hovered_font_color={r=1, g=1, b=1},
    top_padding = 0,
    right_padding = 0,
    bottom_padding = 0,
    left_padding = 0,
    left_click_sound =
    {
        {
            filename = "__core__/sound/gui-click.ogg",
            volume = 1
        }
    },
}

default_gui.checkbox_stknt_style =
{
    type = "checkbox_style",
    parent="checkbox_style",
    font = "font_bold_stknt",
    font_color = {r=1, g=1, b=1},
    top_padding = 0,
    bottom_padding = 0,
    left_padding = 0,
    right_padding = 2,
    -- minimal_height = 32,
    -- maximal_height = 32,
}
