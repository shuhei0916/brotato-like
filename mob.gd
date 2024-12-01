"""
queue_freeするタイミング（dieアニメーションを再生した後？）
"""

extends CharacterBody2D


@export var speed = 300.0
const JUMP_VELOCITY = -400.0

@export var max_health = 2
var health = max_health

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
#	print("mob spawnded!!")
	# mobがスポーンしたときにアニメーションを再生し、その完了を待つようにしたい
	$AnimationPlayer.play("spwan")
	await $AnimationPlayer.animation_finished

func _physics_process(delta):
	var direction = Vector2.ZERO
	var player_pos = $"../Player".position
	
	# プレイヤーが死んでいるなら遠ざかる
	if $"../Player".health <= 0:
		speed = 200
		direction = position - player_pos
	# プレイヤーが生きてる場合
	else:
		direction = player_pos - position
		speed = 220
	
	if direction != Vector2.ZERO:
		direction = direction.normalized()
		
	velocity = direction * speed

	
	move_and_slide()
	
	$Sprite2D.flip_h = direction.x < 0
	
# mobに弾が当たった時の処理
func hit():
	health -= 1
	if health <= 0:
		# 衝突を無効にする
		$CollisionShape2D.set_deferred("disabled", true)
		$AnimationPlayer.play("die")
		# 強制的にアニメーションの再生を待つ（改良の余地あり）
#		await get_tree().create_timer(0.5).timeout
		await $AnimationPlayer.animation_finished
		queue_free()
	else:
		$AnimationPlayer.play("hit")
