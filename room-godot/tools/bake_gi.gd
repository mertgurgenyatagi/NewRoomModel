extends SceneTree
## Bakes the VoxelGI in main.tscn, once per lighting mode, and saves each to res://lighting/ (voxel_gi.res for
## day, voxel_gi_night.res for night). Run windowed (not --headless) from the repo root:
##   Godot_v4.7.2-stable_win64_console.exe --path room-godot -s res://tools/bake_gi.gd
## To bake only one mode, add it after "--":  ... -s res://tools/bake_gi.gd -- night


func _init() -> void:
	var main: Node = load("res://main.tscn").instantiate()
	root.add_child(main)
	# Let _ready() run (materials, collision, sun placement) and the frame settle before voxelising.
	await process_frame
	await process_frame
	var lighting = main.lighting()
	var modes: Array = Array(OS.get_cmdline_user_args())
	if modes.is_empty():
		modes = lighting.MODES.duplicate()
	DirAccess.make_dir_recursive_absolute("res://lighting")
	var failed := false
	for m in modes:
		lighting.apply(m)
		await process_frame
		await process_frame
		var gi: VoxelGI = main.get_node("VoxelGI")
		gi.data = null
		print("BAKE start: ", m)
		gi.bake(main, false)
		if gi.data == null:
			printerr("BAKE failed: no data for ", m)
			failed = true
			continue
		var err := ResourceSaver.save(gi.data, lighting.gi_path(m))
		print("BAKE done: ", m, ", save result: ", err)
		failed = failed or err != OK
	quit(1 if failed else 0)
