-- Update formspec with burn time and cook time indicators
local function update_formspec(meta)
    local burn_time = meta:get_float("burn_time") or 0
    local burn_totaltime = meta:get_float("burn_totaltime") or 0
    local cook_time = meta:get_float("cook_time") or 0
    local cook_totaltime = meta:get_float("cook_totaltime") or 0

    local formspec = 
        "size[10,10]" ..
        "label[2,0;Materials to Burn:]" ..
        "list[current_name;src;2,1;4,2;]" ..
        "label[2,3;Fuel:]" ..
        "list[current_name;fuel;2,4;1,1;]" ..
        "label[7,0;Results:]" ..
        "list[current_name;dst;7,1;2,2;]" ..
        "label[0,0.5;Burn Time: " .. burn_time .. "/" .. burn_totaltime .. "]" ..
        "label[0,1;Cook Time: " .. cook_time .. "/" .. cook_totaltime .. "]" ..
        "list[current_player;main;1,6;8,4;]"

    meta:set_string("formspec", formspec)
end

-- Function to spawn smoke particles
local function spawn_smoke_particles(pos)
    minetest.add_particle({
        pos = vector.add(pos, {x = 0, y = 1, z = 0}),
        velocity = {x = 0, y = 1, z = 0},
        acceleration = {x = 0, y = 0, z = 0},
        expirationtime = 2,
        size = 10,
        texture = "default_smoke.png",
        glow = 8,
    })
end

minetest.register_node("industrial_tech:steel_furnace", {
    description = "Steel Furnace",
    tiles = {
        "steel_furnace_top.png",  -- Top
        "steel_furnace_bottom.png",  -- Bottom
        "steel_furnace_side.png",  -- Side
        "steel_furnace_side.png",  -- Side
        "steel_furnace_side.png",  -- Side
        "steel_furnace_front.png"  -- Front
    },
    paramtype2 = "facedir",
    groups = {cracky = 2},
    on_construct = function(pos)
        local meta = minetest.get_meta(pos)
        meta:set_string("infotext", "Steel Furnace")
        local inv = meta:get_inventory()
        inv:set_size("src", 8) -- 8 slots for input
        inv:set_size("fuel", 1) -- 1 slot for fuel
        inv:set_size("dst", 8) -- 8 slots for output
        update_formspec(meta)
    end,
    can_dig = function(pos, player)
        local meta = minetest.get_meta(pos)
        local inv = meta:get_inventory()
        return inv:is_empty("src") and inv:is_empty("fuel") and inv:is_empty("dst")
    end,
    on_place = minetest.rotate_node
})

minetest.register_abm({
    nodenames = {"industrial_tech:steel_furnace", "industrial_tech:steel_furnace_active"},
    interval = 1,
    chance = 1,
    action = function(pos, node)
        local meta = minetest.get_meta(pos)
        local inv = meta:get_inventory()
        local fuel_stack = inv:get_stack("fuel", 1)
        local burn_time = meta:get_float("burn_time") or 0
        local burn_totaltime = meta:get_float("burn_totaltime") or 0
        local cook_time = meta:get_float("cook_time") or 0
        local cook_totaltime = meta:get_float("cook_totaltime") or 0
        local active = false

        -- Check if there is still burn time left
        if burn_time < burn_totaltime then
            burn_time = burn_time + 1
            meta:set_float("burn_time", burn_time)
            -- Only increase cook time if there are items to cook
            if cook_totaltime > 0 then
                cook_time = cook_time + 1
                meta:set_float("cook_time", cook_time)
            end
            active = true
        end

        -- If burn time is over and there's still fuel, consume it
        if burn_time >= burn_totaltime then
            if not fuel_stack:is_empty() then
                local fuel_result = minetest.get_craft_result({method = "fuel", width = 1, items = {fuel_stack}})
                burn_totaltime = fuel_result.time
                meta:set_float("burn_totaltime", burn_totaltime)
                burn_time = 0
                meta:set_float("burn_time", burn_time)
                fuel_stack:take_item()
                inv:set_stack("fuel", 1, fuel_stack)
                active = true
            else
                burn_totaltime = 0
                meta:set_float("burn_totaltime", burn_totaltime)
            end
        end

        -- Process items to cook
        if cook_time >= cook_totaltime then
            for i = 1, inv:get_size("src") do
                local src_stack = inv:get_stack("src", i)
                if not src_stack:is_empty() then
                    local result, after_cook = minetest.get_craft_result({method = "cooking", width = 1, items = {src_stack}})
                    if not result.item:is_empty() and inv:room_for_item("dst", result.item) then
                        inv:remove_item("src", src_stack:get_name() .. " " .. result.item:get_count())
                        inv:add_item("dst", result.item)
                        cook_totaltime = result.time
                        meta:set_float("cook_totaltime", cook_totaltime)
                        cook_time = 0
                        meta:set_float("cook_time", cook_time)
                        active = true
                        break
                    end
                end
            end
        end

        -- Update formspec
        update_formspec(meta)

        -- If active, show active furnace node, otherwise show inactive
        if active then
            minetest.swap_node(pos, {name = "industrial_tech:steel_furnace_active", param2 = node.param2})
            meta:set_string("infotext", "Steel Furnace (Active)")
            spawn_smoke_particles(pos)
        else
            minetest.swap_node(pos, {name = "industrial_tech:steel_furnace", param2 = node.param2})
            meta:set_string("infotext", "Steel Furnace")
        end
    end,
})

minetest.register_node("industrial_tech:steel_furnace_active", {
    description = "Steel Furnace (Active)",
    tiles = {
        "steel_furnace_top.png",  -- Top
        "steel_furnace_bottom.png",  -- Bottom
        "steel_furnace_side.png",  -- Side
        "steel_furnace_side.png",  -- Side
        "steel_furnace_side.png",  -- Side
        {
            name = "steel_furnace_front_active.png",
            animation = {
                type = "vertical_frames",
                aspect_w = 16,
                aspect_h = 16,
                length = 1.0
            },
        }
    },
    paramtype2 = "facedir",
    groups = {cracky = 2, not_in_creative_inventory = 1},
    drop = "industrial_tech:steel_furnace",
    light_source = 8,
    on_construct = function(pos)
        local meta = minetest.get_meta(pos)
        meta:set_string("infotext", "Steel Furnace")
        local inv = meta:get_inventory()
        inv:set_size("src", 8) -- 8 slots for input
        inv:set_size("fuel", 1) -- 1 slot for fuel
        inv:set_size("dst", 8) -- 8 slots for output
        update_formspec(meta)
    end,
    can_dig = function(pos, player)
        local meta = minetest.get_meta(pos)
        local inv = meta:get_inventory()
        return inv:is_empty("src") and inv:is_empty("fuel") and inv:is_empty("dst")
    end,
})