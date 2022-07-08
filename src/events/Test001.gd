extends Event

func startCutscene(args: Array):
	args[0].movable = false
	Dialogue.startDialogue("LeaderJord", "So, how've you been doin'?")
	yield(Dialogue, "d_done")
	Dialogue.dialogue.hide()
	args[0].movable = true
