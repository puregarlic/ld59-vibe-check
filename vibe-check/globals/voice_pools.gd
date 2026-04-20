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

const PRE_SLAP: Array[AudioStream] = [
	preload("res://sfx/voice/11 Pre-Slap Vibe Check_ps1_11k_lpf14k_8b.wav"),
	preload("res://sfx/voice/12 Pre-Slap Vibe Check_ps1_11k_lpf14k_8b.wav"),
	preload("res://sfx/voice/13 Pre-Slap Vibe Check_ps1_11k_lpf14k_8b.wav"),
	preload("res://sfx/voice/14 Pre-Slap Vibe Check_ps1_11k_lpf14k_8b.wav"),
	preload("res://sfx/voice/15 Pre-Slap Vibe Check_ps1_11k_lpf14k_8b.wav"),
	preload("res://sfx/voice/16 Pre-Slap Vibe Check_ps1_11k_lpf14k_8b.wav"),
]


func random_pick(pool: Array) -> AudioStream:
	return pool[randi() % pool.size()]
