extends Node2D


func _ready() -> void:
	$Levels/Level1.load()


# TODO: Either change the way this is done, or apply the same methodology to the Inventory.
func _on_level_1_phase_change(Phase: Variant) -> void:
	if Phase == Level.Phase.PLAN:
		$PhaseLabel.text = "PLAN YOUR\nEXPEDITION"
	elif Phase == Level.Phase.EXPLORE:
		$PhaseLabel.text = "EXPLORE!"
