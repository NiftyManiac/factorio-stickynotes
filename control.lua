--luacheck: globals debug_status debug_mod_name debug_file debug_print num color_array colors bool older_version
--luacheck: globals use_color_picker note_slot_count autohide_time text_color_default mapmark_default text_default

debug_status = 0 -- 0=silent, 1=log to file, 2=log to file and print
debug_mod_name = "StickyNotes"
debug_file = debug_mod_name .. "-debug.txt"
require("utils")
require("config")

--local refrences for speeeeeeeed
local bool = bool
local colors = colors
local color_array = color_array
local debug_print = debug_print
local num = num

local max_chars = 4*(note_slot_count-1)-1 -- max length of storable string

local color_picker_interface = "color-picker"
local open_color_picker_button_name = "open_color_picker_stknt"
local color_picker_name = "color_picker_stknt"

--------------------------------------------------------------------------------------
local function menu_note( player, player_mem, open_or_close )
    if open_or_close == nil then
        open_or_close = (player.gui.left.flow_stknt == nil)
    end

    if player.gui.left.flow_stknt then
        player.gui.left.flow_stknt.destroy()
    end

    if open_or_close then
        local gui0
        local gui1, gui2, gui3
        local note = player_mem.note_sel

        if note then
            gui0 = player.gui.left.add({type = "flow", name = "flow_stknt", style = "achievements_flow_style", direction = "horizontal"})
            gui1 = gui0.add({type = "frame", name = "frm_stknt", caption = {"stknt-gui-title", note.n}, style = "frame_stknt_style"})
            gui1 = gui1.add({type = "flow", name = "flw_stknt", direction = "vertical", style = "flow_stknt_style"})

            gui2 = gui1.add({type = "textfield", name = "txt_stknt", text = note.text, style = "textfield_stknt_style"})
            gui2.style.minimal_width = 400

            if use_color_picker and remote.interfaces[color_picker_interface] then
                -- use Color Picker mod if possible.
                gui1.add({type = "button", name = open_color_picker_button_name, caption = {"gui-train.color"}, style = "button_stknt_style"})
            else
                gui2 = gui1.add({type = "flow", name = "flw_stknt_colors", direction = "horizontal", style = "flow_stknt_style"})
                for name, color in pairs(colors) do
                    gui3 = gui2.add({type = "button", name = "but_stknt_col_" .. name, caption = "@", style = "button_stknt_style"})
                    gui3.style.font_color = color
                end
            end

            gui1.add({type = "checkbox", name = "chk_stknt_autoshow", caption = {"stknt-gui-autoshow"}, state = note.autoshow,
                    tooltip = {"stknt-gui-autoshow-tt"}, style = "checkbox_stknt_style"})
            gui1.add({type = "checkbox", name = "chk_stknt_mapmark", caption = {"stknt-gui-mapmark"}, state = (note.mapmark ~= nil),
                    tooltip = {"stknt-gui-mapmark-tt"}, style = "checkbox_stknt_style"})
            gui1.add({type = "checkbox", name = "chk_stknt_locked_force", caption = {"stknt-gui-locked-force"}, state = note.locked_force,
                    tooltip = {"stknt-gui-locked-force-tt"}, style = "checkbox_stknt_style"})
            if player.admin then
                gui1.add({type = "checkbox", name = "chk_stknt_locked_admin", caption = {"stknt-gui-locked-admin"}, state = note.locked_admin,
                        tooltip = {"stknt-gui-locked-admin-tt"}, style = "checkbox_stknt_style"})
            end

            gui1.add({type = "button", name = "but_stknt_delete", caption = {"stknt-gui-delete"},
                    tooltip = {"stknt-gui-delete-tt"}, style = "button_stknt_style"})
            gui1.add({type = "button", name = "but_stknt_close", caption = {"stknt-gui-close"},
                    tooltip = {"stknt-gui-close-tt"}, style = "button_stknt_style"})
        end
    end
end

