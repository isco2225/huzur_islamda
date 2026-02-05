import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../data/data.dart';
import '../../../../domain/domain.dart';
import '../../../ui.dart';

class PostDetailScreen extends StatefulWidget {
  const PostDetailScreen({super.key, required this.post});

  final Post post;

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  late final PostReportViewModel _postReportViewModel;
  @override
  void initState() {
    super.initState();
    _postReportViewModel = PostReportViewModel(
      reportRepository: context.read<ReportRepository>(),
      userRepository: context.read<UserRepository>(),
    );
    _postReportViewModel.reportPost.handleCompleted(
      context,
      successMessage: 'Şikayetiniz alındı!',
    );
  }

  @override
  void dispose() {
    _postReportViewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PostDetailView(
      post: widget.post,
      postReportViewModel: _postReportViewModel,
    );
  }
}
