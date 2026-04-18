extends VBoxContainer
class_name RoomInterface

# BBCode format
#[wave amp=30.0 freq=1.5]
	#[tornado radius=3.0 freq=0.5 connected=1]
		#[b]Room:
		#[rainbow freq=5.0 sat=0.4 val=1.0 speed=0.1]1[/rainbow]
		#[/b]
	#[/tornado]
#[/wave]

@onready var label := %RichTextLabel

func set_room_number(num: int) -> void:
	label.clear()
	label.push_bold()
	label.append_text("[wave amp=30.0 freq=1.5]")
	label.append_text("[tornado radius=3.0 freq=0.5 connected=1]")
	label.append_text("Room: ")

	label.append_text("[rainbow freq=5.0 sat=0.4 val=1.0 speed=0.1]")
	label.append_text("%s" % num)
	label.append_text("[/rainbow]")

	label.append_text("[/tornado]")
	label.append_text("[/wave]")
	label.pop()
