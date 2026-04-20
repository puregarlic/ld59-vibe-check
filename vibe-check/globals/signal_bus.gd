extends Node

@warning_ignore("unused_signal")
signal start_game

@warning_ignore("unused_signal")
signal start_menu

@warning_ignore("unused_signal")
signal pause

@warning_ignore("unused_signal")
signal unpause

@warning_ignore("unused_signal")
signal scan_progress(progress: float)

@warning_ignore("unused_signal")
signal scan_success(progress: float)

@warning_ignore("unused_signal")
signal baddie_scanned(progress: Slapper)

@warning_ignore("unused_signal")
signal baddie_killed(progress: Slapper)

@warning_ignore("unused_signal")
signal failed

@warning_ignore("unused_signal")
signal baddies_spawned
