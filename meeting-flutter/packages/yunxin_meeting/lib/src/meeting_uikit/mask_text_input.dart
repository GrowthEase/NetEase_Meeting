// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_uikit;

class MaskedTextController extends TextEditingController {
  MaskedTextController({String? text, required this.mask, Map<String, RegExp>? translator}) : super(text: text) {
    this.translator = translator ?? MaskedTextController.getDefaultTranslator();

    this.addListener(() {
      this.updateText(this.text);
    });

    this.updateText(this.text);
  }

  String mask;

  late Map<String, RegExp> translator;

  void updateText(String? text) {
    if (text != null) {
      this.text = this._applyMask(this.mask, text);
    } else {
      this.text = '';
    }
  }

  @override
  set text(String newText) {
    if (!TextUtils.isEmpty(newText) && super.text != newText) {
      //super.text = newText;
      int pos = this.selection.baseOffset >= super.text.length ? newText.length : this.selection.baseOffset;
      value =
          value.copyWith(text: newText, selection: TextSelection.collapsed(offset: pos), composing: TextRange.empty);
      //this.moveCursorToEnd();
    }
  }

  static Map<String, RegExp> getDefaultTranslator() {
    return {
      'A': new RegExp(r'[A-Za-z]'),
      '0': new RegExp(r'[0-9]'),
      '@': new RegExp(r'[A-Za-z0-9]'),
      '*': new RegExp(r'.*')
    };
  }

  String _applyMask(String mask, String? value) {
    String result = '';

    var maskCharIndex = 0;
    var valueCharIndex = 0;

    while (true) {
      // if mask is ended, break or if value is ended, break.
      if (maskCharIndex == mask.length || valueCharIndex == value!.length) {
        break;
      }

      var maskChar = mask[maskCharIndex];
      var valueChar = value[valueCharIndex];

      // value equals mask, just set
      if (maskChar == valueChar) {
        result += maskChar;
        valueCharIndex += 1;
        maskCharIndex += 1;
        continue;
      }

      // apply translator if match
      if (this.translator.containsKey(maskChar)) {
        if (this.translator[maskChar]!.hasMatch(valueChar)) {
          result += valueChar;
          maskCharIndex += 1;
        }

        valueCharIndex += 1;
        continue;
      }

      // not masked value, fixed char on mask
      result += maskChar;
      maskCharIndex += 1;
      continue;
    }

    return result;
  }
}
