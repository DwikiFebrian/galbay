extends Node2D

@onready var label_uang = $"Control/Main layout/Panel atas/uang"
@onready var label_turn = $"Control/Main layout/Panel atas/turn"
@onready var label_boss = $"Control/Main layout/Panel atas/boss"
@onready var label_setor = $"Control/Main layout/Panel atas/setor"
@onready var label_queue = $"Control/Main layout/Panel atas/queue"
@onready var container_draft = $"Control/Main layout/PanelContainer/Paneh tengah/Targetlist"
@onready var container_aktif = $"Control/Main layout/list/VBoxContainer/Paneh bawah/PanelContainer/list nasabah"
@onready var middle_sucker_button = $"Control/Main layout/list/upgrade/MarginContainer/list upgrade/middle sucker/middle sucker"
@onready var high_sucker_button = $"Control/Main layout/list/upgrade/MarginContainer/list upgrade/high sucker/high sucker"
@onready var counter_expansion_button = $"Control/Main layout/list/upgrade/MarginContainer/list upgrade/counter expansion/button"
@onready var doomer_influencer_button = $"Control/Main layout/list/upgrade/MarginContainer/list upgrade/doomer influencer/button"
@onready var broken_kneecaps_button = $"Control/Main layout/list/upgrade/MarginContainer/list upgrade/broken kneecaps/button"
@onready var middle_sucker_upgrades = $"Control/Main layout/list/upgrade/MarginContainer/list upgrade/middle sucker"
@onready var high_sucker_upgrades = $"Control/Main layout/list/upgrade/MarginContainer/list upgrade/high sucker"
@onready var broken_kneecaps_upgrades = $"Control/Main layout/list/upgrade/MarginContainer/list upgrade/broken kneecaps"
@onready var anim_menang = $Control/EngGameLayer/animasimenang
@onready var anim_kalah = $Control/EngGameLayer/animasikalah
@onready var label_judul = $Control/EngGameLayer/UIContainer/LabelJudul
@onready var label_skor = $Control/EngGameLayer/UIContainer/LabelScore

@onready var kurang_duid_audio = $"Control/Main layout/PanelContainer/Paneh tengah/kurang duid"
@onready var accept_audio = $"Control/Main layout/PanelContainer/Paneh tengah/accept"
@onready var reject_audio = $"Control/Main layout/PanelContainer/Paneh tengah/reject"
@onready var bgm_menang = $"Control/EngGameLayer/bgm menang"
@onready var bgm_kalah = $"Control/EngGameLayer/bgm kalah"
@onready var kd_counter_audio = $"Control/Main layout/list/upgrade/MarginContainer/list upgrade/counter expansion/button/kurang duid"

# cutscene
# Tambahkan referensi ke bungkus utama dialog box buat di-hide/show
@onready var ui_layer = $ui_layer
@onready var dialog_box = $"ui_layer/dialog box" 
@onready var dialog_text = $"ui_layer/dialog box/RichTextLabel"
@onready var gambar_babi = $ui_layer/babi

var tween: Tween 
var nasabah_scene = preload("res://nasabahcards.tscn")
var active_row_scene = preload("res://nasabahaktif.tscn")

# dialog
var dialog_lines: Array = []
var current_line: int = 0

var is_dialog_active: bool = false 

# state
var player_cash: int = 10000
var current_turn: int = 0
var deadline: int = 12
var quarter: int = 0
var max_turn: int = 48
var target = [150, 300, 600, 1000]
var boss_goal: int = target[0]
var nasabah_aktif: Array = []
var antrean_nasabah: Array = [] # buat nyimpen 12 calon nasabah per turn
var queue_length: int = 4
var current_on_queue: int = 0
var max_tampil = 2
var weight = [3,0,0]

# modifier upgrade
var bonus_return: int = 0
var bonus_tenor: int = 0
var reduksi_galbay: float = 0.0

# harga upgrade
var harga_counter_expansion = [30, 60]
var harga_middle_sucker = [40, 60, 85]
var harga_high_sucker = [80, 165, 250]
var harga_doomer_influencer = [30, 67, 100, 180]
var harga_broken_kneecap = [60, 125]

# level upgrade
var level_middle_sucker = 0
var level_high_sucker = 0
var level_counter_expansion_sucker = 0
var level_doomer_influencer = 0
var level_broken_kneecaps = 0

