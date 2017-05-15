data:extend{

    {
        type = "string-setting",
        name = "sticky-default-message",
        setting_type = "runtime-global",
        default_value = "",
        allow_blank = true,
        order = "sticky-aa"
    },
    {
        type = "bool-setting",
        name = "sticky-default-autoshow",
        setting_type = "runtime-global",
        default_value = false,
        order = "sticky-bb"
    },
    {
        type = "bool-setting",
        name = "sticky-default-mapmark",
        setting_type = "runtime-global",
        default_value = false,
        order = "sticky-cb"
    },
    {
        type = "bool-setting",
        name = "sticky-use-color-picker",
        setting_type = "runtime-global",
        default_value = true,
        order = "sticky-db"
    },
    {
        type = "int-setting",
        name = "sticky-note-slot-count",
        setting_type = "startup",
        default_value = 51,
        maximum_value = 100,
        minimum_value = 1,
        order = "sticky-z[textsize]-a"
    },
}
