extends Node

## Glyph Editing
@onready var definer_btn : Button = self.find_child("Definer_Button")
@onready var modifier_A_btn : Button = self.find_child("Modifier_A_Button")
@onready var modifier_B_btn : Button = self.find_child("Modifier_B_Button")

## -Glyph Components- ##
@onready var border : PanelContainer = self.find_child("GlyphBorder")
@onready var unknown_pnl : PanelContainer = self.find_child("UnknownPanel")

## Glyph Display Nodes ##
@onready var prime_slot : TextureRect = self.find_child("Prime")
@onready var define_slot : TextureRect = self.find_child("Definer")
@onready var mod_1_slot : TextureRect = self.find_child("Modifier_01")
@onready var mod_2_slot : TextureRect = self.find_child("Modifier_02")
@onready var mod_3_slot : TextureRect = self.find_child("Modifier_03")
@onready var separator : TextureRect = self.find_child("Separator-L")
var slots : Array = []

## Glyph Info Nodes ##
@onready var prime_label : RichTextLabel = self.find_child("PrimeLabel")
@onready var define_label : RichTextLabel = self.find_child("DefinerLabel")
@onready var mod_1_label : RichTextLabel = self.find_child("Modifier01Label")
@onready var mod_2_label : RichTextLabel = self.find_child("Modifier02Label")
@onready var mod_3_label : RichTextLabel = self.find_child("Modifier03Label")
var labels : Array = []
var is_card : bool = false

## Glyph Info ##
var glyph_string : String

## Glyph Resources ##
var full_folder : String = "Full/"
var half_folder : String = "Half/"
var quarter_folder : String = "Quarter/"
var extrension : String = ".png"

## Popup Window
@onready var popup_window : Popup = self.find_child("SelectorPopup")
@onready var popup_content : Node = popup_window.find_child("glyph_selector_popup")
var path : String = "res://Scenes/glyph_selector_popup.tscn"

func _ready() -> void:
	definer_btn.pressed.connect(spawn_popup_window.bind(definer_btn))
	modifier_A_btn.pressed.connect(spawn_popup_window.bind(modifier_A_btn))
	modifier_B_btn.pressed.connect(spawn_popup_window.bind(modifier_B_btn))
	
	update_button_visibility(Vector3(0, 0, 0))
	
	slots = [prime_slot, define_slot, mod_1_slot, mod_2_slot, mod_3_slot]
	labels = [prime_label, define_label, mod_1_label, mod_2_label, mod_3_label]
	
	draw_glyph()
	
	#Core.font_changed.connect(_on_new_font_selected)
	SignalBus.define_overlay_on.connect(display_labels)
	SignalBus.change_font.connect(_on_new_font_selected)
	SignalBus.change_color.connect(color_change)
	SignalBus.change_thickness.connect(thickness_change)
	
	unknown_pnl.visible = false
	
	#popup_content.source_glyph = self


func update_button_visibility(role : Vector3) -> void:
	definer_btn.visible = role.x
	modifier_A_btn.visible = role.y
	modifier_B_btn.visible = role.z


