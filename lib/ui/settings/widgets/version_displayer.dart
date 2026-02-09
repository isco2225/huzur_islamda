import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class VersionDisplayer extends StatefulWidget {
  const VersionDisplayer({super.key});

  @override
  State<VersionDisplayer> createState() => _VersionDisplayerState();
}

class _VersionDisplayerState extends State<VersionDisplayer> {
  PackageInfo _packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
  );
  @override
  void initState() {
    super.initState();
    _initPackageInfo();
  }

  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      '${_packageInfo.appName} - v${_packageInfo.version}',
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: Colors.grey.shade600,
        fontSize: 12,
        fontWeight: FontWeight.w400,
      ),
    );
  }
}
