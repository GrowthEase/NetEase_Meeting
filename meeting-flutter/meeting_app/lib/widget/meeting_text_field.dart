// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nemeeting/widget/ne_widget.dart';
import 'package:netease_meeting_ui/meeting_ui.dart';
import '../uikit/values/colors.dart';
import '../uikit/values/fonts.dart';

class MeetingTextField extends StatefulWidget {
  final double? width;
  final double? height;
  final double? fontSize;
  final double? hintFontSize;
  final TextEditingController controller;
  final String? hintText;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final bool obscureText;
  final bool showUnderline;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputType? keyboardType;
  final FocusNode? focusNode;
  final GestureTapCallback? onTap;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onEditingComplete;
  final Widget? prefixIcon;

  const MeetingTextField({
    super.key,
    this.width,
    this.height,
    this.fontSize = 16,
    this.hintFontSize = 16,
    required this.controller,
    this.hintText,
    this.textInputAction,
    this.onSubmitted,
    this.inputFormatters,
    this.obscureText = false,
    this.showUnderline = true,
    this.keyboardType,
    this.focusNode,
    this.onTap,
    this.onChanged,
    this.onEditingComplete,
    this.prefixIcon,
  });

  @override
  State<MeetingTextField> createState() => _MeetingTextFieldState();
}

class _MeetingTextFieldState extends State<MeetingTextField> {
  var _obscureText = false;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
  }

  @override
  void didUpdateWidget(covariant MeetingTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.obscureText != widget.obscureText) {
      _obscureText = widget.obscureText;
    }
  }

  @override
  Widget build(BuildContext context) {
    final suffixIcon = ListenableBuilder(
      listenable: widget.controller,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.obscureText) ...[
              NEGestureDetector(
                onTap: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
                child: Icon(
                  _obscureText
                      ? IconFont.iconpassword_hidex
                      : IconFont.iconpassword_displayx,
                  size: 16.r,
                  color: AppColors.color_3C3C43,
                ),
              ),
              if (widget.controller.text.isNotEmpty)
                SizedBox(
                  width: 10.w,
                ),
            ],
            if (widget.focusNode?.hasFocus == true &&
                widget.controller.text.isNotEmpty)
              ClearIconButton(
                size: 20.r,
                onPressed: widget.controller.clear,
              ),
          ],
        );
      },
    );
    final child = TextField(
      onChanged: widget.onChanged,
      obscureText: _obscureText,
      controller: widget.controller,
      keyboardType: widget.keyboardType,
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: TextStyle(
          color: AppColors.greyB0B6BE,
          fontSize: widget.hintFontSize ?? 16.spMin,
        ),
        border: widget.showUnderline
            ? MaterialStateUnderlineInputBorder.resolveWith(
                (states) {
                  final focused = states.hasFocused;
                  return UnderlineInputBorder(
                    borderSide: BorderSide(
                      width: 1.h,
                      color: focused
                          ? AppColors.blue_337eff
                          : AppColors.colorDCDFE5,
                    ),
                  );
                },
              )
            : InputBorder.none,
        prefixIcon: widget.prefixIcon,
        prefixIconConstraints: widget.prefixIcon != null
            ? BoxConstraints.tight(
                Size.square(24.r),
              )
            : null,
        prefix: widget.prefixIcon != null
            ? SizedBox(
                width: 8.w,
              )
            : null,
        suffix: suffixIcon,
      ),
      textInputAction: widget.textInputAction,
      style: TextStyle(
        color: AppColors.color_333333,
        fontSize: widget.fontSize ?? 16.spMin,
      ),
      maxLines: 1,
      focusNode: widget.focusNode,
      onTap: widget.onTap,
      inputFormatters: widget.inputFormatters,
      onSubmitted: widget.onSubmitted,
      onEditingComplete: widget.onEditingComplete,
    );
    return widget.width != null || widget.height != null
        ? SizedBox(
            width: widget.width,
            height: widget.height,
            child: child,
          )
        : child;
  }
}

class MeetingActionButton extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;

  const MeetingActionButton({super.key, required this.text, this.onTap});

  @override
  Widget build(BuildContext context) {
    double opacity = onTap != null ? 1 : 0.6;
    return NEGestureDetector(
      child: Container(
        height: 48,
        decoration: ShapeDecoration(
          color: AppColors.accentElement.withOpacity(opacity),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.secondaryText.withOpacity(opacity),
            fontWeight: FontWeight.w400,
            fontSize: 16.spMin,
            decoration: TextDecoration.none,
          ),
        ),
      ),
      onTap: () {
        onTap?.call();
      },
    );
  }
}
