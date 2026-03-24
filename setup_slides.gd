@tool
extends EditorScript

func _run():
	print("Rebuilding Kivy UI Slides into Godot format with JOUST FONTS...")

	var joust_font = load("res://fonts/joust.ttf")

	# --- Slide 1: mpf_logo ---
	var s_mpf = Control.new()
	s_mpf.name = "mpf_logo"
	s_mpf.set_script(load("res://addons/mpf-gmc/classes/mpf_slide.gd"))
	s_mpf.set_anchors_preset(Control.PRESET_FULL_RECT)

	var bg1 = ColorRect.new()
	bg1.color = Color.BLACK
	bg1.set_anchors_preset(Control.PRESET_FULL_RECT)
	s_mpf.add_child(bg1)
	bg1.owner = s_mpf

	var mpf_img = TextureRect.new()
	mpf_img.name = "Logo"
	mpf_img.texture = load("res://images/mpf_logo.png")
	mpf_img.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	mpf_img.set_anchors_preset(Control.PRESET_FULL_RECT)
	s_mpf.add_child(mpf_img)
	mpf_img.owner = s_mpf

	var mpf_scene = PackedScene.new()
	mpf_scene.pack(s_mpf)
	ResourceSaver.save(mpf_scene, "res://slides/mpf_logo.tscn")

	# --- Slide 2: joust_tips ---
	var s_tips = Control.new()
	s_tips.name = "joust_tips"
	s_tips.set_script(load("res://addons/mpf-gmc/classes/mpf_slide.gd"))
	s_tips.set_anchors_preset(Control.PRESET_FULL_RECT)

	var bg2 = ColorRect.new()
	bg2.color = Color.BLACK
	bg2.set_anchors_preset(Control.PRESET_FULL_RECT)
	s_tips.add_child(bg2)
	bg2.owner = s_tips

	var tips_img = TextureRect.new()
	tips_img.name = "Logo"
	tips_img.texture = load("res://images/joust_logo_sm.jpg")
	tips_img.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	tips_img.set_anchors_preset(Control.PRESET_TOP_WIDE)
	tips_img.custom_minimum_size.y = 300
	s_tips.add_child(tips_img)
	tips_img.owner = s_tips

	var tips_text = Label.new()
	tips_text.name = "TipsList"
	tips_text.text = "-TIPS-\n\nKeep balls on your side\n\n<- Left spinner is yours\n\nRight spinner is opponent ->\n\nKnocking down all 3 drop targets resets opponent's\n\n3 balls each player then 30 second Multiball"
	tips_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tips_text.add_theme_font_override("font", joust_font)
	tips_text.add_theme_font_size_override("font_size", 32)
	tips_text.set_anchors_preset(Control.PRESET_CENTER)
	tips_text.add_theme_color_override("font_color", Color.YELLOW)
	s_tips.add_child(tips_text)
	tips_text.owner = s_tips

	var start_msg = Label.new()
	start_msg.name = "StartMsg"
	start_msg.text = "PLAYER 1 PRESS LEFT FLIPPER FOR MENU"
	start_msg.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	start_msg.add_theme_font_override("font", joust_font)
	start_msg.add_theme_font_size_override("font_size", 40)
	start_msg.add_theme_color_override("font_color", Color.RED)
	start_msg.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	start_msg.offset_top = -60
	s_tips.add_child(start_msg)
	start_msg.owner = s_tips

	var tips_scene = PackedScene.new()
	tips_scene.pack(s_tips)
	ResourceSaver.save(tips_scene, "res://slides/joust_tips.tscn")

	# --- Slide 3: last_game_score_slide ---
	var s_score = Control.new()
	s_score.name = "last_game_score_slide"
	s_score.set_script(load("res://addons/mpf-gmc/classes/mpf_slide.gd"))
	s_score.set_anchors_preset(Control.PRESET_FULL_RECT)

	var bg3 = ColorRect.new()
	bg3.color = Color.BLACK
	bg3.set_anchors_preset(Control.PRESET_FULL_RECT)
	s_score.add_child(bg3)
	bg3.owner = s_score

	var s_logo = tips_img.duplicate()
	s_score.add_child(s_logo)
	s_logo.owner = s_score

	var t_header = Label.new()
	t_header.text = "LAST GAME"
	t_header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	t_header.add_theme_color_override("font_color", Color.RED)
	t_header.add_theme_font_override("font", joust_font)
	t_header.add_theme_font_size_override("font_size", 40)
	t_header.set_anchors_preset(Control.PRESET_TOP_WIDE)
	t_header.offset_top = 280
	s_score.add_child(t_header)
	t_header.owner = s_score

	# Player 1 (Yellow)
	var p1_lbl = Label.new()
	p1_lbl.text = "PLAYER 1"
	p1_lbl.add_theme_color_override("font_color", Color.YELLOW)
	p1_lbl.add_theme_font_override("font", joust_font)
	p1_lbl.add_theme_font_size_override("font_size", 70)
	p1_lbl.set_anchors_preset(Control.PRESET_CENTER_LEFT)
	p1_lbl.offset_left = 100
	p1_lbl.offset_top = -50
	s_score.add_child(p1_lbl)
	p1_lbl.owner = s_score

	var p1_score = Label.new()
	p1_score.text = "0"
	p1_score.add_theme_color_override("font_color", Color.YELLOW)
	p1_score.add_theme_font_override("font", joust_font)
	p1_score.add_theme_font_size_override("font_size", 95)
	p1_score.set_script(load("res://addons/mpf-gmc/classes/mpf_variable.gd"))
	p1_score.variable_type = 1 # MACHINE_VAR
	p1_score.variable_name = "p1_score"
	p1_score.comma_separate = true
	p1_score.set_anchors_preset(Control.PRESET_CENTER_LEFT)
	p1_score.offset_left = 100
	p1_score.offset_top = 50
	s_score.add_child(p1_score)
	p1_score.owner = s_score

	# Player 2 (Blue)
	var p2_lbl = Label.new()
	p2_lbl.text = "PLAYER 2"
	p2_lbl.add_theme_color_override("font_color", Color.DEEP_SKY_BLUE)
	p2_lbl.add_theme_font_override("font", joust_font)
	p2_lbl.add_theme_font_size_override("font_size", 70)
	p2_lbl.set_anchors_preset(Control.PRESET_CENTER_RIGHT)
	p2_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	p2_lbl.offset_right = -100
	p2_lbl.offset_top = -50
	s_score.add_child(p2_lbl)
	p2_lbl.owner = s_score

	var p2_score = Label.new()
	p2_score.text = "0"
	p2_score.add_theme_color_override("font_color", Color.DEEP_SKY_BLUE)
	p2_score.add_theme_font_override("font", joust_font)
	p2_score.add_theme_font_size_override("font_size", 95)
	p2_score.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	p2_score.set_script(load("res://addons/mpf-gmc/classes/mpf_variable.gd"))
	p2_score.variable_type = 1 # MACHINE_VAR
	p2_score.variable_name = "p2_score"
	p2_score.comma_separate = true
	p2_score.set_anchors_preset(Control.PRESET_CENTER_RIGHT)
	p2_score.offset_right = -100
	p2_score.offset_top = 50
	s_score.add_child(p2_score)
	p2_score.owner = s_score

	# Total Score (Red)
	var t_total = Label.new()
	t_total.text = "TOTAL\n"
	t_total.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	t_total.add_theme_color_override("font_color", Color.RED)
	t_total.add_theme_font_override("font", joust_font)
	t_total.add_theme_font_size_override("font_size", 40)
	t_total.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	t_total.offset_top = -200
	s_score.add_child(t_total)
	t_total.owner = s_score

	var total_score = Label.new()
	total_score.text = "0"
	total_score.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	total_score.add_theme_color_override("font_color", Color.RED)
	total_score.add_theme_font_override("font", joust_font)
	total_score.add_theme_font_size_override("font_size", 70)
	total_score.set_script(load("res://addons/mpf-gmc/classes/mpf_variable.gd"))
	total_score.variable_type = 1 # MACHINE_VAR
	total_score.variable_name = "total_score"
	total_score.comma_separate = true
	total_score.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	total_score.offset_top = -140
	s_score.add_child(total_score)
	total_score.owner = s_score

	s_score.add_child(start_msg.duplicate())
	s_score.get_node("StartMsg").owner = s_score

	var last_scene = PackedScene.new()
	last_scene.pack(s_score)
	ResourceSaver.save(last_scene, "res://slides/last_game_score_slide.tscn")

	# --- Slide 4: base (In-Game Screen) ---
	var s_base = Control.new()
	s_base.name = "base"
	s_base.set_script(load("res://addons/mpf-gmc/classes/mpf_slide.gd"))
	s_base.set_anchors_preset(Control.PRESET_FULL_RECT)

	var bg4 = ColorRect.new()
	bg4.color = Color.BLACK
	bg4.set_anchors_preset(Control.PRESET_FULL_RECT)
	s_base.add_child(bg4)
	bg4.owner = s_base

	var b_header = Label.new()
	b_header.text = "PLAYER 1"
	b_header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	b_header.add_theme_color_override("font_color", Color.YELLOW)
	b_header.add_theme_font_override("font", joust_font)
	b_header.add_theme_font_size_override("font_size", 60)
	b_header.set_anchors_preset(Control.PRESET_TOP_WIDE)
	b_header.offset_top = 100
	s_base.add_child(b_header)
	b_header.owner = s_base

	var b_score = Label.new()
	b_score.text = "0"
	b_score.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	b_score.add_theme_color_override("font_color", Color.YELLOW)
	b_score.add_theme_font_override("font", joust_font)
	b_score.add_theme_font_size_override("font_size", 120)
	b_score.set_script(load("res://addons/mpf-gmc/classes/mpf_variable.gd"))
	b_score.variable_type = 0 # CURRENT_PLAYER_VAR
	b_score.variable_name = "score"
	b_score.comma_separate = true
	b_score.set_anchors_preset(Control.PRESET_CENTER)
	s_base.add_child(b_score)
	b_score.owner = s_base

	var base_scene = PackedScene.new()
	base_scene.pack(s_base)
	ResourceSaver.save(base_scene, "res://slides/base.tscn")

	print("================================")
	print("Success! Created 4 pure Godot slides mapped precisely with joust.ttf fonts and solid backgrounds!")
