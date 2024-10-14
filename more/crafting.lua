--minetest.register_craft({
	--output = "default:coalblock",
	--recipe = {
		--{"default:coal_lump", "default:coal_lump", "default:coal_lump"},
		--{"default:coal_lump", "default:coal_lump", "default:coal_lump"},
		--{"default:coal_lump", "default:coal_lump", "default:coal_lump"},
	--}
--})

minetest.register_craft({
	output = "industrial_tech:iron_coal_powder",
	recipe = {
		{"default:coal_lump", "default:iron_lump"},
	}
})

minetest.register_craft({
	type = "cooking",
	output = "industrial_tech:steel_ingot",
	recipe = "industrial_tech:iron_coal_powder",
})

minetest.register_craft({
	output = "industrial_tech:steel_cauldron",
	recipe = {
		{"industrial_tech:steel_ingot", "","industrial_tech:steel_ingot"},
		{"industrial_tech:steel_ingot", "","industrial_tech:steel_ingot"},
		{"industrial_tech:steel_ingot", "industrial_tech:steel_ingot", "industrial_tech:steel_ingot"},
	}
})

minetest.register_craft({
	output = "industrial_tech:steel_stick",
	recipe = {
		{"industrial_tech:steel_ingot"},
		{"industrial_tech:steel_ingot"},
	}
})

minetest.register_craft({
	output = "industrial_tech:steel_furnace",
	recipe = {
		{"industrial_tech:steel_ingot", "industrial_tech:steel_stick", "industrial_tech:steel_ingot"},
		{"industrial_tech:steel_ingot", "industrial_tech:steel_cauldron", "industrial_tech:steel_ingot"},
		{"industrial_tech:steel_ingot", "industrial_tech:steel_stick", "industrial_tech:steel_ingot"},
	}
})