import 'dart:convert';
import 'dart:io';

void main(List<String> arguments) {
  if (arguments.any((argument) => argument != '--check')) {
    stderr.writeln('Usage: dart run tool/apply_identity.dart [--check]');
    exitCode = 64;
    return;
  }

  final checkOnly = arguments.contains('--check');
  final root = Directory.current;
  final identity = _Identity.parse(
    File('${root.path}/app_identity.yaml').readAsStringSync(),
  );
  final targets = _targets(identity);
  final driftedPaths = <String>[];

  for (final target in targets) {
    final file = File('${root.path}/${target.path}');
    final current = file.existsSync() ? file.readAsStringSync() : '';
    final expected = target.rewrite(current);
    if (current == expected) {
      continue;
    }

    driftedPaths.add(target.path);
    if (!checkOnly) {
      file.parent.createSync(recursive: true);
      file.writeAsStringSync(expected);
    }
  }

  if (checkOnly && driftedPaths.isNotEmpty) {
    stderr.writeln('App identity drift detected:');
    for (final path in driftedPaths) {
      stderr.writeln('- $path');
    }
    exitCode = 1;
  }
}

List<_Target> _targets(_Identity identity) {
  final appName = identity.appName;
  final appId = identity.appId;
  final artifactName = identity.artifactName;
  final cppAppName = _escapeCpp(appName);

  return [
    _Target('android/app/build.gradle.kts', (contents) {
      contents = _replaceRequired(
        contents,
        RegExp(r'namespace = "[^"]*"'),
        'namespace = "$appId"',
        'android/app/build.gradle.kts',
      );
      return _replaceRequired(
        contents,
        RegExp(r'applicationId = "[^"]*"'),
        'applicationId = "$appId"',
        'android/app/build.gradle.kts',
      );
    }),
    _Target('android/app/src/main/AndroidManifest.xml', (contents) {
      return _replaceRequired(
        contents,
        RegExp(r'android:label="[^"]*"'),
        'android:label="${_escapeXml(appName)}"',
        'android/app/src/main/AndroidManifest.xml',
      );
    }),
    _Target(
      'android/app/src/main/kotlin/com/example/stencil/MainActivity.kt',
      (contents) => _replaceRequired(
        contents,
        RegExp(r'^package .+$', multiLine: true),
        'package $appId',
        'android/app/src/main/kotlin/com/example/stencil/MainActivity.kt',
      ),
    ),
    _Target('ios/Runner.xcodeproj/project.pbxproj', (contents) {
      final pattern = RegExp(r'PRODUCT_BUNDLE_IDENTIFIER = ([^;]+);');
      if (!pattern.hasMatch(contents)) {
        throw StateError('Expected bundle identifiers in ios project file.');
      }
      return contents.replaceAllMapped(pattern, (match) {
        final suffix = match.group(1)!.endsWith('.RunnerTests')
            ? '.RunnerTests'
            : '';
        return 'PRODUCT_BUNDLE_IDENTIFIER = $appId$suffix;';
      });
    }),
    _Target('ios/Runner/Info.plist', (contents) {
      contents = _replacePlistString(
        contents,
        'CFBundleDisplayName',
        appName,
        'ios/Runner/Info.plist',
      );
      return _replacePlistString(
        contents,
        'CFBundleName',
        artifactName,
        'ios/Runner/Info.plist',
      );
    }),
    _Target('macos/Runner/Configs/AppInfo.xcconfig', (contents) {
      contents = _replaceRequired(
        contents,
        RegExp(r'^PRODUCT_NAME = .+$', multiLine: true),
        'PRODUCT_NAME = $appName',
        'macos/Runner/Configs/AppInfo.xcconfig',
      );
      return _replaceRequired(
        contents,
        RegExp(r'^PRODUCT_BUNDLE_IDENTIFIER = .+$', multiLine: true),
        'PRODUCT_BUNDLE_IDENTIFIER = $appId',
        'macos/Runner/Configs/AppInfo.xcconfig',
      );
    }),
    _Target('macos/Runner.xcodeproj/project.pbxproj', (contents) {
      final pattern = RegExp(
        r'PRODUCT_BUNDLE_IDENTIFIER = [^;]+\.RunnerTests;',
      );
      if (!pattern.hasMatch(contents)) {
        throw StateError(
          'Expected test bundle identifiers in macOS project file.',
        );
      }
      return contents.replaceAll(
        pattern,
        'PRODUCT_BUNDLE_IDENTIFIER = $appId.RunnerTests;',
      );
    }),
    _Target('windows/CMakeLists.txt', (contents) {
      contents = _replaceRequired(
        contents,
        RegExp(r'^project\([^ ]+ LANGUAGES CXX\)$', multiLine: true),
        'project($artifactName LANGUAGES CXX)',
        'windows/CMakeLists.txt',
      );
      return _replaceRequired(
        contents,
        RegExp(r'^set\(BINARY_NAME "[^"]*"\)$', multiLine: true),
        'set(BINARY_NAME "$artifactName")',
        'windows/CMakeLists.txt',
      );
    }),
    _Target(
      'windows/runner/main.cpp',
      (contents) => _replaceRequired(
        contents,
        RegExp(r'window\.Create\(L"[^"]*"'),
        'window.Create(L"$cppAppName"',
        'windows/runner/main.cpp',
      ),
    ),
    _Target('windows/runner/Runner.rc', (contents) {
      contents = _replaceWindowsValue(contents, 'FileDescription', appName);
      contents = _replaceWindowsValue(contents, 'InternalName', artifactName);
      contents = _replaceWindowsValue(
        contents,
        'OriginalFilename',
        '$artifactName.exe',
      );
      return _replaceWindowsValue(contents, 'ProductName', appName);
    }),
    _Target('linux/CMakeLists.txt', (contents) {
      contents = _replaceRequired(
        contents,
        RegExp(r'^set\(BINARY_NAME "[^"]*"\)$', multiLine: true),
        'set(BINARY_NAME "$artifactName")',
        'linux/CMakeLists.txt',
      );
      return _replaceRequired(
        contents,
        RegExp(r'^set\(APPLICATION_ID "[^"]*"\)$', multiLine: true),
        'set(APPLICATION_ID "$appId")',
        'linux/CMakeLists.txt',
      );
    }),
    _Target('linux/runner/my_application.cc', (contents) {
      contents = _replaceRequired(
        contents,
        RegExp(r'gtk_header_bar_set_title\(header_bar, "[^"]*"\)'),
        'gtk_header_bar_set_title(header_bar, "$cppAppName")',
        'linux/runner/my_application.cc',
      );
      return _replaceRequired(
        contents,
        RegExp(r'gtk_window_set_title\(window, "[^"]*"\)'),
        'gtk_window_set_title(window, "$cppAppName")',
        'linux/runner/my_application.cc',
      );
    }),
    _Target('web/index.html', (contents) {
      contents = _replaceRequired(
        contents,
        RegExp(r'<meta name="apple-mobile-web-app-title" content="[^"]*">'),
        '<meta name="apple-mobile-web-app-title" content="${_escapeXml(appName)}">',
        'web/index.html',
      );
      return _replaceRequired(
        contents,
        RegExp(r'<title>[^<]*</title>'),
        '<title>${_escapeXml(appName)}</title>',
        'web/index.html',
      );
    }),
    _Target('web/manifest.json', (contents) {
      final manifest = jsonDecode(contents) as Map<String, dynamic>;
      manifest['name'] = appName;
      manifest['short_name'] = appName;
      return '${const JsonEncoder.withIndent('    ').convert(manifest)}\n';
    }),
    _Target('pubspec.yaml', (contents) {
      contents = _replaceYamlValue(contents, 'display_name', appName);
      contents = _replaceYamlValue(
        contents,
        'identity_name',
        identity.msstoreIdentityName,
      );
      contents = _replaceYamlValue(
        contents,
        'publisher',
        identity.msstorePublisher,
      );
      return _replaceYamlValue(
        contents,
        'publisher_display_name',
        identity.msstorePublisherDisplayName,
      );
    }),
    _Target(
      'lib/core/app_identity.dart',
      (_) => _renderDartConstants(identity),
    ),
  ];
}

