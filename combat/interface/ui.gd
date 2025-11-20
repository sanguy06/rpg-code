extends Control

signal flee(winner: Combatant, loser: Combatant)


@export var combatants_node: Node
@export var info_scene: PackedScene
@onready var popup = $PopupPanel
@onready var gridContainer = $Buttons/GridContainer

func initialize() -> void:
	# Set Popup
	popup.popup_centered()
	popup.show()
	
	# Get JSON File
	var file = FileAccess.open("res://combat/questions/question_set1.json", 
		FileAccess.READ)
	var text = file.get_as_text()
	var data = JSON.parse_string(text)
	
	var count = 0
	# Enable All Buttons
	for button in gridContainer.get_children():
		button.disabled = false
		#button.text = data["opponent1"]["answers"][count]
		count += 1
		
	for combatant in combatants_node.get_children():
		var health := combatant.get_node(^"Health")
		var info := info_scene.instantiate()
		var health_info := info.get_node(^"VBoxContainer/HealthContainer/Health")
		health_info.value = health.life
		health_info.max_value = health.max_life
		info.get_node(^"VBoxContainer/NameContainer/Name").text = combatant.name
		health.health_changed.connect(health_info.set_value)
		$Combatants.add_child(info)

	$Buttons/GridContainer/Attack.grab_focus()


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

# Force Character to flee if answer is wrong
func _on_Answer1_button_up() -> void: 
	popup.hide()
	disableButtons()

# Answer is correct, so allow them to choose
func _on_Answer2_button_up() -> void: 
	popup.hide()

func _on_Answer3_button_up() -> void: 
	popup.hide()
	disableButtons()

func _on_Answer4_button_up() -> void: 
	popup.hide()
	disableButtons()

# Allow User to only choose Flee
func disableButtons() -> void: 
	$Buttons/GridContainer/Attack.disabled = true
	$Buttons/GridContainer/Defend.disabled = true