--------------------------------------------------------------------------------------
local function display_mapmark( note, on_or_off )
    if note.mapmark and note.mapmark.valid then
        note.mapmark.destroy()
    end

    note.mapmark = nil

    if on_or_off and note.invis_note and note.invis_note.valid then
        local mapmark = note.invis_note.surface.create_entity({name = "sticky-note-mapmark", force = game.forces.neutral, position = note.invis_note.position})
        if mapmark then
            mapmark.destructible = false
            mapmark.operable = false
            mapmark.active = false
            mapmark.backer_name = note.text
            note.mapmark = mapmark
        end
    end
end

--!!
local function create_invis_note( entity )
    local surf = entity.surface
    local invis_note = surf.create_entity(
        {
            name = "invis-note",
            position = entity.position,
            direction = entity.direction,
            force = entity.force
        })
    invis_note.destructible = false
    invis_note.operable = false
    return invis_note
end

--------------------------------------------------------------------------------------
-- store the note data into an existing invis-note
local function encode_note( note )
    local encoding_version = 1
    local invis_note = note.invis_note

    if invis_note then
        -- metadata bytes (big endian): <encoding version>, <reserved>, <flags>, <color index>
        local metadata = 0
        metadata = bit32.replace(metadata, encoding_version, 24, 8)

        metadata = bit32.replace(metadata, num(note.autoshow), 8)
        metadata = bit32.replace(metadata, num(note.mapmark ~= nil), 9)
        metadata = bit32.replace(metadata, num(note.locked_force), 10)
        metadata = bit32.replace(metadata, num(note.locked_admin), 11)

        local color = note.color
        local color_index
        for i, v in pairs(color_array) do
            if color.r == v.r and color.g == v.g and color.b == v.b then
                color_index = i
                break
            end
        end
        if color_index == nil or color_index>255 then
            debug_print("Colors must be hardcoded and be no more than 255 in number")
            return
        end

        debug_print("Color: "..note.color.r..note.color.g..note.color.b)
        debug_print("Color index: "..color_index)

        metadata = bit32.replace(metadata, color_index, 0, 8)

        debug_print("Encoded metadata: "..metadata)

        -- array of encoded values to store in the invis-note
        local signal_vals = {}
        for i = 1, note_slot_count do
            signal_vals[i] = -2 ^ 31
        end

        signal_vals[1] = signal_vals[1] + metadata
        debug_print("Encoded metadata2: "..signal_vals[1])

        for i = 1,#note.text+1 do
            local signal_i = math.floor((i-1)/4)
            local shift = (i-1)%4 * 8
            local val
            if i == #note.text+1 then
                val = 0 -- string termination
            else
                val = string.byte(note.text,i)
            end
            signal_vals[signal_i+2] = signal_vals[signal_i+2] + val * 2 ^ shift
        end
        debug_print("Text1: ",signal_vals[2])
        debug_print("Text2: ",signal_vals[3])
        if #signal_vals > note_slot_count then
            debug_print("String length must not exceed "..(4*(note_slot_count-1))..". Increase note_slot_count in config.lua if needed.")
            return
        end

        local params = {}
        for i, v in pairs(signal_vals) do
            table.insert(params,
                {
                    signal =
                    {
                        type = "virtual",
                        name = "signal-0"
                    },
                    count = v,
                    index = i
                })
        end

        -- assign encoded values to invis_note
        invis_note.get_or_create_control_behavior().parameters = {parameters = params};
    end
end

