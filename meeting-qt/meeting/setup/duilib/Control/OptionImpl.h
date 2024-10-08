﻿// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

template <typename InheritType>
OptionTemplate<InheritType>::~OptionTemplate() {
    if (!m_sGroupName.empty() && m_pWindow)
        m_pWindow->RemoveOptionGroup(m_sGroupName, this);
}

template <typename InheritType>
void OptionTemplate<InheritType>::SetWindow(Window* pManager, Box* pParent, bool bInit) {
    __super::SetWindow(pManager, pParent, bInit);
    if (bInit && !m_sGroupName.empty()) {
        if (m_pWindow)
            m_pWindow->AddOptionGroup(m_sGroupName, this);
    }
}

template <typename InheritType>
void OptionTemplate<InheritType>::SetAttribute(const std::wstring& pstrName, const std::wstring& pstrValue) {
    if (pstrName == _T("group"))
        SetGroup(pstrValue);
    else
        __super::SetAttribute(pstrName, pstrValue);
}

template <typename InheritType>
void OptionTemplate<InheritType>::SetGroup(const std::wstring& pStrGroupName) {
    if (pStrGroupName.empty()) {
        if (m_sGroupName.empty())
            return;
        m_sGroupName.clear();
    } else {
        if (m_sGroupName == pStrGroupName)
            return;
        if (!m_sGroupName.empty() && m_pWindow)
            m_pWindow->RemoveOptionGroup(m_sGroupName, this);
        m_sGroupName = pStrGroupName;
    }

    if (!m_sGroupName.empty()) {
        if (m_pWindow)
            m_pWindow->AddOptionGroup(m_sGroupName, this);
    } else {
        if (m_pWindow)
            m_pWindow->RemoveOptionGroup(m_sGroupName, this);
    }

    Selected(m_bSelected, true);
}

template <typename InheritType>
std::wstring OptionTemplate<InheritType>::GetGroup() const {
    return m_sGroupName;
}

template <typename InheritType>
void OptionTemplate<InheritType>::Selected(bool bSelected, bool bTriggerEvent) {
    if (m_bSelected == bSelected)
        return;
    m_bSelected = bSelected;

    if (m_pWindow != NULL) {
        if (!m_sGroupName.empty()) {
            if (m_bSelected) {
                std::vector<Control*>* aOptionGroup = m_pWindow->GetOptionGroup(m_sGroupName);
                for (auto it = aOptionGroup->begin(); it != aOptionGroup->end(); it++) {
                    auto pControl = static_cast<OptionTemplate<InheritType>*>(*it);
                    if (pControl != this) {
                        pControl->Selected(false, bTriggerEvent);
                    }
                }
                if (bTriggerEvent) {
                    m_pWindow->SendNotify(this, EventType::SELECT);
                }
            } else {
                m_pWindow->SendNotify(this, EventType::UNSELECT);
            }
        } else {
            ASSERT(FALSE);
        }
    }

    Invalidate();
}

template <typename InheritType>
void OptionTemplate<InheritType>::Activate() {
    if (!IsActivatable())
        return;
    if (!m_sGroupName.empty()) {
        Selected(true, true);
    } else {
        ASSERT(FALSE);
    }
}
