extends Node

@onready var input_box : TextEdit = self.find_child("TextEdit")
@onready var submit_btn : Button = self.find_child("Button")
@onready var output_field : VFlowContainer = self.find_child("VFlowContainer")

var glyph : PackedScene = preload("res://Scenes/glyph.tscn")
#var path : String = "res://Scenes/glyph.tscn"


func _ready() -> void:
	submit_btn.pressed.connect(button_pressed)


func slice_input_string(input : String) -> Array:
	input.strip_edges()
	input.remove_chars(",")
	print(input)
	input.remove_chars(";")
	
	var sliced_input = input.split(" ", true, 0)
	print(sliced_input)
	return sliced_input


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
	new_glyph.draw_glyph()
	new_glyph.is_card = true
	new_glyph.find_child("GlyphBorder").visible = false


func translate_text(text_IDs : Array) -> void:
	for symbol in text_IDs.size():
		spawn_glyph(text_IDs[symbol])


func button_pressed() -> void:
	clear_output_field()
	
	var first_step : Array = slice_input_string(input_box.text)
	
	var second_step : Array = get_id_strings(first_step)
	
	translate_text(second_step)


func clear_output_field() -> void:
	var output_children : Array = output_field.get_children()
	
	for child in output_children.size():
		output_children[child].queue_free()
