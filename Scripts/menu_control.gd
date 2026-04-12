extends Node

@onready var main : Node = self.get_parent()
@onready var menu_bar : MenuBar = main.find_child("MenuBar")
@onready var file_menu : PopupMenu = menu_bar.find_child("FileMenu")
@onready var export_control : Node = main.find_child("TextExport_Control")
@onready var add_unknown_btn : Button = main.find_child("AddUndefinedBtn")

var editor_window : Window

var editor_panel : Node
var path : String = "res://Scenes/glyph_composer.tscn"


func _ready() -> void:
	file_menu.index_pressed.connect(file_menu_elements)
	add_unknown_btn.pressed.connect(add_unknown_concept)


func file_menu_elements(index : int) -> void:
	if index == 0:
		open_subwindow("")
	elif index == 1:
		export_control.export_glyph_to_png()
	elif index == 2:
		pass
	elif index == 3:
		get_tree().quit()


func open_subwindow(pre_define : String) -> void:
	var window : Window = Window.new()
	
	window.set_title("Glyph Editor")
	window.set_initial_position(Window.WINDOW_INITIAL_POSITION_CENTER_MAIN_WINDOW_SCREEN)
	window.set_exclusive(true)
	window.set_flag(Window.FLAG_BORDERLESS, true)
	window.set_flag(Window.FLAG_TRANSPARENT, true)
	window.set_flag(Window.FLAG_RESIZE_DISABLED, true)
	window.set_flag(Window.FLAG_MINIMIZE_DISABLED, true)
	window.set_flag(Window.FLAG_MAXIMIZE_DISABLED, true)
	window.set_min_size(Vector2(470, 470))
	
	main.add_child(window)
	
	var new_panel = load(path)
	
	editor_panel = new_panel.instantiate()
	
	window.add_child(editor_panel)
	editor_panel.definition_box.set_text(pre_define)
	
	add_unknown_btn.visible = false


func add_unknown_concept() -> void:
	open_subwindow(add_unknown_btn.get_meta("UnknownDefinition"))

func close_subwindow() -> void:
	pass
