import 'package:flutter/material.dart';

import '../../../app/app.dart';
import '../../../domain/domain.dart';
import '../../ui.dart';

class ReportPostBottomSheet extends StatefulWidget {
  const ReportPostBottomSheet({
    super.key,
    required this.post,
    required this.postReportViewModel,
  });

  final Post post;
  final PostReportViewModel postReportViewModel;

  @override
  State<ReportPostBottomSheet> createState() => _ReportPostBottomSheetState();
}

class _ReportPostBottomSheetState extends State<ReportPostBottomSheet> {
  String? _selectedReason;
  String _otherReason = '';

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    final textTheme = Theme.of(context).textTheme;
    final reasons = <String>[
      'Yanıltıcı veya yanlış bilgi',
      'Uygunsuz dil veya içerik',
      'Diğer',
    ];

    final bool isOtherSelected = _selectedReason == 'Diğer';
    final bool canSend =
        _selectedReason != null &&
        (!isOtherSelected || _otherReason.trim().isNotEmpty);

    return Padding(
      padding: EdgeInsets.only(
        left: responsive.horizontalPadding,
        right: responsive.horizontalPadding,
        top: responsive.spacingMedium,
        bottom:
            MediaQuery.of(context).viewInsets.bottom + responsive.spacingMedium,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Text(
            'Gönderiyi şikayet et',
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'Lütfen bu gönderiyi neden şikayet etmek istediğinizi seçin.',
            style: textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),
          RadioGroup<String>(
            groupValue: _selectedReason,
            onChanged: (value) {
              setState(() {
                _selectedReason = value;
                if (_selectedReason != 'Diğer') {
                  _otherReason = '';
                }
              });
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ...reasons.map(
                  (reason) => RadioListTile<String>(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: Text(reason, style: textTheme.bodyMedium),
                    value: reason,
                  ),
                ),
              ],
            ),
          ),
          if (isOtherSelected) ...[
            const SizedBox(height: 8),
            TextField(
              maxLines: 3,
              onChanged: (value) {
                setState(() {
                  _otherReason = value;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Şikayet nedeninizi yazın',
                border: OutlineInputBorder(),
              ),
            ),
          ],
          SizedBox(height: responsive.spacingMedium),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Vazgeç'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: AppButton(
                  onPressed: () async {
                    if (!canSend) return;
                    await widget.postReportViewModel.reportPost.execute((
                      reportedPostId: widget.post.id,
                      reason: _selectedReason == 'Diğer'
                          ? _otherReason.trim()
                          : _selectedReason!,
                    ));
                    if (context.mounted) {
                      Navigator.of(context).pop();
                    }
                  },
                  text: 'Şikayeti Gönder',
                  running: widget.postReportViewModel.reportPost.running,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
