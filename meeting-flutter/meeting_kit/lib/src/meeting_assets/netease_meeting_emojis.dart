// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_assets;

class NEMeetingEmojis {
  static const String package = meetingAssetsPackageName;

  static const _emojiMap = {
    '[大笑]': 'a-1.png',
    '[开心]': 'a-2.png',
    '[色]': 'a-3.png',
    '[酷]': 'a-4.png',
    '[奸笑]': 'a-5.png',
    '[亲]': 'a-6.png',
    '[伸舌头]': 'a-7.png',
    '[眯眼]': 'a-8.png',
    '[可爱]': 'a-9.png',
    '[鬼脸]': 'a-10.png',
    '[偷笑]': 'a-11.png',
    '[喜悦]': 'a-12.png',
    '[狂喜]': 'a-13.png',
    '[惊讶]': 'a-14.png',
    '[流泪]': 'a-15.png',
    '[流汗]': 'a-16.png',
    '[天使]': 'a-17.png',
    '[笑哭]': 'a-18.png',
    '[尴尬]': 'a-19.png',
    '[惊恐]': 'a-20.png',
    '[大哭]': 'a-21.png',
    '[烦躁]': 'a-22.png',
    '[恐怖]': 'a-23.png',
    '[两眼冒星]': 'a-24.png',
    '[害羞]': 'a-25.png',
    '[睡着]': 'a-26.png',
    '[冒星]': 'a-27.png',
    '[口罩]': 'a-28.png',
    '[OK]': 'a-29.png',
    '[好吧]': 'a-30.png',
    '[鄙视]': 'a-31.png',
    '[难受]': 'a-32.png',
    '[不屑]': 'a-33.png',
    '[不舒服]': 'a-34.png',
    '[愤怒]': 'a-35.png',
    '[鬼怪]': 'a-36.png',
    '[发怒]': 'a-37.png',
    '[生气]': 'a-38.png',
    '[不高兴]': 'a-39.png',
    '[皱眉]': 'a-40.png',
    '[心碎]': 'a-41.png',
    '[心动]': 'a-42.png',
    '[好的]': 'a-43.png',
    '[低级]': 'a-44.png',
    '[赞]': 'a-45.png',
    '[鼓掌]': 'a-46.png',
    '[给力]': 'a-47.png',
    '[打你]': 'a-48.png',
    '[阿弥陀佛]': 'a-49.png',
    '[拜拜]': 'a-50.png',
    '[第一]': 'a-51.png',
    '[拳头]': 'a-52.png',
    '[手掌]': 'a-53.png',
    '[剪刀]': 'a-54.png',
    '[招手]': 'a-55.png',
    '[不要]': 'a-56.png',
    '[举着]': 'a-57.png',
    '[思考]': 'a-58.png',
    '[猪头]': 'a-59.png',
    '[不听]': 'a-60.png',
    '[不看]': 'a-61.png',
    '[不说]': 'a-62.png',
    '[猴子]': 'a-63.png',
    '[炸弹]': 'a-64.png',
    '[睡觉]': 'a-65.png',
    '[筋斗云]': 'a-66.png',
    '[火箭]': 'a-67.png',
    '[救护车]': 'a-68.png',
  };

  static bool hasEmoji(String tag) => _emojiMap.containsKey(tag);

  static List<String> get emojiTags => _emojiMap.keys.toList();

  static Image assetImage(String tag,
          {double? width, double? height, BoxFit? fit}) =>
      Image.asset(
        'assets/emojis/${_emojiMap[tag]}',
        package: meetingAssetsPackageName,
        width: width,
        height: height,
        fit: fit,
      );

  static AssetImage assetImageProvider(String tag) =>
      AssetImage('assets/emojis/${_emojiMap[tag]}',
          package: meetingAssetsPackageName);
}
