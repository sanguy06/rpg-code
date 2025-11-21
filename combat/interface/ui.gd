extends Control

signal flee(winner: Combatant, loser: Combatant)

@export var combatants_node: Node
@export var info_scene: PackedScene
@onready var popup = $PopupPanel
@onready var gridContainer = $PopupPanel/GridContainer
@onready var correctAnswer = 0
@onready var playerMove = false

func initialize() -> void:

	for combatant in combatants_node.get_children():
		var health := combatant.get_node(^"Health")
		var info := info_scene.instantiate()
		var health_info := info.get_node(^"VBoxContainer/HealthContainer/Health")
		health_info.value = health.life
		health_info.max_value = health.max_life
		info.get_node(^"VBoxContainer/NameContainer/Name").text = combatant.name
		health.health_changed.connect(health_info.set_value)
		health.damage_taken.connect(show_question_popup)
		$Combatants.add_child(info)
	
	show_question_popup()
	
	$Buttons/GridContainer/Attack.grab_focus()
	

func show_question_popup() -> void: 
	# Set Popup
	popup.popup_centered()
	popup.show()
	
	# Set Buttons to Enabled 
	$Buttons/GridContainer/Attack.disabled = false
	$Buttons/GridContainer/Defend.disabled = false
	$Buttons/GridContainer/Flee.disabled = false
	
	# Generate Random Number for Random question
	randomize()
	var n = randi_range(0, 3) 
	
	# Get JSON File
	var file = FileAccess.open("res://combat/questions/question_set1.json", 
		FileAccess.READ)
	var text = file.get_as_text()
	var data = JSON.parse_string(text)
	
	# Get Correct Answer Depending on Random Question Generated
	correctAnswer = data[n]["correct_answer"]
	
	# Enable all buttons
	var answer_index = 0
	for button in gridContainer.get_children():
		if button is Label:
			button.text = data[n]["question"]
			continue
		button.disabled = false
		button.text = data[n]["answers"][answer_index]
		answer_index += 1
			
func _on_Attack_button_up() -> void:
	if not combatants_node.get_node(^"Player").active:
		return
	combatants_node.get_node(^"Player").attack(combatants_node.get_node(^"Opponent"))

func _on_Defend_button_up() -> void:
	if not combatants_node.get_node(^"Player").active:
		return
	combatants_node.get_node(^"Player").defend()


func _on_Flee_button_up() -> void:
	if not combatants_node.get_node(^"Player").active:
		return

	combatants_node.get_node(^"Player").flee()

	var loser: Combatant = combatants_node.get_node(^"Player")
	var winner: Combatant = combatants_node.get_node(^"Opponent")
	flee.emit(winner, loser)

# These buttons used Connection native to IDE

# If Answer is wrong user can't attack
func _on_Answer1_button_up() -> void: 
	if correctAnswer != 1: 
		disableButtons()
	popup.hide()

# Answer is correct, so allow them to choose
func _on_Answer2_button_up() -> void: 
	if correctAnswer != 2: 
		disableButtons()
	popup.hide()
	
func _on_Answer3_button_up() -> void: 
	if correctAnswer != 3: 
		disableButtons()
	popup.hide()
		

func _on_Answer4_button_up() -> void: 
	if correctAnswer != 4: 
		disableButtons()
	popup.hide()
		

# Allow User to only choose Flee
func disableButtons() -> void: 
	$Buttons/GridContainer/Attack.disabled = true
