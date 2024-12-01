"""
ヘルスバー
"""

extends CharacterBody2D

#var Bullet = preload("res://bullet.tscn")
@export var Bullet: PackedScene

signal died

@export var speed = 300.0
@export var maxhealth = 10
var health
var is_invincible = false

#弾関連
var radius = 50
# 一度に発射される弾の数　
@export var num_bullets = 8
@export var bullet_speed  = 500

func _ready():
	hide()

func get_input():
	var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = input_dir * speed
	# 左右反転（この条件式はちょいムズい）
	if velocity.x != 0:
		$Sprite2D.flip_h = velocity.x < 0

# 角度をラジアンに変換するヘルパー関数
func deg2rad(deg):
	return deg * PI / 180	

func shoot():
	var angle = 0
	
	for i in range(num_bullets):
		var bullet = Bullet.instantiate()
		
		# Bullet.tscnにstart関数があるか確認して呼び出す
		if bullet.has_method("start"):
			bullet.start(global_position, deg2rad(angle))
		
		# 弾をシーンに追加
		get_parent().add_child(bullet)
		
		# 次の弾の角度を設定
		angle += 360 / num_bullets
	

func _physics_process(delta):
	get_input()
#	print(is_invincible)
	# move_and_slide()は計算にタイムステップを自動的に含めるため、速度ベクトルにはdeltaを描けないこと。
	move_and_slide()
	

	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		if not is_invincible:
			# ココ長いから関数化する？？
			$AnimationPlayer.play("hit")
#			await $AnimationPlayer.animation_finished
			health -= 1
			print(health, " / ", maxhealth)
			is_invincible = true
			$InvincibleTimer.start()
			if health <= 0:
				print("player died!")
				died.emit()
				$CollisionShape2D.set_deferred("disabled", true)


# 対象と重なったとき
#func _on_area_2d_body_entered(_body):
#	modulate = Color(1, 0.5, 0.5)
#	print("hit!")
	
func start(pos):
	health = maxhealth
	position = pos
	show()
	$CollisionShape2D.disabled = false
#	$ShootTimer.start()
	

func _on_shoot_timer_timeout():
	pass
#	shoot()
	

func _on_invincible_timer_timeout():
	is_invincible = false
	$InvincibleTimer.start()
