extends Node

@onready var library_container : Node = owner.find_child("LibraryContainer")

## Filters
@onready var primes_on : CheckBox = owner.find_child("PrimesOn")
@onready var comps_on : CheckBox = owner.find_child("CompsOn")

var filter_list : Array

var glyph_card : Node
#var glyph_display : Node
var path : String = "res://Scenes/glyph_card.tscn"

var prime_glyph_info : Array = []
var prime_cards : Array = []
var comp_glyph_info : Array = []
var comp_cards : Array = []


func _ready() -> void:
	connect_filters(primes_on)
	connect_filters(comps_on)
	
	filter_list.append(owner.find_child("ConceptFilters"))
	filter_list.append(owner.find_child("ProcessFilters"))
	filter_list.append(owner.find_child("ClassFilters"))
	
	for list in filter_list.size():
		for item in filter_list[list].get_children().size():
			connect_filters(filter_list[list].get_children()[item])
	
	prime_glyph_info = Core.get_database_info(Core.prime_db, "prime_index")
	prime_glyph_info.remove_at(0)
	comp_glyph_info = Core.get_database_info(Core.comp_db, "compound_index")
	
	for prime in prime_glyph_info.size():
		add_card(prime_glyph_info[prime], true)
	
	for comp in comp_glyph_info.size():
		add_card(comp_glyph_info[comp], false)
	
	Core.new_glyph_added.connect(add_card)


func add_card(card_info : Dictionary, is_prime : bool) -> void:
	var new_card = load(path)
	
	glyph_card = new_card.instantiate()
	setup_card(glyph_card, card_info, is_prime)

	library_container.add_child(glyph_card)
	glyph_card.set_scale(Vector2(0.5, 0.5))
	if is_prime:
		prime_cards.append(glyph_card)
	else:
		comp_cards.append(glyph_card)


func setup_card(card : Node, glyph_info : Dictionary, is_prime : bool) -> void:
	var card_descript_box = card.find_child("CardDef_Box")
	var card_ID_box = card.find_child("ID_Box")
	var card_glyph = card.find_child("Glyph")
	
	if is_prime:
		card.glyph_type = card.Type.PRIME
		card.MatrixID.x = glyph_info.get("MatrixID").substr(0, 1).to_int()
		card.MatrixID.y = glyph_info.get("MatrixID").substr(2, 1).to_int()
		card.MatrixID.z = glyph_info.get("MatrixID").substr(4, 1).to_int()
	else:
		card.glyph_type = card.Type.COMPOUND
	
	card_ID_box.text = glyph_info.get("ID")
	card_glyph.set_meta("Glyph_ID", glyph_info.get("ID"))
	card_glyph.is_card = true
	card_descript_box.text = glyph_info.get("Definitions")


func connect_filters(button : CheckBox) -> void:
	button.pressed.connect(filter_toggle)


func filter_toggle() -> void:
	var concept_filters = owner.find_child("ConceptFilters")
	var process_filters = owner.find_child("ProcessFilters")
	var class_filters = owner.find_child("ClassFilters")
	
	var cards_to_hide : Array = []
	
	for card in prime_cards.size():
		prime_cards[card].visible = true
	
	for card in comp_cards.size():
		comp_cards[card].visible = true
	
	for card in prime_cards.size():
		if not primes_on.button_pressed:
			cards_to_hide.append(prime_cards[card])
	
	for card in comp_cards.size():
		if not comps_on.button_pressed:
			cards_to_hide.append(comp_cards[card])
	
	for item in concept_filters.get_children().size():
		for card in prime_cards.size():
			if prime_cards[card].MatrixID.x == item + 1:
				if not concept_filters.get_children()[item].button_pressed:
					cards_to_hide.append(prime_cards[card])
	
	for item in process_filters.get_children().size():
		for card in prime_cards.size():
			if prime_cards[card].MatrixID.y == item + 1:
				if not process_filters.get_children()[item].button_pressed:
					cards_to_hide.append(prime_cards[card])
	
	for item in class_filters.get_children().size():
		for card in prime_cards.size():
			if prime_cards[card].MatrixID.z == item + 1:
				if not class_filters.get_children()[item].button_pressed:
					cards_to_hide.append(prime_cards[card])
	
	for card in cards_to_hide.size():
		cards_to_hide[card].visible = false