# katalog manual
var template_kelas = [
	{
		"tipe": "Low Income",
		"modal_min": 10, "modal_max": 25,
		"bunga_min": 0.30, "bunga_max": 0.50,
		"return_min": 4, "return_max": 7,
		"galbay_min": 0.10, "galbay_max": 0.20,
		"gambar": [
			"res://sprite/low1.png", 
			"res://sprite/low2.png", 
			"res://sprite/low3.png",
			"res://sprite/low4.png",
			"res://sprite/low5.png",
			"res://sprite/low6.png"
			
		]
	}
	,
	{
		"tipe": "Middle Class",
		"modal_min": 40, "modal_max": 80,
		"return_min": 10, "return_max": 18,
		"bunga_min": 0.15, "bunga_max": 0.35,
		"galbay_min": 0.07, "galbay_max": 0.15,
		"gambar": [
			"res://sprite/middle1.png",
			"res://sprite/middle2.png",
			"res://sprite/middle3.png",
			"res://sprite/middle4.png",
			"res://sprite/middle5.png"
		]
	},
	{
		"tipe": "High Income",
		"modal_min": 100, "modal_max": 200,
		"return_min": 25, "return_max": 40,
		"bunga_min": 0.10, "bunga_max": 0.20,
		"galbay_min": 0.05, "galbay_max": 0.10,
		"gambar": [
			"res://sprite/high1.png",
			"res://sprite/high2.png",
			"res://sprite/high3.png",
			"res://sprite/high4.png" 
		]
	}
]

func _ready() -> void:
	update_ui_header()
	tutorial()
	# bikin 12 antrean
	generate_antrean_turn(queue_length)

func update_ui_header() -> void:
	label_uang.text = str(player_cash)
	#label_turn.text = "Turn: Week " + str(current_turn) + " / Week " + str(max_turn)
	#label_boss.text = "Boss Goal: $" + str(boss_goal)
	label_setor.text = "Tribute $" + str(boss_goal) + " in " + str(deadline - current_turn) + " week"
	#label_boss.text = "Tribute $" + str(boss_goal)
	#label_turn.text = "in " + str(deadline - current_turn) + " week"
	label_queue.text = str(current_on_queue) + " suckers currently on queue"

# bikin antrean
func generate_antrean_turn(jumlah: int) -> void:
	antrean_nasabah.clear()
	for child in container_draft.get_children():
		child.queue_free()
	
	var class_weight = []
	for i in range(3):
		for j in weight[i]:
			class_weight.append(i)
	for i in range(jumlah):
		#var kelas_terpilih = template_kelas.pick_random()
		var chosen_class = class_weight.pick_random()
		var kelas_terpilih = template_kelas[chosen_class]
		var data_random = {
			"id_nasabah": randi_range(1000, 9999),
			"tipe_kelas": kelas_terpilih["tipe"],
			"modal": randi_range(kelas_terpilih["modal_min"], kelas_terpilih["modal_max"]),
			"bunga": randf_range(kelas_terpilih["bunga_min"], kelas_terpilih["bunga_max"]),
			#"cicilan_per_turn": randi_range(kelas_terpilih["return_min"], kelas_terpilih["return_max"]),
			"peluang_galbay": max(0.01, randf_range(kelas_terpilih["galbay_min"], kelas_terpilih["galbay_max"]) /pow(2, level_broken_kneecaps) ),
			"tenor": 4 + bonus_tenor,
			"path_gambar": kelas_terpilih["gambar"].pick_random()
		}
		data_random["cicilan_per_turn"] = int(ceil(data_random["modal"] * (1 + data_random["bunga"]) / data_random["tenor"])) + bonus_return
		antrean_nasabah.append(data_random) # Masukkan ke dalam antrean
		
	isi_slot_kosong()

