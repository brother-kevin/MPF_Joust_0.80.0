@tool
extends EditorScript

func _run():
	print("Rebuilding Kivy UI Slides into Godot format with HALF-SCREEN MIRRORED DIMENSIONS...")

	var joust_font = load("res://fonts/joust.ttf")

	# --- Common elements ---
	var start_msg = Label.new()alal
	start_msg.name = "StartMsg"
	start_msg.text = "PLAYER 1 PRESS LEFT FLIPPER FOR MENU"
	start_msg.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	start_msg.add_theme_font_override("font", joust_font)
	start_msg.add_theme_font_size_override("font_size", 40)
	start_msg.add_theme_color_override("font_color", Color.RED)
	start_msg.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	start_msg.offset_top = -60

	var logo_tex = load("res://images/joust_logo_sm.jpg")

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
	tips_img.texture = logo_tex
	tips_img.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	tips_img.set_anchors_preset(Control.PRESET_TOP_WIDE)
	tips_img.custom_minimum_size.y = 250
	s_tips.add_child(tips_img)
	tips_img.owner = s_tips

	var tips_vbox = VBoxContainer.new()
	tips_vbox.name = "TipsList"
	tips_vbox.set_anchors_preset(Control.PRESET_TOP_WIDE)
	tips_vbox.offset_top = 213
	s_tips.add_child(tips_vbox)
	tips_vbox.owner = s_tips

	var tips_text = Label.new()
	tips_text.text = "-TIPS-\n\nKeep balls on your side\n\n<- Left spinner is yours\n\nRight spinner is opponent ->\n\nKnocking down all 3 drop targets resets opponent's\n\n3 balls each player then 30 second Multiball"
	tips_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tips_text.add_theme_font_override("font", joust_font)
	tips_text.add_theme_font_size_override("font_size", 32)
	tips_text.add_theme_color_override("font_color", Color.YELLOW)
	tips_text.custom_minimum_size.x = 1024
	tips_vbox.add_child(tips_text)
	tips_text.owner = s_tips

	var s_msg2 = start_msg.duplicate()
	s_tips.add_child(s_msg2)
	s_msg2.owner = s_tips

	var tips_scene = PackedScene.new()
	tips_scene.pack(s_tips)
	ResourceSaver.save(tips_scene, "res://slides/joust_tips.tscn")

	# --- Loop generator for Slide 3 and Slide 4 ---
	for build in [["last_game_score_slide", true], ["base", false]]:
		var slide_name = build[0]
		var is_attract = build[1]

		var s = Control.new()
		s.name = "Root"
		s.set_script(load("res://addons/mpf-gmc/classes/mpf_slide.gd"))
		s.set_anchors_preset(Control.PRESET_FULL_RECT)

		var bg = ColorRect.new()
		bg.color = Color.BLACK
		bg.set_anchors_preset(Control.PRESET_FULL_RECT)
		s.add_child(bg)
		bg.owner = s

		var l = TextureRect.new()
		l.name = "Logo"
		l.texture = logo_tex
		l.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		l.set_anchors_preset(Control.PRESET_TOP_WIDE)
		l.custom_minimum_size.y = 250
		s.add_child(l)
		l.owner = s

		if is_attract:
			var t_header = Label.new()
			t_header.text = "LAST GAME"
			t_header.name = "LastGameLbl"
			t_header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			t_header.add_theme_color_override("font_color", Color.RED)
			t_header.add_theme_font_override("font", joust_font)
			t_header.add_theme_font_size_override("font_size", 40)
			t_header.set_anchors_preset(Control.PRESET_TOP_WIDE)
			t_header.offset_top = 220
			s.add_child(t_header)
			t_header.owner = s

		# PLAYER 1 - Absolute Left Half
		var p1_lbl = Label.new()
		p1_lbl.text = "PLAYER 1"
		p1_lbl.name = "P1Lbl"
		p1_lbl.add_theme_color_override("font_color", Color.YELLOW)
		p1_lbl.add_theme_font_override("font", joust_font)
		p1_lbl.add_theme_font_size_override("font_size", 70)
		p1_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		p1_lbl.position = Vector2(0, 310)
		p1_lbl.size = Vector2(576, 100)
		s.add_child(p1_lbl)
		p1_lbl.owner = s

		var p1_score = Label.new()
		p1_score.text = "0"
		p1_score.name = "P1Score"
		p1_score.add_theme_color_override("font_color", Color.YELLOW)
		p1_score.add_theme_font_override("font", joust_font)
		p1_score.add_theme_font_size_override("font_size", 95)
		p1_score.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		p1_score.set_script(load("res://addons/mpf-gmc/classes/mpf_variable.gd"))
		p1_score.variable_type = 1 if is_attract else 0 # 1=MACHINE_VAR, 0=CURRENT_PLAYER_VAR
		p1_score.variable_name = "p1_score"
		p1_score.comma_separate = true
		p1_score.initialize_empty = false
		p1_score.position = Vector2(0, 420)
		p1_score.size = Vector2(576, 120)
		s.add_child(p1_score)
		p1_score.owner = s

		# PLAYER 2 - Absolute Right Half
		var p2_lbl = Label.new()
		p2_lbl.text = "PLAYER 2"
		p2_lbl.name = "P2Lbl"
		p2_lbl.add_theme_color_override("font_color", Color("0189FF")) # Blue
		p2_lbl.add_theme_font_override("font", joust_font)
		p2_lbl.add_theme_font_size_override("font_size", 70)
		p2_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		p2_lbl.position = Vector2(576, 310)
		p2_lbl.size = Vector2(576, 100)
		s.add_child(p2_lbl)
		p2_lbl.owner = s

		var p2_score = Label.new()
		p2_score.text = "0"
		p2_score.name = "P2Score"
		p2_score.add_theme_color_override("font_color", Color("0189FF"))
		p2_score.add_theme_font_override("font", joust_font)
		p2_score.add_theme_font_size_override("font_size", 95)
		p2_score.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		p2_score.set_script(load("res://addons/mpf-gmc/classes/mpf_variable.gd"))
		p2_score.variable_type = 1 if is_attract else 0
		p2_score.variable_name = "p2_score"
		p2_score.comma_separate = true
		p2_score.initialize_empty = false
		p2_score.position = Vector2(576, 420)
		p2_score.size = Vector2(576, 120)
		s.add_child(p2_score)
		p2_score.owner = s

		if is_attract:
			var t_total = Label.new()
			t_total.text = "TOTAL\n"
			t_total.name = "TotalLbl"
			t_total.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			t_total.add_theme_color_override("font_color", Color.RED)
			t_total.add_theme_font_override("font", joust_font)
			t_total.add_theme_font_size_override("font_size", 40)
			t_total.set_anchors_preset(Control.PRESET_TOP_WIDE)
			t_total.offset_top = 588
			s.add_child(t_total)
			t_total.owner = s

			var t_score = Label.new()
			t_score.text = "0"
			t_score.name = "TotalScore"
			t_score.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			t_score.add_theme_color_override("font_color", Color.RED)
			t_score.add_theme_font_override("font", joust_font)
			t_score.add_theme_font_size_override("font_size", 70)
			t_score.set_script(load("res://addons/mpf-gmc/classes/mpf_variable.gd"))
			t_score.variable_type = 1
			t_score.variable_name = "total_score"
			t_score.comma_separate = true
			t_score.initialize_empty = false
			t_score.set_anchors_preset(Control.PRESET_TOP_WIDE)
			t_score.offset_top = 640
			s.add_child(t_score)
			t_score.owner = s

			var s_msg3 = start_msg.duplicate()
			s.add_child(s_msg3)
			s_msg3.owner = s

		var res_scene = PackedScene.new()
		res_scene.pack(s)
		ResourceSaver.save(res_scene, "res://slides/" + slide_name + ".tscn")

	# --- Carousel Slides (3 variants, one per highlighted mode) ---
	var mode_names = ["COMPETITIVE: 2-PLAYER JOUST", "CO-OPERATIVE: COMBINED SCORE", "SINGLE PLAYER JOUST"]
	var slide_names = ["carousel_competitive", "carousel_cooperative", "carousel_single"]

	for idx in range(3):
		var s_car = Control.new()
		s_car.name = slide_names[idx]
		s_car.set_script(load("res://addons/mpf-gmc/classes/mpf_slide.gd"))
		s_car.set_anchors_preset(Control.PRESET_FULL_RECT)

		var bg = ColorRect.new()
		bg.color = Color.BLACK
		bg.set_anchors_preset(Control.PRESET_FULL_RECT)
		s_car.add_child(bg)
		bg.owner = s_car

		var logo = TextureRect.new()
		logo.name = "Logo"
		logo.texture = logo_tex
		logo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		logo.set_anchors_preset(Control.PRESET_TOP_WIDE)
		logo.custom_minimum_size.y = 250
		s_car.add_child(logo)
		logo.owner = s_car

		var header = Label.new()
		header.text = "SELECT GAME MODE"
		header.name = "SelectHeaderLbl"
		header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		header.add_theme_color_override("font_color", Color.YELLOW)
		header.add_theme_font_override("font", joust_font)
		header.add_theme_font_size_override("font_size", 60)
		header.set_anchors_preset(Control.PRESET_TOP_WIDE)
		header.offset_top = 280
		s_car.add_child(header)
		header.owner = s_car

		# Create 3 mode labels
		for m in range(3):
			var lbl = Label.new()
			lbl.name = "Mode%dLbl" % (m + 1)
			lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			lbl.add_theme_font_override("font", joust_font)
			lbl.set_anchors_preset(Control.PRESET_TOP_WIDE)
			lbl.offset_top = 380 + (m * 80)

			if m == idx:
				# Highlighted mode — bright yellow, larger, with arrows
				lbl.text = ">> %s <<" % mode_names[m]
				lbl.add_theme_color_override("font_color", Color.YELLOW)
				lbl.add_theme_font_size_override("font_size", 56)
			else:
				# Non-highlighted — dim gray, smaller
				lbl.text = mode_names[m]
				lbl.add_theme_color_override("font_color", Color(0.4, 0.4, 0.4))
				lbl.add_theme_font_size_override("font_size", 44)

			s_car.add_child(lbl)
			lbl.owner = s_car

		var instr = Label.new()
		instr.text = "LEFT FLIPPER TO ROTATE      RIGHT FLIPPER TO SELECT"
		instr.name = "InstrLbl"
		instr.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		instr.add_theme_color_override("font_color", Color.RED)
		instr.add_theme_font_override("font", joust_font)
		instr.add_theme_font_size_override("font_size", 36)
		instr.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
		instr.offset_top = -120
		s_car.add_child(instr)
		instr.owner = s_car

		var scene = PackedScene.new()
		scene.pack(s_car)
		ResourceSaver.save(scene, "res://slides/%s.tscn" % slide_names[idx])

	print("================================")
	print("Success! Generated all slides including 3 carousel variants!")
