extends Node

@onready var search_box: LineEdit = self.find_child("SearchBox")
@onready var search_button: Button = self.find_child("SearchButton")
@onready var suggestion_scroll : ScrollContainer = self.find_child("SuggestionScroll")
@onready var suggestion_list : VBoxContainer = self.find_child("SuggestionList")
@onready var library : Node = self.find_child("Library_Control")
@onready var blackboard : Node = self.find_child("Blackboard_Control")
@onready var undefined_cont : Node = self.find_child("UndefinedGlyphContainer")
@onready var display_box: RichTextLabel = self.find_child("DisplayBox")
@onready var add_unknown_btn : Button = self.find_child("AddUndefinedBtn")
@onready var font_selector : OptionButton = self.find_child("FontSelector")
@onready var line_thickness : SpinBox = self.find_child("ThicknessBox")
@onready var line_color : ColorPickerButton = self.find_child("ColorPicker")

var suggestion_scroll_length : int


func _ready() -> void:
	Core.font_selector = font_selector
	Core.font_selector.item_selected.connect(Core.new_font_selected)
	
	search_box.text_submitted.connect(_on_input_box_text_submitted)
	search_box.text_changed.connect(_on_input_box_text_update)
	search_button.pressed.connect(_on_search_button_pressed)
	
	suggestion_scroll.visible = false
	undefined_cont.visible = false


func _on_check_button_toggled(toggled_on: bool) -> void:
		SignalBus.emit_define_overlay(toggled_on)
		Core.overlay_on = toggled_on


func get_input_box_string(is_suggestion : bool) -> void:
	display_box.text = ""
	
	if is_suggestion:
		if search_box.text.length() > 1:
			search_box.set_keep_editing_on_text_submit(true)
			suggest_search(search_box.text)
		else:
			return
	else:
		if search_box.text != "":
			stepped_search(search_box.text)
		else:
			library.toggle_visible_cards()
			library.toggle_view(true)


#region Search handling


func _on_search_button_pressed() -> void:
	suggestion_scroll.visible = false
	get_input_box_string(false)


func _on_input_box_text_submitted(_new_text: String) -> void:
	suggestion_scroll.visible = false
	get_input_box_string(false)


func stepped_search(search_string : String) -> void:
	var search = db_search(Core.prime_db, search_string, "prime_index", "Definitions")

	if search != []:
		display_box.text = search[0].get("Definitions")
		library.search_toggle(search[0].get("ID"))
	else:
		search = db_search(Core.comp_db, search_string, "compound_index", "Definitions")
		if search != []:
			display_box.text = search[0].get("Definitions")
			library.search_toggle(search[0].get("ID"))
		else:
			display_box.text = "Unknown Phrase"
			library.toggle_view(false)
			add_unknown_btn.set_meta("UnknownDefinition", search_box.text)
			undefined_cont.visible = true
			return


func db_search(database : SQLite, search_term : String, table : String, column : String) -> Variant:
	var query = "SELECT * FROM " + table + " WHERE " + column + " MATCH '" + search_term + "';"
	database.query(query)
	
	return database.query_result
#endregion


#region Suggestion handling


func _on_input_box_text_update(_new_text: String) -> void:
	undefined_cont.visible = false
	
	suggestion_scroll.visible = false
	suggestion_scroll_length = 0
	clear_suggestion_list(suggestion_list.get_children())
	
	get_input_box_string(true)


func clear_suggestion_list(list_array : Array) -> void:
	for node in list_array.size():
		suggestion_list.remove_child(list_array[node])


func suggest_search(new_string : String) -> void:
	var suggested_rows : Array
	var suggested_rowIDs : Array
	var suggested_words : Array
	var suggested_IDs : Array
	
	var temp_array = db_suggest(Core.prime_db, new_string, "prime_index")
	
	suggested_rowIDs.append_array(temp_array[0])
	suggested_rows.append_array(temp_array[1])
	
	temp_array = db_suggest(Core.comp_db, new_string, "compound_index")
	
	suggested_rowIDs.append_array(temp_array[0])
	suggested_rows.append_array(temp_array[1])
	
	for row in suggested_rows.size():
		var split_row = suggested_rows[row].split(", ", true, 0)
		var filter : Array
		
		filter.append_array(split_row)
		for word in filter.size():
			if filter[word].begins_with(new_string):
				suggested_words.append(filter[word] + suggested_rowIDs[row])
			else:
				continue
	
	suggested_words.sort()
	
	for i in suggested_words.size():
		suggested_IDs.append(suggested_words[i].right(6))
		suggested_words.set(i, suggested_words[i].rstrip(suggested_IDs[i]))
	
	if suggested_words.size() > 0:
		fill_suggestion_list(suggested_words, suggested_IDs)
		suggestion_scroll.visible = true
	else:
		return


func db_suggest(database : SQLite, search_term : String, table : String) -> Variant:
	var query = "SELECT * FROM " + table + " WHERE Definitions Like ?"
	var binding : Array = ["%" + search_term + "%"]
	database.query_with_bindings(query, binding)
	var rows : Array = database.query_result.map(func(row): return row["Definitions"])
	var row_IDs : Array = database.query_result.map(func(row): return row["ID"])
	
	return [row_IDs, rows]


func fill_suggestion_list(suggestions : Array, suggestionIDs : Array) -> void:
	for word in suggestions.size():
		create_suggestion_button(suggestions[word], suggestionIDs[word])


func create_suggestion_button(btn_text : String, btn_meta : String) -> void:
	var button = Button.new()
	
	button.text = btn_text
	button.custom_minimum_size.x = 150
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	button.pressed.connect(suggestion_selected.bind(button))
	button.theme_type_variation = "FlatButton"
	
	suggestion_list.add_child(button)
	button.set_meta("Glyph_ID", btn_meta)
	suggestion_scroll_length += 32
	suggestion_scroll.custom_minimum_size.y = suggestion_scroll_length


func suggestion_selected(button : Button) -> void:
	suggestion_scroll.visible = false
	search_box.text = button.text
	get_input_box_string(false)
	
	#var search : Array
	#search = db_search(Core.prime_db, button.get_meta("Glyph_ID"), "prime_index", "ID")
	#
	#if search != []:
		#display_box.text = search[0].get("Definitions")
	#else:
		#search = db_search(Core.comp_db, button.get_meta("Glyph_ID"), "compound_index", "ID")
		#display_box.text = search[0].get("Definitions")


func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_ESCAPE:
			suggestion_scroll.visible = false
		elif event.pressed and event.keycode == KEY_DOWN:
			if search_box.is_editing():
				search_box.unedit()


#endregion


func _on_color_picker_color_changed(color: Color) -> void:
	SignalBus.emit_color_change(color)


func _on_thickness_box_value_changed(value: float) -> void:
	SignalBus.emit_thickness_change(value)


func _on_font_selector_item_selected(index: int) -> void:
	SignalBus.emit_font_change(index)
