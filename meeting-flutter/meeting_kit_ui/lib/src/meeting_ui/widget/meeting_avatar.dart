// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_ui;

/// [Design Doc](https://www.figma.com/file/SBuppk9FelS12Ft6b5nVHk/%E7%BD%91%E6%98%93%E4%BC%9A%E8%AE%AE?node-id=13001%3A41971&mode=dev)
class AvatarTextStyle {
  /// 单个中文字体大小
  final double fontSizeOneChinese;

  /// 两个中文字体大小
  final double fontSizeTwoChinese;

  /// 单/多英文字母字体大小
  final double fontSizeLetter;

  /// 字体颜色
  final Color color;

  const AvatarTextStyle({
    required this.fontSizeOneChinese,
    required this.fontSizeTwoChinese,
    required this.fontSizeLetter,
    this.color = Colors.white,
  });
}

const _smallTextStyle = AvatarTextStyle(
  fontSizeOneChinese: 12,
  fontSizeTwoChinese: 10,
  fontSizeLetter: 12,
);

const _mediumTextStyle = AvatarTextStyle(
  fontSizeOneChinese: 15,
  fontSizeTwoChinese: 12,
  fontSizeLetter: 14,
);

const _largeTextStyle = AvatarTextStyle(
  fontSizeOneChinese: 16,
  fontSizeTwoChinese: 14,
  fontSizeLetter: 15,
);

const _xlargeTextStyle = AvatarTextStyle(
  fontSizeOneChinese: 22,
  fontSizeTwoChinese: 18,
  fontSizeLetter: 20,
);

const _xxlargeTextStyle = AvatarTextStyle(
  fontSizeOneChinese: 28,
  fontSizeTwoChinese: 24,
  fontSizeLetter: 26,
);

class NEMeetingAvatar extends StatelessWidget {
  /// 头像尺寸
  final double size;

  /// 头像昵称
  final String? name;

  /// 头像昵称文本样式
  final AvatarTextStyle textStyle;

  /// 头像地址
  final String? url;

  const NEMeetingAvatar({
    super.key,
    required this.size,
    this.name,
    this.url,
    required this.textStyle,
  }) : assert(name != null || url != null);

  NEMeetingAvatar.small({
    super.key,
    this.name,
    this.url,
  })  : size = 24,
        textStyle = _smallTextStyle;

  NEMeetingAvatar.medium({
    super.key,
    this.name,
    this.url,
  })  : size = 32,
        textStyle = _mediumTextStyle;

  NEMeetingAvatar.large({
    super.key,
    this.name,
    this.url,
  })  : size = 36,
        textStyle = _largeTextStyle;

  NEMeetingAvatar.xlarge({
    super.key,
    this.name,
    this.url,
  })  : size = 48,
        textStyle = _xlargeTextStyle;

  NEMeetingAvatar.xxlarge({
    super.key,
    this.name,
    this.url,
  })  : size = 64,
        textStyle = _xxlargeTextStyle;

  @override
  Widget build(BuildContext context) {
    var name = this.name;
    double fontSize = 0;
    if (name != null) {
      final chinese = <String>[];
      final letters = <String>[];
      final digits = <String>[];
      name.characters.forEach((value) {
        if (StringUtil.isChinese(value)) {
          chinese.add(value);
        } else if (StringUtil.isLetter(value)) {
          letters.add(value);
        } else if (StringUtil.isDigit(value)) {
          digits.add(value);
        }
      });
      if (chinese.isNotEmpty) {
        fontSize = chinese.length >= 2
            ? textStyle.fontSizeTwoChinese
            : textStyle.fontSizeOneChinese;
        name = chinese.sublist(max(0, chinese.length - 2)).join();
      } else if (letters.isNotEmpty) {
        fontSize = textStyle.fontSizeLetter;
        letters[0] = letters[0].toUpperCase();
        name = letters.sublist(0, min(2, letters.length)).join();
      } else if (digits.isNotEmpty) {
        fontSize = textStyle.fontSizeLetter;
        name = digits.sublist(max(0, digits.length - 2)).join();
      } else {
        name = '*';
        fontSize = textStyle.fontSizeOneChinese;
      }
    }

    final url = this.url;

    return ClipOval(
      child: Container(
        height: size,
        width: size,
        decoration: ShapeDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[_UIColors.blue_5996FF, _UIColors.blue_2575FF],
          ),
          shape: CircleBorder(),
        ),
        foregroundDecoration: url != null &&
                (url.startsWith('http://') || url.startsWith('https://'))
            ? BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(url),
                  fit: BoxFit.cover,
                ),
                shape: BoxShape.circle,
              )
            : null,
        alignment: Alignment.center,
        child: name == '*'
            ? LayoutBuilder(
                builder: (context, constraints) {
                  return Icon(
                    NEMeetingIconFont.icon_asterisk,
                    size: constraints.maxWidth * 0.3,
                    color: textStyle.color,
                  );
                },
              )
            : (name != null
                ? Text(
                    name,
                    style: TextStyle(
                      fontSize: fontSize,
                      color: Colors.white,
                      decoration: TextDecoration.none,
                    ),
                  )
                : null),
      ),
    );
  }
}
