extends GutTest
## ScreenFade: every fade releases exactly its own waiters, a replaced fade never hangs.

var fade: ScreenFadeService


func before_each() -> void:
	fade = ScreenFadeService.new()
	add_child_autofree(fade)


func test_an_instant_fade_covers_at_once_and_still_signals() -> void:
	var done := [false]
	var wait := func() -> void:
		await fade.fade_out(0.0)
		done[0] = true
	wait.call()
	assert_true(fade.is_covered(), "covered right away")
	assert_false(done[0], "the signal comes after the caller waits")
	await wait_physics_frames(2)
	assert_true(done[0])


func test_an_instant_fade_does_not_release_the_next_one() -> void:
	fade.fade_out(0.0)
	var done := [false]
	var wait := func() -> void:
		await fade.fade_in(0.5)
		done[0] = true
	wait.call()
	await wait_physics_frames(3)
	assert_false(done[0], "the fade in is still running")
	assert_true(fade.is_fading())
	await wait_seconds(0.7)
	assert_true(done[0])
	assert_false(fade.is_covered())


func test_a_replaced_fade_lets_its_waiters_go() -> void:
	var first := [false]
	var wait := func() -> void:
		await fade.fade_out(5.0)
		first[0] = true
	wait.call()
	await wait_physics_frames(2)
	fade.fade_in(0.1)
	assert_true(first[0], "replaced, not hanging")
