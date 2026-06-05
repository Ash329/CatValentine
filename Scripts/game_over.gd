extends CanvasLayer

class PixelCat extends Node2D:
	func _draw() -> void:
		var vp := get_viewport_rect().size
		var px := 8
		var ox := (vp.x - 12 * px) * 0.5
		var oy  := vp.y * 0.5 + px * 1.0

		const ORANGE := Color(0.98, 0.65, 0.15)
		const DARK   := Color(0.18, 0.08, 0.02)
		const EYE    := Color(0.05, 0.05, 0.05)
		const PINK   := Color(0.99, 0.72, 0.76)

		# 0=air  1=orange  2=dark  3=X-eye  4=nose-pink
		var grid := [
			[0, 0, 1, 1, 0, 0, 0, 0, 1, 1, 0, 0],
			[0, 1, 1, 1, 1, 0, 0, 1, 1, 1, 1, 0],
			[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
			[1, 1, 3, 1, 1, 1, 1, 1, 1, 3, 1, 1],
			[1, 3, 1, 3, 1, 1, 1, 1, 3, 1, 3, 1],
			[1, 1, 3, 1, 1, 1, 1, 1, 1, 3, 1, 1],
			[1, 1, 1, 1, 4, 1, 1, 4, 1, 1, 1, 1],
			[1, 1, 1, 2, 1, 2, 2, 1, 2, 1, 1, 1],
			[0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0],
			[0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0],
		]

		var palette := {1: ORANGE, 2: DARK, 3: EYE, 4: PINK}
		for r in grid.size():
			for c in grid[r].size():
				var v: int = grid[r][c]
				if v == 0:
					continue
				draw_rect(Rect2(ox + c * px, oy + r * px, px - 1, px - 1), palette[v])

		const STAR := Color(1.0, 1.0, 0.85)
		var sparks := [
			Vector2(ox - 3 * px, oy + 2 * px),
			Vector2(ox + 13 * px + 4, oy + 3 * px),
			Vector2(ox - 3 * px, oy + 7 * px),
			Vector2(ox + 13 * px + 4, oy + 7 * px),
		]
		for s in sparks:
			draw_rect(Rect2(s.x + 2, s.y, 2, px), STAR)
			draw_rect(Rect2(s.x, s.y + 2, px, 2), STAR)

		const HEART := Color(1.0, 0.35, 0.5)
		var hearts := [
			Vector2(ox - 5 * px, oy - 3 * px),
			Vector2(ox + 14 * px, oy - 3 * px),
		]
		var ht := [[0,1,0,1,0],[1,1,1,1,1],[0,1,1,1,0],[0,0,1,0,0]]
		for h in hearts:
			for hr in ht.size():
				for hc in ht[hr].size():
					if ht[hr][hc] == 1:
						draw_rect(Rect2(h.x + hc * 3, h.y + hr * 3, 3, 3), HEART)

var _hint: Label
var _restarting: bool = false

func _ready() -> void:
	layer = 100
	process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().paused = true

	var overlay := ColorRect.new()
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.color = Color(0.04, 0.0, 0.09, 0.87)
	add_child(overlay)

	var font: FontFile = null
	if ResourceLoader.exists("res://Assets/m6x11.ttf"):
		font = load("res://Assets/m6x11.ttf") as FontFile

	# Main message
	add_child(_lbl("TRY AGAIN BABE", font, 50, Color(1.0, 0.45, 0.65),
			Vector2(-185, -172), Vector2(370, 62), true))

	# Sub messages
	add_child(_lbl("youll get it this time", font, 24, Color(0.92, 0.82, 0.95),
			Vector2(-185, -102), Vector2(370, 36), false))
	add_child(_lbl("Mwah  <3", font, 34, Color(1.0, 0.38, 0.58),
			Vector2(-185, -60), Vector2(370, 46), true))

	# Blinking hint
	_hint = _lbl("[R] try again   [M] menu", font, 16, Color(0.78, 0.78, 0.90),
			Vector2(-185, 118), Vector2(370, 28), false)
	add_child(_hint)

	var blink := Timer.new()
	blink.wait_time = 0.55
	blink.one_shot = false
	blink.timeout.connect(func() -> void: _hint.visible = not _hint.visible)
	add_child(blink)
	blink.start()

	var auto_restart := Timer.new()
	auto_restart.wait_time = 7.0
	auto_restart.one_shot = true
	auto_restart.timeout.connect(_restart)
	add_child(auto_restart)
	auto_restart.start()


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
			ls.shadow_color  = Color(0.45, 0.0, 0.08, 0.95)
			ls.shadow_offset = Vector2(3, 3)
			ls.outline_color = Color(0.0, 0.0, 0.0, 0.55)
			ls.outline_size  = 2
		l.label_settings = ls
	return l


func _unhandled_input(event: InputEvent) -> void:
	if _restarting or not (event is InputEventKey and event.pressed and not event.echo):
		return
	if event.keycode == KEY_R:
		_restart()
	elif event.keycode == KEY_M:
		_go_menu()


func _restart() -> void:
	if _restarting:
		return
	_restarting = true
	get_tree().paused = false
	get_tree().reload_current_scene()


func _go_menu() -> void:
	if _restarting:
		return
	_restarting = true
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/ui/MainMenu.tscn")
