import 'package:flutter/material.dart';
import 'package:modules/base/assets/image_path.dart';

enum ListStatus { idle, loading, success, empty, error }

class ListStatusView extends StatelessWidget {
  final ListStatus status;
  String? emptyDesc;
  String? errorDesc;

  ListStatusView({super.key, required this.status,this.emptyDesc,this.errorDesc});

  Widget buildEmptyView() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(ImagePath.empty_list, width: 156, height: 156),
          Text(emptyDesc ?? 'No data', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xFF9EA1A8))),
        ],
      ),
    );
  }

  Widget buildErrorView() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(ImagePath.empty_list, width: 156, height: 156),
          Text(
            errorDesc ?? 'Network exception, please try again later',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xFF9EA1A8)),
          ),
        ],
      ),
    );
  }

  Widget buildLoadingView() {
    return CircularProgressIndicator(color: Color(0xFFE962F6));
  }

  Widget buildSuccessView() {
    return const SizedBox.shrink();
  }

  Widget buildView(ListStatus status) {
    switch (status) {
      case ListStatus.idle:
        return buildSuccessView();
      case ListStatus.loading:
        return buildLoadingView();
      case ListStatus.empty:
        return buildEmptyView();
      case ListStatus.error:
        return buildErrorView();
      case ListStatus.success:
        return buildSuccessView();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(child: buildView(status));
  }
}

// class ListStatusViewController extends GetxController {
//   var status = ListStatus.idle.obs;
// }
