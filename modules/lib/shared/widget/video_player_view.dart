// 用Getx库实现一个视频播放器，播放器接受 videoUrl 作为参数，并播放视频
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerView extends StatelessWidget {
  VideoPlayerView({super.key});

  VideoPlayerViewController viewController = Get.put(VideoPlayerViewController());

  @override
  Widget build(BuildContext context) {
    VideoPlayerController playerController = viewController.playerController;
    return Scaffold(
      // 去掉标题栏，设置背景为黑色
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white), // 设置返回按钮为白色
        title: null, // 去掉标题
        elevation: 0, // 去掉阴影
      ),
      backgroundColor: Colors.black, // 设置页面背景为黑色
      body: FutureBuilder(
        future: viewController.initializeVideoPlayerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // 视频初始化完成，显示视频播放器
            return AspectRatio(aspectRatio: playerController.value.aspectRatio, child: VideoPlayer(playerController));
          } else {
            // 视频正在初始化，显示加载指示器
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.transparent,
        onPressed: () {
          if (playerController.value.isPlaying) {
            playerController.pause();
          } else {
            playerController.play();
          }
        },
        // child: Icon(playerController.value.isPlaying ? Icons.pause : Icons.play_arrow),
        child: Container(
          // padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(60)),
          child: Center(child: Obx(() => Icon(viewController.isPlaying.value ? Icons.pause : Icons.play_arrow, color: Colors.white, size: 32))),
        ),
      ),
    );
  }
}

class VideoPlayerViewController extends GetxController {
  late VideoPlayerController playerController;
  late Future<void> initializeVideoPlayerFuture;

  String get videoUrl => Get.arguments['videoUrl'] ?? '';

  var isPlaying = false.obs;

  @override
  void onInit() {
    super.onInit();

    playerController = VideoPlayerController.networkUrl(Uri.parse(videoUrl));
    //     // 初始化视频播放器
    initializeVideoPlayerFuture = playerController.initialize().then((_) {
      // 视频初始化完成后自动播放
      // if (mounted) {
      playerController.play();
      isPlaying.value = true;
      // }
    });
    // 循环播放视频
    playerController.setLooping(true);
    // 添加监听器，当控制器状态变化时更新 UI
    playerController.addListener(() {
      if (playerController.value.isPlaying) {
        isPlaying.value = true;
      } else {
        isPlaying.value = false;
      }
    });
  }

  @override
  void onClose() {
    playerController.removeListener(() {});
    // 释放控制器资源
    playerController.dispose();
  }

  @override
  void dispose() {
    // 移除监听器
    super.dispose();
  }
}
