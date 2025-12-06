import 'package:flutter/material.dart';
import '../../../domain/domain.dart';
import '../../../app/app.dart';
import '../../ui.dart';

class FlowCard extends StatelessWidget {
  const FlowCard({super.key, required this.post});
  final Post post;

  Color _getBorderColor(ContentType contentType) {
    switch (contentType) {
      case ContentType.dua:
        return AppColors.primary;
      case ContentType.hadis:
        return AppColors.secondary;
      case ContentType.ayet:
        return AppColors.success;
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final cardHeight = context.isSmallScreen ? 200.0 : 240.0;

    return GestureDetector(
      onTap: () {
        PostDetailRoute($extra: post).push<void>(context);
      },
      child: SizedBox(
        width: double.infinity,
        height: cardHeight,
        child: Card(
          elevation: 2.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
            side: BorderSide(
              color: _getBorderColor(post.contentType),
              width: 1.0,
            ),
          ),
          child: Padding(
            padding: context.containerPadding,
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      post.title,
                      style: textTheme.titleLarge?.copyWith(
                        fontSize: context.responsiveFontSize(
                          textTheme.titleLarge?.fontSize,
                        ),
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: context.spacingSmall),
                    // Content
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Arabic Content (if available)
                        if (post.arabicContent != null &&
                            post.arabicContent!.isNotEmpty) ...[
                          SizedBox(height: context.spacingExtraSmall),
                          Directionality(
                            textDirection: TextDirection.rtl,
                            child: Text(
                              post.arabicContent!,
                              style: textTheme.bodyMedium?.copyWith(
                                fontSize: context.responsiveFontSize(
                                  (textTheme.bodyMedium?.fontSize ?? 14) * 1.1,
                                ),
                                height: 1.5,
                                fontFeatures: const [
                                  FontFeature.enable('liga'),
                                ],
                              ),
                              textAlign: TextAlign.right,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          // Turkish Content
                          Text(
                            post.content,
                            style: textTheme.bodyMedium?.copyWith(
                              fontSize: context.responsiveFontSize(
                                textTheme.bodyMedium?.fontSize,
                              ),
                              height: 1.5,
                            ),
                            maxLines: context.isSmallScreen ? 3 : 4,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
                // Three dots menu (top right)
                Positioned(
                  top: 0,
                  right: 0,
                  child: ContentTypeBadge(type: post.contentType),
                ),
                // Content Type Badge (bottom left)
                Positioned(
                  bottom: 0,
                  left: 0,
                  child: ContentTypeBadge(type: post.contentType),
                ),
                // Save Button (bottom right)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: SaveButton(isSaved: true),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
