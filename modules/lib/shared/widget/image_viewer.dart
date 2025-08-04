import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ImageViewer extends StatelessWidget {
  ImageViewer({super.key});
  final String imageUrl = Get.arguments['imageUrl'];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 去除默认的 AppBar
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        // 设置为透明背景
        backgroundColor: Colors.transparent,
        // 去除阴影
        elevation: 0,
        // 左上方添加返回按钮
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        color: Colors.black,
        child: Center(
          // 使用 InteractiveViewer 实现双指捏合缩放和拖动
          child: InteractiveViewer(
            minScale: 0.5,
            maxScale: 4.0,
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              placeholder:
                  (context, url) => Container(
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(width: 32, height: 32, child: const CircularProgressIndicator(color: Colors.white)),
                  ),
            ),
          ),
        ),
      ),
    );
  }
}

class ImageViewerViewController extends GetxController {
  final String imageUrl;
  ImageViewerViewController(this.imageUrl);
}
