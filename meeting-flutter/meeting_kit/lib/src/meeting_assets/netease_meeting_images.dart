// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_assets;

class NEMeetingImages {
  static const String package = meetingAssetsPackageName;

  static const String meetingJoin = "assets/images/icon_meeting_joining.png";
  static const String hangup = "assets/images/icon_hangup.png";
  static const String call = "assets/images/icon_call.png";
  static const String controlCreateMeeting =
      "assets/images/icon_control_create_meeting.png";
  static const String controlJoinMeeting =
      "assets/images/icon_control_join_meeting.png";
  static const String controlDisconnectMeeting =
      "assets/images/icon_control_disconnect_meeting.png";
  static const String stopMeeting =
      "assets/images/icon_control_stop_meeting.png";
  static const String leaveMeeting =
      "assets/images/icon_control_leave_meeting.png";
  static const String arrowRightGray = "assets/images/right_gray.png";
  static const String arrowRightWhite = "assets/images/right_white.png";
  static const String arrowLeftWhite = "assets/images/left_white.png";
  static const String otherFile = "assets/images/icon_other.png";
  static const String excelFile = "assets/images/icon_excel.png";
  static const String compressFile = "assets/images/icon_compress.png";
  static const String pdfFile = "assets/images/icon_pdf.png";
  static const String pptFile = "assets/images/icon_ppt.png";
  static const String wordFile = "assets/images/icon_word.png";
  static const String waitingRoomBackground =
      "assets/images/waiting_room_background.png";

  static const String bricksBackGround = "assets/images/sticker/bricks.jpg";
  static const String interiorDesignBackGround =
      "assets/images/sticker/interior_design.jpg";
  static const String meetingRoomBackGround =
      "assets/images/sticker/meeting_room.jpg";
  static const String pixelsPicasaBackGround =
      "assets/images/sticker/pixels_picasa.jpg";
  static const String pixelsKaterinaHolmesBackGround =
      "assets/images/sticker/pixels_katerina_holmes.jpg";
  static const String whiteboardBackGround =
      "assets/images/sticker/whiteboard.jpg";

  static const String fileTypeAudio = 'assets/images/icon_file_type_audio.png';
  static const String fileTypeVideo = 'assets/images/icon_file_type_video.png';
  static const String fileTypeTxt = 'assets/images/icon_file_type_txt.png';
  static const String fileTypeZip = 'assets/images/icon_file_type_zip.png';
  static const String fileTypeWord = 'assets/images/icon_file_type_word.png';
  static const String fileTypeExcel = 'assets/images/icon_file_type_excel.png';
  static const String fileTypePpt = 'assets/images/icon_file_type_ppt.png';
  static const String fileTypePicture =
      'assets/images/icon_file_type_picture.png';
  static const String fileTypePdf = 'assets/images/icon_file_type_pdf.png';
  static const String fileTypeUnknown =
      'assets/images/icon_file_type_unknown.png';
  static const String arrow = 'assets/images/arrow.png';
  static const String noMessageHistory = 'assets/images/no_message_history.png';
  static const String noNotifyMessageHistory =
      'assets/images/no_notify_message.png';
  static const String iconContacts = 'assets/images/icon_contacts.png';
  static const String iconEmptyContacts =
      'assets/images/icon_empty_contacts.png';
  static const String iconCircleChecked =
      'assets/images/icon_circle_checked.png';
  static const String iconCircleUnchecked =
      'assets/images/icon_circle_unchecked.png';
  static const String iconCircleCheckedImmutable =
      'assets/images/icon_circle_checked_immutable.png';
  static const String iconNoContacts = 'assets/images/no_contacts.png';
  static const String iconSearchContacts = 'assets/images/search_contacts.png';
  static const String callLoadingGif = 'assets/images/call_loading.gif';
  static const String iconBulletScreenEnabled =
      'assets/images/icon_bullet_screen_enabled.png';
  static const String iconBulletScreenDisabled =
      'assets/images/icon_bullet_screen_disabled.png';
  static const String iconHandsUp = 'assets/images/icon_hands_up.png';
  static const String iconNoContent = 'assets/images/icon_no_content.png';

  static Image assetImage(String image,
          {double? width, double? height, BoxFit? fit}) =>
      Image.asset(
        image,
        package: meetingAssetsPackageName,
        width: width,
        height: height,
        fit: fit,
      );

  static AssetImage assetImageProvider(String image) =>
      AssetImage(image, package: meetingAssetsPackageName);
}

const List<String> backGroundList = [
  NEMeetingImages.bricksBackGround,
  NEMeetingImages.interiorDesignBackGround,
  NEMeetingImages.meetingRoomBackGround,
  NEMeetingImages.pixelsPicasaBackGround,
  NEMeetingImages.pixelsKaterinaHolmesBackGround,
  NEMeetingImages.whiteboardBackGround,
  NEMeetingImages.bricksBackGround,
  NEMeetingImages.interiorDesignBackGround,
  NEMeetingImages.meetingRoomBackGround,
  NEMeetingImages.pixelsPicasaBackGround,
  NEMeetingImages.pixelsKaterinaHolmesBackGround,
  NEMeetingImages.whiteboardBackGround,
];