--------------------------------------------------------------------------------------
-- decode an invis_note and return a note object. Also, create a mapmark if needed.
-- returns nil if decode failed
-- encoding versions changes:
--  2.0.0: 0
--  2.0.1: 1
local function decode_note( invis_note, target )
    local note = {}
    note.invis_note = invis_note
    note.target = target
    note.target_unit_number = target.unit_number -- needed in case target becomes invalid

    local params = invis_note.get_or_create_control_behavior().parameters.parameters
    local metadata = params[1].count + 2^31

    local version = bit32.extract(metadata, 24, 8)

    local terminator = 0
    if version==0 then
        terminator = 3
    end

    if version==0 or version==1 then
        note.autoshow = bool(bit32.extract(metadata, 8))
        local show_mapmark = bool(bit32.extract(metadata, 9))
        note.locked_force = bool(bit32.extract(metadata, 10))
        note.locked_admin = bool(bit32.extract(metadata, 11))

        local color_i = bit32.extract(metadata, 0, 8) 
        note.color = color_array[color_i]
        if note.color == nil then
            debug_print("Failed to decode color")
        end

        note.text = ""
        for i = 1, (note_slot_count-1)*4 do
            local signal_i = math.floor((i-1)/4)
            local shift = (i-1)%4 * 8

            local byte = bit32.extract(params[signal_i+2].count+2^31, shift, 8)
            if byte == terminator then
                break
            end
            note.text = note.text .. string.char(byte)
        end

        display_mapmark(note, show_mapmark)

    else
        game.print("StickyNotes failed to decode a note, as it was made with a newer version of the mod. Please install the newest version of StickyNotes and try again.")
        return
    end

    debug_print("Decoded note (ver "..version.."): "..note.text)

    return note
end

--------------------------------------------------------------------------------------
local function show_note( note )
    if note.fly then return end

    if note.invis_note and note.invis_note.valid then
        local pos = note.invis_note.position
        local surf = note.invis_note.surface
        --local force = note.invis_note.force
        local x = pos.x-1
        local y = pos.y

        local fly = surf.create_entity({name="sticky-text",text=note.text,color=note.color,position={x=x,y=y}})
        if fly then
            note.fly = fly
            note.fly.active = false
            note.autohide_tick = game.tick + autohide_time
        end
    end
end

--------------------------------------------------------------------------------------
local function hide_note( note )
    if note.fly and note.fly.valid then
        note.fly.destroy()
    end
    note.fly = nil
end

--------------------------------------------------------------------------------------
local function destroy_note( note )
    for i, player in pairs(game.players) do
        if player.connected then
            local player_mem = global.player_mem[i]

            if player_mem.note_sel == note then
                menu_note(player,player_mem,false)
                player_mem.note_sel = nil
            end
        end
    end

    hide_note(note)

    if note.mapmark and note.mapmark.valid then
        note.mapmark.destroy()
    end
    note.mapmark = nil

    global.notes_by_invis[note.invis_note.unit_number] = nil
    global.notes_by_target[note.target_unit_number] = nil

    if note.invis_note and note.invis_note.valid then
        note.invis_note.destroy()
    end
end

--------------------------------------------------------------------------------------
-- lookup the note of an invis-note or a target entity
local function get_note( ent )
    if ent.name == "invis-note" then
        return global.notes_by_invis[ent.unit_number]
    end
    return global.notes_by_target[ent.unit_number]
end

--------------------------------------------------------------------------------------
local function register_note( note )
    debug_print("Registering note")
    global.n_note = global.n_note + 1
    note.n = global.n_note;
    global.notes_by_target[note.target.unit_number] = note
    global.notes_by_invis[note.invis_note.unit_number] = note
end
--------------------------------------------------------------------------------------

local function update_note_target(note, new_target)
    if note.target then
        global.notes_by_target[note.target_unit_number] = nil
    end
    note.target = new_target
    note.target_unit_number = new_target.unit_number
    global.notes_by_target[new_target.unit_number] = note
end

--------------------------------------------------------------------------------------
local function add_note( entity )

    local note =
    {
        text = "text " .. global.n_note+1, -- text
        color = text_color_default, -- color
        n = nil, -- number of the note
        fly = nil, -- text entity
        autoshow = false, -- if true, then note autoshows/hides
        autohide_tick = game.tick + autohide_time, -- tick when to autohide
        mapmark = nil, -- mark on the map
        locked_force = true, -- only modifiable by the same force
        locked_admin = false, -- only modifiable by admins
        editer = nil, -- player currently editing
        is_sign = (entity.name == "sticky-note" or entity.name == "sticky-sign"), -- is connected to a real note/sign object
        invis_note = create_invis_note(entity),
        target = entity,
        target_unit_number = entity.unit_number -- needed in case target becomes invalid
    }

    if text_default ~= nil then
        note.text = text_default
    end
    show_note(note)

    register_note(note)

    if mapmark_default == true then
        display_mapmark(note,true)
    end

    encode_note(note)

    return(note)
