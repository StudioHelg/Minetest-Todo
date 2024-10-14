-- Function to update the formspec with energy count
local function update_formspec(meta)
    local energy = meta:get_float("energy") or 0
    local max_energy = 10000000  -- Define the maximum energy capacity

    local formspec =
        "size[8,8]" ..
        "label[0,0;Energy Generator]" ..
        "label[0,1;Fuel:]" ..
        "list[current_name;fuel;0,2;1,1;]" ..
        "label[0,4;Energy: " .. math.floor(energy) .. " / " .. max_energy .. "]" ..
        "list[current_player;main;0,6;8,2;]"

    meta:set_string("formspec", formspec)
end

-- Function to check if the generator is underwater
local function is_underwater(pos)
    local node = minetest.get_node(pos)
    local nodedef = minetest.registered_nodes[node.name]
    return nodedef and nodedef.groups and nodedef.groups.water ~= nil
end

-- Function to trigger explosion
local function trigger_explosion(pos)
    minetest.sound_play("tnt_explode", {pos = pos, gain = 1.0, max_hear_distance = 32})
    minetest.set_node(pos, {name = "air"})
    minetest.add_particlespawner({
        amount = 100,
        time = 0.1,
        minpos = {x=pos.x-1, y=pos.y-1, z=pos.z-1},
        maxpos = {x=pos.x+1, y=pos.y+1, z=pos.z+1},
        minvel = {x=-5, y=-5, z=-5},
        maxvel = {x=5, y=5, z=5},
        minacc = {x=0, y=0, z=0},
        maxacc = {x=0, y=0, z=0},
        minexptime = 1,
        maxexptime = 2,
        minsize = 4,
        maxsize = 8,
        texture = "tnt_smoke.png",
    })
    local objects = minetest.get_objects_inside_radius(pos, 3)
    for _, obj in ipairs(objects) do
        if obj:is_player() or obj:get_luaentity() then
            obj:punch(obj, {full_punch_interval = 1.0, damage_groups = {fleshy = 10}}, nil, nil)
        end
    end
end

-- Node definition for the generator
minetest.register_node("industrial_tech:generator", {
    description = "Energy Generator",
    tiles = {
        "generator_top.png",  -- Top
        "generator_bottom.png",  -- Bottom
        "generator_side.png",  -- Side
        "generator_side.png",  -- Side
        "generator_side.png",  -- Side
        "generator_front.png"  -- Front
    },
    paramtype2 = "facedir",
    groups = {cracky = 2},
    on_construct = function(pos)
        local meta = minetest.get_meta(pos)
        meta:set_string("infotext", "Energy Generator")
        meta:set_float("energy", 0)
        local inv = meta:get_inventory()
        inv:set_size("fuel", 1)
        update_formspec(meta)
    end,
    can_dig = function(pos, player)
        local meta = minetest.get_meta(pos)
        local inv = meta:get_inventory()
        return inv:is_empty("fuel")
    end,
    on_place = minetest.rotate_node
})

-- ABM to handle energy generation and explosion
minetest.register_abm({
    nodenames = {"industrial_tech:generator"},
    interval = 1,
    chance = 1,
    action = function(pos, node)
        local meta = minetest.get_meta(pos)
        local inv = meta:get_inventory()
        local fuel_stack = inv:get_stack("fuel", 1)
        local energy = meta:get_float("energy") or 0
        local max_energy = 10000000  -- Define the maximum energy capacity

        if not fuel_stack:is_empty() then
            if is_underwater(pos) then
                trigger_explosion(pos)
            else
                local fuel_time = minetest.get_craft_result({method = "fuel", width = 1, items = {fuel_stack}}).time
                local fuel_rate = (fuel_time / 100) * 1000  -- Calculate energy generation based on fuel burn time

                -- Calculate energy based on fuel
                if energy < max_energy then
                    energy = energy + fuel_rate
                    if energy > max_energy then
                        energy = max_energy
                    end
                    meta:set_float("energy", energy)
                    -- Consume the fuel
                    fuel_stack:take_item()
                    inv:set_stack("fuel", 1, fuel_stack)
                end
            end
        end

        update_formspec(meta)
    end,
})