String _replaceRequired(
  String contents,
  RegExp pattern,
  String replacement,
  String path,
) {
  if (!pattern.hasMatch(contents)) {
    throw StateError('Expected identity field in $path.');
  }
  return contents.replaceAll(pattern, replacement);
}

String _replacePlistString(
  String contents,
  String key,
  String value,
  String path,
) {
  return _replaceRequired(
    contents,
    RegExp('<key>$key</key>\\s*<string>[^<]*</string>'),
    '<key>$key</key>\n\t<string>${_escapeXml(value)}</string>',
    path,
  );
}

String _replaceWindowsValue(String contents, String key, String value) {
  return _replaceRequired(
    contents,
    RegExp('VALUE "$key", "[^"]*"'),
    'VALUE "$key", "${_escapeCpp(value)}"',
    'windows/runner/Runner.rc',
  );
}

String _replaceYamlValue(String contents, String key, String value) {
  return _replaceRequired(
    contents,
    RegExp('^  $key:.*\$', multiLine: true),
    '  $key: $value',
    'pubspec.yaml',
  );
}

String _renderDartConstants(_Identity identity) {
  return '''// Generated by tool/apply_identity.dart. Do not edit by hand.
// dart format off
abstract final class AppIdentity {
  static const appName = '${_escapeDart(identity.appName)}';
  static const appId = '${_escapeDart(identity.appId)}';
  static const artifactName = '${_escapeDart(identity.artifactName)}';
  static const msstoreIdentityName = '${_escapeDart(identity.msstoreIdentityName)}';
  static const msstorePublisher = '${_escapeDart(identity.msstorePublisher)}';
  static const msstorePublisherDisplayName = '${_escapeDart(identity.msstorePublisherDisplayName)}';
}
// dart format on
''';
}

