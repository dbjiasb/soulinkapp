import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:modules/shared/app_theme.dart';

import './chat_cell.dart';
import './chat_system_message.dart';

class ChatSystemCell extends ChatCell {
  ChatSystemCell(super.message);
  ChatSystemMessage get systemMessage => message as ChatSystemMessage;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 70, vertical: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          children: [
            BackdropFilter(filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0), child: Container(color: Colors.transparent, width: double.infinity)),
            Container(
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(22), color: Color(0xFF000000).withValues(alpha: 0.2)),
              child: Text('Notice: Everything AI says is made up', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: AppFonts.medium)),
            ),
          ],
        ),
      ),
    );
  }
}
