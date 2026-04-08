extends Node

@onready var dictionary_glyph : Node = self.find_child("Glyph_Dict")
@onready var composer_glyph : Node = self.find_child("Glyph_Comp")
@onready var search_box: LineEdit = self.find_child("SearchBox")
@onready var display_box: RichTextLabel = self.find_child("DisplayBox")
@onready var search_button: Button = self.find_child("SearchButton")
@onready var suggestion_scroll : ScrollContainer = self.find_child("SuggestionScroll")
@onready var suggestion_list : VBoxContainer = self.find_child("SuggestionList")
@onready var add_to_dict : Button = self.find_child("AddToDictionary")
@onready var definition_box : TextEdit = self.find_child("DefinitionBox")
@onready var feedback_display : RichTextLabel = self.find_child("1_IbC_FeedbackMsg")
@onready var font_selector : OptionButton = self.find_child("FontSelector")

var suggestion_scroll_length : int


func _ready() -> void:
	Core.font_selector = font_selector
	Core.font_selector.item_selected.connect(Core.new_font_selected)
	
	## Glyph Composer Resources ##
	Validator.glyph_node = composer_glyph
	Validator.definition_box = definition_box
	Validator.feedback_display = feedback_display
	
	add_to_dict.pressed.connect(_on_add_to_dictionary_pressed)
	
	search_box.text_submitted.connect(_on_input_box_text_submitted)
	search_box.text_changed.connect(_on_input_box_text_update)
	search_button.pressed.connect(_on_search_button_pressed)
	
	suggestion_scroll.visible = false
	
	glyph_edit_visible()


func glyph_edit_visible() -> void:
	composer_glyph.update_button_visibility(Vector3(1, 0, 0))
	dictionary_glyph.update_button_visibility(Vector3(0, 0, 0))


func get_input_box_string(is_suggestion : bool) -> void:
	display_box.text = ""
	dictionary_glyph.set_meta("Glyph_ID", "000000")
	dictionary_glyph.draw_glyph()
	
	if is_suggestion:
		if search_box.text.length() > 1:
			search_box.set_keep_editing_on_text_submit(true)
			suggest_search(search_box.text)
		else:
			return
	else:
		stepped_search(search_box.text)


func _on_search_button_pressed() -> void:
	suggestion_scroll.visible = false
	get_input_box_string(false)


func _on_input_box_text_submitted(_new_text: String) -> void:
	suggestion_scroll.visible = false
	get_input_box_string(false)


func stepped_search(search_string : String) -> void:
	var search = db_search(Core.prime_db, search_string, "prime_index")

	if search != []:
		dictionary_glyph.set_meta("Glyph_ID", search[0].get("ID"))
		dictionary_glyph.draw_glyph()
		display_box.text = search[0].get("Definitions")
	else:
		search = db_search(Core.comp_db, search_string, "compound_index")
		if search != []:
			dictionary_glyph.set_meta("Glyph_ID", search[0].get("ID"))
			dictionary_glyph.draw_glyph()
			display_box.text = search[0].get("Definitions")
		else:
			dictionary_glyph.set_meta("Glyph_ID", "000000")
			dictionary_glyph.draw_glyph()
			display_box.text = "Unknown Phrase"
			return


func db_search(database : SQLite, search_term : String, table : String) -> Variant:
	var query = "SELECT * FROM " + table + " WHERE Definitions MATCH '" + search_term + "';"
	database.query(query)
	
	return database.query_result


func _on_input_box_text_update(_new_text: String) -> void:
	suggestion_scroll.visible = false
	suggestion_scroll_length = 0
	clear_suggestion_list(suggestion_list.get_children())
	get_input_box_string(true)


func clear_suggestion_list(list_array : Array) -> void:
	for node in list_array.size():
		suggestion_list.remove_child(list_array[node])


func suggest_search(new_string : String) -> void:
	var suggested_rows : Array
	var suggested_words : Array
	
	suggested_rows.append_array(db_suggest(Core.prime_db, new_string, "prime_index"))
	suggested_rows.append_array(db_suggest(Core.comp_db, new_string, "compound_index"))
	
	for row in suggested_rows.size():
		var split_row = suggested_rows[row].split(", ", true, 0)
		var filter : Array
		
		filter.append_array(split_row)
		for word in filter.size():
			if filter[word].begins_with(new_string):
				suggested_words.append(filter[word])
			else:
				continue
	
	suggested_words.sort()
	
	if suggested_words.size() > 0:
		fill_suggestion_list(suggested_words)
		suggestion_scroll.visible = true
	else:
		return


func db_suggest(database : SQLite, search_term : String, table : String) -> Variant:
	var query = "SELECT * FROM " + table + " WHERE Definitions Like ?"
	var binding : Array = ["%" + search_term + "%"]
	database.query_with_bindings(query, binding)
	var rows : Array = database.query_result.map(func(row): return row["Definitions"])
	
	return rows


func fill_suggestion_list(suggestions : Array) -> void:
	for word in suggestions.size():
		create_suggestion_button(suggestions[word])


func create_suggestion_button(btn_text : String) -> void:
	var button = Button.new()
	
	button.text = btn_text
	button.custom_minimum_size.x = 200
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	button.pressed.connect(suggestion_selected.bind(btn_text))
	button.theme_type_variation = "FlatButton"
	
	suggestion_list.add_child(button)
	suggestion_scroll_length += 32
	suggestion_scroll.custom_minimum_size.y = suggestion_scroll_length


func suggestion_selected(button_text : String) -> void:
	suggestion_scroll.visible = false
	search_box.text = button_text
	_on_search_button_pressed()


func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_ESCAPE:
			suggestion_scroll.visible = false
		elif event.pressed and event.keycode == KEY_DOWN:
			if search_box.is_editing():
				search_box.unedit()


func _on_add_to_dictionary_pressed() -> void:
	var def_pack : Array = [definition_box.text, ""]
	var ID_pack : Array = [composer_glyph.get_meta("Glyph_ID"), ""]
	
	Validator.validate_entry(def_pack, ID_pack, Core.comp_db, [true, false, false])


func _on_check_button_toggled(toggled_on: bool) -> void:
		SignalBus.emit_signal("define_overlay_on", toggled_on)
		Core.overlay_on = toggled_on
