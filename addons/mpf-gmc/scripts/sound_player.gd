# Copyright 2021 Paradigm Tilt

extends GMCCoreScriptNode

signal marker(event_name: String)

@onready var duckAttackTimer = Timer.new()
@onready var duckReleaseTimer = Timer.new()

var buses := {}
var default_bus: GMCBus
var default_duck_bus: GMCBus


func initialize(config: ConfigFile, log_level: int = 30) -> void:
	self.configure_logging("SoundPlayer")
	for i in range(0, AudioServer.bus_count):
		var bus_name: String = AudioServer.get_bus_name(i)
		var bus_obj = GMCBus.new(self.mpf, bus_name, log_level)
		self.buses[bus_name] = bus_obj
		self.add_child(bus_obj)
		
		# --- FORCE WAKEUP: Set every bus to 0dB (Full Volume) immediately ---
		AudioServer.set_bus_volume_db(i, 0.0)
		AudioServer.set_bus_mute(i, false)
		print("FORCING BUS ALIVE: ", bus_name, " at 0dB")
		
		if bus_obj.has_method("set_bus_volume_full"):
			bus_obj.set_bus_volume_full(0.0) 
			print("GMC ENGINE: Forced '", bus_name, "' bus to active.")
			
	self.configure_logging("SoundPlayer")
	for i in range(0, AudioServer.bus_count):
		var bus_name: String = AudioServer.get_bus_name(i)
		self.buses[bus_name] = GMCBus.new(self.mpf, bus_name, log_level)
		# Buses have tweens so must be in the tree
		self.add_child(self.buses[bus_name])
	if config.has_section("sound_system"):
		for key in config.get_section_keys("sound_system"):
			var settings: Dictionary = config.get_value("sound_system", key)
			var target_bus_name: String = settings['bus'] if settings.get('bus') else key
			assert(target_bus_name in self.buses, "Sound system does not have an audio bus '%s' configured." % target_bus_name)
			assert(settings.get("type"), "Sound system bus '%s' missing required field 'type'." % target_bus_name)
			var bus_type := GMCBus.get_bus_type(settings["type"])
			var bus: GMCBus = self.buses[target_bus_name]
			bus.set_type(bus_type)
			var channels_to_make = 2 if bus_type == GMCBus.BusType.SOLO else settings.get("simultaneous_sounds", 1)
			for i in range(0, channels_to_make):
				var channel_name: String = "%s_%s" % [target_bus_name, i+1]
				bus.create_channel(channel_name)
			# A bus can be marked default
			if settings.get("default", false):
				self.default_bus = self.buses[target_bus_name]
			# A bus can be default for ducking
			if settings.get("duck_default", false):
				self.default_duck_bus = self.buses[target_bus_name]

func _ready() -> void:
	self.mpf.game.volume.connect(self._on_volume)
	self.mpf.server.connect("clear", self._on_clear_context)
	# Set names to help debugging
	duckAttackTimer.name = "DuckAttackTimer"
	duckReleaseTimer.name = "DuckReleaseTimer"

func _exit_tree():
	duckAttackTimer.free()
	duckReleaseTimer.free()

func get_bus(bus_name: String = "") -> GMCBus:
	if not bus_name:
		assert(self.default_bus, "No default bus defined.")
		return self.default_bus
	return self.buses[bus_name]

func get_ducking_bus(bus_name: String = "") -> GMCBus:
	if not bus_name:
		assert(self.default_duck_bus, "No default duck bus defined.")
		return self.default_duck_bus
	return self.get_bus(bus_name)

func play_sounds(s: Dictionary) -> void:
	assert(typeof(s) == TYPE_DICTIONARY, "Sound player called with non-dict value: %s" % s)
	
	if not s.has("settings") or s.settings.keys().size() == 0:
		return

	for asset in s.settings.keys():
		var settings: Dictionary = s.settings[asset]
		
		# 1. Defensive Checks
		if not self.mpf.media.sounds.has(asset):
			continue

		# 2. Handle Nulls from MPF 0.81
		if settings.get("volume") == null: settings["volume"] = 1.0
		if settings.get("bus") == null: 
			settings["bus"] = "sfx" if "sfx" in self.buses else "Master"

		# 3. Get the Sound Resource
		var config: Variant = self.mpf.media.get_sound_instance(asset)
		if not config: continue

		var file_path: String = ""
		if config is AudioStream:
			file_path = config.resource_path
		elif config is MPFSoundAsset:
			file_path = config.stream.resource_path
			# Merge asset properties
			for prop in ["bus", "volume"]:
				if settings.get(prop) == null and config.get(prop):
					settings[prop] = config[prop]
		
		# 4. EXECUTE PLAY (The Direct Godot Way)
		var stream = load(file_path)
		if stream:
			var player = AudioStreamPlayer.new()
			self.add_child(player) # Add directly to the sound_player node
			
			player.stream = stream
			player.bus = settings["bus"] # e.g., "sfx"
			
			# Linear to DB conversion for the volume
			var vol = float(settings.get("volume", 1.0))
			player.volume_db = linear_to_db(vol)
			
			player.play()
			
			# Self-destruct the player when the sound finishes to save memory
			player.finished.connect(player.queue_free)
			
			print("GMC LIVE: Played ", asset, " on bus ", settings["bus"], " at vol ", vol)
		else:
			print("ERROR: Could not load ", file_path)

		# NOTE: We are NOT calling bus.play() here because it is currently failing.

func play_bus(s: Dictionary) -> void:
	for bus_name in s.settings.keys():
		assert(bus_name in self.buses, "Bus name %s is not a valid audio bus." % bus_name)
		var bus: GMCBus = self.buses[bus_name]
		var settings: Dictionary = s.settings[bus_name]

		match settings["action"]:
			"pause":
				bus.pause({"fade_out": settings.get("fade")})
			"unpause":
				bus.unpause({"fade_in": settings.get("fade")})
			"stop":
				bus.stop_all(settings.get("fade", 0.0))

# Not currently implemented anywhere
func stop_all(fade_out: float = 1.0) -> void:
	self.log.debug("STOP ALL called with fadeout of %s" , fade_out)
	for bus in self.buses.values():
		bus.stop_all(fade_out)

func _on_volume(bus: String, value: float, _change: float) -> void:
	print("VOLUME UPDATE: Bus ", bus, " set to ", value) # <--- ADD THIS
	var bus_name: String = bus.trim_suffix("_volume")
	# The Master bus is fixed and capitalized
	if bus_name.to_lower() == "master":
		bus_name = "Master"
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index(bus_name), linear_to_db(value))
		return
	# Some devices, like hardware sound platforms, have volumes as well.
	# Those don't correspond to buses, so ignore them.
	if bus_name not in self.buses:
		self.log.debug("No software audio bus named '%s', ignoring.", bus_name)
		return
	self.buses[bus_name].set_bus_volume_full(linear_to_db(value))

func _on_clear_context(context_name: String) -> void:
	# Loop through all the channels and stop any that are playing this context
	for bus in self.buses.values():
		bus.clear_context(context_name)