end

--------------------------------------------------------------------------------------
local function init_globals()
    -- initialize or update general globals of the mod
    debug_print( "init_globals" )

    global.tick = global.tick or 0
    global.player_mem = global.player_mem or {}

    global.notes_by_invis = global.notes_by_invis or {}
    global.notes_by_target = global.notes_by_target or {}
    global.n_note = global.n_note or 0
end

--------------------------------------------------------------------------------------
local function init_player(player)
    if global.player_mem == nil then return end

    -- initialize or update per player globals of the mod, and reset the gui
    debug_print( "init_player ", player.name, " connected=", player.connected )

    global.player_mem[player.index] = global.player_mem[player.index] or {}

    local player_mem = global.player_mem[player.index]
    player_mem.note_sel = player_mem.note_sel or nil
end

--------------------------------------------------------------------------------------
local function init_players()
    for _, player in pairs(game.players) do
        init_player(player)
    end
end

--------------------------------------------------------------------------------------
local function init_forces()
    for _,force in pairs(game.forces) do
        force.recipes["sticky-note"].enabled = force.technologies["sticky-notes"].researched
        force.recipes["sticky-sign"].enabled = force.technologies["sticky-notes"].researched
    end
end

--------------------------------------------------------------------------------------
local function on_init()
    -- called once, the first time the mod is loaded on a game (new or existing game)
    debug_print( "on_init" )
    init_globals()
    init_players()
end

script.on_init(on_init)

--------------------------------------------------------------------------------------
local function on_configuration_changed(data)

    -- detect any mod or game version change
    debug_print("Config changed ")
    if data.mod_changes ~= nil then
        local changes = data.mod_changes[debug_mod_name]
        if changes ~= nil then
            debug_print( "update mod: ", debug_mod_name, " ", tostring(changes.old_version), " to ", tostring(changes.new_version) )

            init_globals()
            init_forces()
            init_players()

            -- close all notes menu, by precaution

            for i, player in pairs(game.players) do
                if player.connected then
                    local player_mem = global.player_mem[i]
                    menu_note(player,player_mem,false)
                    player_mem.note_sel = nil
                end
            end

            if changes.old_version and older_version(changes.old_version, "1.0.8") then
                game.print( "Sticky Notes: please now use the ALT-W key instead of ENTER (or redefine it in the menu/options)." )
                game.print( "Sticky Notes: you can now add a text on any entity on the map." )
            end

            if changes.old_version and older_version(changes.old_version, "1.0.12") then
                for _,note in pairs(global.notes) do
					--Not perfect, TODO expand logic to clean when entity is invalid
                    local ent_name = note.entity and note.entity.valid and note.entity.name or ""
                    note.locked_force = note.locked
                    note.locked_admin = false
                    note.is_sign = (ent_name == "sticky-note" or ent_name == "sticky-sign")
                end

                game.print( "Sticky Notes: new option to lock notes for admins." )
            end

            if changes.old_version and older_version(changes.old_version, "2.0.0") then
                -- encode all notes
                for _,note in pairs(global.notes) do
                    if note.invis_note == nil and note.entity and note.entity.valid then
                        debug_print('Upgrading '..note.text)
                        note.invis_note = create_invis_note(note.entity)
                        encode_note(note)

                        update_note_target(note, note.entity)
                        global.notes_by_invis[note.invis_note.unit_number] = note

                        note.entity = nil
                    end
                    --convert old flying-text to new flying-text
                    if note.fly and note.fly.valid and note.fly.name == "flying-text" then
                        note.fly.destroy()
                        note.fly = nil
                        show_note(note)
                    end
                end
                global.notes = nil
                game.print( "Sticky Notes: notes will now persist through blueprints, and can be shared with blueprint strings.")

            elseif changes.old_version and older_version(changes.old_version, "2.1.0") then --elseif is not a typo, there's two separate migrations here  
                -- replace global.notes with global.notes_by_invis and global.notes_by_target
                for _,note in pairs(global.notes) do
                    local invis_note = note.invis_note
                    local targets = invis_note.surface.find_entities_filtered{position=invis_note.position}
                    for _,target in pairs(targets) do
                        if target ~= invis_note then
                            update_note_target(note, target)
                            global.notes_by_invis[note.invis_note.unit_number] = note
                            break
                        end
                    end
                end
            end
        end
    end
