class_name NodeTimer
extends RefCounted
## One-shot waits owned by a node: `await NodeTimer.after(self, 1.5)`.
## Unlike get_tree().create_timer(), the timer is a child of `owner`, so when the owner is
## freed (scene change mid-sequence), the wait simply never ends instead of resuming a
## coroutine on a freed object.


static func after(owner: Node, seconds: float) -> Signal:
	var timer := Timer.new()
	timer.one_shot = true
	timer.wait_time = maxf(seconds, 0.001)
	owner.add_child(timer)
	timer.timeout.connect(timer.queue_free)
	timer.start()
	return timer.timeout
