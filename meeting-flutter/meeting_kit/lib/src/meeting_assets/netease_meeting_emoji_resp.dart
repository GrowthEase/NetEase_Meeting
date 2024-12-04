// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_assets;

class NEMeetingEmojiResp {
  static const String package = meetingAssetsPackageName;

  static const _emojiRespMap = {
    '[鼓掌]': '鼓掌.png',
    '[点赞]': '点赞.png',
    '[爱心]': '爱心.png',
    '[笑哭]': '笑哭.png',
    '[惊叹]': '惊叹.png',
    '[撒花]': '撒花.png',
  };

  static const _emojiRespCoverMap = {
    '[鼓掌]': '鼓掌_cover.png',
    '[点赞]': '点赞_cover.png',
    '[爱心]': '爱心_cover.png',
    '[笑哭]': '笑哭_cover.png',
    '[惊叹]': '惊叹_cover.png',
    '[撒花]': '撒花_cover.png',
  };

  static bool hasEmojiResp(String? tag) => _emojiRespMap.containsKey(tag);

  static List<String> get emojiRespTags => _emojiRespMap.keys.toList();

  static Image? assetImage(String? tag,
      {double? width, double? height, bool isCover = false}) {
    final imageAsset = assetImageProvider(tag, isCover);
    if (imageAsset == null) return null;
    return Image(
      image: imageAsset,
      width: width,
      height: height,
    );
  }

  static AssetImage? assetImageProvider(String? tag, bool isCover) => hasEmojiResp(
          tag)
      ? AssetImage(
          'assets/emoji_resp/${isCover ? _emojiRespCoverMap[tag] : _emojiRespMap[tag]}',
          package: meetingAssetsPackageName)
      : null;
}
