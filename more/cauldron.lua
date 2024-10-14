minetest.register_node("industrial_tech:steel_cauldron", {
    description = ("Cauldron"),
    wield_image = "steel_cauldron.png",
    inventory_image = "steel_cauldron.png",
    use_texture_alpha = minetest.features.use_texture_alpha_string_modes and "opaque" or false,
    drawtype = "nodebox",
    paramtype = "light",
    is_ground_content = false,
    groups = {cracky = 2},
    selection_box = { type = "regular" },
    tiles = {
        "cauldrons_cauldron_inner.png^cauldrons_cauldron_top.png",
        "cauldrons_cauldron_inner.png^cauldrons_cauldron_bottom.png",
        "cauldrons_cauldron_side.png"
    },

    on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
        local item_name = itemstack:get_name()
        local meta = minetest.get_meta(pos)
        local cauldron_content = meta:get_string("cauldron_content")

        -- Detectar si el jugador tiene un cubo de agua
        if item_name == "bucket:bucket_water" then
            if cauldron_content == "" then
                -- Llenar el caldero con agua
                meta:set_string("cauldron_content", "water")
                minetest.swap_node(pos, {name = "industrial_tech:steel_cauldron_full_water"})
                itemstack:take_item()
                clicker:get_inventory():add_item("main", "bucket:bucket_empty")
                return itemstack
            end
        end

        -- Detectar si el jugador tiene un cubo de lava
        if item_name == "bucket:bucket_lava" then
            if cauldron_content == "" then
                -- Llenar el caldero con lava
                meta:set_string("cauldron_content", "lava")
                minetest.swap_node(pos, {name = "industrial_tech:steel_cauldron_full_lava"})
                itemstack:take_item()
                clicker:get_inventory():add_item("main", "bucket:bucket_empty")
                return itemstack
            end
        end

        -- Si el jugador tiene un cubo vacío y el caldero tiene agua
        if item_name == "bucket:bucket_empty" and cauldron_content == "water" then
            meta:set_string("cauldron_content", "")
            minetest.swap_node(pos, {name = "industrial_tech:steel_cauldron"})
            itemstack:take_item()
            clicker:get_inventory():add_item("main", "bucket:bucket_water")
            return itemstack
        end

        -- Si el jugador tiene un cubo vacío y el caldero tiene lava
        if item_name == "bucket:bucket_empty" and cauldron_content == "lava" then
            meta:set_string("cauldron_content", "")
            minetest.swap_node(pos, {name = "industrial_tech:steel_cauldron"})
            itemstack:take_item()
            clicker:get_inventory():add_item("main", "bucket:bucket_lava")
            return itemstack
        end
    end,
})

-- Registro de los calderos llenos de agua y lava
minetest.register_node("industrial_tech:steel_cauldron_full_water", {
    description = "Steel Cauldron (Full of Water)",
    tiles = {
        "cauldrons_cauldron_inner.png^cauldrons_cauldron_top_water.png",
        "cauldrons_cauldron_inner.png^cauldrons_cauldron_bottom.png",
        "cauldrons_cauldron_side.png"
    },
    groups = {cracky = 2, not_in_creative_inventory = 1},
    drop = "industrial_tech:steel_cauldron", -- Devuelve el caldero vacío al romperse
    on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
        local meta = minetest.get_meta(pos)
        local item_name = itemstack:get_name()

        -- Vaciar el agua si el jugador tiene un cubo vacío
        if item_name == "bucket:bucket_empty" then
            meta:set_string("cauldron_content", "")
            minetest.swap_node(pos, {name = "industrial_tech:steel_cauldron"})
            itemstack:take_item()
            clicker:get_inventory():add_item("main", "bucket:bucket_water")
        end

        return itemstack
    end,
})

minetest.register_node("industrial_tech:steel_cauldron_full_lava", {
    description = "Steel Cauldron (Full of Lava)",
    tiles = {
        "cauldrons_cauldron_inner.png^cauldrons_cauldron_top_lava.png",
        "cauldrons_cauldron_inner.png^cauldrons_cauldron_bottom.png",
        "cauldrons_cauldron_side.png"
    },
    groups = {cracky = 2, not_in_creative_inventory = 1},
    drop = "industrial_tech:steel_cauldron", -- Devuelve el caldero vacío al romperse
    on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
        local meta = minetest.get_meta(pos)
        local item_name = itemstack:get_name()

        -- Vaciar la lava si el jugador tiene un cubo vacío
        if item_name == "bucket:bucket_empty" then
            meta:set_string("cauldron_content", "")
            minetest.swap_node(pos, {name = "industrial_tech:steel_cauldron"})
            itemstack:take_item()
            clicker:get_inventory():add_item("main", "bucket:bucket_lava")
        end

        return itemstack
    end,
})