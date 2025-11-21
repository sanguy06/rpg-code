extends Node

const PLAYER_WIN = "res://dialogue/dialogue_data/player_won.json"
const PLAYER_LOSE = "res://dialogue/dialogue_data/player_lose.json"

# Export New Combat Screen Nodes for the New Opponents into the Game Scene
@export var combat_screen: Node2D
@export var exploration_screen: Node2D
@export var combat2_screen: Node2D
@export var combat3_screen : Node2D
@export var current_opponent : Node2D

func _ready() -> void:
	combat_screen.combat_finished.connect(_on_combat_finished)

	for n in $Exploration/Grid.get_children():
		if not n.type == n.CellType.ACTOR:
			continue
		if not n.has_node(^"DialoguePlayer"):
			continue
		n.get_node(^"DialoguePlayer").dialogue_finished.connect(_on_opponent_dialogue_finished.bind(n))

	remove_child(combat_screen)


func start_combat(combat_actors: Array[PackedScene], exploration_opponent: Pawn) -> void:
	$AnimationPlayer.play(&"fade_to_black")
	await $AnimationPlayer.animation_finished
	remove_child($Exploration)
	add_child(combat_screen)
	combat_screen.show()
	combat_screen.initialize(combat_actors)
	self.current_opponent = exploration_opponent
	$AnimationPlayer.play_backwards(&"fade_to_black")


func _on_opponent_dialogue_finished(opponent: Pawn) -> void:
	if opponent.lost:
		return
	var player: Node2D = $Exploration/Grid/Player
	var combatants: Array[PackedScene] = [player.combat_actor, opponent.combat_actor]
	if opponent.name != "Opponent4":
		start_combat(combatants, opponent)


func _on_combat_finished(winner: Combatant, loser: Combatant) -> void:
	var is_player_winner = false
	remove_child(combat_screen)
	$AnimationPlayer.play_backwards(&"fade_to_black")
	add_child(exploration_screen)
	var dialogue: Node = load("res://dialogue/dialogue_player/dialogue_player.tscn").instantiate()
	if winner.name == "Player":
		dialogue.dialogue_file = PLAYER_WIN
		is_player_winner = true
	else:
		dialogue.dialogue_file = PLAYER_LOSE

	await $AnimationPlayer.animation_finished
	var player: Pawn = $Exploration/Grid/Player
	exploration_screen.get_node(^"DialogueCanvas/DialogueUI").show_dialogue(player, dialogue)
	combat_screen.clear_combat()
	await dialogue.dialogue_finished
	dialogue.queue_free()
	
	if is_player_winner and is_instance_valid(current_opponent):
		current_opponent.queue_free()
		current_opponent = null
