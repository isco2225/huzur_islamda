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
  late final PostSaveViewModel _postSaveViewModel;
  @override
  void initState() {
    super.initState();
    _postReportViewModel = PostReportViewModel(
      reportRepository: context.read<ReportRepository>(),
      userRepository: context.read<UserRepository>(),
    );
    _postSaveViewModel = PostSaveViewModel(
      postRepository: context.read<PostRepository>(),
      userRepository: context.read<UserRepository>(),
      connectivityUseCase: context.read<ConnectivityUseCase>(),
    );
    _postSaveViewModel.savePost.handleError(context, showSnackBar: true);
    _postSaveViewModel.unsavePost.handleError(context, showSnackBar: true);
    _postReportViewModel.reportPost.handleError(context, showSnackBar: true);
    _postReportViewModel.reportPost.handleCompleted(
      context,
      successMessage: 'Şikayetiniz alındı!',
    );
  }

  @override
  void dispose() {
    _postReportViewModel.dispose();
    _postSaveViewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PostDetailView(
      post: widget.post,
      postReportViewModel: _postReportViewModel,
      postSaveViewModel: _postSaveViewModel,
    );
  }
}
