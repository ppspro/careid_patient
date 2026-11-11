import 'dart:io';

/// CareID Patient App — E2E Test Suite Runner
/// Executable via:
///   `dart test/e2e/runner.dart`
///   or `flutter test test/e2e/`
void main([List<String>? args]) async {
  stdout.writeln('================================================================');
  stdout.writeln('CAREID PATIENT APP — 4-TIER E2E TEST RUNNER');
  stdout.writeln('Architecture: Requirement-Driven Opaque-Box Test Suite');
  stdout.writeln('Endpoints: Postman CareID-Staging Catalog (20+ Folders)');
  stdout.writeln('Tiers: Tier 1 (Features), Tier 2 (Boundaries), Tier 3 (Cross-Feature), Tier 4 (Workflows)');
  stdout.writeln('================================================================\n');

  final isWindows = Platform.isWindows;
  final executable = isWindows ? 'flutter.bat' : 'flutter';

  final stopwatch = Stopwatch()..start();

  stdout.writeln('Launching E2E test suites via Flutter Test Engine...\n');

  final process = await Process.start(
    executable,
    ['test', 'test/e2e/'],
    runInShell: true,
  );

  final stdoutFuture = stdout.addStream(process.stdout);
  final stderrFuture = stderr.addStream(process.stderr);

  await Future.wait([stdoutFuture, stderrFuture]);
  final code = await process.exitCode;
  stopwatch.stop();

  stdout.writeln('\n================================================================');
  if (code == 0) {
    stdout.writeln('RESULT: SUCCESS — ALL E2E TIERS PASSED IN ${stopwatch.elapsed.inSeconds}s');
  } else {
    stdout.writeln('RESULT: FAILURE — EXIT CODE $code IN ${stopwatch.elapsed.inSeconds}s');
  }
  stdout.writeln('================================================================\n');

  exitCode = code;
}
