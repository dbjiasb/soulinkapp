import 'package:modules/base/assets/image_path.dart';
import 'package:modules/base/crypt/security.dart';
import 'package:flutter/material.dart';

class AppWidgets {

  static userTag(int type,{int? id}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Image.asset(
        id == 100000? ImagePath.ic_tag_official:(type == 0 ? ImagePath.ic_tag_real:ImagePath.ic_tag_ai),
        height: 16,
        fit: BoxFit.fitHeight,
      )
    );
  }

}