extends CharacterBody2D
class_name Slime

var _is_dead: bool = false
var _player_ref = null

@export_category("Objects")
@export var _attack_timer: Timer = null
@export var _texture: Sprite2D = null
@export var _animation: AnimationPlayer = null


func _on_detection_area_body_entered(_body) -> void:
	if _body.is_in_group("character"):
		_player_ref = _body


func _on_detection_area_body_exited(_body) -> void:
	if _body.is_in_group("character"):
		_player_ref = null

func _physics_process(_delta: float) -> void:
	if _is_dead:
		return
	
	_animate()
	_attack()
	
func _attack() -> void:
	if _player_ref != null:
		var _direction: Vector2 = global_position.direction_to(_player_ref.global_position)
		var _distance: float = global_position.distance_to(_player_ref.global_position)
		
		if _distance < 30 and not _player_ref.is_dead:
			set_physics_process(false)
			_attack_timer.start()
			_animation.play("attack")
		
		velocity = _direction.normalized() * 40
		move_and_slide()

func _animate() -> void:
	if velocity.x > 0:
		_texture.flip_h = false
	
	if velocity.x < 0:
		_texture.flip_h = true
	
	if velocity != Vector2.ZERO:
		_animation.play("walk")
		return
		
	_animation.play("idle")

func _on_attack_timer_timeout():
	var _distance: float = global_position.distance_to(_player_ref.global_position)
	
	if _distance < 30:
		_player_ref.die()
		_animate()
		velocity = Vector2.ZERO
		move_and_slide()
		return
	
	set_physics_process(true)
	return
	
func update_health() -> void:
	_is_dead = true
	_animation.play("death")

func _on_animation_finished(_anim_name: String) -> void:
	if _anim_name == "death":
		queue_free()