end

script.on_configuration_changed(on_configuration_changed)

--------------------------------------------------------------------------------------
local function on_player_created(event)
    -- called at player creation
    local player = game.players[event.player_index]
    debug_print( "player created ", player.name )

    init_player(player)

    if debug_status == 1 then
        if #game.players > 1 then
            local force = game.create_force(player.name .. "-force")
            player.force = force
        end
        local inv = player.get_inventory(defines.inventory.player_quickbar)
        inv.insert({name="sticky-note", count=50})
        inv.insert({name="sticky-sign", count=50})
    end
end

script.on_event(defines.events.on_player_created, on_player_created )

--------------------------------------------------------------------------------------
local function on_player_joined_game(event)
    -- called in SP(once) and MP(at every connect), eventually after on_player_created
    local player = game.players[event.player_index]
    debug_print( "player joined ", player.name )

    init_player(player)
end

script.on_event(defines.events.on_player_joined_game, on_player_joined_game )

--------------------------------------------------------------------------------------
-- !!fix sign behaviors
local function on_creation( event )
    local ent = event.created_entity
    local debug_name = ent.name
    if debug_name=="entity-ghost" then
        debug_name = debug_name.." "..ent.ghost_name
    end
    debug_print( "on_creation ", debug_name, " ", ent.unit_number)

    -- revive note ghosts immediately
    if ent.name == "entity-ghost" and ent.ghost_name == "invis-note" then
        local revived, rev_ent = ent.revive()
        if revived then
            debug_print("Revived invis-note")
            ent = rev_ent
        end
    end

    if ent.name == "invis-note" then
        ent.destructible = false;
        ent.operable = false;

		-- only place an invis-note on a ghost, if that ghost doesn't already have a note
        local note_target
		
		-- With instant blueprint, the entity revive order is different between different entities. It is known that oil-refinery > invis-note > chest.
		-- In case the target has not been revived yet, e.g. no instant blueprint, or chest with instant blueprint.
		local note_targets = ent.surface.find_entities_filtered{name = "entity-ghost", position = ent.position, force = ent.force, limit = 1}
		if #note_targets > 0 then
			local target = note_targets[1]
			if target.valid and get_note(target) == nil then
				note_target = target
			end
		end
		-- In case the target has already been revived, e.g. oil-refinery with instant blueprint.
		if not note_target then
			note_targets = ent.surface.find_entities_filtered{position = ent.position, force = ent.force}
			for _, target in pairs(note_targets) do
				debug_print("target"..target.name)
				if target.prototype.has_flag("player-creation") then
					if target.valid and get_note(target) == nil then
						note_target = target
					end
					break
				end
			end
		end
		
        if note_target then
            debug_print("Decoding invis-note")
            local note = decode_note(ent, note_target)
            if note then
                note.invis_note.teleport(note.target.position) -- align the note to avoid adding up error
                register_note(note)
                show_note(note)
                display_mapmark(note, note.mapmark)
            else
                -- we could keep around the invis-note in case they install a newer version that makes it readable
                -- but then we'd have to keep track of the invis-notes on the map, instead of just decoding on creation
                debug_print("Decoding failed")
                ent.destroy()
            end

        else
            debug_print("No valid note target found")
            ent.destroy()
        end
		
    elseif ent.name ~= "entity-ghost" then -- when a normal item is placed figure out what ghosts are destroyed
        debug_print("Placed nonghost")
		
		if (ent.name == "sticky-note" or ent.name == "sticky-sign") then
			ent.destructible = false
			ent.operable = false
		end
		
        local x = ent.position.x
        local y = ent.position.y
        local invis_notes = ent.surface.find_entities_filtered{name="invis-note",area={{x-10,y-10},{x+10, y+10}}}
        for _,invis_note in pairs(invis_notes) do
            local note = get_note(invis_note)
            if not note.target.valid then -- if we deleted a ghost with this placement
                if math.abs(invis_note.position.x-x)<0.01 and math.abs(invis_note.position.y-y)<0.01 then -- if we replaced a correct ghost, reassign
                    update_note_target(note, ent)
                else -- we destroyed an unrelated ghost
                    destroy_note(note)
                end
            end
        end
    end
