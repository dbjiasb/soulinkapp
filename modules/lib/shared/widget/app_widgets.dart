import 'package:flutter/material.dart';

class AppWidgets {

  static userTag(int type) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Image.asset(
        'packages/modules/assets/images/ic_tag_${type == 0 ? 'real':'ai'}.png',
        height: 8,
        fit: BoxFit.fitHeight,
      )
    );
  }

}