import 'dart:io';

import 'environment_provider.dart';

/// Resolves the path to the system 'xclip' binary.
///
/// Resolution order:
/// 1. Environment override via 'QUILL_NATIVE_BRIDGE_XCLIP_PATH'
/// 2. 'which xclip'
/// 3. Common installation locations
///
/// Throws [StateError] if not found.
Future<String> resolveXclipBinaryPath() async {
  final environment = EnvironmentProvider.instance.environment;

  final overridePath = environment['QUILL_NATIVE_BRIDGE_XCLIP_PATH'];
  if (overridePath != null && overridePath.trim().isNotEmpty) {
    final overrideFile = File(overridePath);
    if (await overrideFile.exists()) {
      return overrideFile.path;
    }
  }

  try {
    final whichResult = await Process.run('which', ['xclip']);
    final stdoutString = whichResult.stdout?.toString().trim() ?? '';
    if (whichResult.exitCode == 0 && stdoutString.isNotEmpty) {
      return stdoutString;
    }
  } catch (_) {
    // Ignore and try fallback locations
  }

  for (final candidate in const ['/usr/bin/xclip', '/usr/local/bin/xclip']) {
    final candidateFile = File(candidate);
    if (await candidateFile.exists()) {
      return candidateFile.path;
    }
  }

  throw StateError(
    "xclip not found. Please install 'xclip' (e.g., 'sudo apt-get install xclip') or set QUILL_NATIVE_BRIDGE_XCLIP_PATH to its full path.",
  );
}


