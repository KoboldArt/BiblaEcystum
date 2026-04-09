extends Node

@onready var main : Node = self.get_parent()
@onready var menu_bar : MenuBar = main.find_child("MenuBar")
@onready var file_menu : PopupMenu = menu_bar.find_child("FileMenu")

@onready var test_button : Button = main.find_child("TestButton")

var editor_window : Window

var editor_panel : Node
var path : String = "res://Scenes/glyph_composer.tscn"


func _ready() -> void:
	file_menu.index_pressed.connect(file_menu_elements)
	test_button.pressed.connect(open_subwindow)


func file_menu_elements(index : int) -> void:
	if index == 0:
		open_subwindow()
	elif index == 1:
		get_tree().quit()


func open_subwindow() -> void:
	var window : Window = Window.new()
	
	window.set_title("Glyph Editor")
	window.set_initial_position(Window.WINDOW_INITIAL_POSITION_CENTER_MAIN_WINDOW_SCREEN)
	window.set_exclusive(true)
	window.set_flag(Window.FLAG_BORDERLESS, true)
	window.set_flag(Window.FLAG_TRANSPARENT, true)
	window.set_flag(Window.FLAG_RESIZE_DISABLED, true)
	#window.set_flag(Window.FLAG_ALWAYS_ON_TOP, true)
	window.set_flag(Window.FLAG_MINIMIZE_DISABLED, true)
	window.set_flag(Window.FLAG_MAXIMIZE_DISABLED, true)
	window.set_min_size(Vector2(470, 420))
	
	main.add_child(window)
	
	var new_panel = load(path)
	
	editor_panel = new_panel.instantiate()
	
	window.add_child(editor_panel)
	
	


func close_subwindow() -> void:
	pass
