extends SceneTree
## Bakes the VoxelGI in main.tscn and saves it to res://lighting/voxel_gi.res.
## Run windowed (not --headless) from the repo root:
##   Godot_v4.7.2-stable_win64_console.exe --path room-godot -s res://tools/bake_gi.gd


func _init() -> void:
	var main: Node = load("res://main.tscn").instantiate()
	root.add_child(main)
	# Let _ready() run (materials, collision) and the frame settle before voxelising.
	await process_frame
	await process_frame
	var gi: VoxelGI = main.get_node("VoxelGI")
	gi.data = null
	print("BAKE start")
	gi.bake(main, false)
	print("BAKE done, data: ", gi.data)
	if gi.data == null:
		printerr("BAKE failed: no data")
		quit(1)
		return
	DirAccess.make_dir_recursive_absolute("res://lighting")
	var err := ResourceSaver.save(gi.data, "res://lighting/voxel_gi.res")
	print("SAVE result: ", err)
	quit(0 if err == OK else 1)