func isi_slot_kosong() -> void:
	var jumlah_sekarang = 0
	
	for child in container_draft.get_children():
		if not child.is_queued_for_deletion():
			jumlah_sekarang += 1
			
	while jumlah_sekarang < max_tampil and antrean_nasabah.size() > 0:
		var data_next = antrean_nasabah.pop_front() 
		
		var kartu_baru = nasabah_scene.instantiate()
		
		kartu_baru.nasabah_diterima.connect(proses_terima_nasabah)
		kartu_baru.nasabah_ditolak.connect(proses_tolak_nasabah)
		
		container_draft.add_child(kartu_baru)
		if quarter <= 1:
			kartu_baru.isi_data_no_galbay(data_next)
		else:
			kartu_baru.isi_data(data_next)
		
		current_on_queue = antrean_nasabah.size()
		jumlah_sekarang += 1
		
	current_on_queue = antrean_nasabah.size()
	update_ui_header()
	print("sisa antrean: ", antrean_nasabah.size())

func proses_terima_nasabah(kartu: Node, data: Dictionary) -> void:
	if player_cash >= data["modal"]:
		player_cash -= data["modal"]
		nasabah_aktif.append(data)
		update_ui_header()
		
		var baris_baru = active_row_scene.instantiate()
		container_aktif.add_child(baris_baru)
		
		if quarter <= 1:
			baris_baru.isi_data_no_galbay(data)
		else:
			baris_baru.isi_data(data) 
		
		kartu.queue_free()
		
		accept_audio.play()
		call_deferred("isi_slot_kosong")
	else:
		print("duit kurang")
		kurang_duid_audio.play()

func proses_tolak_nasabah(kartu: Node) -> void:
	kartu.queue_free()
	reject_audio.play()
	call_deferred("isi_slot_kosong")

func _on_nextweek_pressed() -> void:
	print("minggu berganti")
	
	var penghutang = get_node("Control/Main layout/list/VBoxContainer/Paneh bawah/PanelContainer/list nasabah")
	for nasabah in penghutang.get_children():
		if quarter <= 1:
			nasabah.kurangi_turn_no_galbay()
		else:
			nasabah.kurangi_turn()
	
	for i in range(len(nasabah_aktif) - 1, -1, -1):
		var nasabah = nasabah_aktif[i]
		if nasabah.has("is_galbay") and nasabah["is_galbay"] == true:
			nasabah_aktif.remove_at(i)
			continue
		player_cash += nasabah["cicilan_per_turn"]
		nasabah["tenor"] -= 1
		if nasabah["tenor"] == 0:
			nasabah_aktif.remove_at(i)
		
	update_ui_header()
	
	current_turn += 1
	if current_turn % 12 == 0:
		setor_boss()
		current_turn = 0
		quarter += 1
		new_quarter()
	
	update_ui_header()
	generate_antrean_turn(queue_length)
	
	var sisa_minggu = deadline - current_turn
	var float_lbl = Label.new()
	
	if sisa_minggu == 1:
		float_lbl.text = "LAST WEEK!"
	else:
		float_lbl.text = str(sisa_minggu) + " WEEKS LEFT!"

	float_lbl.add_theme_font_size_override("font_size", 72)
	
	if sisa_minggu <= 3:
		float_lbl.modulate = Color(1.0, 0.2, 0.2) # Merah bahaya
	else:
		float_lbl.modulate = Color(1.0, 0.7, 0.1) # Kuning

	float_lbl.custom_minimum_size = Vector2(400, 100)
	float_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	float_lbl.z_index = 100 
		
	add_child(float_lbl)

	var screen_size = get_viewport_rect().size
	var center_x = (screen_size.x / 2.0) - (float_lbl.custom_minimum_size.x / 2.0)
	var center_y = (screen_size.y / 2.0)
	
	float_lbl.global_position = Vector2(center_x, center_y)
	
	var tw = create_tween()
	tw.set_parallel(true)
	tw.tween_property(float_lbl, "global_position:y", float_lbl.global_position.y - 100, 1.2).set_trans(Tween.TRANS_SINE)
	tw.tween_property(float_lbl, "modulate:a", 0.0, 1.2)
	
	tw.chain().tween_callback(float_lbl.queue_free)
	
func setor_boss():
	if player_cash < boss_goal:
		game_over()
	else:
		player_cash -= boss_goal
		
