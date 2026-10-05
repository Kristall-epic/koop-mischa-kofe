const GeoLayout blue_kofe_geo[] = {
	GEO_NODE_START(),
	GEO_OPEN_NODE(),
	GEO_ASM(0, geo_rotate_coin),
		GEO_DISPLAY_LIST(LAYER_OPAQUE, blue_kofe_cup_mesh_layer_1),
	GEO_CLOSE_NODE(),
	GEO_END(),
};
