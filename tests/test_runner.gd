extends SceneTree
## HUNGERHALL — test runner (G6 §3.4). Runs all test_*.gd suites via assert.
## Invoke: godot --headless --script tests/test_runner.gd
## Exit 0 = all pass, exit 1 = failures.

var _suites: Array = []
var _pass_count: int = 0
var _fail_count: int = 0
var _failures: Array = []

func _init() -> void:
	_register_suites()
	_run_all()
	_print_results()
	_exit()

func _register_suites() -> void:
	# why: DYNAMIC discovery — every test_*.gd suite under res://tests/ is
	# registered (round 6: 14 suite FILES existed on disk but this list only
	# registered the original 12, so the "PASS" was a false green over the
	# suites pinning that round's fixes). A suite that fails to load/parse is
	# a loud FAIL here, never a silent skip; a new suite file can never again
	# ship dark.
	var files: Array = _list_suite_files()
	files.sort()
	for fname: String in files:
		var path: String = "res://tests/" + fname
		var script: Variant = load(path)
		if script == null or not (script is GDScript):
			_fail_count += 1
			_failures.append("test_runner::_register_suites: failed to load " + path)
			continue
		_suites.append(script.new())

func _list_suite_files() -> Array:
	var found: Array = []
	var dir: DirAccess = DirAccess.open("res://tests")
	if dir == null:
		_fail_count += 1
		_failures.append("test_runner::_register_suites: cannot open res://tests")
		return found
	dir.list_dir_begin()
	var fname: String = dir.get_next()
	while fname != "":
		if not dir.current_is_dir() and fname.begins_with("test_") \
				and fname.ends_with(".gd") and fname != "test_runner.gd":
			found.append(fname)
		fname = dir.get_next()
	dir.list_dir_end()
	return found

func _run_all() -> void:
	for suite in _suites:
		var suite_name: String = suite.get_class()
		var methods: Array = suite.get_method_list()
		for m in methods:
			var mname: String = m.name
			if mname.begins_with("test_"):
				_run_test(suite, suite_name, mname)

func _run_test(suite: Object, suite_name: String, test_name: String) -> void:
	var ok: bool = true
	var err_msg: String = ""
	# why: call the test method; catch assertion failures via the return value
	var result: Variant = null
	if suite.has_method("setup"):
		suite.call("setup")
	# why: use a guard via try-catch emulation — GDScript doesn't have try-catch
	# so tests use assert() which aborts on failure; we use a custom assert pattern
	# where tests return a Dictionary with {ok, msg}
	if suite.has_method(test_name):
		result = suite.call(test_name)
		if result is Dictionary:
			ok = result.get("ok", false)
			err_msg = result.get("msg", "")
		elif result is bool:
			ok = result
		# why: void return = implicit pass (asserts would have aborted the process)
	if suite.has_method("teardown"):
		suite.call("teardown")
	if ok:
		_pass_count += 1
	else:
		_fail_count += 1
		_failures.append(suite_name + "::" + test_name + ": " + err_msg)

func _print_results() -> void:
	print("\n=== HUNGERHALL TEST RESULTS ===")
	print("PASS: %d  FAIL: %d  TOTAL: %d" % [_pass_count, _fail_count, _pass_count + _fail_count])
	if not _failures.is_empty():
		print("\nFAILURES:")
		for f in _failures:
			print("  - " + f)
	print("===============================\n")

func _exit() -> void:
	quit(_fail_count > 0)