func new_quarter():
	if quarter == 4:
		end_game()
	else:
		boss_goal = target[quarter]
		if quarter == 1:
			middle_sucker_upgrades.visible = true
			high_sucker_upgrades.visible = true
			var dialog_lines_q2: Array[String] = ["These broke suckers only bring in chump change.", 
			"Set up a Gambling Ring Partnership to lure in bigger fish,", 
			"those naive folks who think they can double their money."]
			start_dialog(dialog_lines_q2)
		elif quarter == 2:
			broken_kneecaps_upgrades.visible = true
			var dialog_lines_q3: Array[String] = ["Business was good, but the street has changed.", 
			"Some suckers figured out they can just run away with your money and stop paying back.", 
			"We call it Galbay."]
			start_dialog(dialog_lines_q3)
		elif quarter == 3:
			var dialog_lines_q4: Array[String] = ["Soon, you’ll see if you’ve actually got what it takes to be a big shot.", "Now is the moment that separates the players from the suckers."]
			start_dialog(dialog_lines_q4)
		
func game_over():
	$Control/EngGameLayer.visible = true
	anim_menang.visible = false
	anim_kalah.visible = true
	anim_kalah.play("default") 
	
	label_judul.text = "[center][b][color=#ff3333]YOU'RE THE SUCKER NOW.[/color][/b][/center]"
	label_skor.text = "[center][b]Failed to pay the $" + str(boss_goal) + " tribute.[/b]\nYou couldn't bleed those suckers dry, [b]so the Boss is gonna bleed YOU instead.[/b]\n\n[b][All assets seized][/b][/center]"
	
	var ui_container = $Control/EngGameLayer/UIContainer
	var background_gelap = $Control/EngGameLayer/ColorRect
	
	ui_container.modulate.a = 0.0
	background_gelap.color.a = 0.0
	anim_kalah.modulate.a = 0.0 

	if tween and tween.is_running():
		tween.kill()
	tween = get_tree().create_tween()
	tween.set_parallel(true) 
	tween.tween_property(background_gelap, "color:a", 0.8, 1.5) 
	tween.tween_property(ui_container, "modulate:a", 1.0, 1.5) 
	tween.tween_property(anim_kalah, "modulate:a", 1.0, 1.5)   
	
	$"Control/Main layout/Paneh footer/nextweek".disabled = true
	print("Game Over")
	
func end_game():
	$Control/EngGameLayer.visible = true
	bgm_menang.play()
	anim_kalah.visible = false
	anim_menang.visible = true
	anim_menang.play("default") 
	
	label_judul.text = "[center][b][color=#33cc33]YOU'RE THE BOSS NOW.[/color][/b][/center]"
	label_skor.text = "[center][b]Tribute paid in full![/b] You've bled those suckers so dry that you just bought a seat at the table. [b]You don't pay tributes anymore—you collect them.[/b]\n\n[b]Filthy Cash Left: $" + str(player_cash) + "[/b][/center]"
	
	var ui_container = $Control/EngGameLayer/UIContainer
	var background_gelap = $Control/EngGameLayer/ColorRect
		
	ui_container.modulate.a = 0.0
	background_gelap.color.a = 0.0
	anim_menang.modulate.a = 0.0 

	if tween and tween.is_running():
			tween.kill()
	tween = get_tree().create_tween()
	tween.set_parallel(true) 
	tween.tween_property(background_gelap, "color:a", 0.8, 1.5) 
	tween.tween_property(ui_container, "modulate:a", 1.0, 1.5)  
	tween.tween_property(anim_menang, "modulate:a", 1.0, 1.5) 
	
	$"Control/Main layout/Paneh footer/nextweek".disabled = true
	
# tombol upgrade

func _on_middle_sucker_pressed() -> void:
	if player_cash >= harga_middle_sucker[level_middle_sucker]:
		player_cash -= harga_middle_sucker[level_middle_sucker]
		weight[1] += 4
		level_middle_sucker += 1
		update_ui_header()
	else:
		kurang_duid_audio.play()
		print("Duit kurang buat upgrade Middle Sucker")
	if level_middle_sucker == 2:
		middle_sucker_button.disabled = true
	else:
		middle_sucker_button.text ="$" +  str(harga_middle_sucker[level_middle_sucker])
		
func _on_high_sucker_pressed() -> void:
	if player_cash >= harga_high_sucker[level_high_sucker]:
		player_cash -= harga_high_sucker[level_high_sucker]
		weight[1] += 5
		level_high_sucker += 1
		update_ui_header()
	else:
		kurang_duid_audio.play()
		print("Duit kurang buat upgrade High Sucker")
	if level_high_sucker == 3:
		high_sucker_button.disabled = true
	else:
		high_sucker_button.text ="$" +  str(harga_high_sucker[level_high_sucker])

