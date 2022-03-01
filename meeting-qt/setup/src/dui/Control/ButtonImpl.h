/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */




template<typename InheritType>
ButtonTemplate<InheritType>::ButtonTemplate()
{
	m_uTextStyle =  DT_VCENTER | DT_CENTER | DT_END_ELLIPSIS | DT_NOCLIP | DT_SINGLELINE;
}

template<typename InheritType>
void ButtonTemplate<InheritType>::HandleMessage(EventArgs& event)
{
	if( !IsMouseEnabled() && event.Type > EventType::MOUSEBEGIN && event.Type < EventType::MOUSEEND ) {
		if( m_pParent != NULL ) m_pParent->HandleMessageTemplate(event);
		else __super::HandleMessage(event);
		return;
	}
	if( event.Type == EventType::KEYDOWN )
	{
		if (IsKeyboardEnabled()) {
			if( event.chKey == VK_SPACE || event.chKey == VK_RETURN ) {
				Activate();
				return;
			}
		}
	}
	if( event.Type == EventType::INTERNAL_CONTEXTMENU )
	{
		if( IsContextMenuUsed() ) {
			m_pWindow->SendNotify(this, EventType::MENU, event.wParam, event.lParam);
		}
		return;
	}

	__super::HandleMessage(event);
}

template<typename InheritType>
void ButtonTemplate<InheritType>::Activate()
{
	if( !IsActivatable() ) return;
	if( m_pWindow != NULL ) m_pWindow->SendNotify(this, EventType::CLICK);
}


