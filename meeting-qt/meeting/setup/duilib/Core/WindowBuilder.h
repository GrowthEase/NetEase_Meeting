﻿// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#ifndef UI_CORE_WINDOWBUILDER_H_
#define UI_CORE_WINDOWBUILDER_H_

#pragma once

namespace ui {

class Box;
class Window;

typedef std::function<Control*(const std::wstring&)> CreateControlCallback;

class UILIB_API WindowBuilder {
public:
    WindowBuilder();

    UI_FORBID_COPY(WindowBuilder)

    Box* Create(STRINGorID xml,
                CreateControlCallback pCallback = CreateControlCallback(),
                Window* pManager = nullptr,
                Box* pParent = nullptr,
                Box* userDefinedBox = nullptr);
    Box* Create(CreateControlCallback pCallback = CreateControlCallback(),
                Window* pManager = nullptr,
                Box* pParent = nullptr,
                Box* userDefinedBox = nullptr);

    CMarkup* GetMarkup();

    void GetLastErrorMessage(LPTSTR pstrMessage, SIZE_T cchMax) const;
    void GetLastErrorLocation(LPTSTR pstrSource, SIZE_T cchMax) const;

private:
    Control* _Parse(CMarkupNode* parent, Control* pParent = NULL, Window* pManager = NULL);
    Control* GetUiLibControl(const std::wstring& pstrClass);
    bool AttachXmlEvent(const std::wstring& pstrClass, CMarkupNode& node, Control* pParent);

private:
    CMarkup m_xml;
    CreateControlCallback m_createControlCallback;
};

}  // namespace ui

#endif  // UI_CORE_WINDOWBUILDER_H_