func _on_counter_expansion_pressed() -> void:
	if player_cash >= harga_counter_expansion[level_counter_expansion_sucker]:
		player_cash -= harga_counter_expansion[level_counter_expansion_sucker]
		max_tampil += 1 
		level_counter_expansion_sucker += 1 
		
		update_ui_header()
		isi_slot_kosong() 
	else:
		kurang_duid_audio.play()
		print("Duit kurang buat upgrade Counter Expansion!")
	
	if level_counter_expansion_sucker == 2:
		counter_expansion_button.disabled = true
		counter_expansion_button.text = "Sold"
	else:
		counter_expansion_button.text = "$" + str(harga_counter_expansion[level_counter_expansion_sucker])


#func _on_tombolbeli_2_pressed() -> void:
	#if player_cash >= harga_up2:
		#player_cash -= harga_up2
		#bonus_return += 1
		#harga_up2 += 50
		#update_ui_header()
	#else:
		#print("Duit kurang buat Upgrade 2!")


func _on_doomer_influencer_pressed() -> void:
	if player_cash >= harga_doomer_influencer[level_doomer_influencer]:
		player_cash -= harga_doomer_influencer[level_doomer_influencer]
		queue_length += 2
		level_doomer_influencer += 1
		update_ui_header()
	else:
		kurang_duid_audio.play()
		print("Duit kurang buat upgrade Doomer Influencer!")
		
	if level_doomer_influencer == 4:
		doomer_influencer_button.disabled = true
	else:
		doomer_influencer_button.text = "$" + str(harga_doomer_influencer[level_doomer_influencer])


#func _on_tombolbeli_4_pressed() -> void:
	#if player_cash >= harga_up4:
		#player_cash -= harga_up4
		#bonus_tenor += 1
		#harga_up4 += 50
		#update_ui_header()
	#else:
		#print("Duit kurang buat Upgrade 4!")


func _on_broken_kneecap_pressed() -> void:
	if player_cash >= harga_broken_kneecap[level_broken_kneecaps]:
		player_cash -= harga_broken_kneecap[level_broken_kneecaps]
		level_broken_kneecaps += 1
		update_ui_header()
		
	else:
		kurang_duid_audio.play()
		print("Duit kurang buat Upgrade 5!")
	if level_broken_kneecaps == 2:
		broken_kneecaps_button.disabled = true
	else:
		broken_kneecaps_button.text = "$" + str(harga_broken_kneecap[level_broken_kneecaps])

func _on_button_restart_pressed() -> void:
	get_tree().reload_current_scene()
func tutorial():
	var dialog_lines_tutorial: Array[String] = ["Here's $100 and a business,","Expand it yourself and give me my cut every 12 weeks.", "Figure the rest out on your own."]
	gambar_babi.visible = true
	start_dialog(dialog_lines_tutorial)
	gambar_babi.visible = false

func start_dialog(lines: Array[String]) -> void:
	if lines.is_empty():
		return
		
	dialog_lines = lines
	current_line = 0
	is_dialog_active = true
	
	ui_layer.visible = true
	#show() # Make the dialogue box visible
	tampilkan_dialog()

func tampilkan_dialog() -> void:
	if current_line < dialog_lines.size():
		dialog_text.text = dialog_lines[current_line]
		dialog_text.visible_ratio = 0.0 
		
		# Cancel previous tween if it exists before making a new one
		if tween and tween.is_running():
			tween.kill()
			
		tween = get_tree().create_tween()
		var durasi_ngetik = dialog_lines[current_line].length() * 0.05
		tween.tween_property(dialog_text, "visible_ratio", 1.0, durasi_ngetik)
	else:
		# Hide and reset when all lines are finished
		is_dialog_active = false
		ui_layer.visible = false

func _input(event: InputEvent) -> void:
	if not is_dialog_active:
		return
		
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		lanjut_dialog()

func lanjut_dialog() -> void:
	if tween and tween.is_running():
		tween.kill()
		dialog_text.visible_ratio = 1.0
	else:
		current_line += 1
		tampilkan_dialog()
