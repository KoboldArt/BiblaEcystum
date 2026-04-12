extends Node

@onready var main : Node = self.get_parent()
@onready var input_box : TextEdit = main.find_child("TextBlock")
@onready var submit_btn : Button = main.find_child("Submit_Btn")
@onready var output_field : VFlowContainer = main.find_child("Blackboard")

var glyph : PackedScene = preload("res://Scenes/glyph.tscn")
var glyph_count : int

@onready var export_btn : Button = main.find_child("Export_Btn")
@onready var export_frame : SubViewport = main.find_child("Canvas")
@onready var export_window : FileDialog = main.find_child("ExportPopup")

var export_name : String
var export_path : String
var export_img : Image
var subVP_size : Vector2i = Vector2i(588, 720)



func _ready() -> void:
	submit_btn.pressed.connect(button_pressed)
	export_btn.pressed.connect(export_glyph_to_png)
	export_window.file_selected.connect(get_save_params)


func slice_input_string(input : String) -> Array:
	var sliced_input = clean_out_string(input).split(" ", false, 0)
	print(sliced_input)
	return sliced_input


func clean_out_string(raw_string : String) -> String:
	raw_string = raw_string.strip_edges()
	raw_string = raw_string.replace("\'", " ")
	raw_string = raw_string.replace("\"", " ")
	raw_string = raw_string.replace("\\", " ")
	raw_string = raw_string.replace("\a", " ")
	raw_string = raw_string.replace("\b", " ")
	raw_string = raw_string.replace("\f", " ")
	raw_string = raw_string.replace("\n", " ")
	raw_string = raw_string.replace("\r", " ")
	raw_string = raw_string.replace("\t", " ")
	raw_string = raw_string.replace("\v", " ")
	raw_string = raw_string.replace(".", " ")
	raw_string = raw_string.replace(",", " ")
	raw_string = raw_string.replace(";", " ")
	raw_string = raw_string.replace("?", " ")
	raw_string = raw_string.replace("!", " ")
	raw_string = raw_string.replace(":", " ")
	raw_string = raw_string.replace("'", " ")
	raw_string = raw_string.replace("(", " ")
	raw_string = raw_string.replace(")", " ")
	var clean_string = raw_string
	
	return clean_string


func get_id_strings(words_array : Array) -> Array:
	var ID_list : Array
	
	for word in words_array.size():
		ID_list.append(find_glyph(words_array[word]))
	
	return ID_list


func find_glyph(word : String) -> String:
	var result : Array
	var query = "SELECT * FROM prime_index WHERE Definitions MATCH '" + word + "';"
	Core.prime_db.query(query)
	result = Core.prime_db.query_result
	if result.is_empty():
		query = "SELECT * FROM compound_index WHERE Definitions MATCH '" + word + "';"
		Core.comp_db.query(query)
		result = Core.comp_db.query_result
	
	if not result.is_empty():
		return result[0].get("ID")
	else:
		return "000000"


func spawn_glyph(ID : String) -> void:
	var new_glyph = glyph.instantiate()
	output_field.add_child(new_glyph)
	new_glyph.set_meta("Glyph_ID", ID)
	new_glyph.is_card = true
	new_glyph.draw_glyph()
	new_glyph.find_child("GlyphBorder").visible = false


func translate_text(text_IDs : Array) -> void:
	for symbol in text_IDs.size():
		spawn_glyph(text_IDs[symbol])


func button_pressed() -> void:
	clear_output_field()
	
	var first_step : Array = slice_input_string(input_box.text)
	
	var second_step : Array = get_id_strings(first_step)
	
	glyph_count = second_step.size()
	translate_text(second_step)


func clear_output_field() -> void:
	var output_children : Array = output_field.get_children()
	
	for child in output_children.size():
		output_children[child].queue_free()


func export_glyph_to_png() -> void:
	await RenderingServer.frame_post_draw

	export_img = export_frame.get_texture().get_image()
	
	export_window.set_access(FileDialog.ACCESS_FILESYSTEM)
	export_window.set_filters(["*.png"])
	export_window.use_native_dialog = true
	export_window.set_initial_position(Window.WINDOW_INITIAL_POSITION_CENTER_MAIN_WINDOW_SCREEN)
	
	export_window.popup_centered(Vector2i(640, 360))


func get_save_params(_path : String) -> void:
	export_path = export_window.get_current_path()
	export_name = export_window.get_line_edit().text
	save_image()
	clear_buffer(false)


func save_image() -> void:
	var error = export_img.save_png(export_path)
	
	if error == OK:
		print("All good!")
	else:
		print("We fucked up!")


func clear_buffer(toggle_on : bool) -> void:
	if not toggle_on:
		export_img = null
	else:
		return


func set_canvas_size() -> void:
	var unit : Vector2i = Vector2i(164, 164)
	var columns : int = output_field.get_line_count()
	var grid_size : Vector2i = Vector2i(columns, 4)
	export_frame.set_size(Vector2i(grid_size.x * unit.x, grid_size.y * unit.y + 20))
