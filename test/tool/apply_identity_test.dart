import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

const _rewrittenPaths = [
  'android/app/build.gradle.kts',
  'android/app/src/main/AndroidManifest.xml',
  'android/app/src/main/kotlin/com/example/stencil/MainActivity.kt',
  'ios/Runner.xcodeproj/project.pbxproj',
  'ios/Runner/Info.plist',
  'macos/Runner/Configs/AppInfo.xcconfig',
  'macos/Runner.xcodeproj/project.pbxproj',
  'windows/CMakeLists.txt',
  'windows/runner/main.cpp',
  'windows/runner/Runner.rc',
  'linux/CMakeLists.txt',
  'linux/runner/my_application.cc',
  'web/index.html',
  'web/manifest.json',
  'pubspec.yaml',
  'lib/core/app_identity.dart',
];

void main() {
  late Directory temporaryProject;

  setUp(() {
    temporaryProject = Directory.systemTemp.createTempSync(
      'stencil_identity_test.',
    );
    for (final path in [
      'app_identity.yaml',
      'tool/apply_identity.dart',
      ..._rewrittenPaths,
    ]) {
      final destination = File('${temporaryProject.path}/$path');
      destination.parent.createSync(recursive: true);
      File(path).copySync(destination.path);
    }
    File('${temporaryProject.path}/app_identity.yaml').writeAsStringSync('''
app_name: Paper Trail
app_id: com.acme.papertrail
artifact_name: paper_trail
msstore_identity_name: 12345Acme.PaperTrail
msstore_publisher: CN=11111111-2222-3333-4444-555555555555
msstore_publisher_display_name: Acme Limited
''');
  });

  tearDown(() {
    temporaryProject.deleteSync(recursive: true);
  });

  test('rewrites every platform and the generated constants', () async {
    final result = await _runIdentityCommand(temporaryProject);

    expect(result.exitCode, 0, reason: _output(result));
    expect(
      _read(temporaryProject, 'android/app/build.gradle.kts'),
      allOf(
        contains('namespace = "com.acme.papertrail"'),
        contains('applicationId = "com.acme.papertrail"'),
      ),
    );
    expect(
      _read(temporaryProject, 'android/app/src/main/AndroidManifest.xml'),
      contains('android:label="Paper Trail"'),
    );
    expect(
      _read(
        temporaryProject,
        'android/app/src/main/kotlin/com/example/stencil/MainActivity.kt',
      ),
      contains('package com.acme.papertrail'),
    );
    expect(
      _read(temporaryProject, 'ios/Runner.xcodeproj/project.pbxproj'),
      allOf(
        contains('PRODUCT_BUNDLE_IDENTIFIER = com.acme.papertrail;'),
        contains(
          'PRODUCT_BUNDLE_IDENTIFIER = com.acme.papertrail.RunnerTests;',
        ),
      ),
    );
    expect(
      _read(temporaryProject, 'ios/Runner/Info.plist'),
      allOf(
        contains('<string>Paper Trail</string>'),
        contains('<string>paper_trail</string>'),
      ),
    );
    expect(
      _read(temporaryProject, 'macos/Runner/Configs/AppInfo.xcconfig'),
      allOf(
        contains('PRODUCT_NAME = Paper Trail'),
        contains('PRODUCT_BUNDLE_IDENTIFIER = com.acme.papertrail'),
      ),
    );
    expect(
      _read(temporaryProject, 'macos/Runner.xcodeproj/project.pbxproj'),
      contains('PRODUCT_BUNDLE_IDENTIFIER = com.acme.papertrail.RunnerTests;'),
    );
    expect(
      _read(temporaryProject, 'windows/CMakeLists.txt'),
      allOf(
        contains('project(paper_trail LANGUAGES CXX)'),
        contains('set(BINARY_NAME "paper_trail")'),
      ),
    );
    expect(
      _read(temporaryProject, 'windows/runner/main.cpp'),
      contains('window.Create(L"Paper Trail"'),
    );
    expect(
      _read(temporaryProject, 'windows/runner/Runner.rc'),
      allOf(
        contains('VALUE "FileDescription", "Paper Trail"'),
        contains('VALUE "InternalName", "paper_trail"'),
        contains('VALUE "OriginalFilename", "paper_trail.exe"'),
        contains('VALUE "ProductName", "Paper Trail"'),
      ),
    );
    expect(
      _read(temporaryProject, 'linux/CMakeLists.txt'),
      allOf(
        contains('set(BINARY_NAME "paper_trail")'),
        contains('set(APPLICATION_ID "com.acme.papertrail")'),
      ),
    );
    expect(
      _read(temporaryProject, 'linux/runner/my_application.cc'),
      allOf(
        contains('gtk_header_bar_set_title(header_bar, "Paper Trail")'),
        contains('gtk_window_set_title(window, "Paper Trail")'),
      ),
    );
    expect(
      _read(temporaryProject, 'web/index.html'),
      allOf(
        contains('content="Paper Trail"'),
        contains('<title>Paper Trail</title>'),
      ),
    );
    final manifest = jsonDecode(
      _read(temporaryProject, 'web/manifest.json'),
    ) as Map<String, dynamic>;
    expect(manifest['name'], 'Paper Trail');
    expect(manifest['short_name'], 'Paper Trail');
    expect(
      _read(temporaryProject, 'pubspec.yaml'),
      allOf(
        contains('display_name: Paper Trail'),
        contains('identity_name: 12345Acme.PaperTrail'),
        contains('publisher: CN=11111111-2222-3333-4444-555555555555'),
        contains('publisher_display_name: Acme Limited'),
      ),
    );
    expect(
      _read(temporaryProject, 'lib/core/app_identity.dart'),
      allOf(
        contains("appName = 'Paper Trail'"),
        contains("appId = 'com.acme.papertrail'"),
        contains("artifactName = 'paper_trail'"),
        contains("msstoreIdentityName = '12345Acme.PaperTrail'"),
        contains(
          "msstorePublisher = 'CN=11111111-2222-3333-4444-555555555555'",
        ),
        contains("msstorePublisherDisplayName = 'Acme Limited'"),
      ),
    );
  });

  test('is idempotent', () async {
    final firstResult = await _runIdentityCommand(temporaryProject);
    expect(firstResult.exitCode, 0, reason: _output(firstResult));
    final afterFirstRun = _snapshot(temporaryProject);

    final secondResult = await _runIdentityCommand(temporaryProject);

    expect(secondResult.exitCode, 0, reason: _output(secondResult));
    expect(_snapshot(temporaryProject), afterFirstRun);
  });

  test('--check reports every drifted file without changing it', () async {
    final applyResult = await _runIdentityCommand(temporaryProject);
    expect(applyResult.exitCode, 0, reason: _output(applyResult));

    final webIndex = File('${temporaryProject.path}/web/index.html');
    final windowsMain = File(
      '${temporaryProject.path}/windows/runner/main.cpp',
    );
    webIndex.writeAsStringSync(
      webIndex.readAsStringSync().replaceFirst(
        '<title>Paper Trail</title>',
        '<title>Hand edit</title>',
      ),
    );
    windowsMain.writeAsStringSync(
      windowsMain.readAsStringSync().replaceFirst('Paper Trail', 'Hand edit'),
    );
    final beforeCheck = _snapshot(temporaryProject);

    final result = await _runIdentityCommand(temporaryProject, check: true);

    expect(result.exitCode, isNot(0));
    expect(_output(result), contains('web/index.html'));
    expect(_output(result), contains('windows/runner/main.cpp'));
    expect(_snapshot(temporaryProject), beforeCheck);
  });
}

Future<ProcessResult> _runIdentityCommand(
  Directory project, {
  bool check = false,
}) {
  final flutterRoot = Platform.environment['FLUTTER_ROOT'];
  final dart = flutterRoot == null
      ? 'dart'
      : '$flutterRoot/bin/cache/dart-sdk/bin/dart';
  return Process.run(dart, [
    '${project.path}/tool/apply_identity.dart',
    if (check) '--check',
  ], workingDirectory: project.path);
}

String _read(Directory project, String path) =>
    File('${project.path}/$path').readAsStringSync();

Map<String, String> _snapshot(Directory project) => {
  for (final path in _rewrittenPaths) path: _read(project, path),
};

String _output(ProcessResult result) => '${result.stdout}\n${result.stderr}';
