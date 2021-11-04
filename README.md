# Exercise-05d-Networked-Game
Exercise for MSCH-C220, 4 November 2021

This exercise is a chance to play with Godot's networking capability in a 3D context. We will be extending a simple first-person-controlled character and allow the control of two of these characters over localhost.

Fork this repository. When that process has completed, make sure that the top of the repository reads [your username]/Exercise-05d-Networked-Game. Edit the LICENSE and replace BL-MSCH-C220-F21 with your full name. Commit your changes.

Clone the repository to a Local Path on your computer.

Open Godot. Import the project.godot file and open the "Networked Game" project.

In res://Game.tscn, I have provided a starting place for the exercise: the scene contains a parent Spatial node (named Game) and a StaticBody Ground node (containing a MeshInstance Plane and a CollisionShape). There are two starting locations for the players and a light source. There is also a HUD control node (to show information about the player).

We are now going to make this a two-player experience (not really a game, yet).

First create a new scene. Make it a User Interface scene (Control) and change the name of the resulting node to Lobby. Add two buttons, Host and Join. Center them on the page, and update their labels to Host and Join (respectively).

Attach the following script to the Lobby node (save it as res://Lobby/Lobby.gd):
```
extends Control

func _ready():
	var _connect = get_tree().connect("network_peer_connected", self, "_player_connected")


func _on_Host_pressed():
	var net = NetworkedMultiplayerENet.new()
	net.create_server(13458, 4095)
	get_tree().set_network_peer(net)
	Global.which_player = 1
	print("hosting")

func _on_Join_pressed():
	var net = NetworkedMultiplayerENet.new()
	net.create_client("127.0.0.1", 13458)
	get_tree().set_network_peer(net)
	Global.which_player = 2

func _player_connected(id):
	Global.player2id = id
	var game = preload("res://Game.tscn").instance()
	get_tree().get_root().add_child(game)
	hide()
```

Then, attach signals to Host and Join and connect them to the preexisting functions in the Lobby script.

Save the scene as res://Lobby/Lobby.tscn, and then, in the Project menu, Project Settings->Application->Run, set the main scene to res://Lobby/Lobby.tscn

Next, edit res://Game.gd so that a second player is added:
```
extends Spatial

onready var player1pos = $Player1Pos
onready var player2pos = $Player2Pos

func _ready():
	var player1 = preload("res://Player/Player.tscn").instance()
	player1.set_name(str(get_tree().get_network_unique_id()))
	player1.set_network_master(get_tree().get_network_unique_id())
	player1.global_transform = player1pos.global_transform
	add_child(player1)
	
	var player2 = preload("res://Player/Player.tscn").instance()
	player2.set_name(str(Global.player2id))
	player2.set_network_master(Global.player2id)
	player2.global_transform = player2pos.global_transform
	add_child(player2)
```

Finally, we need to edit res://Player/Player.gd so that it understands remote commands. First add this function:
```
remote func _set_position(pos):
	global_transform.origin = pos
```

Then, edit the _ready() function to set up the right camera and color the players:
```
func _ready():
	if is_network_master():
		camera.current = true
	if Global.which_player == 1:
		$MeshInstance.get_surface_material(0).albedo_color = Color8(34,139,230)
	else:
		$MeshInstance.get_surface_material(0).albedo_color = Color8(250,82,82)
```

Finally, in _physics_process, replace the `velocity = move_and_slide(velocity, Vector3.UP)` line with the following:
```
	if velocity != Vector3.ZERO:
		if is_network_master():
			velocity = move_and_slide(velocity, Vector3.UP)
		rpc_unreliable("_set_position", global_transform.origin)
```

Test your project. You will need to bring up two instances of the same project in Godot and run both of them. In one window, select "Host". In the other, select "Join". You should be able to move between the two windows and see the two players updated as they move around.

Quit Godot. In GitHub desktop, add a summary message, commit your changes and push them back to GitHub. If you return to and refresh your GitHub repository page, you should now see your updated files with the time when they were changed.

Now edit the README.md file. When you have finished editing, commit your changes, and then turn in the URL of the main repository page (https://github.com/[username]/Exercise-05d-Networked-Game) on Canvas.

The final state of the file should be as follows (replacing the "Created by" information with your name):
```
# Exercise-05d-Networked-Game
Exercise for MSCH-C220, 4 November 2021

A simple networked game

To play, load two copies of this exercise in Godot. Run one and press the Host Game button. Then load the second copy and press the Join Game button. The position of the players will be relayed over the network (over localhost) from one copy to the other. Each player can be controlled (using WASD) depending on which window is selected.

## Implementation
Built using Godot 3.3.3

## References
[3D Multiplayer for Beginners](https://www.youtube.com/watch?v=K0luHLZxjBA)

## Future Development
None

## Created by 
Jason Francis
```
