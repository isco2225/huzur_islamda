import 'package:flutter/material.dart';

import '../../../../app/app.dart';
import '../../../../domain/domain.dart';
import '../../../ui.dart';

class PostDetailView extends StatelessWidget {
  const PostDetailView({super.key, required this.post});

  final Post post;

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    final textTheme = Theme.of(context).textTheme;

    return BaseScaffold(
      safeArea: true,
      appBar: AppBar(
        leading: const SafeBackButton(),
        title: const Text('Gönderi Detayı'),
        backgroundColor: AppColors.background,
        elevation: 0,
        actions: const [PopMenuButton()],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implement save functionality
        },
        backgroundColor: AppColors.background,
        child: Icon(Icons.bookmark_border, color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(responsive.horizontalPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              post.title,
              style: textTheme.headlineSmall?.copyWith(
                fontSize: responsive.responsiveFontSize(
                  textTheme.headlineSmall?.fontSize,
                ),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: responsive.spacingMedium),
            // Content Type Badge
            ContentTypeBadge(type: post.contentType),
            // Arabic Content (if available)
            if (post.arabicContent != null &&
                post.arabicContent!.isNotEmpty) ...[
              SizedBox(height: responsive.spacingLarge),
              Divider(color: Colors.grey[300]),
              SizedBox(height: responsive.spacingMedium),
              Directionality(
                textDirection: TextDirection.rtl,
                child: Text(
                  post.arabicContent!,
                  style: textTheme.bodyLarge?.copyWith(
                    fontSize: responsive.responsiveFontSize(
                      (textTheme.bodyLarge?.fontSize ?? 16) * 1.2,
                    ),
                    height: 1.8,
                    fontFeatures: const [FontFeature.enable('liga')],
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
            SizedBox(height: responsive.spacingLarge),
            // Content
            Text(
              post.content,
              style: textTheme.bodyLarge?.copyWith(
                fontSize: responsive.responsiveFontSize(
                  textTheme.bodyLarge?.fontSize,
                ),
                height: 1.8,
              ),
            ),
            SizedBox(height: responsive.spacingExtraLarge),
            // Kaynak (Source)
            Divider(color: Colors.grey[300]),
            SizedBox(height: responsive.spacingMedium),
            Text(
              'Kaynak',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: responsive.spacingSmall),
            Text(
              post.source,
              style: textTheme.bodyMedium?.copyWith(
                fontSize: responsive.responsiveFontSize(
                  textTheme.bodyMedium?.fontSize,
                ),
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: responsive.spacingLarge),
          ],
        ),
      ),
    );
  }
}
