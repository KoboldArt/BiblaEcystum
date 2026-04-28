extends Node

#@onready var library_container : Node = owner.find_child("LibraryContainer")
@onready var card_box : Node = owner.find_child("CardsLibrary")
@onready var word_box : Node = owner.find_child("WordsLibrary")
@onready var toggle_library : CheckButton = owner.find_child("ToggleLibraryView")
@onready var operator : CheckButton = owner.find_child("OperatorBtn")

## Filters
@onready var show_all : CheckBox = owner.find_child("ShowAll")

@onready var type_filter : MenuButton = owner.find_child("TypesOfGlyph")
@onready var concept_filter : MenuButton = owner.find_child("AreasOfConcept")
@onready var process_filter : MenuButton = owner.find_child("StagesOfProcessing")
@onready var caste_filter : MenuButton = owner.find_child("CastesOfTheHive")

var filter_list : Array

var glyph_card : Node
var path : String = "res://Scenes/glyph_card_new.tscn"

var prime_glyph_info : Array = []
var prime_IDs : Array = []
var prime_cards : Array = []
var comp_glyph_info : Array = []
var comp_IDs : Array = []
var comp_cards : Array = []

var all_cards : Array = []
var hidden_cards : Array = []
var visible_cards : Array = []

var all_buttons : Array = []
var hidden_buttons : Array = []
var visible_buttons : Array = []

var type_state : Array = [true, true]
var concept_state : Array = [true, true, true, true, true]
var process_state : Array = [true, true, true, true, true]
var caste_state : Array = [true, true, true, true]


func _ready() -> void:
	setup_filters()
	
	prime_glyph_info = Core.get_database_info(Core.prime_db)
	prime_glyph_info.remove_at(0)
	comp_glyph_info = Core.get_database_info(Core.comp_db)
	
	collect_IDs(prime_glyph_info, prime_IDs)
	collect_IDs(comp_glyph_info, comp_IDs)
	
	for prime in prime_glyph_info.size():
		add_glyph_card(prime_glyph_info[prime])
		add_word_card(prime_glyph_info[prime])
	
	for comp in comp_glyph_info.size():
		add_glyph_card(comp_glyph_info[comp])
		add_word_card(comp_glyph_info[comp])
	
	visible_cards.append_array(all_cards)
	visible_buttons.append_array(all_buttons)
	
	Core.new_glyph_added.connect(add_glyph_card)
	toggle_library.toggled.connect(toggle_library_mode)
	
	show_all.toggled.connect(toggle_all)
	
	toggle_library_mode(false)


#region Filters logic
func setup_filters() -> void:
	type_filter.get_popup().index_pressed.connect(filter_toggle.bind(type_filter))
	type_filter.get_popup().set_hide_on_checkable_item_selection(false)
	concept_filter.get_popup().index_pressed.connect(filter_toggle.bind(concept_filter))
	concept_filter.get_popup().set_hide_on_checkable_item_selection(false)
	process_filter.get_popup().index_pressed.connect(filter_toggle.bind(process_filter))
	process_filter.get_popup().set_hide_on_checkable_item_selection(false)
	caste_filter.get_popup().index_pressed.connect(filter_toggle.bind(caste_filter))
	caste_filter.get_popup().set_hide_on_checkable_item_selection(false)


func toggle_all(toggled_on : bool) -> void:
	for i in type_filter.get_popup().item_count:
		type_filter.get_popup().set_item_checked(i, toggled_on)
		type_state.set(i, toggled_on)
	
	for i in concept_filter.get_popup().item_count:
		concept_filter.get_popup().set_item_checked(i, toggled_on)
		concept_state.set(i, toggled_on)
	
	for i in process_filter.get_popup().item_count:
		process_filter.get_popup().set_item_checked(i, toggled_on)
		process_state.set(i, toggled_on)
	
	for i in caste_filter.get_popup().item_count:
		caste_filter.get_popup().set_item_checked(i, toggled_on)
		caste_state.set(i, toggled_on)
	
	toggle_visible_cards()
	toggle_visible_buttons()
	toggle_view(true)


func filter_toggle(index : int, filter : Node) -> void:
	var toggle = not filter.get_popup().is_item_checked(index)
	filter.get_popup().set_item_checked(index, toggle)
	
	if filter == type_filter:
		type_state.set(index, toggle)
	elif filter == concept_filter:
		concept_state.set(index, toggle)
	elif filter == process_filter:
		process_state.set(index, toggle)
	elif filter == caste_filter:
		caste_state.set(index, toggle)
	
	toggle_visible_cards()
	toggle_visible_buttons()
	toggle_view(true)