String _escapeXml(String value) => value
    .replaceAll('&', '&amp;')
    .replaceAll('"', '&quot;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;');

String _escapeCpp(String value) =>
    value.replaceAll(r'\', r'\\').replaceAll('"', r'\"');

String _escapeDart(String value) => value
    .replaceAll(r'\', r'\\')
    .replaceAll("'", r"\'")
    .replaceAll(r'$', r'\$');

final class _Target {
  const _Target(this.path, this.rewrite);

  final String path;
  final String Function(String contents) rewrite;
}

final class _Identity {
  const _Identity({
    required this.appName,
    required this.appId,
    required this.artifactName,
    required this.msstoreIdentityName,
    required this.msstorePublisher,
    required this.msstorePublisherDisplayName,
  });

  factory _Identity.parse(String yaml) {
    final values = <String, String>{};
    for (final line in const LineSplitter().convert(yaml)) {
      final match = RegExp(r'^([a-z_]+):\s*(.+)$').firstMatch(line);
      if (match != null) {
        values[match.group(1)!] = _unquote(match.group(2)!.trim());
      }
    }

    String requiredValue(String key) {
      final value = values[key];
      if (value == null || value.isEmpty) {
        throw FormatException('Missing app identity value: $key');
      }
      return value;
    }

    return _Identity(
      appName: requiredValue('app_name'),
      appId: requiredValue('app_id'),
      artifactName: requiredValue('artifact_name'),
      msstoreIdentityName: requiredValue('msstore_identity_name'),
      msstorePublisher: requiredValue('msstore_publisher'),
      msstorePublisherDisplayName: requiredValue(
        'msstore_publisher_display_name',
      ),
    );
  }

  final String appName;
  final String appId;
  final String artifactName;
  final String msstoreIdentityName;
  final String msstorePublisher;
  final String msstorePublisherDisplayName;
}

String _unquote(String value) {
  if (value.length >= 2 &&
      ((value.startsWith("'") && value.endsWith("'")) ||
          (value.startsWith('"') && value.endsWith('"')))) {
    return value.substring(1, value.length - 1);
  }
  return value;
}