end

script.on_event(defines.events.on_built_entity, on_creation )
script.on_event(defines.events.on_robot_built_entity, on_creation )

--------------------------------------------------------------------------------------
local function on_destruction( event )
    local ent = event.entity

    local note = get_note(ent)

    if note then
        debug_print( "on_destruction ", ent.name )
        destroy_note(note)
    end
end

script.on_event(defines.events.on_entity_died, on_destruction )
script.on_event(defines.events.on_robot_pre_mined, on_destruction )
script.on_event(defines.events.on_preplayer_mined_item, on_destruction )

--------------------------------------------------------------------------------------
local function on_marked_for_deconstruction( event )
    local ent = event.entity

    if ent.name == "invis-note" then
        local note = get_note(ent)
        debug_print("Marked for decon")
        if not note.target.valid or note.target.name == "entity-ghost" then 
            destroy_note(note)
        else -- if target is still valid, just cancel deconstruction
            local force = (event.player_index and game.players[event.player_index].force) or
                          (ent.last_user and ent.last_user.force) or
                          ent.force
            ent.cancel_deconstruction(force)
        end
    end
end

script.on_event(defines.events.on_marked_for_deconstruction, on_marked_for_deconstruction)

--------------------------------------------------------------------------------------
local function on_tick()
    if global.tick <= 0 then
        -- auto show notes
        global.tick = 28

        for _, player in pairs(game.connected_players) do
            local selected = player.selected

            if selected then
                local note = get_note(selected)
                if note and note.autoshow then
                    show_note(note)
                end
            end
        end

    elseif global.tick == 13 then
        -- cleaning and auto hiding notes

        for _,note in pairs(global.notes_by_invis) do
            if note.invis_note and note.invis_note.valid then
                if note.autoshow and note.fly and note.editer == nil and game.tick > note.autohide_tick then
                    hide_note(note)
                end
            else
                destroy_note(note)
            end
        end
    end

    global.tick = global.tick -1
end

script.on_event(defines.events.on_tick, on_tick)

--------------------------------------------------------------------------------------
local function on_gui_text_changed(event)
    local player = game.players[event.player_index]
    local event_name = event.element.name

    debug_print( "on_gui_text_changed ", player.name, " ", event_name )

    if event_name == "txt_stknt" then
        local player_mem = global.player_mem[player.index]
        local note = player_mem.note_sel

        if note then
            if #event.element.text > max_chars then
                event.element.text = string.sub(event.element.text, 1, max_chars)
                game.print("StickyNotes: Notes are limited to "..max_chars.." in length. To raise this limit, edit config.lua.")
            end

            note.text = event.element.text
            encode_note(note)

            hide_note(note)
            show_note(note)
            if note.mapmark then
                display_mapmark(note,true)
            end
        end
    end
end

script.on_event(defines.events.on_gui_text_changed,on_gui_text_changed)

