"""
GAME OVER時の処理
	敵が全員ハケるまで待つ？（await?）
	
曲の分割の方法について調べる（ピアノ、ドラム、ベース、ギター、歌？）
	ビート検出？
	
キャラクターの顔を歌に合わせて動かしたい
	母音（a e i o u）のアニメーションを用意する？
	
プレイヤーを追従するカメラの設定

hitのアニメーションの完了を待っていない？

mobのtick_moveアニメーションもやる
"""

extends Node

@export var mob_scene: PackedScene
@export var is_mute = true
@export var peaceful = true
var score

# BGM関連
@export var BPM = 116
@export var BARS = 4 # 何拍子か
var playing = false
const COMPENSATE_FRAMES = 2
const COMPENSATE_HZ = 60.0

enum SyncSource {
	SYSTEM_CLOCK,
	SOUND_CLOCK,
}

var sync_source = SyncSource.SYSTEM_CLOCK

# Used by system clock.
var time_begin
var time_delay

var old_beat = 0


func strsec(secs):
	var s = str(secs)
	if (secs < 10):
		s = "0" + s
	return s

# Called when the node enters the scene tree for the first time.
func _ready():
#	new_game()
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not playing or not $Music.playing:
		return

	var time = 0.0
	if sync_source == SyncSource.SYSTEM_CLOCK:
		# Obtain from ticks.
		time = (Time.get_ticks_usec() - time_begin) / 1000000.0
		# Compensate.
		time -= time_delay
#		print("time:", time)
	# 今回はSOUND_CLOCKは使っていないので、このelse分は実行されない
	elif sync_source == SyncSource.SOUND_CLOCK:
		time = $Music.get_playback_position() + AudioServer.get_time_since_last_mix() - AudioServer.get_output_latency() + (1 / COMPENSATE_HZ) * COMPENSATE_FRAMES
	
	var beat = int(time * BPM / 60.0)
	# beatに変更があった時のみpirnt
	if old_beat != beat: 
#		print("beat: ", beat)
		tick()
	old_beat = beat
	
	var seconds = int(time)
	var seconds_total = int($Music.stream.get_length())
	@warning_ignore("integer_division")
	$Label.text = str("BEAT: ", beat % BARS + 1, "/", BARS, " TIME: ", seconds / 60, ":", strsec(seconds % 60), " / ", seconds_total / 60, ":", strsec(seconds_total % 60))

# tickが起こった時のみ実行する関数
func tick():
	if $Player.health <= 0: 
		return
		
	$TickTimer/Tick.play()
	$Player.shoot()
	$Player/AnimationPlayer.play("tick_move")
#	mob_scene.
	
	
func game_over():
	pass
	

func new_game():
	score = 0
	var start_pos = Vector2(1152/2, 324)
	$HUD.show_message("Get Ready")
	$Player.start(start_pos)
	$StartTimer.start()


func _on_mob_timer_timeout():
	var mob = mob_scene.instantiate()
	
	var mob_spawn_location = get_node("MobPath/MobSpawnLocation")
	mob_spawn_location.progress_ratio = randf()
	
	mob.position = mob_spawn_location.position
	
	add_child(mob)


func _on_start_timer_timeout():
	if not peaceful:
		$MobTimer.start()
#	$TickTimer.start(60.0 / bpm)
#	if not is_mute:
#		$Music.play()
		
	# 音楽の処理(あんまり分かってないですよォ！)
	sync_source = SyncSource.SYSTEM_CLOCK
	time_begin = Time.get_ticks_usec()
	time_delay = AudioServer.get_time_to_next_mix() + AudioServer.get_output_latency()
	playing = true
	$Music.play()


var counter = 0
var note = 3
func _on_tick_timer_timeout():
#	print("counter: ", counter)
	if counter == 0:
		$TickTimer/TickSound1.play()
	else:
		$TickTimer/TickSound2.play()
	if counter == note:
		counter = 0
	else:
		counter += 1


func _on_player_died():
	$HUD.show_game_over()
#	print("GAME OVER!!")
	$MobTimer.stop()
	$Music.stop()
	
