import 'package:modules/base/assets/image_path.dart';
import 'package:modules/base/crypt/security.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:modules/base/router/router_names.dart';
import 'package:modules/core/account/account_service.dart';

enum BalanceType { coin, gem }

class BalanceViewStyle {
  final Color color; // 添加final
  final Color bgColor;
  final double height;
  final double borderRadius;
  final double padding;
  const BalanceViewStyle({
    // 添加const构造函数
    required this.color,
    required this.bgColor,
    required this.height,
    required this.borderRadius,
    required this.padding,
  });

  static const defaultStyle = BalanceViewStyle(
    // 改为const常量
    color: Colors.white,
    bgColor: Color(0x1AFFFFFF),
    height: 20,
    borderRadius: 10,
    padding: 4,
  );
}

class BalanceView extends StatelessWidget {
  final BalanceType type;
  final BalanceViewStyle style;
  const BalanceView({
    super.key,
    required this.type,
    this.style = BalanceViewStyle.defaultStyle, // 使用const常量
  });

  String get icon => type == BalanceType.coin ? ImagePath.coin : ImagePath.gem;

  String get addIcon => ImagePath.icon_add;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.toNamed(Routers.rechargeCurrency.name, arguments: {Security.security_rcgType: type == BalanceType.coin ? 0 : 1});
      },
      child: Container(
        height: style.height,
        decoration: BoxDecoration(color: style.bgColor, borderRadius: BorderRadius.all(Radius.circular(style.borderRadius))),
        padding: EdgeInsets.symmetric(horizontal: style.padding),
        child: Row(
          children: [
            Image.asset(icon, width: 16, height: 16),
            SizedBox(width: 4),
            Obx(
              () => Text(
                type == BalanceType.coin ? MyAccount.coins.toString() : MyAccount.gems.toString(),
                style: TextStyle(fontSize: 11, color: style.color, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(width: 4),
            Image.asset(
              addIcon,
              width: 12,
              height: 12,
              color: style.color, // 使用style中的颜色
              colorBlendMode: BlendMode.srcIn, // 确保颜色混合模式正确
            ),
          ],
        ),
      ),
    );
  }
}
