import 'package:flutter/material.dart';

import '../../../../app/app.dart';

/// Zikir önerilerini gösteren bottom sheet widget'ı
class DhikrSuggestionsBottomSheet extends StatelessWidget {
  const DhikrSuggestionsBottomSheet({super.key, required this.onDhikrSelected});

  /// Zikir seçildiğinde çağrılacak callback
  final ValueChanged<String> onDhikrSelected;

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    final textTheme = Theme.of(context).textTheme;

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
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: EdgeInsets.only(bottom: responsive.spacingMedium),
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Başlık
          Text(
            'Zikir Öner',
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: responsive.spacingSmall),
          Text(
            'Seçmek istediğiniz zikir\'e tıklayın.',
            style: textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
          ),
          SizedBox(height: responsive.spacingMedium),
          // Dhikr listesi (scrollable)
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: responsive.screenHeight * 0.6,
            ),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: DhikrSuggestions.suggestions.length,
              separatorBuilder: (context, index) =>
                  Divider(height: 1, color: Colors.grey.shade300),
              itemBuilder: (context, index) {
                final suggestion = DhikrSuggestions.suggestions[index];
                return InkWell(
                  onTap: () {
                    onDhikrSelected(suggestion.name);
                    Navigator.of(context).pop();
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: responsive.spacingSmall,
                      vertical: responsive.spacingMedium,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Arapça metin
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            suggestion.arabic,
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                              fontSize: 20,
                              height: 1.5,
                            ),
                            textDirection: TextDirection.rtl,
                          ),
                        ),
                        SizedBox(height: responsive.spacingExtraSmall),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                suggestion.name,
                                style: textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: Colors.grey.shade600,
                            ),
                          ],
                        ),
                        SizedBox(height: responsive.spacingExtraSmall),
                        // Fayda bilgisi
                        Text(
                          suggestion.benefit,
                          style: textTheme.bodySmall?.copyWith(
                            color: Colors.grey[700],
                            fontSize: 12,
                          ),
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: responsive.spacingMedium),
        ],
      ),
    );
  }
}
