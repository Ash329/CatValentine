extends CanvasLayer

func _ready() -> void:
	layer = 10

	var bg := TextureRect.new()
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bg.stretch_mode = TextureRect.STRETCH_SCALE
	if ResourceLoader.exists("res://Assets/main_menu_background.jpg"):
		bg.texture = load("res://Assets/main_menu_background.jpg")
	add_child(bg)
	bg.position = Vector2.ZERO
	bg.size = get_viewport().get_visible_rect().size

	var font: FontFile = null
	if ResourceLoader.exists("res://Assets/m6x11.ttf"):
		font = load("res://Assets/m6x11.ttf") as FontFile

	# Game title
	add_child(_lbl("CAT VALENTINE", font, 72, Color(1.0, 0.48, 0.70),
			Vector2(-272, -224), Vector2(544, 92), true))

	# Subtitle
	add_child(_lbl("<3  select your level  <3", font, 22, Color(0.82, 0.72, 0.90),
			Vector2(-235, -118), Vector2(470, 34), false))

	# Level buttons
	_level_btn("VALENTINE LEVEL", "res://scenes/levels/Game.tscn",          true,  font, Vector2(-145, -62))
	_level_btn("ANNIVERSARY",     "res://scenes/levels/Anniversary.tscn",   true,  font, Vector2(-145,  14))
	_level_btn("UNTITLED",        "",                                 false, font, Vector2(-145,  90))


func _lbl(txt: String, font: FontFile, size: int, color: Color,
		pos: Vector2, sz: Vector2, shd: bool) -> Label:
	var l := Label.new()
	l.text = txt
	l.set_anchors_preset(Control.PRESET_CENTER)
	l.position = pos
	l.size = sz
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	if font:
		var ls := LabelSettings.new()
		ls.font = font
		ls.font_size = size
		ls.font_color = color
		if shd:
			ls.shadow_color  = Color(0.35, 0.0, 0.12, 0.95)
			ls.shadow_offset = Vector2(4, 4)
			ls.outline_color = Color(0.0, 0.0, 0.0, 0.55)
			ls.outline_size  = 2
		l.label_settings = ls
	return l


func _make_box(bg: Color, border: Color) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = bg
	s.set_border_width_all(2)
	s.border_color = border
	s.set_corner_radius_all(0)
	return s


func _level_btn(label: String, scene: String, active: bool,
		font: FontFile, offset: Vector2) -> void:
	var btn := Button.new()
	btn.text = label
	btn.set_anchors_preset(Control.PRESET_CENTER)
	btn.position = offset
	btn.size = Vector2(290, 60)
	btn.disabled = not active
	btn.focus_mode = Control.FOCUS_NONE

	if font:
		btn.add_theme_font_override("font", font)
		btn.add_theme_font_size_override("font_size", 30)

	if active:
		btn.add_theme_stylebox_override("normal",
				_make_box(Color(0.50, 0.10, 0.22), Color(1.0, 0.55, 0.72)))
		btn.add_theme_stylebox_override("hover",
				_make_box(Color(0.72, 0.20, 0.36), Color(1.0, 0.78, 0.88)))
		btn.add_theme_stylebox_override("pressed",
				_make_box(Color(0.35, 0.06, 0.15), Color(1.0, 0.55, 0.72)))
		btn.add_theme_stylebox_override("focus",
				_make_box(Color(0.50, 0.10, 0.22), Color(1.0, 0.55, 0.72)))
		btn.add_theme_color_override("font_color",         Color(1.00, 0.95, 0.98))
		btn.add_theme_color_override("font_hover_color",   Color(1.00, 1.00, 1.00))
		btn.add_theme_color_override("font_pressed_color", Color(0.85, 0.85, 0.90))
		btn.pressed.connect(func() -> void:
			get_tree().change_scene_to_file(scene))
	else:
		var dis := _make_box(Color(0.11, 0.08, 0.16), Color(0.28, 0.22, 0.33))
		for state in ["normal", "hover", "pressed", "disabled", "focus"]:
			btn.add_theme_stylebox_override(state, dis)
		btn.add_theme_color_override("font_color",          Color(0.35, 0.30, 0.40))
		btn.add_theme_color_override("font_disabled_color", Color(0.35, 0.30, 0.40))

	add_child(btn)
