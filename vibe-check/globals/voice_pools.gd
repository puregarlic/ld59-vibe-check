extends Node

const FIND_THEM: AudioStream = preload("res://sfx/voice/01 Find Them Vibe Check_ps1_11k_lpf14k_8b.wav")
const SUCCESS: AudioStream = preload("res://sfx/voice/02 Success Vibe Check_ps1_11k_lpf14k_8b.wav")
const FAILURE: AudioStream = preload("res://sfx/voice/03 Failure Vibe Check_ps1_11k_lpf14k_8b.wav")
const SLAP_IMPACT: AudioStream = preload("res://sfx/voice/10 Slap Vibe Check_ps1_11k_lpf14k_8b.wav")

const FALLING: Array[AudioStream] = [
	preload("res://sfx/voice/04 Falling Vibe Check_ps1_11k_lpf14k_8b.wav"),
	preload("res://sfx/voice/05 Falling Vibe Check_ps1_11k_lpf14k_8b.wav"),
]

const FALLING_DEATH: Array[AudioStream] = [
	preload("res://sfx/voice/06 Falling Death Vibe Check_ps1_11k_lpf14k_8b.wav"),
	preload("res://sfx/voice/07 Falling Death Vibe Check_ps1_11k_lpf14k_8b.wav"),
]

const HUH: Array[AudioStream] = [
	preload("res://sfx/voice/08 Huh Vibe Check_ps1_11k_lpf14k_8b.wav"),
	preload("res://sfx/voice/09 Huh Vibe Check_ps1_11k_lpf14k_8b.wav"),
	preload("res://sfx/voice/huh2_ps1_11k_lpf14k_8b.wav"),
]

const JUMPING: Array[AudioStream] = [
	preload("res://sfx/voice/19 Jump Vibe Check JumpingPassFail_ps1_11k_lpf14k_8b.wav"),
	preload("res://sfx/voice/20 Jump Vibe Check JumpingPassFail_ps1_11k_lpf14k_8b.wav"),
	preload("res://sfx/voice/21 Jump Vibe Check JumpingPassFail_ps1_11k_lpf14k_8b.wav"),
	preload("res://sfx/voice/22 Jump Vibe Check JumpingPassFail_ps1_11k_lpf14k_8b.wav"),
	preload("res://sfx/voice/23 Jump Vibe Check JumpingPassFail_ps1_11k_lpf14k_8b.wav"),
]

const LANDING: Array[AudioStream] = [
	preload("res://sfx/voice/24 Land Vibe Check JumpingPassFail_ps1_11k_lpf14k_8b.wav"),
	preload("res://sfx/voice/25 Land Vibe Check JumpingPassFail_ps1_11k_lpf14k_8b.wav"),
	preload("res://sfx/voice/26 Land Vibe Check JumpingPassFail_ps1_11k_lpf14k_8b.wav"),
	preload("res://sfx/voice/27 Land Vibe Check JumpingPassFail_ps1_11k_lpf14k_8b.wav"),
	preload("res://sfx/voice/28 Land Vibe Check JumpingPassFail_ps1_11k_lpf14k_8b.wav"),
]

const PRE_SLAP: Array[AudioStream] = [
	preload("res://sfx/voice/11 Pre-Slap Vibe Check_ps1_11k_lpf14k_8b.wav"),
	preload("res://sfx/voice/12 Pre-Slap Vibe Check_ps1_11k_lpf14k_8b.wav"),
	preload("res://sfx/voice/13 Pre-Slap Vibe Check_ps1_11k_lpf14k_8b.wav"),
	preload("res://sfx/voice/14 Pre-Slap Vibe Check_ps1_11k_lpf14k_8b.wav"),
	preload("res://sfx/voice/15 Pre-Slap Vibe Check_ps1_11k_lpf14k_8b.wav"),
	preload("res://sfx/voice/16 Pre-Slap Vibe Check_ps1_11k_lpf14k_8b.wav"),
]

const PASS_VIBE: Array[AudioStream] = [
	preload("res://sfx/voice/29 Pass Vibe Check JumpingPassFail_ps1_11k_lpf14k_8b.wav"),
	preload("res://sfx/voice/30 Pass Vibe Check JumpingPassFail_ps1_11k_lpf14k_8b.wav"),
	preload("res://sfx/voice/31 Pass Vibe Check JumpingPassFail_ps1_11k_lpf14k_8b.wav"),
	preload("res://sfx/voice/32 Pass Vibe Check JumpingPassFail_ps1_11k_lpf14k_8b.wav"),
	preload("res://sfx/voice/33 Pass Vibe Check JumpingPassFail_ps1_11k_lpf14k_8b.wav"),
]

const FAIL_VIBE: Array[AudioStream] = [
	preload("res://sfx/voice/34 Fail Vibe Check JumpingPassFail_ps1_11k_lpf14k_8b.wav"),
	preload("res://sfx/voice/35 Fail Vibe Check JumpingPassFail_ps1_11k_lpf14k_8b.wav"),
	preload("res://sfx/voice/36 Fail Vibe Check JumpingPassFail_ps1_11k_lpf14k_8b.wav"),
	preload("res://sfx/voice/37 Fail Vibe Check JumpingPassFail_ps1_11k_lpf14k_8b.wav"),
	preload("res://sfx/voice/38 Fail Vibe Check JumpingPassFail_ps1_11k_lpf14k_8b.wav"),
]


func random_pick(pool: Array) -> AudioStream:
	return pool[randi() % pool.size()]
