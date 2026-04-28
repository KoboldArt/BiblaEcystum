extends Node

signal define_overlay_on(toggled_on : bool)
signal save_img_trigger()

signal change_font(index : int)
signal change_thickness(thickness : float)
signal change_color(color : Color)

func emit_define_overlay(toggled_on : bool) -> void:
	emit_signal("define_overlay_on", toggled_on)


func emit_save_img() -> void:
	emit_signal("save_img_trigger")


func emit_font_change(index : int) -> void:
	emit_signal("change_font", index)


func emit_thickness_change(thickness : float) -> void:
	emit_signal("change_thickness", thickness)


func emit_color_change(color : Color) -> void:
	emit_signal("change_color", color)