--------------------------------------------------------------------------------------
local function on_gui_click(event)
    local player = game.players[event.player_index]
    local event_name = event.element.name
    local prefix = string.sub(event_name,1,14)
    local suffix = string.sub(event_name,15)

    debug_print( "on_gui_click ", player.name, " ", event_name )

    if event_name == "but_stknt_close" then
        local player_mem = global.player_mem[player.index]
        local note = player_mem.note_sel

        if note then
            note.editer = nil
        end

        menu_note(player,player_mem,false)
        player_mem.note_sel = nil

    elseif event_name == "but_stknt_delete" then
        local player_mem = global.player_mem[player.index]
        local note = player_mem.note_sel

        if note then
            destroy_note(note)
            menu_note(player,player_mem,false)
            player_mem.note_sel = nil
        end

    elseif prefix == "but_stknt_col_" then
        local player_mem = global.player_mem[player.index]
        local note = player_mem.note_sel
        local color = colors[suffix]

        if color and note then
            note.color = color
            encode_note(note)
            hide_note(note)
            show_note(note)
        end

    elseif event_name == "chk_stknt_autoshow" then
        local player_mem = global.player_mem[player.index]
        local note = player_mem.note_sel

        if note then
            note.autoshow = event.element.state
            encode_note(note)
            if note.autoshow then
                hide_note(note)
            else
                show_note(note)
            end
        end

    elseif event_name == "chk_stknt_mapmark" then
        local player_mem = global.player_mem[player.index]
        local note = player_mem.note_sel

        if note then
            if event.element.state then
                display_mapmark(note,true)
            else
                display_mapmark(note,false)
            end
        end
        encode_note(note)

    elseif event_name == "chk_stknt_locked_force" then
        local player_mem = global.player_mem[player.index]
        local note = player_mem.note_sel

        note.locked_force = event.element.state
        encode_note(note)

    elseif event_name == "chk_stknt_locked_admin" then
        if player.admin then
            local player_mem = global.player_mem[player.index]
            local note = player_mem.note_sel

            note.locked_admin = event.element.state
            encode_note(note)

            if note.is_sign then
                if note.locked_admin then
                    note.target.minable = false
                else
                    note.target.minable = true
                end
            end
        end

    elseif event_name == open_color_picker_button_name then
        -- open color picker.
        local flow = player.gui.left.flow_stknt
        if flow then
            if flow[color_picker_name] then
                flow[color_picker_name].destroy()
            else
                remote.call(color_picker_interface, "add_instance",
                    {
                        parent = flow,
                        container_name = color_picker_name,
                        color = global.player_mem[player.index].note_sel and global.player_mem[player.index].note_sel.color,
                        show_ok_button = true,
                        -- result_caption = "@@@@@@"
                    }
                )
            end
        end
    end
end

script.on_event(defines.events.on_gui_click, on_gui_click)

--------------------------------------------------------------------------------------
local function on_hotkey_write(event)
    local player = game.players[event.player_index]
    local player_mem = global.player_mem[player.index]
    local selected = player.selected
    local note = nil

    if selected and player.force.technologies["sticky-notes"].researched then
        note = get_note(selected)

        if note == nil and player.force == selected.force then
            -- add a new note
            local type = selected.type

            -- do not add a text on movable objects or rails.

            if type ~= "car"
            and type ~= "tank"
            and type ~= "player"
            and type ~= "unit"
            and type ~= "unit-spawner"
            and type ~= "straight-rail"
            and type ~= "curved-rail"
            and type ~= "locomotive"
            and type ~= "cargo-wagon"
            and type ~= "logistic-robot"
            and type ~= "construction-robot"
            and type ~= "combat-robot"
            then
                note = add_note(selected)
            end
        end
    end

    local previous = player_mem.note_sel

    if previous ~= note then
        -- hide the previous menu
        if previous then
            previous.editer = nil
            menu_note(player,player_mem,false)
            player_mem.note_sel = nil
        end

        -- show the new menu
        if note and (note.editer == nil or not note.editer.connected) and (note.invis_note.force == player.force or not note.locked_force) and (player.admin or not note.locked_admin) then
            player_mem.note_sel = note
            note.editer = player
            menu_note(player,player_mem,true)
        end
    end