func search_toggle(cardID : String) -> void:
	for card in visible_cards.size():
		if visible_cards[card].card_id_box.text != cardID:
			hidden_cards.append(visible_cards[card])
	
	sort_hidden_visible(true)
	toggle_view(true)


func toggle_visible_cards() -> void:
	visible_cards = all_cards.duplicate()
	hidden_cards.clear()
	
	for card in visible_cards.size():
		for filter in type_state.size():
			if visible_cards[card].glyph_type == filter:
				if not type_state[filter]:
					hidden_cards.append(visible_cards[card])
				
	sort_hidden_visible(true)
	
	for card in visible_cards.size():
		for filter in concept_state.size():
			if visible_cards[card].MatrixID[0].x == filter + 1:
				if not concept_state[filter]:
					hidden_cards.append(visible_cards[card])
				
	sort_hidden_visible(true)
	
	for card in visible_cards.size():
		for filter in process_state.size():
			if visible_cards[card].MatrixID[0].y == filter + 1:
				if not process_state[filter]:
					hidden_cards.append(visible_cards[card])
				
	sort_hidden_visible(true)
	
	for card in visible_cards.size():
		for filter in caste_state.size():
			if visible_cards[card].MatrixID[0].z == filter + 1:
				if not caste_state[filter]:
					hidden_cards.append(visible_cards[card])
				
	sort_hidden_visible(true)


func toggle_visible_buttons() -> void:
	visible_buttons = all_buttons.duplicate()
	hidden_buttons.clear()
	
	for button in visible_buttons.size():
		for filter in type_state.size():
			var glyph_type = visible_buttons[button].get_meta("Prime")
			if glyph_type == filter:
				if not type_state[filter]:
					hidden_buttons.append(visible_buttons[button])
				
	sort_hidden_visible(false)
	
	for button in visible_buttons.size():
		for filter in concept_state.size():
			var MatrixID = visible_buttons[button].get_meta("MatrixID")
			if MatrixID[0].x == filter + 1:
				if not concept_state[filter]:
					hidden_buttons.append(visible_buttons[button])
				
	sort_hidden_visible(false)
	
	for button in visible_buttons.size():
		for filter in process_state.size():
			var MatrixID = visible_buttons[button].get_meta("MatrixID")
			if MatrixID[0].y == filter + 1:
				if not process_state[filter]:
					hidden_buttons.append(visible_buttons[button])
				
	sort_hidden_visible(false)
	
	for button in visible_buttons.size():
		for filter in caste_state.size():
			var MatrixID = visible_buttons[button].get_meta("MatrixID")
			if MatrixID[0].z == filter + 1:
				if not caste_state[filter]:
					hidden_buttons.append(visible_buttons[button])
				
	sort_hidden_visible(false)


func sort_hidden_visible(is_card : bool) -> void:
	if is_card:
		for card in hidden_cards.size():
			visible_cards.erase(hidden_cards[card])
	else:
		for button in hidden_buttons.size():
			visible_buttons.erase(hidden_buttons[button])


func toggle_view(toggle : bool) -> void:
	for card in all_cards.size():
		all_cards[card].visible = false
		
	if toggle:
		for card in visible_cards.size():
			visible_cards[card].visible = true
	
	for button in all_buttons.size():
		all_buttons[button].visible = false
	
	if toggle:
		for button in visible_buttons.size():
			visible_buttons[button].visible = true
#endregion


#region Spawn glyph-cards
func add_glyph_card(card_info : Dictionary) -> void:
	var new_card = load(path)
	
	glyph_card = new_card.instantiate()
	setup_glyph_card(glyph_card, card_info)

	card_box.add_child(glyph_card)
	glyph_card.pressed.connect(glyph_card_pressed.bind(glyph_card))
	glyph_card.set_scale(Vector2(0.5, 0.5))
	
	all_cards.append(glyph_card)


func setup_glyph_card(card : Node, glyph_info : Dictionary) -> void:
	var card_descript_box = card.find_child("CardDef_Box")
	var card_ID_box = card.find_child("ID_Box")
	var card_glyph = card.find_child("Glyph")
	
	var matrix_array : Array = glyph_info.get("MatrixID")
	
	if matrix_array.size() == 1:
		card.glyph_type = card.Type.PRIME
	else:
		card.glyph_type = card.Type.COMPOUND
	
	for m in matrix_array.size():
		var matrix : Vector3i
		matrix.x = glyph_info.get("MatrixID")[m].x
		matrix.y = glyph_info.get("MatrixID")[m].y
		matrix.z = glyph_info.get("MatrixID")[m].z
		
		card.MatrixID.append(matrix)
	
	card_ID_box.text = glyph_info.get("ID")
	card_glyph.set_meta("Glyph_ID", glyph_info.get("ID"))
	card_glyph.is_card = true
	card_descript_box.text = ", ".join(glyph_info.get("Definitions"))