func draw_glyph() -> void:
	glyph_string = self.get_meta("Glyph_ID")
	
	self.visible = false
	unknown_pnl.visible = false
	separator.visible = false
	
	for i in slots.size():
		clear_nodes(slots[i], labels[i])
	
	if glyph_string.substr(0, 2) == "00":
		self.visible = true
		unknown_pnl.visible = true
		display_labels(Core.overlay_on)
		return
	elif glyph_string.substr(2, 2) == "00":
		construct_glyph(glyph_string.substr(0, 2), prime_slot)
		#load_glyph(full_folder, glyph_string.substr(0, 2), prime_slot)
		fill_label(prime_label, glyph_string.substr(0, 2))
		self.visible = true
		display_labels(Core.overlay_on)
		return
	elif glyph_string.substr(4, 2)  == "00":
		separator.visible = true
		separator.change_line_type(separator.separator, true)
		construct_glyph(glyph_string.substr(0, 2), define_slot)
		#load_glyph(half_folder, glyph_string.substr(0, 2), define_slot)
		fill_label(define_label, glyph_string.substr(0, 2))
		construct_glyph(glyph_string.substr(2, 2), mod_1_slot)
		#load_glyph(half_folder, glyph_string.substr(2, 2), mod_1_slot)
		fill_label(mod_1_label, glyph_string.substr(2, 2))
		self.visible = true
		display_labels(Core.overlay_on)
		return
	elif not glyph_string.contains("00"):
		separator.visible = true
		separator.change_line_type(separator.separator, true)
		construct_glyph(glyph_string.substr(0, 2), define_slot)
		#load_glyph(half_folder, glyph_string.substr(0, 2), define_slot)
		fill_label(define_label, glyph_string.substr(0, 2))
		construct_glyph(glyph_string.substr(2, 2), mod_2_slot)
		#load_glyph(quarter_folder, glyph_string.substr(2, 2), mod_2_slot)
		fill_label(mod_2_label, glyph_string.substr(2, 2))
		construct_glyph(glyph_string.substr(4, 2), mod_3_slot)
		#load_glyph(quarter_folder, glyph_string.substr(4, 2), mod_3_slot)
		fill_label(mod_3_label, glyph_string.substr(4, 2))
		self.visible = true
		display_labels(Core.overlay_on)


func clear_nodes(slot : Node, label : RichTextLabel) -> void:
	construct_glyph("00", slot)
	#slot.set_texture(null)
	label.text = ""
	label.get_parent().visible = false


func construct_glyph(ID : String, slot : Node) -> void:
	slot._on_ID_submitted(ID)
	


func load_glyph(type_folder : String, img_name : String, slot : Node) -> void:
	var glyph_access = load(str(Core.cur_font, type_folder, img_name, extrension))
	slot.set_texture(glyph_access)


func fill_label(label : RichTextLabel, ID : String) -> void:
	var update_text = Core.get_prime_info(ID + "0000", "ID", "Definitions")[0]
	update_text = update_text.get("Definitions").split(", ", true, 0)[0]
	label.text = update_text


func display_labels(turn_on : bool) -> void:
	if turn_on and not is_card:
		for i in labels.size():
			if labels[i].text != "":
				labels[i].get_parent().visible = true
			else:
				labels[i].get_parent().visible = false
	else:
		for i in labels.size():
			labels[i].get_parent().visible = false


func _on_new_font_selected(index: int) -> void:
	separator.Line = index
	
	for e in slots.size():
		slots[e].Line = index
	#Core.cur_font = Core.font_dict[index]
	draw_glyph()


func color_change(color : Color) -> void:
	separator.change_color(color)
	
	for e in slots.size():
		slots[e].change_color(color)


func thickness_change(thickness : float) -> void:
	separator.line_width = thickness
	
	for e in slots.size():
		slots[e].line_width = thickness
	
	draw_glyph()


func spawn_popup_window(button : Button) -> void:
	#popup_window.popup_centered(Vector2i(420, 370))
	popup_window.show()
	#popup_content.visible = true
	popup_content.source_button = button
	
	
	#var new_popup : Popup = Popup.new()
	#var new_content = load(path)
	#
	#new_popup.set_initial_position(Window.WINDOW_INITIAL_POSITION_CENTER_MAIN_WINDOW_SCREEN)
	#new_popup.set_size(Vector2(420, 370))
	#new_popup.transparent = true
	#new_popup.visible = true
	#popup_window = new_popup
	#self.add_child(new_popup)
	#
	#popup_content = new_content.instantiate()
	#
	#
	#new_popup.add_child(popup_content)


func drop_popup(popup : Popup) -> void:
	popup.hide()
	#popup_content.visible = false
	#popup.queue_free()