end

script.on_event("notes_write_hotkey", on_hotkey_write)

--------------------------------------------------------------------------------------
if remote.interfaces[color_picker_interface] then
    -- color picker events.
    script.on_event(remote.call(color_picker_interface, "on_color_updated"),
        function(event)
            if event.container.name == color_picker_name then
                local player_mem = global.player_mem[event.player_index]
                local note = player_mem.note_sel
                local color = event.color

                if color and note then
                    note.color = color
                    hide_note(note)
                    show_note(note)
                end
            end
        end
    )

    script.on_event(remote.call(color_picker_interface, "on_ok_button_clicked"),
        function(event)
            if event.container.name == color_picker_name then
                event.container.destroy()
            end
        end
    )
end

--------------------------------------------------------------------------------------
local interface = {}

function interface.delete_all()
    debug_print( "delete all" )
    for _,note in pairs(global.notes_by_invis) do
        destroy_note(note)
    end
    for _,note in pairs(global.notes_by_target) do
        destroy_note(note)
    end
end

function interface.count()
    local count = 0
    for _,note in pairs(global.notes_by_invis) do
        count = count+1
    end
    game.print("Notes by invis-notes: "..count)
    count = 0
    for _,note in pairs(global.notes_by_target) do
        count = count+1
    end
    game.print("Notes by targets: "..count)
end

-- destroy any remaining notes without targets or invis-notes
-- also, make sure notes are aligned with their targets
function interface.clean()
    local destroy_count = 0
    local align_count = 0

    local function fix_note(note)
        if not note.invis_note.valid or not note.target.valid then
            destroy_note(note)
            destroy_count = destroy_count+1
        elseif note.invis_note.position.x ~= note.target.position.x or 
                note.invis_note.position.y ~= note.target.position.y then
            note.invis_note.teleport(note.target.position)
            hide_note(note)
            show_note(note)
            align_count = align_count+1;
        end
    end
    for _,note in pairs(global.notes_by_invis) do
        fix_note(note)
    end
    for _,note in pairs(global.notes_by_target) do
        fix_note(note)
    end
    game.print("Cleaned out "..destroy_count.." notes")
    game.print("Aligned "..align_count.." notes")
end

function interface.print_global()
	game.print(serpent.block(global, {comment=false}))
	game.write_file("StickyNotes/Global.lua", serpent.block(global, {comment=false}))
end

function interface.add_note(entity,parameters)
	add_note(entity)
	interface.modify_note( entity, parameters)
end

function interface.remove_note(entity)
	local note=get_note(entity)
	if note then destroy_note(note) end
end

local isset = function(val) 
	return val and true or val==false
end
local writable_fields={--[fieldname]=function(value,note), functions should perform check of the passed values and transformations as needed 
        text = function(note,t)
			note.text=t and tostring(t):sub(1, max_chars)
		end, -- text
        color = function(note,color_name) 
			note.color=colors[color_name] or note.color
		end, -- color
        autoshow = function(note,bool)
			note.autoshow = bool
		end, -- if true, then note autoshows/hides
        mapmark = function(note,bool)
			display_mapmark(note,bool)
        end, -- mark on the map
        locked_force = function(note,bool)
			note.locked_force = bool
		end, -- only modifiable by the same force
        locked_admin = function(note, bool)
			if note.is_sign then 
				if bool then
					note.target.minable = false
				else
					note.target.minable = true
				end
			end
        end, -- only modifiable by admins
    }
    
function interface.modify_note(entity,par)
	local note=get_note(entity)
	if not note then return end
    for k,v in pairs(writable_fields) do 
		if isset(par[k]) then v(note,par[k]) end
	end
    
    encode_note(note)
	hide_note(note)
	show_note(note)
	if note.mapmark then
		display_mapmark(note,true)
	end
end

remote.add_interface( "StickyNotes", interface )

-- /c remote.call( "StickyNotes", "clean" )
