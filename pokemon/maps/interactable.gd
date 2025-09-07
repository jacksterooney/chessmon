class_name Interactable
extends StaticBody2D

@export var dialogue: Array[String]

var timeline: DialogicTimeline

func _ready() -> void:
	add_to_group("interactables")
	_create_timeline()

func start_interaction() -> void:
	Dialogic.start(timeline)
	
func _create_timeline() -> void:
	timeline = DialogicTimeline.new()
	var events: Array[DialogicEvent] = []
	for line in dialogue:
		var event := DialogicTextEvent.new()
		event.text = line
		events.append(event)
	
	var end_dialogue_event := DialogicEndTimelineEvent.new()
	events.append(end_dialogue_event)
		
	timeline.events = events
	timeline.events_processed = true
		
