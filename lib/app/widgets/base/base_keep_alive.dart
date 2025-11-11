import 'package:flutter/widgets.dart';

class BaseKeepAlive extends StatefulWidget {
  const BaseKeepAlive({super.key, required this.child});
  final Widget child;
  @override
  State<BaseKeepAlive> createState() => _BaseKeepAliveState();
}

class _BaseKeepAliveState extends State<BaseKeepAlive>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }

  @override
  bool get wantKeepAlive => true;
}
