import 'package:flutter/material.dart';

import '../../../app/app.dart';
import '../../../domain/domain.dart';
import '../../ui.dart';

class FlowCard extends StatelessWidget {
  const FlowCard({super.key, required this.post});
  final Post post;

  Color _getBorderColor(ContentType contentType) {
    switch (contentType) {
      case ContentType.dua:
        return AppColors.duaColor;
      case ContentType.hadis:
        return AppColors.hadisColor;
      case ContentType.ayet:
        return AppColors.ayetColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final cardHeight = context.isSmallScreen
        ? 250.0
        : context.isMediumScreen
        ? 270.0
        : 320.0;
    return GestureDetector(
      onTap: () {
        PostDetailRoute($extra: post).push<void>(context);
      },
      child: SizedBox(
        width: context.screenWidth * 0.9,
        height: cardHeight,
        child: Card(
          color: Colors.white,
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
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            post.title,
                            style: textTheme.titleMedium?.copyWith(
                              fontSize: context.responsiveFontSize(
                                textTheme.titleMedium?.fontSize,
                              ),
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        PopMenuButton(),
                      ],
                    ),
                    SizedBox(height: context.spacingExtraSmall),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (post.arabicContent != null &&
                              post.arabicContent!.isNotEmpty)
                            Directionality(
                              textDirection: TextDirection.rtl,
                              child: Text(
                                post.arabicContent!,
                                style: textTheme.bodyMedium?.copyWith(
                                  fontSize: context.responsiveFontSize(
                                    (textTheme.bodyMedium?.fontSize ?? 14) *
                                        1.1,
                                  ),
                                  height: 1.5,
                                ),
                                textAlign: TextAlign.right,
                                maxLines: context.isSmallScreen ? 1 : 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          Flexible(
                            child: Text(
                              post.content,
                              style: textTheme.bodyMedium?.copyWith(
                                fontSize: context.responsiveFontSize(
                                  textTheme.bodyMedium?.fontSize,
                                ),
                                height: 1.5,
                              ),
                              maxLines:
                                  post.arabicContent != null &&
                                      post.arabicContent!.isNotEmpty
                                  ? (context.isSmallScreen ? 2 : 3)
                                  : (context.isSmallScreen ? 4 : 5),
                              overflow: TextOverflow.fade,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  child: ContentTypeBadge(type: post.contentType),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: SaveButton(isSaved: false),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