func collect_IDs(ID_info : Array, target_array : Array) -> void:
	for e in ID_info.size():
		target_array.append(ID_info[e].get("ID"))
#endregion


#region Spawn word-cards
func add_word_card(card_info : Dictionary) -> void:
	var word_array : Array = []
	
	word_array = setup_word_card(card_info)
	
	for word in word_array.size():
		var new_button : Button
		new_button = create_card(word_array[word])
		word_box.add_child(new_button)
		all_buttons.append(new_button)
		new_button.pressed.connect(word_card_pressed.bind(new_button))


func create_card(data : Array) -> Button:
	var button : Button = Button.new()
	
	button.text = data[0]
	button.set_meta("Glyph_ID", data[1])
	button.set_meta("MatrixID", data[2])
	
	if data[1].ends_with("0000"):
		button.set_meta("Prime", 0)
	else:
		button.set_meta("Prime", 1)
	
	return button


func setup_word_card(card_info : Dictionary) -> Array:
	var card_array : Array = []
	#var word_count : Array = card_info.get("Definitions")
	
	#for info in word_count.size():
	card_array.append_array(derive_word_card_source(card_info))
	
	card_array.sort()
	
	return card_array


func derive_word_card_source(row_data : Dictionary) -> Array:
	var word_list : Array = []
	var data_ID : String
	var matrix_array : Array = row_data.get("MatrixID")
	var matrix_data : Array
	
	word_list = row_data.get("Definitions")
	data_ID = row_data.get("ID")
	
	for m in matrix_array.size():
		var matrix : Vector3i
		matrix.x = row_data.get("MatrixID")[m].x
		matrix.y = row_data.get("MatrixID")[m].y
		matrix.z = row_data.get("MatrixID")[m].z
		
		matrix_data.append(matrix)
	
	var result_array = extract_data(word_list, data_ID, matrix_data)
	
	#result_array.append(matrix_data)
	
	return result_array


#Extracting each word as separate elements attaching the glyph ID to each word.
func extract_data(data : Array, data_ID : String, matrix : Array) -> Array:
	var output_array : Array = []
	
	for w in data.size():
		var temp_array : Array = []
		temp_array.append(data[w])
		temp_array.append(data_ID)
		temp_array.append(matrix)
		#if data_ID.ends_with("0000"):
			#temp_array.append("prime")
		output_array.append(temp_array)
	
	return output_array
#endregion


func glyph_card_pressed(button : Button) -> void:
	# Edit branch
	if operator.button_pressed:
		print("edit")
		return
		#if button.glyph_type == button.Type.COMPOUND:
			#var text : String = button.card_id_box.get_text()
			#var id_array : Array = []
			#var matrix_array : String = ""
			#var data_array : Array = []
			#id_array.append(text.substr(0, 2) + "0000")
			#id_array.append(text.substr(2, 2) + "0000")
			#id_array.append(text.substr(4, 2) + "0000")
			#
			#for id in id_array.size():
				#if id_array[id] != "000000":
					#var search : Vector3i
					#for row in prime_glyph_info.size():
						#if id_array[id] == prime_glyph_info[row].get("ID"):
							#search = prime_glyph_info[row].get("MatrixID")[0]
							#var vec_to_str = str(search.x, ",", search.y, ",", search.z)
							#matrix_array += vec_to_str + ";"
							#break
						#else:
							#continue
				#else:
					#continue
			#
			#matrix_array = matrix_array.rstrip(";")
			#print(button.card_def_box.text)
			#print(text)
			#print(matrix_array)
			#data_array.append(matrix_array)
			#data_array.append(text)
			#print(data_array)
			##Core.update_comp_matrices(data_array, Core.comp_db)
			#
		#else:
			#return
	# Add branch
	else:
		var word_array : Array = button.card_def_box.text.split(", ", true, 0)
		owner.blackboard.input_box.text += word_array[0] + " "
		owner.blackboard.button_pressed()


func word_card_pressed(button : Button) -> void:
	if operator.button_pressed:
		print("edit")
	else:
		owner.blackboard.input_box.text += button.text + " "
		owner.blackboard.button_pressed()


func toggle_library_mode(toggle : bool) -> void:
	card_box.visible = not toggle
	word_box.visible = toggle
