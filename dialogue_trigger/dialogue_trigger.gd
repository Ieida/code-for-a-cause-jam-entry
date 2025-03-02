class_name DialogueTrigger extends Area2D


@export var disable_after_trigger: bool
## Should the main line be said by the companion?
@export var is_main_line_companion: bool
@export_multiline var main_line: String
## Should the response be included?
@export var respond: bool
@export_multiline var response: String


func _on_body_entered(body: Node2D):
	if body.has_method(&"say"):
		if disable_after_trigger: disable()
		if is_main_line_companion:
			var cmp = body.get(&"companion")
			if cmp:
				cmp.say(main_line)
				if respond:
					await get_tree().create_timer(5).timeout
					body.say(response)
		else:
			body.say(main_line)
			if respond:
				var cmp = body.get(&"companion")
				if cmp:
					await get_tree().create_timer(5).timeout
					cmp.say(response)


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func disable():
	set_deferred(&"monitoring", false)


func enable():
	set_deferred(&"monitoring", true)
