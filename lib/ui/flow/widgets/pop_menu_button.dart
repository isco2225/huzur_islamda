import 'package:flutter/material.dart';

import '../../../app/app.dart';
import '../../../domain/domain.dart';
import '../../ui.dart';

class PopMenuButton extends StatelessWidget {
  const PopMenuButton({
    super.key,
    required this.post,
    required this.postReportViewModel,
  });
  final Post post;
  final PostReportViewModel postReportViewModel;
  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert, size: responsive.isSmallScreen ? 20.0 : 24.0),

      itemBuilder: (context) => [
        PopupMenuItem(
          onTap: () {
            _showReportBottomSheet(context);
          },
          value: 'report',
          child: Row(
            children: [
              Icon(Icons.flag_outlined, size: 20),
              SizedBox(width: 8),
              Text('Şikayet Et'),
            ],
          ),
        ),
      ],
    );
  }

  void _showReportBottomSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return SingleChildScrollView(
          child: ReportPostBottomSheet(
            post: post,
            postReportViewModel: postReportViewModel,
          ),
        );
      },
    );
  }
}
