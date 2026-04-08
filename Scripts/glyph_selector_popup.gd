extends Node

@onready var parent_node : Node = self.get_parent()
@onready var popup_contents : Node = self.find_child("PopupContents")
@onready var glyph_button : Button = self.find_child("GlyphButton")

var source_glyph : Node
var source_button : Button
var IDs : Array = []

func _ready() -> void:
	self.visibility_changed.connect(popup_visible)
	
	popup_visible()


func popup_visible() -> void:
	if self.visible:
		populate_list()
	else:
		var clean_list = popup_contents.get_children()
		
		for child in clean_list.size():
			clean_list[child].queue_free()


func populate_list() -> void:
	var database_info : Array = get_glyph_info()
	
	database_info = get_glyph_info()
	
	for data in database_info.size():
		var button = Button.new()
		var ID = database_info[data].get("ID").substr(0, 2)
		
		IDs.append(ID)
		button = glyph_button.duplicate()
		
		button.set_meta("Glyph_ID", ID)
		if ID != "00":
			button.icon = load(str(Core.cur_font, "Full/", ID, ".png"))
		else:
			pass
		button.set_tooltip_text(database_info[data].get("Definitions"))
		
		button.visible = true
		
		popup_contents.add_child(button)
		button.pressed.connect(glyph_selected.bind(button.get_meta("Glyph_ID")))


func get_glyph_info() -> Array:
	var db_master_array : Array = []
	
	var query = "SELECT * FROM prime_index ORDER BY ID ASC;"
	Core.prime_db.query(query)
	db_master_array = Core.prime_db.query_result
	
	return db_master_array


func glyph_selected(ID : String) -> void:
	var source_ID : String
	if source_glyph.get_meta("Glyph_ID") != "":
		source_ID = source_glyph.get_meta("Glyph_ID")
	else:
		source_ID = "000000"
	
	var def_str = source_ID.substr(0, 2)
	var mod1_str = source_ID.substr(2, 2)
	var mod2_str = source_ID.substr(4, 2)
	
	if source_button.text == "Definer":
		if ID == "00":
			source_glyph.set_meta("Glyph_ID", "000000")
			source_glyph.draw_glyph()
			source_glyph.modifier_A_btn.visible = false
			source_glyph.modifier_B_btn.visible = false
		else:
			def_str = ID
			source_glyph.set_meta("Glyph_ID", def_str + mod1_str + mod2_str)
			source_glyph.draw_glyph()
			source_glyph.modifier_A_btn.visible = true
	elif source_button.text == "Modifier A":
		if ID == "00":
			source_glyph.set_meta("Glyph_ID", def_str + "0000")
			source_glyph.draw_glyph()
			source_glyph.modifier_B_btn.visible = false
		else:
			mod1_str = ID
			source_glyph.set_meta("Glyph_ID", def_str + mod1_str + mod2_str)
			source_glyph.draw_glyph()
			source_glyph.modifier_B_btn.visible = true
	elif source_button.text == "Modifier B":
		mod2_str = ID
		source_glyph.set_meta("Glyph_ID", def_str + mod1_str + mod2_str)
		source_glyph.draw_glyph()
	
	#source_glyph.set_meta("Glyph_ID", Core.glyph_string)
	
	source_glyph.drop_popup(source_glyph.popup_window)
